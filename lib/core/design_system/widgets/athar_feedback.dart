import 'package:flutter/material.dart';
import '../tokens.dart';

enum AtharSnackbarVariant { info, success, warning, error }

class AtharSnackbar {
  AtharSnackbar._();

  static void show({
    required BuildContext context,
    required String message,
    AtharSnackbarVariant variant = AtharSnackbarVariant.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool showCloseButton = false,
    IconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final snackbarColors = _getVariantColors(variant, colorScheme);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: snackbarColors.foreground, size: 20),
              AtharGap.hSm,
            ] else ...[
              Icon(
                _getDefaultIcon(variant),
                color: snackbarColors.foreground,
                size: 20,
              ),
              AtharGap.hSm,
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  color: snackbarColors.foreground,
                ),
              ),
            ),
            if (showCloseButton)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: snackbarColors.foreground,
                  size: 18,
                ),
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        backgroundColor: snackbarColors.background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AtharRadii.md),
        ),
        margin: AtharSpacing.allLg,
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: snackbarColors.foreground,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  static void showWithMessenger({
    required ScaffoldMessengerState messenger,
    required String message,
    required ColorScheme colorScheme,
    AtharSnackbarVariant variant = AtharSnackbarVariant.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool clearPrevious = true,
    IconData? icon,
  }) {
    final snackbarColors = _getVariantColors(variant, colorScheme);

    if (clearPrevious) {
      messenger.clearSnackBars();
    }

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? _getDefaultIcon(variant),
              color: snackbarColors.foreground,
              size: 20,
            ),
            AtharGap.hSm,
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  color: snackbarColors.foreground,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: snackbarColors.background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AtharRadii.md),
        ),
        margin: AtharSpacing.allLg,
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: snackbarColors.foreground,
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  onAction?.call();
                },
              )
            : null,
      ),
    );
  }

  static void success({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    IconData? icon,
  }) => show(
    context: context,
    message: message,
    variant: AtharSnackbarVariant.success,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration ?? const Duration(seconds: 3),
    icon: icon,
  );

  static void error({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    IconData? icon,
  }) => show(
    context: context,
    message: message,
    variant: AtharSnackbarVariant.error,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration ?? const Duration(seconds: 4),
    icon: icon,
  );

  static void warning({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    IconData? icon,
  }) => show(
    context: context,
    message: message,
    variant: AtharSnackbarVariant.warning,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration ?? const Duration(seconds: 4),
    icon: icon,
  );

  static void info({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    IconData? icon,
  }) => show(
    context: context,
    message: message,
    variant: AtharSnackbarVariant.info,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration ?? const Duration(seconds: 4),
    icon: icon,
  );

  // Semantic colors — not in ColorScheme, defined as constants
  static const _infoColor = Color(0xFF74B9FF);
  static const _successColor = Color(0xFF00B894);
  static const _warningColor = Color(0xFFFDCB6E);
  static const _onWarningColor = Color(0xFF000000);

  static _SnackbarColors _getVariantColors(
    AtharSnackbarVariant variant,
    ColorScheme colorScheme,
  ) {
    switch (variant) {
      case AtharSnackbarVariant.info:
        return const _SnackbarColors(_infoColor, Colors.white);
      case AtharSnackbarVariant.success:
        return const _SnackbarColors(_successColor, Colors.white);
      case AtharSnackbarVariant.warning:
        return const _SnackbarColors(_warningColor, _onWarningColor);
      case AtharSnackbarVariant.error:
        return _SnackbarColors(colorScheme.error, colorScheme.onError);
    }
  }

  static IconData _getDefaultIcon(AtharSnackbarVariant variant) {
    switch (variant) {
      case AtharSnackbarVariant.info:
        return Icons.info_outline;
      case AtharSnackbarVariant.success:
        return Icons.check_circle_outline;
      case AtharSnackbarVariant.warning:
        return Icons.warning_amber_outlined;
      case AtharSnackbarVariant.error:
        return Icons.error_outline;
    }
  }
}

class _SnackbarColors {
  final Color background;
  final Color foreground;
  const _SnackbarColors(this.background, this.foreground);
}

/// ATHAR LOADING

class AtharLoading extends StatelessWidget {
  const AtharLoading({
    super.key,
    this.size = 24,
    this.strokeWidth = 2,
    this.color,
    this.value,
  });

  final double size;
  final double strokeWidth;
  final Color? color;
  final double? value;

  factory AtharLoading.small({Color? color}) =>
      AtharLoading(size: 16, strokeWidth: 1.5, color: color);

  factory AtharLoading.large({Color? color}) =>
      AtharLoading(size: 40, strokeWidth: 3, color: color);

  const factory AtharLoading.centered({
    Key? key,
    double size,
    double strokeWidth,
    Color? color,
  }) = _AtharLoadingCentered;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        value: value,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? colorScheme.primary),
        backgroundColor: (color ?? colorScheme.primary).withValues(alpha: 0.2),
      ),
    );
  }
}

class _AtharLoadingCentered extends AtharLoading {
  const _AtharLoadingCentered({
    super.key,
    super.size = 24,
    super.strokeWidth = 2,
    super.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: super.build(context));
  }
}

/// ATHAR LINEAR LOADING

class AtharLinearLoading extends StatelessWidget {
  const AtharLinearLoading({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
    this.minHeight = 4,
    this.borderRadius,
  });

  final double? value;
  final Color? color;
  final Color? backgroundColor;
  final double minHeight;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? minHeight / 2),
      child: LinearProgressIndicator(
        value: value,
        minHeight: minHeight,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? colorScheme.primary),
        backgroundColor: backgroundColor ?? colorScheme.surfaceContainer,
      ),
    );
  }
}

/// ATHAR LOADING OVERLAY

class AtharLoadingOverlay extends StatelessWidget {
  const AtharLoadingOverlay({
    super.key,
    required this.isLoading,
    this.message,
    this.color,
    this.opacity = 0.7,
    required this.child,
  });

  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: (color ?? colorScheme.surface).withValues(alpha: opacity),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AtharLoading(),
                    if (message != null) ...[
                      AtharGap.md,
                      Text(
                        message!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: AtharSpacing.allXxl,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AtharRadii.lg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AtharLoading(),
                  if (message != null) ...[
                    AtharGap.lg,
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// ATHAR SHIMMER

class AtharShimmer extends StatefulWidget {
  const AtharShimmer({
    super.key,
    this.baseColor,
    this.highlightColor,
    this.enabled = true,
    required this.child,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final bool enabled;

  factory AtharShimmer.rect({
    double? width,
    double? height,
    double borderRadius = 8,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return AtharShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  factory AtharShimmer.circle({
    double size = 48,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return AtharShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // Shimmer colors — not in ColorScheme
  static const _defaultBase = Color(0xFFE0E0E0);
  static const _defaultHighlight = Color(0xFFF5F5F5);

  @override
  State<AtharShimmer> createState() => _AtharShimmerState();
}

class _AtharShimmerState extends State<AtharShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AtharAnimations.shimmerDuration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final baseColor = widget.baseColor ?? AtharShimmer._defaultBase;
    final highlightColor =
        widget.highlightColor ?? AtharShimmer._defaultHighlight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import '../tokens.dart';

// /// ===================================================================
// /// ATHAR SNACKBAR - رسالة التنبيه
// /// ===================================================================

// enum AtharSnackbarVariant { info, success, warning, error }

// /// رسالة التنبيه الموحدة
// class AtharSnackbar {
//   AtharSnackbar._();

//   /// عرض رسالة تنبيه
//   static void show({
//     required BuildContext context,
//     required String message,
//     AtharSnackbarVariant variant = AtharSnackbarVariant.info,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration duration = const Duration(seconds: 4),
//     bool showCloseButton = false,
//     IconData? icon,
//   }) {
//     final colors =
//         Theme.of(context).extension<AtharColors>() ?? AtharColors.light;
//     final snackbarColors = _getVariantColors(variant, colors);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             if (icon != null) ...[
//               Icon(icon, color: snackbarColors.foreground, size: 20),
//               AtharGap.hSm,
//             ] else ...[
//               Icon(
//                 _getDefaultIcon(variant),
//                 color: snackbarColors.foreground,
//                 size: 20,
//               ),
//               AtharGap.hSm,
//             ],
//             Expanded(
//               child: Text(
//                 message,
//                 style: AtharTypography.bodyMedium.copyWith(
//                   color: snackbarColors.foreground,
//                 ),
//               ),
//             ),
//             if (showCloseButton)
//               IconButton(
//                 icon: Icon(
//                   Icons.close,
//                   color: snackbarColors.foreground,
//                   size: 18,
//                 ),
//                 onPressed: () =>
//                     ScaffoldMessenger.of(context).hideCurrentSnackBar(),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//           ],
//         ),
//         backgroundColor: snackbarColors.background,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AtharRadii.md),
//         ),
//         margin: AtharSpacing.allLg,
//         duration: duration,
//         action: actionLabel != null
//             ? SnackBarAction(
//                 label: actionLabel,
//                 textColor: snackbarColors.foreground,
//                 onPressed: onAction ?? () {},
//               )
//             : null,
//       ),
//     );
//   }

//   /// ─────────────────────────────────────────────────────────────────
//   /// عرض رسالة مع دعم كامل للـ ScaffoldMessenger (للحالات المتقدمة)
//   /// يُستخدم عند الحاجة لـ clearSnackBars أو hideCurrentSnackBar
//   /// مثل: عمليات الحذف مع التراجع (Undo)
//   /// ─────────────────────────────────────────────────────────────────
//   static void showWithMessenger({
//     required ScaffoldMessengerState messenger,
//     required String message,
//     required AtharColors colors,
//     AtharSnackbarVariant variant = AtharSnackbarVariant.info,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration duration = const Duration(seconds: 4),
//     bool clearPrevious = true,
//     IconData? icon,
//   }) {
//     final snackbarColors = _getVariantColors(variant, colors);

//     if (clearPrevious) {
//       messenger.clearSnackBars();
//     }

//     messenger.showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               icon ?? _getDefaultIcon(variant),
//               color: snackbarColors.foreground,
//               size: 20,
//             ),
//             AtharGap.hSm,
//             Expanded(
//               child: Text(
//                 message,
//                 style: AtharTypography.bodyMedium.copyWith(
//                   color: snackbarColors.foreground,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: snackbarColors.background,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AtharRadii.md),
//         ),
//         margin: AtharSpacing.allLg,
//         duration: duration,
//         action: actionLabel != null
//             ? SnackBarAction(
//                 label: actionLabel,
//                 textColor: snackbarColors.foreground,
//                 onPressed: () {
//                   messenger.hideCurrentSnackBar();
//                   onAction?.call();
//                 },
//               )
//             : null,
//       ),
//     );
//   }

//   /// رسالة نجاح
//   static void success({
//     required BuildContext context,
//     required String message,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration? duration,
//     IconData? icon,
//   }) => show(
//     context: context,
//     message: message,
//     variant: AtharSnackbarVariant.success,
//     actionLabel: actionLabel,
//     onAction: onAction,
//     duration: duration ?? const Duration(seconds: 3),
//     icon: icon,
//   );

//   /// رسالة خطأ
//   static void error({
//     required BuildContext context,
//     required String message,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration? duration,
//     IconData? icon,
//   }) => show(
//     context: context,
//     message: message,
//     variant: AtharSnackbarVariant.error,
//     actionLabel: actionLabel,
//     onAction: onAction,
//     duration: duration ?? const Duration(seconds: 4),
//     icon: icon,
//   );

//   /// رسالة تحذير
//   static void warning({
//     required BuildContext context,
//     required String message,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration? duration,
//     IconData? icon,
//   }) => show(
//     context: context,
//     message: message,
//     variant: AtharSnackbarVariant.warning,
//     actionLabel: actionLabel,
//     onAction: onAction,
//     duration: duration ?? const Duration(seconds: 4),
//     icon: icon,
//   );

//   /// رسالة معلومات
//   static void info({
//     required BuildContext context,
//     required String message,
//     String? actionLabel,
//     VoidCallback? onAction,
//     Duration? duration,
//     IconData? icon,
//   }) => show(
//     context: context,
//     message: message,
//     variant: AtharSnackbarVariant.info,
//     actionLabel: actionLabel,
//     onAction: onAction,
//     duration: duration ?? const Duration(seconds: 4),
//     icon: icon,
//   );

//   static _SnackbarColors _getVariantColors(
//     AtharSnackbarVariant variant,
//     AtharColors colors,
//   ) {
//     switch (variant) {
//       case AtharSnackbarVariant.info:
//         return _SnackbarColors(colors.info, colors.onInfo);
//       case AtharSnackbarVariant.success:
//         return _SnackbarColors(colors.success, colors.onSuccess);
//       case AtharSnackbarVariant.warning:
//         return _SnackbarColors(colors.warning, colors.onWarning);
//       case AtharSnackbarVariant.error:
//         return _SnackbarColors(colors.error, colors.onError);
//     }
//   }

//   static IconData _getDefaultIcon(AtharSnackbarVariant variant) {
//     switch (variant) {
//       case AtharSnackbarVariant.info:
//         return Icons.info_outline;
//       case AtharSnackbarVariant.success:
//         return Icons.check_circle_outline;
//       case AtharSnackbarVariant.warning:
//         return Icons.warning_amber_outlined;
//       case AtharSnackbarVariant.error:
//         return Icons.error_outline;
//     }
//   }
// }

// class _SnackbarColors {
//   final Color background;
//   final Color foreground;
//   const _SnackbarColors(this.background, this.foreground);
// }

// /// ===================================================================
// /// ATHAR LOADING - مؤشرات التحميل
// /// ===================================================================

// /// مؤشر تحميل دائري
// class AtharLoading extends StatelessWidget {
//   const AtharLoading({
//     super.key,
//     this.size = 24,
//     this.strokeWidth = 2,
//     this.color,
//     this.value,
//   });

//   final double size;
//   final double strokeWidth;
//   final Color? color;
//   final double? value;

//   /// مؤشر صغير
//   factory AtharLoading.small({Color? color}) =>
//       AtharLoading(size: 16, strokeWidth: 1.5, color: color);

//   /// مؤشر كبير
//   factory AtharLoading.large({Color? color}) =>
//       AtharLoading(size: 40, strokeWidth: 3, color: color);

//   /// مؤشر في المنتصف
//   const factory AtharLoading.centered({
//     Key? key,
//     double size,
//     double strokeWidth,
//     Color? color,
//   }) = _AtharLoadingCentered;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     return SizedBox(
//       width: size,
//       height: size,
//       child: CircularProgressIndicator(
//         strokeWidth: strokeWidth,
//         value: value,
//         valueColor: AlwaysStoppedAnimation<Color>(color ?? colors.primary),
//         backgroundColor: (color ?? colors.primary).withValues(alpha: 0.2),
//       ),
//     );
//   }
// }

// /// مؤشر تحميل في المنتصف
// class _AtharLoadingCentered extends AtharLoading {
//   const _AtharLoadingCentered({
//     super.key,
//     super.size = 24,
//     super.strokeWidth = 2,
//     super.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(child: super.build(context));
//   }
// }

// /// مؤشر تحميل خطي
// class AtharLinearLoading extends StatelessWidget {
//   const AtharLinearLoading({
//     super.key,
//     this.value,
//     this.color,
//     this.backgroundColor,
//     this.minHeight = 4,
//     this.borderRadius,
//   });

//   final double? value;
//   final Color? color;
//   final Color? backgroundColor;
//   final double minHeight;
//   final double? borderRadius;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(borderRadius ?? minHeight / 2),
//       child: LinearProgressIndicator(
//         value: value,
//         minHeight: minHeight,
//         valueColor: AlwaysStoppedAnimation<Color>(color ?? colors.primary),
//         backgroundColor: backgroundColor ?? colors.surfaceContainer,
//       ),
//     );
//   }
// }

// /// غطاء التحميل
// class AtharLoadingOverlay extends StatelessWidget {
//   const AtharLoadingOverlay({
//     super.key,
//     required this.isLoading,
//     this.message,
//     this.color,
//     this.opacity = 0.7,
//     required this.child,
//   });

//   final Widget child;
//   final bool isLoading;
//   final String? message;
//   final Color? color;
//   final double opacity;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     return Stack(
//       children: [
//         child,
//         if (isLoading)
//           Positioned.fill(
//             child: Container(
//               color: (color ?? colors.surface).withValues(alpha: opacity),
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const AtharLoading(),
//                     if (message != null) ...[
//                       AtharGap.md,
//                       Text(
//                         message!,
//                         style: AtharTypography.bodyMedium.copyWith(
//                           color: colors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   /// عرض شاشة تحميل كاملة
//   static void show(BuildContext context, {String? message}) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: Colors.black54,
//       builder: (context) {
//         final colors =
//             Theme.of(context).extension<AtharColors>() ?? AtharColors.light;
//         return PopScope(
//           canPop: false,
//           child: Center(
//             child: Container(
//               padding: AtharSpacing.allXxl,
//               decoration: BoxDecoration(
//                 color: colors.surface,
//                 borderRadius: BorderRadius.circular(AtharRadii.lg),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const AtharLoading(),
//                   if (message != null) ...[
//                     AtharGap.lg,
//                     Text(
//                       message,
//                       style: AtharTypography.bodyMedium.copyWith(
//                         color: colors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// إخفاء شاشة التحميل
//   static void hide(BuildContext context) {
//     Navigator.of(context, rootNavigator: true).pop();
//   }
// }

// /// ===================================================================
// /// ATHAR SHIMMER - تأثير التحميل اللامع
// /// ===================================================================

// class AtharShimmer extends StatefulWidget {
//   const AtharShimmer({
//     super.key,
//     this.baseColor,
//     this.highlightColor,
//     this.enabled = true,
//     required this.child,
//   });

//   final Widget child;
//   final Color? baseColor;
//   final Color? highlightColor;
//   final bool enabled;

//   /// شكل مستطيل
//   factory AtharShimmer.rect({
//     double? width,
//     double? height,
//     double borderRadius = 8,
//     Color? baseColor,
//     Color? highlightColor,
//   }) {
//     return AtharShimmer(
//       baseColor: baseColor,
//       highlightColor: highlightColor,
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(borderRadius),
//         ),
//       ),
//     );
//   }

//   /// شكل دائري
//   factory AtharShimmer.circle({
//     double size = 48,
//     Color? baseColor,
//     Color? highlightColor,
//   }) {
//     return AtharShimmer(
//       baseColor: baseColor,
//       highlightColor: highlightColor,
//       child: Container(
//         width: size,
//         height: size,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//         ),
//       ),
//     );
//   }

//   @override
//   State<AtharShimmer> createState() => _AtharShimmerState();
// }

// class _AtharShimmerState extends State<AtharShimmer>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: AtharAnimations.shimmerDuration,
//       vsync: this,
//     )..repeat();
//     _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!widget.enabled) return widget.child;

//     final colors = context.colors;
//     final baseColor = widget.baseColor ?? colors.shimmerBase;
//     final highlightColor = widget.highlightColor ?? colors.shimmerHighlight;

//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return ShaderMask(
//           shaderCallback: (bounds) {
//             return LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [baseColor, highlightColor, baseColor],
//               stops: [
//                 (_animation.value - 0.3).clamp(0.0, 1.0),
//                 _animation.value.clamp(0.0, 1.0),
//                 (_animation.value + 0.3).clamp(0.0, 1.0),
//               ],
//             ).createShader(bounds);
//           },
//           blendMode: BlendMode.srcATop,
//           child: widget.child,
//         );
//       },
//     );
//   }
// }
//-----------------------------------------------------------------------
