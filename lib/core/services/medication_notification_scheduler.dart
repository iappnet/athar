import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'local_notification_service.dart';
import 'notification_id_manager.dart';
import '../../features/health/domain/repositories/health_repository.dart';
import '../../features/health/data/models/medicine_model.dart';
// import '../../features/health/data/models/medicine_log_model.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

/// ✅ جدولة إشعارات الأدوية (متوافق مع MedicineModel)
@singleton
class MedicationNotificationScheduler {
  final HealthRepository _healthRepository;
  final SettingsRepository _settingsRepository;
  final LocalNotificationService _notificationService;
  final NotificationIdManager _idManager;

  MedicationNotificationScheduler(
    this._healthRepository,
    this._settingsRepository,
    this._notificationService,
    this._idManager,
  );

  // ═══════════════════════════════════════════════════════════
  // 🎬 INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  /// ✅ التهيئة الكاملة - جدولة جميع الأدوية النشطة
  Future<void> initializeScheduling() async {
    try {
      if (kDebugMode) {
        print('💊 Initializing medication scheduler...');
      }

      // 1. التحقق من الإعدادات
      final settings = await _settingsRepository.getSettings();
      if (!(settings.isMedicationNotificationsEnabled)) {
        if (kDebugMode) {
          print('⏸️ Medication notifications disabled in settings');
        }
        return;
      }

      // 2. جلب جميع الأدوية النشطة
      final medicines = await _healthRepository.getAllActiveMedicines();

      if (medicines.isEmpty) {
        if (kDebugMode) {
          print('ℹ️ No active medicines to schedule');
        }
        return;
      }

      // 3. جدولة كل دواء
      int successCount = 0;
      for (final medicine in medicines) {
        try {
          await scheduleMedicine(medicine);
          successCount++;
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Failed to schedule ${medicine.name}: $e');
          }
        }
      }
      // ✅ جدولة auto-renewal بعد 7 أيام
      await _scheduleAutoRenewal();

      if (kDebugMode) {
        print(
          '✅ Medication scheduler initialized: $successCount/${medicines.length} medicines scheduled',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error initializing medication scheduler: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📅 SCHEDULING
  // ═══════════════════════════════════════════════════════════

  /// ✅ جدولة تجديد تلقائي بعد 7 أيام
  Future<void> _scheduleAutoRenewal() async {
    try {
      final renewalTime = DateTime.now().add(const Duration(days: 7));

      await _notificationService.schedule(
        id: NotificationIdRanges.autoRenew + 1, // 900001
        title: '🔄 تجديد إشعارات الأدوية',
        body: 'جاري تجديد جدولة إشعارات الأدوية...',
        scheduledDate: renewalTime,
        category: NotificationCategory.general,
        payload: 'auto_reschedule_medications',
      );

      if (kDebugMode) {
        print('✅ Medication auto-renewal scheduled for: $renewalTime');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to schedule medication auto-renewal: $e');
      }
    }
  }

  /// ✅ جدولة إشعار دواء واحد
  Future<void> scheduleMedicine(MedicineModel medicine) async {
    if (!medicine.isActive) {
      if (kDebugMode) {
        print('⏸️ Skipping archived medicine: ${medicine.name}');
      }
      return;
    }

    try {
      // إلغاء الإشعارات السابقة
      await cancelMedicine(medicine.uuid);

      // جدولة حسب النوع
      if (medicine.schedulingType == 'fixed') {
        await _scheduleFixedTime(medicine);
      } else if (medicine.schedulingType == 'interval') {
        await _scheduleInterval(medicine);
      } else {
        if (kDebugMode) {
          print('⚠️ Unknown scheduling type: ${medicine.schedulingType}');
        }
      }

      if (kDebugMode) {
        print('✅ Scheduled medicine: ${medicine.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling medicine ${medicine.name}: $e');
      }
    }
  }

  /// ✅ جدولة دواء بأوقات ثابتة (Fixed Time Slots)
  Future<void> _scheduleFixedTime(MedicineModel medicine) async {
    final timeSlots = medicine.fixedTimeSlots;

    if (timeSlots == null || timeSlots.isEmpty) {
      if (kDebugMode) {
        print('⚠️ No time slots for ${medicine.name}');
      }
      return;
    }

    // جدولة لـ 7 أيام قادمة
    for (int dayOffset = 0; dayOffset <= 6; dayOffset++) {
      for (final timeSlot in timeSlots) {
        await _scheduleFixedTimeSlot(medicine, timeSlot, dayOffset);
      }
    }
  }

  /// ✅ جدولة وقت ثابت واحد
  Future<void> _scheduleFixedTimeSlot(
    MedicineModel medicine,
    String timeSlot,
    int dayOffset,
  ) async {
    try {
      // تحليل الوقت (مثل "08:00")
      final parts = timeSlot.split(':');
      if (parts.length != 2) {
        if (kDebugMode) {
          print('⚠️ Invalid time format: $timeSlot');
        }
        return;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        if (kDebugMode) {
          print('⚠️ Invalid time values: $timeSlot');
        }
        return;
      }

      // حساب التاريخ والوقت
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day + dayOffset,
        hour,
        minute,
      );

      // تجاهل الأوقات الماضية
      if (scheduledDate.isBefore(now)) {
        return;
      }

      // جدولة الإشعار الرئيسي
      await _notificationService.schedule(
        id: _idManager.forMedication(medicine.uuid, dayOffset: dayOffset),
        title: '💊 وقت الدواء',
        body: medicine.name,
        scheduledDate: scheduledDate,
        category: NotificationCategory.medication,
        payload: 'medication:${medicine.uuid}:$dayOffset',
      );

      // جدولة تذكير (قبل 5 دقائق)
      final reminderTime = scheduledDate.subtract(const Duration(minutes: 5));
      if (reminderTime.isAfter(now)) {
        await _notificationService.schedule(
          id: _idManager.forMedicationReminder(
            medicine.uuid,
            dayOffset: dayOffset,
          ),
          title: '⏰ تذكير: دواء قريباً',
          body: '${medicine.name} - بعد 5 دقائق',
          scheduledDate: reminderTime,
          category: NotificationCategory.medication,
          payload: 'medication_reminder:${medicine.uuid}:$dayOffset',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling time slot $timeSlot: $e');
      }
    }
  }

  /// ✅ جدولة دواء بفترات زمنية (Interval-based)
  Future<void> _scheduleInterval(MedicineModel medicine) async {
    final intervalHours = medicine.intervalHours;

    if (intervalHours == null || intervalHours <= 0) {
      if (kDebugMode) {
        print('⚠️ Invalid interval for ${medicine.name}');
      }
      return;
    }

    try {
      // جلب آخر جرعة
      final lastLog = await _healthRepository.getLastLogForMedicine(
        medicine.uuid,
      );

      DateTime nextDoseTime;

      if (lastLog != null) {
        // حساب الموعد القادم بناءً على آخر جرعة
        nextDoseTime = lastLog.takenAt.add(Duration(hours: intervalHours));
      } else {
        // أول جرعة - نبدأ من الآن
        nextDoseTime = DateTime.now();
      }

      // جدولة الجرعات القادمة (7 أيام)
      final now = DateTime.now();
      int dayOffset = 0;

      while (dayOffset < 7) {
        if (nextDoseTime.isAfter(now)) {
          // جدولة الإشعار الرئيسي
          await _notificationService.schedule(
            id: _idManager.forMedication(medicine.uuid, dayOffset: dayOffset),
            title: '💊 وقت الدواء',
            body: medicine.name,
            scheduledDate: nextDoseTime,
            category: NotificationCategory.medication,
            payload: 'medication:${medicine.uuid}:interval:$dayOffset',
          );

          // جدولة تذكير (قبل 5 دقائق)
          final reminderTime = nextDoseTime.subtract(
            const Duration(minutes: 5),
          );
          if (reminderTime.isAfter(now)) {
            await _notificationService.schedule(
              id: _idManager.forMedicationReminder(
                medicine.uuid,
                dayOffset: dayOffset,
              ),
              title: '⏰ تذكير: دواء قريباً',
              body: '${medicine.name} - بعد 5 دقائق',
              scheduledDate: reminderTime,
              category: NotificationCategory.medication,
              payload:
                  'medication_reminder:${medicine.uuid}:interval:$dayOffset',
            );
          }
        }

        // الجرعة القادمة
        nextDoseTime = nextDoseTime.add(Duration(hours: intervalHours));
        dayOffset++;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling interval medicine: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🗑️ CANCELLATION
  // ═══════════════════════════════════════════════════════════

  /// ✅ إلغاء إشعارات دواء
  Future<void> cancelMedicine(String medicineUuid) async {
    try {
      // إلغاء الإشعارات لـ 7 أيام قادمة
      for (int dayOffset = 0; dayOffset <= 6; dayOffset++) {
        await _notificationService.cancel(
          _idManager.forMedication(medicineUuid, dayOffset: dayOffset),
        );
        await _notificationService.cancel(
          _idManager.forMedicationReminder(medicineUuid, dayOffset: dayOffset),
        );
      }

      if (kDebugMode) {
        print('🗑️ Cancelled notifications for medicine: $medicineUuid');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling medicine: $e');
      }
    }
  }

  /// ✅ إلغاء جميع إشعارات الأدوية
  Future<void> cancelAllMedications() async {
    try {
      await _notificationService.cancelRange(
        NotificationIdRanges.medicationBase,
        NotificationIdRanges.medicationMax,
      );

      if (kDebugMode) {
        print('🗑️ Cancelled all medication notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling all medications: $e');
      }
    }
  }

  /// ✅ إلغاء جميع إشعارات دواء معين
  Future<void> cancelMedication(String medicineUuid) async {
    try {
      // إلغاء الإشعار الأساسي
      await _notificationService.cancel(_idManager.forMedication(medicineUuid));

      // إلغاء جميع الإشعارات الإضافية لهذا الدواء
      // (في حالة كان interval-based مع عدة أوقات)
      for (int i = 0; i < 10; i++) {
        await _notificationService.cancel(
          _idManager.forMedication(medicineUuid) + i,
        );
      }

      if (kDebugMode) {
        print('🗑️ Cancelled all notifications for medicine: $medicineUuid');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling medication notifications: $e');
      }
    }
  }

  /// ✅ إعادة جدولة دواء (إلغاء + جدولة جديدة) - مُصلح
  Future<void> rescheduleMedication(MedicineModel medicine) async {
    await cancelMedication(medicine.uuid);
    await scheduleMedicine(medicine); // ✅ استخدام الاسم الصحيح
  }

  // ═══════════════════════════════════════════════════════════
  // 🔧 UTILITIES
  // ═══════════════════════════════════════════════════════════

  Future<void> rescheduleMedicine(MedicineModel medicine) async {
    await scheduleMedicine(medicine);
  }

  Future<void> rescheduleAll() async {
    await initializeScheduling();
  }
}
