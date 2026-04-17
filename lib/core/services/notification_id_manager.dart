import 'package:injectable/injectable.dart';
import '../../features/prayer/domain/entities/prayer_time.dart';

// ════════════════════════════════════════════════════════════
// 📊 NOTIFICATION ID RANGES
// ════════════════════════════════════════════════════════════

/// ✅ نطاقات الـ IDs (Notification ID Namespaces)
///
/// كل feature له نطاق 100,000 ID لتجنب التعارض
class NotificationIdRanges {
  NotificationIdRanges._();

  // 🕌 Prayer: 100,000 - 199,999
  static const int prayerBase = 100000;
  static const int prayerMax = 199999;

  // 💊 Medication: 200,000 - 299,999
  static const int medicationBase = 200000;
  static const int medicationMax = 299999;

  // 📅 Appointment: 300,000 - 399,999
  static const int appointmentBase = 300000;
  static const int appointmentMax = 399999;

  // ✅ Task: 400,000 - 499,999
  static const int taskBase = 400000;
  static const int taskMax = 499999;

  // 🎯 Habit: 500,000 - 599,999
  static const int habitBase = 500000;
  static const int habitMax = 599999;

  // 📿 Athkar: 600,000 - 699,999
  static const int athkarBase = 600000;
  static const int athkarMax = 699999;

  // 📦 Asset: 700,000 - 799,999
  static const int assetBase = 700000;
  static const int assetMax = 799999;

  // 📊 Project: 800,000 - 899,999
  static const int projectBase = 800000;
  static const int projectMax = 899999;

  // 🔧 System: 900,000 - 999,999
  static const int systemBase = 900000;
  static const int systemMax = 999999;

  // ✅ إضافة: Auto-renewal IDs
  static const int autoRenewPrayer = 900000;
  static const int autoRenewMedication = 900001;
  static const int autoRenewTask = 900002;
  static const int autoRenewAppointment = 900003;
  static const int autoRenewHabit = 900004;
  static const int autoRenewAthkar = 900005;
  static const int autoRenewAsset = 900006;
  static const int autoRenewProject = 900007;
  static const int autoRenewSystem = 900008;
  static const int autoRenew = 900009;
  static const int autoRenewMax = 900009;
}

// ════════════════════════════════════════════════════════════
// 🎯 NOTIFICATION ID MANAGER
// ════════════════════════════════════════════════════════════

/// ✅ نظام مركزي لإدارة IDs الإشعارات
///
/// يمنع تعارض IDs بين features مختلفة عبر تخصيص ranges محددة
@lazySingleton
class NotificationIdManager {
  NotificationIdManager();

  // ═══════════════════════════════════════════════════════════
  // 🕌 PRAYER NOTIFICATIONS (100,000 - 199,999)
  // ═══════════════════════════════════════════════════════════

  /// ✅ ID للصلاة في يوم محدد
  ///
  /// Formula: prayerBase + (dayOfYear * 10) + prayerIndex
  ///
  /// Example:
  /// - Fajr on day 25 = 100,000 + (25 * 10) + 0 = 100,250
  /// - Dhuhr on day 25 = 100,000 + (25 * 10) + 2 = 100,252
  // ═══════════════════════════════════════════════════════════
  // 🕌 PRAYER NOTIFICATIONS (100,000 - 199,999)
  // ═══════════════════════════════════════════════════════════

  /// ✅ ID للصلاة في يوم محدد (مُصحح)
  ///
  /// Formula: prayerBase + (dayOfYear * 20) + (prayerIndex * 2)
  ///
  /// كل يوم له 20 slot (10 صلوات × 2 لكل واحدة)
  /// كل صلاة لها 2 IDs: إشعار رئيسي + تذكير
  int forPrayer(PrayerType type, DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final prayerIndex = type.index; // 0-5

    // ✅ مُصحح: dayOfYear * 20 بدلاً من 10
    final id =
        NotificationIdRanges.prayerBase + (dayOfYear * 20) + (prayerIndex * 2);

    assert(
      id <= NotificationIdRanges.prayerMax,
      'Prayer ID overflow! ID: $id, Max: ${NotificationIdRanges.prayerMax}',
    );

    return id;
  }

  /// ✅ ID لتذكير قبل الصلاة (مُصحح)

  /// ✅ ID لتذكير قبل الصلاة (15 دقيقة قبل)
  ///
  /// Formula: forPrayer() + 6
  ///
  /// نضيف 6 لأن لدينا 6 أوقات (فجر، شروق، ظهر، عصر، مغرب، عشاء)
  int forPrayerReminder(PrayerType type, DateTime date) {
    return forPrayer(type, date) + 1; // ✅ +1 بدلاً من +6
  }

  // ═══════════════════════════════════════════════════════════
  // 💊 MEDICATION NOTIFICATIONS (200,000 - 299,999)
  // ═══════════════════════════════════════════════════════════

  /// ✅ ID للدواء (يدعم 30 يوم)
  ///
  /// Formula: medicationBase + (dayOffset * 10000) + hash
  ///
  /// يدعم جدولة 30 يوم مقدماً (0-29)
  int forMedication(String medicationId, {int dayOffset = 0}) {
    assert(
      dayOffset >= 0 && dayOffset < 30,
      'Day offset must be 0-29, got: $dayOffset',
    );

    final hash = medicationId.hashCode.abs() % 10000; // 0-9,999
    final id = NotificationIdRanges.medicationBase + (dayOffset * 10000) + hash;

    assert(
      id <= NotificationIdRanges.medicationMax,
      'Medication ID overflow! ID: $id, Max: ${NotificationIdRanges.medicationMax}',
    );

    return id;
  }

  /// ✅ ID لتذكير نفاد المخزون
  int forMedicationRefillAlert(String medicationId) {
    final hash = medicationId.hashCode.abs() % 10000;
    return NotificationIdRanges.medicationBase + 50000 + hash;
  }

  /// ✅ ID لتذكير قبل الدواء (قبل 5 دقائق)
  int forMedicationReminder(String medicationId, {int dayOffset = 0}) {
    final baseId = forMedication(medicationId, dayOffset: dayOffset);
    final reminderId = baseId + 40000;

    assert(
      reminderId <= NotificationIdRanges.medicationMax,
      'Medication reminder ID overflow! ID: $reminderId',
    );

    return reminderId;
  }

  // ═══════════════════════════════════════════════════════════
  // 📅 APPOINTMENT NOTIFICATIONS (300,000 - 399,999)
  // ═══════════════════════════════════════════════════════════

  /// ✅ ID للموعد
  int forAppointment(String appointmentId) {
    final hash = appointmentId.hashCode.abs() % 100000; // 0-99,999
    final id = NotificationIdRanges.appointmentBase + hash;

    assert(
      id <= NotificationIdRanges.appointmentMax,
      'Appointment ID overflow! ID: $id',
    );

    return id;
  }

  // ✅ الإضافات الجديدة للمواعيد

  /// تذكير قبل يوم
  int forAppointmentDayBefore(String appointmentId) {
    return forAppointment(appointmentId) + 60000;
  }

  /// تذكير قبل ساعة
  int forAppointmentHourBefore(String appointmentId) {
    return forAppointment(appointmentId) + 50000;
  }

  /// تذكير قبل دقائق (15 دقيقة مثلاً)
  int forAppointmentMinutesBefore(String appointmentId) {
    return forAppointment(appointmentId) + 70000;
  }

  /// ✅ ID لتذكير الموعد (قبل ساعة)
  int forAppointmentReminder1Hour(String appointmentId) {
    return forAppointment(appointmentId) + 50000;
  }

  /// ✅ ID لتذكير الموعد (قبل يوم)
  int forAppointmentReminder1Day(String appointmentId) {
    return forAppointment(appointmentId) + 60000;
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ TASK NOTIFICATIONS (400,000 - 499,999)
  // ═══════════════════════════════════════════════════════════

  /// ✅ ID لإشعار مهمة
  /// يستخدم UUID hash لتوليد ID فريد ومستقر
  int forTask(String taskUuid) {
    final hash = taskUuid.hashCode.abs() % 100000;
    final id = NotificationIdRanges.taskBase + hash;

    assert(
      id >= NotificationIdRanges.taskBase && id <= NotificationIdRanges.taskMax,
      'Task ID out of range! ID: $id',
    );

    return id;
  }

  /// ✅ ID لتذكير قبل المهمة
  /// يضيف offset لـ task ID الأساسي
  int forTaskReminder(String taskUuid) {
    final baseId = forTask(taskUuid);
    return baseId + 50000; // Offset to separate from main task notification
  }

  /// ✅ ID للمهمة المتكررة
  int forTaskRecurring(String taskId, {int occurrenceNumber = 0}) {
    final hash = taskId.hashCode.abs() % 1000;
    return NotificationIdRanges.taskBase +
        60000 +
        (occurrenceNumber * 1000) +
        hash;
  }

  // ═══════════════════════════════════════════════════════════
  // 🎯 HABIT NOTIFICATIONS (500,000 - 599,999)
  // ═══════════════════════════════════════════════════════════

  /// ✅ ID للعادة (يدعم 14 يوم)
  int forHabit(String habitId, {int dayOffset = 0}) {
    assert(
      dayOffset >= 0 && dayOffset < 14,
      'Day offset must be 0-13, got: $dayOffset',
    );

    final hash = habitId.hashCode.abs() % 10000;
    final id = NotificationIdRanges.habitBase + (dayOffset * 10000) + hash;

    assert(id <= NotificationIdRanges.habitMax, 'Habit ID overflow! ID: $id');

    return id;
  }

  /// ✅ ID لتنبيه Streak
  int forHabitStreak(String habitId) {
    final hash = habitId.hashCode.abs() % 10000;
    return NotificationIdRanges.habitBase + 90000 + hash;
  }

  /// ✅ ID لتذكير العادة (للعادات الأسبوعية/الشهرية)
  /// يدعم جدولة متعددة لنفس العادة في أيام مختلفة
  int forHabitReminder(String habitId, {int dayOffset = 0}) {
    assert(
      dayOffset >= 0 && dayOffset < 30,
      'Day offset must be 0-29, got: $dayOffset',
    );

    final hash = habitId.hashCode.abs() % 1000;
    final id =
        NotificationIdRanges.habitBase + 140000 + (dayOffset * 100) + hash;

    assert(
      id <= NotificationIdRanges.habitMax,
      'Habit reminder ID overflow! ID: $id, Max: ${NotificationIdRanges.habitMax}',
    );

    return id;
  }

  // ═══════════════════════════════════════════════════════════
  // 📿 ATHKAR NOTIFICATIONS (600,000 - 699,999)
  // ═══════════════════════════════════════════════════════════

  int forAthkar(String athkarType) {
    final hash = athkarType.hashCode.abs() % 100000;
    final id = NotificationIdRanges.athkarBase + hash;

    assert(id <= NotificationIdRanges.athkarMax, 'Athkar ID overflow! ID: $id');

    return id;
  }

  // IDs ثابتة للأذكار الأساسية
  int get morningAthkar => NotificationIdRanges.athkarBase + 1;
  int get eveningAthkar => NotificationIdRanges.athkarBase + 2;
  int get sleepAthkar => NotificationIdRanges.athkarBase + 3;
  int get prayerAthkar => NotificationIdRanges.athkarBase + 4;
  int get wakeUpAthkar => NotificationIdRanges.athkarBase + 5;

  /// ✅ ID لذكر مخصص
  int forCustomAthkar(String athkarId) {
    final hash = athkarId.hashCode.abs() % 10000;
    return NotificationIdRanges.athkarBase + 1000 + hash;
  }

  // ═══════════════════════════════════════════════════════════
  // 📦 ASSET NOTIFICATIONS (700,000 - 799,999)
  // ═══════════════════════════════════════════════════════════

  int forAsset(String assetId) {
    final hash = assetId.hashCode.abs() % 100000;
    final id = NotificationIdRanges.assetBase + hash;

    assert(id <= NotificationIdRanges.assetMax, 'Asset ID overflow! ID: $id');

    return id;
  }

  int forAssetMaintenance(String assetId) {
    return forAsset(assetId) + 10000;
  }

  int forAssetInsurance(String assetId) {
    return forAsset(assetId) + 20000;
  }

  int forAssetLicense(String assetId) {
    return forAsset(assetId) + 30000;
  }

  /// ✅ ID لانتهاء ضمان الأصل
  int forAssetWarranty(String assetId, {int daysBeforeExpiry = 0}) {
    final hash = assetId.hashCode.abs() % 1000;

    // نطاقات مختلفة حسب البعد عن الانتهاء
    int offset;
    if (daysBeforeExpiry == 30) {
      offset = 0; // قبل 30 يوم
    } else if (daysBeforeExpiry == 7) {
      offset = 10000; // قبل 7 أيام
    } else {
      offset = 20000; // يوم الانتهاء
    }

    return NotificationIdRanges.assetBase + offset + hash;
  }

  /// ✅ ID لتذكير الصيانة
  // int forAssetMaintenance(String assetId) {
  //   final hash = assetId.hashCode.abs() % 1000;
  //   return NotificationIdRanges.assetBase + 30000 + hash;
  // }

  /// ✅ ID لمراجعة الأصول الشهرية
  int get assetMonthlyReview => NotificationIdRanges.assetBase + 90000;

  // ═══════════════════════════════════════════════════════════
  // 📊 PROJECT NOTIFICATIONS (800,000 - 899,999)
  // ═══════════════════════════════════════════════════════════
  int forProject(String projectId) {
    final hash = projectId.hashCode.abs() % 100000;
    final id = NotificationIdRanges.projectBase + hash;

    assert(
      id <= NotificationIdRanges.projectMax,
      'Project ID overflow! ID: $id',
    );

    return id;
  }

  int forProjectMilestone(String projectId, int milestoneIndex) {
    return forProject(projectId) + 10000 + milestoneIndex;
  }

  /// ✅ ID للموعد النهائي للمشروع
  int forProjectDeadline(String projectId) {
    final hash = projectId.hashCode.abs() % 100000;
    return NotificationIdRanges.projectBase + hash;
  }

  /// ✅ ID لتذكير الموعد النهائي (قبل 3 أيام)
  int forProjectDeadlineReminder(String projectId) {
    return forProjectDeadline(projectId) + 50000;
  }

  // ═══════════════════════════════════════════════════════════
  // 🔧 SYSTEM NOTIFICATIONS (900,000 - 999,999)
  // ═══════════════════════════════════════════════════════════

  /// ✅ ID لإعادة الجدولة التلقائية (Auto-reschedule)
  ///
  /// يُستخدم لجدولة إشعار يُطلق بعد 7 أيام لإعادة جدولة
  /// جميع الإشعارات للأيام الـ 7 القادمة
  int get autoReschedule => NotificationIdRanges.systemBase;

  /// ✅ ID لتذكير فتح التطبيق (إذا لم يُفتح منذ 7 أيام)
  int get appOpenReminder => NotificationIdRanges.systemBase + 1;

  /// ✅ ID لتحديث التطبيق
  int get appUpdate => NotificationIdRanges.systemBase + 2;

  // Auto-renewal IDs لكل نظام
  int get autoRenewPrayer => NotificationIdRanges.autoRenewPrayer;
  int get autoRenewMedication => NotificationIdRanges.autoRenewMedication;
  int get autoRenewTask => NotificationIdRanges.autoRenewTask;
  int get autoRenewAppointment => NotificationIdRanges.autoRenewAppointment;
  int get autoRenewHabit => NotificationIdRanges.autoRenewHabit;
  int get autoRenewAthkar => NotificationIdRanges.autoRenewAthkar;
  int get autoRenewAsset => NotificationIdRanges.autoRenewAsset;

  // ═══════════════════════════════════════════════════════════
  // 🛠️ UTILITY METHODS
  // ═══════════════════════════════════════════════════════════

  /// ✅ التحقق: هل هذا ID صالح؟
  bool isValid(int id) {
    return id >= 0 && id < 1000000;
  }

  /// ✅ معرفة نوع الإشعار من ID
  NotificationType getType(int id) {
    if (id >= NotificationIdRanges.prayerBase &&
        id <= NotificationIdRanges.prayerMax) {
      return NotificationType.prayer;
    } else if (id >= NotificationIdRanges.medicationBase &&
        id <= NotificationIdRanges.medicationMax) {
      return NotificationType.medication;
    } else if (id >= NotificationIdRanges.appointmentBase &&
        id <= NotificationIdRanges.appointmentMax) {
      return NotificationType.appointment;
    } else if (id >= NotificationIdRanges.taskBase &&
        id <= NotificationIdRanges.taskMax) {
      return NotificationType.task;
    } else if (id >= NotificationIdRanges.habitBase &&
        id <= NotificationIdRanges.habitMax) {
      return NotificationType.habit;
    } else if (id >= NotificationIdRanges.athkarBase &&
        id <= NotificationIdRanges.athkarMax) {
      return NotificationType.athkar;
    } else if (id >= NotificationIdRanges.assetBase &&
        id <= NotificationIdRanges.assetMax) {
      return NotificationType.asset;
    } else if (id >= NotificationIdRanges.projectBase &&
        id <= NotificationIdRanges.projectMax) {
      return NotificationType.project;
    } else if (id >= NotificationIdRanges.systemBase &&
        id <= NotificationIdRanges.systemMax) {
      return NotificationType.system;
    }
    return NotificationType.unknown;
  }

  /// ✅ للـ Debugging: عرض معلومات ID
  String debugInfo(int id) {
    final type = getType(id);
    final range = _getRange(type);
    return 'ID: $id, Type: $type, Range: $range';
  }

  String _getRange(NotificationType type) {
    switch (type) {
      case NotificationType.prayer:
        return '${NotificationIdRanges.prayerBase}-${NotificationIdRanges.prayerMax}';
      case NotificationType.medication:
        return '${NotificationIdRanges.medicationBase}-${NotificationIdRanges.medicationMax}';
      case NotificationType.appointment:
        return '${NotificationIdRanges.appointmentBase}-${NotificationIdRanges.appointmentMax}';
      case NotificationType.task:
        return '${NotificationIdRanges.taskBase}-${NotificationIdRanges.taskMax}';
      case NotificationType.habit:
        return '${NotificationIdRanges.habitBase}-${NotificationIdRanges.habitMax}';
      case NotificationType.athkar:
        return '${NotificationIdRanges.athkarBase}-${NotificationIdRanges.athkarMax}';
      case NotificationType.asset:
        return '${NotificationIdRanges.assetBase}-${NotificationIdRanges.assetMax}';
      case NotificationType.project:
        return '${NotificationIdRanges.projectBase}-${NotificationIdRanges.projectMax}';
      case NotificationType.system:
        return '${NotificationIdRanges.systemBase}-${NotificationIdRanges.systemMax}';
      case NotificationType.unknown:
        return 'unknown';
    }
  }
}

// ════════════════════════════════════════════════════════════
// 📋 ENUMS
// ════════════════════════════════════════════════════════════

/// ✅ أنواع الإشعارات
enum NotificationType {
  prayer,
  medication,
  appointment,
  task,
  habit,
  athkar,
  asset,
  project,
  system,
  unknown,
}
