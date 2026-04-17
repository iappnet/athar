import 'package:flutter/material.dart';
import '../tokens.dart';

/// ATHAR BUTTON

enum AtharButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
  success,
  warning,
  info,
}

enum AtharButtonSize { small, medium, large, xlarge }

enum IconPosition { start, end }

class AtharButtonStyle {
  const AtharButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.padding,
    this.textStyle,
    this.iconSize,
    this.gap,
  });

  final Color? backgroundColor, foregroundColor;
  final Color? disabledBackgroundColor, disabledForegroundColor;
  final Color? borderColor, shadowColor;
  final double? borderWidth, borderRadius, elevation, iconSize, gap;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
}

class AtharButton extends StatefulWidget {
  const AtharButton({
    super.key,
    this.label,
    this.icon,
    this.child,
    this.iconPosition = IconPosition.start,
    this.variant = AtharButtonVariant.primary,
    this.size = AtharButtonSize.medium,
    this.customStyle,
    this.onPressed,
    this.onLongPress,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.loadingWidget,
    this.tooltip,
  }) : assert(label != null || child != null || icon != null);

  final String? label;
  final IconData? icon;
  final Widget? child;
  final IconPosition iconPosition;
  final AtharButtonVariant variant;
  final AtharButtonSize size;
  final AtharButtonStyle? customStyle;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isLoading, isDisabled, isFullWidth;
  final Widget? loadingWidget;
  final String? tooltip;

  factory AtharButton.primary({
    Key? key,
    String? label,
    IconData? icon,
    AtharButtonSize size = AtharButtonSize.medium,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    String? tooltip,
  }) => AtharButton(
    key: key,
    label: label,
    icon: icon,
    variant: AtharButtonVariant.primary,
    size: size,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    isFullWidth: isFullWidth,
    tooltip: tooltip,
  );

  factory AtharButton.secondary({
    Key? key,
    String? label,
    IconData? icon,
    AtharButtonSize size = AtharButtonSize.medium,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    String? tooltip,
  }) => AtharButton(
    key: key,
    label: label,
    icon: icon,
    variant: AtharButtonVariant.secondary,
    size: size,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    isFullWidth: isFullWidth,
    tooltip: tooltip,
  );

  factory AtharButton.outline({
    Key? key,
    String? label,
    IconData? icon,
    AtharButtonSize size = AtharButtonSize.medium,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    String? tooltip,
  }) => AtharButton(
    key: key,
    label: label,
    icon: icon,
    variant: AtharButtonVariant.outline,
    size: size,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    isFullWidth: isFullWidth,
    tooltip: tooltip,
  );

  factory AtharButton.ghost({
    Key? key,
    String? label,
    IconData? icon,
    AtharButtonSize size = AtharButtonSize.medium,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    String? tooltip,
  }) => AtharButton(
    key: key,
    label: label,
    icon: icon,
    variant: AtharButtonVariant.ghost,
    size: size,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    isFullWidth: isFullWidth,
    tooltip: tooltip,
  );

  factory AtharButton.danger({
    Key? key,
    String? label,
    IconData? icon,
    AtharButtonSize size = AtharButtonSize.medium,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    String? tooltip,
  }) => AtharButton(
    key: key,
    label: label,
    icon: icon,
    variant: AtharButtonVariant.danger,
    size: size,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    isFullWidth: isFullWidth,
    tooltip: tooltip,
  );

  factory AtharButton.success({
    Key? key,
    String? label,
    IconData? icon,
    AtharButtonSize size = AtharButtonSize.medium,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    String? tooltip,
  }) => AtharButton(
    key: key,
    label: label,
    icon: icon,
    variant: AtharButtonVariant.success,
    size: size,
    onPressed: onPressed,
    isLoading: isLoading,
    isDisabled: isDisabled,
    isFullWidth: isFullWidth,
    tooltip: tooltip,
  );

  factory AtharButton.icon({
    Key? key,
    required IconData icon,
    AtharButtonVariant variant = AtharButtonVariant.ghost,
    AtharButtonSize size = AtharButtonSize.medium,
    VoidCallback? onPressed,
    bool isDisabled = false,
    String? tooltip,
  }) => AtharButton(
    key: key,
    icon: icon,
    variant: variant,
    size: size,
    onPressed: onPressed,
    isDisabled: isDisabled,
    tooltip: tooltip,
  );

  @override
  State<AtharButton> createState() => _AtharButtonState();
}

class _AtharButtonState extends State<AtharButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  // Semantic colors — not in ColorScheme
  static const _successColor = Color(0xFF00B894);
  static const _onSuccessColor = Colors.white;
  static const _warningColor = Color(0xFFFDCB6E);
  static const _onWarningColor = Color(0xFF000000);
  static const _infoColor = Color(0xFF74B9FF);
  static const _onInfoColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AtharAnimations.buttonDuration,
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AtharAnimations.buttonCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled =>
      !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = _resolveStyle(colorScheme);

    Widget button = GestureDetector(
      onTapDown: _isEnabled ? (_) => _controller.forward() : null,
      onTapUp: _isEnabled ? (_) => _controller.reverse() : null,
      onTapCancel: _isEnabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: _buildButton(colorScheme, style),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    if (widget.isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildButton(ColorScheme colorScheme, _Style s) {
    return AnimatedContainer(
      duration: AtharAnimations.fast,
      height: s.height,
      constraints: BoxConstraints(minWidth: s.minWidth),
      decoration: BoxDecoration(
        color: _isEnabled ? s.bgColor : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(s.radius),
        border: s.borderColor != null
            ? Border.all(
                color: _isEnabled ? s.borderColor! : colorScheme.outlineVariant,
                width: s.borderWidth,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isEnabled ? widget.onPressed : null,
          onLongPress: _isEnabled ? widget.onLongPress : null,
          borderRadius: BorderRadius.circular(s.radius),
          splashColor: s.fgColor.withValues(alpha: 0.1),
          child: Padding(
            padding: s.padding,
            child: _buildContent(colorScheme, s),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme, _Style s) {
    final fg = _isEnabled
        ? s.fgColor
        : colorScheme.onSurface.withValues(alpha: 0.38);

    if (widget.isLoading) {
      return widget.loadingWidget ??
          SizedBox(
            width: s.iconSize,
            height: s.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(fg),
            ),
          );
    }
    if (widget.child != null) return widget.child!;
    if (widget.label == null && widget.icon != null) {
      return Icon(widget.icon, size: s.iconSize, color: fg);
    }
    if (widget.icon == null && widget.label != null) {
      return Text(widget.label!, style: s.textStyle.copyWith(color: fg));
    }

    final icon = Icon(widget.icon, size: s.iconSize, color: fg);
    final text = Flexible(
      child: Text(
        widget.label!,
        style: s.textStyle.copyWith(color: fg),
        overflow: TextOverflow.ellipsis,
      ),
    );
    final gap = SizedBox(width: s.gap);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.iconPosition == IconPosition.start
          ? [icon, gap, text]
          : [text, gap, icon],
    );
  }

  _Style _resolveStyle(ColorScheme c) {
    final v = _variantStyle(c);
    final z = _sizeStyle();
    final custom = widget.customStyle;
    return _Style(
      bgColor: custom?.backgroundColor ?? v.bgColor,
      fgColor: custom?.foregroundColor ?? v.fgColor,
      borderColor: custom?.borderColor ?? v.borderColor,
      borderWidth: custom?.borderWidth ?? v.borderWidth,
      radius: custom?.borderRadius ?? z.radius,
      padding: custom?.padding ?? z.padding,
      textStyle: custom?.textStyle ?? z.textStyle,
      iconSize: custom?.iconSize ?? z.iconSize,
      gap: custom?.gap ?? z.gap,
      height: z.height,
      minWidth: z.minWidth,
    );
  }

  _VStyle _variantStyle(ColorScheme c) {
    switch (widget.variant) {
      case AtharButtonVariant.primary:
        return _VStyle(c.primary, c.onPrimary, null, 0);
      case AtharButtonVariant.secondary:
        return _VStyle(c.secondary, c.onSecondary, null, 0);
      case AtharButtonVariant.outline:
        return _VStyle(Colors.transparent, c.primary, c.primary, 1.5);
      case AtharButtonVariant.ghost:
        return _VStyle(Colors.transparent, c.primary, null, 0);
      case AtharButtonVariant.danger:
        return _VStyle(c.error, c.onError, null, 0);
      case AtharButtonVariant.success:
        return const _VStyle(_successColor, _onSuccessColor, null, 0);
      case AtharButtonVariant.warning:
        return const _VStyle(_warningColor, _onWarningColor, null, 0);
      case AtharButtonVariant.info:
        return const _VStyle(_infoColor, _onInfoColor, null, 0);
    }
  }

  static const _buttonSmallStyle = TextStyle(
    fontSize: AtharTypography.sizeSm,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.25,
  );
  static const _buttonStyle = TextStyle(
    fontSize: AtharTypography.sizeMd,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.25,
  );
  static const _buttonLargeStyle = TextStyle(
    fontSize: AtharTypography.sizeLg,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.25,
  );

  _ZStyle _sizeStyle() {
    switch (widget.size) {
      case AtharButtonSize.small:
        return _ZStyle(
          36,
          64,
          AtharRadii.sm,
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          _buttonSmallStyle,
          16,
          6,
        );
      case AtharButtonSize.medium:
        return _ZStyle(
          44,
          80,
          AtharRadii.sm,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          _buttonStyle,
          20,
          8,
        );
      case AtharButtonSize.large:
        return _ZStyle(
          52,
          96,
          AtharRadii.md,
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          _buttonStyle,
          22,
          10,
        );
      case AtharButtonSize.xlarge:
        return _ZStyle(
          60,
          120,
          AtharRadii.md,
          const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          _buttonLargeStyle,
          24,
          12,
        );
    }
  }
}

class _VStyle {
  final Color bgColor, fgColor;
  final Color? borderColor;
  final double borderWidth;
  const _VStyle(this.bgColor, this.fgColor, this.borderColor, this.borderWidth);
}

class _ZStyle {
  final double height, minWidth, radius, iconSize, gap;
  final EdgeInsets padding;
  final TextStyle textStyle;
  const _ZStyle(
    this.height,
    this.minWidth,
    this.radius,
    this.padding,
    this.textStyle,
    this.iconSize,
    this.gap,
  );
}

class _Style {
  final Color bgColor, fgColor;
  final Color? borderColor;
  final double borderWidth, radius, iconSize, gap, height, minWidth;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  const _Style({
    required this.bgColor,
    required this.fgColor,
    this.borderColor,
    required this.borderWidth,
    required this.radius,
    required this.padding,
    required this.textStyle,
    required this.iconSize,
    required this.gap,
    required this.height,
    required this.minWidth,
  });
}
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import '../tokens.dart';

// /// ===================================================================
// /// ATHAR BUTTON - الزر الموحد
// /// ===================================================================

// enum AtharButtonVariant {
//   primary,
//   secondary,
//   outline,
//   ghost,
//   danger,
//   success,
//   warning,
//   info,
// }

// enum AtharButtonSize { small, medium, large, xlarge }

// enum IconPosition { start, end }

// /// ستايل مخصص للزر
// class AtharButtonStyle {
//   const AtharButtonStyle({
//     this.backgroundColor,
//     this.foregroundColor,
//     this.disabledBackgroundColor,
//     this.disabledForegroundColor,
//     this.borderColor,
//     this.borderWidth,
//     this.borderRadius,
//     this.elevation,
//     this.shadowColor,
//     this.padding,
//     this.textStyle,
//     this.iconSize,
//     this.gap,
//   });

//   final Color? backgroundColor, foregroundColor;
//   final Color? disabledBackgroundColor, disabledForegroundColor;
//   final Color? borderColor, shadowColor;
//   final double? borderWidth, borderRadius, elevation, iconSize, gap;
//   final EdgeInsetsGeometry? padding;
//   final TextStyle? textStyle;
// }

// /// الزر الموحد
// class AtharButton extends StatefulWidget {
//   const AtharButton({
//     super.key,
//     this.label,
//     this.icon,
//     this.child,
//     this.iconPosition = IconPosition.start,
//     this.variant = AtharButtonVariant.primary,
//     this.size = AtharButtonSize.medium,
//     this.customStyle,
//     this.onPressed,
//     this.onLongPress,
//     this.isLoading = false,
//     this.isDisabled = false,
//     this.isFullWidth = false,
//     this.loadingWidget,
//     this.tooltip,
//   }) : assert(label != null || child != null || icon != null);

//   final String? label;
//   final IconData? icon;
//   final Widget? child;
//   final IconPosition iconPosition;
//   final AtharButtonVariant variant;
//   final AtharButtonSize size;
//   final AtharButtonStyle? customStyle;
//   final VoidCallback? onPressed;
//   final VoidCallback? onLongPress;
//   final bool isLoading, isDisabled, isFullWidth;
//   final Widget? loadingWidget;
//   final String? tooltip;

//   // Factory constructors
//   factory AtharButton.primary({
//     Key? key,
//     String? label,
//     IconData? icon,
//     AtharButtonSize size = AtharButtonSize.medium,
//     VoidCallback? onPressed,
//     bool isLoading = false,
//     bool isDisabled = false,
//     bool isFullWidth = false,
//     String? tooltip,
//   }) => AtharButton(
//     key: key,
//     label: label,
//     icon: icon,
//     variant: AtharButtonVariant.primary,
//     size: size,
//     onPressed: onPressed,
//     isLoading: isLoading,
//     isDisabled: isDisabled,
//     isFullWidth: isFullWidth,
//     tooltip: tooltip,
//   );
//   factory AtharButton.secondary({
//     Key? key,
//     String? label,
//     IconData? icon,
//     AtharButtonSize size = AtharButtonSize.medium,
//     VoidCallback? onPressed,
//     bool isLoading = false,
//     bool isDisabled = false,
//     bool isFullWidth = false,
//     String? tooltip,
//   }) => AtharButton(
//     key: key,
//     label: label,
//     icon: icon,
//     variant: AtharButtonVariant.secondary,
//     size: size,
//     onPressed: onPressed,
//     isLoading: isLoading,
//     isDisabled: isDisabled,
//     isFullWidth: isFullWidth,
//     tooltip: tooltip,
//   );
//   factory AtharButton.outline({
//     Key? key,
//     String? label,
//     IconData? icon,
//     AtharButtonSize size = AtharButtonSize.medium,
//     VoidCallback? onPressed,
//     bool isLoading = false,
//     bool isDisabled = false,
//     bool isFullWidth = false,
//     String? tooltip,
//   }) => AtharButton(
//     key: key,
//     label: label,
//     icon: icon,
//     variant: AtharButtonVariant.outline,
//     size: size,
//     onPressed: onPressed,
//     isLoading: isLoading,
//     isDisabled: isDisabled,
//     isFullWidth: isFullWidth,
//     tooltip: tooltip,
//   );
//   factory AtharButton.ghost({
//     Key? key,
//     String? label,
//     IconData? icon,
//     AtharButtonSize size = AtharButtonSize.medium,
//     VoidCallback? onPressed,
//     bool isLoading = false,
//     bool isDisabled = false,
//     bool isFullWidth = false,
//     String? tooltip,
//   }) => AtharButton(
//     key: key,
//     label: label,
//     icon: icon,
//     variant: AtharButtonVariant.ghost,
//     size: size,
//     onPressed: onPressed,
//     isLoading: isLoading,
//     isDisabled: isDisabled,
//     isFullWidth: isFullWidth,
//     tooltip: tooltip,
//   );
//   factory AtharButton.danger({
//     Key? key,
//     String? label,
//     IconData? icon,
//     AtharButtonSize size = AtharButtonSize.medium,
//     VoidCallback? onPressed,
//     bool isLoading = false,
//     bool isDisabled = false,
//     bool isFullWidth = false,
//     String? tooltip,
//   }) => AtharButton(
//     key: key,
//     label: label,
//     icon: icon,
//     variant: AtharButtonVariant.danger,
//     size: size,
//     onPressed: onPressed,
//     isLoading: isLoading,
//     isDisabled: isDisabled,
//     isFullWidth: isFullWidth,
//     tooltip: tooltip,
//   );
//   factory AtharButton.success({
//     Key? key,
//     String? label,
//     IconData? icon,
//     AtharButtonSize size = AtharButtonSize.medium,
//     VoidCallback? onPressed,
//     bool isLoading = false,
//     bool isDisabled = false,
//     bool isFullWidth = false,
//     String? tooltip,
//   }) => AtharButton(
//     key: key,
//     label: label,
//     icon: icon,
//     variant: AtharButtonVariant.success,
//     size: size,
//     onPressed: onPressed,
//     isLoading: isLoading,
//     isDisabled: isDisabled,
//     isFullWidth: isFullWidth,
//     tooltip: tooltip,
//   );
//   factory AtharButton.icon({
//     Key? key,
//     required IconData icon,
//     AtharButtonVariant variant = AtharButtonVariant.ghost,
//     AtharButtonSize size = AtharButtonSize.medium,
//     VoidCallback? onPressed,
//     bool isDisabled = false,
//     String? tooltip,
//   }) => AtharButton(
//     key: key,
//     icon: icon,
//     variant: variant,
//     size: size,
//     onPressed: onPressed,
//     isDisabled: isDisabled,
//     tooltip: tooltip,
//   );

//   @override
//   State<AtharButton> createState() => _AtharButtonState();
// }

// class _AtharButtonState extends State<AtharButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: AtharAnimations.buttonDuration,
//       vsync: this,
//     );
//     _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
//       CurvedAnimation(parent: _controller, curve: AtharAnimations.buttonCurve),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   bool get _isEnabled =>
//       !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final style = _resolveStyle(colors);

//     Widget button = GestureDetector(
//       onTapDown: _isEnabled ? (_) => _controller.forward() : null,
//       onTapUp: _isEnabled ? (_) => _controller.reverse() : null,
//       onTapCancel: _isEnabled ? () => _controller.reverse() : null,
//       child: AnimatedBuilder(
//         animation: _scale,
//         builder: (_, child) =>
//             Transform.scale(scale: _scale.value, child: child),
//         child: _buildButton(colors, style),
//       ),
//     );

//     if (widget.tooltip != null) {
//       button = Tooltip(message: widget.tooltip!, child: button);
//     }
//     if (widget.isFullWidth) {
//       button = SizedBox(width: double.infinity, child: button);
//     }
//     return button;
//   }

//   Widget _buildButton(AtharColors colors, _Style s) {
//     return AnimatedContainer(
//       duration: AtharAnimations.fast,
//       height: s.height,
//       constraints: BoxConstraints(minWidth: s.minWidth),
//       decoration: BoxDecoration(
//         color: _isEnabled ? s.bgColor : colors.surfaceContainer,
//         borderRadius: BorderRadius.circular(s.radius),
//         border: s.borderColor != null
//             ? Border.all(
//                 color: _isEnabled ? s.borderColor! : colors.borderLight,
//                 width: s.borderWidth,
//               )
//             : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _isEnabled ? widget.onPressed : null,
//           onLongPress: _isEnabled ? widget.onLongPress : null,
//           borderRadius: BorderRadius.circular(s.radius),
//           splashColor: s.fgColor.withValues(alpha: 0.1),
//           child: Padding(padding: s.padding, child: _buildContent(colors, s)),
//         ),
//       ),
//     );
//   }

//   Widget _buildContent(AtharColors colors, _Style s) {
//     final fg = _isEnabled ? s.fgColor : colors.textDisabled;

//     if (widget.isLoading) {
//       return widget.loadingWidget ??
//           SizedBox(
//             width: s.iconSize,
//             height: s.iconSize,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation(fg),
//             ),
//           );
//     }
//     if (widget.child != null) return widget.child!;
//     if (widget.label == null && widget.icon != null) {
//       return Icon(widget.icon, size: s.iconSize, color: fg);
//     }
//     if (widget.icon == null && widget.label != null) {
//       return Text(widget.label!, style: s.textStyle.copyWith(color: fg));
//     }

//     final icon = Icon(widget.icon, size: s.iconSize, color: fg);
//     final text = Flexible(
//       child: Text(
//         widget.label!,
//         style: s.textStyle.copyWith(color: fg),
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//     final gap = SizedBox(width: s.gap);
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: widget.iconPosition == IconPosition.start
//           ? [icon, gap, text]
//           : [text, gap, icon],
//     );
//   }

//   _Style _resolveStyle(AtharColors c) {
//     final v = _variantStyle(c);
//     final z = _sizeStyle();
//     final custom = widget.customStyle;
//     return _Style(
//       bgColor: custom?.backgroundColor ?? v.bgColor,
//       fgColor: custom?.foregroundColor ?? v.fgColor,
//       borderColor: custom?.borderColor ?? v.borderColor,
//       borderWidth: custom?.borderWidth ?? v.borderWidth,
//       radius: custom?.borderRadius ?? z.radius,
//       padding: custom?.padding ?? z.padding,
//       textStyle: custom?.textStyle ?? z.textStyle,
//       iconSize: custom?.iconSize ?? z.iconSize,
//       gap: custom?.gap ?? z.gap,
//       height: z.height,
//       minWidth: z.minWidth,
//     );
//   }

//   _VStyle _variantStyle(AtharColors c) {
//     switch (widget.variant) {
//       case AtharButtonVariant.primary:
//         return _VStyle(c.primary, c.onPrimary, null, 0);
//       case AtharButtonVariant.secondary:
//         return _VStyle(c.secondary, c.onSecondary, null, 0);
//       case AtharButtonVariant.outline:
//         return _VStyle(Colors.transparent, c.primary, c.primary, 1.5);
//       case AtharButtonVariant.ghost:
//         return _VStyle(Colors.transparent, c.primary, null, 0);
//       case AtharButtonVariant.danger:
//         return _VStyle(c.error, c.onError, null, 0);
//       case AtharButtonVariant.success:
//         return _VStyle(c.success, c.onSuccess, null, 0);
//       case AtharButtonVariant.warning:
//         return _VStyle(c.warning, c.onWarning, null, 0);
//       case AtharButtonVariant.info:
//         return _VStyle(c.info, c.onInfo, null, 0);
//     }
//   }

//   _ZStyle _sizeStyle() {
//     switch (widget.size) {
//       case AtharButtonSize.small:
//         return _ZStyle(
//           36,
//           64,
//           AtharRadii.sm,
//           const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           AtharTypography.buttonSmall,
//           16,
//           6,
//         );
//       case AtharButtonSize.medium:
//         return _ZStyle(
//           44,
//           80,
//           AtharRadii.sm,
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           AtharTypography.button,
//           20,
//           8,
//         );
//       case AtharButtonSize.large:
//         return _ZStyle(
//           52,
//           96,
//           AtharRadii.md,
//           const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//           AtharTypography.button,
//           22,
//           10,
//         );
//       case AtharButtonSize.xlarge:
//         return _ZStyle(
//           60,
//           120,
//           AtharRadii.md,
//           const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//           AtharTypography.buttonLarge,
//           24,
//           12,
//         );
//     }
//   }
// }

// class _VStyle {
//   final Color bgColor, fgColor;
//   final Color? borderColor;
//   final double borderWidth;
//   const _VStyle(this.bgColor, this.fgColor, this.borderColor, this.borderWidth);
// }

// class _ZStyle {
//   final double height, minWidth, radius, iconSize, gap;
//   final EdgeInsets padding;
//   final TextStyle textStyle;
//   const _ZStyle(
//     this.height,
//     this.minWidth,
//     this.radius,
//     this.padding,
//     this.textStyle,
//     this.iconSize,
//     this.gap,
//   );
// }

// class _Style {
//   final Color bgColor, fgColor;
//   final Color? borderColor;
//   final double borderWidth, radius, iconSize, gap, height, minWidth;
//   final EdgeInsetsGeometry padding;
//   final TextStyle textStyle;
//   const _Style({
//     required this.bgColor,
//     required this.fgColor,
//     this.borderColor,
//     required this.borderWidth,
//     required this.radius,
//     required this.padding,
//     required this.textStyle,
//     required this.iconSize,
//     required this.gap,
//     required this.height,
//     required this.minWidth,
//   });
// }
//-----------------------------------------------------------------------
