import 'package:isar/isar.dart';

part 'focus_session.g.dart';

@collection
class FocusSession {
  Id id = Isar.autoIncrement;

  late DateTime startTime;
  late int durationMinutes;

  @Index()
  late DateTime date;

  bool isCompleted = true;

  // AtharTimePeriod.index — the Islamic time period when the session started.
  // null for sessions recorded before this field was added.
  int? timePeriodIndex;
}
