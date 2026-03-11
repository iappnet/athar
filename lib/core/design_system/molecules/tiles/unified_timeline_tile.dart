import 'package:athar/core/design_system/tokens/athar_animations.dart';
import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
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
    final l10n = AppLocalizations.of(context);
    final color = _getColor(colorScheme);
    final icon = _getIcon();
    final isCompleted = item.isCompleted;

    return Dismissible(
      key: Key(item.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: AtharSpacing.xl),
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
            border: Border(
              right: BorderSide(
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

  Color _getColor(ColorScheme colorScheme) {
    switch (item.type) {
      case DailyItemType.task:
        return colorScheme.primary;
      case DailyItemType.medicine:
        return Colors.orange;
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
//-----------------------------------------------------------------------
// // lib/core/design_system/molecules/tiles/unified_timeline_tile.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 1 | File 1.7
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/features/home/domain/entities/daily_item.dart';

// class UnifiedTimelineTile extends StatelessWidget {
//   final DailyItem item;
//   final VoidCallback onToggle;
//   final VoidCallback? onDelete;
//   final VoidCallback? onTap;

//   const UnifiedTimelineTile({
//     super.key,
//     required this.item,
//     required this.onToggle,
//     this.onDelete,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;
//     final color = _getColor(colors);
//     final icon = _getIcon();
//     final isCompleted = item.isCompleted;

//     return Dismissible(
//       key: Key(item.id),
//       direction: onDelete != null
//           ? DismissDirection.endToStart
//           : DismissDirection.none,
//       background: Container(
//         alignment: Alignment.centerLeft,
//         // ✅ EdgeInsets.only(left: 20.w)
//         padding: EdgeInsets.only(left: AtharSpacing.xl),
//         // ✅ Colors.red → colors.error
//         color: colors.error,
//         // ✅ Colors.white → colors.onPrimary
//         child: Icon(Icons.delete, color: colors.onPrimary),
//       ),
//       onDismissed: (_) => onDelete?.call(),
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           // ✅ EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h)
//           margin: EdgeInsets.symmetric(
//             horizontal: AtharSpacing.lg,
//             vertical: AtharSpacing.xs,
//           ),
//           // ✅ EdgeInsets.all(16.w) → AtharSpacing.allLg
//           padding: AtharSpacing.allLg,
//           decoration: BoxDecoration(
//             // ✅ Colors.grey.shade50 / Colors.white → colors.background / colors.surface
//             color: isCompleted ? colors.background : colors.surface,
//             // ✅ BorderRadius.circular(16.r) → AtharRadii.lg
//             borderRadius: AtharRadii.radiusLg,
//             boxShadow: [
//               BoxShadow(
//                 // ✅ Colors.black.withOpacity(0.03)
//                 color: colors.shadow.withValues(alpha: 0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//             border: Border(
//               right: BorderSide(
//                 color: color.withValues(alpha: 0.4),
//                 width: 4.w,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               // زر الأكشن السريع (دائرة الإكمال)
//               _buildActionCircle(colors, isCompleted, color),

//               // ✅ SizedBox(width: 16.w) → AtharGap.hLg
//               AtharGap.hLg,

//               // محتوى البطاقة
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(icon, size: 14.sp, color: color),
//                         // ✅ SizedBox(width: 6.w) → AtharGap.hXs
//                         AtharGap.hXs,
//                         Text(
//                           _getTypeLabel(),
//                           // ✅ AtharTypography
//                           style: AtharTypography.labelSmall.copyWith(
//                             color: color,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         if (item.hasReminder)
//                           Icon(
//                             Icons.notifications_active_outlined,
//                             size: 12.sp,
//                             color: color,
//                           ),
//                         const Spacer(),
//                         Text(
//                           DateFormat('hh:mm a').format(item.time),
//                           // ✅ AtharTypography
//                           style: AtharTypography.labelSmall.copyWith(
//                             color: colors.textTertiary,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // ✅ SizedBox(height: 6.h) → AtharGap.xs
//                     AtharGap.xs,
//                     Text(
//                       item.title,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       // ✅ AtharTypography
//                       style: AtharTypography.titleSmall.copyWith(
//                         decoration: isCompleted
//                             ? TextDecoration.lineThrough
//                             : null,
//                         // ✅ Colors.grey / AppColors.textPrimary
//                         color: isCompleted
//                             ? colors.textTertiary
//                             : colors.textPrimary,
//                       ),
//                     ),
//                     if (item.subtitle != null) ...[
//                       // ✅ SizedBox(height: 2.h) → AtharGap.xxxs
//                       AtharGap.xxxs,
//                       Text(
//                         item.subtitle!,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         // ✅ AtharTypography
//                         style: AtharTypography.bodySmall.copyWith(
//                           color: colors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionCircle(AtharColors colors, bool isDone, Color color) {
//     return GestureDetector(
//       onTap: onToggle,
//       child: AnimatedContainer(
//         // ✅ AtharAnimations.normal
//         duration: AtharAnimations.normal,
//         width: 24.w,
//         height: 24.w,
//         decoration: BoxDecoration(
//           color: isDone ? color : Colors.transparent,
//           shape: BoxShape.circle,
//           border: Border.all(
//             // ✅ Colors.grey.shade300 → colors.borderLight
//             color: isDone ? color : colors.borderLight,
//             width: 2,
//           ),
//         ),
//         child: isDone
//             // ✅ Colors.white → colors.onPrimary
//             ? Icon(Icons.check, size: 14.sp, color: colors.onPrimary)
//             : null,
//       ),
//     );
//   }

//   // ✅ استخدام ألوان من الثيم
//   Color _getColor(AtharColors colors) {
//     switch (item.type) {
//       case DailyItemType.task:
//         // ✅ AppColors.primary → colors.primary
//         return colors.primary;
//       case DailyItemType.medicine:
//         return colors.warning;
//       case DailyItemType.appointment:
//         return colors.secondary;
//     }
//   }

//   IconData _getIcon() {
//     switch (item.type) {
//       case DailyItemType.task:
//         return Icons.task_alt_rounded;
//       case DailyItemType.medicine:
//         return Icons.medication_rounded;
//       case DailyItemType.appointment:
//         return Icons.event_note_rounded;
//     }
//   }

//   String _getTypeLabel() {
//     switch (item.type) {
//       case DailyItemType.task:
//         return "مهمة";
//       case DailyItemType.medicine:
//         return "دواء";
//       case DailyItemType.appointment:
//         return "موعد";
//     }
//   }
// }
//-----------------------------------------------------------------------

// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/home/domain/entities/daily_item.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class UnifiedTimelineTile extends StatelessWidget {
//   final DailyItem item;
//   final VoidCallback onToggle;
//   final VoidCallback? onDelete;
//   final VoidCallback? onTap;

//   const UnifiedTimelineTile({
//     super.key,
//     required this.item,
//     required this.onToggle,
//     this.onDelete,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = _getColor();
//     final icon = _getIcon();
//     final isCompleted = item.isCompleted;

//     return Dismissible(
//       key: Key(item.id),
//       direction: onDelete != null
//           ? DismissDirection.endToStart
//           : DismissDirection.none,
//       background: Container(
//         alignment: Alignment.centerLeft,
//         padding: EdgeInsets.only(left: 20.w),
//         color: Colors.red,
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       onDismissed: (_) => onDelete?.call(),
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//           padding: EdgeInsets.all(16.w),
//           decoration: BoxDecoration(
//             color: isCompleted ? Colors.grey.shade50 : Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.03),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//             border: Border(
//               right: BorderSide(color: color.withOpacity(0.4), width: 4.w),
//             ),
//           ),
//           child: Row(
//             children: [
//               // زر الأكشن السريع (دائرة الإكمال)
//               _buildActionCircle(isCompleted, color),

//               SizedBox(width: 16.w),

//               // محتوى البطاقة
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(icon, size: 14.sp, color: color),
//                         SizedBox(width: 6.w),
//                         Text(
//                           _getTypeLabel(),
//                           style: TextStyle(
//                             color: color,
//                             fontSize: 10.sp,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Tajawal',
//                           ),
//                         ),
//                         if (item.hasReminder) // ✅ إضافة
//                           Icon(
//                             Icons.notifications_active_outlined,
//                             size: 12.sp,
//                             color: color,
//                           ),
//                         const Spacer(),
//                         Text(
//                           DateFormat('hh:mm a').format(item.time),
//                           style: TextStyle(
//                             color: Colors.grey.shade500,
//                             fontSize: 10.sp,
//                             fontFamily: 'Tajawal',
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 6.h),
//                     Text(
//                       item.title,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Tajawal',
//                         decoration: isCompleted
//                             ? TextDecoration.lineThrough
//                             : null,
//                         color: isCompleted
//                             ? Colors.grey
//                             : AppColors.textPrimary,
//                       ),
//                     ),
//                     if (item.subtitle != null) ...[
//                       SizedBox(height: 2.h),
//                       Text(
//                         item.subtitle!,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey.shade600,
//                           fontFamily: 'Tajawal',
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionCircle(bool isDone, Color color) {
//     return GestureDetector(
//       onTap: onToggle,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: 24.w,
//         height: 24.w,
//         decoration: BoxDecoration(
//           color: isDone ? color : Colors.transparent,
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: isDone ? color : Colors.grey.shade300,
//             width: 2,
//           ),
//         ),
//         child: isDone
//             ? Icon(Icons.check, size: 14.sp, color: Colors.white)
//             : null,
//       ),
//     );
//   }

//   Color _getColor() {
//     switch (item.type) {
//       case DailyItemType.task:
//         return AppColors.primary;
//       case DailyItemType.medicine:
//         return Colors.orange.shade700;
//       case DailyItemType.appointment:
//         return Colors.purple.shade600;
//     }
//   }

//   IconData _getIcon() {
//     switch (item.type) {
//       case DailyItemType.task:
//         return Icons.task_alt_rounded;
//       case DailyItemType.medicine:
//         return Icons.medication_rounded;
//       case DailyItemType.appointment:
//         return Icons.event_note_rounded;
//     }
//   }

//   String _getTypeLabel() {
//     switch (item.type) {
//       case DailyItemType.task:
//         return "مهمة";
//       case DailyItemType.medicine:
//         return "دواء";
//       case DailyItemType.appointment:
//         return "موعد";
//     }
//   }
// }
