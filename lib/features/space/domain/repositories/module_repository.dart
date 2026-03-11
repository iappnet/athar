import 'package:athar/features/space/data/models/delegation_mode.dart';
import 'package:athar/features/space/data/models/module_model.dart';

abstract class ModuleRepository {
  /// مراقبة الموديولات في مساحة معينة
  Stream<List<ModuleModel>> watchModules(String spaceId);

  /// إنشاء موديول جديد
  Future<void> createModule({
    required String spaceId,
    required String name,
    required String type,
    String? uuid,
    String visibility = 'public',
    String? description, // ➕ إضافة
    DateTime? endDate, // ➕ إضافة
    bool reminderEnabled = false, // ➕ إضافة
    DateTime? reminderTime, // ➕ إضافة
  });

  /// تحديث إعدادات التفويض
  Future<void> updateModuleDelegation(String uuid, DelegationMode mode);

  /// حذف موديول (Soft Delete)
  Future<void> deleteModule(String uuid);

  Future<void> updateModule({
    required String uuid,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? progressPercentage, // ➕ إضافة
    DateTime? completedDate, // ➕ إضافة
    bool? reminderEnabled, // ➕ إضافة
    DateTime? reminderTime, // ➕ إضافة
  });
}
