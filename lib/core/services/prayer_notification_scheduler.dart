import 'package:injectable/injectable.dart';
import 'local_notification_service.dart';
import 'notification_id_manager.dart';
import '../../features/prayer/domain/repositories/prayer_repository.dart';
import '../../features/prayer/domain/entities/prayer_time.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

/// ✅ Scheduler لإشعارات الصلاة
@singleton
class PrayerNotificationScheduler {
  final PrayerRepository _prayerRepository;
  final SettingsRepository _settingsRepository;
  final LocalNotificationService _notificationService;
  final NotificationIdManager _idManager;

  PrayerNotificationScheduler(
    this._prayerRepository,
    this._settingsRepository,
    this._notificationService,
    this._idManager,
  );

  // ═══════════════════════════════════════════════════════════
  // 🎬 INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  /// ✅ التهيئة الكاملة
  Future<void> initializeScheduling() async {
    try {
      print('🕌 Initializing prayer notification scheduler...');

      // 1. التحقق من الإعدادات
      final settings = await _settingsRepository.getSettings();
      if (!(settings.isPrayerEnabled)) {
        print('⏸️ Prayer notifications disabled by user');
        return;
      }

      // 2. جدولة 7 أيام
      await scheduleSevenDays();

      // 3. جدولة إعادة الجدولة التلقائية
      await _scheduleAutoRenewal();

      print('✅ Prayer notification scheduler initialized');
    } catch (e, stackTrace) {
      print('❌ Error initializing prayer scheduler: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📅 SCHEDULING
  // ═══════════════════════════════════════════════════════════

  /// ✅ جدولة 7 أيام مقدماً
  Future<void> scheduleSevenDays() async {
    try {
      print('📅 Scheduling prayers for 7 days...');

      // 1. إلغاء الإشعارات القديمة
      await _cancelAllPrayerNotifications();

      // 2. جدولة 7 أيام
      for (int i = 0; i < 7; i++) {
        final date = DateTime.now().add(Duration(days: i));
        await _schedulePrayersForDate(date);
      }

      // 3. عرض ملخص
      final pending = await _notificationService.getPendingNotifications();
      final prayerNotifications = pending
          .where(
            (n) =>
                n.id >= NotificationIdRanges.prayerBase &&
                n.id <= NotificationIdRanges.prayerMax,
          )
          .length;

      print('✅ Prayer notifications scheduled: $prayerNotifications');
    } catch (e) {
      print('❌ Error scheduling 7 days: $e');
    }
  }

  /// ✅ جدولة إشعارات يوم واحد
  Future<void> _schedulePrayersForDate(DateTime date) async {
    try {
      // 1. جلب مواقيت الصلاة
      final prayerTimes = await _prayerRepository.getPrayerTimesForDate(date);

      // 2. جلب الإعدادات
      final settings = await _settingsRepository.getSettings();

      // 3. جدولة كل صلاة
      for (final prayer in prayerTimes) {
        // تخطي الأوقات الماضية
        if (prayer.time.isBefore(DateTime.now())) {
          continue;
        }

        // تخطي الشروق (ليس فرض)
        if (prayer.type == PrayerType.sunrise) {
          continue;
        }

        // إشعار الأذان
        await _schedulePrayerNotification(prayer, date);

        // تذكير قبل 15 دقيقة (إذا مفعّل)
        if (settings.enablePrayerReminders) {
          await _schedulePrayerReminder(prayer, date);
        }
      }
    } catch (e) {
      print('❌ Error scheduling prayers for $date: $e');
    }
  }

  /// ✅ جدولة إشعار الأذان
  Future<void> _schedulePrayerNotification(
    PrayerTime prayer,
    DateTime date,
  ) async {
    try {
      await _notificationService.schedule(
        id: _idManager.forPrayer(prayer.type, date),
        title: '🕌 حان وقت ${prayer.nameArabic}',
        body: _getPrayerBody(prayer),
        scheduledDate: prayer.time,
        category: NotificationCategory.prayer,
        payload: 'prayer:${prayer.type.name}:${date.toIso8601String()}',
      );
    } catch (e) {
      print('❌ Error scheduling prayer ${prayer.nameArabic}: $e');
    }
  }

  /// ✅ جدولة تذكير قبل 15 دقيقة
  Future<void> _schedulePrayerReminder(PrayerTime prayer, DateTime date) async {
    try {
      final reminderTime = prayer.time.subtract(const Duration(minutes: 15));

      if (reminderTime.isBefore(DateTime.now())) {
        return;
      }

      await _notificationService.schedule(
        id: _idManager.forPrayerReminder(prayer.type, date),
        title: '⏰ تذكير: صلاة ${prayer.nameArabic}',
        body: 'بعد 15 دقيقة',
        scheduledDate: reminderTime,
        category: NotificationCategory.prayer,
        payload:
            'prayer_reminder:${prayer.type.name}:${date.toIso8601String()}',
      );
    } catch (e) {
      print('❌ Error scheduling prayer reminder: $e');
    }
  }

  /// ✅ محتوى الإشعار حسب الصلاة
  String _getPrayerBody(PrayerTime prayer) {
    switch (prayer.type) {
      case PrayerType.fajr:
        return 'الصلاة خير من النوم';
      case PrayerType.dhuhr:
        return 'اللهم صل على محمد';
      case PrayerType.asr:
        return 'لا تنسَ العصر';
      case PrayerType.maghrib:
        return 'اللهم بارك لنا في مغربنا';
      case PrayerType.isha:
        return 'اللهم إنك عفو تحب العفو';
      default:
        return 'حان وقت الصلاة';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔄 AUTO-RENEWAL
  // ═══════════════════════════════════════════════════════════

  /// ✅ جدولة إعادة الجدولة التلقائية (بعد 7 أيام)
  Future<void> _scheduleAutoRenewal() async {
    try {
      final renewalDate = DateTime.now().add(const Duration(days: 7));

      await _notificationService.schedule(
        id: _idManager.autoReschedule,
        title: '_internal_reschedule_',
        body: 'Auto-renewal trigger',
        scheduledDate: renewalDate,
        category: NotificationCategory.general,
        payload: 'auto_reschedule_prayers',
      );

      print('📆 Auto-renewal scheduled for: $renewalDate');
    } catch (e) {
      print('❌ Error scheduling auto-renewal: $e');
    }
  }

  /// ✅ معالجة إعادة الجدولة التلقائية
  Future<void> handleAutoRenewal() async {
    print('🔄 Auto-renewal triggered - rescheduling prayers');
    await scheduleSevenDays();
    await _scheduleAutoRenewal();
  }

  // ═══════════════════════════════════════════════════════════
  // 🗑️ CANCELLATION
  // ═══════════════════════════════════════════════════════════

  /// ✅ إلغاء جميع إشعارات الصلاة
  Future<void> _cancelAllPrayerNotifications() async {
    try {
      print('🗑️ Cancelling all prayer notifications...');
      await _notificationService.cancelRange(
        NotificationIdRanges.prayerBase,
        NotificationIdRanges.prayerMax,
      );
    } catch (e) {
      print('❌ Error cancelling prayer notifications: $e');
    }
  }

  /// ✅ إيقاف جميع الإشعارات
  Future<void> disableNotifications() async {
    print('⏸️ Disabling prayer notifications');
    await _cancelAllPrayerNotifications();
  }

  // ═══════════════════════════════════════════════════════════
  // 🔧 UTILITIES
  // ═══════════════════════════════════════════════════════════

  /// ✅ التحقق من صحة الجدولة
  Future<bool> verifyScheduling() async {
    final pending = await _notificationService.getPendingNotifications();
    final prayerNotifications = pending
        .where(
          (n) =>
              n.id >= NotificationIdRanges.prayerBase &&
              n.id <= NotificationIdRanges.prayerMax,
        )
        .length;

    final isValid = prayerNotifications >= 15;

    if (!isValid) {
      print(
        '⚠️ Low prayer notifications: $prayerNotifications (expected: 15+)',
      );
    }

    return isValid;
  }

  /// ✅ إعادة الجدولة عند تغيير الموقع
  Future<void> onLocationChanged() async {
    print('📍 Location changed - rescheduling prayers');
    await scheduleSevenDays();
  }
}
