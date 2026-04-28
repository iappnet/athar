import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:athar/features/focus/data/models/focus_session.dart';
import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/settings/data/models/category_model.dart';
import 'package:athar/features/stats/domain/logic/stats_helpers.dart';
import 'package:athar/features/stats/domain/models/stats_data.dart';
import 'package:athar/features/stats/domain/repositories/i_stats_repository.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

@LazySingleton(as: IStatsRepository)
class StatsRepositoryImpl implements IStatsRepository {
  final Isar _isar;

  StatsRepositoryImpl(this._isar);

  // ── TTL cache ──────────────────────────────────────────────────────────────
  // Key: "$userId-$rangeDays". Invalidated automatically after 5 minutes.
  // Stats computations are CPU-light but do multiple sequential Isar queries;
  // caching avoids redundant work when the user switches tabs and returns.
  final Map<String, ({StatsData data, DateTime at})> _cache = {};
  static const Duration _cacheTTL = Duration(minutes: 5);

  static const Map<AtharTimePeriod, ({String ar, String en})> _periodLabels = {
    AtharTimePeriod.dawn: (ar: 'الفجر', en: 'Dawn'),
    AtharTimePeriod.bakur: (ar: 'البكور', en: 'Bakur'),
    AtharTimePeriod.duha: (ar: 'الضحى', en: 'Duha'),
    AtharTimePeriod.morning: (ar: 'الصباح', en: 'Morning'),
    AtharTimePeriod.noon: (ar: 'الظهيرة', en: 'Noon'),
    AtharTimePeriod.afternoon: (ar: 'العصر', en: 'Afternoon'),
    AtharTimePeriod.maghrib: (ar: 'المغرب', en: 'Maghrib'),
    AtharTimePeriod.isha: (ar: 'العشاء', en: 'Isha'),
    AtharTimePeriod.night: (ar: 'الليل', en: 'Night'),
    AtharTimePeriod.lastThird: (ar: 'الثلث الأخير', en: 'Last Third'),
    AtharTimePeriod.undefined: (ar: 'غير محدد', en: 'Unspecified'),
  };

  static const List<AtharTimePeriod> _chronologicalPeriods = [
    AtharTimePeriod.dawn,
    AtharTimePeriod.bakur,
    AtharTimePeriod.duha,
    AtharTimePeriod.morning,
    AtharTimePeriod.noon,
    AtharTimePeriod.afternoon,
    AtharTimePeriod.maghrib,
    AtharTimePeriod.isha,
    AtharTimePeriod.night,
    AtharTimePeriod.lastThird,
    AtharTimePeriod.undefined,
  ];

  @override
  void invalidateCache() => _cache.clear();

  @override
  Future<StatsData> getStats({
    required int rangeDays,
    required String userId,
  }) async {
    // ── Cache check ────────────────────────────────────────────
    final cacheKey = '$userId-$rangeDays';
    final cached = _cache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.at) < _cacheTTL) {
      return cached.data;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rangeStart = today.subtract(Duration(days: rangeDays - 1));

    // Previous range boundaries (for focus week-over-week)
    final prevEnd = rangeStart.subtract(const Duration(days: 1));
    final prevStart = prevEnd.subtract(Duration(days: rangeDays - 1));

    // Parallel Isar queries.
    // FIX(focus-safety): filter isCompleted=true so any future partial session
    // writes cannot inflate focus totals.
    final tasksFuture = _fetchTasks(userId, rangeStart, today);
    final habitsFuture = _fetchHabits(userId);
    final categoriesFuture = _isar.categoryModels.where().findAll();
    final currFocusFuture = _isar.focusSessions
        .filter()
        .isCompletedEqualTo(true)
        .and()
        .dateBetween(rangeStart, today)
        .findAll();
    final prevFocusFuture = _isar.focusSessions
        .filter()
        .isCompletedEqualTo(true)
        .and()
        .dateBetween(prevStart, prevEnd)
        .findAll();

    final rawTasks = await tasksFuture;
    final habits = await habitsFuture;
    final categories = await categoriesFuture;
    final currFocusSessions = await currFocusFuture;
    final prevFocusSessions = await prevFocusFuture;

    // Filter sample data out
    final tasks = rawTasks.where((t) => !t.isSampleData).toList();

    final categoryMap = {for (final c in categories) c.id: c};

    // Load habit → category links (small N, acceptable N+1)
    for (final habit in habits) {
      await habit.category.load();
    }

    // ── Focus metrics ──────────────────────────────────────────
    final Map<int, int> focusByDayKey = {};
    for (final s in currFocusSessions) {
      final dayKey = DateTime(s.date.year, s.date.month, s.date.day)
          .millisecondsSinceEpoch;
      focusByDayKey[dayKey] = (focusByDayKey[dayKey] ?? 0) + s.durationMinutes;
    }

    final dailyFocusMinutes = [
      for (int i = rangeDays - 1; i >= 0; i--)
        focusByDayKey[
                today.subtract(Duration(days: i)).millisecondsSinceEpoch] ??
            0,
    ];
    final todayFocusMinutes =
        focusByDayKey[today.millisecondsSinceEpoch] ?? 0;
    final totalFocusMinutes =
        dailyFocusMinutes.fold<int>(0, (s, m) => s + m);
    final prevFocusMinutes = prevFocusSessions.fold<int>(
        0, (s, sess) => s + sess.durationMinutes);

    // ── Build sections ─────────────────────────────────────────
    final taskMetrics = _buildTaskMetrics(
      tasks,
      today,
      rangeStart,
      rangeDays,
      todayFocusMinutes,
    );
    final habitMetrics = _buildHabitMetrics(habits, today, rangeStart, rangeDays);
    final focusMetrics = FocusMetrics(
      totalMinutes: totalFocusMinutes,
      previousRangeMinutes: prevFocusMinutes,
      dailyMinutes: dailyFocusMinutes,
      todayMinutes: todayFocusMinutes,
      minutesByPeriod: _buildFocusByPeriod(currFocusSessions),
    );
    final periodMetrics = _buildPeriodMetrics(tasks);
    final domainMetrics = _buildDomainMetrics(tasks, categoryMap);
    final insights = _generateInsights(
      taskMetrics,
      habitMetrics,
      focusMetrics,
      periodMetrics,
      domainMetrics,
    );

    // ── Derived composite scores ───────────────────────────────
    final productivityScore =
        _computeProductivityScore(taskMetrics, habitMetrics, focusMetrics, rangeDays);
    final consistencyScore =
        _computeConsistencyScore(tasks, habits, today, rangeDays);
    final streakQuality = _computeStreakQuality(habits);

    final result = StatsData(
      tasks: taskMetrics,
      habits: habitMetrics,
      focus: focusMetrics,
      periods: periodMetrics,
      domains: domainMetrics,
      insights: insights,
      rangeDays: rangeDays,
      computedAt: now,
      productivityScore: productivityScore,
      consistencyScore: consistencyScore,
      streakQuality: streakQuality,
    );

    // ── Cache store ────────────────────────────────────────────
    _cache[cacheKey] = (data: result, at: DateTime.now());

    return result;
  }

  // ── Isar fetch helpers ─────────────────────────────────────────────────────

  Future<List<TaskModel>> _fetchTasks(
    String userId,
    DateTime rangeStart,
    DateTime today,
  ) {
    if (userId.isEmpty) {
      return _isar.taskModels
          .filter()
          .dateBetween(rangeStart, today)
          .and()
          .deletedAtIsNull()
          .findAll();
    }
    return _isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .and()
        .dateBetween(rangeStart, today)
        .and()
        .deletedAtIsNull()
        .findAll();
  }

  Future<List<HabitModel>> _fetchHabits(String userId) {
    if (userId.isEmpty) {
      return _isar.habitModels.filter().deletedAtIsNull().findAll();
    }
    return _isar.habitModels
        .filter()
        .userIdEqualTo(userId)
        .and()
        .deletedAtIsNull()
        .findAll();
  }

  // ── TaskMetrics ────────────────────────────────────────────────────────────

  TaskMetrics _buildTaskMetrics(
    List<TaskModel> tasks,
    DateTime today,
    DateTime rangeStart,
    int rangeDays,
    int todayFocusMinutes,
  ) {
    final todayTasks = tasks.where((t) => _sameDay(t.date, today)).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();
    final overdue =
        tasks.where((t) => !t.isCompleted && t.date.isBefore(today)).toList();

    final Map<String, int> completedByPriority = {};
    final Map<String, int> totalByPriority = {};
    for (final task in tasks) {
      final key = task.priority.name;
      totalByPriority[key] = (totalByPriority[key] ?? 0) + 1;
      if (task.isCompleted) {
        completedByPriority[key] = (completedByPriority[key] ?? 0) + 1;
      }
    }

    final dailyCounts = [
      for (int i = rangeDays - 1; i >= 0; i--)
        _dailyCount(tasks, today.subtract(Duration(days: i))),
    ];

    // Average delay for tasks that were completed late
    final lateTasks = completed.where(
      (t) => t.completedAt != null && t.completedAt!.isAfter(t.date),
    );
    final avgDelayDays = lateTasks.isEmpty
        ? 0.0
        : lateTasks
                .map((t) =>
                    t.completedAt!.difference(t.date).inDays.toDouble())
                .reduce((a, b) => a + b) /
            lateTasks.length;

    return TaskMetrics(
      totalTasks: tasks.length,
      completedTasks: completed.length,
      overdueTasks: overdue.length,
      totalToday: todayTasks.length,
      completedToday: todayTasks.where((t) => t.isCompleted).length,
      focusMinutesToday: todayFocusMinutes,
      completedByPriority: completedByPriority,
      totalByPriority: totalByPriority,
      dailyCounts: dailyCounts,
      avgDelayDays: avgDelayDays,
    );
  }

  DailyTaskCount _dailyCount(List<TaskModel> tasks, DateTime day) {
    final dayTasks = tasks.where((t) => _sameDay(t.date, day)).toList();
    return DailyTaskCount(
      date: day,
      total: dayTasks.length,
      completed: dayTasks.where((t) => t.isCompleted).length,
    );
  }

  // ── HabitMetrics ───────────────────────────────────────────────────────────

  HabitMetrics _buildHabitMetrics(
    List<HabitModel> habits,
    DateTime today,
    DateTime rangeStart,
    int rangeDays,
  ) {
    if (habits.isEmpty) return HabitMetrics.empty();

    final dailyHabits =
        habits.where((h) => h.frequency == HabitFrequency.daily).toList();

    final completedToday = dailyHabits
        .where((h) => h.completedDays.any((d) => _sameDay(d, today)))
        .length;

    // Heatmap and per-habit consistency in one pass.
    //
    // FIX(habit-consistency): Three bugs corrected here:
    //   1. effectiveStart = max(rangeStart, habit.startDate) so newly created
    //      habits are not penalised for days before they existed.
    //   2. Non-daily habits (weekly, monthly) are now included in the average
    //      using StatsHelpers.countExpectedDays for the correct denominator.
    //   3. Non-scheduled days are never in the denominator — only the expected
    //      occurrences for the habit's own frequency are counted.
    final Map<DateTime, int> heatmap = {};
    final consistencies = <double>[];

    for (final habit in habits) {
      final effectiveStart = _effectiveRangeStart(habit, rangeStart);

      int daysInRange = 0;
      for (final d in habit.completedDays) {
        final day = DateTime(d.year, d.month, d.day);
        if (!day.isBefore(effectiveStart) && !day.isAfter(today)) {
          daysInRange++;
          heatmap[day] = (heatmap[day] ?? 0) + 1;
        }
      }

      final expected =
          StatsHelpers.countExpectedDays(habit, effectiveStart, today);
      if (expected > 0) {
        consistencies.add((daysInRange / expected).clamp(0.0, 1.0));
      }
    }

    final overallConsistency = consistencies.isEmpty
        ? 0.0
        : consistencies.fold(0.0, (a, b) => a + b) / consistencies.length;

    final sorted = [...habits]
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

    final topStreaks = sorted.take(3).map((h) {
      final colorValue = h.category.value?.colorValue ?? 0xFF10B981;
      return HabitStreakItem(
        title: h.title,
        currentStreak: h.currentStreak,
        longestStreak: h.longestStreak,
        iconKey: h.icon ?? 'check_circle',
        colorValue: colorValue,
      );
    }).toList();

    final byHabit = habits.map((h) {
      final effectiveStart = _effectiveRangeStart(h, rangeStart);
      final daysInRange = h.completedDays.where((d) {
        final day = DateTime(d.year, d.month, d.day);
        return !day.isBefore(effectiveStart) && !day.isAfter(today);
      }).length;
      final expected =
          StatsHelpers.countExpectedDays(h, effectiveStart, today);
      final consistencyRate =
          expected > 0 ? (daysInRange / expected).clamp(0.0, 1.0) : 0.0;
      return HabitConsistency(
        title: h.title,
        consistencyRate: consistencyRate,
        currentStreak: h.currentStreak,
        iconKey: h.icon ?? 'check_circle',
        colorValue: h.category.value?.colorValue ?? 0xFF10B981,
      );
    }).toList();

    return HabitMetrics(
      totalHabits: habits.length,
      completedToday: completedToday,
      totalToday: dailyHabits.length,
      overallConsistency: overallConsistency,
      topStreaks: topStreaks,
      byHabit: byHabit,
      heatmapData: heatmap,
    );
  }

  /// Returns the effective range start for [habit]:
  /// the later of [rangeStart] and [HabitModel.startDate] (midnight-normalised).
  /// Prevents penalising habits for days before they were created.
  DateTime _effectiveRangeStart(HabitModel habit, DateTime rangeStart) {
    if (habit.startDate == null) return rangeStart;
    final sd = DateTime(
      habit.startDate!.year,
      habit.startDate!.month,
      habit.startDate!.day,
    );
    return sd.isAfter(rangeStart) ? sd : rangeStart;
  }

  // ── PeriodMetrics ──────────────────────────────────────────────────────────

  List<PeriodMetric> _buildPeriodMetrics(List<TaskModel> tasks) {
    final Map<AtharTimePeriod, List<TaskModel>> byPeriod = {};
    for (final task in tasks) {
      final period = task.timePeriod ?? AtharTimePeriod.undefined;
      byPeriod.putIfAbsent(period, () => []).add(task);
    }

    return _chronologicalPeriods
        .where(byPeriod.containsKey)
        .map((p) {
          final periodTasks = byPeriod[p]!;
          final labels = _periodLabels[p]!;
          return PeriodMetric(
            period: p,
            labelAr: labels.ar,
            labelEn: labels.en,
            completedTasks: periodTasks.where((t) => t.isCompleted).length,
            totalTasks: periodTasks.length,
          );
        })
        .toList();
  }

  // ── DomainMetrics ──────────────────────────────────────────────────────────

  List<DomainMetric> _buildDomainMetrics(
    List<TaskModel> tasks,
    Map<int, CategoryModel> categoryMap,
  ) {
    final Map<int, List<TaskModel>> byCat = {};
    for (final task in tasks) {
      if (task.categoryId != null) {
        byCat.putIfAbsent(task.categoryId!, () => []).add(task);
      }
    }
    if (byCat.isEmpty) return [];

    // FIX(domain-avgPerDomain): use only categorized tasks in the numerator.
    // Previously `tasks.length` was used, which inflated the average by including
    // uncategorized tasks and raised the isOverloaded threshold incorrectly.
    final categorizedCount =
        byCat.values.fold<int>(0, (sum, list) => sum + list.length);
    final avgPerDomain = categorizedCount / byCat.length;

    final metrics = <DomainMetric>[];
    for (final entry in byCat.entries) {
      final cat = categoryMap[entry.key];
      if (cat == null) continue;
      final total = entry.value.length;
      final done = entry.value.where((t) => t.isCompleted).length;
      final rate = total == 0 ? 0.0 : done / total;
      metrics.add(DomainMetric(
        categoryId: entry.key,
        name: cat.name,
        colorValue: cat.colorValue,
        iconKey: cat.iconKey,
        completedTasks: done,
        totalTasks: total,
        isNeglected: rate < 0.3 && total >= 3,
        isOverloaded: total > (avgPerDomain * 2).ceil() && total >= 5,
      ));
    }
    metrics.sort((a, b) => b.totalTasks.compareTo(a.totalTasks));
    return metrics;
  }

  // ── InsightEngine ──────────────────────────────────────────────────────────

  List<StatsInsight> _generateInsights(
    TaskMetrics tasks,
    HabitMetrics habits,
    FocusMetrics focus,
    List<PeriodMetric> periods,
    List<DomainMetric> domains,
  ) {
    final insights = <StatsInsight>[];

    // Task completion rate
    if (tasks.hasEnoughData) {
      if (tasks.completionRate >= 0.8) {
        final pct = (tasks.completionRate * 100).round();
        insights.add(StatsInsight(
          messageAr: 'أحسنت! أنجزت $pct% من مهامك — استمر على هذا المستوى',
          messageEn: 'Great work! You completed $pct% of your tasks — keep it up!',
          icon: Icons.star_rounded,
          type: InsightType.positive,
        ));
      } else if (tasks.overdueRate >= 0.3) {
        insights.add(StatsInsight(
          messageAr:
              'لديك ${tasks.overdueTasks} مهام متأخرة — راجع جدولك وحدد أولوياتك',
          messageEn:
              'You have ${tasks.overdueTasks} overdue tasks — review your schedule and set priorities.',
          icon: Icons.warning_amber_rounded,
          type: InsightType.warning,
        ));
      }
    }

    // Focus trend
    if (focus.hasEnoughData && focus.previousRangeMinutes > 0) {
      final change = focus.weekOverWeekChange;
      if (change > 0.2) {
        final pct = (change * 100).round();
        insights.add(StatsInsight(
          messageAr: 'ارتفع وقت تركيزك $pct% مقارنة بالفترة الماضية — رائع!',
          messageEn: 'Your focus time is up $pct% from last period — excellent!',
          icon: Icons.trending_up_rounded,
          type: InsightType.positive,
        ));
      } else if (change < -0.2) {
        final pct = (change.abs() * 100).round();
        insights.add(StatsInsight(
          messageAr:
              'انخفض وقت تركيزك $pct% — حاول تخصيص وقت يومي ثابت للتركيز',
          messageEn:
              'Your focus time dropped $pct% — try setting a fixed daily focus block.',
          icon: Icons.trending_down_rounded,
          type: InsightType.warning,
        ));
      }
    }

    // Habit consistency
    if (habits.hasEnoughData) {
      final pct = (habits.overallConsistency * 100).round();
      if (habits.overallConsistency >= 0.7) {
        insights.add(StatsInsight(
          messageAr: 'استمراريتك في العادات $pct% — ثابر وابنِ على هذا الأساس',
          messageEn: 'Your habit consistency is $pct% — keep building on this foundation.',
          icon: Icons.local_fire_department_rounded,
          type: InsightType.positive,
        ));
      } else if (habits.overallConsistency < 0.4) {
        insights.add(StatsInsight(
          messageAr: 'استمراريتك $pct% فقط — ابدأ بعادة واحدة يومياً وأتقنها',
          messageEn: 'Consistency is only $pct% — start with one daily habit and master it.',
          icon: Icons.refresh_rounded,
          type: InsightType.warning,
        ));
      }
    }

    // Best productive period
    final bestPeriod = periods
        .where((p) => p.hasData && p.totalTasks >= 2)
        .fold<PeriodMetric?>(
          null,
          (best, p) =>
              best == null || p.completionRate > best.completionRate ? p : best,
        );
    if (bestPeriod != null && bestPeriod.completionRate >= 0.6) {
      insights.add(StatsInsight(
        messageAr:
            'فترة ${bestPeriod.labelAr} هي أكثر أوقاتك إنتاجية — استغلها جيداً',
        messageEn:
            '${bestPeriod.labelEn} is your most productive period — make the most of it.',
        icon: Icons.access_time_rounded,
        type: InsightType.positive,
      ));
    }

    // Neglected domains
    final neglected = domains.where((d) => d.isNeglected).toList();
    if (neglected.isNotEmpty) {
      final namesAr = neglected.map((d) => d.name).join('، ');
      final namesEn = neglected.map((d) => d.name).join(', ');
      insights.add(StatsInsight(
        messageAr: 'مجال "$namesAr" يحتاج اهتماماً أكبر',
        messageEn: '"$namesEn" needs more attention.',
        icon: Icons.folder_open_rounded,
        type: InsightType.warning,
      ));
    }

    // Fallback when there's no data yet
    if (insights.isEmpty) {
      insights.add(StatsInsight(
        messageAr: 'أضف مهاماً وعادات لرؤية تحليل شامل لإنتاجيتك',
        messageEn: 'Add tasks and habits to see a full productivity analysis.',
        icon: Icons.insights_rounded,
        type: InsightType.neutral,
      ));
    }

    return insights;
  }

  // ── FocusByPeriod ──────────────────────────────────────────────────────────

  /// Groups focus session minutes by Islamic time period.
  /// Sessions with a null timePeriodIndex (recorded before that field existed)
  /// are silently skipped — no fake data is substituted.
  Map<AtharTimePeriod, int> _buildFocusByPeriod(List<FocusSession> sessions) {
    final map = <AtharTimePeriod, int>{};
    for (final s in sessions) {
      final idx = s.timePeriodIndex;
      if (idx == null || idx < 0 || idx >= AtharTimePeriod.values.length) {
        continue;
      }
      final period = AtharTimePeriod.values[idx];
      map[period] = (map[period] ?? 0) + s.durationMinutes;
    }
    return map;
  }

  // ── Derived composite scores ───────────────────────────────────────────────

  /// Delegates to [StatsHelpers.computeProductivityScore] for testability.
  double _computeProductivityScore(
    TaskMetrics tasks,
    HabitMetrics habits,
    FocusMetrics focus,
    int rangeDays,
  ) {
    return StatsHelpers.computeProductivityScore(
      completionRate: tasks.completionRate,
      overallConsistency: habits.overallConsistency,
      totalFocusMinutes: focus.totalMinutes,
      rangeDays: rangeDays,
    );
  }

  /// Consistency score (0.0–1.0):
  /// Fraction of days in the range on which the user completed at least one
  /// task OR at least one habit. Measures daily engagement breadth.
  double _computeConsistencyScore(
    List<TaskModel> tasks,
    List<HabitModel> habits,
    DateTime today,
    int rangeDays,
  ) {
    if (rangeDays == 0) return 0.0;
    int activeDays = 0;
    for (int i = 0; i < rangeDays; i++) {
      final day = today.subtract(Duration(days: i));
      final hadTask = tasks.any((t) => t.isCompleted && _sameDay(t.date, day));
      final hadHabit =
          habits.any((h) => h.completedDays.any((d) => _sameDay(d, day)));
      if (hadTask || hadHabit) activeDays++;
    }
    return activeDays / rangeDays;
  }

  /// Streak quality (0.0–1.0):
  /// For every habit that has ever recorded a streak (longestStreak > 0),
  /// compute currentStreak / longestStreak, then average across all such habits.
  /// A score of 1.0 means every habit is at its personal best streak.
  double _computeStreakQuality(List<HabitModel> habits) {
    final eligible = habits.where((h) => h.longestStreak > 0).toList();
    if (eligible.isEmpty) return 0.0;
    final sum = eligible.fold<double>(
      0.0,
      (acc, h) =>
          acc + (h.currentStreak / h.longestStreak).clamp(0.0, 1.0),
    );
    return (sum / eligible.length).clamp(0.0, 1.0);
  }

  // ── Utility ────────────────────────────────────────────────────────────────

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
