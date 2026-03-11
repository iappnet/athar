import 'dart:io';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_notification_service.dart';

/// ✅ معالجة الرسائل في الخلفية (يجب أن تكون top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // ملاحظة: لا نضع طباعة هنا في الإنتاج إلا للضرورة
}

/// ✅ خدمة Firebase Cloud Messaging
@lazySingleton
class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService;
  final SupabaseClient _supabase = Supabase.instance.client;

  FCMService(this._localNotificationService);

  String? _fcmToken;

  /// ✅ الحصول على FCM Token الحالي
  String? get fcmToken => _fcmToken;

  // ═══════════════════════════════════════════════════════════
  // 🎬 INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  Future<void> init() async {
    try {
      // 1. طلب الأذونات
      await _requestPermissions();

      // 2. الحصول على Token الأولي
      _fcmToken = await _fcm.getToken();
      if (kDebugMode) print('✅ FCM Token Initial: $_fcmToken');

      // 3. ✅ تحديث التوكن تلقائياً عند التغيير (onTokenRefresh)
      _fcm.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        if (kDebugMode) print('🔄 FCM Token Refreshed: $newToken');

        final authCubit = getIt<AuthCubit>();
        final state = authCubit.state;

        // ✅ الإصلاح: استخدام الحقل 'username' المتاح في الحالة
        if (state is AuthAuthenticated) {
          final userId = state.username; // في مشروعك username يمثل الـ ID
          await saveFCMTokenToSupabase(userId);
        }
      });

      // 4. إعداد معالجات الرسائل
      _setupMessageHandlers();

      if (kDebugMode) print('✅ FCMService initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Error initializing FCMService: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📨 MESSAGE HANDLERS
  // ═══════════════════════════════════════════════════════════

  void _setupMessageHandlers() {
    // التطبيق مفتوح
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // النقر على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // فتح التطبيق من إشعار وهو مغلق تماماً
    _fcm.getInitialMessage().then((message) {
      if (message != null) _handleMessageOpened(message);
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await _localNotificationService.showNow(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: notification.title ?? 'تنبيه جديد',
        body: notification.body ?? '',
        category: _getCategoryFromData(message.data),
        payload: message.data['type'], // تمرير النوع كـ payload للتنقل
      );
    }
  }

  void _handleMessageOpened(RemoteMessage message) {
    final data = message.data;
    if (kDebugMode) print('📱 App opened via notification with data: $data');
    // هنا يتم استدعاء منطق التنقل (Navigator) بناءً على data['type']
  }

  NotificationCategory _getCategoryFromData(Map<String, dynamic> data) {
    final type = data['type']?.toString().toLowerCase();
    switch (type) {
      case 'prayer':
        return NotificationCategory.prayer;
      case 'medication':
        return NotificationCategory.medication;
      case 'task':
        return NotificationCategory.task;
      default:
        return NotificationCategory.general;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 💾 SUPABASE INTEGRATION
  // ═══════════════════════════════════════════════════════════

  /// ✅ حفظ أو تحديث التوكن في جدول الـ profiles
  Future<void> saveFCMTokenToSupabase(String userId) async {
    if (_fcmToken == null) return;

    try {
      // نقوم بتحديث حقل fcm_token في جدول البروفايل الخاص بالمستخدم
      await _supabase
          .from('profiles')
          .update({
            'fcm_token': _fcmToken,
            'last_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      if (kDebugMode) print('💾 FCM Token synced for user: $userId');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to sync FCM Token: $e');
    }
  }

  /// ✅ حذف التوكن عند تسجيل الخروج لمنع وصول إشعارات لمستخدم قديم
  Future<void> deleteFCMTokenFromSupabase(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .update({'fcm_token': null})
          .eq('id', userId);
      if (kDebugMode) print('🗑️ FCM Token cleared from Supabase');
    } catch (e) {
      if (kDebugMode) print('❌ Error clearing FCM Token: $e');
    }
  }
}
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:injectable/injectable.dart';
// import 'local_notification_service.dart';

// /// ✅ معالجة الرسائل في الخلفية (يجب أن تكون top-level function)
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('📨 Background message: ${message.messageId}');
//   // يمكن عرض إشعار محلي هنا
// }

// /// ✅ خدمة Firebase Cloud Messaging
// @lazySingleton
// class FCMService {
//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   final LocalNotificationService _localNotificationService;

//   FCMService(this._localNotificationService);

//   String? _fcmToken;

//   /// ✅ الحصول على FCM Token
//   String? get fcmToken => _fcmToken;

//   // ═══════════════════════════════════════════════════════════
//   // 🎬 INITIALIZATION
//   // ═══════════════════════════════════════════════════════════

//   /// ✅ التهيئة الأولية
//   Future<void> init() async {
//     try {
//       // 1. طلب الأذونات (iOS)
//       await _requestPermissions();

//       // 2. الحصول على FCM Token
//       _fcmToken = await _fcm.getToken();
//       print('✅ FCM Token: $_fcmToken');

//       // 3. الاستماع لتغييرات Token
//       _fcm.onTokenRefresh.listen((newToken) {
//         _fcmToken = newToken;
//         print('🔄 FCM Token refreshed: $newToken');
//         // TODO: حفظ Token الجديد في Supabase
//       });

//       // 4. معالجة الرسائل
//       _setupMessageHandlers();

//       print('✅ FCMService initialized');
//     } catch (e, stackTrace) {
//       print('❌ Error initializing FCMService: $e');
//       print('Stack trace: $stackTrace');
//     }
//   }

//   /// ✅ طلب الأذونات (iOS)
//   Future<void> _requestPermissions() async {
//     if (Platform.isIOS) {
//       NotificationSettings settings = await _fcm.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );

//       print('📱 iOS FCM Permission: ${settings.authorizationStatus}');
//     }
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 📨 MESSAGE HANDLERS
//   // ═══════════════════════════════════════════════════════════

//   /// ✅ إعداد معالجات الرسائل
//   void _setupMessageHandlers() {
//     // 1. Foreground Messages (التطبيق مفتوح)
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

//     // 2. Background Messages (التطبيق في الخلفية)
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//     // 3. Notification Opened (عند النقر على الإشعار)
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

//     // 4. Initial Message (إذا فُتح التطبيق من إشعار)
//     _fcm.getInitialMessage().then((message) {
//       if (message != null) {
//         _handleMessageOpened(message);
//       }
//     });
//   }

//   /// ✅ معالجة رسالة في Foreground
//   Future<void> _handleForegroundMessage(RemoteMessage message) async {
//     print('📨 Foreground message: ${message.messageId}');

//     final notification = message.notification;
//     final data = message.data;

//     if (notification != null) {
//       // عرض إشعار محلي
//       await _localNotificationService.showNow(
//         id: DateTime.now().millisecondsSinceEpoch % 100000,
//         title: notification.title ?? 'إشعار جديد',
//         body: notification.body ?? '',
//         category: _getCategoryFromData(data),
//         payload: data['payload'],
//       );
//     }
//   }

//   /// ✅ معالجة النقر على الإشعار
//   void _handleMessageOpened(RemoteMessage message) {
//     print('📱 Message opened: ${message.messageId}');

//     final data = message.data;

//     // TODO: التنقل حسب نوع الإشعار
//     if (data['type'] == 'prayer') {
//       // navigatorKey.currentState?.pushNamed('/prayer');
//     } else if (data['type'] == 'medication') {
//       // navigatorKey.currentState?.pushNamed('/medications');
//     }
//   }

//   /// ✅ تحديد الفئة من البيانات
//   NotificationCategory _getCategoryFromData(Map<String, dynamic> data) {
//     final type = data['type']?.toString().toLowerCase();

//     switch (type) {
//       case 'prayer':
//         return NotificationCategory.prayer;
//       case 'medication':
//         return NotificationCategory.medication;
//       case 'task':
//         return NotificationCategory.task;
//       case 'habit':
//         return NotificationCategory.habit;
//       default:
//         return NotificationCategory.general;
//     }
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 📢 TOPICS
//   // ═══════════════════════════════════════════════════════════

//   /// ✅ الاشتراك في Topic
//   Future<void> subscribeToTopic(String topic) async {
//     try {
//       await _fcm.subscribeToTopic(topic);
//       print('✅ Subscribed to topic: $topic');
//     } catch (e) {
//       print('❌ Error subscribing to topic: $e');
//     }
//   }

//   /// ✅ إلغاء الاشتراك من Topic
//   Future<void> unsubscribeFromTopic(String topic) async {
//     try {
//       await _fcm.unsubscribeFromTopic(topic);
//       print('✅ Unsubscribed from topic: $topic');
//     } catch (e) {
//       print('❌ Error unsubscribing from topic: $e');
//     }
//   }

//   // ═══════════════════════════════════════════════════════════
//   // 🔧 UTILITIES
//   // ═══════════════════════════════════════════════════════════

//   /// ✅ حفظ FCM Token في Supabase
//   Future<void> saveFCMTokenToSupabase(String userId) async {
//     if (_fcmToken == null) return;

//     // TODO: حفظ في Supabase
//     // await _supabase.from('user_fcm_tokens').upsert({
//     //   'user_id': userId,
//     //   'token': _fcmToken,
//     //   'platform': Platform.isIOS ? 'ios' : 'android',
//     //   'updated_at': DateTime.now().toIso8601String(),
//     // });

//     print('💾 FCM Token saved to Supabase');
//   }

//   /// ✅ حذف FCM Token من Supabase (عند تسجيل الخروج)
//   Future<void> deleteFCMTokenFromSupabase(String userId) async {
//     // TODO: حذف من Supabase
//     // await _supabase
//     //     .from('user_fcm_tokens')
//     //     .delete()
//     //     .eq('user_id', userId)
//     //     .eq('token', _fcmToken);

//     print('🗑️ FCM Token deleted from Supabase');
//   }
// }
