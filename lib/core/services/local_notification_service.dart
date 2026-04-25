// lib/core/services/local_notification_service.dart

import 'dart:io';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/deep_link_service.dart';
import 'package:athar/core/services/notification_id_manager.dart';
import 'package:athar/features/habits/presentation/pages/habit_page.dart';
import 'package:athar/features/notifications/data/models/notification_model.dart';
import 'package:athar/features/prayer/presentation/pages/prayer_page.dart';
import 'package:athar/features/task/presentation/pages/task_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
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

  // Payload from a cold-start (app terminated → user tapped notification).
  // Populated during init(), consumed once by app.dart after the first frame.
  String? _coldStartPayload;

  String _notificationUuid(Map<String, dynamic> row) {
    final value = row['uuid'] ?? row['id'];
    return value?.toString() ?? 'missing_${DateTime.now().millisecondsSinceEpoch}';
  }

  NotificationModel _mapStoredNotification({
    required Map<String, dynamic> row,
    required String fallbackTitle,
    required String fallbackBody,
    required String fallbackType,
    String? fallbackPayload,
  }) {
    return NotificationModel()
      ..uuid = _notificationUuid(row)
      ..title = row['title']?.toString() ?? fallbackTitle
      ..body = row['body']?.toString() ?? fallbackBody
      ..type = row['type']?.toString() ?? fallbackType
      ..payload = row['payload']?.toString() ?? fallbackPayload
      ..createdAt =
          DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now()
      ..isRead = row['is_read'] == true
      ..isSynced = true;
  }

  // ═══════════════════════════════════════════════════════════
  // 🎬 INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  /// ✅ التهيئة الأولية (مع الأذونات)
  ///
  /// ✅ جديد: يمكن تمرير callback لمعالجة auto-renewal
  Future<void> init({Function(String payload)? onAutoRenewal}) async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('⚠️ LocalNotificationService already initialized');
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
      debugPrint('✅ LocalNotificationService initialized successfully');

      // 7. Check for cold-start: did the user tap a notification to launch the app?
      //    getNotificationAppLaunchDetails() only returns data once per cold start.
      final launchDetails = await _notifications.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        if (payload != null && !_isAutoRenewalPayload(payload)) {
          // Log immediately so the inbox is populated before the first frame.
          await _logNotificationLocal(
            title: _titleFromPayload(payload),
            body: '',
            type: payload.split(':').first,
            payload: payload,
          );
          _coldStartPayload = payload;
          if (kDebugMode) debugPrint('📲 Cold-start payload stored: $payload');
        } else if (payload != null && _isAutoRenewalPayload(payload)) {
          _onAutoRenewalCallback?.call(payload);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing LocalNotificationService: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Returns (and clears) a notification payload that launched the app from
  /// terminated state. Call once from app.dart after the first frame.
  String? consumeColdStartPayload() {
    final payload = _coldStartPayload;
    _coldStartPayload = null;
    return payload;
  }

  /// Navigate to the correct page for a given notification payload.
  /// Public so app.dart can invoke it after the navigator is ready.
  void navigateFromNotificationPayload(String payload) {
    _handleRegularNotification(payload);
  }

  /// ✅ طلب الأذونات (Android 13+ & iOS)
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ - Notification Permission
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        final result = await Permission.notification.request();
        if (result.isDenied) {
          debugPrint('⚠️ Notification permission denied');
        }
      }

      // Android 12+ - Exact Alarm Permission (حرجة!)
      if (await Permission.scheduleExactAlarm.isDenied) {
        final result = await Permission.scheduleExactAlarm.request();
        if (result.isDenied) {
          debugPrint('⚠️ Exact alarm permission denied');
        }
      }
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      debugPrint('iOS Notification Permission: $result');
    }
  }

  /// ✅ معالجة النقر على الإشعار (foreground)
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    debugPrint('📱 Notification tapped: $payload');
    clearAppBadge();

    if (_isAutoRenewalPayload(payload)) {
      debugPrint('🔄 Auto-renewal notification detected');
      _onAutoRenewalCallback?.call(payload);
      return;
    }

    // Log the tapped notification into the in-app inbox so it appears in
    // the notification center (prayer and other local notifications are
    // never pushed to Supabase, so this is the only logging point).
    _logNotificationLocal(
      title: _titleFromPayload(payload),
      body: '',
      type: payload.split(':').first,
      payload: payload,
    );

    _handleRegularNotification(payload);
  }

  /// ✅ معالجة النقر على الإشعار (background)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('📱 Background notification tapped: $payload');

    // ✅ معالجة auto-renewal في الخلفية
    if (payload != null && _isAutoRenewalPayloadStatic(payload)) {
      debugPrint('🔄 Background auto-renewal detected');
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
      if (kDebugMode) debugPrint('⚠️ Navigator not ready for payload: $payload');
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

    try {
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

      final newNote = _mapStoredNotification(
        row: response,
        fallbackTitle: title,
        fallbackBody: body,
        fallbackType: type,
        fallbackPayload: payload,
      );

      await isar.writeTxn(() async {
        await isar.notificationModels.put(newNote);
      });
    } catch (_) {
      final offlineNote = NotificationModel()
        ..uuid = 'off_${DateTime.now().millisecondsSinceEpoch}'
        ..title = title
        ..body = body
        ..type = type
        ..payload = payload
        ..createdAt = DateTime.now()
        ..isRead = false
        ..isSynced = false;

      await isar.writeTxn(() async {
        await isar.notificationModels.put(offlineNote);
      });
    }
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
      debugPrint('⚠️ Service not initialized. Call init() first.');
      return;
    }

    // التحقق: الوقت في المستقبل
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('⚠️ Cannot schedule notification in the past: $id');
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

      // debugPrint('✅ Scheduled notification #$id at $scheduledDate');
    } catch (e) {
      debugPrint('❌ Error scheduling notification #$id: $e');
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
      debugPrint('⚠️ Service not initialized. Call init() first.');
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

      debugPrint('✅ Showed immediate notification #$id');
    } catch (e) {
      debugPrint('❌ Error showing notification #$id: $e');
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
      debugPrint('⚠️ Service not initialized. Call init() first.');
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

      debugPrint('✅ Scheduled daily notification #$id at $hour:$minute');
    } catch (e) {
      debugPrint('❌ Error scheduling daily notification #$id: $e');
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
  //   debugPrint('🗑️ Cancelled notification #$id');
  // }
  Future<void> cancel(int id, {bool silent = false}) async {
    await _notifications.cancel(id: id);
    if (!silent && kDebugMode) {
      debugPrint('🗑️ Cancelled notification #$id');
    }
  }

  /// ✅ إلغاء جميع الإشعارات
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('🗑️ Cancelled all notifications');
  }

  Future<void> clearAppBadge() => setAppBadge(0);

  Future<void> setAppBadge(int count) async {
    try {
      if (count == 0) {
        await FlutterAppBadger.removeBadge();
      } else {
        await FlutterAppBadger.updateBadgeCount(count);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Could not set app badge to $count: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📥 LOCAL NOTIFICATION LOGGING
  // ═══════════════════════════════════════════════════════════

  /// Reconstructs a human-readable title from a notification payload.
  String _titleFromPayload(String payload) {
    final parts = payload.split(':');
    final type = parts.isNotEmpty ? parts[0] : 'general';
    final sub = parts.length > 1 ? parts[1] : '';
    const prayerNames = {
      'fajr': 'الفجر',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghrib': 'المغرب',
      'isha': 'العشاء',
      'sunrise': 'الشروق',
    };
    switch (type) {
      case 'prayer':
        return '🕌 حان وقت ${prayerNames[sub] ?? sub}';
      case 'prayer_reminder':
        return '⏰ تذكير: صلاة ${prayerNames[sub] ?? sub}';
      case 'task':
        return '✅ تذكير مهمة';
      case 'habit':
        return '🌟 تذكير عادة';
      case 'medication':
      case 'medicine':
        return '💊 تذكير دواء';
      case 'appointment':
        return '📅 موعد قادم';
      default:
        return 'تنبيه جديد';
    }
  }

  /// Writes a notification record directly to Isar (no Supabase).
  /// Uses a deterministic UUID from the payload so duplicates are replaced.
  Future<void> _logNotificationLocal({
    required String title,
    required String body,
    required String type,
    required String? payload,
  }) async {
    try {
      final isar = getIt<Isar>();
      final uuid =
          'local_${(payload ?? 'no_payload').replaceAll(RegExp(r'[:/.]'), '_')}';
      final note = NotificationModel()
        ..uuid = uuid
        ..title = title.isNotEmpty ? title : _titleFromPayload(payload ?? type)
        ..body = body
        ..type = type
        ..payload = payload
        ..createdAt = DateTime.now()
        ..isRead = false
        ..isSynced = false;
      await isar.writeTxn(() async {
        await isar.notificationModels.put(note);
      });
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ logNotificationLocal failed: $e');
    }
  }

  /// Logs any notifications currently in the system tray (delivered but not dismissed).
  /// Safe to call on app resume — uses deterministic UUIDs to prevent duplicates.
  Future<void> logActiveNotifications() async {
    try {
      List<ActiveNotification>? active;
      if (Platform.isIOS) {
        active = await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications();
      } else if (Platform.isAndroid) {
        active = await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getActiveNotifications();
      }
      if (active == null || active.isEmpty) return;
      for (final notification in active) {
        final payload = notification.payload;
        if (payload == null) continue;
        if (_isAutoRenewalPayload(payload)) continue;
        await _logNotificationLocal(
          title: notification.title ?? '',
          body: notification.body ?? '',
          type: payload.split(':').first,
          payload: payload,
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ logActiveNotifications failed: $e');
    }
  }

  /// ✅ إلغاء نطاق من الإشعارات
  // Future<void> cancelRange(int startId, int endId) async {
  //   debugPrint('🗑️ Cancelling notifications from $startId to $endId');

  //   for (int id = startId; id <= endId; id++) {
  //     await cancel(id);
  //   }

  //   debugPrint('✅ Cancelled ${endId - startId + 1} notifications');
  // }

  /// ✅ إلغاء نطاق من الإشعارات (المجدولة فعلياً فقط)
  Future<void> cancelRange(int startId, int endId) async {
    if (kDebugMode) {
      debugPrint('🗑️ Cancelling notifications in range $startId-$endId...');
    }

    // 1. جلب الإشعارات المجدولة فعلياً
    final pending = await getPendingNotifications();

    // 2. تصفية فقط الإشعارات في النطاق المحدد
    final toCancel = pending
        .where((n) => n.id >= startId && n.id <= endId)
        .toList();

    if (toCancel.isEmpty) {
      if (kDebugMode) {
        debugPrint('ℹ️ No notifications to cancel in this range');
      }
      return;
    }

    // 3. إلغاء فقط الإشعارات الموجودة (بدون طباعة لكل واحد)
    for (final notification in toCancel) {
      await _notifications.cancel(id: notification.id);
    }

    if (kDebugMode) {
      debugPrint('✅ Cancelled ${toCancel.length} notifications');
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
        // badge count is managed via MethodChannel (setAppBadge) — not per-notification
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
      debugPrint('⚠️ Sound file not found: $e');
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
    debugPrint('📋 Pending notifications (${pending.length}):');
    for (final n in pending) {
      debugPrint('  - ID: ${n.id}, Title: ${n.title}, Body: ${n.body}');
    }
  }
}
