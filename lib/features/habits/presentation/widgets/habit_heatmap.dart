// lib/features/habits/presentation/widgets/habit_heatmap.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Part 3 | File 4
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/design_system.dart';

// ✅ OLD: import '../../../../core/design_system/themes/app_colors.dart';

class HabitHeatmap extends StatelessWidget {
  final Map<DateTime, int> datasets;

  const HabitHeatmap({super.key, required this.datasets});

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors & l10n from context
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        // ✅ AppColors.surface → colors.surface
        color: colors.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: [
          BoxShadow(
            // ✅ Colors.black → colors.shadow
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // ✅ l10n: "خارطة الالتزام"
            l10n.habitHeatmapTitle,
            style: AtharTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              // ✅ AppColors.textPrimary → colors.textPrimary
              color: colors.textPrimary,
            ),
          ),
          AtharGap.md,
          HeatMap(
            datasets: datasets,
            colorMode: ColorMode.opacity,
            showText: false,
            scrollable: true,
            startDate: DateTime.now().subtract(const Duration(days: 90)),
            endDate: DateTime.now().add(const Duration(days: 10)),
            colorsets: {
              // ✅ AppColors.primary → colors.primary
              1: colors.primary.withValues(alpha: 0.2),
              3: colors.primary.withValues(alpha: 0.4),
              5: colors.primary.withValues(alpha: 0.6),
              7: colors.primary.withValues(alpha: 0.8),
              10: colors.primary,
            },
            onClick: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  // ✅ l10n: "إنجازات يوم: {day}/{month}"
                  content: Text(
                    l10n.habitHeatmapDayAchievements(
                      value.day.toString(),
                      value.month.toString(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
//-----------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';

// class HabitHeatmap extends StatelessWidget {
//   final Map<DateTime, int> datasets; // التاريخ: عدد العادات المنجزة

//   const HabitHeatmap({super.key, required this.datasets});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
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
//             "خارطة الالتزام",
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           HeatMap(
//             datasets: datasets,
//             colorMode: ColorMode.opacity,
//             showText: false,
//             scrollable: true,
//             startDate: DateTime.now().subtract(
//               const Duration(days: 90),
//             ), // آخر 3 أشهر
//             endDate: DateTime.now().add(const Duration(days: 10)),
//             colorsets: {
//               1: AppColors.primary.withValues(alpha: 0.2),
//               3: AppColors.primary.withValues(alpha: 0.4),
//               5: AppColors.primary.withValues(alpha: 0.6),
//               7: AppColors.primary.withValues(alpha: 0.8),
//               10: AppColors.primary, // كلما زاد الرقم زادت دكانة اللون
//             },
//             onClick: (value) {
//               // يمكن إضافة تفاعل هنا لاحقاً لعرض تفاصيل ذلك اليوم
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text("إنجازات يوم: ${value.day}/${value.month}"),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
