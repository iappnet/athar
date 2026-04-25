import 'dart:math'; // ✅ ضروري لمنطق Max Value
import 'package:athar/core/constants/athkar_data.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:athar/core/services/file_service.dart';
import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';
import 'package:athar/features/space/data/models/space_model.dart'; // ✅ استيراد المساحات
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../features/task/data/models/task_model.dart';

// ✅ تعريف حالات المزامنة الأربعة
enum SyncStatus {
  clean, // جديد كلياً
  restoreCloud, // إعادة تثبيت (محلي فارغ + سحاب ممتلئ)
  pushLocal, // جهاز جديد بدون نت سابقاً
  conflict, // تعارض (محلي ممتلئ + سحاب ممتلئ)
}

@lazySingleton
class SyncService {
  final Isar _isar;
  final HabitRepository _habitRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  SyncService(this._isar, this._habitRepository);

  // ===========================================================================
  // 🧠 1. مرحلة التحقيق والقرار (Investigation Phase)
  // ===========================================================================

  Future<SyncStatus> checkSyncStatus(String userId) async {
    try {
      // أ. فحص السحابة
      final cloudCount = await _supabase
          .from('habits')
          .count(CountOption.exact)
          .eq('user_id', userId);
      final hasCloudData = cloudCount > 0;

      // ب. فحص المحلي
      final isLocalDirty = await _habitRepository.hasUserInteractedWithHabits();

      // ج. مصفوفة القرار
      if (!isLocalDirty && !hasCloudData) {
        return SyncStatus.clean;
      } else if (!isLocalDirty && hasCloudData) {
        return SyncStatus.restoreCloud; // ✅ سيتم استرجاع البيانات
      } else if (isLocalDirty && !hasCloudData) {
        return SyncStatus.pushLocal;
      } else {
        return SyncStatus.conflict;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking sync status: $e");
      }
      return SyncStatus.clean;
    }
  }

  // ===========================================================================
  // 🚀 2. مرحلة التنفيذ (Execution Phase)
  // ===========================================================================

  Future<void> executeAutomatedSync(SyncStatus status, String userId) async {
    // Sync is a Spaces Pro feature — skip silently for free users.
    if (!getIt<SubscriptionCubit>().hasSyncAccess) return;

    switch (status) {
      case SyncStatus.clean:
        await syncAll(); // ✅ استدعاء المزامنة الكاملة بالترتيب الصحيح
        break;
      case SyncStatus.restoreCloud:
        // 🛑 التعديل الجوهري: الجلب فقط أولاً (مساحات ثم مهام ثم عادات)
        await _pullAndMergeSpaces(userId);
        await _pullAndMergeTasks(userId);
        await _pullAndMergeHabits(userId);
        break;
      case SyncStatus.pushLocal:
        // رفع كل شيء بالترتيب
        await _pushLocalSpaces(userId);
        await _pushLocalChanges(userId);
        break;
      case SyncStatus.conflict:
        break;
    }
  }

  // دوال حل التعارض
  Future<void> resolveConflictKeepCloud(String userId) async {
    await _pullAndMergeSpaces(userId);
    await _pullAndMergeTasks(userId);
    await _pullAndMergeHabits(userId);
  }

  Future<void> resolveConflictKeepLocal(String userId) async {
    await _pushLocalSpaces(userId);
    await _pushLocalChanges(userId);
  }

  Future<void> resolveConflictMerge(String userId) async {
    await _mergeDataSmartly(userId);
  }

  // ===========================================================================
  // 🔄 3. وظائف المزامنة العامة (الترتيب المقدس) 🕍
  // ===========================================================================

  Future<void> syncAll() async {
    // ✅✅ الترتيب الصحيح لمنع أخطاء المفاتيح الأجنبية (FK Errors)
    await performRetryHandshake(); // أولاً: حل المشاكل العالقة
    await syncSpaces(); // 1. ابنِ الجراج (المساحات)
    await syncTasks(); // 2. أدخل السيارة (المهام)
    await syncHabits(); // 3. العادات (مستقلة)
  }

  // --- دالة مزامنة المساحات الجديدة ---
  Future<void> syncSpaces() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      await _pushLocalSpaces(user.id);
      await _pullAndMergeSpaces(user.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sync Spaces Error: $e');
      }
    }
  }

  Future<void> syncTasks() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      await _pushLocalChanges(user.id, syncOnlyTasks: true);
      await _pullAndMergeTasks(user.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sync Tasks Error: $e');
      }
    }
  }

  Future<void> syncHabits() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      // ✅ الترتيب هنا: نحاول الرفع (المحمي)، ثم نجلب
      await _pushLocalChanges(user.id, syncOnlyHabits: true);
      await _pullAndMergeHabits(user.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sync Habits Error: $e');
      }
    }
  }

  // ===========================================================================
  // 🏗️ منطق رفع المساحات (جديد)
  // ===========================================================================

  Future<void> _pushLocalSpaces(String userId) async {
    final unsyncedSpaces = await _isar.spaceModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();

    if (unsyncedSpaces.isNotEmpty) {
      final spacesData = unsyncedSpaces.map((s) {
        final json = s.toSupabaseJson();
        // تأكد من الحقل الصحيح للمالك في قاعدة البيانات
        json['owner_id'] = userId;
        return json;
      }).toList();

      // استخدام upsert لضمان عدم التكرار
      await _supabase.from('spaces').upsert(spacesData, onConflict: 'uuid');

      await _isar.writeTxn(() async {
        for (var space in unsyncedSpaces) {
          space.isSynced = true;
          await _isar.spaceModels.put(space);
        }
      });
    }
  }

  // ===========================================================================
  // ⬆️ 4. منطق الرفع (Push) - مع جدار الحماية (The Firewall) 🛡️
  // ===========================================================================
  Future<void> performRetryHandshake() async {
    if (kDebugMode) print("🤝 Starting Sync Handshake...");

    // 1. استئناف رفع الملفات العالقة في الطابور (تم الإصلاح)
    try {
      await getIt<FileService>().processUploadQueue();
    } catch (e) {
      if (kDebugMode) print("⚠️ Error during file queue handshake: $e");
    }

    // 2. التحقق من العناصر التي تحمل isSynced = false
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _pushLocalSpaces(user.id);
    await _pushLocalChanges(user.id);

    if (kDebugMode) print("✅ Handshake Completed.");
  }

  Future<void> _pushLocalChanges(
    String userId, {
    bool syncOnlyTasks = false,
    bool syncOnlyHabits = false,
  }) async {
    // --- رفع المهام ---
    if (!syncOnlyHabits) {
      final unsyncedTasks = await _isar.taskModels
          .filter()
          .isSyncedEqualTo(false)
          .findAll();

      if (unsyncedTasks.isNotEmpty) {
        final List<Map<String, dynamic>> tasksData = [];

        // 🛑 تصفية المهام اليتيمة (التي مساحتها غير متزامنة)
        for (var t in unsyncedTasks) {
          // إذا كانت المهمة تابعة لمساحة، نتأكد أن المساحة مرفوعة
          if (t.spaceId != null) {
            final parentSpace = await _isar.spaceModels
                .filter()
                .uuidEqualTo(t.spaceId!)
                .findFirst();

            // إذا المساحة غير موجودة أو لم تتزامن بعد، نؤجل رفع المهمة
            if (parentSpace == null || !parentSpace.isSynced) {
              continue;
            }
          }

          final json = t.toJson();
          json['created_by'] = userId;
          tasksData.add(json);
        }

        if (tasksData.isNotEmpty) {
          await _supabase.from('tasks').upsert(tasksData, onConflict: 'uuid');

          // نحدث حالة المهام المرفوعة فقط
          final raisedUuids = tasksData.map((e) => e['uuid']).toSet();

          await _isar.writeTxn(() async {
            for (var task in unsyncedTasks) {
              if (raisedUuids.contains(task.uuid)) {
                task.isSynced = true;
                await _isar.taskModels.put(task);
              }
            }
          });
        }
      }
    }

    // --- رفع العادات ---
    if (!syncOnlyTasks) {
      final unsyncedHabits = await _isar.habitModels
          .filter()
          .isSyncedEqualTo(false)
          .findAll();

      if (unsyncedHabits.isNotEmpty) {
        List<Map<String, dynamic>> habitsData = [];

        for (var h in unsyncedHabits) {
          // 🛑 1. حماية المعرفات
          if (h.type == HabitType.athkar) {
            if (h.uuid != AthkarData.morningAthkarId &&
                h.uuid != AthkarData.eveningAthkarId &&
                h.uuid != AthkarData.prayerAthkarId &&
                h.uuid != AthkarData.sleepAthkarId) {
              continue;
            }
          }

          // 🛑 2. جدار الحماية (The Firewall)
          if (h.type == HabitType.athkar) {
            bool isContentTrulyEmpty = true;
            if (h.athkarItems.isNotEmpty) {
              if (h.athkarItems.any((i) => i.currentCount > 0)) {
                isContentTrulyEmpty = false;
              }
            }
            if (h.currentProgress > 0 || h.streak > 0 || h.isCompleted) {
              isContentTrulyEmpty = false;
            }
            if (isContentTrulyEmpty) {
              continue;
            }
          }

          final json = h.toMap();
          if (h.type == HabitType.athkar) {
            json['athkar_items'] = h.athkarItems
                .map((e) => e.toCloudMap())
                .toList();
          }
          json['user_id'] = userId;
          habitsData.add(json);
        }

        if (habitsData.isNotEmpty) {
          await _supabase.from('habits').upsert(habitsData, onConflict: 'uuid');
        }

        await _isar.writeTxn(() async {
          for (var habit in unsyncedHabits) {
            habit.isSynced = true;
            await _isar.habitModels.put(habit);
          }
        });
      }
    }
  }

  // ===========================================================================
  // 🧠 5. منطق الدمج الذكي (Smart Merge Logic)
  // ===========================================================================

  Future<void> _mergeDataSmartly(String userId) async {
    // 1. دمج المساحات
    await _pullAndMergeSpaces(userId);
    // (ثم نرفع المحلي)
    await _pushLocalSpaces(userId);

    // 2. دمج العادات (كما هو)
    final List<dynamic> remoteData = await _supabase
        .from('habits')
        .select()
        .eq('user_id', userId);

    await _isar.writeTxn(() async {
      for (final remoteJson in remoteData) {
        final String uuid = remoteJson['uuid'];
        final localHabit = await _isar.habitModels
            .filter()
            .uuidEqualTo(uuid)
            .findFirst();

        if (localHabit != null) {
          // ... (نفس منطق دمج العادات السابق)
          // 1. دمج الأيام
          if (remoteJson['completed_days'] != null) {
            final remoteDays = (remoteJson['completed_days'] as List)
                .map((e) => DateTime.parse(e.toString()))
                .toList();
            for (var d in remoteDays) {
              bool exists = localHabit.completedDays.any(
                (ld) =>
                    ld.year == d.year && ld.month == d.month && ld.day == d.day,
              );
              if (!exists) localHabit.completedDays.add(d);
            }
          }

          // 2. دمج السلسلة
          final remoteStreak = remoteJson['current_streak'] ?? 0;
          localHabit.currentStreak = max(
            localHabit.currentStreak,
            remoteStreak,
          );

          // 3. دمج التقدم
          final remoteUpdatedAt = remoteJson['updated_at'] != null
              ? DateTime.parse(remoteJson['updated_at'])
              : DateTime(2000);

          final isRemoteToday = _isSameDay(remoteUpdatedAt, DateTime.now());
          final isLocalToday = _isSameDay(
            localHabit.lastUpdated ?? DateTime(2000),
            DateTime.now(),
          );

          if (isRemoteToday || isLocalToday) {
            if (remoteJson['athkar_items'] != null) {
              final List remoteItems = remoteJson['athkar_items'];
              for (var localItem in localHabit.athkarItems) {
                final match = remoteItems.firstWhere(
                  (r) => r['item_id'] == localItem.itemId,
                  orElse: () => null,
                );
                if (match != null) {
                  final remoteCount = match['current_count'] ?? 0;
                  localItem.currentCount = max(
                    localItem.currentCount,
                    remoteCount,
                  );
                  localItem.isDone =
                      localItem.currentCount >= localItem.targetCount;
                }
              }
            }
            localHabit.recalculateProgress();
          }

          localHabit.isSynced = false;
          localHabit.updatedAt = DateTime.now();
          await _isar.habitModels.put(localHabit);
        } else {
          if (remoteJson['deleted_at'] == null) {
            final newHabit = HabitModel.fromMap(remoteJson);
            newHabit.isSynced = true;
            await _isar.habitModels.put(newHabit);
          }
        }
      }
    });

    await _pushLocalChanges(userId);
  }

  // ===========================================================================
  // ⬇️ 6. الجلب والدمج (القلب النابض للاسترجاع)
  // ===========================================================================

  // --- دالة جلب المساحات (جديد) ---
  Future<void> _pullAndMergeSpaces(String userId) async {
    final ownedSpaces = await _supabase
        .from('spaces')
        .select()
        .eq('owner_id', userId);

    List<dynamic> memberships = [];
    try {
      memberships = await _supabase
          .from('space_members')
          .select('space_id')
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      if (e.code == '42P17' && kDebugMode) {
        debugPrint(
          'Sync Spaces: skipping membership pull because the current '
          'Supabase RLS policy on space_members is recursively defined.',
        );
      } else {
        rethrow;
      }
    }

    final memberSpaceIds = memberships
        .map((row) => row['space_id'] as String?)
        .whereType<String>()
        .toSet();

    List<dynamic> memberSpaces = [];
    if (memberSpaceIds.isNotEmpty) {
      memberSpaces = await _supabase
          .from('spaces')
          .select()
          .inFilter('uuid', memberSpaceIds.toList());
    }

    final mergedByUuid = <String, dynamic>{};
    for (final row in [...ownedSpaces as List, ...memberSpaces]) {
      final uuid = row['uuid'] as String?;
      if (uuid != null) {
        mergedByUuid[uuid] = row;
      }
    }

    final List<SpaceModel> remoteSpaces = mergedByUuid.values
        .map((e) => SpaceModel.fromJson(e))
        .toList();

    await _isar.writeTxn(() async {
      for (var remoteSpace in remoteSpaces) {
        final localSpace = await _isar.spaceModels
            .filter()
            .uuidEqualTo(remoteSpace.uuid)
            .findFirst();

        if (localSpace == null) {
          if (remoteSpace.deletedAt == null) {
            remoteSpace.isSynced = true;
            await _isar.spaceModels.put(remoteSpace);
          }
        } else {
          // دمج (الأحدث يفوز)
          final remoteTime = remoteSpace.updatedAt ?? DateTime(2000);
          final localTime = localSpace.updatedAt ?? DateTime(2000);

          if (remoteTime.isAfter(localTime)) {
            remoteSpace.id = localSpace.id; // الحفاظ على ID المحلي
            remoteSpace.isSynced = true;
            await _isar.spaceModels.put(remoteSpace);
          }
        }
      }
    });
  }

  Future<void> _pullAndMergeHabits(String userId) async {
    final List<dynamic> remoteData = await _supabase
        .from('habits')
        .select()
        .eq('user_id', userId);

    await _isar.writeTxn(() async {
      for (final remoteJson in remoteData) {
        final String uuid = remoteJson['uuid'];
        final localHabit = await _isar.habitModels
            .filter()
            .uuidEqualTo(uuid)
            .findFirst();

        if (localHabit != null) {
          final DateTime remoteUpdatedAt = remoteJson['updated_at'] != null
              ? DateTime.parse(remoteJson['updated_at'])
              : DateTime.now();
          final localUpdatedAt = localHabit.updatedAt ?? DateTime(2000);

          bool isSystemAthkar = [
            AthkarData.morningAthkarId,
            AthkarData.eveningAthkarId,
            AthkarData.prayerAthkarId,
            AthkarData.sleepAthkarId,
          ].contains(uuid);

          bool isLocalEmpty =
              localHabit.currentProgress == 0 && localHabit.streak == 0;
          if (isLocalEmpty && localHabit.athkarItems.isNotEmpty) {
            if (localHabit.athkarItems.every((i) => i.currentCount == 0)) {
              isLocalEmpty = true;
            } else {
              isLocalEmpty = false;
            }
          }

          bool shouldMerge =
              (isSystemAthkar && isLocalEmpty) ||
              remoteUpdatedAt.isAfter(localUpdatedAt);

          if (shouldMerge) {
            localHabit.currentStreak =
                remoteJson['current_streak'] ?? localHabit.currentStreak;

            if (remoteJson['completed_days'] != null) {
              final remoteDays = (remoteJson['completed_days'] as List)
                  .map((e) => DateTime.parse(e.toString()))
                  .toList();
              for (var d in remoteDays) {
                bool exists = localHabit.completedDays.any(
                  (ld) =>
                      ld.year == d.year &&
                      ld.month == d.month &&
                      ld.day == d.day,
                );
                if (!exists) localHabit.completedDays.add(d);
              }
            }

            if (remoteJson['athkar_items'] != null) {
              final List remoteItems = remoteJson['athkar_items'];
              for (var localItem in localHabit.athkarItems) {
                var match = remoteItems.firstWhere(
                  (r) => r['item_id'] == localItem.itemId,
                  orElse: () => null,
                );
                if (match == null && localItem.text != null) {
                  match = remoteItems.firstWhere(
                    (r) => r['text'] == localItem.text,
                    orElse: () => null,
                  );
                }
                if (match != null) {
                  localItem.currentCount =
                      match['current_count'] ?? localItem.currentCount;
                  localItem.isDone =
                      (localItem.currentCount >= localItem.targetCount);
                }
              }
            }
            localHabit.recalculateProgress();
            localHabit.updatedAt = remoteUpdatedAt;
            localHabit.isSynced = true;
            await _isar.habitModels.put(localHabit);
          }
        } else {
          if (remoteJson['deleted_at'] == null) {
            final newHabit = HabitModel.fromMap(remoteJson);
            newHabit.isSynced = true;
            await _isar.habitModels.put(newHabit);
          }
        }
      }
    });
  }

  // ===========================================================================
  // ⚔️ دوال المهام
  // ===========================================================================

  Future<void> _pullAndMergeTasks(String userId) async {
    final remoteData = await _supabase
        .from('tasks')
        .select()
        .eq('created_by', userId);
    final List<TaskModel> remoteTasks = (remoteData as List)
        .map((e) => TaskModel.fromJson(e))
        .toList();

    await _isar.writeTxn(() async {
      for (var remoteTask in remoteTasks) {
        final localTask = await _isar.taskModels
            .filter()
            .uuidEqualTo(remoteTask.uuid)
            .findFirst();

        if (localTask == null) {
          if (remoteTask.deletedAt == null) {
            remoteTask.isSynced = true;
            await _isar.taskModels.put(remoteTask);
          }
        } else {
          remoteTask.id = localTask.id;
          final winnerTask = _resolveTaskConflict(localTask, remoteTask);
          winnerTask.isSynced = true;
          await _isar.taskModels.put(winnerTask);
        }
      }
    });
  }

  TaskModel _resolveTaskConflict(TaskModel local, TaskModel remote) {
    if (remote.deletedAt != null) return remote;
    if (local.deletedAt != null) return local;
    final localTime = local.updatedAt ?? DateTime(2000);
    final remoteTime = remote.updatedAt ?? DateTime(2000);
    return remoteTime.isAfter(localTime) ? remote : local;
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
