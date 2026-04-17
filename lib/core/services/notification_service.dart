import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:injectable/injectable.dart';
import 'package:athar/core/time_engine/relative_time_parser.dart';
import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:adhan/adhan.dart';

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _inAppNotificationController = StreamController<String>.broadcast();
  Stream<String> get inAppNotifications => _inAppNotificationController.stream;

  /// 1. تهيئة الخدمة
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // منطق التعامل مع الضغط على الإشعار
      },
    );
  }

  /// 2. طلب الصلاحيات
  Future<bool> requestPermissions() async {
    final bool? androidGranted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    final bool? iosGranted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return (androidGranted ?? false) || (iosGranted ?? false);
  }

  /// 3. إشعار فوري داخل التطبيق
  void notifyInApp(String message) {
    _inAppNotificationController.add(message);
  }

  /// 4. جدولة تنبيه رقمي (وقت محدد)
  Future<void> scheduleFixedNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// 5. جدولة تنبيه "نسبي" (مرتبط بمحرك الوقت)
  Future<void> scheduleRelativeNotification({
    required int id,
    required String title,
    required String body,
    required ReferencePrayer prayer,
    required PrayerRelativeTime relation,
    required int offsetMinutes,
    required PrayerTimes prayerTimes,
    String? payload, // ✅ إضافة اقتراح صديقك
  }) async {
    final actualTime = RelativeTimeParser.calculateActualTime(
      prayer: prayer,
      relation: relation,
      offsetMinutes: offsetMinutes,
      prayerTimes: prayerTimes,
    );

    if (actualTime != null) {
      await scheduleFixedNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: actualTime,
        payload: payload, // ✅ تمريره للدالة الأساسية
      );
    }
  }

  /// 6. جدولة تنبيه متكرر (للعادات والأذكار اليومية)
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required DateTimeComponents matchDateTimeComponents,
    String? payload,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
      payload: payload,
    );
  }

  /// 7. إلغاء تنبيه محدد
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  /// 8. إلغاء جميع التنبيهات
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// 9. الحصول على قائمة الإشعارات المعلقة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// دالة مساعدة لإعدادات التنبيه
  NotificationDetails _getNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'athar_main_channel',
        'تنبيهات أثر المركزية',
        channelDescription: 'تنبيهات الصلاة، الأدوية، والمهام المجدولة',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// تنظيف الموارد
  void dispose() {
    _inAppNotificationController.close();
  }
}
