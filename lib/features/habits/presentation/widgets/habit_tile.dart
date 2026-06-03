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
          alignment: AlignmentDirectional.centerStart,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: colorScheme.error,
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
              ? context.colors.success.withValues(alpha: 0.1)
              : colorScheme.surface,
          borderRadius: AtharRadii.radiusLg,
          border: Border.all(
            // ✅ AppColors.primary → colors.primary
            color: isCompletedToday ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: AtharShadows.card,
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
