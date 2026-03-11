import 'package:isar/isar.dart';

part 'focus_session.g.dart';

@collection
class FocusSession {
  Id id = Isar.autoIncrement;

  late DateTime startTime;
  late int durationMinutes; // مدة التركيز بالدقائق

  @Index() // للفهرسة السريعة عند البحث بالتاريخ
  late DateTime date; // تاريخ اليوم فقط (بدون وقت) للتجميع

  bool isCompleted = true; // هل أكمل الجلسة للنهاية أم أوقفها؟
}
