import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'local_notification_service.dart';
import 'notification_id_manager.dart';
import '../../features/space/data/models/module_model.dart';
import 'package:isar/isar.dart';
import '../../features/space/domain/entities/project_entity.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

@singleton
class ProjectNotificationScheduler {
  final Isar _isar;
  final SettingsRepository _settingsRepository;
  final LocalNotificationService _notificationService;
  final NotificationIdManager _idManager;

  ProjectNotificationScheduler(
    this._isar,
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
        print(
          '📊 Initializing project notification scheduler (Module-based)...',
        );
      }

      final settings = await _settingsRepository.getSettings();

      if (!settings.isProjectRemindersEnabled) {
        if (kDebugMode) {
          print('⏸️ Project reminders disabled in settings');
        }
        return;
      }

      await scheduleAllProjects();
      await _scheduleAutoRenewal();

      if (kDebugMode) {
        print('✅ Project notification scheduler initialized successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error initializing project notification scheduler: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📅 PROJECT SCHEDULING
  // ═══════════════════════════════════════════════════════════

  Future<void> scheduleAllProjects() async {
    try {
      if (kDebugMode) {
        print('📅 Scheduling all active projects from modules...');
      }

      // جلب المشاريع النشطة من الموديولات (type: project)
      final projects = await _isar.moduleModels
          .filter()
          .typeEqualTo('project')
          .and()
          .statusEqualTo(ProjectStatus.inProgress.name)
          .and()
          .deletedAtIsNull()
          .and()
          .endDateIsNotNull()
          .findAll();

      if (projects.isEmpty) {
        if (kDebugMode) {
          print('ℹ️ No active project modules to schedule');
        }
        return;
      }

      int successCount = 0;
      int failedCount = 0;

      for (final project in projects) {
        try {
          await scheduleProject(project);
          successCount++;
        } catch (e) {
          failedCount++;
          if (kDebugMode) {
            print('⚠️ Failed to schedule project module "${project.name}": $e');
          }
        }
      }

      if (kDebugMode) {
        print('✅ Project scheduler sync complete:');
        print('   • Scheduled: $successCount projects');
        print('   • Failed: $failedCount projects');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error scheduling all projects: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  Future<void> scheduleProject(ModuleModel project) async {
    try {
      // 1. التحققات الأساسية
      if (!project.reminderEnabled) return;
      if (project.endDate == null) return;

      // 2. التحقق من الحالة باستخدام المساواة النصية (لتوافق Isar)
      if (project.status == ProjectStatus.completed.name ||
          project.status == ProjectStatus.cancelled.name) {
        if (kDebugMode) {
          print('⏸️ Skipping finished/cancelled project: ${project.name}');
        }
        return;
      }

      // 3. التحقق من الوقت
      if (project.endDate!.isBefore(DateTime.now())) {
        if (kDebugMode) {
          print('⏸️ Project end date in past: ${project.name}');
        }
        return;
      }

      // 4. جدولة التذكيرات (يوم قبل وساعة قبل)
      await _scheduleDayBeforeReminder(project);
      await _scheduleHourBeforeReminder(project);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling project module "${project.name}": $e');
      }
      rethrow;
    }
  }

  Future<void> _scheduleDayBeforeReminder(ModuleModel project) async {
    final reminderDate = project.endDate!.subtract(
      Duration(days: project.reminderDaysBefore),
    );

    if (reminderDate.isBefore(DateTime.now())) return;

    await _notificationService.schedule(
      id: _idManager.forProject(project.uuid),
      title: '📊 تذكير: مشروع ${project.name}',
      body: 'موعد التسليم بعد ${project.reminderDaysBefore} أيام',
      scheduledDate: reminderDate,
      category: NotificationCategory.project,
      payload: 'project:${project.uuid}:day',
    );
  }

  Future<void> _scheduleHourBeforeReminder(ModuleModel project) async {
    final reminderDate = project.endDate!.subtract(
      Duration(hours: project.reminderHoursBefore),
    );

    if (reminderDate.isBefore(DateTime.now())) return;

    await _notificationService.schedule(
      id: _idManager.forProjectMilestone(project.uuid, 1),
      title: '⏰ تذكير عاجل: ${project.name}',
      body: 'موعد التسليم بعد ${project.reminderHoursBefore} ساعة',
      scheduledDate: reminderDate,
      category: NotificationCategory.project,
      payload: 'project:${project.uuid}:hour',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🗑️ CANCELLATION & UPDATES
  // ═══════════════════════════════════════════════════════════

  Future<void> cancelProject(String projectUuid) async {
    try {
      await _notificationService.cancel(_idManager.forProject(projectUuid));

      // إلغاء المعالم (Milestones)
      for (int i = 0; i < 5; i++) {
        await _notificationService.cancel(
          _idManager.forProjectMilestone(projectUuid, i),
        );
      }

      if (kDebugMode) {
        print('🗑️ Cancelled project reminders for: $projectUuid');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling project reminders: $e');
      }
      rethrow;
    }
  }

  Future<void> cancelAllProjects() async {
    try {
      await _notificationService.cancelRange(
        NotificationIdRanges.projectBase,
        NotificationIdRanges.projectMax,
      );
      if (kDebugMode) {
        print('🗑️ Cancelled all project reminders');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProject(ModuleModel project) async {
    await cancelProject(project.uuid);
    await scheduleProject(project);
  }

  Future<void> rescheduleAll() async {
    await cancelAllProjects();
    await scheduleAllProjects();
  }

  Future<void> _scheduleAutoRenewal() async {
    try {
      final renewalTime = DateTime.now().add(const Duration(days: 7));

      await _notificationService.schedule(
        id: NotificationIdRanges.systemBase + 7,
        title: '🔄 تجديد إشعارات المشاريع',
        body: 'جاري تجديد جدولة إشعارات المشاريع...',
        scheduledDate: renewalTime,
        category: NotificationCategory.general,
        payload: 'auto_reschedule_projects',
      );

      if (kDebugMode) {
        print('✅ Project auto-renewal scheduled for: $renewalTime');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to schedule project auto-renewal: $e');
      }
    }
  }
}
