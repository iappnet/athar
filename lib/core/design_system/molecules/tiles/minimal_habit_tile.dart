import 'package:athar/core/design_system/tokens/athar_animations.dart';
import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../features/habits/data/models/habit_model.dart';

class MinimalHabitTile extends StatelessWidget {
  final HabitModel habit;
  final bool isCompletedOnSelectedDate;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MinimalHabitTile({
    super.key,
    required this.habit,
    required this.isCompletedOnSelectedDate,
    required this.onToggle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = isCompletedOnSelectedDate;

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.horizontal,
      // Swipe right → edit
      background: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AtharSpacing.lg,
          vertical: AtharSpacing.xs,
        ),
        padding: EdgeInsets.only(right: AtharSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: AtharRadii.radiusLg,
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.edit, color: colorScheme.onPrimary),
      ),

      // Swipe left → delete
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AtharSpacing.lg,
          vertical: AtharSpacing.xs,
        ),
        padding: EdgeInsets.only(left: AtharSpacing.xl),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: AtharRadii.radiusLg,
        ),
        alignment: Alignment.centerLeft,
        child: Icon(Icons.delete, color: colorScheme.onPrimary),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        } else {
          onDelete();
          return false;
        }
      },

      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          duration: AtharAnimations.slow,
          opacity: isCompleted ? 0.6 : 1.0,
          child: AnimatedContainer(
            duration: AtharAnimations.normal,
            margin: EdgeInsets.symmetric(
              horizontal: AtharSpacing.lg,
              vertical: AtharSpacing.xs,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AtharSpacing.lg,
              vertical: AtharSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: AtharRadii.radiusLg,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(
                    alpha: isCompleted ? 0.1 : 0.3,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Toggle button
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: AtharAnimations.normal,
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF00B894)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? const Color(0xFF00B894)
                            : colorScheme.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: colorScheme.onPrimary,
                            size: 16.sp,
                          )
                        : null,
                  ),
                ),

                AtharGap.hLg,

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? colorScheme.outline
                              : colorScheme.onSurface,
                        ),
                      ),
                      // Athkar progress
                      if (habit.type == HabitType.athkar)
                        Padding(
                          padding: EdgeInsets.only(top: AtharSpacing.xxs),
                          child: LinearProgressIndicator(
                            value:
                                habit.currentProgress /
                                (habit.target == 0 ? 1 : habit.target),
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            color: colorScheme.primary.withValues(alpha: 0.5),
                            minHeight: 4.h,
                            borderRadius: AtharRadii.radiusXs,
                          ),
                        ),
                    ],
                  ),
                ),

                // Streak badge
                if (habit.currentStreak > 0)
                  _buildStreakBadge(colorScheme, habit.currentStreak),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge(ColorScheme colorScheme, int streak) {
    final isCompleted = isCompletedOnSelectedDate;
    return Opacity(
      opacity: isCompleted ? 0.5 : 1.0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AtharSpacing.sm,
          vertical: AtharSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: AtharRadii.radiusSm,
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange,
              size: 14.sp,
            ),
            AtharGap.hXxs,
            Text(
              "$streak",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//-----------------------------------------------------------------------
// // lib/core/design_system/molecules/tiles/minimal_habit_tile.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 1 | File 1.9
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ❌ REMOVED: import '../../themes/app_colors.dart';

// import '../../../../features/habits/data/models/habit_model.dart';

// class MinimalHabitTile extends StatelessWidget {
//   final HabitModel habit;
//   final bool isCompletedOnSelectedDate;
//   final VoidCallback onToggle;
//   final VoidCallback onTap;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const MinimalHabitTile({
//     super.key,
//     required this.habit,
//     required this.isCompletedOnSelectedDate,
//     required this.onToggle,
//     required this.onTap,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;
//     final isCompleted = isCompletedOnSelectedDate;

//     return Dismissible(
//       key: ValueKey(habit.id),
//       direction: DismissDirection.horizontal,
//       // خلفية السحب لليمين (تعديل)
//       background: Container(
//         margin: EdgeInsets.symmetric(
//           horizontal: AtharSpacing.lg,
//           vertical: AtharSpacing.xs,
//         ),
//         padding: EdgeInsets.only(right: AtharSpacing.xl),
//         decoration: BoxDecoration(
//           // ✅ Colors.blueAccent → colors.info
//           color: colors.info,
//           borderRadius: AtharRadii.radiusLg,
//         ),
//         alignment: Alignment.centerRight,
//         child: Icon(Icons.edit, color: colors.onPrimary),
//       ),

//       // خلفية السحب لليسار (حذف)
//       secondaryBackground: Container(
//         margin: EdgeInsets.symmetric(
//           horizontal: AtharSpacing.lg,
//           vertical: AtharSpacing.xs,
//         ),
//         padding: EdgeInsets.only(left: AtharSpacing.xl),
//         decoration: BoxDecoration(
//           // ✅ Colors.redAccent → colors.error
//           color: colors.error,
//           borderRadius: AtharRadii.radiusLg,
//         ),
//         alignment: Alignment.centerLeft,
//         child: Icon(Icons.delete, color: colors.onPrimary),
//       ),

//       confirmDismiss: (direction) async {
//         if (direction == DismissDirection.startToEnd) {
//           onEdit();
//           return false;
//         } else {
//           onDelete();
//           return false;
//         }
//       },

//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedOpacity(
//           // ✅ AtharAnimations.slow
//           duration: AtharAnimations.slow,
//           opacity: isCompleted ? 0.6 : 1.0,
//           child: AnimatedContainer(
//             // ✅ AtharAnimations.normal
//             duration: AtharAnimations.normal,
//             margin: EdgeInsets.symmetric(
//               horizontal: AtharSpacing.lg,
//               vertical: AtharSpacing.xs,
//             ),
//             padding: EdgeInsets.symmetric(
//               horizontal: AtharSpacing.lg,
//               vertical: AtharSpacing.lg,
//             ),
//             decoration: BoxDecoration(
//               // ✅ Colors.white → colors.surface
//               color: colors.surface,
//               borderRadius: AtharRadii.radiusLg,
//               boxShadow: [
//                 BoxShadow(
//                   color: colors.shadow.withValues(
//                     alpha: isCompleted ? 0.1 : 0.3,
//                   ),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 // 1. زر التفاعل
//                 GestureDetector(
//                   onTap: onToggle,
//                   child: AnimatedContainer(
//                     duration: AtharAnimations.normal,
//                     width: 28.w,
//                     height: 28.w,
//                     decoration: BoxDecoration(
//                       // ✅ AppColors.success → colors.success
//                       color: isCompleted ? colors.success : Colors.transparent,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         // ✅ Colors.grey.shade300 → colors.borderLight
//                         color: isCompleted
//                             ? colors.success
//                             : colors.borderLight,
//                         width: 2,
//                       ),
//                     ),
//                     child: isCompleted
//                         ? Icon(
//                             Icons.check,
//                             color: colors.onPrimary,
//                             size: 16.sp,
//                           )
//                         : null,
//                   ),
//                 ),

//                 // ✅ SizedBox(width: 16.w) → AtharGap.hLg
//                 AtharGap.hLg,

//                 // 2. المحتوى
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         habit.title,
//                         // ✅ AtharTypography
//                         style: AtharTypography.titleSmall.copyWith(
//                           // ✅ AppColors.dimmedText / AppColors.textPrimary
//                           color: isCompleted
//                               ? colors.textTertiary
//                               : colors.textPrimary,
//                         ),
//                       ),
//                       // إظهار تقدم الأذكار
//                       if (habit.type == HabitType.athkar)
//                         Padding(
//                           padding: EdgeInsets.only(top: AtharSpacing.xxs),
//                           child: LinearProgressIndicator(
//                             value:
//                                 habit.currentProgress /
//                                 (habit.target == 0 ? 1 : habit.target),
//                             // ✅ Colors.grey.shade100 → colors.background
//                             backgroundColor: colors.background,
//                             // ✅ AppColors.primary → colors.primary
//                             color: colors.primary.withValues(alpha: 0.5),
//                             minHeight: 4.h,
//                             borderRadius: AtharRadii.radiusXs,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//                 // 3. السلسلة
//                 if (habit.currentStreak > 0)
//                   _buildStreakBadge(colors, habit.currentStreak),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStreakBadge(AtharColors colors, int streak) {
//     final isCompleted = isCompletedOnSelectedDate;
//     return Opacity(
//       opacity: isCompleted ? 0.5 : 1.0,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: AtharSpacing.sm,
//           vertical: AtharSpacing.xxs,
//         ),
//         decoration: BoxDecoration(
//           // ✅ Colors.orange → colors.warning
//           color: colors.warning.withValues(alpha: 0.1),
//           borderRadius: AtharRadii.radiusSm,
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.local_fire_department_rounded,
//               color: colors.warning,
//               size: 14.sp,
//             ),
//             AtharGap.hXxs,
//             Text(
//               "$streak",
//               // ✅ AtharTypography
//               style: AtharTypography.labelMedium.copyWith(
//                 color: colors.warning,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../themes/app_colors.dart';
// import '../../../../features/habits/data/models/habit_model.dart';

// class MinimalHabitTile extends StatelessWidget {
//   final HabitModel habit;
//   final bool
//   isCompletedOnSelectedDate; // ✅ متغير جديد: الحالة بناءً على التاريخ
//   final VoidCallback onToggle;
//   final VoidCallback onTap;
//   // final VoidCallback onLongPress; // ✅ للإجراءات الإضافية (حذف/تعديل)

//   // ✅ دوال جديدة للسحب
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const MinimalHabitTile({
//     super.key,
//     required this.habit,
//     required this.isCompletedOnSelectedDate,
//     required this.onToggle,
//     required this.onTap,
//     // required this.onLongPress,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // نستخدم المتغير الممرر بدلاً من المتغير الداخلي للعادة
//     final isCompleted = isCompletedOnSelectedDate;

//     // ✅ 1. استخدام Dismissible للسحب
//     return Dismissible(
//       key: ValueKey(habit.id), // مفتاح فريد ضروري
//       direction: DismissDirection.horizontal, // السحب لليمين واليسار
//       // خلفية السحب لليمين (تعديل - أزرق/أخضر)
//       background: Container(
//         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//         padding: EdgeInsets.only(right: 20.w), // للمحاذاة العربية
//         decoration: BoxDecoration(
//           color: Colors.blueAccent,
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         alignment: Alignment.centerRight,
//         child: const Icon(Icons.edit, color: Colors.white),
//       ),

//       // خلفية السحب ليسار (حذف - أحمر)
//       secondaryBackground: Container(
//         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//         padding: EdgeInsets.only(left: 20.w),
//         decoration: BoxDecoration(
//           color: Colors.redAccent,
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         alignment: Alignment.centerLeft,
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),

//       // منطق التأكيد (لمنع الحذف المباشر عند التعديل)
//       confirmDismiss: (direction) async {
//         if (direction == DismissDirection.startToEnd) {
//           // سحب لليمين -> تعديل
//           onEdit();
//           return false; // لا تحذف العنصر من الشجرة
//         } else {
//           // سحب لليسار -> حذف
//           onDelete();
//           return false; // نرجع false لأننا سنظهر ديالوج تأكيد الحذف في الصفحة
//         }
//       },

//       child: GestureDetector(
//         onTap: onTap,
//         // ✅ 2. تطبيق التلاشي (Fade Out) عند الإنجاز
//         child: AnimatedOpacity(
//           duration: const Duration(milliseconds: 500),
//           opacity: isCompleted ? 0.6 : 1.0, // تصبح باهتة
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.r),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: isCompleted ? 0.01 : 0.03),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 // 1. زر التفاعل
//                 GestureDetector(
//                   onTap: onToggle,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     width: 28.w,
//                     height: 28.w,
//                     decoration: BoxDecoration(
//                       color: isCompleted
//                           ? AppColors.success
//                           : Colors.transparent,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: isCompleted
//                             ? AppColors.success
//                             : Colors.grey.shade300,
//                         width: 2,
//                       ),
//                     ),
//                     child: isCompleted
//                         ? Icon(Icons.check, color: Colors.white, size: 16.sp)
//                         : null,
//                   ),
//                 ),

//                 SizedBox(width: 16.w),

//                 // 2. المحتوى
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         habit.title,
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Cairo',
//                           decoration: isCompleted
//                               ? TextDecoration.none
//                               : TextDecoration.none,
//                           color: isCompleted
//                               ? AppColors.dimmedText
//                               : AppColors.textPrimary,
//                         ),
//                       ),
//                       // إظهار تقدم الأذكار إذا كانت من نوع أذكار
//                       if (habit.type == HabitType.athkar)
//                         Padding(
//                           padding: EdgeInsets.only(top: 4.h),
//                           child: LinearProgressIndicator(
//                             value:
//                                 habit.currentProgress /
//                                 (habit.target == 0 ? 1 : habit.target),
//                             backgroundColor: Colors.grey.shade100,
//                             color: AppColors.primary.withValues(alpha: 0.5),
//                             minHeight: 4.h,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//                 // 3. السلسلة
//                 if (habit.currentStreak > 0)
//                   _buildStreakBadge(habit.currentStreak),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStreakBadge(int streak) {
//     // نستخدم المتغير الممرر بدلاً من المتغير الداخلي للعادة
//     final isCompleted = isCompletedOnSelectedDate;
//     return Opacity(
//       opacity: isCompleted ? 0.5 : 1.0, // حتى السلسلة تبهت قليلاً
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//         decoration: BoxDecoration(
//           color: Colors.orange.withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.local_fire_department_rounded,
//               color: Colors.orange,
//               size: 14.sp,
//             ),
//             SizedBox(width: 4.w),
//             Text(
//               "$streak",
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: Colors.orange,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
