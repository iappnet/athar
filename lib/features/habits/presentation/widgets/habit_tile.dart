// lib/features/habits/presentation/widgets/habit_tile.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Part 3 | File 1
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import '../../data/models/habit_model.dart';

/// Semantic colors (not in ColorScheme)
const _successColor = AppColors.success;

class HabitTile extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  final bool readOnly;
  final bool isTemporarilyDone;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    this.onDelete,
    this.readOnly = false,
    this.isTemporarilyDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompletedToday = habit.isCompleted || isTemporarilyDone;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    if (readOnly || onDelete == null) {
      return _buildTileContent(context, colorScheme, isCompletedToday);
    }

    return Opacity(
      opacity: isCompletedToday ? 0.6 : 1.0,
      child: Dismissible(
        key: Key(habit.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFE4A49),
            borderRadius: AtharRadii.radiusLg,
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                // ✅ l10n: "تأكيد الحذف"
                title: Text(l10n.habitTileDeleteConfirmTitle),
                // ✅ l10n: "هل أنت متأكد من حذف هذه العادة؟"
                content: Text(l10n.habitTileDeleteConfirmContent),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    // ✅ l10n: "إلغاء"
                    child: Text(l10n.habitTileDeleteCancel),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // ✅ Colors.red → colors.error
                      backgroundColor: colorScheme.error,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                      if (onDelete != null) onDelete!();
                    },
                    // ✅ l10n: "حذف"
                    child: Text(
                      l10n.habitTileDeleteAction,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (_) {},
        child: _buildTileContent(context, colorScheme, isCompletedToday),
      ),
    );
  }

  Widget _buildTileContent(
    BuildContext context,
    ColorScheme colorScheme,
    bool isCompletedToday,
  ) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: AtharAnimations.normalSlow,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: AtharSpacing.allLg,
        decoration: BoxDecoration(
          // ✅ Colors.green.shade50 / AppColors.surface → colors
          color: isTemporarilyDone
              ? _successColor.withValues(alpha: 0.1)
              : colorScheme.surface,
          borderRadius: AtharRadii.radiusLg,
          border: Border.all(
            // ✅ AppColors.primary → colors.primary
            color: isCompletedToday ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // أيقونة الحالة
                AnimatedContainer(
                  duration: AtharAnimations.normalSlow,
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompletedToday
                        ? colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompletedToday
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: isCompletedToday
                      ? Icon(Icons.check, color: Colors.white, size: 18.sp)
                      : null,
                ),
                AtharGap.hMd,

                Expanded(
                  child: Text(
                    habit.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: isCompletedToday
                          ? TextDecoration.lineThrough
                          : null,
                      // ✅ AppColors.textSecondary / textPrimary → colors
                      color: isCompletedToday
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                ),

                if (habit.currentStreak > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: AtharRadii.radiusSm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 14.sp,
                          color: Colors.orange,
                        ),
                        AtharGap.hXxs,
                        Text(
                          "${habit.currentStreak}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            if (!readOnly) ...[
              AtharGap.lg,
              Divider(height: 1, color: colorScheme.outlineVariant),
              AtharGap.md,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildHistoryBubbles(context, colorScheme),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHistoryBubbles(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    List<Widget> bubbles = [];
    final today = DateTime.now();

    for (int i = 4; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));

      final isDone = habit.completedDays.any(
        (d) =>
            d.year == date.year && d.month == date.month && d.day == date.day,
      );
      final isToday = i == 0;

      bubbles.add(
        Column(
          children: [
            Text(
              DateFormat('E', 'ar').format(date),
              style: TextStyle(
                fontSize: 10.sp,
                // ✅ AppColors.primary / Colors.grey.shade400 → colors
                color: isToday ? colorScheme.primary : colorScheme.outline,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            AtharGap.xs,
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ✅ AppColors.primary → colors.primary
                color: isDone
                    ? (isToday
                          ? colorScheme.primary
                          : colorScheme.primary.withValues(alpha: 0.5))
                    : colorScheme.outlineVariant,
                border: isToday && !isDone
                    ? Border.all(color: colorScheme.primary, width: 1)
                    : null,
              ),
              child: isDone
                  ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                  : null,
            ),
          ],
        ),
      );
    }
    return bubbles;
  }
}
//-----------------------------------------------------------------------
// // lib/features/habits/presentation/widgets/habit_tile.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Part 3 | File 1
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ✅ OLD: import '../../../../core/design_system/themes/app_colors.dart';
// import '../../data/models/habit_model.dart';

// class HabitTile extends StatelessWidget {
//   final HabitModel habit;
//   final VoidCallback onToggle;
//   final VoidCallback? onDelete;
//   final bool readOnly;
//   final bool isTemporarilyDone;

//   const HabitTile({
//     super.key,
//     required this.habit,
//     required this.onToggle,
//     this.onDelete,
//     this.readOnly = false,
//     this.isTemporarilyDone = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isCompletedToday = habit.isCompleted || isTemporarilyDone;
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     if (readOnly || onDelete == null) {
//       return _buildTileContent(context, colors, isCompletedToday);
//     }

//     return Opacity(
//       opacity: isCompletedToday ? 0.6 : 1.0,
//       child: Dismissible(
//         key: Key(habit.id.toString()),
//         direction: DismissDirection.endToStart,
//         background: Container(
//           alignment: Alignment.centerLeft,
//           padding: EdgeInsets.symmetric(horizontal: 20.w),
//           decoration: BoxDecoration(
//             color: const Color(0xFFFE4A49),
//             borderRadius: AtharRadii.radiusLg,
//           ),
//           child: const Icon(Icons.delete, color: Colors.white),
//         ),
//         confirmDismiss: (direction) async {
//           return await showDialog(
//             context: context,
//             builder: (BuildContext ctx) {
//               return AlertDialog(
//                 // ✅ l10n: "تأكيد الحذف"
//                 title: Text(l10n.habitTileDeleteConfirmTitle),
//                 // ✅ l10n: "هل أنت متأكد من حذف هذه العادة؟"
//                 content: Text(l10n.habitTileDeleteConfirmContent),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () => Navigator.of(ctx).pop(false),
//                     // ✅ l10n: "إلغاء"
//                     child: Text(l10n.habitTileDeleteCancel),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       // ✅ Colors.red → colors.error
//                       backgroundColor: colors.error,
//                     ),
//                     onPressed: () {
//                       Navigator.of(ctx).pop(true);
//                       if (onDelete != null) onDelete!();
//                     },
//                     // ✅ l10n: "حذف"
//                     child: Text(
//                       l10n.habitTileDeleteAction,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//         onDismissed: (_) {},
//         child: _buildTileContent(context, colors, isCompletedToday),
//       ),
//     );
//   }

//   Widget _buildTileContent(
//     BuildContext context,
//     AtharColors colors,
//     bool isCompletedToday,
//   ) {
//     return GestureDetector(
//       onTap: onToggle,
//       child: AnimatedContainer(
//         duration: AtharAnimations.normalSlow,
//         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//         padding: AtharSpacing.allLg,
//         decoration: BoxDecoration(
//           // ✅ Colors.green.shade50 / AppColors.surface → colors
//           color: isTemporarilyDone
//               ? colors.success.withValues(alpha: 0.1)
//               : colors.surface,
//           borderRadius: AtharRadii.radiusLg,
//           border: Border.all(
//             // ✅ AppColors.primary → colors.primary
//             color: isCompletedToday ? colors.primary : Colors.transparent,
//             width: 1.5,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: colors.shadow.withValues(alpha: 0.03),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 // أيقونة الحالة
//                 AnimatedContainer(
//                   duration: AtharAnimations.normalSlow,
//                   width: 28.w,
//                   height: 28.w,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isCompletedToday
//                         ? colors.primary
//                         : Colors.transparent,
//                     border: Border.all(
//                       color: isCompletedToday
//                           ? colors.primary
//                           : colors.borderLight,
//                       width: 2,
//                     ),
//                   ),
//                   child: isCompletedToday
//                       ? Icon(Icons.check, color: Colors.white, size: 18.sp)
//                       : null,
//                 ),
//                 AtharGap.hMd,

//                 Expanded(
//                   child: Text(
//                     habit.title,
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       decoration: isCompletedToday
//                           ? TextDecoration.lineThrough
//                           : null,
//                       // ✅ AppColors.textSecondary / textPrimary → colors
//                       color: isCompletedToday
//                           ? colors.textSecondary
//                           : colors.textPrimary,
//                     ),
//                   ),
//                 ),

//                 if (habit.currentStreak > 0)
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.withValues(alpha: 0.1),
//                       borderRadius: AtharRadii.radiusSm,
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.local_fire_department,
//                           size: 14.sp,
//                           color: Colors.orange,
//                         ),
//                         SizedBox(width: 4.w),
//                         Text(
//                           "${habit.currentStreak}",
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Colors.orange,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),

//             if (!readOnly) ...[
//               AtharGap.lg,
//               Divider(height: 1, color: colors.borderLight),
//               AtharGap.md,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: _buildHistoryBubbles(context, colors),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildHistoryBubbles(BuildContext context, AtharColors colors) {
//     List<Widget> bubbles = [];
//     final today = DateTime.now();

//     for (int i = 4; i >= 0; i--) {
//       final date = today.subtract(Duration(days: i));

//       final isDone = habit.completedDays.any(
//         (d) =>
//             d.year == date.year && d.month == date.month && d.day == date.day,
//       );
//       final isToday = i == 0;

//       bubbles.add(
//         Column(
//           children: [
//             Text(
//               DateFormat('E', 'ar').format(date),
//               style: TextStyle(
//                 fontSize: 10.sp,
//                 // ✅ AppColors.primary / Colors.grey.shade400 → colors
//                 color: isToday ? colors.primary : colors.textTertiary,
//                 fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
//               ),
//             ),
//             SizedBox(height: 6.h),
//             Container(
//               width: 30.w,
//               height: 30.w,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 // ✅ AppColors.primary → colors.primary
//                 color: isDone
//                     ? (isToday
//                           ? colors.primary
//                           : colors.primary.withValues(alpha: 0.5))
//                     : colors.borderLight,
//                 border: isToday && !isDone
//                     ? Border.all(color: colors.primary, width: 1)
//                     : null,
//               ),
//               child: isDone
//                   ? Icon(Icons.check, color: Colors.white, size: 16.sp)
//                   : null,
//             ),
//           ],
//         ),
//       );
//     }
//     return bubbles;
//   }
// }
//-----------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../data/models/habit_model.dart';

// class HabitTile extends StatelessWidget {
//   final HabitModel habit;
//   final VoidCallback onToggle;
//   final VoidCallback? onDelete;
//   final bool readOnly;
//   final bool isTemporarilyDone; // للأنيميشن في الداشبورد

//   const HabitTile({
//     super.key,
//     required this.habit,
//     required this.onToggle,
//     this.onDelete,
//     this.readOnly = false,
//     this.isTemporarilyDone = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ تصحيح الخطأ: استبدال isCompletedToday بـ isCompleted
//     final isCompletedToday = habit.isCompleted || isTemporarilyDone;

//     // ✅ إذا كانت للقراءة فقط (أذكار) أو لا يوجد دالة حذف، نعرض المحتوى مباشرة بدون سحب
//     if (readOnly || onDelete == null) {
//       return _buildTileContent(context, isCompletedToday);
//     }

//     return Opacity(
//       opacity: isCompletedToday ? 0.6 : 1.0, // شفافية 60% للمكتمل
//       child: Dismissible(
//         key: Key(habit.id.toString()), // مفتاح فريد
//         direction: DismissDirection.endToStart,
//         background: Container(
//           alignment: Alignment.centerLeft,
//           padding: EdgeInsets.symmetric(horizontal: 20.w),
//           decoration: BoxDecoration(
//             color: const Color(0xFFFE4A49),
//             borderRadius: BorderRadius.circular(16.r),
//           ),
//           child: const Icon(Icons.delete, color: Colors.white),
//         ),
//         // ✅✅ تأكيد الحذف ✅✅
//         confirmDismiss: (direction) async {
//           return await showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text("تأكيد الحذف"),
//                 content: const Text("هل أنت متأكد من حذف هذه العادة؟"),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(false), // إلغاء
//                     child: const Text("إلغاء"),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).pop(true); // تأكيد
//                       // نستدعي الحذف هنا بعد إغلاق الديالوج لضمان سلامة الشجرة
//                       if (onDelete != null) onDelete!();
//                     },
//                     child: const Text(
//                       "حذف",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//         onDismissed: (_) {},
//         child: _buildTileContent(context, isCompletedToday),
//       ),
//     );
//   }

//   Widget _buildTileContent(BuildContext context, bool isCompletedToday) {
//     return GestureDetector(
//       onTap: onToggle,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: isTemporarilyDone ? Colors.green.shade50 : AppColors.surface,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(
//             color: isCompletedToday ? AppColors.primary : Colors.transparent,
//             width: 1.5,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.03),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 // أيقونة الحالة
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   width: 28.w,
//                   height: 28.w,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isCompletedToday
//                         ? AppColors.primary
//                         : Colors.transparent,
//                     border: Border.all(
//                       color: isCompletedToday
//                           ? AppColors.primary
//                           : Colors.grey.shade300,
//                       width: 2,
//                     ),
//                   ),
//                   child: isCompletedToday
//                       ? Icon(Icons.check, color: Colors.white, size: 18.sp)
//                       : null,
//                 ),
//                 SizedBox(width: 12.w),

//                 Expanded(
//                   child: Text(
//                     habit.title,
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       decoration: isCompletedToday
//                           ? TextDecoration.lineThrough
//                           : null,
//                       color: isCompletedToday
//                           ? AppColors.textSecondary
//                           : AppColors.textPrimary,
//                     ),
//                   ),
//                 ),

//                 if (habit.currentStreak > 0)
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.local_fire_department,
//                           size: 14.sp,
//                           color: Colors.orange,
//                         ),
//                         SizedBox(width: 4.w),
//                         Text(
//                           "${habit.currentStreak}",
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Colors.orange,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),

//             // إظهار شريط التاريخ فقط إذا لم تكن للقراءة فقط (لتقليل الضوضاء البصرية في الأذكار)
//             if (!readOnly) ...[
//               SizedBox(height: 16.h),
//               Divider(height: 1, color: Colors.grey.shade100),
//               SizedBox(height: 12.h),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: _buildHistoryBubbles(context),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildHistoryBubbles(BuildContext context) {
//     List<Widget> bubbles = [];
//     final today = DateTime.now();

//     for (int i = 4; i >= 0; i--) {
//       final date = today.subtract(Duration(days: i));

//       // هنا نستخدم completedDays للتحقق من التاريخ القديم
//       final isDone = habit.completedDays.any(
//         (d) =>
//             d.year == date.year && d.month == date.month && d.day == date.day,
//       );
//       final isToday = i == 0;

//       bubbles.add(
//         Column(
//           children: [
//             Text(
//               DateFormat('E', 'ar').format(date),
//               style: TextStyle(
//                 fontSize: 10.sp,
//                 color: isToday ? AppColors.primary : Colors.grey.shade400,
//                 fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
//               ),
//             ),
//             SizedBox(height: 6.h),
//             Container(
//               width: 30.w,
//               height: 30.w,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isDone
//                     ? (isToday
//                           ? AppColors.primary
//                           : AppColors.primary.withValues(alpha: 0.5))
//                     : Colors.grey.shade100,
//                 border: isToday && !isDone
//                     ? Border.all(color: AppColors.primary, width: 1)
//                     : null,
//               ),
//               child: isDone
//                   ? Icon(Icons.check, color: Colors.white, size: 16.sp)
//                   : null,
//             ),
//           ],
//         ),
//       );
//     }
//     return bubbles;
//   }
// }
