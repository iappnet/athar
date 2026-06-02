import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:athar/features/home/domain/entities/daily_item.dart';

class UnifiedTimelineTile extends StatelessWidget {
  final DailyItem item;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const UnifiedTimelineTile({
    super.key,
    required this.item,
    required this.onToggle,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final color = _getColor(colorScheme, colors);
    final icon = _getIcon();
    final isCompleted = item.isCompleted;

    return Dismissible(
      key: Key(item.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsetsDirectional.only(start: AtharSpacing.xl),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onPrimary),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AtharSpacing.lg,
            vertical: AtharSpacing.xs,
          ),
          padding: AtharSpacing.allLg,
          decoration: BoxDecoration(
            color: isCompleted
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            borderRadius: AtharRadii.radiusLg,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: BorderDirectional(
              end: BorderSide(
                color: color.withValues(alpha: 0.4),
                width: 4.w,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildActionCircle(colorScheme, isCompleted, color),

              AtharGap.hLg,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 14.sp, color: color),
                        AtharGap.hXs,
                        Text(
                          _getTypeLabel(l10n),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Calibri',
                            fontFamilyFallback: AtharTypography.fontFallback,
                          ),
                        ),
                        if (item.hasReminder)
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 12.sp,
                            color: color,
                          ),
                        const Spacer(),
                        Text(
                          DateFormat('hh:mm a').format(item.time),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    AtharGap.xs,
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted
                            ? colorScheme.outline
                            : colorScheme.onSurface,
                        fontFamily: 'Calibri',
                        fontFamilyFallback: AtharTypography.fontFallback,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      AtharGap.xxxs,
                      Text(
                        item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCircle(ColorScheme colorScheme, bool isDone, Color color) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: AtharAnimations.normal,
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          color: isDone ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDone ? color : colorScheme.outlineVariant,
            width: 2,
          ),
        ),
        child: isDone
            ? Icon(Icons.check, size: 14.sp, color: colorScheme.onPrimary)
            : null,
      ),
    );
  }

  Color _getColor(ColorScheme colorScheme, AtharColors colors) {
    switch (item.type) {
      case DailyItemType.task:
        return colorScheme.primary;
      case DailyItemType.medicine:
        return colors.warning;
      case DailyItemType.appointment:
        return colorScheme.secondary;
    }
  }

  IconData _getIcon() {
    switch (item.type) {
      case DailyItemType.task:
        return Icons.task_alt_rounded;
      case DailyItemType.medicine:
        return Icons.medication_rounded;
      case DailyItemType.appointment:
        return Icons.event_note_rounded;
    }
  }

  String _getTypeLabel(AppLocalizations l10n) {
    switch (item.type) {
      case DailyItemType.task:
        return l10n.timelineTypeTask;
      case DailyItemType.medicine:
        return l10n.timelineTypeMedicine;
      case DailyItemType.appointment:
        return l10n.timelineTypeAppointment;
    }
  }
}
