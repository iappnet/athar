import 'package:athar/core/iam/models/role_enums.dart';
import 'package:athar/features/space/data/repositories/space_member_repository_impl.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class RoleService {
  final SpaceMemberRepository _memberRepo;
  final SupabaseClient _supabase = Supabase.instance.client;

  RoleService(this._memberRepo);

  /// تحديد دور المستخدم الحالي في مساحة معينة
  Future<SpaceRole> getCurrentUserRole(String spaceId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return SpaceRole.member;

    // 1. محاولة الجلب من الكاش المحلي (Isar) للسرعة
    final cachedRecord = await _memberRepo.getMyRoleInSpace(spaceId, userId);

    if (cachedRecord != null) {
      return SpaceRole.fromString(cachedRecord.role);
    }

    // 2. إذا لم يوجد في الكاش (مستخدم جديد مثلاً)، نستخدم القيمة الافتراضية
    // وسيقوم الـ Cubit بتحديث الكاش في الخلفية
    return SpaceRole.member;
  }
}
