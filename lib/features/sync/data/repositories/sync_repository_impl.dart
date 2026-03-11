import 'package:athar/core/constants/athkar_data.dart';
import 'package:athar/core/utils/data_mappers.dart';
import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/sync/domain/repositories/sync_repository.dart';
import 'package:athar/features/task/data/models/task_model.dart';
// ✅ 1. استيرادات ضرورية للمساحات والموديولات
import 'package:athar/features/space/data/models/space_model.dart';
import 'package:athar/features/space/data/models/module_model.dart';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: SyncRepository)
class SyncRepositoryImpl implements SyncRepository {
  final Isar _isar;
  final SupabaseClient _supabase;

  SyncRepositoryImpl(this._isar, this._supabase);

  @override
  Future<void> syncEverything() async {
    bool hasConnection = await InternetConnection().hasInternetAccess;
    if (!hasConnection) {
      // لا نرمي خطأ هنا لكي لا نزعج المستخدم، فقط نتوقف بصمت
      return;
    }

    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      // إذا لم يكن مسجلاً، لا يمكن المزامنة
      return;
    }

    final userId = currentUser.id;

    try {
      // ✅ 1. الخطوة الأهم: نقل بيانات "الضيف" للمستخدم الحالي
      // هذا يحل مشكلة invalid uuid: "guest"
      await _migrateGuestData(userId);

      // ✅ 2. الترتيب الهرمي الصارم (الآباء ثم الأبناء)
      // هذا يحل مشكلة Foreign Key Constraint
      await _syncSpaces(userId); // نبني البيت
      await _syncModules(userId); // نبني الغرف

      // ✅ 3. رفع المهام (الأثاث)
      await _syncTasks(userId);

      // ✅ 4. باقي البيانات
      await _syncPreferences(userId);
      await _syncHabits(userId);
    } catch (e) {
      if (kDebugMode) {
        print("Sync Error Details: $e");
      }
      // rethrow; // لا نوقف التطبيق بسبب فشل المزامنة الخلفية
    }
  }

  // -----------------------------------------------------------------------------
  // ✅ دالة نقل البيانات (Migration) - الحل الجذري لمشكلة Guest UUID
  // -----------------------------------------------------------------------------
  Future<void> _migrateGuestData(String realUserId) async {
    await _isar.writeTxn(() async {
      // 1. نقل المساحات
      final guestSpaces = await _isar.spaceModels
          .filter()
          .ownerIdEqualTo('guest')
          .findAll();

      for (var space in guestSpaces) {
        space.ownerId = realUserId;
        space.isSynced = false; // إجبار المزامنة لرفع المالك الجديد
        await _isar.spaceModels.put(space);
      }

      // 2. نقل المهام
      final guestTasks = await _isar.taskModels
          .filter()
          .userIdEqualTo('guest')
          .findAll();

      for (var task in guestTasks) {
        task.userId = realUserId;
        task.isSynced = false; // إجبار المزامنة
        await _isar.taskModels.put(task);
      }

      // ملاحظة: الموديولات لا تملك ownerId مباشر (تتبع المساحة)، لذا لا تحتاج تعديل
    });
  }

  // -----------------------------------------------------------------------------
  // ✅ مزامنة المساحات (Spaces)
  // -----------------------------------------------------------------------------
  Future<void> _syncSpaces(String userId) async {
    final unsynced = await _isar.spaceModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();

    for (var item in unsynced) {
      try {
        // نستخدم toMap من SpaceMapper
        await _supabase.from('spaces').upsert(item.toMap());

        await _isar.writeTxn(() async {
          item.isSynced = true;
          await _isar.spaceModels.put(item);
        });
      } catch (e) {
        if (kDebugMode) print("Push Space Error: $e");
      }
    }
    // (يمكن إضافة Pull للمساحات هنا مستقبلاً)
  }

  // -----------------------------------------------------------------------------
  // ✅ مزامنة الموديولات (Modules)
  // -----------------------------------------------------------------------------
  Future<void> _syncModules(String userId) async {
    final unsynced = await _isar.moduleModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();

    for (var item in unsynced) {
      try {
        // نستخدم toMap من ModuleMapper
        await _supabase.from('modules').upsert(item.toMap());

        await _isar.writeTxn(() async {
          item.isSynced = true;
          await _isar.moduleModels.put(item);
        });
      } catch (e) {
        if (kDebugMode) print("Push Module Error: $e");
      }
    }
  }

  // -----------------------------------------------------------------------------
  // ✅ مزامنة المهام (Tasks)
  // -----------------------------------------------------------------------------
  Future<void> _syncTasks(String userId) async {
    // 1. PUSH
    final unsyncedTasks = await _isar.taskModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();

    for (final task in unsyncedTasks) {
      try {
        final taskData = task.toMap();

        // حماية إضافية: ضمان أن المعرف ليس فارغاً أو guest
        if (taskData['created_by'] == null ||
            taskData['created_by'] == '' ||
            taskData['created_by'] == 'guest') {
          taskData['created_by'] = userId;
        }

        await _supabase.from('tasks').upsert(taskData, onConflict: 'uuid');

        await _isar.writeTxn(() async {
          task.isSynced = true;
          await _isar.taskModels.put(task);
        });
      } catch (e) {
        if (kDebugMode) {
          print("Push Task Error: $e");
        }
      }
    }

    // 2. PULL
    try {
      final remoteData = await _supabase
          .from('tasks')
          .select()
          .gt(
            'updated_at',
            DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
          );

      await _isar.writeTxn(() async {
        for (final item in remoteData) {
          final String uuid = item['uuid'] ?? const Uuid().v4();

          final remoteDeletedAt = item['deleted_at'] != null
              ? DateTime.tryParse(item['deleted_at'].toString())
              : null;

          final DateTime remoteUpdatedAt = item['updated_at'] != null
              ? DateTime.tryParse(item['updated_at'].toString()) ??
                    DateTime.now()
              : DateTime.now();

          final localTask = await _isar.taskModels
              .filter()
              .uuidEqualTo(uuid)
              .findFirst();

          final remoteTaskObj = TaskModel(
            title: '',
            date: DateTime.now(),
            uuid: uuid,
            userId: '',
            isSynced: true,
          );

          remoteTaskObj.updateFromMap(item);
          remoteTaskObj.updatedAt = remoteUpdatedAt;
          remoteTaskObj.deletedAt = remoteDeletedAt;

          if (localTask == null) {
            if (remoteDeletedAt == null) {
              await _isar.taskModels.put(remoteTaskObj);
            }
          } else {
            final winner = _resolveConflict(
              localTask,
              remoteTaskObj,
              localTask.updatedAt,
              remoteUpdatedAt,
              localTask.deletedAt,
              remoteDeletedAt,
            );

            if (winner == remoteTaskObj) {
              remoteTaskObj.id = localTask.id;
              await _isar.taskModels.put(remoteTaskObj);
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) print("Pull Task Error: $e");
    }
  }

  // -----------------------------------------------------------------------------
  // ✅ مزامنة العادات والأذكار والتفضيلات (كما هي)
  // -----------------------------------------------------------------------------
  Future<void> _syncHabits(String userId) async {
    // 1. PUSH
    final unsynced = await _isar.habitModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
    for (final habit in unsynced) {
      try {
        final map = habit.toMap();
        if (habit.type == HabitType.athkar) {
          map['athkar_items'] = habit.athkarItems
              .map((e) => e.toCloudMap())
              .toList();
        }
        await _supabase.from('habits').upsert(map, onConflict: 'uuid');
        await _isar.writeTxn(() async {
          habit.isSynced = true;
          await _isar.habitModels.put(habit);
        });
      } catch (e) {
        continue;
      }
    }

    // 2. PULL
    final remoteData = await _supabase
        .from('habits')
        .select()
        .eq('user_id', userId);

    await _isar.writeTxn(() async {
      for (final item in remoteData) {
        final String uuid = item['uuid'];
        final habitType = _parseHabitType(item['type']);
        final habitPeriod = _parseHabitPeriod(item['period']);
        final habitFreq = _parseHabitFrequency(item['frequency']);

        final local = await _isar.habitModels
            .filter()
            .uuidEqualTo(uuid)
            .findFirst();

        if (local != null) {
          final DateTime remoteUpdatedAt = item['updated_at'] != null
              ? DateTime.tryParse(item['updated_at'].toString()) ??
                    DateTime.now()
              : DateTime.now();
          final localUpdate = local.updatedAt ?? DateTime(2000);

          if (remoteUpdatedAt.isAfter(localUpdate) ||
              remoteUpdatedAt.isAtSameMomentAs(localUpdate)) {
            local.type = habitType;
            local.period = habitPeriod;
            local.frequency = habitFreq;

            if (local.type == HabitType.athkar &&
                item['athkar_items'] != null) {
              final List remoteItems = item['athkar_items'];
              for (var localItem in local.athkarItems) {
                final match = remoteItems.firstWhere(
                  (r) => r['item_id'] == localItem.itemId,
                  orElse: () => null,
                );
                if (match != null) {
                  localItem.currentCount =
                      match['current_count'] > localItem.currentCount
                      ? match['current_count']
                      : localItem.currentCount;
                  localItem.isDone =
                      localItem.isDone || (match['is_done'] ?? false);
                }
              }
              local.currentStreak = local.athkarItems.fold(
                0,
                (sum, it) => sum + it.currentCount,
              );
              local.isCompleted = local.currentStreak >= local.target;
            } else if (local.type == HabitType.regular) {
              local.currentStreak =
                  item['current_streak'] ?? local.currentStreak;
              local.isCompleted = item['is_completed'] ?? local.isCompleted;
              local.target = item['target'] ?? local.target;
            }
            local.updatedAt = remoteUpdatedAt;
            local.isSynced = true;
            await _isar.habitModels.put(local);
          }
        } else {
          if (habitType != HabitType.athkar) {
            final newHabit = HabitModel.fromMap(item);
            await _isar.habitModels.put(newHabit);
          } else {
            final items = item['athkar_items'] as List?;
            if (items != null && items.isNotEmpty) {
              _getOriginalAthkarData(items.first['item_id']);
            }
          }
        }
      }
    });
  }

  Future<void> _syncPreferences(String userId) async {
    final userSettings = await _isar.userSettings.where().findFirst();
    if (userSettings == null) return;

    final prefsData = {
      'user_id': userId,
      'is_hijri_mode': userSettings.isHijriMode,
      'is_athkar_enabled': userSettings.isAthkarEnabled,
      'athkar_display_mode': userSettings.athkarDisplayMode.name,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await _supabase.from('profiles').upsert(prefsData, onConflict: 'user_id');
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (response != null) {
        await _isar.writeTxn(() async {
          userSettings.isHijriMode =
              response['is_hijri_mode'] ?? userSettings.isHijriMode;
          userSettings.isAthkarEnabled =
              response['is_athkar_enabled'] ?? userSettings.isAthkarEnabled;
          userSettings.athkarDisplayMode = _parseDisplayMode(
            response['athkar_display_mode'],
          );
          await _isar.userSettings.put(userSettings);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Sync Preferences Error: $e");
      }
    }
  }

  // --- Helpers ---

  T _resolveConflict<T>(
    T local,
    T remote,
    DateTime? localUpdate,
    DateTime? remoteUpdate,
    DateTime? localDelete,
    DateTime? remoteDelete,
  ) {
    if (remoteDelete != null) return remote;
    if (localDelete != null) return local;
    final lTime = localUpdate ?? DateTime(2000);
    final rTime = remoteUpdate ?? DateTime(2000);
    return rTime.isAfter(lTime) ? remote : local;
  }

  HabitType _parseHabitType(String? val) => HabitType.values.firstWhere(
    (e) => e.name == val,
    orElse: () => HabitType.regular,
  );

  HabitPeriod _parseHabitPeriod(String? val) => HabitPeriod.values.firstWhere(
    (e) => e.name == val,
    orElse: () => HabitPeriod.anyTime,
  );

  HabitFrequency _parseHabitFrequency(String? val) => HabitFrequency.values
      .firstWhere((e) => e.name == val, orElse: () => HabitFrequency.daily);

  AthkarDisplayMode _parseDisplayMode(String? val) =>
      AthkarDisplayMode.values.firstWhere(
        (e) => e.name == val,
        orElse: () => AthkarDisplayMode.independent,
      );

  DhikrSource? _getOriginalAthkarData(int? itemId) {
    if (itemId == null) return null;
    int index = -1;
    if (itemId >= 4000) {
      index = itemId - 4000;
    } else if (itemId >= 3000) {
      index = itemId - 3000;
    } else if (itemId >= 2000) {
      index = itemId - 2000;
    } else if (itemId >= 1000) {
      index = itemId - 1000;
    }
    if (index >= 0 && index < AthkarData.allAthkar.length) {
      return AthkarData.allAthkar[index];
    }
    return null;
  }
}
