import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/data/models/project_stats.dart';
import 'package:athar/features/space/data/models/space_model.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(
  as: SpaceRepository,
) // ✅ هذا السطر يخبر GetIt بحقن هذا الكلاس عند طلب SpaceRepository
class SpaceRepositoryImpl implements SpaceRepository {
  // ✅ التعديل الأهم: إضافة implements لربط الكلاس بالواجهة
  final Isar _isar;
  final SupabaseClient _supabase = Supabase.instance.client;

  SpaceRepositoryImpl(this._isar);

  // 1. مراقبة المساحات الخاصة بي (Stream)
  @override // ✅ إضافة override
  Stream<List<SpaceModel>> watchMySpaces() {
    // إذا لم يكن هناك مستخدم مسجل، نستخدم 'guest' كمعرف
    final userId = _supabase.auth.currentUser?.id ?? 'guest';

    return _isar.spaceModels
        .filter()
        .ownerIdEqualTo(userId)
        .deletedAtIsNull()
        .sortByCreatedAt()
        .watch(fireImmediately: true);
  }

  // ✅ الدالة المصححة بالكامل
  @override // ✅ إضافة override
  Future<void> claimLocalSpaces(String userId) async {
    // 1. البحث عن المساحات المملوكة للزائر "guest"
    // لاحظ: استخدمنا ownerIdEqualTo('guest') لأن هذا ما تم تعيينه في initDefaultData
    final localSpaces = await _isar.spaceModels
        .filter()
        .ownerIdEqualTo('guest')
        .findAll();

    // 2. البحث عن المهام المملوكة للزائر
    final localTasks = await _isar.taskModels
        .filter()
        .userIdEqualTo('guest')
        .findAll();

    if (localSpaces.isNotEmpty || localTasks.isNotEmpty) {
      await _isar.writeTxn(() async {
        // أ. تحديث ملكية المساحات
        for (final space in localSpaces) {
          space.ownerId = userId; // نقل الملكية للمستخدم الجديد
          space.isSynced = false; // لرفعها للسحابة
          space.updatedAt = DateTime.now();
          await _isar.spaceModels.put(space);
        }

        // ب. تحديث ملكية المهام
        for (final task in localTasks) {
          task.userId = userId; // نقل الملكية للمستخدم الجديد
          task.isSynced = false;
          await _isar.taskModels.put(task);
        }

        // ملاحظة: الموديولات (Modules) عادة تتبع المساحة عبر spaceId
        // لذا لا نحتاج لتحديثها يدوياً إلا إذا كان لديها حقل ownerId خاص بها
      });
      debugPrint("✅ Local data (Spaces & Tasks) claimed for user: $userId");
    }
  }

  @override
  Future<void> removeMember(String spaceId, String userId) async {
    await _supabase.from('space_members').delete().match({
      'space_id': spaceId,
      'user_id': userId,
    });
  }

  @override
  Future<void> updateMemberRole(
    String spaceId,
    String userId,
    String role,
  ) async {
    await _supabase.from('space_members').update({'role': role}).match({
      'space_id': spaceId,
      'user_id': userId,
    });
  }

  // ✅ دالة إنشاء البيانات الافتراضية للزوار (تم تحسين التحقق)
  // ملاحظة: إذا كانت هذه الدالة موجودة في الواجهة SpaceRepository أضف @override، وإلا اتركها كما هي.
  // سأضيفها كدالة عامة (Public) لأنك تستدعيها من main.dart
  @override // ✅ تأكد من وجود هذا
  Future<void> initDefaultData() async {
    final count = await _isar.spaceModels.filter().deletedAtIsNull().count();
    if (count > 0) return;

    final mySpaceId = const Uuid().v4();
    final healthModuleId = const Uuid().v4();
    final projectModuleId = const Uuid().v4();
    final now = DateTime.now();

    await _isar.writeTxn(() async {
      final mySpace = SpaceModel()
        ..uuid = mySpaceId
        ..name = "مساحتي"
        ..type = "personal"
        ..ownerId = "guest"
        ..createdAt = now
        ..updatedAt = now
        ..isSynced = false;
      await _isar.spaceModels.put(mySpace);

      final healthModule = ModuleModel()
        ..uuid = healthModuleId
        ..spaceId = mySpaceId
        ..name = "ملفي الصحي"
        ..type = "health"
        ..createdAt = now
        ..updatedAt = now
        ..isSynced = false;
      await _isar.moduleModels.put(healthModule);

      final projectModule = ModuleModel()
        ..uuid = projectModuleId
        ..spaceId = mySpaceId
        ..name = "ترميم البيت"
        ..type = "project"
        ..createdAt = now
        ..updatedAt = now
        ..isSynced = false;
      await _isar.moduleModels.put(projectModule);

      final demoTask = TaskModel(
        title: "شراء مواد الدهان",
        date: now.add(const Duration(hours: 1)),
        uuid: const Uuid().v4(),
        userId: "guest",
        isSynced: false,
        moduleId: projectModuleId,
        spaceId: mySpaceId,
      )..durationMinutes = 60;
      await _isar.taskModels.put(demoTask);
    });
  }

  @override // ✅ إضافة override
  Future<void> createSpace({required String name, required String type}) async {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    final newSpace = SpaceModel()
      ..uuid = const Uuid().v4()
      ..name = name
      ..type = type
      ..ownerId = userId
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..isSynced = false;

    await _isar.writeTxn(() async {
      await _isar.spaceModels.put(newSpace);
    });
  }

  @override // ✅ إضافة override
  Future<void> ensurePersonalSpaceExists() async {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    final count = await _isar.spaceModels
        .filter()
        .ownerIdEqualTo(userId)
        .and()
        .typeEqualTo('personal')
        .deletedAtIsNull()
        .count();

    if (count == 0) {
      await createSpace(name: "مساحتي", type: "personal");
    }
  }

  @override // ✅ إضافة override
  Future<void> deleteSpace(String uuid) async {
    await _isar.writeTxn(() async {
      final space = await _isar.spaceModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (space != null) {
        space.deletedAt = DateTime.now();
        space.isSynced = false;
        space.updatedAt = DateTime.now();
        await _isar.spaceModels.put(space);
      }
    });
  }

  // ✅✅ الدالة المعدلة جذرياً: ترحيل البيانات وحل مشكلة الأرشفة عند حذف الحساب السحابي
  @override
  Future<void> migrateDataForGuest(String oldUserId) async {
    await _isar.writeTxn(() async {
      // 1. التعامل مع المساحات
      final spaces = await _isar.spaceModels
          .filter()
          .ownerIdEqualTo(oldUserId)
          .findAll();

      for (var space in spaces) {
        // نقل الملكية للزائر
        space.ownerId = 'guest';
        space.isSynced = false; // قطع الاتصال بالسحابة
        space.updatedAt = DateTime.now();

        // 🛑 التعديل الجوهري: إذا كانت مساحة مشتركة، نحول نوعها لأرشيف
        if (space.type == 'shared' || space.type == 'work') {
          space.type = 'archived_shared'; // ✅ تغيير النوع لتمييزها برمجياً
          space.name = "${space.name} (أرشيف)"; // تغيير الاسم للتوضيح للمستخدم
        }

        // المساحات الشخصية (personal) تبقى كما هي، فقط يتغير المالك لـ guest

        await _isar.spaceModels.put(space);
      }

      // 2. ترحيل المهام المرتبطة بهذا المستخدم
      final tasks = await _isar.taskModels
          .filter()
          .userIdEqualTo(oldUserId)
          .findAll();

      for (var task in tasks) {
        task.userId = 'guest';
        task.isSynced = false; // ستصبح مهام محلية للضيف
        await _isar.taskModels.put(task);
      }
    });

    if (kDebugMode) {
      print("✅ All data migrated to guest. Shared spaces archived.");
    }
  }

  // ✅ تحديث بيانات الموديول (المشروع)
  @override
  Future<void> updateModule({
    required String uuid,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
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
        if (status != null) module.status = status; // active, archived

        module.updatedAt = DateTime.now();
        module.isSynced = false; // لرفع التغييرات

        await _isar.moduleModels.put(module);
      }
    });
  }

  // ✅ جلب إحصائيات المشروع (للداشبورد)
  @override
  Future<ProjectStats> getProjectStats(String moduleUuid) async {
    final totalTasks = await _isar.taskModels
        .filter()
        .moduleIdEqualTo(moduleUuid)
        .deletedAtIsNull()
        .count();

    final completedTasks = await _isar.taskModels
        .filter()
        .moduleIdEqualTo(moduleUuid)
        .deletedAtIsNull()
        .isCompletedEqualTo(true)
        .count();

    return ProjectStats(total: totalTasks, completed: completedTasks);
  }

  @override
  Future<void> updateSpaceDelegation(String uuid, bool allowDelegation) async {
    await _isar.writeTxn(() async {
      final space = await _isar.spaceModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (space != null) {
        space.allowMemberDelegation = allowDelegation;
        space.isSynced = false;
        space.updatedAt = DateTime.now();
        await _isar.spaceModels.put(space);
      }
    });
  }

  @override // ✅ إضافة override
  Future<void> clearAllLocalData() async {
    await _isar.writeTxn(() async {
      await _isar.spaceModels.clear();
      await _isar.moduleModels.clear();
      await _isar.taskModels.clear();
      // إعادة تهيئة البيانات الافتراضية للزائر لكي لا يبدو التطبيق معطلاً
    });
    // إعادة إنشاء مساحة افتراضية نظيفة
    await initDefaultData();
  }

  @override
  Future<List<Map<String, dynamic>>> getSpaceMembers(String spaceId) async {
    // نجلب الأعضاء ونربطهم بجدول profiles
    final response = await _supabase
        .from('space_members')
        .select('role, user_id, profiles(full_name, avatar_url, username)')
        .eq('space_id', spaceId);

    return List<Map<String, dynamic>>.from(response);
  }
}
