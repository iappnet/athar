import 'package:athar/core/constants/athkar_data.dart';
import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/habit_repository.dart';
import '../models/habit_model.dart';

@LazySingleton(as: HabitRepository)
class HabitRepositoryImpl implements HabitRepository {
  final Isar _isar;

  HabitRepositoryImpl(this._isar);

  @override
  Stream<List<HabitModel>> watchHabits() {
    return _isar.habitModels.filter().deletedAtIsNull().sortByCreatedAt().watch(
      fireImmediately: true,
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ العمليات الأساسية (CRUD)
  // ---------------------------------------------------------------------------

  @override
  Future<void> addHabit(HabitModel habit) async {
    await _isar.writeTxn(() async {
      await _isar.habitModels.put(habit);
    });
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    await _isar.writeTxn(() async {
      // ✅ إعادة حساب التقدم قبل الحفظ لضمان الاتساق
      habit.recalculateProgress();

      habit.updatedAt = DateTime.now();
      habit.isSynced = false;
      await _isar.habitModels.put(habit);
    });
  }

  @override
  Future<void> deleteHabit(int id) async {
    await _isar.writeTxn(() async {
      final habit = await _isar.habitModels.get(id);
      if (habit != null) {
        habit.deletedAt = DateTime.now();
        habit.isSynced = false;
        habit.updatedAt = DateTime.now();
        await _isar.habitModels.put(habit);
      }
    });
  }

  @override
  Future<void> toggleHabit(int id) async {
    await _isar.writeTxn(() async {
      final habit = await _isar.habitModels.get(id);
      if (habit != null) {
        if (habit.isCompleted) {
          habit.isCompleted = false;
          habit.currentProgress = 0;
        } else {
          habit.isCompleted = true;
          habit.currentProgress = habit.target;
          habit.lastCompletionDate = DateTime.now();
        }
        habit.lastUpdated = DateTime.now();
        habit.updatedAt = DateTime.now();
        habit.isSynced = false;
        await _isar.habitModels.put(habit);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // ✅ التنفيذ الجديد للدالة المفقودة
  // ---------------------------------------------------------------------------
  @override
  Future<void> fixMissingUserIds(String userId) async {
    // البحث عن العادات التي ليس لها مالك (user_id is null)
    final orphanHabits = await _isar.habitModels
        .filter()
        .userIdIsNull()
        .findAll();

    if (orphanHabits.isNotEmpty) {
      await _isar.writeTxn(() async {
        for (final habit in orphanHabits) {
          habit.userId = userId; // تعيين المالك
          habit.isSynced = false; // وضع علامة للرفع للسحابة
          habit.updatedAt = DateTime.now();
          await _isar.habitModels.put(habit);
        }
      });
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ إدارة عادات النظام (System Habits Management)
  // ---------------------------------------------------------------------------

  @override
  Future<void> resetAthkarToDefault(int habitId) async {
    await _isar.writeTxn(() async {
      final habit = await _isar.habitModels.get(habitId);
      if (habit != null) {
        // ✅ التوجيه الصحيح لكل نوع من الأذكار
        if (habit.uuid == AthkarData.morningAthkarId ||
            habit.title.contains("الصباح")) {
          habit.athkarItems = _getMorningAthkarItems();
        } else if (habit.uuid == AthkarData.eveningAthkarId ||
            habit.title.contains("المساء")) {
          habit.athkarItems = _getEveningAthkarItems();
        } else if (habit.uuid == AthkarData.prayerAthkarId ||
            habit.title.contains("الصلاة")) {
          habit.athkarItems = _getPrayerAthkarItems();
        } else if (habit.uuid == AthkarData.sleepAthkarId ||
            habit.title.contains("النوم")) {
          habit.athkarItems = _getSleepAthkarItems();
        } else {
          return; // ليست عادة نظامية معروفة
        }

        habit.recalculateProgress(); // إعادة حساب الأهداف
        habit.updatedAt = DateTime.now();
        habit.isSynced = false;

        await _isar.habitModels.put(habit);
      }
    });
  }

  @override
  Future<void> ensureSystemHabits() async {
    await _isar.writeTxn(() async {
      await _cleanupLegacyAthkar();

      // 1. أذكار الصباح
      await _createOrFixSystemHabit(
        targetUuid: AthkarData.morningAthkarId,
        title: "أذكار الصباح",
        period: HabitPeriod.morning,
        itemsGetter: _getMorningAthkarItems,
      );

      // 2. أذكار المساء
      await _createOrFixSystemHabit(
        targetUuid: AthkarData.eveningAthkarId,
        title: "أذكار المساء",
        period: HabitPeriod.afternoon,
        itemsGetter: _getEveningAthkarItems,
      );

      // 3. أذكار الصلاة (Post Prayer)
      await _createOrFixSystemHabit(
        targetUuid: AthkarData.prayerAthkarId,
        title: "أذكار بعد الصلاة",
        period: HabitPeriod.postPrayer,
        itemsGetter: _getPrayerAthkarItems,
      );

      // 4. أذكار النوم (Night)
      await _createOrFixSystemHabit(
        targetUuid: AthkarData.sleepAthkarId,
        title: "أذكار النوم",
        period: HabitPeriod.night,
        itemsGetter: _getSleepAthkarItems,
      );
    });
  }

  @override
  Future<bool> hasUserInteractedWithHabits() async {
    final count = await _isar.habitModels
        .filter()
        .group(
          (q) => q
              .currentProgressGreaterThan(0)
              .or()
              .isCompletedEqualTo(true)
              .or()
              .completedDaysIsNotEmpty(),
        )
        .count();

    return count > 0;
  }

  @override
  Future<void> clearAllHabits() async {
    await _isar.writeTxn(() async {
      await _isar.habitModels.clear();
    });
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ دوال جديدة للإشعارات
  // ═══════════════════════════════════════════════════════════

  @override
  Future<List<HabitModel>> getHabitsWithReminders() async {
    return await _isar.habitModels
        .filter()
        .reminderEnabledEqualTo(true)
        .and()
        .reminderTimeIsNotNull()
        .and()
        .deletedAtIsNull()
        .findAll();
  }

  @override
  Future<HabitModel?> getHabitByUuid(String uuid) async {
    return await _isar.habitModels
        .filter()
        .uuidEqualTo(uuid)
        .and()
        .deletedAtIsNull()
        .findFirst();
  }

  // ---------------------------------------------------------------------------
  // 🛠️ دوال مساعدة خاصة (Private Helpers)
  // ---------------------------------------------------------------------------

  Future<void> _cleanupLegacyAthkar() async {
    final idsToDelete = [
      '11111111-1111-1111-1111-111111111111',
      '22222222-2222-2222-2222-222222222222',
    ];

    await _isar.habitModels
        .filter()
        .anyOf(idsToDelete, (q, String uuid) => q.uuidEqualTo(uuid))
        .deleteAll();
  }

  Future<void> _createOrFixSystemHabit({
    required String targetUuid,
    required String title,
    required HabitPeriod period,
    required List<AthkarItem> Function() itemsGetter,
  }) async {
    // محاولة العثور بالـ UUID
    HabitModel? existing = await _isar.habitModels
        .filter()
        .uuidEqualTo(targetUuid)
        .findFirst();

    // محاولة العثور بالعنوان (للنسخ القديمة)
    if (existing == null) {
      existing = await _isar.habitModels
          .filter()
          .titleEqualTo(title)
          .findFirst();
      if (existing != null) existing.uuid = targetUuid; // تصحيح الـ UUID
    }

    if (existing == null) {
      // إنشاء جديد
      final items = itemsGetter();
      final habit = HabitModel(title: title, uuid: targetUuid)
        ..type = HabitType.athkar
        ..period = period
        ..frequency = HabitFrequency.daily
        ..createdAt = DateTime.now()
        ..athkarItems = items
        ..recalculateProgress();

      await _isar.habitModels.put(habit);
    } else {
      // إصلاح الموجود
      bool changed = false;

      if (existing.uuid != targetUuid) {
        existing.uuid = targetUuid;
        changed = true;
      }
      if (existing.deletedAt != null) {
        existing.deletedAt = null;
        changed = true;
      }

      // ✅ فحص دقيق: هل القائمة فارغة؟ أو هل المعرفات مفقودة (null)؟
      // هذا يضمن إصلاح الأذكار التي تم إنشاؤها سابقاً بدون أرقام
      if (existing.athkarItems.isEmpty ||
          existing.athkarItems.any((i) => i.itemId == null)) {
        existing.athkarItems = itemsGetter();
        existing.recalculateProgress();
        changed = true;
      }

      if (changed) {
        existing.updatedAt = DateTime.now();
        existing.isSynced = false;
        await _isar.habitModels.put(existing);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // ✅✅✅ مصنع الأذكار (Generators) مع أرقام تسلسلية ثابتة ✅✅✅
  // النطاقات:
  // الصباح: 1000+
  // المساء: 2000+
  // الصلاة: 3000+
  // النوم:  4000+
  // ---------------------------------------------------------------------------

  List<AthkarItem> _getMorningAthkarItems() {
    List<AthkarItem> items = [];
    for (int i = 0; i < AthkarData.allAthkar.length; i++) {
      final source = AthkarData.allAthkar[i];
      if (source.timings.contains(DhikrTiming.morning)) {
        items.add(
          AthkarItem()
            ..itemId = 1000 + i
            ..text = source.text
            ..targetCount = source.count
            ..currentCount = 0
            ..isDone = false,
        );
      }
    }
    return items;
  }

  List<AthkarItem> _getEveningAthkarItems() {
    List<AthkarItem> items = [];
    for (int i = 0; i < AthkarData.allAthkar.length; i++) {
      final source = AthkarData.allAthkar[i];
      if (source.timings.contains(DhikrTiming.evening)) {
        items.add(
          AthkarItem()
            ..itemId = 2000 + i
            ..text = source.text
            ..targetCount = source.count
            ..currentCount = 0
            ..isDone = false,
        );
      }
    }
    return items;
  }

  List<AthkarItem> _getPrayerAthkarItems() {
    List<AthkarItem> items = [];
    for (int i = 0; i < AthkarData.allAthkar.length; i++) {
      final source = AthkarData.allAthkar[i];
      if (source.timings.contains(DhikrTiming.prayer)) {
        items.add(
          AthkarItem()
            ..itemId = 3000 + i
            ..text = source.text
            ..targetCount = source.count
            ..currentCount = 0
            ..isDone = false,
        );
      }
    }
    return items;
  }

  List<AthkarItem> _getSleepAthkarItems() {
    List<AthkarItem> items = [];
    for (int i = 0; i < AthkarData.allAthkar.length; i++) {
      final source = AthkarData.allAthkar[i];
      if (source.timings.contains(DhikrTiming.sleep)) {
        items.add(
          AthkarItem()
            ..itemId = 4000 + i
            ..text = source.text
            ..targetCount = source.count
            ..currentCount = 0
            ..isDone = false,
        );
      }
    }
    return items;
  }

  @override
  Future<void> migrateDataForGuest(String oldUserId) async {
    await _isar.writeTxn(() async {
      final habits = await _isar.habitModels
          .filter()
          .userIdEqualTo(oldUserId)
          .findAll();

      for (var habit in habits) {
        habit.userId = 'guest'; // تحويل للمحلي
        habit.isSynced = false;
        habit.updatedAt = DateTime.now();
        await _isar.habitModels.put(habit);
      }
    });
  }
}
