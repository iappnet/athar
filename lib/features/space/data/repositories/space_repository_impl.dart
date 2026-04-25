// lib/features/space/data/repositories/space_repository_impl.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ SpaceRepositoryImpl - يستخدم Isar فقط (بدون SharedPreferences)
// 📅 جلسة 11 - النسخة النهائية
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/space/data/models/space_member_model.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/data/models/project_stats.dart';
import 'package:athar/features/space/data/models/space_model.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Exception مخصص للمساحات المشتركة
// ═══════════════════════════════════════════════════════════════════════════════

class SharedSpaceException implements Exception {
  final String message;
  final String code;

  SharedSpaceException(this.message, {this.code = 'SHARED_SPACE_ERROR'});

  @override
  String toString() => 'SharedSpaceException: $message (code: $code)';
}

// ═══════════════════════════════════════════════════════════════════════════════
// SpaceRepositoryImpl
// ═══════════════════════════════════════════════════════════════════════════════

@LazySingleton(as: SpaceRepository)
class SpaceRepositoryImpl implements SpaceRepository {
  final Isar _isar;
  final SupabaseClient _supabase = Supabase.instance.client;

  SpaceRepositoryImpl(this._isar);

  // ═══════════════════════════════════════════════════════════════════════════
  // Helper: التحقق من تسجيل الدخول
  // ═══════════════════════════════════════════════════════════════════════════

  bool get _isAuthenticated => _supabase.auth.currentUser != null;

  String get _currentUserId => _supabase.auth.currentUser?.id ?? 'guest';

  void _requireAuth(String operation) {
    if (!_isAuthenticated) {
      throw SharedSpaceException(
        'يجب تسجيل الدخول للقيام بـ: $operation',
        code: 'AUTH_REQUIRED',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Helper: الحصول على UserSettings
  // ═══════════════════════════════════════════════════════════════════════════

  Future<UserSettings> _getOrCreateSettings() async {
    var settings = await _isar.userSettings.where().findFirst();
    if (settings == null) {
      settings = UserSettings();
      await _isar.writeTxn(() async {
        await _isar.userSettings.put(settings!);
      });
    }
    return settings;
  }

  Future<void> _updateSettings(UserSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.userSettings.put(settings);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // مراقبة المساحات
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Stream<List<SpaceModel>> watchMySpaces() {
    final userId = _currentUserId;
    final spacesStream = _isar.spaceModels
        .filter()
        .deletedAtIsNull()
        .sortByCreatedAt()
        .watch(fireImmediately: true);

    if (!_isAuthenticated) {
      return spacesStream.map(
        (spaces) => spaces.where((space) => space.ownerId == 'guest').toList(),
      );
    }

    final memberStream = _isar.spaceMemberModels
        .filter()
        .userIdEqualTo(userId)
        .watch(fireImmediately: true);

    return Rx.combineLatest2<List<SpaceModel>, List<SpaceMemberModel>,
        List<SpaceModel>>(spacesStream, memberStream, (spaces, members) {
      final memberSpaceIds = members.map((member) => member.spaceId).toSet();

      return spaces
          .where(
            (space) =>
                space.ownerId == userId || memberSpaceIds.contains(space.uuid),
          )
          .toList();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إنشاء مساحة
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> createSpace({required String name, required String type}) async {
    final odUserId = _currentUserId;

    // المساحات المشتركة تتطلب تسجيل دخول
    if (type == 'shared' || type == 'work' || type == 'team') {
      _requireAuth('إنشاء مساحة مشتركة');
    }

    final newSpace = SpaceModel()
      ..uuid = const Uuid().v4()
      ..name = name
      ..type = type
      ..ownerId = odUserId
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..isSynced = false;

    await _isar.writeTxn(() async {
      await _isar.spaceModels.put(newSpace);
    });

    // للمساحات المشتركة: إضافة المالك كعضو تلقائياً
    if (type == 'shared' && _isAuthenticated) {
      try {
        await _cacheMemberLocally(
          spaceId: newSpace.uuid,
          userId: odUserId,
          role: 'owner',
        );
        await _syncSharedSpaceImmediately(newSpace);
      } catch (e) {
        debugPrint('⚠️ Could not add owner as member: $e');
      }
    }
  }

  Future<void> _cacheMemberLocally({
    required String spaceId,
    required String userId,
    required String role,
  }) async {
    final existing = await _isar.spaceMemberModels
        .filter()
        .spaceIdEqualTo(spaceId)
        .userIdEqualTo(userId)
        .findFirst();

    final member = existing ?? SpaceMemberModel();
    member.uuid = existing?.uuid ?? const Uuid().v4();
    member.spaceId = spaceId;
    member.userId = userId;
    member.role = role;
    member.joinedAt = existing?.joinedAt ?? DateTime.now();
    member.isSynced = true;

    await _isar.writeTxn(() async {
      await _isar.spaceMemberModels.put(member);
    });
  }

  Future<void> _syncSharedSpaceImmediately(SpaceModel space) async {
    await _supabase
        .from('spaces')
        .upsert([space.toSupabaseJson()], onConflict: 'uuid');

    final existingMember = await _supabase
        .from('space_members')
        .select('uuid')
        .eq('space_id', space.uuid)
        .eq('user_id', _currentUserId)
        .maybeSingle();

    if (existingMember == null) {
      await _supabase.from('space_members').insert({
        'space_id': space.uuid,
        'user_id': _currentUserId,
        'role': 'owner',
        'joined_at': DateTime.now().toIso8601String(),
      });
    }

    await _isar.writeTxn(() async {
      space.isSynced = true;
      await _isar.spaceModels.put(space);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // جلب الأعضاء - إصلاح خطأ PGRST200
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<Map<String, dynamic>>> getSpaceMembers(String spaceId) async {
    if (!_isAuthenticated) {
      debugPrint('⚠️ getSpaceMembers: User not authenticated');
      return [];
    }

    try {
      // استعلامات منفصلة لتجنب PGRST200

      // 1. جلب الأعضاء
      final membersResponse = await _supabase
          .from('space_members')
          .select('uuid, space_id, user_id, role, joined_at')
          .eq('space_id', spaceId);

      if (membersResponse.isEmpty) return [];

      // 2. جمع user_ids
      final userIds = (membersResponse as List)
          .map((m) => m['user_id'] as String)
          .toSet()
          .toList();

      // 3. جلب profiles منفصلة
      final profilesResponse = await _supabase
          .from('profiles')
          .select('user_id, full_name, avatar_url, username')
          .inFilter('user_id', userIds);

      // 4. إنشاء map للـ profiles
      final profilesMap = <String, Map<String, dynamic>>{};
      for (final profile in profilesResponse) {
        profilesMap[profile['user_id']] = profile;
      }

      // 5. دمج البيانات
      final result = <Map<String, dynamic>>[];
      for (final member in membersResponse) {
        final odUserId = member['user_id'] as String;
        final profile = profilesMap[odUserId] ?? {};

        result.add({
          'uuid': member['uuid']?.toString(),
          'space_id': member['space_id'],
          'user_id': odUserId,
          'role': member['role'],
          'joined_at': member['joined_at'],
          'full_name': profile['full_name'],
          'avatar_url': profile['avatar_url'],
          'username': profile['username'],
        });
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error fetching space members: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تحويل مساحة لمشتركة
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> canConvertToShared() async {
    return _isAuthenticated;
  }

  Future<void> convertToShared(String spaceUuid) async {
    _requireAuth('تحويل المساحة لمشتركة');

    await _isar.writeTxn(() async {
      final space = await _isar.spaceModels
          .filter()
          .uuidEqualTo(spaceUuid)
          .findFirst();

      if (space != null) {
        space.type = 'shared';
        space.isSynced = false;
        space.updatedAt = DateTime.now();
        await _isar.spaceModels.put(space);
      }
    });

    final localSpace = await _isar.spaceModels
        .filter()
        .uuidEqualTo(spaceUuid)
        .findFirst();
    if (localSpace != null) {
      await _cacheMemberLocally(
        spaceId: spaceUuid,
        userId: _currentUserId,
        role: 'owner',
      );
      await _syncSharedSpaceImmediately(localSpace);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إدارة الأعضاء
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> claimLocalSpaces(String odUserId) async {
    final localSpaces = await _isar.spaceModels
        .filter()
        .ownerIdEqualTo('guest')
        .findAll();

    final localTasks = await _isar.taskModels
        .filter()
        .userIdEqualTo('guest')
        .findAll();

    if (localSpaces.isNotEmpty || localTasks.isNotEmpty) {
      await _isar.writeTxn(() async {
        for (final space in localSpaces) {
          space.ownerId = odUserId;
          space.isSynced = false;
          space.updatedAt = DateTime.now();
          await _isar.spaceModels.put(space);
        }

        for (final task in localTasks) {
          task.userId = odUserId;
          task.isSynced = false;
          await _isar.taskModels.put(task);
        }
      });
      debugPrint("✅ Local data claimed for user: $odUserId");
    }
  }

  @override
  Future<void> removeMember(String spaceId, String odUserId) async {
    _requireAuth('إزالة عضو');

    await _supabase.from('space_members').delete().match({
      'space_id': spaceId,
      'user_id': odUserId,
    });
  }

  @override
  Future<void> updateMemberRole(
    String spaceId,
    String odUserId,
    String role,
  ) async {
    _requireAuth('تغيير صلاحيات عضو');

    await _supabase.from('space_members').update({'role': role}).match({
      'space_id': spaceId,
      'user_id': odUserId,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅✅✅ initDefaultData - يستخدم Isar فقط ✅✅✅
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> initDefaultData() async {
    // ✅ قراءة الإعدادات من Isar
    final settings = await _getOrCreateSettings();

    // ✅ التحقق: هل رفض المستخدم البيانات التجريبية؟
    if (settings.sampleDataDismissed) {
      debugPrint('📦 Sample data was dismissed by user, skipping...');
      return;
    }

    // ✅ التحقق من وجود أي مساحات
    final totalCount = await _isar.spaceModels.count();
    if (totalCount > 0) {
      // تحديث أنه تم عرض البيانات
      if (!settings.sampleDataShown) {
        settings.sampleDataShown = true;
        await _updateSettings(settings);
      }
      debugPrint('📦 Spaces already exist, skipping sample data');
      return;
    }

    // إنشاء البيانات التجريبية للمرة الأولى فقط
    await _createSampleData();

    // ✅ تحديث الإعدادات
    settings.sampleDataShown = true;
    await _updateSettings(settings);
  }

  Future<void> _createSampleData() async {
    final mySpaceId = const Uuid().v4();
    final healthModuleId = const Uuid().v4();
    final projectModuleId = const Uuid().v4();
    final demoTaskId = const Uuid().v4();
    final now = DateTime.now();

    await _isar.writeTxn(() async {
      // 1. إنشاء المساحة الشخصية
      final mySpace = SpaceModel()
        ..uuid = mySpaceId
        ..name = "مساحتي"
        ..type = "personal"
        ..ownerId = "guest"
        ..createdAt = now
        ..updatedAt = now
        ..isSynced = false;

      await _isar.spaceModels.put(mySpace);

      // 2. إنشاء موديول الصحة
      final healthModule = ModuleModel()
        ..uuid = healthModuleId
        ..spaceId = mySpaceId
        ..name = "ملفي الصحي"
        ..type = "health"
        ..createdAt = now
        ..updatedAt = now
        ..isSynced = false;

      await _isar.moduleModels.put(healthModule);

      // 3. إنشاء موديول المشروع
      final projectModule = ModuleModel()
        ..uuid = projectModuleId
        ..spaceId = mySpaceId
        ..name = "ترميم البيت"
        ..type = "project"
        ..createdAt = now
        ..updatedAt = now
        ..isSynced = false;

      await _isar.moduleModels.put(projectModule);

      // 4. إنشاء مهمة تجريبية
      final demoTask = TaskModel(
        title: "شراء مواد الدهان",
        date: now.add(const Duration(hours: 1)),
        uuid: demoTaskId,
        userId: "guest",
        isSynced: false,
        moduleId: projectModuleId,
        spaceId: mySpaceId,
      )..durationMinutes = 60;

      await _isar.taskModels.put(demoTask);
    });

    debugPrint('📦 Sample data created successfully');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅✅✅ دوال التحكم في البيانات التجريبية ✅✅✅
  // ═══════════════════════════════════════════════════════════════════════════

  /// ✅ هل يوجد بيانات تجريبية؟
  @override
  Future<bool> hasSampleData() async {
    // التحقق من وجود المساحة التجريبية "مساحتي"
    final count = await _isar.spaceModels
        .filter()
        .nameEqualTo("مساحتي")
        .ownerIdEqualTo("guest")
        .deletedAtIsNull()
        .count();
    return count > 0;
  }

  /// ✅ رفض/حذف البيانات التجريبية نهائياً
  @override
  Future<void> dismissSampleData() async {
    // 1. حذف البيانات
    await _isar.writeTxn(() async {
      // حذف المهام المرتبطة بالمساحات التجريبية
      final sampleSpaces = await _isar.spaceModels
          .filter()
          .ownerIdEqualTo("guest")
          .findAll();

      for (final space in sampleSpaces) {
        await _isar.taskModels.filter().spaceIdEqualTo(space.uuid).deleteAll();

        await _isar.moduleModels
            .filter()
            .spaceIdEqualTo(space.uuid)
            .deleteAll();
      }

      // حذف المساحات التجريبية
      await _isar.spaceModels.filter().ownerIdEqualTo("guest").deleteAll();
    });

    // 2. تحديث الإعدادات
    final settings = await _getOrCreateSettings();
    settings.sampleDataDismissed = true;
    await _updateSettings(settings);

    debugPrint('🗑️ Sample data dismissed permanently');
  }

  /// ✅ إعادة تعيين حالة البيانات التجريبية (للتطوير/الاختبار)
  @override
  Future<void> resetSampleDataState() async {
    final settings = await _getOrCreateSettings();
    settings.sampleDataShown = false;
    settings.sampleDataDismissed = false;
    await _updateSettings(settings);

    debugPrint('🔄 Sample data state reset');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ensurePersonalSpaceExists - فارغة (ليست إلزامية)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> ensurePersonalSpaceExists() async {
    // ✅ لا نفعل شيئاً - ليس إلزامياً وجود مساحة شخصية
    // المستخدم حر في إنشاء مساحات أو عدم إنشائها
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // حذف مساحة
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> deleteSpace(String uuid) async {
    await _isar.writeTxn(() async {
      final space = await _isar.spaceModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();

      if (space != null) {
        // ✅ الحذف النهائي
        await _isar.spaceModels.delete(space.id);

        // حذف الموديولات والمهام المرتبطة
        await _isar.moduleModels.filter().spaceIdEqualTo(uuid).deleteAll();

        await _isar.taskModels.filter().spaceIdEqualTo(uuid).deleteAll();

        debugPrint('🗑️ Space deleted permanently: $uuid');
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ترحيل البيانات للضيف
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> migrateDataForGuest(String oldUserId) async {
    await _isar.writeTxn(() async {
      final spaces = await _isar.spaceModels
          .filter()
          .ownerIdEqualTo(oldUserId)
          .findAll();

      for (var space in spaces) {
        space.ownerId = 'guest';
        space.isSynced = false;
        space.updatedAt = DateTime.now();

        if (space.type == 'shared' || space.type == 'work') {
          space.type = 'archived_shared';
          space.name = "${space.name} (أرشيف)";
        }

        await _isar.spaceModels.put(space);
      }

      final tasks = await _isar.taskModels
          .filter()
          .userIdEqualTo(oldUserId)
          .findAll();

      for (var task in tasks) {
        task.userId = 'guest';
        task.isSynced = false;
        await _isar.taskModels.put(task);
      }
    });

    debugPrint("✅ All data migrated to guest. Shared spaces archived.");
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // تحديث الموديول
  // ═══════════════════════════════════════════════════════════════════════════

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
        if (status != null) module.status = status;

        module.updatedAt = DateTime.now();
        module.isSynced = false;

        await _isar.moduleModels.put(module);
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إحصائيات المشروع
  // ═══════════════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════════════
  // تحديث صلاحيات التفويض
  // ═══════════════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════════════
  // مسح جميع البيانات المحلية
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> clearAllLocalData() async {
    await _isar.writeTxn(() async {
      await _isar.spaceModels.clear();
      await _isar.moduleModels.clear();
      await _isar.taskModels.clear();
    });
    // ❌ لا نستدعي initDefaultData - المستخدم يريد بداية نظيفة
  }
}

//--------------------------------------------------------------------------

// // lib/features/space/data/repositories/space_repository_impl.dart
// // ✅ الإصلاح الشامل لمشاكل المساحات المشتركة

// import 'package:athar/features/space/data/models/module_model.dart';
// import 'package:athar/features/space/data/models/project_stats.dart';
// import 'package:athar/features/space/data/models/space_model.dart';
// import 'package:athar/features/space/domain/repositories/space_repository.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:isar/isar.dart';
// import 'package:injectable/injectable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:athar/core/exceptions/shared_space_exception.dart';

// /// ✅ Exception مخصص للمساحات المشتركة
// class SharedSpaceException implements Exception {
//   final String message;
//   final String code;

//   SharedSpaceException(this.message, {this.code = 'SHARED_SPACE_ERROR'});

//   @override
//   String toString() => 'SharedSpaceException: $message (code: $code)';
// }

// // ✅ هذا السطر يخبر GetIt بحقن هذا الكلاس عند طلب SpaceRepository
// @LazySingleton(as: SpaceRepository)
// class SpaceRepositoryImpl implements SpaceRepository {
//   // ✅ التعديل الأهم: إضافة implements لربط الكلاس بالواجهة

//   final Isar _isar;
//   final SupabaseClient _supabase = Supabase.instance.client;

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅✅✅ مفاتيح SharedPreferences للتحكم في البيانات التجريبية ✅✅✅
//   // ═══════════════════════════════════════════════════════════════════════════
//   static const String _kSampleDataShownKey = 'sample_data_shown_v1';
//   static const String _kSampleDataDismissedKey = 'sample_data_dismissed_v1';
//   static const String _kSampleSpaceIdKey = 'sample_space_id';
//   static const String _kSampleModuleIdKey = 'sample_module_id';
//   static const String _kSampleTaskIdKey = 'sample_task_id';

//   SpaceRepositoryImpl(this._isar);

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅ Helper: التحقق من أن المستخدم مسجل دخول
//   // ═══════════════════════════════════════════════════════════════════════════

//   bool get _isAuthenticated => _supabase.auth.currentUser != null;

//   String get _currentUserId => _supabase.auth.currentUser?.id ?? 'guest';

//   /// ✅ يرمي exception إذا حاول guest عمل شيء يتطلب تسجيل دخول
//   void _requireAuth(String operation) {
//     if (!_isAuthenticated) {
//       throw SharedSpaceException(
//         'يجب تسجيل الدخول للقيام بـ: $operation',
//         code: 'AUTH_REQUIRED',
//       );
//     }
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // مراقبة المساحات
//   // ═══════════════════════════════════════════════════════════════════════════

//   // 1. مراقبة المساحات الخاصة بي (Stream)

//   @override
//   Stream<List<SpaceModel>> watchMySpaces() {
//     final userId = _currentUserId;

//     return _isar.spaceModels
//         .filter()
//         .ownerIdEqualTo(userId)
//         .deletedAtIsNull()
//         .sortByCreatedAt()
//         .watch(fireImmediately: true);
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅ إنشاء مساحة - مع التحقق من الصلاحيات
//   // ═══════════════════════════════════════════════════════════════════════════

//   @override
//   Future<void> createSpace({required String name, required String type}) async {
//     final userId = _currentUserId;

//     // ✅ التحقق: المساحات المشتركة تتطلب تسجيل دخول
//     if (type == 'shared' || type == 'work' || type == 'team') {
//       _requireAuth('إنشاء مساحة مشتركة');
//     }

//     final newSpace = SpaceModel()
//       ..uuid = const Uuid().v4()
//       ..name = name
//       ..type = type
//       ..ownerId = userId
//       ..createdAt = DateTime.now()
//       ..updatedAt = DateTime.now()
//       ..isSynced = false;

//     await _isar.writeTxn(() async {
//       await _isar.spaceModels.put(newSpace);
//     });

//     // ✅ للمساحات المشتركة: إضافة المالك كعضو تلقائياً
//     if (type == 'shared' && _isAuthenticated) {
//       try {
//         await _addOwnerAsMember(newSpace.uuid, userId);
//       } catch (e) {
//         debugPrint('⚠️ Could not add owner as member: $e');
//       }
//     }
//   }

//   /// ✅ إضافة المالك كعضو في المساحة المشتركة
//   Future<void> _addOwnerAsMember(String spaceId, String userId) async {
//     await _supabase.from('space_members').insert({
//       'space_id': spaceId,
//       'user_id': userId,
//       'role': 'owner',
//       'joined_at': DateTime.now().toIso8601String(),
//     });
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅ جلب الأعضاء - إصلاح خطأ PGRST200
//   // ═══════════════════════════════════════════════════════════════════════════

//   @override
//   Future<List<Map<String, dynamic>>> getSpaceMembers(String spaceId) async {
//     // ✅ التحقق من تسجيل الدخول
//     if (!_isAuthenticated) {
//       debugPrint('⚠️ getSpaceMembers: User not authenticated');
//       return [];
//     }

//     try {
//       // ✅ الطريقة الآمنة: استعلامات منفصلة بدون embedded query
//       // هذا يعمل حتى لو لم يكن هناك foreign key

//       // 1. جلب الأعضاء
//       final membersResponse = await _supabase
//           .from('space_members')
//           .select('id, space_id, user_id, role, joined_at')
//           .eq('space_id', spaceId);

//       if (membersResponse.isEmpty) {
//         return [];
//       }

//       // 2. جمع user_ids
//       final userIds = (membersResponse as List)
//           .map((m) => m['user_id'] as String)
//           .toSet()
//           .toList();

//       // 3. جلب profiles منفصلة
//       final profilesResponse = await _supabase
//           .from('profiles')
//           .select('user_id, full_name, avatar_url, username')
//           .inFilter('user_id', userIds);

//       // 4. إنشاء map للـ profiles
//       final profilesMap = <String, Map<String, dynamic>>{};
//       for (final profile in profilesResponse) {
//         profilesMap[profile['user_id']] = profile;
//       }

//       // 5. دمج البيانات
//       final result = <Map<String, dynamic>>[];
//       for (final member in membersResponse) {
//         final userId = member['user_id'] as String;
//         final profile = profilesMap[userId] ?? {};

//         result.add({
//           'id': member['id'],
//           'space_id': member['space_id'],
//           'user_id': userId,
//           'role': member['role'],
//           'joined_at': member['joined_at'],
//           // ✅ بيانات البروفايل مدمجة
//           'full_name': profile['full_name'],
//           'avatar_url': profile['avatar_url'],
//           'username': profile['username'],
//         });
//       }

//       return result;
//     } catch (e) {
//       debugPrint('❌ Error fetching space members: $e');

//       // ✅ Fallback: جلب الأعضاء بدون profiles
//       try {
//         final response = await _supabase
//             .from('space_members')
//             .select('id, space_id, user_id, role, joined_at')
//             .eq('space_id', spaceId);

//         return List<Map<String, dynamic>>.from(response);
//       } catch (e2) {
//         debugPrint('❌ Fallback also failed: $e2');
//         return [];
//       }
//     }
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅ التحقق من إمكانية التحويل لمشتركة
//   // ═══════════════════════════════════════════════════════════════════════════

//   /// ✅ دالة جديدة: التحقق من إمكانية تحويل مساحة لمشتركة
//   Future<bool> canConvertToShared() async {
//     return _isAuthenticated;
//   }

//   /// ✅ دالة جديدة: تحويل مساحة شخصية لمشتركة
//   Future<void> convertToShared(String spaceUuid) async {
//     _requireAuth('تحويل المساحة لمشتركة');

//     await _isar.writeTxn(() async {
//       final space = await _isar.spaceModels
//           .filter()
//           .uuidEqualTo(spaceUuid)
//           .findFirst();

//       if (space != null) {
//         space.type = 'shared';
//         space.isSynced = false;
//         space.updatedAt = DateTime.now();
//         await _isar.spaceModels.put(space);
//       }
//     });

//     // إضافة المالك كعضو
//     await _addOwnerAsMember(spaceUuid, _currentUserId);
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // باقي الدوال كما هي مع تحسينات بسيطة
//   // ═══════════════════════════════════════════════════════════════════════════

//   @override
//   Future<void> claimLocalSpaces(String userId) async {
//     final localSpaces = await _isar.spaceModels
//         .filter()
//         .ownerIdEqualTo('guest')
//         .findAll();

//     final localTasks = await _isar.taskModels
//         .filter()
//         .userIdEqualTo('guest')
//         .findAll();

//     if (localSpaces.isNotEmpty || localTasks.isNotEmpty) {
//       await _isar.writeTxn(() async {
//         for (final space in localSpaces) {
//           space.ownerId = userId;
//           space.isSynced = false;
//           space.updatedAt = DateTime.now();
//           await _isar.spaceModels.put(space);
//         }

//         for (final task in localTasks) {
//           task.userId = userId;
//           task.isSynced = false;
//           await _isar.taskModels.put(task);
//         }
//       });
//       debugPrint("✅ Local data claimed for user: $userId");
//     }
//   }

//   @override
//   Future<void> removeMember(String spaceId, String userId) async {
//     _requireAuth('إزالة عضو');

//     await _supabase.from('space_members').delete().match({
//       'space_id': spaceId,
//       'user_id': userId,
//     });
//   }

//   @override
//   Future<void> updateMemberRole(
//     String spaceId,
//     String userId,
//     String role,
//   ) async {
//     _requireAuth('تغيير صلاحيات عضو');

//     await _supabase.from('space_members').update({'role': role}).match({
//       'space_id': spaceId,
//       'user_id': userId,
//     });
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅✅✅ إصلاح initDefaultData - لا تتكرر البيانات ✅✅✅
//   // ═══════════════════════════════════════════════════════════════════════════

//   @override
//   Future<void> initDefaultData() async {
//     final prefs = await SharedPreferences.getInstance();

//     // ✅ التحقق: هل تم عرض البيانات التجريبية من قبل؟
//     final alreadyShown = prefs.getBool(_kSampleDataShownKey) ?? false;
//     final dismissed = prefs.getBool(_kSampleDataDismissedKey) ?? false;

//     // إذا تم عرضها وحذفها، لا نعرضها مرة أخرى
//     if (alreadyShown && dismissed) {
//       if (kDebugMode) {
//         print('📦 Sample data was dismissed by user, skipping...');
//       }
//       return;
//     }

//     // التحقق من وجود أي مساحات (بما في ذلك المحذوفة)
//     final totalCount = await _isar.spaceModels.count();
//     if (totalCount > 0) {
//       // حفظ أنه تم عرض البيانات
//       await prefs.setBool(_kSampleDataShownKey, true);
//       return;
//     }

//     // إنشاء البيانات التجريبية للمرة الأولى فقط
//     await _createSampleData(prefs);
//   }

//   /// ✅ إنشاء البيانات التجريبية مع حفظ الـ IDs
//   Future<void> _createSampleData(SharedPreferences prefs) async {
//     final mySpaceId = const Uuid().v4();
//     final healthModuleId = const Uuid().v4();
//     final projectModuleId = const Uuid().v4();
//     final demoTaskId = const Uuid().v4();
//     final now = DateTime.now();

//     await _isar.writeTxn(() async {
//       // 1. إنشاء المساحة الشخصية
//       final mySpace = SpaceModel()
//         ..uuid = mySpaceId
//         ..name = "مساحتي"
//         ..type = "personal"
//         ..ownerId = "guest"
//         ..createdAt = now
//         ..updatedAt = now
//         ..isSynced = false
//         ..isSampleData = true; // ✅ علامة للبيانات التجريبية

//       await _isar.spaceModels.put(mySpace);

//       // 2. إنشاء موديول الصحة
//       final healthModule = ModuleModel()
//         ..uuid = healthModuleId
//         ..spaceId = mySpaceId
//         ..name = "ملفي الصحي"
//         ..type = "health"
//         ..createdAt = now
//         ..updatedAt = now
//         ..isSynced = false
//         ..isSampleData = true;

//       await _isar.moduleModels.put(healthModule);

//       // 3. إنشاء موديول المشروع
//       final projectModule = ModuleModel()
//         ..uuid = projectModuleId
//         ..spaceId = mySpaceId
//         ..name = "ترميم البيت"
//         ..type = "project"
//         ..createdAt = now
//         ..updatedAt = now
//         ..isSynced = false
//         ..isSampleData = true;

//       await _isar.moduleModels.put(projectModule);

//       // 4. إنشاء مهمة تجريبية
//       final demoTask =
//           TaskModel(
//               title: "شراء مواد الدهان",
//               date: now.add(const Duration(hours: 1)),
//               uuid: demoTaskId,
//               userId: "guest",
//               isSynced: false,
//               moduleId: projectModuleId,
//               spaceId: mySpaceId,
//             )
//             ..durationMinutes = 60
//             ..isSampleData = true;

//       await _isar.taskModels.put(demoTask);
//     });

//     // ✅ حفظ الـ IDs لإمكانية الحذف لاحقاً
//     await prefs.setBool(_kSampleDataShownKey, true);
//     await prefs.setString(_kSampleSpaceIdKey, mySpaceId);
//     await prefs.setString(_kSampleModuleIdKey, projectModuleId);
//     await prefs.setString(_kSampleTaskIdKey, demoTaskId);

//     if (kDebugMode) {
//       print('📦 Sample data created successfully');
//     }
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅✅✅ دوال جديدة للتحكم في البيانات التجريبية ✅✅✅
//   // ═══════════════════════════════════════════════════════════════════════════

//   /// ✅ هل يوجد بيانات تجريبية؟
//   @override
//   Future<bool> hasSampleData() async {
//     final count = await _isar.spaceModels
//         .filter()
//         .isSampleDataEqualTo(true)
//         .deletedAtIsNull()
//         .count();
//     return count > 0;
//   }

//   /// ✅ حذف جميع البيانات التجريبية نهائياً
//   @override
//   Future<void> dismissSampleData() async {
//     final prefs = await SharedPreferences.getInstance();

//     await _isar.writeTxn(() async {
//       // حذف المهام التجريبية
//       await _isar.taskModels.filter().isSampleDataEqualTo(true).deleteAll();

//       // حذف الموديولات التجريبية
//       await _isar.moduleModels.filter().isSampleDataEqualTo(true).deleteAll();

//       // حذف المساحات التجريبية
//       await _isar.spaceModels.filter().isSampleDataEqualTo(true).deleteAll();
//     });

//     // ✅ تسجيل أن المستخدم رفض البيانات التجريبية
//     await prefs.setBool(_kSampleDataDismissedKey, true);

//     if (kDebugMode) {
//       print('🗑️ Sample data dismissed permanently');
//     }
//   }

//   /// ✅ إعادة تعيين حالة البيانات التجريبية (للتطوير/الاختبار)
//   @override
//   Future<void> resetSampleDataState() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_kSampleDataShownKey);
//     await prefs.remove(_kSampleDataDismissedKey);
//     await prefs.remove(_kSampleSpaceIdKey);
//     await prefs.remove(_kSampleModuleIdKey);
//     await prefs.remove(_kSampleTaskIdKey);

//     if (kDebugMode) {
//       print('🔄 Sample data state reset');
//     }
//   }

//   @override
//   Future<void> ensurePersonalSpaceExists() async {
//     // final userId = _currentUserId;
//     // final count = await _isar.spaceModels
//     //     .filter()
//     //     .ownerIdEqualTo(userId)
//     //     .and()
//     //     .typeEqualTo('personal')
//     //     .deletedAtIsNull()
//     //     .count();

//     // if (count == 0) {
//     //   await createSpace(name: "مساحتي", type: "personal");
//     // }

//     // ✅ لا نفعل شيئاً - ليس إلزامياً وجود مساحة شخصية
//     debugPrint('ℹ️ ensurePersonalSpaceExists called but not enforced');
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // حذف مساحة
//   // ═══════════════════════════════════════════════════════════════════════════

//   @override
//   Future<void> deleteSpace(String uuid) async {
//     await _isar.writeTxn(() async {
//       final space = await _isar.spaceModels
//           .filter()
//           .uuidEqualTo(uuid)
//           .findFirst();

//       if (space != null) {
//         // ✅ إذا كانت بيانات تجريبية، نحذفها نهائياً
//         if (space.isSampleData == true) {
//           await _isar.spaceModels.delete(space.id);

//           // حذف الموديولات والمهام المرتبطة
//           await _isar.moduleModels.filter().spaceIdEqualTo(uuid).deleteAll();

//           await _isar.taskModels.filter().spaceIdEqualTo(uuid).deleteAll();
//         } else {
//           // الحذف الناعم للمساحات العادية
//           space.deletedAt = DateTime.now();
//           space.isSynced = false;
//           space.updatedAt = DateTime.now();
//           await _isar.spaceModels.put(space);
//         }
//       }
//     });
//   }

//   @override
//   Future<void> migrateDataForGuest(String oldUserId) async {
//     await _isar.writeTxn(() async {
//       final spaces = await _isar.spaceModels
//           .filter()
//           .ownerIdEqualTo(oldUserId)
//           .findAll();

//       for (var space in spaces) {
//         space.ownerId = 'guest';
//         space.isSynced = false;
//         space.updatedAt = DateTime.now();

//         if (space.type == 'shared' || space.type == 'work') {
//           space.type = 'archived_shared';
//           space.name = "${space.name} (أرشيف)";
//         }

//         await _isar.spaceModels.put(space);
//       }

//       final tasks = await _isar.taskModels
//           .filter()
//           .userIdEqualTo(oldUserId)
//           .findAll();

//       for (var task in tasks) {
//         task.userId = 'guest';
//         task.isSynced = false;
//         await _isar.taskModels.put(task);
//       }
//     });

//     if (kDebugMode) {
//       print("✅ All data migrated to guest. Shared spaces archived.");
//     }
//   }

//   @override
//   Future<void> updateModule({
//     required String uuid,
//     String? name,
//     String? description,
//     DateTime? startDate,
//     DateTime? endDate,
//     String? status,
//   }) async {
//     await _isar.writeTxn(() async {
//       final module = await _isar.moduleModels
//           .filter()
//           .uuidEqualTo(uuid)
//           .findFirst();
//       if (module != null) {
//         if (name != null) module.name = name;
//         if (description != null) module.description = description;
//         if (startDate != null) module.startDate = startDate;
//         if (endDate != null) module.endDate = endDate;
//         if (status != null) module.status = status;

//         module.updatedAt = DateTime.now();
//         module.isSynced = false;

//         await _isar.moduleModels.put(module);
//       }
//     });
//   }

//   @override
//   Future<ProjectStats> getProjectStats(String moduleUuid) async {
//     final totalTasks = await _isar.taskModels
//         .filter()
//         .moduleIdEqualTo(moduleUuid)
//         .deletedAtIsNull()
//         .count();

//     final completedTasks = await _isar.taskModels
//         .filter()
//         .moduleIdEqualTo(moduleUuid)
//         .deletedAtIsNull()
//         .isCompletedEqualTo(true)
//         .count();

//     return ProjectStats(total: totalTasks, completed: completedTasks);
//   }

//   @override
//   Future<void> updateSpaceDelegation(String uuid, bool allowDelegation) async {
//     await _isar.writeTxn(() async {
//       final space = await _isar.spaceModels
//           .filter()
//           .uuidEqualTo(uuid)
//           .findFirst();
//       if (space != null) {
//         space.allowMemberDelegation = allowDelegation;
//         space.isSynced = false;
//         space.updatedAt = DateTime.now();
//         await _isar.spaceModels.put(space);
//       }
//     });
//   }

//   @override
//   Future<void> clearAllLocalData() async {
//     await _isar.writeTxn(() async {
//       await _isar.spaceModels.clear();
//       await _isar.moduleModels.clear();
//       await _isar.taskModels.clear();
//     });
//     await initDefaultData();
//   }
// }

//--------------------------------------------------------------------------
// import 'package:athar/features/space/data/models/module_model.dart';
// import 'package:athar/features/space/data/models/project_stats.dart';
// import 'package:athar/features/space/data/models/space_model.dart';
// import 'package:athar/features/space/domain/repositories/space_repository.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// import 'package:isar/isar.dart';
// import 'package:injectable/injectable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';

// @LazySingleton(
//   as: SpaceRepository,
// ) // ✅ هذا السطر يخبر GetIt بحقن هذا الكلاس عند طلب SpaceRepository
// class SpaceRepositoryImpl implements SpaceRepository {
//   // ✅ التعديل الأهم: إضافة implements لربط الكلاس بالواجهة
//   final Isar _isar;
//   final SupabaseClient _supabase = Supabase.instance.client;

//   SpaceRepositoryImpl(this._isar);

//   // 1. مراقبة المساحات الخاصة بي (Stream)
//   @override // ✅ إضافة override
//   Stream<List<SpaceModel>> watchMySpaces() {
//     // إذا لم يكن هناك مستخدم مسجل، نستخدم 'guest' كمعرف
//     final userId = _supabase.auth.currentUser?.id ?? 'guest';

//     return _isar.spaceModels
//         .filter()
//         .ownerIdEqualTo(userId)
//         .deletedAtIsNull()
//         .sortByCreatedAt()
//         .watch(fireImmediately: true);
//   }

//   // ✅ الدالة المصححة بالكامل
//   @override // ✅ إضافة override
//   Future<void> claimLocalSpaces(String userId) async {
//     // 1. البحث عن المساحات المملوكة للزائر "guest"
//     // لاحظ: استخدمنا ownerIdEqualTo('guest') لأن هذا ما تم تعيينه في initDefaultData
//     final localSpaces = await _isar.spaceModels
//         .filter()
//         .ownerIdEqualTo('guest')
//         .findAll();

//     // 2. البحث عن المهام المملوكة للزائر
//     final localTasks = await _isar.taskModels
//         .filter()
//         .userIdEqualTo('guest')
//         .findAll();

//     if (localSpaces.isNotEmpty || localTasks.isNotEmpty) {
//       await _isar.writeTxn(() async {
//         // أ. تحديث ملكية المساحات
//         for (final space in localSpaces) {
//           space.ownerId = userId; // نقل الملكية للمستخدم الجديد
//           space.isSynced = false; // لرفعها للسحابة
//           space.updatedAt = DateTime.now();
//           await _isar.spaceModels.put(space);
//         }

//         // ب. تحديث ملكية المهام
//         for (final task in localTasks) {
//           task.userId = userId; // نقل الملكية للمستخدم الجديد
//           task.isSynced = false;
//           await _isar.taskModels.put(task);
//         }

//         // ملاحظة: الموديولات (Modules) عادة تتبع المساحة عبر spaceId
//         // لذا لا نحتاج لتحديثها يدوياً إلا إذا كان لديها حقل ownerId خاص بها
//       });
//       debugPrint("✅ Local data (Spaces & Tasks) claimed for user: $userId");
//     }
//   }

//   @override
//   Future<void> removeMember(String spaceId, String userId) async {
//     await _supabase.from('space_members').delete().match({
//       'space_id': spaceId,
//       'user_id': userId,
//     });
//   }

//   @override
//   Future<void> updateMemberRole(
//     String spaceId,
//     String userId,
//     String role,
//   ) async {
//     await _supabase.from('space_members').update({'role': role}).match({
//       'space_id': spaceId,
//       'user_id': userId,
//     });
//   }

//   // ✅ دالة إنشاء البيانات الافتراضية للزوار (تم تحسين التحقق)
//   // ملاحظة: إذا كانت هذه الدالة موجودة في الواجهة SpaceRepository أضف @override، وإلا اتركها كما هي.
//   // سأضيفها كدالة عامة (Public) لأنك تستدعيها من main.dart
//   @override // ✅ تأكد من وجود هذا
//   Future<void> initDefaultData() async {
//     final count = await _isar.spaceModels.filter().deletedAtIsNull().count();
//     if (count > 0) return;

//     final mySpaceId = const Uuid().v4();
//     final healthModuleId = const Uuid().v4();
//     final projectModuleId = const Uuid().v4();
//     final now = DateTime.now();

//     await _isar.writeTxn(() async {
//       final mySpace = SpaceModel()
//         ..uuid = mySpaceId
//         ..name = "مساحتي"
//         ..type = "personal"
//         ..ownerId = "guest"
//         ..createdAt = now
//         ..updatedAt = now
//         ..isSynced = false;
//       await _isar.spaceModels.put(mySpace);

//       final healthModule = ModuleModel()
//         ..uuid = healthModuleId
//         ..spaceId = mySpaceId
//         ..name = "ملفي الصحي"
//         ..type = "health"
//         ..createdAt = now
//         ..updatedAt = now
//         ..isSynced = false;
//       await _isar.moduleModels.put(healthModule);

//       final projectModule = ModuleModel()
//         ..uuid = projectModuleId
//         ..spaceId = mySpaceId
//         ..name = "ترميم البيت"
//         ..type = "project"
//         ..createdAt = now
//         ..updatedAt = now
//         ..isSynced = false;
//       await _isar.moduleModels.put(projectModule);

//       final demoTask = TaskModel(
//         title: "شراء مواد الدهان",
//         date: now.add(const Duration(hours: 1)),
//         uuid: const Uuid().v4(),
//         userId: "guest",
//         isSynced: false,
//         moduleId: projectModuleId,
//         spaceId: mySpaceId,
//       )..durationMinutes = 60;
//       await _isar.taskModels.put(demoTask);
//     });
//   }

//   @override // ✅ إضافة override
//   Future<void> createSpace({required String name, required String type}) async {
//     final userId = _supabase.auth.currentUser?.id ?? 'guest';
//     final newSpace = SpaceModel()
//       ..uuid = const Uuid().v4()
//       ..name = name
//       ..type = type
//       ..ownerId = userId
//       ..createdAt = DateTime.now()
//       ..updatedAt = DateTime.now()
//       ..isSynced = false;

//     await _isar.writeTxn(() async {
//       await _isar.spaceModels.put(newSpace);
//     });
//   }

//   @override // ✅ إضافة override
//   Future<void> ensurePersonalSpaceExists() async {
//     final userId = _supabase.auth.currentUser?.id ?? 'guest';
//     final count = await _isar.spaceModels
//         .filter()
//         .ownerIdEqualTo(userId)
//         .and()
//         .typeEqualTo('personal')
//         .deletedAtIsNull()
//         .count();

//     if (count == 0) {
//       await createSpace(name: "مساحتي", type: "personal");
//     }
//   }

//   @override // ✅ إضافة override
//   Future<void> deleteSpace(String uuid) async {
//     await _isar.writeTxn(() async {
//       final space = await _isar.spaceModels
//           .filter()
//           .uuidEqualTo(uuid)
//           .findFirst();

//       if (space != null) {
//         space.deletedAt = DateTime.now();
//         space.isSynced = false;
//         space.updatedAt = DateTime.now();
//         await _isar.spaceModels.put(space);
//       }
//     });
//   }

//   // ✅✅ الدالة المعدلة جذرياً: ترحيل البيانات وحل مشكلة الأرشفة عند حذف الحساب السحابي
//   @override
//   Future<void> migrateDataForGuest(String oldUserId) async {
//     await _isar.writeTxn(() async {
//       // 1. التعامل مع المساحات
//       final spaces = await _isar.spaceModels
//           .filter()
//           .ownerIdEqualTo(oldUserId)
//           .findAll();

//       for (var space in spaces) {
//         // نقل الملكية للزائر
//         space.ownerId = 'guest';
//         space.isSynced = false; // قطع الاتصال بالسحابة
//         space.updatedAt = DateTime.now();

//         // 🛑 التعديل الجوهري: إذا كانت مساحة مشتركة، نحول نوعها لأرشيف
//         if (space.type == 'shared' || space.type == 'work') {
//           space.type = 'archived_shared'; // ✅ تغيير النوع لتمييزها برمجياً
//           space.name = "${space.name} (أرشيف)"; // تغيير الاسم للتوضيح للمستخدم
//         }

//         // المساحات الشخصية (personal) تبقى كما هي، فقط يتغير المالك لـ guest

//         await _isar.spaceModels.put(space);
//       }

//       // 2. ترحيل المهام المرتبطة بهذا المستخدم
//       final tasks = await _isar.taskModels
//           .filter()
//           .userIdEqualTo(oldUserId)
//           .findAll();

//       for (var task in tasks) {
//         task.userId = 'guest';
//         task.isSynced = false; // ستصبح مهام محلية للضيف
//         await _isar.taskModels.put(task);
//       }
//     });

//     if (kDebugMode) {
//       print("✅ All data migrated to guest. Shared spaces archived.");
//     }
//   }

//   // ✅ تحديث بيانات الموديول (المشروع)
//   @override
//   Future<void> updateModule({
//     required String uuid,
//     String? name,
//     String? description,
//     DateTime? startDate,
//     DateTime? endDate,
//     String? status,
//   }) async {
//     await _isar.writeTxn(() async {
//       final module = await _isar.moduleModels
//           .filter()
//           .uuidEqualTo(uuid)
//           .findFirst();
//       if (module != null) {
//         if (name != null) module.name = name;
//         if (description != null) module.description = description;
//         if (startDate != null) module.startDate = startDate;
//         if (endDate != null) module.endDate = endDate;
//         if (status != null) module.status = status; // active, archived

//         module.updatedAt = DateTime.now();
//         module.isSynced = false; // لرفع التغييرات

//         await _isar.moduleModels.put(module);
//       }
//     });
//   }

//   // ✅ جلب إحصائيات المشروع (للداشبورد)
//   @override
//   Future<ProjectStats> getProjectStats(String moduleUuid) async {
//     final totalTasks = await _isar.taskModels
//         .filter()
//         .moduleIdEqualTo(moduleUuid)
//         .deletedAtIsNull()
//         .count();

//     final completedTasks = await _isar.taskModels
//         .filter()
//         .moduleIdEqualTo(moduleUuid)
//         .deletedAtIsNull()
//         .isCompletedEqualTo(true)
//         .count();

//     return ProjectStats(total: totalTasks, completed: completedTasks);
//   }

//   @override
//   Future<void> updateSpaceDelegation(String uuid, bool allowDelegation) async {
//     await _isar.writeTxn(() async {
//       final space = await _isar.spaceModels
//           .filter()
//           .uuidEqualTo(uuid)
//           .findFirst();
//       if (space != null) {
//         space.allowMemberDelegation = allowDelegation;
//         space.isSynced = false;
//         space.updatedAt = DateTime.now();
//         await _isar.spaceModels.put(space);
//       }
//     });
//   }

//   @override // ✅ إضافة override
//   Future<void> clearAllLocalData() async {
//     await _isar.writeTxn(() async {
//       await _isar.spaceModels.clear();
//       await _isar.moduleModels.clear();
//       await _isar.taskModels.clear();
//       // إعادة تهيئة البيانات الافتراضية للزائر لكي لا يبدو التطبيق معطلاً
//     });
//     // إعادة إنشاء مساحة افتراضية نظيفة
//     await initDefaultData();
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getSpaceMembers(String spaceId) async {
//     // نجلب الأعضاء ونربطهم بجدول profiles
//     final response = await _supabase
//         .from('space_members')
//         .select('role, user_id, profiles(full_name, avatar_url, username)')
//         .eq('space_id', spaceId);

//     return List<Map<String, dynamic>>.from(response);
//   }
// }
//--------------------------------------------------------------------------
