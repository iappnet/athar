import 'package:isar/isar.dart';

part 'notification_model.g.dart';

@collection
class NotificationModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid; // المعرف القادم من السحاب

  late String title;
  late String body;

  // نوع التنبيه (task, health, space_invite, habit)
  late String type;

  // بيانات إضافية للانتقال (مثل id المهمة أو id المساحة)
  String? payload;

  late DateTime createdAt;

  bool isRead = false;
  bool isSynced = false;

  NotificationModel();
}
