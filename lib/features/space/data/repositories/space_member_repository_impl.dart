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

  /// جلب الأعضاء مع دعم Offline-First
  Stream<List<SpaceMemberModel>> watchSpaceMembers(String spaceId) {
    // نقوم بمزامنة البيانات في الخلفية عند بدء المراقبة
    syncSpaceMembers(spaceId);

    return _isar.spaceMemberModels
        .filter()
        .spaceIdEqualTo(spaceId)
        .watch(fireImmediately: true);
  }

  /// مزامنة البيانات من السحاب وتحديث الكاش
  Future<void> syncSpaceMembers(String spaceId) async {
    try {
      final response = await _supabase
          .from('space_members')
          .select('*, profiles(*)') // جلب بيانات البروفايل أيضاً
          .eq('space_id', spaceId);

      final List<SpaceMemberModel> remoteMembers = (response as List).map((
        json,
      ) {
        final profile = json['profiles'] ?? {};
        return SpaceMemberModel()
          ..uuid = json['id']
          ..spaceId = json['space_id']
          ..userId = json['user_id']
          ..role = json['role']
          ..joinedAt = DateTime.parse(json['joined_at'])
          ..tempDisplayName = profile['full_name']
          ..tempAvatarUrl = profile['avatar_url']
          ..isSynced = true;
      }).toList();

      await _isar.writeTxn(() async {
        await _isar.spaceMemberModels
            .filter()
            .spaceIdEqualTo(spaceId)
            .deleteAll();
        await _isar.spaceMemberModels.putAll(remoteMembers);
      });
    } catch (e) {
      if (kDebugMode) print("❌ Error syncing members: $e");
    }
  }

  /// تحديث دور عضو
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

  /// حذف عضو (طرد)
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
}
