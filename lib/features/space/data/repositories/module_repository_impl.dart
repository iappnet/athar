import 'package:athar/features/space/data/models/delegation_mode.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/domain/repositories/module_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: ModuleRepository)
class ModuleRepositoryImpl implements ModuleRepository {
  final Isar _isar;
  final SupabaseClient _supabase = Supabase.instance.client;

  ModuleRepositoryImpl(this._isar);

  @override
  Stream<List<ModuleModel>> watchModules(String spaceId) {
    final currentUserId = _supabase.auth.currentUser?.id;

    // البث المحلي مع مراعاة الخصوصية والترتيب
    return _isar.moduleModels
        .filter()
        .spaceIdEqualTo(spaceId)
        .deletedAtIsNull()
        .and()
        .group(
          (q) => q
              .visibilityEqualTo('public')
              .or()
              .creatorIdEqualTo(currentUserId),
        )
        .sortByPosition()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> createModule({
    required String spaceId,
    required String name,
    required String type,
    String? uuid,
    String visibility = 'public',
    String? description, // ✅ إضافة
    DateTime? endDate, // ✅ إضافة
    bool reminderEnabled = false, // ✅ إضافة البارامتر الجديد
    DateTime? reminderTime, // ✅ إضافة البارامتر الجديد
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;

    final newModule = ModuleModel()
      ..uuid = uuid ?? const Uuid().v4()
      ..spaceId = spaceId
      ..name = name
      ..type = type
      ..visibility = visibility
      ..description =
          description // ✅ تمرير الوصف
      ..endDate =
          endDate // ✅ تمرير التاريخ
      ..reminderEnabled =
          reminderEnabled // ✅ حفظ حالة التذكير
      ..reminderTime =
          reminderTime // ✅ حفظ وقت التذكير
      ..creatorId = currentUserId
      ..isSynced = false
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.moduleModels.put(newModule);
    });

    // الرفع للسحابة فوراً
    try {
      await _supabase.from('modules').upsert(newModule.toJson());
      newModule.isSynced = true;
      await _isar.writeTxn(() => _isar.moduleModels.put(newModule));
    } catch (e) {
      // ستقوم خدمة المزامنة الخلفية بالمعالجة لاحقاً
    }
  }

  @override
  Future<void> updateModuleDelegation(String uuid, DelegationMode mode) async {
    await _isar.writeTxn(() async {
      final module = await _isar.moduleModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (module != null) {
        module.delegationMode = mode;
        module.isSynced = false;
        module.updatedAt = DateTime.now();
        await _isar.moduleModels.put(module);
      }
    });
  }

  @override
  Future<void> updateModule({
    required String uuid,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? progressPercentage, // ✅ إضافة دعم التقدم
    DateTime? completedDate, // ✅ إضافة دعم تاريخ الإكمال
    bool? reminderEnabled, // ✅ إضافة لدعم التحديث
    DateTime? reminderTime, // ✅ إضافة لدعم التحديث
  }) async {
    await _isar.writeTxn(() async {
      final module = await _isar.moduleModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (module != null) {
        if (name != null) module.name = name;
        if (description != null) module.description = description;
        if (startDate != null) module.startDate = startDate;
        if (endDate != null) module.endDate = endDate;
        if (status != null) module.status = status;
        if (progressPercentage != null) {
          module.progressPercentage = progressPercentage;
        }
        if (completedDate != null) module.completedDate = completedDate;
        // ✅ تحديث قيم التذكير إذا تم تمريرها
        if (reminderEnabled != null) module.reminderEnabled = reminderEnabled;
        if (reminderTime != null) module.reminderTime = reminderTime;
        module.updatedAt = DateTime.now();
        module.isSynced =
            false; // يتم تعيينها كـ false حتى تكتمل العملية السحابية

        await _isar.moduleModels.put(module);
      }
    });

    // جلب البيانات المحدثة لرفعها
    final updated = await _isar.moduleModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
    if (updated != null) {
      try {
        await _supabase.from('modules').upsert(updated.toJson());

        // ✅ تحديث علامة المزامنة بعد نجاح الرفع
        await _isar.writeTxn(() async {
          updated.isSynced = true;
          await _isar.moduleModels.put(updated);
        });
      } catch (e) {
        // في حال فشل الإنترنت، سيبقى isSynced = false وستتولى SyncService معالجته لاحقاً
      }
    }
  }

  @override
  Future<void> deleteModule(String uuid) async {
    await _isar.writeTxn(() async {
      final module = await _isar.moduleModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (module != null) {
        module.deletedAt = DateTime.now();
        module.isSynced = false;
        module.updatedAt = DateTime.now();
        await _isar.moduleModels.put(module);
      }
    });

    // تحديث السحابة بالـ Soft Delete
    try {
      await _supabase
          .from('modules')
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'status': 'archived',
          })
          .eq('uuid', uuid);
    } catch (e) {
      // SyncService will handle it
    }
  }
}
