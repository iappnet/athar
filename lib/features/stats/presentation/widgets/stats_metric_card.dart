import 'package:athar/core/design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum StatsTrend { up, down, flat }

/// Tier-1 KPI card — spec: radius 18, AppColors.surface, 1pt borderLight,
/// title captionM/textTertiary, value numericMono 28pt/textPrimary,
/// trend pill bottom-right.
class StatsMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final StatsTrend? trend;
  final String? trendLabel;
  final Widget? sparkline;

  const StatsMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.trend,
    this.trendLabel,
    this.sparkline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasTrend = trend != null && trendLabel != null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AtharTypography.caption.copyWith(color: colors.textTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AtharTypography.numericMono.copyWith(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (unit != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 3.h, start: 2.w),
                  child: Text(
                    unit!,
                    style: AtharTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          if (sparkline != null) ...[
            SizedBox(height: 8.h),
            sparkline!,
          ],
          if (hasTrend) ...[
            SizedBox(height: 8.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _TrendPill(direction: trend!, label: trendLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  final StatsTrend direction;
  final String label;

  const _TrendPill({required this.direction, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, fg, icon) = switch (direction) {
      StatsTrend.up => (
          colors.successLight,
          colors.success,
          Icons.arrow_upward_rounded,
        ),
      StatsTrend.down => (
          colors.errorLight,
          colors.error,
          Icons.arrow_downward_rounded,
        ),
      StatsTrend.flat => (
          colors.surfaceVariant,
          colors.textTertiary,
          Icons.remove_rounded,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AtharRadii.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: fg),
          SizedBox(width: 2.w),
          Text(
            label,
            style: AtharTypography.labelSmall.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

/// Mini sparkline (area line chart) for KPI card footers.
/// Renders nothing when [values] has fewer than 2 points.
class StatsSparkline extends StatelessWidget {
  final List<double> values;
  final Color color;

  const StatsSparkline({
    super.key,
    required this.values,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return const SizedBox.shrink();

    final spots = values.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return SizedBox(
      height: 36.h,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 1.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder card shown during loading.
class StatsMetricCardSkeleton extends StatelessWidget {
  const StatsMetricCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget shimmer(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: colors.shimmerBase,
            borderRadius: AtharRadii.radiusXs,
          ),
        );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          shimmer(80.w, 12.h),
          SizedBox(height: 10.h),
          shimmer(48.w, 28.h),
          SizedBox(height: 10.h),
          shimmer(double.infinity, 36.h),
        ],
      ),
    );
  }
}
