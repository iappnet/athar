import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../models/focus_session.dart';

@lazySingleton
class FocusRepository {
  final Isar _isar;

  FocusRepository(this._isar);

  // حفظ جلسة جديدة
  Future<void> saveSession(int durationSeconds) async {
    final now = DateTime.now();
    final session = FocusSession()
      ..startTime = now
      ..durationMinutes = (durationSeconds / 60).round()
      ..date =
          DateTime(now.year, now.month, now.day) // تصفير الوقت
      ..isCompleted = true;

    await _isar.writeTxn(() async {
      await _isar.focusSessions.put(session);
    });
  }

  // جلب مجموع دقائق التركيز لآخر 7 أيام (للشارت)
  Future<List<int>> getLast7DaysFocus() async {
    final today = DateTime.now();
    List<int> dailyMinutes = [];

    // نعود للوراء 6 أيام + اليوم الحالي = 7 أيام
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: i));

      // نجمع كل الجلسات التي حدثت في هذا اليوم
      final sessions = await _isar.focusSessions
          .filter()
          .dateEqualTo(day)
          .findAll();

      int totalMinutes = sessions.fold(
        0,
        (sum, item) => sum + item.durationMinutes,
      );
      dailyMinutes.add(totalMinutes);
    }

    return dailyMinutes;
  }
}
