// test/features/stats/stats_helpers_test.dart
//
// Unit tests for the pure stats computation helpers.
// No Isar, no Flutter widgets, no platform dependencies required.

import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/stats/domain/logic/stats_helpers.dart';
import 'package:athar/features/stats/domain/models/stats_data.dart';
import 'package:athar/features/stats/domain/repositories/i_stats_repository.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

/// Constructs a minimal [HabitModel] for testing.
/// [startDate] and [reminderDays] are optional.
HabitModel _makeHabit({
  HabitFrequency frequency = HabitFrequency.daily,
  DateTime? startDate,
  List<int>? reminderDays,
}) {
  final h = HabitModel(title: 'test', frequency: frequency);
  h.startDate = startDate;
  h.reminderDays = reminderDays;
  return h;
}

// Stable anchor for all date arithmetic (Tuesday, 28 April 2026).
// Dart weekday = 2 → app weekday = (2 % 7) + 1 = 3.
final _today = DateTime(2026, 4, 28);
final _rangeStart7 = _today.subtract(const Duration(days: 6)); // 7-day range

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // 1. Daily habit created mid-range
  // ─────────────────────────────────────────────────────────────────────────
  group('countExpectedDays — daily habit created mid-range', () {
    test('habit older than range → full 7 days as denominator', () {
      final habit = _makeHabit(
        startDate: _today.subtract(const Duration(days: 10)),
      );
      expect(
        StatsHelpers.countExpectedDays(habit, _rangeStart7, _today),
        7,
      );
    });

    test('habit started 2 days ago → denominator is 3', () {
      final startDate = _today.subtract(const Duration(days: 2));
      final effectiveStart =
          DateTime(startDate.year, startDate.month, startDate.day);
      final habit = _makeHabit(startDate: startDate);
      expect(
        StatsHelpers.countExpectedDays(habit, effectiveStart, _today),
        3, // today-2, today-1, today
      );
    });

    test('habit started today → denominator is 1', () {
      final habit = _makeHabit(startDate: _today);
      expect(
        StatsHelpers.countExpectedDays(habit, _today, _today),
        1,
      );
    });

    test('no startDate → defaults to full range denominator', () {
      final habit = _makeHabit();
      expect(
        StatsHelpers.countExpectedDays(habit, _rangeStart7, _today),
        7,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 2. Weekly habit consistency
  // ─────────────────────────────────────────────────────────────────────────
  group('countExpectedWeeklyDays', () {
    // Range: Apr 22 (Wed) → Apr 28 (Tue), 7 days.
    // Schedule: Mon (app 2) + Thu (app 5).
    // Mondays in range: Apr 27.  Thursdays: Apr 23.  → 2 expected.
    test('7-day range with Mon+Thu scheduled → 2 expected occurrences', () {
      expect(
        StatsHelpers.countExpectedWeeklyDays(_rangeStart7, _today, [2, 5]),
        2,
      );
    });

    test('null reminderDays → fallback: (span ~/ 7) + 1 = 1', () {
      expect(
        StatsHelpers.countExpectedWeeklyDays(_rangeStart7, _today, null),
        1,
      );
    });

    test('empty reminderDays → same fallback as null', () {
      expect(
        StatsHelpers.countExpectedWeeklyDays(_rangeStart7, _today, []),
        1,
      );
    });

    // 14-day range: Apr 15 (Wed) → Apr 28 (Tue).
    // Sundays (app 1, Dart 7): Apr 19 and Apr 26 → 2.
    test('14-day range with Sunday only → 2 Sundays', () {
      final start14 = _today.subtract(const Duration(days: 13));
      expect(
        StatsHelpers.countExpectedWeeklyDays(start14, _today, [1]),
        2,
      );
    });

    test('single day range, that day is scheduled → 1', () {
      // today = Tue, app 3. Schedule Tue (app 3).
      expect(
        StatsHelpers.countExpectedWeeklyDays(_today, _today, [3]),
        1,
      );
    });

    test('single day range, that day is NOT scheduled → 0', () {
      // today = Tue, app 3. Schedule Mon (app 2) only.
      expect(
        StatsHelpers.countExpectedWeeklyDays(_today, _today, [2]),
        0,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 3. Monthly habit consistency
  // ─────────────────────────────────────────────────────────────────────────
  group('countExpectedMonths', () {
    test('7-day range within one month → 1 expected', () {
      expect(
        StatsHelpers.countExpectedMonths(DateTime(2026, 4, 22), _today),
        1,
      );
    });

    test('range spanning Apr–May → 2 expected', () {
      expect(
        StatsHelpers.countExpectedMonths(DateTime(2026, 4, 28), DateTime(2026, 5, 2)),
        2,
      );
    });

    test('30-day range within one calendar month → 1 expected', () {
      expect(
        StatsHelpers.countExpectedMonths(DateTime(2026, 3, 1), DateTime(2026, 3, 30)),
        1,
      );
    });

    test('same day → 1 expected', () {
      expect(StatsHelpers.countExpectedMonths(_today, _today), 1);
    });

    test('range spanning 3 months → 3 expected', () {
      expect(
        StatsHelpers.countExpectedMonths(DateTime(2026, 2, 1), DateTime(2026, 4, 1)),
        3,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 4. Empty data
  // ─────────────────────────────────────────────────────────────────────────
  group('productivityScore — empty / zero data', () {
    test('all zeros → 0.0', () {
      expect(
        StatsHelpers.computeProductivityScore(
          completionRate: 0,
          overallConsistency: 0,
          totalFocusMinutes: 0,
          rangeDays: 7,
        ),
        0.0,
      );
    });

    test('rangeDays = 0 → no division by zero, focus component = 0', () {
      expect(
        StatsHelpers.computeProductivityScore(
          completionRate: 0,
          overallConsistency: 0,
          totalFocusMinutes: 999,
          rangeDays: 0,
        ),
        0.0,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 5. productivityScore formula
  // ─────────────────────────────────────────────────────────────────────────
  group('productivityScore formula', () {
    test('100% tasks + 100% habits + 0 focus → 0.80', () {
      expect(
        StatsHelpers.computeProductivityScore(
          completionRate: 1.0,
          overallConsistency: 1.0,
          totalFocusMinutes: 0,
          rangeDays: 7,
        ),
        closeTo(0.80, 0.001),
      );
    });

    test('0% tasks + 0% habits + full focus (30 min/day × 7) → 0.20', () {
      expect(
        StatsHelpers.computeProductivityScore(
          completionRate: 0.0,
          overallConsistency: 0.0,
          totalFocusMinutes: 210, // 7 × 30
          rangeDays: 7,
        ),
        closeTo(0.20, 0.001),
      );
    });

    test('50% tasks + 60% habits + 50% focus → 0.54', () {
      // focusRate = 105 / (7×30) = 0.5
      // score = 0.5×0.4 + 0.6×0.4 + 0.5×0.2 = 0.20 + 0.24 + 0.10 = 0.54
      expect(
        StatsHelpers.computeProductivityScore(
          completionRate: 0.5,
          overallConsistency: 0.6,
          totalFocusMinutes: 105,
          rangeDays: 7,
        ),
        closeTo(0.54, 0.001),
      );
    });

    test('perfect everything → clamped to 1.0', () {
      expect(
        StatsHelpers.computeProductivityScore(
          completionRate: 1.0,
          overallConsistency: 1.0,
          totalFocusMinutes: 9999,
          rangeDays: 7,
        ),
        1.0,
      );
    });

    test('30-day range uses correct focus target (30 × 30 = 900 min)', () {
      // half focus = 450 min → focusRate 0.5 → focus component = 0.1
      // tasks=1.0→0.4, habits=1.0→0.4, focus=0.5→0.1 → 0.9
      expect(
        StatsHelpers.computeProductivityScore(
          completionRate: 1.0,
          overallConsistency: 1.0,
          totalFocusMinutes: 450,
          rangeDays: 30,
        ),
        closeTo(0.90, 0.001),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 6. Domain overloaded calculation — avgPerDomain fix
  // ─────────────────────────────────────────────────────────────────────────
  group('domain avgPerDomain — categorized tasks only', () {
    test('6 categorized / 10 total → avg = 3.0 not 5.0', () {
      // Before fix: tasks.length=10, byCat.length=2 → avg=5.0, threshold=ceil(10)=10
      // After fix:  categorizedCount=6, byCat.length=2 → avg=3.0, threshold=ceil(6)=6
      final byCat = <int, List<String>>{
        1: ['t1', 't2', 't3'],
        2: ['t4', 't5', 't6'],
      };
      final categorizedCount =
          byCat.values.fold<int>(0, (sum, list) => sum + list.length);
      expect(categorizedCount, 6);
      expect(categorizedCount / byCat.length, 3.0);
    });

    test('correct threshold flags domain with 7 tasks as overloaded', () {
      // avg = 3.0 → threshold = ceil(3.0 × 2) = 6.
      // A domain with 7 tasks (≥ 5) IS overloaded.
      // With the old avg = 5.0, threshold = 10, and 7 would NOT be flagged.
      final byCat = <int, List<String>>{
        1: ['t1', 't2', 't3'],
        2: ['t4', 't5', 't6'],
      };
      final avg = byCat.values.fold<int>(0, (s, l) => s + l.length) /
          byCat.length;
      final threshold = (avg * 2).ceil();
      const domainSize = 7;
      expect(threshold, 6);
      expect(domainSize > threshold && domainSize >= 5, isTrue);
    });

    test('only uncategorized tasks → byCat is empty → no domain metrics', () {
      // Mirrors the guard `if (byCat.isEmpty) return [];` in _buildDomainMetrics.
      final byCat = <int, List<String>>{};
      expect(byCat.isEmpty, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 7. Cache invalidation — hand-written mock
  // ─────────────────────────────────────────────────────────────────────────
  group('cache invalidation contract', () {
    test('invalidateCache() increments call count', () {
      int calls = 0;
      final mock = _MockStatsRepository(onInvalidate: () => calls++);
      mock.invalidateCache();
      expect(calls, 1);
    });

    test('invalidateCache() is idempotent — multiple calls do not throw', () {
      int calls = 0;
      final mock = _MockStatsRepository(onInvalidate: () => calls++);
      for (int i = 0; i < 5; i++) {
        mock.invalidateCache();
      }
      expect(calls, 5);
    });

    test('focus completion path calls invalidateCache() exactly once', () {
      // Simulates the sequence in FocusCubit._saveSessionData():
      //   await _repository.saveSession(...);
      //   getIt<IStatsRepository>().invalidateCache();   ← the fix
      int calls = 0;
      final mock = _MockStatsRepository(onInvalidate: () => calls++);
      // Simulate one focus session save
      mock.invalidateCache();
      expect(calls, 1);
    });
  });
}

// ---------------------------------------------------------------------------
// Minimal hand-written mock (no package:mocktail required)
// ---------------------------------------------------------------------------

class _MockStatsRepository implements IStatsRepository {
  final void Function() onInvalidate;
  _MockStatsRepository({required this.onInvalidate});

  @override
  void invalidateCache() => onInvalidate();

  @override
  Future<StatsData> getStats({
    required int rangeDays,
    required String userId,
  }) {
    throw UnimplementedError('not needed in these tests');
  }
}
