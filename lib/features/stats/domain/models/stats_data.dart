import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root container
// ─────────────────────────────────────────────────────────────────────────────

class StatsData {
  final TaskMetrics tasks;
  final HabitMetrics habits;
  final FocusMetrics focus;
  final List<PeriodMetric> periods;
  final List<DomainMetric> domains;
  final List<StatsInsight> insights;
  final int rangeDays;
  final DateTime computedAt;

  /// Composite score (0.0–1.0): 40% task completion + 40% habit consistency
  /// + 20% focus (target = 30 min/day).
  final double productivityScore;

  /// Days in range where the user completed at least one task or habit,
  /// divided by rangeDays. Measures daily engagement breadth.
  final double consistencyScore;

  /// Average ratio of currentStreak / longestStreak across all habits that
  /// have ever had a streak. Rewards building toward personal records.
  final double streakQuality;

  const StatsData({
    required this.tasks,
    required this.habits,
    required this.focus,
    required this.periods,
    required this.domains,
    required this.insights,
    required this.rangeDays,
    required this.computedAt,
    required this.productivityScore,
    required this.consistencyScore,
    required this.streakQuality,
  });

  static StatsData empty(int rangeDays) => StatsData(
        tasks: TaskMetrics.empty(),
        habits: HabitMetrics.empty(),
        focus: FocusMetrics.empty(rangeDays),
        periods: [],
        domains: [],
        insights: [],
        rangeDays: rangeDays,
        computedAt: DateTime.now(),
        productivityScore: 0,
        consistencyScore: 0,
        streakQuality: 0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Task metrics
// ─────────────────────────────────────────────────────────────────────────────

class TaskMetrics {
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final int totalToday;
  final int completedToday;
  final int focusMinutesToday;

  /// priority name → count
  final Map<String, int> completedByPriority;
  final Map<String, int> totalByPriority;

  /// One entry per day oldest → newest
  final List<DailyTaskCount> dailyCounts;

  final double avgDelayDays;

  const TaskMetrics({
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.totalToday,
    required this.completedToday,
    required this.focusMinutesToday,
    required this.completedByPriority,
    required this.totalByPriority,
    required this.dailyCounts,
    required this.avgDelayDays,
  });

  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  double get overdueRate =>
      totalTasks == 0 ? 0 : overdueTasks / totalTasks;

  bool get hasEnoughData => totalTasks >= 5;

  factory TaskMetrics.empty() => const TaskMetrics(
        totalTasks: 0,
        completedTasks: 0,
        overdueTasks: 0,
        totalToday: 0,
        completedToday: 0,
        focusMinutesToday: 0,
        completedByPriority: {},
        totalByPriority: {},
        dailyCounts: [],
        avgDelayDays: 0,
      );
}

class DailyTaskCount {
  final DateTime date;
  final int total;
  final int completed;

  const DailyTaskCount({
    required this.date,
    required this.total,
    required this.completed,
  });

  double get rate => total == 0 ? 0 : completed / total;
}

// ─────────────────────────────────────────────────────────────────────────────
// Habit metrics
// ─────────────────────────────────────────────────────────────────────────────

class HabitMetrics {
  final int totalHabits;
  final int completedToday;
  final int totalToday;
  final double overallConsistency;

  /// Top 3 habits by streak for display
  final List<HabitStreakItem> topStreaks;

  /// Full per-habit consistency list
  final List<HabitConsistency> byHabit;

  /// Date → count of habits completed that day (for heatmap)
  final Map<DateTime, int> heatmapData;

  const HabitMetrics({
    required this.totalHabits,
    required this.completedToday,
    required this.totalToday,
    required this.overallConsistency,
    required this.topStreaks,
    required this.byHabit,
    required this.heatmapData,
  });

  bool get hasEnoughData => totalHabits >= 3;

  factory HabitMetrics.empty() => const HabitMetrics(
        totalHabits: 0,
        completedToday: 0,
        totalToday: 0,
        overallConsistency: 0,
        topStreaks: [],
        byHabit: [],
        heatmapData: {},
      );
}

class HabitStreakItem {
  final String title;
  final int currentStreak;
  final int longestStreak;
  final String iconKey;
  final int colorValue;

  const HabitStreakItem({
    required this.title,
    required this.currentStreak,
    required this.longestStreak,
    required this.iconKey,
    required this.colorValue,
  });
}

class HabitConsistency {
  final String title;
  final double consistencyRate;
  final int currentStreak;
  final String iconKey;
  final int colorValue;

  const HabitConsistency({
    required this.title,
    required this.consistencyRate,
    required this.currentStreak,
    required this.iconKey,
    required this.colorValue,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Focus metrics
// ─────────────────────────────────────────────────────────────────────────────

class FocusMetrics {
  final int totalMinutes;
  final int previousRangeMinutes;
  final List<int> dailyMinutes;
  final int todayMinutes;

  /// Focus minutes aggregated by Islamic time period.
  /// Keyed by AtharTimePeriod; periods with zero minutes are absent.
  /// Populated from FocusSession.timePeriodIndex; sessions recorded before
  /// that field existed contribute nothing (timePeriodIndex == null).
  final Map<AtharTimePeriod, int> minutesByPeriod;

  const FocusMetrics({
    required this.totalMinutes,
    required this.previousRangeMinutes,
    required this.dailyMinutes,
    required this.todayMinutes,
    required this.minutesByPeriod,
  });

  double get weekOverWeekChange {
    if (previousRangeMinutes == 0) return 0;
    return (totalMinutes - previousRangeMinutes) / previousRangeMinutes;
  }

  bool get hasEnoughData => totalMinutes > 0;

  factory FocusMetrics.empty(int days) => FocusMetrics(
        totalMinutes: 0,
        previousRangeMinutes: 0,
        dailyMinutes: List.filled(days, 0),
        todayMinutes: 0,
        minutesByPeriod: const {},
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-period metric (Islamic time periods)
// ─────────────────────────────────────────────────────────────────────────────

class PeriodMetric {
  final AtharTimePeriod period;
  final String labelAr;
  final String labelEn;
  final int completedTasks;
  final int totalTasks;

  const PeriodMetric({
    required this.period,
    required this.labelAr,
    required this.labelEn,
    required this.completedTasks,
    required this.totalTasks,
  });

  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  bool get hasData => totalTasks > 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-domain (category) metric
// ─────────────────────────────────────────────────────────────────────────────

class DomainMetric {
  final int categoryId;
  final String name;
  final int colorValue;
  final String iconKey;
  final int completedTasks;
  final int totalTasks;
  final bool isNeglected;
  final bool isOverloaded;

  const DomainMetric({
    required this.categoryId,
    required this.name,
    required this.colorValue,
    required this.iconKey,
    required this.completedTasks,
    required this.totalTasks,
    required this.isNeglected,
    required this.isOverloaded,
  });

  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;
}

// ─────────────────────────────────────────────────────────────────────────────
// Insight card
// ─────────────────────────────────────────────────────────────────────────────

enum InsightType { positive, warning, neutral }

class StatsInsight {
  final String messageAr;
  final String messageEn;
  final IconData icon;
  final InsightType type;

  const StatsInsight({
    required this.messageAr,
    required this.messageEn,
    required this.icon,
    required this.type,
  });
}
