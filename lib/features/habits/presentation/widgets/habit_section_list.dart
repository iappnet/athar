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
          padding: EdgeInsetsDirectional.fromSTEB(AtharSpacing.xl, AtharSpacing.xxl, AtharSpacing.xl, AtharSpacing.md),
          child: Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 18.sp)),
              AtharGap.hSm,
              Text(
                title,
                style: AtharTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: AtharTypography.fontFallback,
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
