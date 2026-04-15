// lib/core/services/local_notification_service.dart

import 'dart:io';
import 'dart:ui';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/deep_link_service.dart';
import 'package:athar/core/services/notification_id_manager.dart';
import 'package:athar/features/habits/presentation/pages/habit_page.dart';
import 'package:athar/features/notifications/data/models/notification_model.dart';
import 'package:athar/features/prayer/presentation/pages/prayer_page.dart';
import 'package:athar/features/task/presentation/pages/task_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';

/// ✅ فئات الإشعارات
enum NotificationCategory {
  prayer,
  medication,
  appointment,
  task,
  habit,
  athkar,
  asset,
  project,
  zone,
  general,
}

/// ✅ خدمة الإشعارات المحلية الشاملة (Singleton)
@lazySingleton
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ✅ إضافة: callback للتعامل مع auto-renewal
  Function(String payload)? _onAutoRenewalCallback;

  // ═══════════════════════════════════════════════════════════
  // 🎬 INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  /// ✅ التهيئة الأولية (مع الأذونات)
  ///
  /// ✅ جديد: يمكن تمرير callback لمعالجة auto-renewal
  Future<void> init({Function(String payload)? onAutoRenewal}) async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('⚠️ LocalNotificationService already initialized');
      }
      return;
    }

    // ✅ حفظ الـ callback
    _onAutoRenewalCallback = onAutoRenewal;

    try {
      // 1. تهيئة timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));

      // 2. طلب الأذونات أولاً (قبل التهيئة)
      await _requestPermissions();

      // 3. إعدادات Android
      const androidSettings = AndroidInitializationSettings(
        '@drawable/ic_notification',
      );

      // 4. إعدادات iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 5. إعدادات عامة
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 6. تهيئة Plugin
      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationTapped,
      );

      _isInitialized = true;
      print('✅ LocalNotificationService initialized successfully');
    } catch (e, stackTrace) {
      print('❌ Error initializing LocalNotificationService: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// ✅ طلب الأذونات (Android 13+ & iOS)
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ - Notification Permission
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        final result = await Permission.notification.request();
        if (result.isDenied) {
          print('⚠️ Notification permission denied');
        }
      }

      // Android 12+ - Exact Alarm Permission (حرجة!)
      if (await Permission.scheduleExactAlarm.isDenied) {
        final result = await Permission.scheduleExactAlarm.request();
        if (result.isDenied) {
          print('⚠️ Exact alarm permission denied');
        }
      }
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      print('iOS Notification Permission: $result');
    }
  }

  /// ✅ معالجة النقر على الإشعار (foreground)
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    print('📱 Notification tapped: $payload');

    // ✅✅✅ معالجة auto-renewal (الإصلاح الجديد)
    if (_isAutoRenewalPayload(payload)) {
      print('🔄 Auto-renewal notification detected');

      // استدعاء الـ callback
      if (_onAutoRenewalCallback != null) {
        _onAutoRenewalCallback!(payload);
      } else {
        print('⚠️ No auto-renewal callback registered');
      }

      return; // إيقاف - لا نريد معالجة إضافية
    }

    // ✅ معالجة باقي الإشعارات
    _handleRegularNotification(payload);
  }

  /// ✅ معالجة النقر على الإشعار (background)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    print('📱 Background notification tapped: $payload');

    // ✅ معالجة auto-renewal في الخلفية
    if (payload != null && _isAutoRenewalPayloadStatic(payload)) {
      print('🔄 Background auto-renewal detected');
      // في الخلفية، سيتم معالجته عند فتح التطبيق
    }
  }

  /// ✅ التحقق: هل هذا payload خاص بـ auto-renewal؟
  bool _isAutoRenewalPayload(String payload) {
    return payload.startsWith('auto_reschedule_');
  }

  /// ✅ نسخة static للاستخدام في background
  static bool _isAutoRenewalPayloadStatic(String payload) {
    return payload.startsWith('auto_reschedule_');
  }

  /// ✅ معالجة الإشعارات العادية — التنقل عبر DeepLinkService
  void _handleRegularNotification(String payload) {
    final navigator = DeepLinkService.navigatorKey.currentState;
    if (navigator == null) {
      if (kDebugMode) print('⚠️ Navigator not ready for payload: $payload');
      return;
    }

    // استخراج النوع (مثال: "task:uuid-123" → "task")
    final type = payload.split(':').first;

    // الوصول للشاشة الرئيسية أولاً ثم فتح التفاصيل (إن أمكن)
    void openHomeThen(Widget page) {
      navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      navigator.push(MaterialPageRoute(builder: (_) => page));
    }

    switch (type) {
      case 'prayer':
        openHomeThen(const PrayerPage());
        break;
      case 'task':
        openHomeThen(const TasksPage());
        break;
      case 'habit':
        openHomeThen(const HabitsPage());
        break;
      // medication / appointment يحتاجان moduleId — نفتح الصفحة الرئيسية
      // ليختار المستخدم المساحة الصحية من هناك.
      case 'medication':
      case 'medicine':
      case 'appointment':
      case 'athkar':
      default:
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
        break;
    }
  }

  /// حفظ التنبيه في سجل الإشعارات (In-app Inbox)
  Future<void> logNotification({
    required String title,
    required String body,
    required String type,
    String? payload,
  }) async {
    final isar = getIt<Isar>();
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    // 1. الحفظ في Supabase أولاً للحصول على UUID
    final response = await supabase
        .from('notifications')
        .insert({
          'user_id': userId,
          'title': title,
          'body': body,
          'type': type,
          'payload': payload,
          'is_read': false,
        })
        .select()
        .single();

    // 2. الحفظ في Isar للمزامنة المحلية
    final newNote = NotificationModel()
      ..uuid = response['id']
      ..title = title
      ..body = body
      ..type = type
      ..payload = payload
      ..createdAt = DateTime.now()
      ..isRead = false
      ..isSynced = true;

    await isar.writeTxn(() async {
      await isar.notificationModels.put(newNote);
    });
  }

  // ═══════════════════════════════════════════════════════════
  // 📅 SCHEDULING
  // ═══════════════════════════════════════════════════════════

  /// ✅ جدولة إشعار في وقت محدد
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    NotificationCategory category = NotificationCategory.general,
    String? payload,
  }) async {
    if (!_isInitialized) {
      print('⚠️ Service not initialized. Call init() first.');
      return;
    }

    // التحقق: الوقت في المستقبل
    if (scheduledDate.isBefore(DateTime.now())) {
      print('⚠️ Cannot schedule notification in the past: $id');
      return;
    }

    try {
      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: _getNotificationDetails(category),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      // print('✅ Scheduled notification #$id at $scheduledDate');
    } catch (e) {
      print('❌ Error scheduling notification #$id: $e');
    }
  }

  /// ✅ جدولة إشعار فوري (يظهر الآن)
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    NotificationCategory category = NotificationCategory.general,
    String? payload,
  }) async {
    if (!_isInitialized) {
      print('⚠️ Service not initialized. Call init() first.');
      return;
    }

    try {
      await _notifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _getNotificationDetails(category),
        payload: payload,
      );

      print('✅ Showed immediate notification #$id');
    } catch (e) {
      print('❌ Error showing notification #$id: $e');
    }
  }

  /// ✅ جدولة إشعار يومي متكرر في وقت محدد
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    NotificationCategory category = NotificationCategory.general,
    String? payload,
  }) async {
    if (!_isInitialized) {
      print('⚠️ Service not initialized. Call init() first.');
      return;
    }

    try {
      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfTime(hour, minute),
        notificationDetails: _getNotificationDetails(category),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      print('✅ Scheduled daily notification #$id at $hour:$minute');
    } catch (e) {
      print('❌ Error scheduling daily notification #$id: $e');
    }
  }

  /// ✅ حساب الوقت القادم لساعة محددة
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );

    // إذا فات الوقت اليوم، جدول لغداً
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // ═══════════════════════════════════════════════════════════
  // 🗑️ CANCELLATION
  // ═══════════════════════════════════════════════════════════

  /// ✅ إلغاء إشعار محدد
  // Future<void> cancel(int id) async {
  //   await _notifications.cancel(id);
  //   print('🗑️ Cancelled notification #$id');
  // }
  Future<void> cancel(int id, {bool silent = false}) async {
    await _notifications.cancel(id: id);
    if (!silent && kDebugMode) {
      print('🗑️ Cancelled notification #$id');
    }
  }

  /// ✅ إلغاء جميع الإشعارات
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    print('🗑️ Cancelled all notifications');
  }

  /// ✅ إلغاء نطاق من الإشعارات
  // Future<void> cancelRange(int startId, int endId) async {
  //   print('🗑️ Cancelling notifications from $startId to $endId');

  //   for (int id = startId; id <= endId; id++) {
  //     await cancel(id);
  //   }

  //   print('✅ Cancelled ${endId - startId + 1} notifications');
  // }

  /// ✅ إلغاء نطاق من الإشعارات (المجدولة فعلياً فقط)
  Future<void> cancelRange(int startId, int endId) async {
    if (kDebugMode) {
      print('🗑️ Cancelling notifications in range $startId-$endId...');
    }

    // 1. جلب الإشعارات المجدولة فعلياً
    final pending = await getPendingNotifications();

    // 2. تصفية فقط الإشعارات في النطاق المحدد
    final toCancel = pending
        .where((n) => n.id >= startId && n.id <= endId)
        .toList();

    if (toCancel.isEmpty) {
      if (kDebugMode) {
        print('ℹ️ No notifications to cancel in this range');
      }
      return;
    }

    // 3. إلغاء فقط الإشعارات الموجودة (بدون طباعة لكل واحد)
    for (final notification in toCancel) {
      await _notifications.cancel(id: notification.id);
    }

    if (kDebugMode) {
      print('✅ Cancelled ${toCancel.length} notifications');
    }
  }

  /// إلغاء جميع إشعارات المهام
  Future<void> cancelTaskNotifications() async {
    // إلغاء النطاق الكامل
    await cancelRange(
      NotificationIdRanges.taskBase,
      NotificationIdRanges.taskMax,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🔍 QUERIES
  // ═══════════════════════════════════════════════════════════

  /// ✅ الحصول على قائمة الإشعارات المجدولة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// ✅ الحصول على عدد الإشعارات المجدولة
  Future<int> getPendingCount() async {
    final pending = await getPendingNotifications();
    return pending.length;
  }

  /// ✅ التحقق: هل يوجد إشعار مجدول برقم معين؟
  Future<bool> isScheduled(int id) async {
    final pending = await getPendingNotifications();
    return pending.any((n) => n.id == id);
  }

  // ═══════════════════════════════════════════════════════════
  // 🎨 NOTIFICATION DETAILS
  // ═══════════════════════════════════════════════════════════

  /// ✅ تفاصيل الإشعار (Android + iOS)
  NotificationDetails _getNotificationDetails(NotificationCategory category) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _getChannelId(category),
        _getChannelName(category),
        channelDescription: _getChannelDescription(category),
        importance: Importance.max,
        priority: Priority.high,
        sound: _getAndroidSound(category),
        icon: '@drawable/ic_notification',
        color: _getColor(category),
        enableVibration: true,
        playSound: true,
        fullScreenIntent: category == NotificationCategory.prayer,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: _getIOSSound(category),
        badgeNumber: 1,
      ),
    );
  }

  /// ✅ Channel ID
  String _getChannelId(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.prayer:
        return 'prayer_notifications';
      case NotificationCategory.medication:
        return 'medication_notifications';
      case NotificationCategory.task:
        return 'task_notifications';
      case NotificationCategory.habit:
        return 'habit_notifications';
      case NotificationCategory.zone:
        return 'zone_notifications';
      default:
        return 'general_notifications';
    }
  }

  /// ✅ Channel Name
  String _getChannelName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.prayer:
        return 'تنبيهات الصلاة';
      case NotificationCategory.medication:
        return 'تنبيهات الأدوية';
      case NotificationCategory.task:
        return 'تنبيهات المهام';
      case NotificationCategory.habit:
        return 'تنبيهات العادات';
      case NotificationCategory.zone:
        return 'تنبيهات المناطق الذكية';
      default:
        return 'تنبيهات عامة';
    }
  }

  /// ✅ Channel Description
  String _getChannelDescription(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.prayer:
        return 'تذكيرك بأوقات الصلاة';
      case NotificationCategory.medication:
        return 'تذكيرك بمواعيد الأدوية';
      case NotificationCategory.task:
        return 'تذكيرك بالمهام المجدولة';
      case NotificationCategory.habit:
        return 'تذكيرك بالعادات اليومية';
      case NotificationCategory.zone:
        return 'إشعارات تغيير المنطقة الذكية';
      default:
        return 'إشعارات عامة من التطبيق';
    }
  }

  /// ✅ الصوت لـ Android
  RawResourceAndroidNotificationSound? _getAndroidSound(
    NotificationCategory category,
  ) {
    try {
      switch (category) {
        case NotificationCategory.prayer:
          return const RawResourceAndroidNotificationSound('adhan');
        case NotificationCategory.medication:
          return const RawResourceAndroidNotificationSound('medication_alert');
        default:
          return null;
      }
    } catch (e) {
      print('⚠️ Sound file not found: $e');
      return null;
    }
  }

  /// ✅ الصوت لـ iOS
  String? _getIOSSound(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.prayer:
        return 'adhan.caf';
      case NotificationCategory.medication:
        return 'medication_alert.caf';
      default:
        return null;
    }
  }

  /// ✅ اللون حسب الفئة
  Color _getColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.prayer:
        return const Color(0xFF00796B);
      case NotificationCategory.medication:
        return const Color(0xFFE53935);
      case NotificationCategory.task:
        return const Color(0xFF1976D2);
      case NotificationCategory.habit:
        return const Color(0xFF388E3C);
      case NotificationCategory.zone:
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFF2196F3);
    }
  }

  /// ✅ للـ Debugging
  Future<void> debugPrintPending() async {
    final pending = await getPendingNotifications();
    print('📋 Pending notifications (${pending.length}):');
    for (final n in pending) {
      print('  - ID: ${n.id}, Title: ${n.title}, Body: ${n.body}');
    }
  }
}
