// lib/core/services/habit_notification_scheduler.dart

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'local_notification_service.dart';
import 'notification_id_manager.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

/// ✅ جدولة إشعارات العادات والأذكار
@singleton
class HabitNotificationScheduler {
  final HabitRepository _habitRepository;
  final SettingsRepository _settingsRepository;
  final LocalNotificationService _notificationService;
  final NotificationIdManager _idManager;

  HabitNotificationScheduler(
    this._habitRepository,
    this._settingsRepository,
    this._notificationService,
    this._idManager,
  );

  // ═══════════════════════════════════════════════════════════
  // 🎬 INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  Future<void> initializeScheduling() async {
    try {
      if (kDebugMode) {
        print('💪 Initializing habit notification scheduler...');
      }

      final settings = await _settingsRepository.getSettings();

      // جدولة العادات
      if (settings.isHabitRemindersEnabled) {
        await scheduleAllHabits();
      }

      // جدولة الأذكار
      if (settings.isAthkarRemindersEnabled) {
        await scheduleAllAthkar();
      }

      await _scheduleAutoRenewal();

      if (kDebugMode) {
        print('✅ Habit notification scheduler initialized successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error initializing habit notification scheduler: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📅 HABIT SCHEDULING
  // ═══════════════════════════════════════════════════════════

  Future<void> scheduleAllHabits() async {
    try {
      if (kDebugMode) {
        print('📅 Scheduling all habits with reminders...');
      }

      final habits = await _habitRepository.getHabitsWithReminders();

      if (habits.isEmpty) {
        if (kDebugMode) {
          print('ℹ️ No habits with reminders to schedule');
        }
        return;
      }

      int successCount = 0;
      int failedCount = 0;

      for (final habit in habits) {
        try {
          // تخطي الأذكار - لهم جدولة منفصلة
          if (habit.isAthkar) continue;

          await scheduleHabit(habit);
          successCount++;
        } catch (e) {
          failedCount++;
          if (kDebugMode) {
            print('⚠️ Failed to schedule habit "${habit.title}": $e');
          }
        }
      }

      if (kDebugMode) {
        print('✅ Habit scheduler initialized:');
        print('   • Scheduled: $successCount habits');
        print('   • Failed: $failedCount habits');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error scheduling all habits: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  Future<void> scheduleHabit(HabitModel habit) async {
    try {
      // التحققات الأولية
      if (!habit.reminderEnabled) {
        if (kDebugMode) {
          print('⏸️ Reminder disabled for habit: ${habit.title}');
        }
        return;
      }

      if (habit.reminderTime == null) {
        if (kDebugMode) {
          print('⚠️ No reminder time for habit: ${habit.title}');
        }
        return;
      }

      // جدولة حسب التكرار
      switch (habit.frequency) {
        case HabitFrequency.daily:
          await _scheduleDailyHabit(habit);
          break;
        case HabitFrequency.weekly:
          await _scheduleWeeklyHabit(habit);
          break;
        case HabitFrequency.monthly:
          await _scheduleMonthlyHabit(habit);
          break;
      }

      if (kDebugMode) {
        print('✅ Scheduled habit: ${habit.title}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error scheduling habit "${habit.title}": $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// جدولة عادة يومية
  Future<void> _scheduleDailyHabit(HabitModel habit) async {
    final reminderTime = habit.reminderTime!;

    await _notificationService.scheduleDailyNotification(
      id: _idManager.forHabit(habit.uuid!),
      title: '💪 عادة يومية: ${habit.title}',
      body: 'حان وقت إنجاز عادتك اليومية',
      hour: reminderTime.hour,
      minute: reminderTime.minute,
      category: NotificationCategory.habit,
      payload: 'habit:${habit.uuid}',
    );
  }

  /// جدولة عادة أسبوعية
  Future<void> _scheduleWeeklyHabit(HabitModel habit) async {
    final reminderTime = habit.reminderTime!;
    final reminderDays =
        habit.reminderDays ?? [1, 2, 3, 4, 5]; // الافتراضي: أيام الأسبوع

    // جدولة لـ 4 أسابيع قادمة
    for (int week = 0; week < 4; week++) {
      for (final dayNumber in reminderDays) {
        final scheduledDate = _getNextOccurrence(
          dayOfWeek: dayNumber,
          hour: reminderTime.hour,
          minute: reminderTime.minute,
          weeksOffset: week,
        );

        if (scheduledDate.isBefore(DateTime.now())) continue;

        await _notificationService.schedule(
          id: _idManager.forHabitReminder(
            habit.uuid!,
            dayOffset: week * 7 + dayNumber,
          ),
          title: '💪 عادة أسبوعية: ${habit.title}',
          body: 'حان وقت إنجاز عادتك',
          scheduledDate: scheduledDate,
          category: NotificationCategory.habit,
          payload: 'habit:${habit.uuid}:week:$week',
        );
      }
    }
  }

  /// جدولة عادة شهرية
  Future<void> _scheduleMonthlyHabit(HabitModel habit) async {
    final reminderTime = habit.reminderTime!;

    // جدولة لـ 3 أشهر قادمة
    for (int month = 0; month < 3; month++) {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month + month,
        reminderTime.day,
        reminderTime.hour,
        reminderTime.minute,
      );

      // إذا كان اليوم غير موجود في الشهر (مثل 31 في فبراير)
      // استخدم آخر يوم في الشهر
      if (scheduledDate.month != (now.month + month) % 12) {
        scheduledDate = DateTime(
          now.year,
          now.month + month + 1,
          0, // آخر يوم في الشهر السابق
          reminderTime.hour,
          reminderTime.minute,
        );
      }

      if (scheduledDate.isBefore(DateTime.now())) continue;

      await _notificationService.schedule(
        id: _idManager.forHabitReminder(habit.uuid!, dayOffset: month),
        title: '💪 عادة شهرية: ${habit.title}',
        body: 'حان وقت إنجاز عادتك الشهرية',
        scheduledDate: scheduledDate,
        category: NotificationCategory.habit,
        payload: 'habit:${habit.uuid}:month:$month',
      );
    }
  }

  /// حساب الموعد القادم ليوم معين من الأسبوع
  DateTime _getNextOccurrence({
    required int dayOfWeek, // 1=الأحد, 7=السبت
    required int hour,
    required int minute,
    int weeksOffset = 0,
  }) {
    final now = DateTime.now();
    final currentWeekDay = now.weekday == 7 ? 7 : now.weekday; // 1-7

    int daysUntil = dayOfWeek - currentWeekDay;
    if (daysUntil < 0) daysUntil += 7;

    daysUntil += weeksOffset * 7;

    return DateTime(now.year, now.month, now.day + daysUntil, hour, minute);
  }

  // ═══════════════════════════════════════════════════════════
  // 📿 ATHKAR SCHEDULING
  // ═══════════════════════════════════════════════════════════

  Future<void> scheduleAllAthkar() async {
    try {
      if (kDebugMode) {
        print('📿 Scheduling athkar reminders...');
      }

      final settings = await _settingsRepository.getSettings();

      // أذكار الصباح
      await _scheduleAthkar(
        id: _idManager.morningAthkar,
        title: '☀️ أذكار الصباح',
        body: 'حان وقت أذكار الصباح',
        timeString: settings.morningAthkarTime,
        payload: 'athkar:morning',
      );

      // أذكار المساء
      await _scheduleAthkar(
        id: _idManager.eveningAthkar,
        title: '🌅 أذكار المساء',
        body: 'حان وقت أذكار المساء',
        timeString: settings.eveningAthkarTime,
        payload: 'athkar:evening',
      );

      // أذكار النوم
      await _scheduleAthkar(
        id: _idManager.sleepAthkar,
        title: '🌙 أذكار النوم',
        body: 'حان وقت أذكار النوم',
        timeString: settings.sleepAthkarTime,
        payload: 'athkar:sleep',
      );

      if (kDebugMode) {
        print('✅ Athkar reminders scheduled successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling athkar: $e');
      }
    }
  }

  Future<void> _scheduleAthkar({
    required int id,
    required String title,
    required String body,
    required String timeString,
    required String payload,
  }) async {
    final timeParts = timeString.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 6;
    final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;

    await _notificationService.scheduleDailyNotification(
      id: id,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      category: NotificationCategory.athkar,
      payload: payload,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🗑️ CANCELLATION
  // ═══════════════════════════════════════════════════════════

  Future<void> cancelHabit(String habitUuid) async {
    try {
      // إلغاء الإشعار الرئيسي
      await _notificationService.cancel(_idManager.forHabit(habitUuid));

      // إلغاء الإشعارات الإضافية (للعادات الأسبوعية/الشهرية)
      for (int i = 0; i < 30; i++) {
        await _notificationService.cancel(
          _idManager.forHabitReminder(habitUuid, dayOffset: i),
        );
      }

      if (kDebugMode) {
        print('🗑️ Cancelled habit reminder: $habitUuid');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling habit reminder: $e');
      }
      rethrow;
    }
  }

  Future<void> cancelAllHabits() async {
    try {
      await _notificationService.cancelRange(
        NotificationIdRanges.habitBase,
        NotificationIdRanges.habitMax,
      );

      if (kDebugMode) {
        print('🗑️ Cancelled all habit reminders');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling all habit reminders: $e');
      }
      rethrow;
    }
  }

  Future<void> cancelAllAthkar() async {
    try {
      await _notificationService.cancelRange(
        NotificationIdRanges.athkarBase,
        NotificationIdRanges.athkarMax,
      );

      if (kDebugMode) {
        print('🗑️ Cancelled all athkar reminders');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling all athkar reminders: $e');
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔧 UTILITIES
  // ═══════════════════════════════════════════════════════════

  Future<void> updateHabit(HabitModel habit) async {
    await cancelHabit(habit.uuid!);
    await scheduleHabit(habit);
  }

  Future<void> rescheduleAll() async {
    await cancelAllHabits();
    await cancelAllAthkar();
    await initializeScheduling();
  }

  Future<void> _scheduleAutoRenewal() async {
    try {
      final renewalTime = DateTime.now().add(const Duration(days: 7));

      await _notificationService.schedule(
        id: _idManager.autoRenewHabit,
        title: '🔄 تجديد إشعارات العادات',
        body: 'جاري تجديد جدولة إشعارات العادات والأذكار...',
        scheduledDate: renewalTime,
        category: NotificationCategory.general,
        payload: 'auto_reschedule_habits',
      );

      if (kDebugMode) {
        print('✅ Habit auto-renewal scheduled for: $renewalTime');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to schedule habit auto-renewal: $e');
      }
    }
  }
}
