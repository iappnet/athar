import 'package:athar/core/design_system/design_system.dart';
import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:athar/features/habits/presentation/widgets/habit_heatmap.dart';
import 'package:athar/features/stats/domain/models/stats_data.dart';
import 'package:athar/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:athar/features/stats/presentation/cubit/stats_state.dart';
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

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.statsPageTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<StatsCubit, StatsState>(
            buildWhen: (p, c) => c is StatsLoaded || c is StatsLoading,
            builder: (context, state) {
              final current =
                  state is StatsLoaded ? state.rangeDays : 7;
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 12.w),
                child: SegmentedButton<int>(
                  style: SegmentedButton.styleFrom(
                    textStyle: TextStyle(fontSize: 12.sp),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: [
                    ButtonSegment(value: 7, label: Text(l10n.statsRange7Days)),
                    ButtonSegment(
                        value: 30, label: Text(l10n.statsRange30Days)),
                  ],
                  selected: {current},
                  onSelectionChanged: (s) =>
                      context.read<StatsCubit>().setRange(s.first),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading || state is StatsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StatsError) {
            return _ErrorView(message: state.message);
          }
          if (state is StatsLoaded) {
            return BlocBuilder<SubscriptionCubit, SubscriptionState>(
              buildWhen: (prev, curr) {
                final prevAccess = prev is SubscriptionLoaded && prev.status.hasSyncAccess;
                final currAccess = curr is SubscriptionLoaded && curr.status.hasSyncAccess;
                return prevAccess != currAccess;
              },
              builder: (context, subState) {
                final hasAccess = subState is SubscriptionLoaded
                    ? subState.status.hasSyncAccess
                    : false;
                return _StatsContent(
                  data: state.data,
                  rangeDays: state.rangeDays,
                  hasAccess: hasAccess,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Main scrollable content ────────────────────────────────────────────────────

class _StatsContent extends StatelessWidget {
  final StatsData data;
  final int rangeDays;
  final bool hasAccess;

  const _StatsContent({
    required this.data,
    required this.rangeDays,
    required this.hasAccess,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Score dashboard ─────────────────────────────────────────
          _ScoreDashboard(data: data),
          AtharGap.lg,

          // ── Today snapshot ──────────────────────────────────────────
          _TodayCard(tasks: data.tasks, habits: data.habits),
          AtharGap.lg,

          // ── Tasks ───────────────────────────────────────────────────
          _SectionHeader(title: l10n.statsTasksSection, icon: Icons.task_alt_rounded),
          AtharGap.sm,
          _TaskSummaryRow(tasks: data.tasks, l10n: l10n),
          AtharGap.sm,
          if (data.tasks.dailyCounts.isNotEmpty)
            _DailyCompletionChart(
              counts: data.tasks.dailyCounts,
              rangeDays: rangeDays,
              l10n: l10n,
            ),
          AtharGap.lg,

          // ── Focus ───────────────────────────────────────────────────
          _SectionHeader(title: l10n.statsFocusSection, icon: Icons.timer_rounded),
          AtharGap.sm,
          _FocusSummaryRow(focus: data.focus, l10n: l10n),
          AtharGap.sm,
          if (data.focus.dailyMinutes.isNotEmpty)
            WeeklyFocusChart(weeklyData: data.focus.dailyMinutes),
          if (data.focus.minutesByPeriod.isNotEmpty) ...[
            AtharGap.sm,
            _FocusByPeriodBars(minutesByPeriod: data.focus.minutesByPeriod),
          ],
          AtharGap.lg,

          // ── Habits ──────────────────────────────────────────────────
          _SectionHeader(
              title: l10n.statsHabitCommitment,
              icon: Icons.calendar_month_rounded),
          AtharGap.sm,
          if (hasAccess) ...[
            _HabitConsistencyRow(habits: data.habits, l10n: l10n),
            AtharGap.sm,
            if (data.habits.topStreaks.isNotEmpty)
              _TopStreaksCard(streaks: data.habits.topStreaks, l10n: l10n),
            AtharGap.sm,
            HabitHeatmap(datasets: data.habits.heatmapData),
          ] else
            _PaywallSection(l10n: l10n),
          AtharGap.lg,

          // ── Periods (subscribers only) ───────────────────────────────
          if (hasAccess && data.periods.isNotEmpty) ...[
            _SectionHeader(
                title: l10n.statsPeriodsSection,
                icon: Icons.access_time_rounded),
            AtharGap.sm,
            _PeriodChart(periods: data.periods),
            AtharGap.lg,
          ],

          // ── Domains (subscribers only) ───────────────────────────────
          if (hasAccess && data.domains.isNotEmpty) ...[
            _SectionHeader(
                title: l10n.statsDomainsSection,
                icon: Icons.folder_rounded),
            AtharGap.sm,
            _DomainList(domains: data.domains, l10n: l10n),
            AtharGap.lg,
          ],

          // ── Insights (subscribers only) ──────────────────────────────
          if (hasAccess && data.insights.isNotEmpty) ...[
            _SectionHeader(
                title: l10n.statsInsightsSection,
                icon: Icons.insights_rounded),
            AtharGap.sm,
            _InsightsList(insights: data.insights),
            AtharGap.lg,
          ],

          SizedBox(height: 24.h),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 18.sp),
        AtharGap.hXs,
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// ── Today card ─────────────────────────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  final TaskMetrics tasks;
  final HabitMetrics habits;

  const _TodayCard({required this.tasks, required this.habits});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: AtharRadii.radiusXl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TodayKpi(
            icon: Icons.task_alt_rounded,
            label: l10n.statsTasksSection,
            value: l10n.statsTodayTasks(
                tasks.completedToday, tasks.totalToday),
          ),
          _VerticalDivider(),
          _TodayKpi(
            icon: Icons.repeat_rounded,
            label: l10n.statsHabitCommitment,
            value: l10n.statsTodayHabits(
                habits.completedToday, habits.totalToday),
          ),
          _VerticalDivider(),
          _TodayKpi(
            icon: Icons.timer_rounded,
            label: l10n.statsFocusSection,
            value: l10n.statsTodayFocus(tasks.focusMinutesToday),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40.h,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}

class _TodayKpi extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TodayKpi({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 18.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10.sp,
          ),
        ),
      ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final pct = (tasks.completionRate * 100).round();

    return Row(
      children: [
        Expanded(
          child: _MetricChip(
            label: l10n.statsCompletionRate(pct),
            color: colorScheme.primary,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _MetricChip(
            label: l10n.statsOverdueTasks(tasks.overdueTasks),
            color: tasks.overdueTasks > 0
                ? colorScheme.error
                : colorScheme.outline,
            icon: Icons.warning_amber_rounded,
          ),
        ),
        if (tasks.avgDelayDays > 0) ...[
          SizedBox(width: 8.w),
          Expanded(
            child: _MetricChip(
              label: l10n.statsAvgDelay(tasks.avgDelayDays.round()),
              color: colorScheme.tertiary,
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
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily completion chart ─────────────────────────────────────────────────────

class _DailyCompletionChart extends StatelessWidget {
  final List<DailyTaskCount> counts;
  final int rangeDays;
  final AppLocalizations l10n;

  const _DailyCompletionChart({
    required this.counts,
    required this.rangeDays,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxY = counts
        .map((c) => c.total.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      height: 160.h,
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsDailyCompletion,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          AtharGap.xs,
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxY == 0 ? 5 : maxY) * 1.25,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: counts.length <= 10,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= counts.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('E', 'ar').format(counts[idx].date),
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: colorScheme.outline,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: counts.asMap().entries.map((e) {
                  final idx = e.key;
                  final c = e.value;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: c.total.toDouble(),
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 10.w,
                        borderRadius: AtharRadii.radiusXxs,
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            c.completed.toDouble(),
                            colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final h = focus.totalMinutes ~/ 60;
    final m = focus.totalMinutes % 60;
    final changeAbs = focus.weekOverWeekChange.abs();
    final isUp = focus.weekOverWeekChange >= 0;

    return Row(
      children: [
        Expanded(
          child: _MetricChip(
            label: l10n.statsFocusHours(h, m),
            color: colorScheme.primary,
            icon: Icons.timer_rounded,
          ),
        ),
        if (focus.previousRangeMinutes > 0) ...[
          SizedBox(width: 8.w),
          Expanded(
            child: _MetricChip(
              label: '${isUp ? '+' : '-'}${(changeAbs * 100).round()}%',
              color: isUp ? Colors.green : colorScheme.error,
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
    final colorScheme = Theme.of(context).colorScheme;
    final pct = (habits.overallConsistency * 100).round();

    return _MetricChip(
      label: l10n.statsConsistency(pct),
      color: pct >= 70
          ? Colors.green
          : pct >= 40
              ? colorScheme.primary
              : colorScheme.error,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsTopStreaks,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: colorScheme.onSurfaceVariant,
            ),
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
    final colorScheme = Theme.of(context).colorScheme;
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
              style: TextStyle(fontSize: 13.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: Colors.orange, size: 14.sp),
              SizedBox(width: 2.w),
              Text(
                l10n.statsStreakDays(streak.currentStreak),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final rate = period.completionRate;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          SizedBox(
            width: 60.w,
            child: Text(
              period.labelAr,
              style: TextStyle(
                fontSize: 11.sp,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.15),
              color: rate >= 0.7
                  ? Colors.green
                  : rate >= 0.4
                      ? colorScheme.primary
                      : colorScheme.error,
              borderRadius: AtharRadii.radiusXxs,
              minHeight: 8.h,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            '${(rate * 100).round()}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final cat = Color(domain.colorValue);
    final rate = domain.completionRate;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: cat,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          SizedBox(
            width: 64.w,
            child: Text(
              domain.name,
              style: TextStyle(fontSize: 11.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.15),
              color: cat,
              borderRadius: AtharRadii.radiusXxs,
              minHeight: 8.h,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            '${domain.completedTasks}/${domain.totalTasks}',
            style: TextStyle(
              fontSize: 11.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (domain.isNeglected)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 4.w),
              child: Icon(Icons.warning_amber_rounded,
                  size: 12.sp, color: colorScheme.error),
            ),
          if (domain.isOverloaded)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 4.w),
              child: Icon(Icons.priority_high_rounded,
                  size: 12.sp, color: Colors.orange),
            ),
        ],
      ),
    );
  }
}

// ── Insights list ──────────────────────────────────────────────────────────────

class _InsightsList extends StatelessWidget {
  final List<StatsInsight> insights;

  const _InsightsList({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: insights
          .map((i) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _InsightCard(insight: i),
              ))
          .toList(),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final StatsInsight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (insight.type) {
      InsightType.positive => Colors.green,
      InsightType.warning => colorScheme.error,
      InsightType.neutral => colorScheme.primary,
    };
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final message = isArabic ? insight.messageAr : insight.messageEn;

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(insight.icon, color: color, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13.sp,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Score dashboard ────────────────────────────────────────────────────────────

class _ScoreDashboard extends StatelessWidget {
  final StatsData data;

  const _ScoreDashboard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: AtharRadii.radiusLg,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ScoreGauge(
            label: isArabic ? 'الإنتاجية' : 'Productivity',
            value: data.productivityScore,
            color: colorScheme.primary,
          ),
          _ScoreGauge(
            label: isArabic ? 'الاستمرارية' : 'Consistency',
            value: data.consistencyScore,
            color: Colors.green,
          ),
          _ScoreGauge(
            label: isArabic ? 'جودة السلاسل' : 'Streak Quality',
            value: data.streakQuality,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _ScoreGauge extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ScoreGauge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct = (value * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64.w,
          height: 64.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.15),
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final labels = isArabic ? _labelsAr : _labelsEn;

    final maxMinutes = minutesByPeriod.values.fold(0, (a, b) => a > b ? a : b);
    final sorted = _order.where(minutesByPeriod.containsKey).toList();

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'التركيز حسب الوقت' : 'Focus by Time Period',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: colorScheme.onSurfaceVariant,
            ),
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
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: rate,
                      backgroundColor:
                          colorScheme.outline.withValues(alpha: 0.15),
                      color: colorScheme.primary,
                      borderRadius: AtharRadii.radiusXxs,
                      minHeight: 8.h,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
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

// ── Paywall section ────────────────────────────────────────────────────────────

class _PaywallSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _PaywallSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: AtharSpacing.allXl,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: AtharRadii.radiusLg,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_rounded,
              color: colorScheme.primary, size: 32.sp),
          AtharGap.sm,
          Text(
            l10n.statsUpgradeTitle,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          AtharGap.xs,
          Text(
            l10n.statsUpgradeBody,
            style: TextStyle(
              fontSize: 13.sp,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          AtharGap.md,
          FilledButton.icon(
            onPressed: () {
              // Navigate to subscription page
            },
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
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 40.sp),
          AtharGap.sm,
          Text(message,
              style: TextStyle(color: colorScheme.error, fontSize: 14.sp)),
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
