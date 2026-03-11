import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CalendarStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final weekDates = List.generate(7, (index) {
      return now.add(Duration(days: index - now.weekday + 1));
    });

    return SizedBox(
      height: 70.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AtharSpacing.lg),
        itemCount: weekDates.length,
        separatorBuilder: (ctx, _) => AtharGap.hMd,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected =
              date.day == selectedDate.day && date.month == selectedDate.month;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 50.w,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.onSurface : colorScheme.surface,
                borderRadius: AtharRadii.radiusLg,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.outlineVariant,
                ),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'en').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isSelected
                          ? colorScheme.onPrimary.withValues(alpha: 0.7)
                          : colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AtharGap.xxs,
                  Text(
                    "${date.day}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
//-----------------------------------------------------------------------
// // lib/core/design_system/molecules/strips/calendar_strip.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 1 | File 1.5
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ❌ REMOVED: import '../../themes/app_colors.dart';

// class CalendarStrip extends StatelessWidget {
//   final DateTime selectedDate;
//   final Function(DateTime) onDateSelected;

//   const CalendarStrip({
//     super.key,
//     required this.selectedDate,
//     required this.onDateSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;

//     // توليد أيام الأسبوع الحالي
//     final now = DateTime.now();
//     final weekDates = List.generate(7, (index) {
//       return now.add(Duration(days: index - now.weekday + 1));
//     });

//     return SizedBox(
//       height: 70.h,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         // ✅ EdgeInsets.symmetric(horizontal: 16.w)
//         padding: EdgeInsets.symmetric(horizontal: AtharSpacing.lg),
//         itemCount: weekDates.length,
//         // ✅ SizedBox(width: 12.w) → AtharGap.hMd
//         separatorBuilder: (ctx, _) => AtharGap.hMd,
//         itemBuilder: (context, index) {
//           final date = weekDates[index];
//           final isSelected =
//               date.day == selectedDate.day && date.month == selectedDate.month;

//           return GestureDetector(
//             onTap: () => onDateSelected(date),
//             child: Container(
//               width: 50.w,
//               decoration: BoxDecoration(
//                 // ✅ Colors.black87 → colors.textPrimary (للمحدد)
//                 // ✅ Colors.white → colors.surface
//                 color: isSelected ? colors.textPrimary : colors.surface,
//                 // ✅ BorderRadius.circular(16.r) → AtharRadii.lg
//                 borderRadius: AtharRadii.radiusLg,
//                 border: Border.all(
//                   // ✅ Colors.grey.shade200 → colors.borderLight
//                   color: isSelected ? colors.textPrimary : colors.borderLight,
//                 ),
//                 boxShadow: [
//                   if (!isSelected)
//                     BoxShadow(
//                       // ✅ Colors.black.withOpacity(0.03) → colors.shadow
//                       color: colors.shadow.withValues(alpha: 0.3),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     DateFormat('E', 'en').format(date).toUpperCase(),
//                     // ✅ AtharTypography
//                     style: AtharTypography.labelSmall.copyWith(
//                       // ✅ Colors.white70 / Colors.grey
//                       color: isSelected
//                           ? colors.onPrimary.withValues(alpha: 0.7)
//                           : colors.textTertiary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   // ✅ SizedBox(height: 4.h) → AtharGap.xxs
//                   AtharGap.xxs,
//                   Text(
//                     "${date.day}",
//                     // ✅ AtharTypography
//                     style: AtharTypography.titleMedium.copyWith(
//                       // ✅ Colors.white / AppColors.textPrimary
//                       color: isSelected ? colors.onPrimary : colors.textPrimary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../themes/app_colors.dart';

// class CalendarStrip extends StatelessWidget {
//   final DateTime selectedDate;
//   final Function(DateTime) onDateSelected;

//   const CalendarStrip({
//     super.key,
//     required this.selectedDate,
//     required this.onDateSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // توليد أيام الأسبوع الحالي
//     final now = DateTime.now();
//     final weekDates = List.generate(7, (index) {
//       return now.add(
//         Duration(days: index - now.weekday + 1),
//       ); // يبدأ من الاثنين أو حسب رغبتك
//     });

//     return SizedBox(
//       height: 70.h,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         itemCount: weekDates.length,
//         separatorBuilder: (ctx, _) => SizedBox(width: 12.w),
//         itemBuilder: (context, index) {
//           final date = weekDates[index];
//           final isSelected =
//               date.day == selectedDate.day && date.month == selectedDate.month;

//           return GestureDetector(
//             onTap: () => onDateSelected(date),
//             child: Container(
//               width: 50.w,
//               decoration: BoxDecoration(
//                 color: isSelected ? Colors.black87 : Colors.white,
//                 borderRadius: BorderRadius.circular(16.r),
//                 border: Border.all(
//                   color: isSelected ? Colors.black87 : Colors.grey.shade200,
//                 ),
//                 boxShadow: [
//                   if (!isSelected)
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.03),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     DateFormat(
//                       'E',
//                       'en',
//                     ).format(date).toUpperCase(), // Mon, Tue...
//                     style: TextStyle(
//                       fontSize: 10.sp,
//                       color: isSelected ? Colors.white70 : Colors.grey,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     "${date.day}",
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       color: isSelected ? Colors.white : AppColors.textPrimary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
