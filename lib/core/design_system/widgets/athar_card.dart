import 'package:flutter/material.dart';
import '../tokens.dart';

/// ATHAR CARD - البطاقة الموحدة

enum AtharCardVariant { elevated, outlined, filled }

class AtharCardStyle {
  const AtharCardStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.padding,
  });

  final Color? backgroundColor, borderColor, shadowColor;
  final double? borderWidth, borderRadius, elevation;
  final EdgeInsetsGeometry? padding;
}

class AtharCard extends StatelessWidget {
  const AtharCard({
    super.key,
    required this.child,
    this.variant = AtharCardVariant.elevated,
    this.customStyle,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final AtharCardVariant variant;
  final AtharCardStyle? customStyle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width, height;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;

  factory AtharCard.elevated({
    Key? key,
    required Widget child,
    AtharCardStyle? customStyle,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
  }) => AtharCard(
    key: key,
    variant: AtharCardVariant.elevated,
    customStyle: customStyle,
    onTap: onTap,
    onLongPress: onLongPress,
    width: width,
    height: height,
    margin: margin,
    child: child,
  );

  factory AtharCard.outlined({
    Key? key,
    required Widget child,
    AtharCardStyle? customStyle,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
  }) => AtharCard(
    key: key,
    variant: AtharCardVariant.outlined,
    customStyle: customStyle,
    onTap: onTap,
    onLongPress: onLongPress,
    width: width,
    height: height,
    margin: margin,
    child: child,
  );

  factory AtharCard.filled({
    Key? key,
    required Widget child,
    AtharCardStyle? customStyle,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
  }) => AtharCard(
    key: key,
    variant: AtharCardVariant.filled,
    customStyle: customStyle,
    onTap: onTap,
    onLongPress: onLongPress,
    width: width,
    height: height,
    margin: margin,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = _resolveStyle(colorScheme);

    Widget card = AnimatedContainer(
      duration: AtharAnimations.fast,
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(style.borderRadius),
        border: style.borderColor != null
            ? Border.all(color: style.borderColor!, width: style.borderWidth)
            : null,
        boxShadow: style.elevation > 0
            ? [
                BoxShadow(
                  color: style.shadowColor,
                  blurRadius: style.elevation * 2,
                  offset: Offset(0, style.elevation / 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(style.borderRadius),
        clipBehavior: clipBehavior,
        child: Padding(padding: style.padding, child: child),
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(style.borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }

  _CardStyle _resolveStyle(ColorScheme colorScheme) {
    final custom = customStyle;
    switch (variant) {
      case AtharCardVariant.elevated:
        return _CardStyle(
          custom?.backgroundColor ?? colorScheme.surface,
          null,
          0,
          custom?.borderRadius ?? AtharRadii.lg,
          custom?.elevation ?? 2,
          custom?.shadowColor ?? colorScheme.shadow.withValues(alpha: 0.1),
          custom?.padding ?? AtharSpacing.card,
        );
      case AtharCardVariant.outlined:
        return _CardStyle(
          custom?.backgroundColor ?? colorScheme.surface,
          custom?.borderColor ?? colorScheme.outlineVariant,
          custom?.borderWidth ?? 1,
          custom?.borderRadius ?? AtharRadii.lg,
          0,
          Colors.transparent,
          custom?.padding ?? AtharSpacing.card,
        );
      case AtharCardVariant.filled:
        return _CardStyle(
          custom?.backgroundColor ?? colorScheme.surfaceContainer,
          null,
          0,
          custom?.borderRadius ?? AtharRadii.lg,
          0,
          Colors.transparent,
          custom?.padding ?? AtharSpacing.card,
        );
    }
  }
}

class _CardStyle {
  final Color backgroundColor;
  final Color? borderColor;
  final double borderWidth, borderRadius, elevation;
  final Color shadowColor;
  final EdgeInsetsGeometry padding;
  const _CardStyle(
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.padding,
  );
}

/// ATHAR LIST TILE - عنصر القائمة الموحد

class AtharListTile extends StatelessWidget {
  const AtharListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.dense = false,
    this.contentPadding,
    this.leadingIcon,
    this.trailingIcon,
    this.showChevron = false,
  });

  final Widget? leading, trailing;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap, onLongPress;
  final bool enabled, selected, dense, showChevron;
  final EdgeInsetsGeometry? contentPadding;
  final IconData? leadingIcon, trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AtharRadii.sm),
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        borderRadius: BorderRadius.circular(AtharRadii.sm),
        child: Padding(
          padding: contentPadding ?? AtharSpacing.listItem,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                AtharGap.hMd,
              ] else if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                AtharGap.hMd,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: dense ? 14 : 16,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        color: enabled
                            ? (selected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface)
                            : colorScheme.onSurface.withValues(alpha: 0.38),
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: dense ? 2 : 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                AtharGap.hMd,
                trailing!,
              ] else if (trailingIcon != null) ...[
                AtharGap.hMd,
                Icon(trailingIcon, color: colorScheme.outline, size: 20),
              ] else if (showChevron) ...[
                AtharGap.hMd,
                Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import '../tokens.dart';

// /// ===================================================================
// /// ATHAR CARD - البطاقة الموحدة
// /// ===================================================================

// enum AtharCardVariant { elevated, outlined, filled }

// /// ستايل مخصص للبطاقة
// class AtharCardStyle {
//   const AtharCardStyle({
//     this.backgroundColor,
//     this.borderColor,
//     this.borderWidth,
//     this.borderRadius,
//     this.elevation,
//     this.shadowColor,
//     this.padding,
//   });

//   final Color? backgroundColor, borderColor, shadowColor;
//   final double? borderWidth, borderRadius, elevation;
//   final EdgeInsetsGeometry? padding;
// }

// /// البطاقة الموحدة
// ///
// /// ```dart
// /// AtharCard(
// ///   child: Column(
// ///     children: [
// ///       Text('عنوان البطاقة'),
// ///       Text('محتوى البطاقة'),
// ///     ],
// ///   ),
// /// )
// ///
// /// AtharCard.outlined(
// ///   onTap: () {},
// ///   child: ListTile(...),
// /// )
// /// ```
// class AtharCard extends StatelessWidget {
//   const AtharCard({
//     super.key,
//     required this.child,
//     this.variant = AtharCardVariant.elevated,
//     this.customStyle,
//     this.onTap,
//     this.onLongPress,
//     this.width,
//     this.height,
//     this.margin,
//     this.clipBehavior = Clip.antiAlias,
//   });

//   final Widget child;
//   final AtharCardVariant variant;
//   final AtharCardStyle? customStyle;
//   final VoidCallback? onTap;
//   final VoidCallback? onLongPress;
//   final double? width, height;
//   final EdgeInsetsGeometry? margin;
//   final Clip clipBehavior;

//   // Factory constructors
//   factory AtharCard.elevated({
//     Key? key,
//     required Widget child,
//     AtharCardStyle? customStyle,
//     VoidCallback? onTap,
//     VoidCallback? onLongPress,
//     double? width,
//     double? height,
//     EdgeInsetsGeometry? margin,
//   }) => AtharCard(
//     key: key,
//     variant: AtharCardVariant.elevated,
//     customStyle: customStyle,
//     onTap: onTap,
//     onLongPress: onLongPress,
//     width: width,
//     height: height,
//     margin: margin,
//     child: child,
//   );

//   factory AtharCard.outlined({
//     Key? key,
//     required Widget child,
//     AtharCardStyle? customStyle,
//     VoidCallback? onTap,
//     VoidCallback? onLongPress,
//     double? width,
//     double? height,
//     EdgeInsetsGeometry? margin,
//   }) => AtharCard(
//     key: key,
//     variant: AtharCardVariant.outlined,
//     customStyle: customStyle,
//     onTap: onTap,
//     onLongPress: onLongPress,
//     width: width,
//     height: height,
//     margin: margin,
//     child: child,
//   );

//   factory AtharCard.filled({
//     Key? key,
//     required Widget child,
//     AtharCardStyle? customStyle,
//     VoidCallback? onTap,
//     VoidCallback? onLongPress,
//     double? width,
//     double? height,
//     EdgeInsetsGeometry? margin,
//   }) => AtharCard(
//     key: key,
//     variant: AtharCardVariant.filled,
//     customStyle: customStyle,
//     onTap: onTap,
//     onLongPress: onLongPress,
//     width: width,
//     height: height,
//     margin: margin,
//     child: child,
//   );

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final style = _resolveStyle(colors);

//     Widget card = AnimatedContainer(
//       duration: AtharAnimations.fast,
//       width: width,
//       height: height,
//       margin: margin,
//       decoration: BoxDecoration(
//         color: style.backgroundColor,
//         borderRadius: BorderRadius.circular(style.borderRadius),
//         border: style.borderColor != null
//             ? Border.all(color: style.borderColor!, width: style.borderWidth)
//             : null,
//         boxShadow: style.elevation > 0
//             ? [
//                 BoxShadow(
//                   color: style.shadowColor,
//                   blurRadius: style.elevation * 2,
//                   offset: Offset(0, style.elevation / 2),
//                 ),
//               ]
//             : null,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(style.borderRadius),
//         clipBehavior: clipBehavior,
//         child: Padding(padding: style.padding, child: child),
//       ),
//     );

//     if (onTap != null || onLongPress != null) {
//       card = Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           onLongPress: onLongPress,
//           borderRadius: BorderRadius.circular(style.borderRadius),
//           child: card,
//         ),
//       );
//     }

//     return card;
//   }

//   _CardStyle _resolveStyle(AtharColors colors) {
//     final custom = customStyle;
//     switch (variant) {
//       case AtharCardVariant.elevated:
//         return _CardStyle(
//           custom?.backgroundColor ?? colors.surface,
//           null,
//           0,
//           custom?.borderRadius ?? AtharRadii.lg,
//           custom?.elevation ?? 2,
//           custom?.shadowColor ?? colors.shadow.withValues(alpha: 0.1),
//           custom?.padding ?? AtharSpacing.card,
//         );
//       case AtharCardVariant.outlined:
//         return _CardStyle(
//           custom?.backgroundColor ?? colors.surface,
//           custom?.borderColor ?? colors.borderLight,
//           custom?.borderWidth ?? 1,
//           custom?.borderRadius ?? AtharRadii.lg,
//           0,
//           Colors.transparent,
//           custom?.padding ?? AtharSpacing.card,
//         );
//       case AtharCardVariant.filled:
//         return _CardStyle(
//           custom?.backgroundColor ?? colors.surfaceContainer,
//           null,
//           0,
//           custom?.borderRadius ?? AtharRadii.lg,
//           0,
//           Colors.transparent,
//           custom?.padding ?? AtharSpacing.card,
//         );
//     }
//   }
// }

// class _CardStyle {
//   final Color backgroundColor;
//   final Color? borderColor;
//   final double borderWidth, borderRadius, elevation;
//   final Color shadowColor;
//   final EdgeInsetsGeometry padding;
//   const _CardStyle(
//     this.backgroundColor,
//     this.borderColor,
//     this.borderWidth,
//     this.borderRadius,
//     this.elevation,
//     this.shadowColor,
//     this.padding,
//   );
// }

// /// ===================================================================
// /// ATHAR LIST TILE - عنصر القائمة الموحد
// /// ===================================================================

// class AtharListTile extends StatelessWidget {
//   const AtharListTile({
//     super.key,
//     this.leading,
//     required this.title,
//     this.subtitle,
//     this.trailing,
//     this.onTap,
//     this.onLongPress,
//     this.enabled = true,
//     this.selected = false,
//     this.dense = false,
//     this.contentPadding,
//     this.leadingIcon,
//     this.trailingIcon,
//     this.showChevron = false,
//   });

//   final Widget? leading, trailing;
//   final String title;
//   final String? subtitle;
//   final VoidCallback? onTap, onLongPress;
//   final bool enabled, selected, dense, showChevron;
//   final EdgeInsetsGeometry? contentPadding;
//   final IconData? leadingIcon, trailingIcon;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Material(
//       color: selected
//           ? colors.primaryLight.withValues(alpha: 0.1)
//           : Colors.transparent,
//       borderRadius: BorderRadius.circular(AtharRadii.sm),
//       child: InkWell(
//         onTap: enabled ? onTap : null,
//         onLongPress: enabled ? onLongPress : null,
//         borderRadius: BorderRadius.circular(AtharRadii.sm),
//         child: Padding(
//           padding: contentPadding ?? AtharSpacing.listItem,
//           child: Row(
//             children: [
//               if (leading != null) ...[
//                 leading!,
//                 AtharGap.hMd,
//               ] else if (leadingIcon != null) ...[
//                 Icon(
//                   leadingIcon,
//                   color: selected ? colors.primary : colors.textSecondary,
//                   size: 24,
//                 ),
//                 AtharGap.hMd,
//               ],
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       title,
//                       style:
//                           (dense
//                                   ? AtharTypography.bodyMedium
//                                   : AtharTypography.bodyLarge)
//                               .copyWith(
//                                 color: enabled
//                                     ? (selected
//                                           ? colors.primary
//                                           : colors.textPrimary)
//                                     : colors.textDisabled,
//                               ),
//                     ),
//                     if (subtitle != null) ...[
//                       SizedBox(height: dense ? 2 : 4),
//                       Text(
//                         subtitle!,
//                         style: AtharTypography.bodySmall.copyWith(
//                           color: colors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               if (trailing != null) ...[
//                 AtharGap.hMd,
//                 trailing!,
//               ] else if (trailingIcon != null) ...[
//                 AtharGap.hMd,
//                 Icon(trailingIcon, color: colors.textTertiary, size: 20),
//               ] else if (showChevron) ...[
//                 AtharGap.hMd,
//                 Icon(Icons.chevron_right, color: colors.textTertiary, size: 20),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
