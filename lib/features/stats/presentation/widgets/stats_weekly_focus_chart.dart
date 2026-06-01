import 'package:athar/core/design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// Bare weekly/period focus bar chart — no outer container.
/// Wrap in ChartCard at the call site.
/// Expects [weeklyData] ordered oldest → newest (index 0 = oldest day).
/// Pass [rangeDays] to correctly calculate x-axis date labels.
class WeeklyFocusChart extends StatelessWidget {
  final List<int> weeklyData;
  final int rangeDays;

  const WeeklyFocusChart({
    super.key,
    required this.weeklyData,
    this.rangeDays = 7,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    final data = isRtl ? weeklyData.reversed.toList() : weeklyData;
    final n = data.length;

    double maxY = data.fold(0, (m, v) => v > m ? v.toDouble() : m);
    if (maxY == 0) maxY = 60;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => colors.textPrimary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}د',
                AtharTypography.labelSmall.copyWith(
                  color: colors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: n <= 10,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= n) return const SizedBox.shrink();
                final today = DateTime.now();
                final dayOffset = isRtl ? idx : (n - 1 - idx);
                final date = today.subtract(Duration(days: dayOffset));
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('E', 'ar').format(date),
                    style: AtharTypography.labelSmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final isMostRecent = isRtl ? entry.key == 0 : entry.key == n - 1;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: isMostRecent
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0.3),
                width: 12.w,
                borderRadius: AtharRadii.radiusXxs,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY * 1.2,
                  color: colors.border.withValues(alpha: 0.12),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
