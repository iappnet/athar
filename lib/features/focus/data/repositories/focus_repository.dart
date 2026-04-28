import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../models/focus_session.dart';

@lazySingleton
class FocusRepository {
  final Isar _isar;

  FocusRepository(this._isar);

  /// Saves a completed focus session.
  /// [durationSeconds] — actual elapsed seconds.
  /// [timePeriodIndex] — AtharTimePeriod.index at session start (nullable).
  Future<void> saveSession(int durationSeconds, {int? timePeriodIndex}) async {
    final now = DateTime.now();
    final session = FocusSession()
      ..startTime = now
      ..durationMinutes = (durationSeconds / 60).round()
      ..date = DateTime(now.year, now.month, now.day)
      ..isCompleted = true
      ..timePeriodIndex = timePeriodIndex;

    await _isar.writeTxn(() async {
      await _isar.focusSessions.put(session);
    });
  }

  /// Returns total focus minutes per day for the last [days] days (oldest → newest).
  Future<List<int>> getLast7DaysFocus() async {
    return _getDailyMinutes(7);
  }

  Future<List<int>> getDailyMinutes(int days) async {
    return _getDailyMinutes(days);
  }

  Future<List<int>> _getDailyMinutes(int days) async {
    final today = DateTime.now();
    final result = <int>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final sessions = await _isar.focusSessions
          .filter()
          .dateEqualTo(day)
          .findAll();
      result.add(sessions.fold(0, (sum, s) => sum + s.durationMinutes));
    }
    return result;
  }

  /// Total focus minutes in the last [days] days.
  Future<int> getTotalMinutes(int days) async {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final rangeStart = today.subtract(Duration(days: days - 1));
    final sessions = await _isar.focusSessions
        .filter()
        .dateBetween(rangeStart, today)
        .findAll();
    return sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Focus minutes just for today.
  Future<int> getTodayMinutes() async {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final sessions = await _isar.focusSessions
        .filter()
        .dateEqualTo(today)
        .findAll();
    return sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }
}
