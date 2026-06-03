import 'package:athar/core/design_system/design_system.dart';
import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:athar/features/habits/presentation/widgets/habit_heatmap.dart';
import 'package:athar/features/stats/domain/models/stats_data.dart';
import 'package:athar/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:athar/features/stats/presentation/widgets/stats_metric_card.dart';
import 'package:athar/features/stats/presentation/widgets/stats_weekly_focus_chart.dart';
import 'package:athar/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StatsCubit>()..loadStats(),
      child: const _StatisticsView(),
    );
  }
}

// ── Main view ──────────────────────────────────────────────────────────────────

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.statsPageTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _PeriodPillRow(),
          Expanded(
            child: BlocBuilder<StatsCubit, StatsState>(
              builder: (context, state) {
                if (state is StatsInitial || state is StatsLoading) {
                  return _SkeletonGrid();
                }
                if (state is StatsError) {
                  return _ErrorView(message: state.message);
                }
                if (state is StatsLoaded) {
                  return BlocBuilder<SubscriptionCubit, SubscriptionState>(
                    buildWhen: (prev, curr) {
                      final pa = prev is SubscriptionLoaded &&
                          prev.status.hasSyncAccess;
                      final ca = curr is SubscriptionLoaded &&
                          curr.status.hasSyncAccess;
                      return pa != ca;
                    },
                    builder: (context, subState) {
                      final hasAccess = subState is SubscriptionLoaded
                          ? subState.status.hasSyncAccess
                          : false;
                      return _StatsBody(
                        data: state.data,
                        period: state.period,
                        hasAccess: hasAccess,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Period pill row ────────────────────────────────────────────────────────────

class _PeriodPillRow extends StatelessWidget {
  const _PeriodPillRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    final labels = {
      StatsPeriod.today: l10n.statsPeriodToday,
      StatsPeriod.last7Days: l10n.statsPeriodLast7Days,
      StatsPeriod.last30Days: l10n.statsPeriodLast30Days,
    };

    return BlocBuilder<StatsCubit, StatsState>(
      buildWhen: (p, c) => true,
      builder: (context, state) {
        final selected = switch (state) {
          StatsLoaded s => s.period,
          StatsLoading s => s.period,
          _ => StatsPeriod.last7Days,
        };

        return Container(
          color: colors.scaffoldBackground,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsetsDirectional.only(
              start: 16.w,
              end: 16.w,
              top: 8.h,
              bottom: 12.h,
            ),
            child: Row(
              children: StatsPeriod.values.map((period) {
                final isSelected = period == selected;
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: 8.w),
                  child: GestureDetector(
                    onTap: () => context.read<StatsCubit>().setPeriod(period),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : colors.surfaceVariant,
                        borderRadius: AtharRadii.radiusFull,
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.borderLight,
                        ),
                      ),
                      child: Text(
                        labels[period]!,
                        style: AtharTypography.labelLarge.copyWith(
                          color: isSelected
                              ? colors.textOnPrimary
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

// ── Stats body ─────────────────────────────────────────────────────────────────

class _StatsBody extends StatelessWidget {
  final StatsData data;
  final StatsPeriod period;
  final bool hasAccess;

  const _StatsBody({
    required this.data,
    required this.period,
    required this.hasAccess,
  });

  bool get _hasData =>
      data.tasks.totalTasks > 0 ||
      data.focus.totalMinutes > 0 ||
      data.habits.totalHabits > 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!_hasData) return _EmptyState();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tier-1 hero grid ─────────────────────────────────────
          _HeroGrid(data: data, period: period),
          AtharGap.lg,

          // ── Tasks chart ──────────────────────────────────────────
          if (data.tasks.dailyCounts.isNotEmpty) ...[
            _SectionHeader(
              title: l10n.statsTasksSection,
              icon: Icons.task_alt_rounded,
            ),
            AtharGap.sm,
            _ChartCard(
              title: l10n.statsDailyCompletion,
              period: period,
              l10n: l10n,
              child: _DailyCompletionBarChart(
                counts: data.tasks.dailyCounts,
              ),
            ),
            AtharGap.sm,
            _TaskSummaryRow(tasks: data.tasks, l10n: l10n),
            AtharGap.lg,
          ],

          // ── Focus chart ──────────────────────────────────────────
          _SectionHeader(
            title: l10n.statsFocusSection,
            icon: Icons.timer_rounded,
          ),
          AtharGap.sm,
          if (data.focus.dailyMinutes.isNotEmpty &&
              data.focus.dailyMinutes.any((m) => m > 0)) ...[
            _ChartCard(
              title: l10n.statsWeeklyFocusTitle,
              period: period,
              l10n: l10n,
              child: WeeklyFocusChart(
                weeklyData: data.focus.dailyMinutes,
                rangeDays: period.rangeDays,
              ),
            ),
            AtharGap.sm,
          ],
          _FocusSummaryRow(focus: data.focus, l10n: l10n),
          if (data.focus.minutesByPeriod.isNotEmpty) ...[
            AtharGap.sm,
            _FocusByPeriodBars(minutesByPeriod: data.focus.minutesByPeriod),
          ],
          AtharGap.lg,

          // ── Habits ───────────────────────────────────────────────
          _SectionHeader(
            title: l10n.statsHabitCommitment,
            icon: Icons.calendar_month_rounded,
          ),
          AtharGap.sm,
          if (hasAccess) ...[
            _HabitConsistencyRow(habits: data.habits, l10n: l10n),
            if (data.habits.topStreaks.isNotEmpty) ...[
              AtharGap.sm,
              _TopStreaksCard(
                streaks: data.habits.topStreaks,
                l10n: l10n,
              ),
            ],
            AtharGap.sm,
            HabitHeatmap(datasets: data.habits.heatmapData),
          ] else
            _PaywallSection(l10n: l10n),
          AtharGap.lg,

          // ── Periods ──────────────────────────────────────────────
          if (hasAccess && data.periods.isNotEmpty) ...[
            _SectionHeader(
              title: l10n.statsPeriodsSection,
              icon: Icons.access_time_rounded,
            ),
            AtharGap.sm,
            _PeriodChart(periods: data.periods),
            AtharGap.lg,
          ],

          // ── Domains ──────────────────────────────────────────────
          if (hasAccess && data.domains.isNotEmpty) ...[
            _SectionHeader(
              title: l10n.statsDomainsSection,
              icon: Icons.folder_rounded,
            ),
            AtharGap.sm,
            _DomainList(domains: data.domains, l10n: l10n),
            AtharGap.lg,
          ],

          // ── Insights ─────────────────────────────────────────────
          if (hasAccess && data.insights.isNotEmpty) ...[
            _SectionHeader(
              title: l10n.statsInsightsSection,
              icon: Icons.insights_rounded,
            ),
            AtharGap.sm,
            _InsightsSection(insights: data.insights),
            AtharGap.lg,
          ],

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ── Hero grid (Tier-1 KPI cards) ──────────────────────────────────────────────

class _HeroGrid extends StatelessWidget {
  final StatsData data;
  final StatsPeriod period;

  const _HeroGrid({required this.data, required this.period});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final isWide = MediaQuery.of(context).size.width >= 600;
    final crossAxis = isWide ? 3 : 2;
    const gap = 12.0;

    // ── Focus trend pill ───────────────────────────────────────────
    final focusChange = data.focus.weekOverWeekChange;
    final focusTrend = focusChange > 0.05
        ? StatsTrend.up
        : focusChange < -0.05
            ? StatsTrend.down
            : StatsTrend.flat;
    final focusTrendLabel = focusChange == 0 || data.focus.previousRangeMinutes == 0
        ? null
        : '${focusChange >= 0 ? '+' : ''}${(focusChange * 100).round()}%';

    // ── Task sparkline ─────────────────────────────────────────────
    final sparkValues = data.tasks.dailyCounts
        .map((c) => c.completed.toDouble())
        .toList();

    final cards = [
      // #1 Tasks completed
      StatsMetricCard(
        title: l10n.statsKpiTasksDone,
        value: '${data.tasks.completedTasks}',
        sparkline: period != StatsPeriod.today && sparkValues.length >= 2
            ? StatsSparkline(values: sparkValues, color: colors.primary)
            : null,
      ),
      // #2 Habit streak
      StatsMetricCard(
        title: l10n.statsKpiHabitStreak,
        value: data.habits.topStreaks.isEmpty
            ? '0'
            : '${data.habits.topStreaks.first.currentStreak}',
        unit: l10n.statsKpiUnitDays,
      ),
      // #3 Habit rate
      StatsMetricCard(
        title: l10n.statsKpiHabitRate,
        value:
            '${(data.habits.overallConsistency * 100).round()}',
        unit: '%',
      ),
      // #4 Focus minutes
      StatsMetricCard(
        title: l10n.statsKpiFocusMin,
        value: '${data.focus.totalMinutes}',
        unit: l10n.statsKpiUnitMin,
        trend: focusTrendLabel != null ? focusTrend : null,
        trendLabel: focusTrendLabel,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - gap * (crossAxis - 1)) / crossAxis;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map((c) => SizedBox(width: itemWidth, child: c))
              .toList(),
        );
      },
    );
  }
}

// ── Chart card wrapper ─────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final StatsPeriod period;
  final AppLocalizations l10n;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.period,
    required this.l10n,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final periodLabel = switch (period) {
      StatsPeriod.today => l10n.statsPeriodToday,
      StatsPeriod.last7Days => l10n.statsPeriodLast7Days,
      StatsPeriod.last30Days => l10n.statsPeriodLast30Days,
    };

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AtharTypography.titleSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: AtharRadii.radiusFull,
                ),
                child: Text(
                  periodLabel,
                  style: AtharTypography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: MediaQuery.of(context).size.width >= 600 ? 240.h : 180.h,
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 18.sp),
        AtharGap.hXs,
        Text(
          title,
          style: AtharTypography.titleMedium.copyWith(color: colors.textPrimary),
        ),
      ],
    );
  }
}

// ── Skeleton loading grid ──────────────────────────────────────────────────────

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // 4 skeleton KPI cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final crossAxis = isWide ? 3 : 2;
              final itemWidth =
                  (constraints.maxWidth - gap * (crossAxis - 1)) / crossAxis;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: List.generate(
                  4,
                  (_) => SizedBox(
                    width: itemWidth,
                    child: const StatsMetricCardSkeleton(),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          // Skeleton chart placeholder
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: context.colors.shimmerBase,
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 56.sp,
              color: colors.textTertiary,
            ),
            AtharGap.md,
            Text(
              l10n.statsEmptyPeriod,
              style: AtharTypography.titleMedium
                  .copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            AtharGap.xs,
            Text(
              l10n.statsEmptyPeriodSub,
              style:
                  AtharTypography.bodyMedium.copyWith(color: colors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bare daily completion bar chart ───────────────────────────────────────────

class _DailyCompletionBarChart extends StatelessWidget {
  final List<DailyTaskCount> counts;

  const _DailyCompletionBarChart({required this.counts});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    final data = isRtl ? counts.reversed.toList() : counts;
    final n = data.length;

    final maxY = data.map((c) => c.total.toDouble()).fold(0.0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxY == 0 ? 5 : maxY) * 1.25,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: n <= 10,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= n) return const SizedBox.shrink();
                final dayOffset = isRtl ? idx : (n - 1 - idx);
                final date = DateTime.now().subtract(Duration(days: dayOffset));
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('E', 'ar').format(date),
                    style: AtharTypography.labelSmall
                        .copyWith(color: colors.textTertiary),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: data.asMap().entries.map((e) {
          final c = e.value;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: c.total.toDouble(),
                color: colors.primary.withValues(alpha: 0.2),
                width: 10.w,
                borderRadius: AtharRadii.radiusXxs,
                rodStackItems: [
                  BarChartRodStackItem(
                      0, c.completed.toDouble(), colors.primary),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Task summary row ───────────────────────────────────────────────────────────

class _TaskSummaryRow extends StatelessWidget {
  final TaskMetrics tasks;
  final AppLocalizations l10n;

  const _TaskSummaryRow({required this.tasks, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pct = (tasks.completionRate * 100).round();

    return Row(
      children: [
        Expanded(
          child: _MetricChip(
            label: l10n.statsCompletionRate(pct),
            color: colors.primary,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _MetricChip(
            label: l10n.statsOverdueTasks(tasks.overdueTasks),
            color: tasks.overdueTasks > 0 ? colors.error : colors.textTertiary,
            icon: Icons.warning_amber_rounded,
          ),
        ),
        if (tasks.avgDelayDays > 0) ...[
          SizedBox(width: 8.w),
          Expanded(
            child: _MetricChip(
              label: l10n.statsAvgDelay(tasks.avgDelayDays.round()),
              color: colors.secondary,
              icon: Icons.schedule_rounded,
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _MetricChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: AtharTypography.labelMedium.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Focus summary row ──────────────────────────────────────────────────────────

class _FocusSummaryRow extends StatelessWidget {
  final FocusMetrics focus;
  final AppLocalizations l10n;

  const _FocusSummaryRow({required this.focus, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final h = focus.totalMinutes ~/ 60;
    final m = focus.totalMinutes % 60;
    final changeAbs = focus.weekOverWeekChange.abs();
    final isUp = focus.weekOverWeekChange >= 0;

    return Row(
      children: [
        Expanded(
          child: _MetricChip(
            label: l10n.statsFocusHours(h, m),
            color: colors.primary,
            icon: Icons.timer_rounded,
          ),
        ),
        if (focus.previousRangeMinutes > 0) ...[
          SizedBox(width: 8.w),
          Expanded(
            child: _MetricChip(
              label:
                  '${isUp ? '+' : '-'}${(changeAbs * 100).round()}%',
              color: isUp ? colors.success : colors.error,
              icon: isUp
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Habit consistency row ──────────────────────────────────────────────────────

class _HabitConsistencyRow extends StatelessWidget {
  final HabitMetrics habits;
  final AppLocalizations l10n;

  const _HabitConsistencyRow({required this.habits, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pct = (habits.overallConsistency * 100).round();
    final color = pct >= 70
        ? colors.success
        : pct >= 40
            ? colors.primary
            : colors.error;

    return _MetricChip(
      label: l10n.statsConsistency(pct),
      color: color,
      icon: Icons.local_fire_department_rounded,
    );
  }
}

// ── Top streaks card ───────────────────────────────────────────────────────────

class _TopStreaksCard extends StatelessWidget {
  final List<HabitStreakItem> streaks;
  final AppLocalizations l10n;

  const _TopStreaksCard({required this.streaks, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsTopStreaks,
            style:
                AtharTypography.titleSmall.copyWith(color: colors.textSecondary),
          ),
          AtharGap.sm,
          ...streaks.map((s) => _StreakRow(streak: s, l10n: l10n)),
        ],
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  final HabitStreakItem streak;
  final AppLocalizations l10n;

  const _StreakRow({required this.streak, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = Color(streak.colorValue);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AtharRadii.radiusSm,
            ),
            child: Icon(Icons.check_circle_rounded, color: color, size: 16.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              streak.title,
              style: AtharTypography.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: colors.warning, size: 14.sp),
              SizedBox(width: 2.w),
              Text(
                l10n.statsStreakDays(streak.currentStreak),
                style: AtharTypography.titleSmall
                    .copyWith(color: colors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Focus by period bars ───────────────────────────────────────────────────────

class _FocusByPeriodBars extends StatelessWidget {
  final Map<AtharTimePeriod, int> minutesByPeriod;

  const _FocusByPeriodBars({required this.minutesByPeriod});

  static const Map<AtharTimePeriod, String> _labelsAr = {
    AtharTimePeriod.dawn: 'الفجر',
    AtharTimePeriod.bakur: 'البكور',
    AtharTimePeriod.duha: 'الضحى',
    AtharTimePeriod.morning: 'الصباح',
    AtharTimePeriod.noon: 'الظهيرة',
    AtharTimePeriod.afternoon: 'العصر',
    AtharTimePeriod.maghrib: 'المغرب',
    AtharTimePeriod.isha: 'العشاء',
    AtharTimePeriod.night: 'الليل',
    AtharTimePeriod.lastThird: 'الثلث الأخير',
    AtharTimePeriod.undefined: 'غير محدد',
  };

  static const Map<AtharTimePeriod, String> _labelsEn = {
    AtharTimePeriod.dawn: 'Dawn',
    AtharTimePeriod.bakur: 'Bakur',
    AtharTimePeriod.duha: 'Duha',
    AtharTimePeriod.morning: 'Morning',
    AtharTimePeriod.noon: 'Noon',
    AtharTimePeriod.afternoon: 'Afternoon',
    AtharTimePeriod.maghrib: 'Maghrib',
    AtharTimePeriod.isha: 'Isha',
    AtharTimePeriod.night: 'Night',
    AtharTimePeriod.lastThird: 'Last Third',
    AtharTimePeriod.undefined: 'Unspecified',
  };

  static const List<AtharTimePeriod> _order = [
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
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final labels = isArabic ? _labelsAr : _labelsEn;

    final maxMinutes = minutesByPeriod.values.fold(0, (a, b) => a > b ? a : b);
    final sorted = _order.where(minutesByPeriod.containsKey).toList();

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'التركيز حسب الوقت' : 'Focus by Time Period',
            style:
                AtharTypography.titleSmall.copyWith(color: colors.textSecondary),
          ),
          AtharGap.xs,
          ...sorted.map((period) {
            final minutes = minutesByPeriod[period]!;
            final rate = maxMinutes == 0 ? 0.0 : minutes / maxMinutes;
            final h = minutes ~/ 60;
            final m = minutes % 60;
            final timeLabel = h > 0 ? '${h}h ${m}m' : '${m}m';

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 64.w,
                    child: Text(
                      labels[period] ?? '',
                      style: AtharTypography.bodySmall
                          .copyWith(color: colors.textTertiary),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: rate,
                      backgroundColor: colors.border.withValues(alpha: 0.15),
                      color: colors.primary,
                      borderRadius: AtharRadii.radiusXxs,
                      minHeight: 8.h,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    timeLabel,
                    style: AtharTypography.labelMedium
                        .copyWith(color: colors.textPrimary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Period chart ───────────────────────────────────────────────────────────────

class _PeriodChart extends StatelessWidget {
  final List<PeriodMetric> periods;

  const _PeriodChart({required this.periods});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.borderLight, width: 1),
      ),
      child: Column(
        children: periods.map((p) => _PeriodRow(period: p)).toList(),
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  final PeriodMetric period;

  const _PeriodRow({required this.period});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rate = period.completionRate;
    final barColor = rate >= 0.7
        ? colors.success
        : rate >= 0.4
            ? colors.primary
            : colors.error;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          SizedBox(
            width: 60.w,
            child: Text(
              period.labelAr,
              style: AtharTypography.bodySmall.copyWith(
                color: colors.textTertiary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: colors.border.withValues(alpha: 0.15),
              color: barColor,
              borderRadius: AtharRadii.radiusXxs,
              minHeight: 8.h,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            '${(rate * 100).round()}%',
            style: AtharTypography.labelMedium
                .copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Domain list ────────────────────────────────────────────────────────────────

class _DomainList extends StatelessWidget {
  final List<DomainMetric> domains;
  final AppLocalizations l10n;

  const _DomainList({required this.domains, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.borderLight, width: 1),
      ),
      child: Column(
        children: domains.map((d) => _DomainRow(domain: d, l10n: l10n)).toList(),
      ),
    );
  }
}

class _DomainRow extends StatelessWidget {
  final DomainMetric domain;
  final AppLocalizations l10n;

  const _DomainRow({required this.domain, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cat = Color(domain.colorValue);
    final rate = domain.completionRate;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: cat, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          SizedBox(
            width: 64.w,
            child: Text(
              domain.name,
              style: AtharTypography.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: colors.border.withValues(alpha: 0.15),
              color: cat,
              borderRadius: AtharRadii.radiusXxs,
              minHeight: 8.h,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            '${domain.completedTasks}/${domain.totalTasks}',
            style:
                AtharTypography.bodySmall.copyWith(color: colors.textTertiary),
          ),
          if (domain.isNeglected)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 4.w),
              child: Icon(Icons.warning_amber_rounded,
                  size: 12.sp, color: colors.error),
            ),
          if (domain.isOverloaded)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 4.w),
              child: Icon(Icons.priority_high_rounded,
                  size: 12.sp, color: colors.warning),
            ),
        ],
      ),
    );
  }
}

// ── Insights section (StatefulWidget for in-session dismiss) ──────────────────

class _InsightsSection extends StatefulWidget {
  final List<StatsInsight> insights;

  const _InsightsSection({required this.insights});

  @override
  State<_InsightsSection> createState() => _InsightsSectionState();
}

class _InsightsSectionState extends State<_InsightsSection> {
  final Set<int> _dismissed = {};

  @override
  Widget build(BuildContext context) {
    final visible = widget.insights
        .asMap()
        .entries
        .where((e) => !_dismissed.contains(e.key))
        .toList();

    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      children: visible
          .map((e) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _InsightCard(
                  insight: e.value,
                  onDismiss: () => setState(() => _dismissed.add(e.key)),
                ),
              ))
          .toList(),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final StatsInsight insight;
  final VoidCallback onDismiss;

  const _InsightCard({required this.insight, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final message = isArabic ? insight.messageAr : insight.messageEn;

    final color = switch (insight.type) {
      InsightType.positive => colors.success,
      InsightType.warning => colors.error,
      InsightType.neutral => colors.primary,
    };

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(insight.icon, color: color, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: AtharTypography.bodyMedium.copyWith(
                color: colors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 8.w),
              child: Icon(Icons.close_rounded,
                  size: 16.sp, color: colors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Paywall section ────────────────────────────────────────────────────────────

class _PaywallSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _PaywallSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: AtharSpacing.allXl,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_rounded, color: colors.primary, size: 32.sp),
          AtharGap.sm,
          Text(
            l10n.statsUpgradeTitle,
            style: AtharTypography.titleMedium.copyWith(color: colors.textPrimary),
          ),
          AtharGap.xs,
          Text(
            l10n.statsUpgradeBody,
            style: AtharTypography.bodyMedium.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          AtharGap.md,
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.star_rounded),
            label: Text(l10n.statsUpgradeCta),
          ),
        ],
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error, size: 40.sp),
          AtharGap.sm,
          Text(
            message,
            style: AtharTypography.bodyMedium.copyWith(color: colors.error),
          ),
          AtharGap.sm,
          TextButton.icon(
            onPressed: () => context.read<StatsCubit>().loadStats(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
