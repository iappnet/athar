import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/health/domain/repositories/health_repository.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'local_notification_service.dart';
import 'notification_id_manager.dart';

/// ✅ نظام إشعارات المواعيد الطبية المتقدم
///
/// الميزات:
/// - تذكيرات متعددة: يوم، ساعة، 15 دقيقة قبل الموعد
/// - إلغاء تلقائي عند completed/cancelled
/// - auto-renewal كل 7 أيام
/// - دعم كامل للفترات الهادئة
@singleton
class AppointmentNotificationScheduler {
  final HealthRepository _healthRepository;
  final SettingsRepository _settingsRepository;
  final LocalNotificationService _notificationService;
  final NotificationIdManager _idManager;

  AppointmentNotificationScheduler(
    this._healthRepository,
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
        print('🏥 Appointment notification scheduler initializing...');
      }

      final settings = await _settingsRepository.getSettings();

      if (!settings.isAppointmentRemindersEnabled) {
        if (kDebugMode) {
          print('⏸️ Appointment reminders disabled');
        }
        return;
      }

      await scheduleAllAppointments();
      await _scheduleAutoRenewal();

      if (kDebugMode) {
        print('✅ Appointment scheduler initialized');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error initializing appointment scheduler: $e');
        print('Stack: $stackTrace');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📅 SCHEDULING
  // ═══════════════════════════════════════════════════════════

  Future<void> scheduleAllAppointments() async {
    try {
      if (kDebugMode) {
        print('📅 Scheduling all appointments...');
      }

      final appointments = await _healthRepository.getUpcomingAppointments();

      if (appointments.isEmpty) {
        if (kDebugMode) {
          print('ℹ️ No upcoming appointments');
        }
        return;
      }

      int successCount = 0;
      int failedCount = 0;

      for (final appointment in appointments) {
        try {
          await scheduleAppointment(appointment);
          successCount++;
        } catch (e) {
          failedCount++;
          if (kDebugMode) {
            print('⚠️ Failed: ${appointment.title} - $e');
          }
        }
      }

      if (kDebugMode) {
        print('✅ Scheduled: $successCount, Failed: $failedCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling appointments: $e');
      }
    }
  }

  Future<void> scheduleAppointment(AppointmentModel appointment) async {
    try {
      if (appointment.status != 'upcoming') {
        return;
      }

      if (appointment.appointmentDate.isBefore(DateTime.now())) {
        return;
      }

      if (!appointment.reminderEnabled) {
        return;
      }

      final settings = await _settingsRepository.getSettings();

      if (settings.appointmentMultipleReminders) {
        await _scheduleMultipleReminders(appointment);
      } else {
        await _scheduleSingleReminder(appointment);
      }

      if (kDebugMode) {
        print('✅ Scheduled: ${appointment.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling ${appointment.title}: $e');
      }
      rethrow;
    }
  }

  Future<void> _scheduleSingleReminder(AppointmentModel appointment) async {
    final settings = await _settingsRepository.getSettings();
    final reminderTime = appointment.appointmentDate.subtract(
      Duration(minutes: settings.defaultAppointmentReminderMinutes),
    );

    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    await _notificationService.schedule(
      id: _idManager.forAppointment(appointment.uuid),
      title: '🏥 تذكير: ${appointment.title}',
      body: _getReminderBody(appointment, reminderTime),
      scheduledDate: reminderTime,
      category: NotificationCategory.appointment,
      payload: 'appointment:${appointment.uuid}',
    );
  }

  Future<void> _scheduleMultipleReminders(AppointmentModel appointment) async {
    final now = DateTime.now();
    final appointmentTime = appointment.appointmentDate;

    // تذكير قبل يوم
    final dayBefore = appointmentTime.subtract(
      Duration(days: appointment.reminderDaysBefore),
    );
    if (dayBefore.isAfter(now)) {
      await _notificationService.schedule(
        id: _idManager.forAppointmentDayBefore(appointment.uuid),
        title: '🏥 تذكير: ${appointment.title}',
        body: 'غداً: موعدك مع ${appointment.doctorName ?? "الطبيب"}',
        scheduledDate: dayBefore,
        category: NotificationCategory.appointment,
        payload: 'appointment:${appointment.uuid}',
      );
    }

    // تذكير قبل ساعة
    final hourBefore = appointmentTime.subtract(
      Duration(hours: appointment.reminderHoursBefore),
    );
    if (hourBefore.isAfter(now)) {
      await _notificationService.schedule(
        id: _idManager.forAppointmentHourBefore(appointment.uuid),
        title: '🏥 تذكير: ${appointment.title}',
        body: 'بعد ساعة: موعدك مع ${appointment.doctorName ?? "الطبيب"}',
        scheduledDate: hourBefore,
        category: NotificationCategory.appointment,
        payload: 'appointment:${appointment.uuid}',
      );
    }

    // تذكير قبل 15 دقيقة
    final minutesBefore = appointmentTime.subtract(
      Duration(minutes: appointment.reminderMinutesBefore),
    );
    if (minutesBefore.isAfter(now)) {
      await _notificationService.schedule(
        id: _idManager.forAppointmentMinutesBefore(appointment.uuid),
        title: '🏥 تذكير: ${appointment.title}',
        body: 'بعد ${appointment.reminderMinutesBefore} دقيقة: موعدك',
        scheduledDate: minutesBefore,
        category: NotificationCategory.appointment,
        payload: 'appointment:${appointment.uuid}',
      );
    }
  }

  String _getReminderBody(AppointmentModel appointment, DateTime reminderTime) {
    final diff = appointment.appointmentDate.difference(reminderTime);
    String timeText;

    if (diff.inMinutes < 60) {
      timeText = 'بعد ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      timeText = 'بعد ${diff.inHours} ساعة';
    } else {
      timeText = 'غداً';
    }

    String details = '';
    if (appointment.doctorName != null) {
      details = 'مع ${appointment.doctorName}';
    }
    if (appointment.locationName != null) {
      details += ' في ${appointment.locationName}';
    }

    return '$timeText: موعدك $details';
  }

  // ═══════════════════════════════════════════════════════════
  // 🗑️ CANCELLATION
  // ═══════════════════════════════════════════════════════════

  Future<void> cancelAppointment(String appointmentUuid) async {
    try {
      await _notificationService.cancel(
        _idManager.forAppointment(appointmentUuid),
      );
      await _notificationService.cancel(
        _idManager.forAppointmentDayBefore(appointmentUuid),
      );
      await _notificationService.cancel(
        _idManager.forAppointmentHourBefore(appointmentUuid),
      );
      await _notificationService.cancel(
        _idManager.forAppointmentMinutesBefore(appointmentUuid),
      );

      if (kDebugMode) {
        print('🗑️ Cancelled: $appointmentUuid');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling: $e');
      }
    }
  }

  Future<void> cancelAllAppointments() async {
    try {
      await _notificationService.cancelRange(
        NotificationIdRanges.appointmentBase,
        NotificationIdRanges.appointmentMax,
      );

      if (kDebugMode) {
        print('🗑️ Cancelled all appointments');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔧 UTILITIES
  // ═══════════════════════════════════════════════════════════

  Future<void> updateAppointment(AppointmentModel appointment) async {
    await cancelAppointment(appointment.uuid);
    await scheduleAppointment(appointment);
  }

  Future<void> rescheduleAll() async {
    await cancelAllAppointments();
    await scheduleAllAppointments();
  }

  Future<void> _scheduleAutoRenewal() async {
    try {
      final renewalTime = DateTime.now().add(const Duration(days: 7));

      await _notificationService.schedule(
        id: NotificationIdRanges.autoRenew + 3,
        title: '🔄 تجديد إشعارات المواعيد',
        body: 'جاري التجديد...',
        scheduledDate: renewalTime,
        category: NotificationCategory.general,
        payload: 'auto_reschedule_appointments',
      );

      if (kDebugMode) {
        print('✅ Auto-renewal scheduled: $renewalTime');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Auto-renewal failed: $e');
      }
    }
  }
}
