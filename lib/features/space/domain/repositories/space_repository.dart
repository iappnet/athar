import 'package:athar/features/space/data/models/project_stats.dart';
import 'package:athar/features/space/data/models/space_model.dart';

abstract class SpaceRepository {
  Stream<List<SpaceModel>> watchMySpaces();
  Future<void> createSpace({required String name, required String type});
  Future<void> ensurePersonalSpaceExists();
  Future<void> deleteSpace(String uuid);
  // ✅ التعديل: إضافة تعريف الدالة هنا لتتمكن من عمل override لها
  Future<void> claimLocalSpaces(String userId);
  // ✅ دوال الحذف والترحيل الجديدة
  Future<void> migrateDataForGuest(String oldUserId);
  Future<void> clearAllLocalData();
  // ✅✅ الإضافة الضرورية: تعريف الدالة هنا لتصبح متاحة عبر الواجهة
  Future<void> initDefaultData();
  // ✅✅ الدوال الجديدة التي أضفناها (يجب تعريفها هنا)
  Future<void> updateModule({
    required String uuid,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  });

  /// ✅ هل يوجد بيانات تجريبية؟
  Future<bool> hasSampleData();

  /// ✅ حذف جميع البيانات التجريبية نهائياً
  Future<void> dismissSampleData();

  /// ✅ إعادة تعيين حالة البيانات التجريبية (للتطوير)
  Future<void> resetSampleDataState();

  Future<ProjectStats> getProjectStats(String moduleUuid);
  Future<List<Map<String, dynamic>>> getSpaceMembers(String spaceId);
  Future<void> updateSpaceDelegation(String uuid, bool allowDelegation);
  Future<void> removeMember(String spaceId, String userId);
  Future<void> updateMemberRole(String spaceId, String userId, String role);
}
