import 'package:athar/features/habits/data/models/habit_model.dart';

/// Pure, stateless computation helpers for the stats engine.
/// Extracted from [StatsRepositoryImpl] so they can be unit-tested
/// without an Isar database.
///
/// All methods are static and free of side-effects.
class StatsHelpers {
  StatsHelpers._();

  // ── Expected-day helpers ─────────────────────────────────────────────────

  /// Returns the number of expected completions for [habit] in
  /// [[start], [end]] inclusive.
  ///
  /// [start] must already be the effective start date
  /// (i.e. max(rangeStart, habit.startDate)) — callers are responsible
  /// for clamping before passing it here.
  static int countExpectedDays(
    HabitModel habit,
    DateTime start,
    DateTime end,
  ) {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return end.difference(start).inDays + 1;
      case HabitFrequency.weekly:
        return countExpectedWeeklyDays(start, end, habit.reminderDays);
      case HabitFrequency.monthly:
        return countExpectedMonths(start, end);
    }
  }

  /// Counts days in [[start], [end]] whose app-convention weekday appears in
  /// [reminderDays].
  ///
  /// App convention (matches [HabitModel.reminderDays] comments):
  ///   1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday,
  ///   5=Thursday, 6=Friday, 7=Saturday.
  ///
  /// Dart [DateTime.weekday]: 1=Monday … 7=Sunday.
  /// Conversion: appWeekday = (dartWeekday % 7) + 1.
  ///
  /// Falls back to ⌊span / 7⌋ + 1 when [reminderDays] is null or empty
  /// (one occurrence per week as a conservative default).
  static int countExpectedWeeklyDays(
    DateTime start,
    DateTime end,
    List<int>? reminderDays,
  ) {
    final span = end.difference(start).inDays;
    if (reminderDays == null || reminderDays.isEmpty) {
      return (span ~/ 7) + 1;
    }
    int count = 0;
    for (int i = 0; i <= span; i++) {
      final day = start.add(Duration(days: i));
      final appWeekday = (day.weekday % 7) + 1;
      if (reminderDays.contains(appWeekday)) count++;
    }
    return count;
  }

  /// Counts distinct calendar months that have at least one day in
  /// [[start], [end]] inclusive.
  ///
  /// Example: start=2026-04-25, end=2026-05-02 → 2 months.
  static int countExpectedMonths(DateTime start, DateTime end) {
    int count = 0;
    var cursor = DateTime(start.year, start.month);
    final endMonth = DateTime(end.year, end.month);
    while (!cursor.isAfter(endMonth)) {
      count++;
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return count;
  }

  // ── Score helpers ────────────────────────────────────────────────────────

  /// Productivity score (0.0–1.0):
  ///   40% task completion rate + 40% habit consistency +
  ///   20% focus (target = 30 min/day).
  static double computeProductivityScore({
    required double completionRate,
    required double overallConsistency,
    required int totalFocusMinutes,
    required int rangeDays,
  }) {
    final focusTarget = rangeDays * 30.0;
    final focusRate = focusTarget == 0
        ? 0.0
        : (totalFocusMinutes / focusTarget).clamp(0.0, 1.0);
    return (completionRate * 0.4 + overallConsistency * 0.4 + focusRate * 0.2)
        .clamp(0.0, 1.0);
  }
}
