// lib/features/habits/presentation/widgets/habit_section_list.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Part 3 | File 3
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/design_system.dart';

// ✅ OLD: import '../../../../core/design_system/themes/app_colors.dart';
import '../../../../core/design_system/molecules/tiles/minimal_habit_tile.dart';
import '../../data/models/habit_model.dart';

class HabitSectionList extends StatelessWidget {
  final String title;
  final String emoji;
  final List<HabitModel> habits;
  final Function(HabitModel) onToggle;
  final Function(HabitModel) onTap;
  final DateTime selectedDate;
  final Function(HabitModel) onEdit;
  final Function(HabitModel) onDelete;

  const HabitSectionList({
    super.key,
    required this.title,
    required this.emoji,
    required this.habits,
    required this.onToggle,
    required this.onTap,
    required this.selectedDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) return const SizedBox.shrink();

    // ✅ Get colors from context
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
          child: Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 18.sp)),
              AtharGap.hSm,
              Text(
                title,
                style: AtharTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  // ✅ AppColors.textSerif → colors.textPrimary
                  color: colors.textPrimary,
                ),
              ),
              AtharGap.hSm,
              // خط فاصل ناعم
              Expanded(child: Divider(color: colors.borderLight, thickness: 1)),
            ],
          ),
        ),

        // قائمة العادات
        ...habits.map(
          (habit) => MinimalHabitTile(
            habit: habit,
            isCompletedOnSelectedDate: habit.completedDays.any(
              (d) =>
                  d.year == selectedDate.year &&
                  d.month == selectedDate.month &&
                  d.day == selectedDate.day,
            ),
            onToggle: () => onToggle(habit),
            onTap: () => onTap(habit),
            onEdit: () => onEdit(habit),
            onDelete: () => onDelete(habit),
          ),
        ),
      ],
    );
  }
}
//-----------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../../core/design_system/molecules/tiles/minimal_habit_tile.dart';
// import '../../data/models/habit_model.dart';

// class HabitSectionList extends StatelessWidget {
//   final String title;
//   final String emoji; // أيقونة تعبيرية بجانب العنوان (مثلاً 🌅)
//   final List<HabitModel> habits;
//   final Function(HabitModel) onToggle;
//   final Function(HabitModel) onTap;
//   final DateTime selectedDate; // ✅ إضافة التاريخ
//   // final Function(HabitModel) onLongPress; // ✅ إضافة الضغط المطول
//   // ✅ إضافة الكولباك الجديدة
//   final Function(HabitModel) onEdit;
//   final Function(HabitModel) onDelete;

//   const HabitSectionList({
//     super.key,
//     required this.title,
//     required this.emoji,
//     required this.habits,
//     required this.onToggle,
//     required this.onTap,
//     required this.selectedDate,
//     // required this.onLongPress,
//     required this.onEdit, // ✅
//     required this.onDelete, // ✅
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (habits.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // عنوان القسم
//         Padding(
//           padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
//           child: Row(
//             children: [
//               Text(emoji, style: TextStyle(fontSize: 18.sp)),
//               SizedBox(width: 8.w),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Cairo', // خط العناوين
//                   color: AppColors.textSerif,
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               // خط فاصل ناعم
//               Expanded(
//                 child: Divider(
//                   color: Colors.grey.withValues(alpha: 0.2),
//                   thickness: 1,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // قائمة العادات
//         ...habits.map(
//           (habit) => MinimalHabitTile(
//             habit: habit,
//             isCompletedOnSelectedDate: habit.completedDays.any(
//               (d) =>
//                   d.year == selectedDate.year &&
//                   d.month == selectedDate.month &&
//                   d.day == selectedDate.day,
//             ),
//             onToggle: () => onToggle(habit),
//             onTap: () => onTap(habit),

//             // ✅ تمرير الدوال للتايل
//             onEdit: () => onEdit(habit),
//             onDelete: () => onDelete(habit),
//           ),
//         ),
//       ],
//     );
//   }
// }
//-----------------------------------------------------------------------
