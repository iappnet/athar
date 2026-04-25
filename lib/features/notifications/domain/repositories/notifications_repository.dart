import 'package:athar/features/notifications/data/models/notification_model.dart';

abstract class NotificationsRepository {
  /// مراقبة التنبيهات بشكل حي
  Stream<List<NotificationModel>> watchNotifications();

  /// جلب التنبيهات من السحاب وتحديث الكاش
  Future<void> syncNotifications();

  /// تمييز تنبيه كمقروء
  Future<void> markAsRead(String uuid);

  /// تمييز جميع التنبيهات كمقروءة
  Future<void> markAllAsRead();

  /// مسح كافة التنبيهات
  Future<void> clearAll();

  /// تسجيل تنبيه جديد (لوج داخلي)
  Future<void> logNotification({
    required String title,
    required String body,
    required String type,
    String? payload,
  });
}
