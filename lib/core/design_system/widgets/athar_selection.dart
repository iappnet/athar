import 'package:flutter/material.dart';
import '../tokens.dart';

/// ATHAR CHECKBOX

class AtharCheckbox extends StatelessWidget {
  const AtharCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.subtitle,
    this.activeColor,
    this.checkColor,
    this.size = 24,
    this.enabled = true,
    this.tristate = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final String? subtitle;
  final Color? activeColor;
  final Color? checkColor;
  final double size;
  final bool enabled;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveActiveColor = activeColor ?? colorScheme.primary;
    final effectiveCheckColor = checkColor ?? colorScheme.onPrimary;

    Widget checkbox = SizedBox(
      width: size,
      height: size,
      child: Checkbox(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: effectiveActiveColor,
        checkColor: effectiveCheckColor,
        tristate: tristate,
        side: BorderSide(
          color: enabled ? colorScheme.outline : colorScheme.outlineVariant,
          width: 2,
        ),
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusXxs),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    if (label == null) return checkbox;

    return InkWell(
      onTap: enabled
          ? () => onChanged?.call(value == true ? false : true)
          : null,
      borderRadius: BorderRadius.circular(AtharRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            checkbox,
            AtharGap.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      color: enabled
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        color: colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ATHAR SWITCH

class AtharSwitch extends StatelessWidget {
  const AtharSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.subtitle,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? subtitle;
  final Color? activeColor;
  final Color? activeTrackColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget switchWidget = Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeThumbColor: activeColor ?? colorScheme.primary,
      activeTrackColor: activeTrackColor ?? colorScheme.primaryContainer,
      inactiveThumbColor:
          inactiveThumbColor ?? colorScheme.surfaceContainerHigh,
      inactiveTrackColor: inactiveTrackColor ?? colorScheme.surfaceContainer,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    if (label == null) return switchWidget;

    return InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      borderRadius: BorderRadius.circular(AtharRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      color: enabled
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        color: colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            switchWidget,
          ],
        ),
      ),
    );
  }
}

/// ATHAR RADIO

class AtharRadio<T> extends StatelessWidget {
  const AtharRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.subtitle,
    this.activeColor,
    this.enabled = true,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? subtitle;
  final Color? activeColor;
  final bool enabled;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveActiveColor = activeColor ?? colorScheme.primary;

    Widget radio = RadioGroup<T>(
      groupValue: groupValue,
      onChanged: enabled ? (value) => onChanged?.call(value) : (_) {},
      child: Radio<T>(
        value: value,
        activeColor: effectiveActiveColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    if (label == null) return radio;

    return InkWell(
      onTap: enabled ? () => onChanged?.call(value) : null,
      borderRadius: BorderRadius.circular(AtharRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            radio,
            AtharGap.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      color: enabled
                          ? (_selected
                                ? effectiveActiveColor
                                : colorScheme.onSurface)
                          : colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        color: colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AtharRadioGroup<T> extends StatelessWidget {
  const AtharRadioGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.direction = Axis.vertical,
    this.spacing = 8,
    this.enabled = true,
  });

  final T? value;
  final List<AtharRadioOption<T>> options;
  final ValueChanged<T?> onChanged;
  final Axis direction;
  final double spacing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final children = options.map((option) {
      return AtharRadio<T>(
        value: option.value,
        groupValue: value,
        onChanged: enabled && option.enabled ? onChanged : null,
        label: option.label,
        subtitle: option.subtitle,
        enabled: enabled && option.enabled,
      );
    }).toList();

    if (direction == Axis.horizontal) {
      return Wrap(spacing: spacing, runSpacing: spacing, children: children);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map(
            (child) => Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: child,
            ),
          )
          .toList(),
    );
  }
}

class AtharRadioOption<T> {
  const AtharRadioOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final bool enabled;
}

/// ATHAR CHIP

enum AtharChipVariant { filled, outlined, ghost }

class AtharChip extends StatelessWidget {
  const AtharChip({
    super.key,
    required this.label,
    this.icon,
    this.avatar,
    this.deleteIcon,
    this.onTap,
    this.onDelete,
    this.variant = AtharChipVariant.filled,
    this.selected = false,
    this.enabled = true,
    this.color,
    this.backgroundColor,
  });

  final String label;
  final IconData? icon;
  final Widget? avatar;
  final IconData? deleteIcon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final AtharChipVariant variant;
  final bool selected;
  final bool enabled;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    Color bgColor;
    Color fgColor;
    Color? borderColor;

    switch (variant) {
      case AtharChipVariant.filled:
        bgColor = selected
            ? effectiveColor
            : (backgroundColor ?? colorScheme.surfaceContainer);
        fgColor = selected ? colorScheme.onPrimary : colorScheme.onSurface;
        break;
      case AtharChipVariant.outlined:
        bgColor = Colors.transparent;
        fgColor = selected ? effectiveColor : colorScheme.onSurface;
        borderColor = selected ? effectiveColor : colorScheme.outline;
        break;
      case AtharChipVariant.ghost:
        bgColor = selected
            ? effectiveColor.withValues(alpha: 0.1)
            : Colors.transparent;
        fgColor = selected ? effectiveColor : colorScheme.onSurface;
        break;
    }

    if (!enabled) {
      fgColor = colorScheme.onSurface.withValues(alpha: 0.38);
      bgColor = colorScheme.surfaceContainer;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AtharRadii.full),
        child: AnimatedContainer(
          duration: AtharAnimations.fast,
          padding: EdgeInsets.symmetric(
            horizontal: (avatar != null || icon != null) ? 12 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AtharRadii.full),
            border: borderColor != null ? Border.all(color: borderColor) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (avatar != null) ...[avatar!, const AtharGap.hSm],
              if (icon != null) ...[
                Icon(icon, size: 18, color: fgColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                  color: fgColor,
                ),
              ),
              if (onDelete != null) ...[
                const AtharGap.hXxs,
                InkWell(
                  onTap: enabled ? onDelete : null,
                  borderRadius: AtharRadii.radiusMd,
                  child: Icon(
                    deleteIcon ?? Icons.close,
                    size: 16,
                    color: fgColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ATHAR BADGE

enum AtharBadgePosition { topStart, topEnd, bottomStart, bottomEnd }

class AtharBadge extends StatelessWidget {
  const AtharBadge({
    super.key,
    this.label,
    this.count,
    this.color,
    this.textColor,
    this.size = 18,
    this.show = true,
    this.position = AtharBadgePosition.topEnd,
    this.offset,
    required this.child,
  });

  final Widget child;
  final String? label;
  final int? count;
  final Color? color;
  final Color? textColor;
  final double size;
  final bool show;
  final AtharBadgePosition position;
  final Offset? offset;

  factory AtharBadge.dot({
    Color? color,
    bool show = true,
    AtharBadgePosition position = AtharBadgePosition.topEnd,
    required Widget child,
  }) {
    return AtharBadge(
      color: color,
      show: show,
      position: position,
      size: 8,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!show) return child;

    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.error;
    final effectiveTextColor = textColor ?? colorScheme.onError;

    final displayText =
        label ??
        (count != null ? (count! > 99 ? '99+' : count.toString()) : null);
    final isDot = displayText == null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top:
              position == AtharBadgePosition.topStart ||
                  position == AtharBadgePosition.topEnd
              ? (offset?.dy ?? -4)
              : null,
          bottom:
              position == AtharBadgePosition.bottomStart ||
                  position == AtharBadgePosition.bottomEnd
              ? (offset?.dy ?? -4)
              : null,
          start:
              position == AtharBadgePosition.topStart ||
                  position == AtharBadgePosition.bottomStart
              ? (offset?.dx ?? -4)
              : null,
          end:
              position == AtharBadgePosition.topEnd ||
                  position == AtharBadgePosition.bottomEnd
              ? (offset?.dx ?? -4)
              : null,
          child: AnimatedContainer(
            duration: AtharAnimations.fast,
            constraints: BoxConstraints(
              minWidth: size,
              minHeight: isDot ? size : 18,
            ),
            padding: isDot
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(isDot ? size / 2 : 9),
            ),
            child: isDot
                ? null
                : Center(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                        letterSpacing: 0.5,
                        color: effectiveTextColor,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import '../tokens.dart';

// /// ===================================================================
// /// ATHAR CHECKBOX - مربع الاختيار الموحد
// /// ===================================================================

// class AtharCheckbox extends StatelessWidget {
//   const AtharCheckbox({
//     super.key,
//     required this.value,
//     required this.onChanged,
//     this.label,
//     this.subtitle,
//     this.activeColor,
//     this.checkColor,
//     this.size = 24,
//     this.enabled = true,
//     this.tristate = false,
//   });

//   final bool? value;
//   final ValueChanged<bool?>? onChanged;
//   final String? label;
//   final String? subtitle;
//   final Color? activeColor;
//   final Color? checkColor;
//   final double size;
//   final bool enabled;
//   final bool tristate;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final effectiveActiveColor = activeColor ?? colors.primary;
//     final effectiveCheckColor = checkColor ?? colors.onPrimary;

//     Widget checkbox = SizedBox(
//       width: size,
//       height: size,
//       child: Checkbox(
//         value: value,
//         onChanged: enabled ? onChanged : null,
//         activeColor: effectiveActiveColor,
//         checkColor: effectiveCheckColor,
//         tristate: tristate,
//         side: BorderSide(
//           color: enabled ? colors.border : colors.borderLight,
//           width: 2,
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//     );

//     if (label == null) return checkbox;

//     return InkWell(
//       onTap: enabled
//           ? () => onChanged?.call(value == true ? false : true)
//           : null,
//       borderRadius: BorderRadius.circular(AtharRadii.sm),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Row(
//           children: [
//             checkbox,
//             AtharGap.hMd,
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label!,
//                     style: AtharTypography.bodyMedium.copyWith(
//                       color: enabled ? colors.textPrimary : colors.textDisabled,
//                     ),
//                   ),
//                   if (subtitle != null)
//                     Text(
//                       subtitle!,
//                       style: AtharTypography.bodySmall.copyWith(
//                         color: colors.textTertiary,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// ===================================================================
// /// ATHAR SWITCH - المفتاح الموحد
// /// ===================================================================

// class AtharSwitch extends StatelessWidget {
//   const AtharSwitch({
//     super.key,
//     required this.value,
//     required this.onChanged,
//     this.label,
//     this.subtitle,
//     this.activeColor,
//     this.activeTrackColor,
//     this.inactiveThumbColor,
//     this.inactiveTrackColor,
//     this.enabled = true,
//   });

//   final bool value;
//   final ValueChanged<bool>? onChanged;
//   final String? label;
//   final String? subtitle;
//   final Color? activeColor;
//   final Color? activeTrackColor;
//   final Color? inactiveThumbColor;
//   final Color? inactiveTrackColor;
//   final bool enabled;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     Widget switchWidget = Switch(
//       value: value,
//       onChanged: enabled ? onChanged : null,
//       activeThumbColor: activeColor ?? colors.primary,
//       activeTrackColor: activeTrackColor ?? colors.primaryLight,
//       inactiveThumbColor: inactiveThumbColor ?? colors.surfaceContainerHigh,
//       inactiveTrackColor: inactiveTrackColor ?? colors.surfaceContainer,
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//     );

//     if (label == null) return switchWidget;

//     return InkWell(
//       onTap: enabled ? () => onChanged?.call(!value) : null,
//       borderRadius: BorderRadius.circular(AtharRadii.sm),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label!,
//                     style: AtharTypography.bodyMedium.copyWith(
//                       color: enabled ? colors.textPrimary : colors.textDisabled,
//                     ),
//                   ),
//                   if (subtitle != null)
//                     Text(
//                       subtitle!,
//                       style: AtharTypography.bodySmall.copyWith(
//                         color: colors.textTertiary,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             switchWidget,
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// ===================================================================
// /// ATHAR RADIO - زر الراديو الموحد
// /// ===================================================================

// class AtharRadio<T> extends StatelessWidget {
//   const AtharRadio({
//     super.key,
//     required this.value,
//     required this.groupValue,
//     required this.onChanged,
//     this.label,
//     this.subtitle,
//     this.activeColor,
//     this.enabled = true,
//   });

//   final T value;
//   final T? groupValue;
//   final ValueChanged<T?>? onChanged;
//   final String? label;
//   final String? subtitle;
//   final Color? activeColor;
//   final bool enabled;

//   bool get _selected => value == groupValue;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final effectiveActiveColor = activeColor ?? colors.primary;

//     Widget radio = Radio<T>(
//       value: value,
//       groupValue: groupValue,
//       onChanged: enabled ? onChanged : null,
//       activeColor: effectiveActiveColor,
//       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//     );

//     if (label == null) return radio;

//     return InkWell(
//       onTap: enabled ? () => onChanged?.call(value) : null,
//       borderRadius: BorderRadius.circular(AtharRadii.sm),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Row(
//           children: [
//             radio,
//             AtharGap.hMd,
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label!,
//                     style: AtharTypography.bodyMedium.copyWith(
//                       color: enabled
//                           ? (_selected
//                                 ? effectiveActiveColor
//                                 : colors.textPrimary)
//                           : colors.textDisabled,
//                     ),
//                   ),
//                   if (subtitle != null)
//                     Text(
//                       subtitle!,
//                       style: AtharTypography.bodySmall.copyWith(
//                         color: colors.textTertiary,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// مجموعة أزرار راديو
// class AtharRadioGroup<T> extends StatelessWidget {
//   const AtharRadioGroup({
//     super.key,
//     required this.value,
//     required this.options,
//     required this.onChanged,
//     this.direction = Axis.vertical,
//     this.spacing = 8,
//     this.enabled = true,
//   });

//   final T? value;
//   final List<AtharRadioOption<T>> options;
//   final ValueChanged<T?> onChanged;
//   final Axis direction;
//   final double spacing;
//   final bool enabled;

//   @override
//   Widget build(BuildContext context) {
//     final children = options.map((option) {
//       return AtharRadio<T>(
//         value: option.value,
//         groupValue: value,
//         onChanged: enabled && option.enabled ? onChanged : null,
//         label: option.label,
//         subtitle: option.subtitle,
//         enabled: enabled && option.enabled,
//       );
//     }).toList();

//     if (direction == Axis.horizontal) {
//       return Wrap(spacing: spacing, runSpacing: spacing, children: children);
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: children
//           .map(
//             (child) => Padding(
//               padding: EdgeInsets.only(bottom: spacing),
//               child: child,
//             ),
//           )
//           .toList(),
//     );
//   }
// }

// /// خيار راديو
// class AtharRadioOption<T> {
//   const AtharRadioOption({
//     required this.value,
//     required this.label,
//     this.subtitle,
//     this.enabled = true,
//   });

//   final T value;
//   final String label;
//   final String? subtitle;
//   final bool enabled;
// }

// /// ===================================================================
// /// ATHAR CHIP - الشريحة الموحدة
// /// ===================================================================

// enum AtharChipVariant { filled, outlined, ghost }

// class AtharChip extends StatelessWidget {
//   const AtharChip({
//     super.key,
//     required this.label,
//     this.icon,
//     this.avatar,
//     this.deleteIcon,
//     this.onTap,
//     this.onDelete,
//     this.variant = AtharChipVariant.filled,
//     this.selected = false,
//     this.enabled = true,
//     this.color,
//     this.backgroundColor,
//   });

//   final String label;
//   final IconData? icon;
//   final Widget? avatar;
//   final IconData? deleteIcon;
//   final VoidCallback? onTap;
//   final VoidCallback? onDelete;
//   final AtharChipVariant variant;
//   final bool selected;
//   final bool enabled;
//   final Color? color;
//   final Color? backgroundColor;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final effectiveColor = color ?? colors.primary;

//     Color bgColor;
//     Color fgColor;
//     Color? borderColor;

//     switch (variant) {
//       case AtharChipVariant.filled:
//         bgColor = selected
//             ? effectiveColor
//             : (backgroundColor ?? colors.surfaceContainer);
//         fgColor = selected ? colors.onPrimary : colors.textPrimary;
//         break;
//       case AtharChipVariant.outlined:
//         bgColor = Colors.transparent;
//         fgColor = selected ? effectiveColor : colors.textPrimary;
//         borderColor = selected ? effectiveColor : colors.border;
//         break;
//       case AtharChipVariant.ghost:
//         bgColor = selected
//             ? effectiveColor.withValues(alpha: 0.1)
//             : Colors.transparent;
//         fgColor = selected ? effectiveColor : colors.textPrimary;
//         break;
//     }

//     if (!enabled) {
//       fgColor = colors.textDisabled;
//       bgColor = colors.surfaceContainer;
//     }

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: enabled ? onTap : null,
//         borderRadius: BorderRadius.circular(AtharRadii.full),
//         child: AnimatedContainer(
//           duration: AtharAnimations.fast,
//           padding: EdgeInsets.symmetric(
//             horizontal: (avatar != null || icon != null) ? 12 : 16,
//             vertical: 8,
//           ),
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(AtharRadii.full),
//             border: borderColor != null ? Border.all(color: borderColor) : null,
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (avatar != null) ...[avatar!, const SizedBox(width: 8)],
//               if (icon != null) ...[
//                 Icon(icon, size: 18, color: fgColor),
//                 const SizedBox(width: 6),
//               ],
//               Text(label, style: AtharTypography.chip.copyWith(color: fgColor)),
//               if (onDelete != null) ...[
//                 const SizedBox(width: 4),
//                 InkWell(
//                   onTap: enabled ? onDelete : null,
//                   borderRadius: BorderRadius.circular(10),
//                   child: Icon(
//                     deleteIcon ?? Icons.close,
//                     size: 16,
//                     color: fgColor,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// ===================================================================
// /// ATHAR BADGE - الشارة الموحدة
// /// ===================================================================

// /// موقع الشارة
// enum AtharBadgePosition { topStart, topEnd, bottomStart, bottomEnd }

// class AtharBadge extends StatelessWidget {
//   const AtharBadge({
//     super.key,
//     this.label,
//     this.count,
//     this.color,
//     this.textColor,
//     this.size = 18,
//     this.show = true,
//     this.position = AtharBadgePosition.topEnd,
//     this.offset,
//     required this.child,
//   });

//   final Widget child;
//   final String? label;
//   final int? count;
//   final Color? color;
//   final Color? textColor;
//   final double size;
//   final bool show;
//   final AtharBadgePosition position;
//   final Offset? offset;

//   /// نقطة بسيطة
//   factory AtharBadge.dot({
//     Color? color,
//     bool show = true,
//     AtharBadgePosition position = AtharBadgePosition.topEnd,
//     required Widget child,
//   }) {
//     return AtharBadge(
//       color: color,
//       show: show,
//       position: position,
//       size: 8,
//       child: child,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!show) return child;

//     final colors = context.colors;
//     final effectiveColor = color ?? colors.error;
//     final effectiveTextColor = textColor ?? colors.onError;

//     final displayText =
//         label ??
//         (count != null ? (count! > 99 ? '99+' : count.toString()) : null);
//     final isDot = displayText == null;

//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         child,
//         PositionedDirectional(
//           top:
//               position == AtharBadgePosition.topStart ||
//                   position == AtharBadgePosition.topEnd
//               ? (offset?.dy ?? -4)
//               : null,
//           bottom:
//               position == AtharBadgePosition.bottomStart ||
//                   position == AtharBadgePosition.bottomEnd
//               ? (offset?.dy ?? -4)
//               : null,
//           start:
//               position == AtharBadgePosition.topStart ||
//                   position == AtharBadgePosition.bottomStart
//               ? (offset?.dx ?? -4)
//               : null,
//           end:
//               position == AtharBadgePosition.topEnd ||
//                   position == AtharBadgePosition.bottomEnd
//               ? (offset?.dx ?? -4)
//               : null,
//           child: AnimatedContainer(
//             duration: AtharAnimations.fast,
//             constraints: BoxConstraints(
//               minWidth: size,
//               minHeight: isDot ? size : 18,
//             ),
//             padding: isDot
//                 ? EdgeInsets.zero
//                 : const EdgeInsets.symmetric(horizontal: 6),
//             decoration: BoxDecoration(
//               color: effectiveColor,
//               borderRadius: BorderRadius.circular(isDot ? size / 2 : 9),
//             ),
//             child: isDot
//                 ? null
//                 : Center(
//                     child: Text(
//                       displayText,
//                       style: AtharTypography.badge.copyWith(
//                         color: effectiveTextColor,
//                       ),
//                     ),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//-----------------------------------------------------------------------
