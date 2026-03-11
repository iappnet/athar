import 'package:flutter/material.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import '../tokens.dart';

/// ATHAR AVATAR

enum AtharAvatarSize { xs, sm, md, lg, xl, xxl }

class AtharAvatar extends StatelessWidget {
  const AtharAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.icon,
    this.size = AtharAvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
    this.badge,
    this.isOnline,
  });

  final String? imageUrl;
  final String? name;
  final IconData? icon;
  final AtharAvatarSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final Widget? badge;
  final bool? isOnline;

  double get _size {
    switch (size) {
      case AtharAvatarSize.xs:
        return 24;
      case AtharAvatarSize.sm:
        return 32;
      case AtharAvatarSize.md:
        return 40;
      case AtharAvatarSize.lg:
        return 56;
      case AtharAvatarSize.xl:
        return 72;
      case AtharAvatarSize.xxl:
        return 96;
    }
  }

  double get _fontSize {
    switch (size) {
      case AtharAvatarSize.xs:
        return 10;
      case AtharAvatarSize.sm:
        return 12;
      case AtharAvatarSize.md:
        return 14;
      case AtharAvatarSize.lg:
        return 20;
      case AtharAvatarSize.xl:
        return 28;
      case AtharAvatarSize.xxl:
        return 36;
    }
  }

  String? get _initials {
    if (name == null || name!.isEmpty) return null;
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  static const Color _successColor = Color(0xFF00B894);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBgColor = backgroundColor ?? colorScheme.primaryContainer;
    final effectiveFgColor = foregroundColor ?? colorScheme.primary;

    Widget avatar = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveBgColor,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? colorScheme.surface,
                width: borderWidth,
              )
            : null,
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: icon != null
                  ? Icon(icon, size: _fontSize * 1.2, color: effectiveFgColor)
                  : Text(
                      _initials ?? '?',
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w600,
                        color: effectiveFgColor,
                      ),
                    ),
            )
          : null,
    );

    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      );
    }

    if (badge != null || isOnline != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (badge != null)
            Positioned(right: 0, bottom: 0, child: badge!)
          else if (isOnline != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: _size * 0.3,
                height: _size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline!
                      ? _successColor
                      : colorScheme.onSurface.withValues(alpha: 0.38),
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
              ),
            ),
        ],
      );
    }

    return avatar;
  }
}

/// مجموعة صور رمزية متداخلة
class AtharAvatarGroup extends StatelessWidget {
  const AtharAvatarGroup({
    super.key,
    required this.avatars,
    this.size = AtharAvatarSize.sm,
    this.maxVisible = 4,
    this.overlap = 0.3,
    this.onTap,
  });

  final List<AtharAvatarData> avatars;
  final AtharAvatarSize size;
  final int maxVisible;
  final double overlap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visibleAvatars = avatars.take(maxVisible).toList();
    final remaining = avatars.length - maxVisible;
    final avatarSize = AtharAvatar(size: size)._size;
    final overlapOffset = avatarSize * overlap;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(avatarSize / 2),
      child: SizedBox(
        height: avatarSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ...visibleAvatars.asMap().entries.map((entry) {
              final index = entry.key;
              final avatar = entry.value;
              return Positioned(
                left: index * (avatarSize - overlapOffset),
                child: AtharAvatar(
                  size: size,
                  imageUrl: avatar.imageUrl,
                  name: avatar.name,
                  borderColor: colorScheme.surface,
                  borderWidth: 2,
                ),
              );
            }),
            if (remaining > 0)
              Positioned(
                left: visibleAvatars.length * (avatarSize - overlapOffset),
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainer,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '+$remaining',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AtharAvatarData {
  const AtharAvatarData({this.imageUrl, this.name});
  final String? imageUrl;
  final String? name;
}

/// ATHAR DIVIDER

class AtharDivider extends StatelessWidget {
  const AtharDivider({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
    this.height,
  });

  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final double? height;

  const AtharDivider.horizontal({
    Key? key,
    double thickness = 1,
    double indent = 0,
    double endIndent = 0,
    Color? color,
    double? height,
  }) : this(
         key: key,
         thickness: thickness,
         indent: indent,
         endIndent: endIndent,
         color: color,
         height: height,
       );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? colorScheme.outlineVariant,
      height: height ?? thickness,
    );
  }
}

class AtharVerticalDivider extends StatelessWidget {
  const AtharVerticalDivider({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
    this.width,
  });

  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return VerticalDivider(
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? colorScheme.outlineVariant,
      width: width ?? thickness,
    );
  }
}

/// ATHAR EMPTY STATE

class AtharEmptyState extends StatelessWidget {
  const AtharEmptyState({
    super.key,
    this.icon,
    this.image,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData? icon;
  final Widget? image;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  factory AtharEmptyState.noData({
    required BuildContext context,
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final l10n = AppLocalizations.of(context);
    return AtharEmptyState(
      icon: Icons.inbox_outlined,
      title: title ?? l10n.emptyStateNoData,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory AtharEmptyState.noResults({
    required BuildContext context,
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final l10n = AppLocalizations.of(context);
    return AtharEmptyState(
      icon: Icons.search_off_outlined,
      title: title ?? l10n.emptyStateNoResults,
      message: message ?? l10n.emptyStateNoResultsMessage,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory AtharEmptyState.error({
    required BuildContext context,
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final l10n = AppLocalizations.of(context);
    return AtharEmptyState(
      icon: Icons.error_outline,
      title: title ?? l10n.emptyStateError,
      message: message ?? l10n.emptyStateErrorMessage,
      actionLabel: actionLabel ?? l10n.emptyStateRetry,
      onAction: onAction,
    );
  }

  factory AtharEmptyState.noConnection({
    required BuildContext context,
    String? title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final l10n = AppLocalizations.of(context);
    return AtharEmptyState(
      icon: Icons.wifi_off_outlined,
      title: title ?? l10n.emptyStateNoConnection,
      message: message ?? l10n.emptyStateNoConnectionMessage,
      actionLabel: actionLabel ?? l10n.emptyStateRetry,
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: compact ? AtharSpacing.allMd : AtharSpacing.allXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null) ...[
              image!,
              SizedBox(height: compact ? 16 : 24),
            ] else if (icon != null) ...[
              Container(
                padding: EdgeInsets.all(compact ? 16 : 24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: compact ? 32 : 48,
                  color: colorScheme.outline,
                ),
              ),
              SizedBox(height: compact ? 16 : 24),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: compact ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: compact ? 4 : 8),
            ],
            if (message != null) ...[
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: compact ? 16 : 24),
            ],
            if (actionLabel != null && onAction != null)
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}
//-----------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import '../tokens.dart';

// /// ===================================================================
// /// ATHAR AVATAR - الصورة الرمزية الموحدة
// /// ===================================================================

// enum AtharAvatarSize { xs, sm, md, lg, xl, xxl }

// class AtharAvatar extends StatelessWidget {
//   const AtharAvatar({
//     super.key,
//     this.imageUrl,
//     this.name,
//     this.icon,
//     this.size = AtharAvatarSize.md,
//     this.backgroundColor,
//     this.foregroundColor,
//     this.borderColor,
//     this.borderWidth = 0,
//     this.onTap,
//     this.badge,
//     this.isOnline,
//   });

//   final String? imageUrl;
//   final String? name;
//   final IconData? icon;
//   final AtharAvatarSize size;
//   final Color? backgroundColor;
//   final Color? foregroundColor;
//   final Color? borderColor;
//   final double borderWidth;
//   final VoidCallback? onTap;
//   final Widget? badge;
//   final bool? isOnline;

//   double get _size {
//     switch (size) {
//       case AtharAvatarSize.xs:
//         return 24;
//       case AtharAvatarSize.sm:
//         return 32;
//       case AtharAvatarSize.md:
//         return 40;
//       case AtharAvatarSize.lg:
//         return 56;
//       case AtharAvatarSize.xl:
//         return 72;
//       case AtharAvatarSize.xxl:
//         return 96;
//     }
//   }

//   double get _fontSize {
//     switch (size) {
//       case AtharAvatarSize.xs:
//         return 10;
//       case AtharAvatarSize.sm:
//         return 12;
//       case AtharAvatarSize.md:
//         return 14;
//       case AtharAvatarSize.lg:
//         return 20;
//       case AtharAvatarSize.xl:
//         return 28;
//       case AtharAvatarSize.xxl:
//         return 36;
//     }
//   }

//   String? get _initials {
//     if (name == null || name!.isEmpty) return null;
//     final parts = name!.trim().split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return parts[0][0].toUpperCase();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final effectiveBgColor = backgroundColor ?? colors.primaryLight;
//     final effectiveFgColor = foregroundColor ?? colors.primary;

//     Widget avatar = Container(
//       width: _size,
//       height: _size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: effectiveBgColor,
//         border: borderWidth > 0
//             ? Border.all(
//                 color: borderColor ?? colors.surface,
//                 width: borderWidth,
//               )
//             : null,
//         image: imageUrl != null
//             ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
//             : null,
//       ),
//       child: imageUrl == null
//           ? Center(
//               child: icon != null
//                   ? Icon(icon, size: _fontSize * 1.2, color: effectiveFgColor)
//                   : Text(
//                       _initials ?? '?',
//                       style: TextStyle(
//                         fontSize: _fontSize,
//                         fontWeight: FontWeight.w600,
//                         color: effectiveFgColor,
//                       ),
//                     ),
//             )
//           : null,
//     );

//     if (onTap != null) {
//       avatar = InkWell(
//         onTap: onTap,
//         customBorder: const CircleBorder(),
//         child: avatar,
//       );
//     }

//     if (badge != null || isOnline != null) {
//       avatar = Stack(
//         clipBehavior: Clip.none,
//         children: [
//           avatar,
//           if (badge != null)
//             Positioned(right: 0, bottom: 0, child: badge!)
//           else if (isOnline != null)
//             Positioned(
//               right: 0,
//               bottom: 0,
//               child: Container(
//                 width: _size * 0.3,
//                 height: _size * 0.3,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: isOnline! ? colors.success : colors.textDisabled,
//                   border: Border.all(color: colors.surface, width: 2),
//                 ),
//               ),
//             ),
//         ],
//       );
//     }

//     return avatar;
//   }
// }

// /// مجموعة صور رمزية متداخلة
// class AtharAvatarGroup extends StatelessWidget {
//   const AtharAvatarGroup({
//     super.key,
//     required this.avatars,
//     this.size = AtharAvatarSize.sm,
//     this.maxVisible = 4,
//     this.overlap = 0.3,
//     this.onTap,
//   });

//   final List<AtharAvatarData> avatars;
//   final AtharAvatarSize size;
//   final int maxVisible;
//   final double overlap;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final visibleAvatars = avatars.take(maxVisible).toList();
//     final remaining = avatars.length - maxVisible;
//     final avatarSize = AtharAvatar(size: size)._size;
//     final overlapOffset = avatarSize * overlap;

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(avatarSize / 2),
//       child: SizedBox(
//         height: avatarSize,
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             ...visibleAvatars.asMap().entries.map((entry) {
//               final index = entry.key;
//               final avatar = entry.value;
//               return Positioned(
//                 left: index * (avatarSize - overlapOffset),
//                 child: AtharAvatar(
//                   size: size,
//                   imageUrl: avatar.imageUrl,
//                   name: avatar.name,
//                   borderColor: colors.surface,
//                   borderWidth: 2,
//                 ),
//               );
//             }),
//             if (remaining > 0)
//               Positioned(
//                 left: visibleAvatars.length * (avatarSize - overlapOffset),
//                 child: Container(
//                   width: avatarSize,
//                   height: avatarSize,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: colors.surfaceContainer,
//                     border: Border.all(color: colors.surface, width: 2),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '+$remaining',
//                       style: AtharTypography.labelSmall.copyWith(
//                         color: colors.textSecondary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AtharAvatarData {
//   const AtharAvatarData({this.imageUrl, this.name});
//   final String? imageUrl;
//   final String? name;
// }

// /// ===================================================================
// /// ATHAR DIVIDER - الفاصل الموحد
// /// ===================================================================

// class AtharDivider extends StatelessWidget {
//   const AtharDivider({
//     super.key,
//     this.thickness = 1,
//     this.indent = 0,
//     this.endIndent = 0,
//     this.color,
//     this.height,
//   });

//   final double thickness;
//   final double indent;
//   final double endIndent;
//   final Color? color;
//   final double? height;

//   /// فاصل أفقي
//   const AtharDivider.horizontal({
//     Key? key,
//     double thickness = 1,
//     double indent = 0,
//     double endIndent = 0,
//     Color? color,
//     double? height,
//   }) : this(
//          key: key,
//          thickness: thickness,
//          indent: indent,
//          endIndent: endIndent,
//          color: color,
//          height: height,
//        );

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     return Divider(
//       thickness: thickness,
//       indent: indent,
//       endIndent: endIndent,
//       color: color ?? colors.divider,
//       height: height ?? thickness,
//     );
//   }
// }

// /// فاصل عمودي
// class AtharVerticalDivider extends StatelessWidget {
//   const AtharVerticalDivider({
//     super.key,
//     this.thickness = 1,
//     this.indent = 0,
//     this.endIndent = 0,
//     this.color,
//     this.width,
//   });

//   final double thickness;
//   final double indent;
//   final double endIndent;
//   final Color? color;
//   final double? width;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     return VerticalDivider(
//       thickness: thickness,
//       indent: indent,
//       endIndent: endIndent,
//       color: color ?? colors.divider,
//       width: width ?? thickness,
//     );
//   }
// }

// /// ===================================================================
// /// ATHAR EMPTY STATE - حالة فارغة موحدة
// /// ===================================================================

// class AtharEmptyState extends StatelessWidget {
//   const AtharEmptyState({
//     super.key,
//     this.icon,
//     this.image,
//     this.title,
//     this.message,
//     this.actionLabel,
//     this.onAction,
//     this.compact = false,
//   });

//   final IconData? icon;
//   final Widget? image;
//   final String? title;
//   final String? message;
//   final String? actionLabel;
//   final VoidCallback? onAction;
//   final bool compact;

//   /// حالة لا توجد بيانات
//   factory AtharEmptyState.noData({
//     String? title,
//     String? message,
//     String? actionLabel,
//     VoidCallback? onAction,
//   }) => AtharEmptyState(
//     icon: Icons.inbox_outlined,
//     title: title ?? 'لا توجد بيانات',
//     message: message,
//     actionLabel: actionLabel,
//     onAction: onAction,
//   );

//   /// حالة لا توجد نتائج بحث
//   factory AtharEmptyState.noResults({
//     String? title,
//     String? message,
//     String? actionLabel,
//     VoidCallback? onAction,
//   }) => AtharEmptyState(
//     icon: Icons.search_off_outlined,
//     title: title ?? 'لا توجد نتائج',
//     message: message ?? 'جرب البحث بكلمات مختلفة',
//     actionLabel: actionLabel,
//     onAction: onAction,
//   );

//   /// حالة خطأ
//   factory AtharEmptyState.error({
//     String? title,
//     String? message,
//     String? actionLabel,
//     VoidCallback? onAction,
//   }) => AtharEmptyState(
//     icon: Icons.error_outline,
//     title: title ?? 'حدث خطأ',
//     message: message ?? 'حدث خطأ غير متوقع',
//     actionLabel: actionLabel ?? 'إعادة المحاولة',
//     onAction: onAction,
//   );

//   /// حالة لا يوجد اتصال
//   factory AtharEmptyState.noConnection({
//     String? title,
//     String? message,
//     String? actionLabel,
//     VoidCallback? onAction,
//   }) => AtharEmptyState(
//     icon: Icons.wifi_off_outlined,
//     title: title ?? 'لا يوجد اتصال',
//     message: message ?? 'تحقق من اتصالك بالإنترنت',
//     actionLabel: actionLabel ?? 'إعادة المحاولة',
//     onAction: onAction,
//   );

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Center(
//       child: Padding(
//         padding: compact ? AtharSpacing.allMd : AtharSpacing.allXxl,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (image != null) ...[
//               image!,
//               SizedBox(height: compact ? 16 : 24),
//             ] else if (icon != null) ...[
//               Container(
//                 padding: EdgeInsets.all(compact ? 16 : 24),
//                 decoration: BoxDecoration(
//                   color: colors.surfaceContainer,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   icon,
//                   size: compact ? 32 : 48,
//                   color: colors.textTertiary,
//                 ),
//               ),
//               SizedBox(height: compact ? 16 : 24),
//             ],
//             if (title != null) ...[
//               Text(
//                 title!,
//                 style:
//                     (compact
//                             ? AtharTypography.titleMedium
//                             : AtharTypography.titleLarge)
//                         .copyWith(color: colors.textPrimary),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: compact ? 4 : 8),
//             ],
//             if (message != null) ...[
//               Text(
//                 message!,
//                 style: AtharTypography.bodyMedium.copyWith(
//                   color: colors.textSecondary,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: compact ? 16 : 24),
//             ],
//             if (actionLabel != null && onAction != null)
//               ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
