import 'package:athar/core/design_system/tokens.dart';
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
    final colors = context.colors;
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
        padding: EdgeInsetsDirectional.only(end: AtharSpacing.xl),
        decoration: BoxDecoration(
          color: colors.info,
          borderRadius: AtharRadii.radiusLg,
        ),
        alignment: AlignmentDirectional.centerEnd,
        child: Icon(Icons.edit, color: colorScheme.onPrimary),
      ),

      // Swipe left → delete
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AtharSpacing.lg,
          vertical: AtharSpacing.xs,
        ),
        padding: EdgeInsetsDirectional.only(start: AtharSpacing.xl),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: AtharRadii.radiusLg,
        ),
        alignment: AlignmentDirectional.centerStart,
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
                          ? colors.success
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? colors.success
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
                          fontFamily: AtharTypography.fontFamily,
                          fontFamilyFallback: AtharTypography.fontFallback,
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
                  _buildStreakBadge(colors, habit.currentStreak),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge(AtharColors colors, int streak) {
    final isCompleted = isCompletedOnSelectedDate;
    return Opacity(
      opacity: isCompleted ? 0.5 : 1.0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AtharSpacing.sm,
          vertical: AtharSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.warning.withValues(alpha: 0.1),
          borderRadius: AtharRadii.radiusSm,
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: colors.warning,
              size: 14.sp,
            ),
            AtharGap.hXxs,
            Text(
              "$streak",
              style: TextStyle(
                fontSize: 12.sp,
                color: colors.warning,
                fontWeight: FontWeight.bold,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
