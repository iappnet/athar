import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Enums
// ═══════════════════════════════════════════════════════════════════════════

enum AtharButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  danger,
  success,
  warning,
}

enum AtharButtonSize { small, medium, large, xlarge }

// ═══════════════════════════════════════════════════════════════════════════
// AtharButton
// ═══════════════════════════════════════════════════════════════════════════

class AtharButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AtharButtonVariant variant;
  final AtharButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isExpanded;
  final double? borderRadius;
  final Color? customColor;
  final double? customHeight;
  final bool enableHapticFeedback;

  const AtharButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AtharButtonVariant.primary,
    this.size = AtharButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.borderRadius,
    this.customColor,
    this.customHeight,
    this.enableHapticFeedback = true,
  });

  factory AtharButton.primary({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    AtharButtonSize size = AtharButtonSize.medium,
  }) {
    return AtharButton(
      text: text,
      onPressed: onPressed,
      variant: AtharButtonVariant.primary,
      size: size,
      leadingIcon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  factory AtharButton.secondary({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    AtharButtonSize size = AtharButtonSize.medium,
  }) {
    return AtharButton(
      text: text,
      onPressed: onPressed,
      variant: AtharButtonVariant.secondary,
      size: size,
      leadingIcon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  factory AtharButton.outlined({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    AtharButtonSize size = AtharButtonSize.medium,
    Color? color,
  }) {
    return AtharButton(
      text: text,
      onPressed: onPressed,
      variant: AtharButtonVariant.outlined,
      size: size,
      leadingIcon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
      customColor: color,
    );
  }

  factory AtharButton.text({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    AtharButtonSize size = AtharButtonSize.medium,
    Color? color,
  }) {
    return AtharButton(
      text: text,
      onPressed: onPressed,
      variant: AtharButtonVariant.text,
      size: size,
      leadingIcon: icon,
      customColor: color,
    );
  }

  factory AtharButton.danger({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    AtharButtonSize size = AtharButtonSize.medium,
  }) {
    return AtharButton(
      text: text,
      onPressed: onPressed,
      variant: AtharButtonVariant.danger,
      size: size,
      leadingIcon: icon ?? Icons.delete_outline,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  factory AtharButton.success({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    AtharButtonSize size = AtharButtonSize.medium,
  }) {
    return AtharButton(
      text: text,
      onPressed: onPressed,
      variant: AtharButtonVariant.success,
      size: size,
      leadingIcon: icon ?? Icons.check,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  factory AtharButton.icon({
    required IconData icon,
    VoidCallback? onPressed,
    AtharButtonVariant variant = AtharButtonVariant.secondary,
    AtharButtonSize size = AtharButtonSize.medium,
    bool isLoading = false,
  }) {
    return AtharButton(
      text: '',
      onPressed: onPressed,
      variant: variant,
      size: size,
      leadingIcon: icon,
      isLoading: isLoading,
    );
  }

  @override
  State<AtharButton> createState() => _AtharButtonState();
}

class _AtharButtonState extends State<AtharButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  double get _height {
    if (widget.customHeight != null) return widget.customHeight!;
    switch (widget.size) {
      case AtharButtonSize.small:
        return 36.h;
      case AtharButtonSize.medium:
        return 44.h;
      case AtharButtonSize.large:
        return 52.h;
      case AtharButtonSize.xlarge:
        return 56.h;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case AtharButtonSize.small:
        return 12.sp;
      case AtharButtonSize.medium:
        return 14.sp;
      case AtharButtonSize.large:
        return 16.sp;
      case AtharButtonSize.xlarge:
        return 18.sp;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AtharButtonSize.small:
        return 16.sp;
      case AtharButtonSize.medium:
        return 18.sp;
      case AtharButtonSize.large:
        return 20.sp;
      case AtharButtonSize.xlarge:
        return 22.sp;
    }
  }

  EdgeInsets get _padding {
    final bool isIconOnly = widget.text.isEmpty && widget.leadingIcon != null;
    if (isIconOnly) return EdgeInsets.zero;
    switch (widget.size) {
      case AtharButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 12.w);
      case AtharButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 16.w);
      case AtharButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 20.w);
      case AtharButtonSize.xlarge:
        return EdgeInsets.symmetric(horizontal: 24.w);
    }
  }

  double get _borderRadius => widget.borderRadius ?? 12.r;

  // Semantic color constants (not in standard ColorScheme)
  static const _dangerColor = Color(0xFFE74C3C);
  static const _successColor = Color(0xFF00B894);
  static const _warningColor = Color(0xFFFDCB6E);

  Color get _backgroundColor {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.customColor != null &&
        widget.variant != AtharButtonVariant.outlined &&
        widget.variant != AtharButtonVariant.text &&
        widget.variant != AtharButtonVariant.secondary) {
      return widget.customColor!;
    }

    switch (widget.variant) {
      case AtharButtonVariant.primary:
        return colorScheme.primary;
      case AtharButtonVariant.secondary:
        return colorScheme.primary.withValues(alpha: 0.1);
      case AtharButtonVariant.outlined:
      case AtharButtonVariant.text:
        return Colors.transparent;
      case AtharButtonVariant.danger:
        return _dangerColor;
      case AtharButtonVariant.success:
        return _successColor;
      case AtharButtonVariant.warning:
        return _warningColor;
    }
  }

  Color get _foregroundColor {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.customColor != null &&
        (widget.variant == AtharButtonVariant.outlined ||
            widget.variant == AtharButtonVariant.text ||
            widget.variant == AtharButtonVariant.secondary)) {
      return widget.customColor!;
    }

    switch (widget.variant) {
      case AtharButtonVariant.primary:
      case AtharButtonVariant.danger:
      case AtharButtonVariant.success:
        return colorScheme.onPrimary;
      case AtharButtonVariant.secondary:
      case AtharButtonVariant.outlined:
      case AtharButtonVariant.text:
        return widget.customColor ?? colorScheme.primary;
      case AtharButtonVariant.warning:
        return colorScheme.onSurface;
    }
  }

  Color? get _borderColor {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.variant == AtharButtonVariant.outlined) {
      return widget.customColor ?? colorScheme.primary;
    }
    return null;
  }

  List<BoxShadow>? get _boxShadow {
    if (!_isEnabled ||
        widget.variant == AtharButtonVariant.text ||
        widget.variant == AtharButtonVariant.outlined ||
        widget.variant == AtharButtonVariant.secondary) {
      return null;
    }

    final colorScheme = Theme.of(context).colorScheme;

    final Color shadowColor;
    switch (widget.variant) {
      case AtharButtonVariant.primary:
        shadowColor = colorScheme.primary;
        break;
      case AtharButtonVariant.danger:
        shadowColor = _dangerColor;
        break;
      case AtharButtonVariant.success:
        shadowColor = _successColor;
        break;
      case AtharButtonVariant.warning:
        shadowColor = _warningColor;
        break;
      default:
        return null;
    }

    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: _isPressed ? 0.2 : 0.3),
        blurRadius: _isPressed ? 4 : 8,
        offset: Offset(0, _isPressed ? 2 : 4),
      ),
    ];
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTap() {
    if (!_isEnabled) return;
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isIconOnly = widget.text.isEmpty && widget.leadingIcon != null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: _height,
          width: isIconOnly
              ? _height
              : (widget.isExpanded ? double.infinity : null),
          padding: _padding,
          decoration: BoxDecoration(
            color: _isEnabled
                ? _backgroundColor
                : _backgroundColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(_borderRadius),
            border: _borderColor != null
                ? Border.all(
                    color: _isEnabled
                        ? _borderColor!
                        : _borderColor!.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
            boxShadow: _boxShadow,
          ),
          child: Center(child: _buildContent(isIconOnly)),
        ),
      ),
    );
  }

  Widget _buildContent(bool isIconOnly) {
    final Color foreground = _isEnabled
        ? _foregroundColor
        : _foregroundColor.withValues(alpha: 0.5);

    if (widget.isLoading) {
      return SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foreground),
        ),
      );
    }

    if (isIconOnly) {
      return Icon(widget.leadingIcon, color: foreground, size: _iconSize);
    }

    return Row(
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, color: foreground, size: _iconSize),
          AtharGap.hSm,
        ],
        Flexible(
          child: Text(
            widget.text,
            style: TextStyle(
              color: foreground,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          AtharGap.hSm,
          Icon(widget.trailingIcon, color: foreground, size: _iconSize),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AtharIconButton
// ═══════════════════════════════════════════════════════════════════════════

class AtharIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final String? tooltip;
  final bool hasBorder;

  const AtharIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.tooltip,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double buttonSize = size ?? 40.w;
    final bool isEnabled = onPressed != null;

    Widget button = GestureDetector(
      onTap: () {
        if (isEnabled) {
          HapticFeedback.lightImpact();
          onPressed?.call();
        }
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: isEnabled
              ? (backgroundColor ?? Colors.transparent)
              : (backgroundColor ?? Colors.transparent).withValues(alpha: 0.5),
          borderRadius: AtharRadii.card,
          border: hasBorder
              ? Border.all(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            color: isEnabled
                ? (iconColor ?? colorScheme.onSurface)
                : (iconColor ?? colorScheme.onSurface).withValues(alpha: 0.5),
            size: buttonSize * 0.5,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AtharFAB
// ═══════════════════════════════════════════════════════════════════════════

class AtharFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final bool isExtended;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? heroTag;

  const AtharFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.isExtended = false,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color bgColor = backgroundColor ?? colorScheme.primary;
    final Color fgColor = foregroundColor ?? colorScheme.onPrimary;

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        heroTag: heroTag,
        onPressed: () {
          if (onPressed != null) {
            HapticFeedback.mediumImpact();
            onPressed!();
          }
        },
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusLg),
        icon: Icon(icon),
        label: Text(
          label!,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
      );
    }

    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: () {
        if (onPressed != null) {
          HapticFeedback.mediumImpact();
          onPressed!();
        }
      },
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusLg),
      child: Icon(icon),
    );
  }
}
//-----------------------------------------------------------------------
// // app_button.dart
// // lib/core/design_system/atoms/buttons/athar_button.dart
// // ═══════════════════════════════════════════════════════════════════════════
// // مكون الزر الموحد لتطبيق أثر - AtharButton
// // الإصدار: 1.0.0
// // ═══════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../themes/app_colors.dart';

// // ═══════════════════════════════════════════════════════════════════════════
// // التعدادات (Enums)
// // ═══════════════════════════════════════════════════════════════════════════

// /// أنماط الزر المتاحة
// enum AtharButtonVariant {
//   /// الزر الأساسي - خلفية ملونة (للإجراءات الرئيسية)
//   primary,

//   /// الزر الثانوي - خلفية فاتحة (للإجراءات البديلة)
//   secondary,

//   /// زر بإطار فقط (للإجراءات الأقل أهمية)
//   outlined,

//   /// زر نصي بدون خلفية (للروابط والإجراءات الخفيفة)
//   text,

//   /// زر الخطر - أحمر (للحذف والإجراءات الحساسة)
//   danger,

//   /// زر النجاح - أخضر (للتأكيدات الإيجابية)
//   success,

//   /// زر التحذير - برتقالي (للتنبيهات)
//   warning,
// }

// /// أحجام الزر المتاحة
// enum AtharButtonSize {
//   /// صغير: ارتفاع 36
//   small,

//   /// متوسط: ارتفاع 44 (الافتراضي)
//   medium,

//   /// كبير: ارتفاع 52
//   large,

//   /// ضخم: ارتفاع 56 (للأزرار البارزة)
//   xlarge,
// }

// // ═══════════════════════════════════════════════════════════════════════════
// // المكون الرئيسي - AtharButton
// // ═══════════════════════════════════════════════════════════════════════════

// class AtharButton extends StatefulWidget {
//   /// النص المعروض على الزر
//   final String text;

//   /// الدالة المنفذة عند الضغط (null = زر معطل)
//   final VoidCallback? onPressed;

//   /// نمط الزر
//   final AtharButtonVariant variant;

//   /// حجم الزر
//   final AtharButtonSize size;

//   /// أيقونة قبل النص
//   final IconData? leadingIcon;

//   /// أيقونة بعد النص
//   final IconData? trailingIcon;

//   /// هل الزر في حالة تحميل؟
//   final bool isLoading;

//   /// هل يأخذ العرض الكامل للحاوية؟
//   final bool isExpanded;

//   /// نصف قطر الحواف
//   final double? borderRadius;

//   /// لون مخصص
//   final Color? customColor;

//   /// ارتفاع مخصص
//   final double? customHeight;

//   /// هل يُصدر اهتزاز عند الضغط؟
//   final bool enableHapticFeedback;

//   const AtharButton({
//     super.key,
//     required this.text,
//     this.onPressed,
//     this.variant = AtharButtonVariant.primary,
//     this.size = AtharButtonSize.medium,
//     this.leadingIcon,
//     this.trailingIcon,
//     this.isLoading = false,
//     this.isExpanded = false,
//     this.borderRadius,
//     this.customColor,
//     this.customHeight,
//     this.enableHapticFeedback = true,
//   });

//   // ═══════════════════════════════════════════════════════════════════════
//   // المُنشئات السريعة
//   // ═══════════════════════════════════════════════════════════════════════

//   /// زر أساسي
//   factory AtharButton.primary({
//     required String text,
//     VoidCallback? onPressed,
//     IconData? icon,
//     bool isLoading = false,
//     bool isExpanded = false,
//     AtharButtonSize size = AtharButtonSize.medium,
//   }) {
//     return AtharButton(
//       text: text,
//       onPressed: onPressed,
//       variant: AtharButtonVariant.primary,
//       size: size,
//       leadingIcon: icon,
//       isLoading: isLoading,
//       isExpanded: isExpanded,
//     );
//   }

//   /// زر ثانوي
//   factory AtharButton.secondary({
//     required String text,
//     VoidCallback? onPressed,
//     IconData? icon,
//     bool isLoading = false,
//     bool isExpanded = false,
//     AtharButtonSize size = AtharButtonSize.medium,
//   }) {
//     return AtharButton(
//       text: text,
//       onPressed: onPressed,
//       variant: AtharButtonVariant.secondary,
//       size: size,
//       leadingIcon: icon,
//       isLoading: isLoading,
//       isExpanded: isExpanded,
//     );
//   }

//   /// زر بإطار
//   factory AtharButton.outlined({
//     required String text,
//     VoidCallback? onPressed,
//     IconData? icon,
//     bool isLoading = false,
//     bool isExpanded = false,
//     AtharButtonSize size = AtharButtonSize.medium,
//     Color? color,
//   }) {
//     return AtharButton(
//       text: text,
//       onPressed: onPressed,
//       variant: AtharButtonVariant.outlined,
//       size: size,
//       leadingIcon: icon,
//       isLoading: isLoading,
//       isExpanded: isExpanded,
//       customColor: color,
//     );
//   }

//   /// زر نصي
//   factory AtharButton.text({
//     required String text,
//     VoidCallback? onPressed,
//     IconData? icon,
//     AtharButtonSize size = AtharButtonSize.medium,
//     Color? color,
//   }) {
//     return AtharButton(
//       text: text,
//       onPressed: onPressed,
//       variant: AtharButtonVariant.text,
//       size: size,
//       leadingIcon: icon,
//       customColor: color,
//     );
//   }

//   /// زر خطر (للحذف)
//   factory AtharButton.danger({
//     required String text,
//     VoidCallback? onPressed,
//     IconData? icon,
//     bool isLoading = false,
//     bool isExpanded = false,
//     AtharButtonSize size = AtharButtonSize.medium,
//   }) {
//     return AtharButton(
//       text: text,
//       onPressed: onPressed,
//       variant: AtharButtonVariant.danger,
//       size: size,
//       leadingIcon: icon ?? Icons.delete_outline,
//       isLoading: isLoading,
//       isExpanded: isExpanded,
//     );
//   }

//   /// زر نجاح (للتأكيد)
//   factory AtharButton.success({
//     required String text,
//     VoidCallback? onPressed,
//     IconData? icon,
//     bool isLoading = false,
//     bool isExpanded = false,
//     AtharButtonSize size = AtharButtonSize.medium,
//   }) {
//     return AtharButton(
//       text: text,
//       onPressed: onPressed,
//       variant: AtharButtonVariant.success,
//       size: size,
//       leadingIcon: icon ?? Icons.check,
//       isLoading: isLoading,
//       isExpanded: isExpanded,
//     );
//   }

//   /// زر أيقونة فقط
//   factory AtharButton.icon({
//     required IconData icon,
//     VoidCallback? onPressed,
//     AtharButtonVariant variant = AtharButtonVariant.secondary,
//     AtharButtonSize size = AtharButtonSize.medium,
//     bool isLoading = false,
//   }) {
//     return AtharButton(
//       text: '',
//       onPressed: onPressed,
//       variant: variant,
//       size: size,
//       leadingIcon: icon,
//       isLoading: isLoading,
//     );
//   }

//   @override
//   State<AtharButton> createState() => _AtharButtonState();
// }

// class _AtharButtonState extends State<AtharButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 100),
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   // ═══════════════════════════════════════════════════════════════════════
//   // الخصائص المحسوبة
//   // ═══════════════════════════════════════════════════════════════════════

//   bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

//   double get _height {
//     if (widget.customHeight != null) return widget.customHeight!;
//     switch (widget.size) {
//       case AtharButtonSize.small:
//         return 36.h;
//       case AtharButtonSize.medium:
//         return 44.h;
//       case AtharButtonSize.large:
//         return 52.h;
//       case AtharButtonSize.xlarge:
//         return 56.h;
//     }
//   }

//   double get _fontSize {
//     switch (widget.size) {
//       case AtharButtonSize.small:
//         return 12.sp;
//       case AtharButtonSize.medium:
//         return 14.sp;
//       case AtharButtonSize.large:
//         return 16.sp;
//       case AtharButtonSize.xlarge:
//         return 18.sp;
//     }
//   }

//   double get _iconSize {
//     switch (widget.size) {
//       case AtharButtonSize.small:
//         return 16.sp;
//       case AtharButtonSize.medium:
//         return 18.sp;
//       case AtharButtonSize.large:
//         return 20.sp;
//       case AtharButtonSize.xlarge:
//         return 22.sp;
//     }
//   }

//   EdgeInsets get _padding {
//     final bool isIconOnly = widget.text.isEmpty && widget.leadingIcon != null;
//     if (isIconOnly) {
//       return EdgeInsets.zero;
//     }
//     switch (widget.size) {
//       case AtharButtonSize.small:
//         return EdgeInsets.symmetric(horizontal: 12.w);
//       case AtharButtonSize.medium:
//         return EdgeInsets.symmetric(horizontal: 16.w);
//       case AtharButtonSize.large:
//         return EdgeInsets.symmetric(horizontal: 20.w);
//       case AtharButtonSize.xlarge:
//         return EdgeInsets.symmetric(horizontal: 24.w);
//     }
//   }

//   double get _borderRadius => widget.borderRadius ?? 12.r;

//   Color get _backgroundColor {
//     if (widget.customColor != null &&
//         widget.variant != AtharButtonVariant.outlined &&
//         widget.variant != AtharButtonVariant.text &&
//         widget.variant != AtharButtonVariant.secondary) {
//       return widget.customColor!;
//     }

//     switch (widget.variant) {
//       case AtharButtonVariant.primary:
//         return AppColors.primary;
//       case AtharButtonVariant.secondary:
//         return AppColors.primary.withValues(alpha: 0.1);
//       case AtharButtonVariant.outlined:
//       case AtharButtonVariant.text:
//         return Colors.transparent;
//       case AtharButtonVariant.danger:
//         return AppColors.urgent;
//       case AtharButtonVariant.success:
//         return AppColors.success;
//       case AtharButtonVariant.warning:
//         return AppColors.warning;
//     }
//   }

//   Color get _foregroundColor {
//     if (widget.customColor != null &&
//         (widget.variant == AtharButtonVariant.outlined ||
//             widget.variant == AtharButtonVariant.text ||
//             widget.variant == AtharButtonVariant.secondary)) {
//       return widget.customColor!;
//     }

//     switch (widget.variant) {
//       case AtharButtonVariant.primary:
//       case AtharButtonVariant.danger:
//       case AtharButtonVariant.success:
//         return Colors.white;
//       case AtharButtonVariant.secondary:
//       case AtharButtonVariant.outlined:
//       case AtharButtonVariant.text:
//         return widget.customColor ?? AppColors.primary;
//       case AtharButtonVariant.warning:
//         return AppColors.textPrimary;
//     }
//   }

//   Color? get _borderColor {
//     if (widget.variant == AtharButtonVariant.outlined) {
//       return widget.customColor ?? AppColors.primary;
//     }
//     return null;
//   }

//   List<BoxShadow>? get _boxShadow {
//     if (!_isEnabled ||
//         widget.variant == AtharButtonVariant.text ||
//         widget.variant == AtharButtonVariant.outlined ||
//         widget.variant == AtharButtonVariant.secondary) {
//       return null;
//     }

//     final Color shadowColor;
//     switch (widget.variant) {
//       case AtharButtonVariant.primary:
//         shadowColor = AppColors.primary;
//         break;
//       case AtharButtonVariant.danger:
//         shadowColor = AppColors.urgent;
//         break;
//       case AtharButtonVariant.success:
//         shadowColor = AppColors.success;
//         break;
//       case AtharButtonVariant.warning:
//         shadowColor = AppColors.warning;
//         break;
//       default:
//         return null;
//     }

//     return [
//       BoxShadow(
//         color: shadowColor.withValues(alpha: _isPressed ? 0.2 : 0.3),
//         blurRadius: _isPressed ? 4 : 8,
//         offset: Offset(0, _isPressed ? 2 : 4),
//       ),
//     ];
//   }

//   // ═══════════════════════════════════════════════════════════════════════
//   // معالجات الأحداث
//   // ═══════════════════════════════════════════════════════════════════════

//   void _onTapDown(TapDownDetails details) {
//     if (!_isEnabled) return;
//     setState(() => _isPressed = true);
//     _animationController.forward();
//   }

//   void _onTapUp(TapUpDetails details) {
//     if (!_isEnabled) return;
//     setState(() => _isPressed = false);
//     _animationController.reverse();
//   }

//   void _onTapCancel() {
//     if (!_isEnabled) return;
//     setState(() => _isPressed = false);
//     _animationController.reverse();
//   }

//   void _onTap() {
//     if (!_isEnabled) return;
//     if (widget.enableHapticFeedback) {
//       HapticFeedback.lightImpact();
//     }
//     widget.onPressed?.call();
//   }

//   // ═══════════════════════════════════════════════════════════════════════
//   // البناء
//   // ═══════════════════════════════════════════════════════════════════════

//   @override
//   Widget build(BuildContext context) {
//     final bool isIconOnly = widget.text.isEmpty && widget.leadingIcon != null;

//     return AnimatedBuilder(
//       animation: _scaleAnimation,
//       builder: (context, child) {
//         return Transform.scale(scale: _scaleAnimation.value, child: child);
//       },
//       child: GestureDetector(
//         onTapDown: _onTapDown,
//         onTapUp: _onTapUp,
//         onTapCancel: _onTapCancel,
//         onTap: _onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeOut,
//           height: _height,
//           width: isIconOnly
//               ? _height
//               : (widget.isExpanded ? double.infinity : null),
//           padding: _padding,
//           decoration: BoxDecoration(
//             color: _isEnabled
//                 ? _backgroundColor
//                 : _backgroundColor.withValues(alpha: 0.5),
//             borderRadius: BorderRadius.circular(_borderRadius),
//             border: _borderColor != null
//                 ? Border.all(
//                     color: _isEnabled
//                         ? _borderColor!
//                         : _borderColor!.withValues(alpha: 0.5),
//                     width: 1.5,
//                   )
//                 : null,
//             boxShadow: _boxShadow,
//           ),
//           child: Center(child: _buildContent(isIconOnly)),
//         ),
//       ),
//     );
//   }

//   Widget _buildContent(bool isIconOnly) {
//     final Color foreground = _isEnabled
//         ? _foregroundColor
//         : _foregroundColor.withValues(alpha: 0.5);

//     // حالة التحميل
//     if (widget.isLoading) {
//       return SizedBox(
//         width: _iconSize,
//         height: _iconSize,
//         child: CircularProgressIndicator(
//           strokeWidth: 2,
//           valueColor: AlwaysStoppedAnimation<Color>(foreground),
//         ),
//       );
//     }

//     // زر أيقونة فقط
//     if (isIconOnly) {
//       return Icon(widget.leadingIcon, color: foreground, size: _iconSize);
//     }

//     // زر عادي
//     return Row(
//       mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         if (widget.leadingIcon != null) ...[
//           Icon(widget.leadingIcon, color: foreground, size: _iconSize),
//           SizedBox(width: 8.w),
//         ],
//         Flexible(
//           child: Text(
//             widget.text,
//             style: TextStyle(
//               color: foreground,
//               fontSize: _fontSize,
//               fontWeight: FontWeight.w600,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         if (widget.trailingIcon != null) ...[
//           SizedBox(width: 8.w),
//           Icon(widget.trailingIcon, color: foreground, size: _iconSize),
//         ],
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════
// // AtharIconButton - زر أيقونة مستقل
// // ═══════════════════════════════════════════════════════════════════════════

// class AtharIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onPressed;
//   final Color? iconColor;
//   final Color? backgroundColor;
//   final double? size;
//   final String? tooltip;
//   final bool hasBorder;

//   const AtharIconButton({
//     super.key,
//     required this.icon,
//     this.onPressed,
//     this.iconColor,
//     this.backgroundColor,
//     this.size,
//     this.tooltip,
//     this.hasBorder = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final double buttonSize = size ?? 40.w;
//     final bool isEnabled = onPressed != null;

//     Widget button = GestureDetector(
//       onTap: () {
//         if (isEnabled) {
//           HapticFeedback.lightImpact();
//           onPressed?.call();
//         }
//       },
//       child: Container(
//         width: buttonSize,
//         height: buttonSize,
//         decoration: BoxDecoration(
//           color: isEnabled
//               ? (backgroundColor ?? Colors.transparent)
//               : (backgroundColor ?? Colors.transparent).withValues(alpha: 0.5),
//           borderRadius: BorderRadius.circular(12.r),
//           border: hasBorder
//               ? Border.all(
//                   color: AppColors.textSecondary.withValues(alpha: 0.2),
//                   width: 1,
//                 )
//               : null,
//         ),
//         child: Center(
//           child: Icon(
//             icon,
//             color: isEnabled
//                 ? (iconColor ?? AppColors.textPrimary)
//                 : (iconColor ?? AppColors.textPrimary).withValues(alpha: 0.5),
//             size: buttonSize * 0.5,
//           ),
//         ),
//       ),
//     );

//     if (tooltip != null) {
//       return Tooltip(message: tooltip!, child: button);
//     }
//     return button;
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════
// // AtharFAB - زر عائم موحد
// // ═══════════════════════════════════════════════════════════════════════════

// class AtharFAB extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onPressed;
//   final String? label;
//   final bool isExtended;
//   final Color? backgroundColor;
//   final Color? foregroundColor;
//   final String? heroTag;

//   const AtharFAB({
//     super.key,
//     required this.icon,
//     this.onPressed,
//     this.label,
//     this.isExtended = false,
//     this.backgroundColor,
//     this.foregroundColor,
//     this.heroTag,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final Color bgColor = backgroundColor ?? AppColors.primary;
//     final Color fgColor = foregroundColor ?? Colors.white;

//     if (isExtended && label != null) {
//       return FloatingActionButton.extended(
//         heroTag: heroTag,
//         onPressed: () {
//           if (onPressed != null) {
//             HapticFeedback.mediumImpact();
//             onPressed!();
//           }
//         },
//         backgroundColor: bgColor,
//         foregroundColor: fgColor,
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         icon: Icon(icon),
//         label: Text(
//           label!,
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
//         ),
//       );
//     }

//     return FloatingActionButton(
//       heroTag: heroTag,
//       onPressed: () {
//         if (onPressed != null) {
//           HapticFeedback.mediumImpact();
//           onPressed!();
//         }
//       },
//       backgroundColor: bgColor,
//       foregroundColor: fgColor,
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//       child: Icon(icon),
//     );
//   }
// }
//-----------------------------------------------------------------------
