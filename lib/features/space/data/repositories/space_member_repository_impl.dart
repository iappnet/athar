// lib/features/space/data/repositories/space_member_repository_impl.dart
// ✅ إصلاح خطأ PGRST200 - استعلامات منفصلة بدون embedded queries

import 'package:athar/features/space/data/models/space_member_model.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class SpaceMemberRepository {
  final Isar _isar;
  final SupabaseClient _supabase = Supabase.instance.client;

  SpaceMemberRepository(this._isar);

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ Helper: التحقق من تسجيل الدخول
  // ═══════════════════════════════════════════════════════════════════════════

  bool get _isAuthenticated => _supabase.auth.currentUser != null;

  // ═══════════════════════════════════════════════════════════════════════════
  // جلب الأعضاء مع دعم Offline-First
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<SpaceMemberModel>> watchSpaceMembers(String spaceId) {
    // نقوم بمزامنة البيانات في الخلفية عند بدء المراقبة
    syncSpaceMembers(spaceId);

    return _isar.spaceMemberModels
        .filter()
        .spaceIdEqualTo(spaceId)
        .watch(fireImmediately: true);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ مزامنة البيانات - إصلاح خطأ PGRST200
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> syncSpaceMembers(String spaceId) async {
    // ✅ التحقق من تسجيل الدخول أولاً
    if (!_isAuthenticated) {
      if (kDebugMode)
        print("⚠️ syncSpaceMembers: User not authenticated, skipping sync");
      return;
    }

    try {
      // ✅ الطريقة الآمنة: استعلامات منفصلة بدلاً من embedded queries
      // هذا يتجنب خطأ PGRST200 تماماً

      // 1. جلب الأعضاء (بدون profiles)
      final membersResponse = await _supabase
          .from('space_members')
          .select('id, space_id, user_id, role, joined_at')
          .eq('space_id', spaceId);

      if (membersResponse.isEmpty) {
        // مسح الكاش المحلي إذا لم يعد هناك أعضاء
        await _isar.writeTxn(() async {
          await _isar.spaceMemberModels
              .filter()
              .spaceIdEqualTo(spaceId)
              .deleteAll();
        });
        return;
      }

      // 2. جمع user_ids
      final userIds = (membersResponse as List)
          .map((m) => m['user_id'] as String)
          .toSet()
          .toList();

      // 3. جلب profiles منفصلة
      Map<String, Map<String, dynamic>> profilesMap = {};
      try {
        final profilesResponse = await _supabase
            .from('profiles')
            .select('user_id, full_name, avatar_url, username, email')
            .inFilter('user_id', userIds);

        for (final profile in profilesResponse) {
          final id = profile['user_id'] as String?;
          if (id != null) {
            profilesMap[id] = profile;
          }
        }
      } catch (e) {
        // إذا فشل جلب profiles، نستمر بدونها
        if (kDebugMode) print("⚠️ Could not fetch profiles: $e");
      }

      // 4. تحويل البيانات إلى SpaceMemberModel
      final List<SpaceMemberModel> remoteMembers = [];

      for (final json in membersResponse) {
        final userId = json['user_id'] as String;
        final profile = profilesMap[userId] ?? {};

        final member = SpaceMemberModel()
          ..uuid = json['id']?.toString() ?? ''
          ..spaceId = json['space_id'] ?? spaceId
          ..userId = userId
          ..role = json['role'] ?? 'member'
          ..joinedAt = json['joined_at'] != null
              ? DateTime.parse(json['joined_at'])
              : DateTime.now()
          // ✅ بيانات البروفايل من الاستعلام المنفصل
          ..tempDisplayName = profile['full_name'] as String?
          ..tempAvatarUrl = profile['avatar_url'] as String?
          ..isSynced = true;

        remoteMembers.add(member);
      }

      // 5. تحديث الكاش المحلي
      await _isar.writeTxn(() async {
        // مسح القديم
        await _isar.spaceMemberModels
            .filter()
            .spaceIdEqualTo(spaceId)
            .deleteAll();
        // إضافة الجديد
        await _isar.spaceMemberModels.putAll(remoteMembers);
      });

      if (kDebugMode) {
        print("✅ Synced ${remoteMembers.length} members for space: $spaceId");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error syncing members: $e");

      // ✅ Fallback: محاولة جلب الأعضاء بدون profiles على الإطلاق
      await _syncMembersWithoutProfiles(spaceId);
    }
  }

  /// ✅ Fallback: جلب الأعضاء بدون profiles
  Future<void> _syncMembersWithoutProfiles(String spaceId) async {
    try {
      final response = await _supabase
          .from('space_members')
          .select('id, space_id, user_id, role, joined_at')
          .eq('space_id', spaceId);

      final List<SpaceMemberModel> members = (response as List).map((json) {
        return SpaceMemberModel()
          ..uuid = json['id']?.toString() ?? ''
          ..spaceId = json['space_id'] ?? spaceId
          ..userId = json['user_id'] ?? ''
          ..role = json['role'] ?? 'member'
          ..joinedAt = json['joined_at'] != null
              ? DateTime.parse(json['joined_at'])
              : DateTime.now()
          ..tempDisplayName =
              null // سيُعرض كـ "عضو" في الـ UI
          ..tempAvatarUrl = null
          ..isSynced = true;
      }).toList();

      await _isar.writeTxn(() async {
        await _isar.spaceMemberModels
            .filter()
            .spaceIdEqualTo(spaceId)
            .deleteAll();
        await _isar.spaceMemberModels.putAll(members);
      });

      if (kDebugMode) {
        print("✅ Fallback sync: ${members.length} members (without profiles)");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Fallback sync also failed: $e");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تحديث دور عضو
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateMemberRole(
    String spaceId,
    String userId,
    String newRole,
  ) async {
    // 1. تحديث سحابي
    await _supabase
        .from('space_members')
        .update({'role': newRole})
        .eq('space_id', spaceId)
        .eq('user_id', userId);

    // 2. تحديث الكاش المحلي فوراً
    final localRecord = await _isar.spaceMemberModels
        .filter()
        .spaceIdEqualTo(spaceId)
        .userIdEqualTo(userId)
        .findFirst();

    if (localRecord != null) {
      await _isar.writeTxn(() async {
        localRecord.role = newRole;
        await _isar.spaceMemberModels.put(localRecord);
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // حذف عضو (طرد)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> removeMember(String spaceId, String userId) async {
    // 1. حذف سحابي
    await _supabase
        .from('space_members')
        .delete()
        .eq('space_id', spaceId)
        .eq('user_id', userId);

    // 2. حذف من الكاش
    await _isar.writeTxn(() async {
      await _isar.spaceMemberModels
          .filter()
          .spaceIdEqualTo(spaceId)
          .userIdEqualTo(userId)
          .deleteAll();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // جلب دور المستخدم الحالي في مساحة
  // ═══════════════════════════════════════════════════════════════════════════

  Future<SpaceMemberModel?> getMyRoleInSpace(
    String spaceId,
    String userId,
  ) async {
    return await _isar.spaceMemberModels
        .filter()
        .spaceIdEqualTo(spaceId)
        .userIdEqualTo(userId)
        .findFirst();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ جلب بيانات عضو واحد مع profile
  // ═══════════════════════════════════════════════════════════════════════════

  Future<SpaceMemberModel?> getMemberWithProfile(
    String spaceId,
    String userId,
  ) async {
    // محاولة من الكاش أولاً
    final cached = await getMyRoleInSpace(spaceId, userId);
    if (cached != null && cached.tempDisplayName != null) {
      return cached;
    }

    // جلب من السحاب
    try {
      final memberResponse = await _supabase
          .from('space_members')
          .select('id, space_id, user_id, role, joined_at')
          .eq('space_id', spaceId)
          .eq('user_id', userId)
          .maybeSingle();

      if (memberResponse == null) return null;

      // جلب profile
      final profileResponse = await _supabase
          .from('profiles')
          .select('full_name, avatar_url, username')
          .eq('user_id', userId)
          .maybeSingle();

      final member = SpaceMemberModel()
        ..uuid = memberResponse['id']?.toString() ?? ''
        ..spaceId = spaceId
        ..userId = userId
        ..role = memberResponse['role'] ?? 'member'
        ..joinedAt = DateTime.parse(memberResponse['joined_at'])
        ..tempDisplayName = profileResponse?['full_name']
        ..tempAvatarUrl = profileResponse?['avatar_url']
        ..isSynced = true;

      // حفظ في الكاش
      await _isar.writeTxn(() async {
        await _isar.spaceMemberModels.put(member);
      });

      return member;
    } catch (e) {
      if (kDebugMode) print("❌ Error fetching member: $e");
      return cached;
    }
  }
}

//--------------------------------------------------------------------------

// import 'package:athar/features/space/data/models/space_member_model.dart';
// import 'package:flutter/foundation.dart';
// import 'package:injectable/injectable.dart';
// import 'package:isar/isar.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// @lazySingleton
// class SpaceMemberRepository {
//   final Isar _isar;
//   final SupabaseClient _supabase = Supabase.instance.client;

//   SpaceMemberRepository(this._isar);

//   /// جلب الأعضاء مع دعم Offline-First
//   Stream<List<SpaceMemberModel>> watchSpaceMembers(String spaceId) {
//     // نقوم بمزامنة البيانات في الخلفية عند بدء المراقبة
//     syncSpaceMembers(spaceId);

//     return _isar.spaceMemberModels
//         .filter()
//         .spaceIdEqualTo(spaceId)
//         .watch(fireImmediately: true);
//   }

//   /// مزامنة البيانات من السحاب وتحديث الكاش
//   Future<void> syncSpaceMembers(String spaceId) async {
//     try {
//       final response = await _supabase
//           .from('space_members')
//           .select('*, profiles(*)') // جلب بيانات البروفايل أيضاً
//           .eq('space_id', spaceId);

//       final List<SpaceMemberModel> remoteMembers = (response as List).map((
//         json,
//       ) {
//         final profile = json['profiles'] ?? {};
//         return SpaceMemberModel()
//           ..uuid = json['id']
//           ..spaceId = json['space_id']
//           ..userId = json['user_id']
//           ..role = json['role']
//           ..joinedAt = DateTime.parse(json['joined_at'])
//           ..tempDisplayName = profile['full_name']
//           ..tempAvatarUrl = profile['avatar_url']
//           ..isSynced = true;
//       }).toList();

//       await _isar.writeTxn(() async {
//         await _isar.spaceMemberModels
//             .filter()
//             .spaceIdEqualTo(spaceId)
//             .deleteAll();
//         await _isar.spaceMemberModels.putAll(remoteMembers);
//       });
//     } catch (e) {
//       if (kDebugMode) print("❌ Error syncing members: $e");
//     }
//   }

//   /// تحديث دور عضو
//   Future<void> updateMemberRole(
//     String spaceId,
//     String userId,
//     String newRole,
//   ) async {
//     // 1. تحديث سحابي
//     await _supabase
//         .from('space_members')
//         .update({'role': newRole})
//         .eq('space_id', spaceId)
//         .eq('user_id', userId);

//     // 2. تحديث الكاش المحلي فوراً
//     final localRecord = await _isar.spaceMemberModels
//         .filter()
//         .spaceIdEqualTo(spaceId)
//         .userIdEqualTo(userId)
//         .findFirst();

//     if (localRecord != null) {
//       await _isar.writeTxn(() async {
//         localRecord.role = newRole;
//         await _isar.spaceMemberModels.put(localRecord);
//       });
//     }
//   }

//   /// حذف عضو (طرد)
//   Future<void> removeMember(String spaceId, String userId) async {
//     // 1. حذف سحابي
//     await _supabase
//         .from('space_members')
//         .delete()
//         .eq('space_id', spaceId)
//         .eq('user_id', userId);

//     // 2. حذف من الكاش
//     await _isar.writeTxn(() async {
//       await _isar.spaceMemberModels
//           .filter()
//           .spaceIdEqualTo(spaceId)
//           .userIdEqualTo(userId)
//           .deleteAll();
//     });
//   }

//   Future<SpaceMemberModel?> getMyRoleInSpace(
//     String spaceId,
//     String userId,
//   ) async {
//     return await _isar.spaceMemberModels
//         .filter()
//         .spaceIdEqualTo(spaceId)
//         .userIdEqualTo(userId)
//         .findFirst();
//   }
// }
//--------------------------------------------------------------------------
