import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/task/domain/repositories/task_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'local_notification_service.dart';
import 'notification_id_manager.dart';
import '../utils/time_zone_query_helper.dart';

/// ✅ نظام إشعارات المهام الذكي
///
/// المزايا:
/// - جدولة تلقائية للتذكيرات
/// - احترام الفترات الهادئة
/// - إعادة جدولة ذكية
/// - تكامل مع TimeZoneQueryHelper
///
@singleton
class TaskNotificationScheduler {
  final TaskRepository _taskRepository;
  final SettingsRepository _settingsRepository;
  final LocalNotificationService _notificationService;
  final NotificationIdManager _idManager;

  TaskNotificationScheduler(
    this._taskRepository,
    this._settingsRepository,
    this._notificationService,
    this._idManager,
  );

  // ═══════════════════════════════════════════════════════════
  // 🎬 INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  /// ✅ التهيئة الكاملة - جدولة جميع المهام ذات التذكيرات
  Future<void> initializeScheduling() async {
    try {
      if (kDebugMode) {
        print('📋 Task notification scheduler initializing...');
      }

      // 1. التحقق من الإعدادات
      final settings = await _settingsRepository.getSettings();
      if (!settings.isTaskRemindersEnabled) {
        if (kDebugMode) {
          print('⏸️ Task reminders disabled in settings');
        }
        return;
      }

      // 2. جدولة جميع المهام
      await scheduleAllTasks();

      // ✅ جدولة auto-renewal بعد 7 أيام
      await _scheduleAutoRenewal();

      if (kDebugMode) {
        print('✅ Task notification scheduler initialized successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error initializing task notification scheduler: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📅 SCHEDULING METHODS
  // ═══════════════════════════════════════════════════════════

  /// ✅ جدولة جميع المهام النشطة ذات التذكيرات
  /// ✅ جدولة جميع المهام النشطة ذات التذكيرات
  Future<void> scheduleAllTasks() async {
    try {
      if (kDebugMode) {
        print('📅 Scheduling all tasks with reminders...');
      }

      // 1. جلب المهام التي لها تذكيرات فقط ✅
      final tasksWithReminders = await _taskRepository.getTasksWithReminders();

      if (tasksWithReminders.isEmpty) {
        if (kDebugMode) {
          print('ℹ️ No tasks with reminders to schedule');
        }
        return;
      }

      // 2. جدولة كل مهمة
      int successCount = 0;
      int failedCount = 0;

      for (final task in tasksWithReminders) {
        try {
          await scheduleTask(task);
          successCount++;
        } catch (e) {
          failedCount++;
          if (kDebugMode) {
            print('⚠️ Failed to schedule task "${task.title}": $e');
          }
        }
      }

      if (kDebugMode) {
        print('✅ Task scheduler initialized:');
        print('   • Scheduled: $successCount tasks');
        print('   • Failed: $failedCount tasks');
        print('   • Total with reminders: ${tasksWithReminders.length}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error scheduling all tasks: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  /// ✅ جدولة تجديد تلقائي بعد 7 أيام
  Future<void> _scheduleAutoRenewal() async {
    try {
      final renewalTime = DateTime.now().add(const Duration(days: 7));

      await _notificationService.schedule(
        id: NotificationIdRanges.autoRenew + 2, // 900002
        title: '🔄 تجديد إشعارات المهام',
        body: 'جاري تجديد جدولة إشعارات المهام...',
        scheduledDate: renewalTime,
        category: NotificationCategory.general,
        payload: 'auto_reschedule_tasks',
      );

      if (kDebugMode) {
        print('✅ Task auto-renewal scheduled for: $renewalTime');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to schedule task auto-renewal: $e');
      }
    }
  }

  /// ✅ جدولة تذكير لمهمة واحدة
  Future<void> scheduleTask(TaskModel task) async {
    try {
      // --- التحققات الأولية ---

      // 1. هل المهمة مكتملة؟
      if (task.isCompleted) {
        if (kDebugMode) {
          print('⏸️ Skipping completed task: ${task.title}');
        }
        return;
      }

      // 2. هل يوجد وقت للتذكير؟
      DateTime? reminderTime = task.reminderTime;

      if (reminderTime == null) {
        // محاولة حساب التذكير من وقت المهمة + الإعدادات
        if (task.time != null) {
          final settings = await _settingsRepository.getSettings();
          reminderTime = task.time!.subtract(
            Duration(minutes: settings.taskReminderMinutesBefore),
          );
        } else {
          if (kDebugMode) {
            print('⚠️ No reminder time for task: ${task.title}');
          }
          return;
        }
      }

      // 3. هل الوقت في الماضي؟
      if (reminderTime.isBefore(DateTime.now())) {
        if (kDebugMode) {
          print('⏸️ Reminder time in past for task: ${task.title}');
        }
        return;
      }

      // --- تحديد وقت التذكير النهائي ---

      final settings = await _settingsRepository.getSettings();
      DateTime scheduledTime = reminderTime;

      // احترام الفترات الهادئة
      if (settings.respectQuietPeriodsForTasks) {
        scheduledTime = _adjustForQuietPeriods(reminderTime, settings);
      }

      // --- جدولة الإشعار ---

      await _notificationService.schedule(
        id: _idManager.forTask(task.uuid),
        title: '⏰ تذكير: ${task.title}',
        body: _getTaskReminderBody(task, scheduledTime),
        scheduledDate: scheduledTime,
        category: NotificationCategory.task,
        payload: 'task:${task.uuid}',
      );

      if (kDebugMode) {
        print('✅ Scheduled reminder for task: ${task.title}');
        print(
          '   • Original time: ${reminderTime.toString().substring(11, 16)}',
        );
        print(
          '   • Scheduled time: ${scheduledTime.toString().substring(11, 16)}',
        );
        print('   • ID: ${_idManager.forTask(task.uuid)}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error scheduling task "${task.title}": $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🗑️ CANCELLATION METHODS
  // ═══════════════════════════════════════════════════════════

  /// ✅ إلغاء تذكير مهمة واحدة
  Future<void> cancelTask(String taskUuid) async {
    try {
      await _notificationService.cancel(_idManager.forTask(taskUuid));

      if (kDebugMode) {
        print('🗑️ Cancelled reminder for task: $taskUuid');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling task reminder: $e');
      }
      rethrow;
    }
  }

  /// ✅ إلغاء جميع تذكيرات المهام
  Future<void> cancelAllTasks() async {
    try {
      await _notificationService.cancelRange(
        NotificationIdRanges.taskBase,
        NotificationIdRanges.taskMax,
      );

      if (kDebugMode) {
        print('🗑️ Cancelled all task reminders');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling all task reminders: $e');
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔧 UTILITY METHODS
  // ═══════════════════════════════════════════════════════════

  /// ✅ تحديث جدولة مهمة (إلغاء + إعادة جدولة)
  Future<void> updateTask(TaskModel task) async {
    await cancelTask(task.uuid);
    await scheduleTask(task);
  }

  /// ✅ إعادة جدولة جميع المهام (عند تغيير الإعدادات)
  Future<void> rescheduleAll() async {
    await cancelAllTasks();
    await scheduleAllTasks();
  }

  // ═══════════════════════════════════════════════════════════
  // 🧠 SMART SCHEDULING LOGIC
  // ═══════════════════════════════════════════════════════════

  /// تعديل وقت التذكير لاحترام الفترات الهادئة
  DateTime _adjustForQuietPeriods(DateTime originalTime, dynamic settings) {
    // التحقق: هل الوقت الأصلي في فترة هادئة؟
    final isQuiet = TimeZoneQueryHelper.isInQuietPeriod(settings);

    if (!isQuiet) {
      // ليس في فترة هادئة، استخدم الوقت الأصلي
      return originalTime;
    }

    // إذا كان في فترة هادئة، ابحث عن نهاية الفترة
    final quietPeriods = settings.quietPeriodsSafe;

    for (final period in quietPeriods) {
      if (period.contains(originalTime)) {
        // حساب نهاية الفترة الهادئة
        DateTime endTime = DateTime(
          originalTime.year,
          originalTime.month,
          originalTime.day,
          period.endHour,
          period.endMinute,
        );

        // إذا كانت الفترة تعبر منتصف الليل
        if (period.endHour < period.startHour) {
          endTime = endTime.add(const Duration(days: 1));
        }

        if (kDebugMode) {
          print('🌙 Adjusted for quiet period:');
          print('   • Original: ${originalTime.toString().substring(11, 16)}');
          print('   • Adjusted: ${endTime.toString().substring(11, 16)}');
        }

        return endTime;
      }
    }

    // في حالة عدم العثور، استخدم الوقت الأصلي
    return originalTime;
  }

  /// محتوى الإشعار حسب المهمة
  String _getTaskReminderBody(TaskModel task, DateTime scheduledTime) {
    final taskTime = task.time;

    if (taskTime != null) {
      final diff = taskTime.difference(scheduledTime);

      if (diff.inMinutes < 60) {
        return 'تبدأ بعد ${diff.inMinutes} دقيقة';
      } else if (diff.inHours < 24) {
        return 'تبدأ بعد ${diff.inHours} ساعة';
      } else {
        return 'تبدأ بعد ${diff.inDays} يوم';
      }
    }

    return 'لديك مهمة قادمة';
  }
}
