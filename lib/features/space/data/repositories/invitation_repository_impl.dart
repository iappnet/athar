// lib/features/space/data/repositories/invitation_repository_impl.dart

import 'package:athar/core/services/sync_service.dart';
import 'package:athar/features/space/data/models/invitation_model.dart';
import 'package:athar/features/space/data/models/dto/search_result_dto.dart';
import 'package:athar/features/space/domain/repositories/invitation_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: InvitationRepository)
class InvitationRepositoryImpl implements InvitationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SyncService _syncService;

  InvitationRepositoryImpl(this._syncService);

  // ═══════════════════════════════════════════════════════════════════
  // البحث عن المستخدمين
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<List<SearchResultDto>> searchUsers(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 3) return [];

    try {
      final List<dynamic> response = await _supabase.rpc(
        'search_profile',
        params: {'search_term': normalizedQuery},
      );

      final results = response.map((e) => SearchResultDto.fromJson(e)).toList();
      if (results.isNotEmpty) {
        return results;
      }
    } catch (e) {
      debugPrint('❌ Error searching users: $e');
    }

    try {
      // Include email in select and OR filter so users can be found by email too.
      final orFilter = normalizedQuery.contains('@')
          ? 'email.ilike.%$normalizedQuery%'
          : 'username.ilike.%$normalizedQuery%,full_name.ilike.%$normalizedQuery%,email.ilike.%$normalizedQuery%';

      final response = await _supabase
          .from('profiles')
          .select('user_id, username, full_name, avatar_url, email')
          .or(orFilter)
          .limit(20);

      return (response as List).map((row) {
        final data = Map<String, dynamic>.from(row as Map);
        data['id'] = data['user_id'];
        return SearchResultDto.fromJson(data);
      }).toList();
    } catch (_) {
      // Fallback without email column (older schema)
      try {
        final response = await _supabase
            .from('profiles')
            .select('user_id, username, full_name, avatar_url')
            .or('username.ilike.%$normalizedQuery%,full_name.ilike.%$normalizedQuery%')
            .limit(20);

        return (response as List).map((row) {
          final data = Map<String, dynamic>.from(row as Map);
          data['id'] = data['user_id'];
          return SearchResultDto.fromJson(data);
        }).toList();
      } catch (e) {
        debugPrint('❌ Fallback profile search failed: $e');
        return [];
      }
    }
  }

  Future<void> _ensureNoPendingInvite({
    required String spaceId,
    String? userId,
    String? email,
  }) async {
    try {
      var request = _supabase
          .from('invitations')
          .select('uuid')
          .eq('space_id', spaceId)
          .eq('status', 'pending');

      if (userId != null && userId.isNotEmpty) {
        request = request.eq('invitee_id', userId);
      } else if (email != null && email.isNotEmpty) {
        request = request.eq('invitee_email', email);
      }

      final existingInvite = await request.maybeSingle();
      if (existingInvite != null) {
        throw Exception('يوجد دعوة معلقة لهذا المستخدم');
      }
    } catch (e) {
      if (e.toString().contains('يوجد دعوة معلقة')) {
        rethrow;
      }
    }
  }

  Future<void> _insertInvite({
    required String spaceId,
    String? userId,
    String? email,
  }) async {
    final currentUserId = _supabase.auth.currentUser!.id;
    final token = const Uuid().v4();

    final payload = <String, dynamic>{
      'uuid': const Uuid().v4(),
      'token': token,
      'space_id': spaceId,
      'inviter_id': currentUserId,
      'type': 'direct_user',
      'status': 'pending',
      'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
    if (userId != null && userId.isNotEmpty) payload['invitee_id'] = userId;
    if (email != null && email.isNotEmpty) payload['invitee_email'] = email;

    await _supabase.from('invitations').insert(payload);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ✅✅✅ إرسال دعوة مباشرة - الإصلاح الرئيسي
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> sendDirectInvite({
    required String spaceId,
    required String userId,
    required String userEmail,
  }) async {
    await _ensureNoPendingInvite(spaceId: spaceId, userId: userId);

    // ✅ التحقق من أن المستخدم ليس عضواً بالفعل
    try {
      final existingMember = await _supabase
          .from('space_members')
          .select('user_id')
          .eq('space_id', spaceId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        throw Exception('هذا المستخدم عضو بالفعل في المساحة');
      }
    } catch (e) {
      if (e.toString().contains('عضو بالفعل')) {
        rethrow;
      }
    }

    // profiles لا يحتوي على email في المخطط الحالي، لذا نعتمد على القيمة
    // القادمة من نتيجة البحث/الواجهة ونخزنها إن كانت متوفرة.
    final normalizedEmail = userEmail.trim().toLowerCase();
    final actualEmail = normalizedEmail.isEmpty ? null : normalizedEmail;

    await _insertInvite(spaceId: spaceId, userId: userId, email: actualEmail);

    debugPrint('✅ Invitation sent to user: $userId');

    // ✅ 5. إرسال إشعار (اختياري - يمكن تفعيله لاحقاً)
    // await _sendInvitationNotification(userId, spaceId);
  }

  @override
  Future<void> sendEmailInvite({
    required String spaceId,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw Exception('البريد الإلكتروني غير صالح');
    }

    await _ensureNoPendingInvite(spaceId: spaceId, email: normalizedEmail);
    await _insertInvite(spaceId: spaceId, email: normalizedEmail);

    debugPrint('✅ Email invitation created for: $normalizedEmail');
  }

  // ═══════════════════════════════════════════════════════════════════
  // إنشاء رابط دعوة
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<String> generateInviteLink(String spaceId) async {
    final shortToken = const Uuid().v4().substring(0, 8);
    final currentUserId = _supabase.auth.currentUser!.id;

    final invite = {
      'uuid': const Uuid().v4(),
      'token': shortToken,
      'space_id': spaceId,
      'inviter_id': currentUserId,
      'type': 'link',
      'status': 'pending',
      'expires_at': DateTime.now()
          .add(const Duration(days: 3))
          .toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from('invitations').insert(invite);

    return "https://athar.app/join?code=$shortToken";
  }

  // ═══════════════════════════════════════════════════════════════════
  // ✅✅✅ جلب الدعوات المعلقة - الإصلاح الرئيسي
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<List<InvitationModel>> getMyPendingInvites() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return [];

    final myEmail = currentUser.email?.trim().toLowerCase();
    final myId = currentUser.id;

    try {
      // ✅ البحث بالـ ID أو بالإيميل
      final response = await _supabase
          .from('invitations')
          .select('''
            *,
            spaces:space_id (
              uuid,
              name,
              description
            ),
            inviter:inviter_id (
              user_id,
              full_name,
              avatar_url
            )
          ''')
          .or('invitee_id.eq.$myId,invitee_email.eq.$myEmail')
          .eq('status', 'pending')
          .eq('type', 'direct_user')
          .order('created_at', ascending: false);

      return (response as List).map((e) {
        // تعديل البيانات لتتوافق مع InvitationModel
        final data = Map<String, dynamic>.from(e);

        // إضافة معلومات المساحة
        if (data['spaces'] != null) {
          data['space_name'] = data['spaces']['name'];
        }

        // إضافة معلومات الداعي
        if (data['inviter'] != null) {
          data['inviter_name'] = data['inviter']['full_name'];
          data['inviter_avatar'] = data['inviter']['avatar_url'];
        }

        return InvitationModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching invitations: $e');

      // Fallback: البحث بالإيميل فقط (للتوافق مع الإصدارات القديمة)
      if (myEmail != null) {
        try {
          final response = await _supabase
              .from('invitations')
              .select()
              .eq('invitee_email', myEmail)
              .eq('status', 'pending')
              .eq('type', 'direct_user');

          return (response as List)
              .map((e) => InvitationModel.fromJson(e))
              .toList();
        } catch (e2) {
          debugPrint('❌ Fallback also failed: $e2');
          return [];
        }
      }
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // قبول الدعوة
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> acceptInvite(String token) async {
    final userId = _supabase.auth.currentUser!.id;

    // 1. جلب تفاصيل الدعوة
    final inviteRes = await _supabase
        .from('invitations')
        .select()
        .eq('token', token)
        .eq('status', 'pending')
        .single();

    final spaceId = inviteRes['space_id'];

    // 2. التحقق من عدم وجود عضوية سابقة
    final existingMember = await _supabase
        .from('space_members')
        .select('user_id')
        .eq('space_id', spaceId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingMember != null) {
      // تحديث حالة الدعوة فقط
      await _supabase
          .from('invitations')
          .update({'status': 'accepted'})
          .eq('token', token);
      return;
    }

    // 3. إضافة العضو
    await _supabase.from('space_members').insert({
      'space_id': spaceId,
      'user_id': userId,
      'role': 'member',
      'joined_at': DateTime.now().toIso8601String(),
    });

    // 4. تحديث حالة الدعوة
    await _supabase
        .from('invitations')
        .update({'status': 'accepted'})
        .eq('token', token);

    // 5. المزامنة الفورية
    await _syncService.syncSpaces();

    debugPrint('✅ Invitation accepted, user joined space: $spaceId');
  }

  // ═══════════════════════════════════════════════════════════════════
  // رفض الدعوة
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> rejectInvite(String token) async {
    await _supabase
        .from('invitations')
        .update({'status': 'rejected'})
        .eq('token', token);

    debugPrint('✅ Invitation rejected');
  }

  // ═══════════════════════════════════════════════════════════════════
  // التحقق من صلاحية الدعوة
  // ═══════════════════════════════════════════════════════════════════

  Future<InvitationModel?> validateInviteToken(String token) async {
    try {
      final response = await _supabase
          .from('invitations')
          .select('''
            *,
            spaces:space_id (
              uuid,
              name,
              description
            )
          ''')
          .eq('token', token)
          .eq('status', 'pending')
          .single();

      // التحقق من انتهاء الصلاحية
      final expiresAt = DateTime.parse(response['expires_at']);
      if (expiresAt.isBefore(DateTime.now())) {
        // تحديث الحالة إلى منتهية
        await _supabase
            .from('invitations')
            .update({'status': 'expired'})
            .eq('token', token);
        return null;
      }

      return InvitationModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Invalid or expired token: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // إلغاء الدعوة (للمدير)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> cancelInvite(String inviteId) async {
    await _supabase
        .from('invitations')
        .update({'status': 'cancelled'})
        .eq('uuid', inviteId);

    debugPrint('✅ Invitation cancelled');
  }

  // ═══════════════════════════════════════════════════════════════════
  // جلب الدعوات المرسلة (للمدير)
  // ═══════════════════════════════════════════════════════════════════

  Future<List<InvitationModel>> getSpacePendingInvites(String spaceId) async {
    try {
      final response = await _supabase
          .from('invitations')
          .select('''
            *,
            invitee:invitee_id (
              user_id,
              full_name,
              avatar_url
            )
          ''')
          .eq('space_id', spaceId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => InvitationModel.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching space invitations: $e');
      return [];
    }
  }
}

//--------------------------------------------------------------------------
// import 'package:athar/core/services/sync_service.dart';
// import 'package:athar/features/space/data/models/dto/search_result_dto.dart';
// import 'package:athar/features/space/data/models/invitation_model.dart';
// import 'package:athar/features/space/domain/repositories/invitation_repository.dart';
// import 'package:injectable/injectable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';

// @LazySingleton(as: InvitationRepository)
// class InvitationRepositoryImpl implements InvitationRepository {
//   final SupabaseClient _supabase = Supabase.instance.client;

//   // ✅ حقن خدمة المزامنة
//   final SyncService _syncService;

//   // ✅ استخدام Constructor Injection
//   InvitationRepositoryImpl(this._syncService);

//   @override
//   Future<List<SearchResultDto>> searchUsers(String query) async {
//     if (query.length < 3) return []; // حماية الأداء

//     try {
//       // استدعاء الدالة الآمنة في Supabase RPC
//       final List<dynamic> response = await _supabase.rpc(
//         'search_profile',
//         params: {'search_term': query},
//       );

//       return response.map((e) => SearchResultDto.fromJson(e)).toList();
//     } catch (e) {
//       // معالجة الأخطاء (أو إرجاع قائمة فارغة)
//       return [];
//     }
//   }

//   @override
//   Future<void> sendDirectInvite({
//     required String spaceId,
//     required String userId,
//     required String userEmail,
//   }) async {
//     final token = const Uuid().v4(); // نولد توكن للدعوة المباشرة أيضاً
//     final currentUserId = _supabase.auth.currentUser!.id;

//     final invite = {
//       'uuid': const Uuid().v4(),
//       'token': token,
//       'space_id': spaceId,
//       'inviter_id': currentUserId,
//       'invitee_email': userEmail, // مهم جداً لنعرف لمن الدعوة
//       'type': 'direct_user',
//       'status': 'pending',
//       'expires_at': DateTime.now()
//           .add(const Duration(days: 7))
//           .toIso8601String(), // صلاحية أسبوع
//     };

//     await _supabase.from('invitations').insert(invite);
//   }

//   @override
//   Future<String> generateInviteLink(String spaceId) async {
//     // نولد كود قصير للرابط (مثلاً 8 خانات) ليكون سهل المشاركة
//     final shortToken = const Uuid().v4().substring(0, 8);
//     final currentUserId = _supabase.auth.currentUser!.id;

//     final invite = {
//       'uuid': const Uuid().v4(),
//       'token': shortToken,
//       'space_id': spaceId,
//       'inviter_id': currentUserId,
//       'type': 'link',
//       'status': 'pending',
//       'expires_at': DateTime.now()
//           .add(const Duration(days: 3))
//           .toIso8601String(), // صلاحية 3 أيام للروابط
//     };

//     await _supabase.from('invitations').insert(invite);

//     // نرجع الرابط جاهزاً للمشاركة
//     return "https://athar.app/join?code=$shortToken";
//   }

//   @override
//   Future<List<InvitationModel>> getMyPendingInvites() async {
//     final myEmail = _supabase.auth.currentUser?.email;
//     if (myEmail == null) return [];

//     final response = await _supabase
//         .from('invitations')
//         .select()
//         .eq('invitee_email', myEmail) // دعوات موجهة لإيميلي
//         .eq('status', 'pending')
//         .eq('type', 'direct_user');

//     return (response as List).map((e) => InvitationModel.fromJson(e)).toList();
//   }

//   @override
//   Future<void> acceptInvite(String token) async {
//     final userId = _supabase.auth.currentUser!.id;

//     // 1. جلب تفاصيل الدعوة
//     final inviteRes = await _supabase
//         .from('invitations')
//         .select()
//         .eq('token', token)
//         .eq('status', 'pending')
//         .single();

//     final spaceId = inviteRes['space_id'];

//     // 2. إضافة المستخدم للمساحة (Transaction)
//     // ملاحظة: Supabase لا يدعم Transactions مباشرة من Flutter بسهولة،
//     // لذا سننفذها كعمليتين (أو نكتب RPC للدقة القصوى). للتبسيط الآن:

//     // أ. إضافة العضو
//     await _supabase.from('space_members').insert({
//       'space_id': spaceId,
//       'user_id': userId,
//       'role': 'member',
//     });

//     // ب. تحديث حالة الدعوة
//     await _supabase
//         .from('invitations')
//         .update({'status': 'accepted'})
//         .eq('token', token);

//     // ✅ 4. الخطوة الحاسمة: المزامنة الفورية لجلب المساحة الجديدة للتطبيق
//     await _syncService.syncSpaces();
//   }
// }
