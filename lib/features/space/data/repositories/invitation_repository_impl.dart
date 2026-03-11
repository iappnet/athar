import 'package:athar/core/services/sync_service.dart';
import 'package:athar/features/space/data/models/dto/search_result_dto.dart';
import 'package:athar/features/space/data/models/invitation_model.dart';
import 'package:athar/features/space/domain/repositories/invitation_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: InvitationRepository)
class InvitationRepositoryImpl implements InvitationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ حقن خدمة المزامنة
  final SyncService _syncService;

  // ✅ استخدام Constructor Injection
  InvitationRepositoryImpl(this._syncService);

  @override
  Future<List<SearchResultDto>> searchUsers(String query) async {
    if (query.length < 3) return []; // حماية الأداء

    try {
      // استدعاء الدالة الآمنة في Supabase RPC
      final List<dynamic> response = await _supabase.rpc(
        'search_profile',
        params: {'search_term': query},
      );

      return response.map((e) => SearchResultDto.fromJson(e)).toList();
    } catch (e) {
      // معالجة الأخطاء (أو إرجاع قائمة فارغة)
      return [];
    }
  }

  @override
  Future<void> sendDirectInvite({
    required String spaceId,
    required String userId,
    required String userEmail,
  }) async {
    final token = const Uuid().v4(); // نولد توكن للدعوة المباشرة أيضاً
    final currentUserId = _supabase.auth.currentUser!.id;

    final invite = {
      'uuid': const Uuid().v4(),
      'token': token,
      'space_id': spaceId,
      'inviter_id': currentUserId,
      'invitee_email': userEmail, // مهم جداً لنعرف لمن الدعوة
      'type': 'direct_user',
      'status': 'pending',
      'expires_at': DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String(), // صلاحية أسبوع
    };

    await _supabase.from('invitations').insert(invite);
  }

  @override
  Future<String> generateInviteLink(String spaceId) async {
    // نولد كود قصير للرابط (مثلاً 8 خانات) ليكون سهل المشاركة
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
          .toIso8601String(), // صلاحية 3 أيام للروابط
    };

    await _supabase.from('invitations').insert(invite);

    // نرجع الرابط جاهزاً للمشاركة
    return "https://athar.app/join?code=$shortToken";
  }

  @override
  Future<List<InvitationModel>> getMyPendingInvites() async {
    final myEmail = _supabase.auth.currentUser?.email;
    if (myEmail == null) return [];

    final response = await _supabase
        .from('invitations')
        .select()
        .eq('invitee_email', myEmail) // دعوات موجهة لإيميلي
        .eq('status', 'pending')
        .eq('type', 'direct_user');

    return (response as List).map((e) => InvitationModel.fromJson(e)).toList();
  }

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

    // 2. إضافة المستخدم للمساحة (Transaction)
    // ملاحظة: Supabase لا يدعم Transactions مباشرة من Flutter بسهولة،
    // لذا سننفذها كعمليتين (أو نكتب RPC للدقة القصوى). للتبسيط الآن:

    // أ. إضافة العضو
    await _supabase.from('space_members').insert({
      'space_id': spaceId,
      'user_id': userId,
      'role': 'member',
    });

    // ب. تحديث حالة الدعوة
    await _supabase
        .from('invitations')
        .update({'status': 'accepted'})
        .eq('token', token);

    // ✅ 4. الخطوة الحاسمة: المزامنة الفورية لجلب المساحة الجديدة للتطبيق
    await _syncService.syncSpaces();
  }
}
