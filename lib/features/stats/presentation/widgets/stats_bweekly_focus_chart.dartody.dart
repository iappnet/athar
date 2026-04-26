import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class WeeklyFocusChart extends StatelessWidget {
  final List<int> weeklyData;

  const WeeklyFocusChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    double maxY = weeklyData
        .reduce((curr, next) => curr > next ? curr : next)
        .toDouble();
    if (maxY == 0) maxY = 60;

    final totalMinutes = weeklyData.reduce((a, b) => a + b);

    return Container(
      height: 200.h,
      padding: AtharSpacing.allXl,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsWeeklyFocusTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          AtharGap.xxs,
          Text(
            l10n.statsWeeklyFocusTotal(totalMinutes),
            style: TextStyle(color: colorScheme.outline, fontSize: 12.sp),
          ),
          AtharGap.xl,
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        l10n.statsMinutesAbbr(rod.toY.round()),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final today = DateTime.now();
                        final date = today.subtract(
                          Duration(days: 6 - value.toInt()),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('E', 'ar').format(date),
                            style: TextStyle(
                              color: colorScheme.outline,
                              fontSize: 10.sp,
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
                barGroups: weeklyData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: entry.key == 6
                            ? colorScheme.primary
                            : colorScheme.primary.withValues(alpha: 0.3),
                        width: 16.w,
                        borderRadius: AtharRadii.radiusXxs,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY * 1.2,
                          color: colorScheme.outline.withValues(alpha: 0.1),
                        ),
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
//-----------------------------------------------------------------------// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/design_system/themes/app_colors.dart';

// class WeeklyFocusChart extends StatelessWidget {
//   final List<int> weeklyData; // مصفوفة من 7 أرقام (دقائق لكل يوم)

//   const WeeklyFocusChart({super.key, required this.weeklyData});

//   @override
//   Widget build(BuildContext context) {
//     // أقصى قيمة في البيانات لتحديد ارتفاع الرسم
//     double maxY = weeklyData
//         .reduce((curr, next) => curr > next ? curr : next)
//         .toDouble();
//     if (maxY == 0) maxY = 60; // افتراضي ساعة واحدة

//     return Container(
//       height: 200.h,
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "تركيزي هذا الأسبوع",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             "${weeklyData.reduce((a, b) => a + b)} دقيقة إجمالية",
//             style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//           ),
//           SizedBox(height: 20.h),
//           Expanded(
//             child: BarChart(
//               BarChartData(
//                 alignment: BarChartAlignment.spaceAround,
//                 maxY: maxY * 1.2, // مساحة إضافية في الأعلى
//                 barTouchData: BarTouchData(
//                   touchTooltipData: BarTouchTooltipData(
//                     getTooltipColor: (_) => Colors.black87,
//                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                       return BarTooltipItem(
//                         '${rod.toY.round()} د',
//                         const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 titlesData: FlTitlesData(
//                   show: true,
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         // حساب اسم اليوم (سبت، أحد...)
//                         final today = DateTime.now();
//                         // لأن البيانات تأتي مرتبة من (قبل 6 أيام) إلى (اليوم)
//                         // المعادلة: اليوم الحالي - (6 - المؤشر)
//                         final date = today.subtract(
//                           Duration(days: 6 - value.toInt()),
//                         );
//                         return Padding(
//                           padding: const EdgeInsets.only(top: 8.0),
//                           child: Text(
//                             DateFormat('E', 'ar').format(date),
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 10.sp,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   leftTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   topTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                   rightTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 gridData: const FlGridData(show: false),
//                 barGroups: weeklyData.asMap().entries.map((entry) {
//                   return BarChartGroupData(
//                     x: entry.key,
//                     barRods: [
//                       BarChartRodData(
//                         toY: entry.value.toDouble(),
//                         color: entry.key == 6
//                             ? AppColors.primary
//                             : AppColors.primary.withValues(
//                                 alpha: 0.3,
//                               ), // تمييز اليوم الحالي
//                         width: 16.w,
//                         borderRadius: BorderRadius.circular(4),
//                         backDrawRodData: BackgroundBarChartRodData(
//                           show: true,
//                           toY: maxY * 1.2, // الخلفية الرمادية الباهتة
//                           color: Colors.grey.withValues(alpha: 0.1),
//                         ),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
