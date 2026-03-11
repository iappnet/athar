import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import '../tokens.dart';

/// ATHAR TEXT FIELD

enum AtharTextFieldVariant { outlined, filled, underlined, borderless }

enum AtharTextFieldSize { small, medium, large }

class AtharTextFieldStyle {
  const AtharTextFieldStyle({
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.borderWidth,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
  });

  final Color? backgroundColor,
      borderColor,
      focusedBorderColor,
      errorBorderColor;
  final double? borderRadius, borderWidth;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle, hintStyle, labelStyle;
}

class AtharTextField extends StatefulWidget {
  const AtharTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.variant = AtharTextFieldVariant.outlined,
    this.size = AtharTextFieldSize.medium,
    this.customStyle,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.showCursor = true,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.expands = false,
    this.initialValue,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label, hint, helperText, errorText, initialValue;
  final IconData? prefixIcon, suffixIcon;
  final Widget? prefix, suffix;
  final AtharTextFieldVariant variant;
  final AtharTextFieldSize size;
  final AtharTextFieldStyle? customStyle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText, autocorrect, enableSuggestions;
  final int? maxLines, minLines, maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged, onSubmitted;
  final VoidCallback? onTap, onEditingComplete;
  final bool enabled, readOnly, autofocus, showCursor, expands;
  final TextAlign textAlign;
  final TextDirection? textDirection;

  factory AtharTextField.email({
    Key? key,
    required BuildContext context,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    final l10n = AppLocalizations.of(context);
    return AtharTextField(
      key: key,
      controller: controller,
      label: label ?? l10n.textFieldEmailLabel,
      hint: hint ?? 'example@email.com',
      errorText: errorText,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      validator: validator,
    );
  }

  factory AtharTextField.password({
    Key? key,
    required BuildContext context,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    bool obscureText = true,
  }) {
    final l10n = AppLocalizations.of(context);
    return AtharTextField(
      key: key,
      controller: controller,
      label: label ?? l10n.textFieldPasswordLabel,
      hint: hint ?? '••••••••',
      errorText: errorText,
      prefixIcon: Icons.lock_outlined,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
    );
  }

  factory AtharTextField.phone({
    Key? key,
    required BuildContext context,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    final l10n = AppLocalizations.of(context);
    return AtharTextField(
      key: key,
      controller: controller,
      label: label ?? l10n.textFieldPhoneLabel,
      hint: hint ?? '+966 5X XXX XXXX',
      errorText: errorText,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      onChanged: onChanged,
      validator: validator,
    );
  }

  factory AtharTextField.search({
    Key? key,
    required BuildContext context,
    TextEditingController? controller,
    String? hint,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) {
    final l10n = AppLocalizations.of(context);
    return AtharTextField(
      key: key,
      controller: controller,
      hint: hint ?? l10n.textFieldSearchHint,
      prefixIcon: Icons.search,
      variant: AtharTextFieldVariant.filled,
      onChanged: onChanged,
      onTap: onTap,
    );
  }

  factory AtharTextField.multiline({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    int maxLines = 5,
    int? minLines,
    int? maxLength,
    ValueChanged<String>? onChanged,
  }) => AtharTextField(
    key: key,
    controller: controller,
    label: label,
    hint: hint,
    maxLines: maxLines,
    minLines: minLines ?? 3,
    maxLength: maxLength,
    keyboardType: TextInputType.multiline,
    textInputAction: TextInputAction.newline,
    onChanged: onChanged,
  );

  factory AtharTextField.borderless({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? hint,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    int? maxLines,
    int? minLines,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    bool autofocus = false,
    String? initialValue,
  }) => AtharTextField(
    key: key,
    controller: controller,
    focusNode: focusNode,
    hint: hint,
    variant: AtharTextFieldVariant.borderless,
    maxLines: maxLines,
    minLines: minLines,
    keyboardType: keyboardType,
    onChanged: onChanged,
    autofocus: autofocus,
    initialValue: initialValue,
    customStyle: AtharTextFieldStyle(
      textStyle: textStyle,
      hintStyle: hintStyle,
      contentPadding: EdgeInsets.zero,
    ),
  );

  @override
  State<AtharTextField> createState() => _AtharTextFieldState();
}

class _AtharTextFieldState extends State<AtharTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = _resolveStyle(colorScheme);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final isBorderless = widget.variant == AtharTextFieldVariant.borderless;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && !isBorderless) ...[
          Text(
            widget.label!,
            style: style.labelStyle.copyWith(
              color: hasError
                  ? colorScheme.error
                  : (_isFocused
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant),
            ),
          ),
          AtharGap.xs,
        ],
        if (isBorderless)
          _buildTextFormField(colorScheme, style, hasError, isBorderless)
        else
          AnimatedContainer(
            duration: AtharAnimations.fast,
            decoration: _buildDecoration(colorScheme, style, hasError),
            child: _buildTextFormField(
              colorScheme,
              style,
              hasError,
              isBorderless,
            ),
          ),
        if (widget.helperText != null || hasError) ...[
          AtharGap.xxs,
          Text(
            hasError ? widget.errorText! : widget.helperText!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: hasError ? colorScheme.error : colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextFormField(
    ColorScheme colorScheme,
    _TFStyle style,
    bool hasError,
    bool isBorderless,
  ) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      initialValue: widget.controller == null ? widget.initialValue : null,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.obscureText ? _obscureText : false,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      showCursor: widget.showCursor,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      expands: widget.expands,
      style: style.textStyle.copyWith(
        color: widget.enabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: style.hintStyle.copyWith(color: colorScheme.outline),
        contentPadding: style.contentPadding,
        isDense: true,
        filled: widget.variant == AtharTextFieldVariant.filled,
        fillColor: widget.variant == AtharTextFieldVariant.filled
            ? (widget.enabled
                  ? colorScheme.surfaceContainerLow
                  : colorScheme.surfaceContainer)
            : Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                size: style.iconSize,
                color: hasError
                    ? colorScheme.error
                    : (_isFocused ? colorScheme.primary : colorScheme.outline),
              )
            : widget.prefix,
        suffixIcon: _buildSuffixIcon(colorScheme, style, hasError),
        counterText: '',
      ),
    );
  }

  BoxDecoration _buildDecoration(
    ColorScheme colorScheme,
    _TFStyle style,
    bool hasError,
  ) {
    Color borderColor = hasError
        ? colorScheme.error
        : (_isFocused
              ? colorScheme.primary
              : (widget.customStyle?.borderColor ?? colorScheme.outline));
    if (!widget.enabled) borderColor = colorScheme.outlineVariant;

    switch (widget.variant) {
      case AtharTextFieldVariant.outlined:
        return BoxDecoration(
          color: widget.enabled
              ? colorScheme.surface
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(style.borderRadius),
          border: Border.all(
            color: borderColor,
            width: _isFocused ? 2 : style.borderWidth,
          ),
        );
      case AtharTextFieldVariant.filled:
        return BoxDecoration(
          color: widget.enabled
              ? colorScheme.surfaceContainerLow
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(style.borderRadius),
          border: hasError
              ? Border.all(color: colorScheme.error, width: style.borderWidth)
              : null,
        );
      case AtharTextFieldVariant.underlined:
        return BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: borderColor,
              width: _isFocused ? 2 : style.borderWidth,
            ),
          ),
        );
      case AtharTextFieldVariant.borderless:
        return const BoxDecoration();
    }
  }

  Widget? _buildSuffixIcon(
    ColorScheme colorScheme,
    _TFStyle style,
    bool hasError,
  ) {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: style.iconSize,
          color: colorScheme.outline,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
        splashRadius: 20,
      );
    }
    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        size: style.iconSize,
        color: hasError ? colorScheme.error : colorScheme.outline,
      );
    }
    return widget.suffix;
  }

  _TFStyle _resolveStyle(ColorScheme colorScheme) {
    final custom = widget.customStyle;
    switch (widget.size) {
      case AtharTextFieldSize.small:
        return _TFStyle(
          AtharRadii.sm,
          1,
          custom?.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          custom?.textStyle ??
              const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
          custom?.hintStyle ??
              const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
          custom?.labelStyle ??
              const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
          18,
        );
      case AtharTextFieldSize.medium:
        return _TFStyle(
          custom?.borderRadius ?? AtharRadii.sm,
          custom?.borderWidth ?? 1,
          custom?.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          custom?.textStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
          custom?.hintStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
          custom?.labelStyle ??
              const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
          20,
        );
      case AtharTextFieldSize.large:
        return _TFStyle(
          custom?.borderRadius ?? AtharRadii.md,
          custom?.borderWidth ?? 1,
          custom?.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          custom?.textStyle ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
          custom?.hintStyle ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
          custom?.labelStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
          24,
        );
    }
  }
}

class _TFStyle {
  final double borderRadius, borderWidth, iconSize;
  final EdgeInsetsGeometry contentPadding;
  final TextStyle textStyle, hintStyle, labelStyle;
  const _TFStyle(
    this.borderRadius,
    this.borderWidth,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.iconSize,
  );
}
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../tokens.dart';

// /// ===================================================================
// /// ATHAR TEXT FIELD - حقل الإدخال الموحد
// /// ===================================================================

// enum AtharTextFieldVariant {
//   /// حقل بإطار خارجي
//   outlined,

//   /// حقل بخلفية ملونة بدون إطار
//   filled,

//   /// حقل بخط سفلي فقط
//   underlined,

//   /// حقل بدون أي إطار أو خلفية (inline)
//   /// مناسب للعناوين الكبيرة وحقول التحرير المباشر
//   /// ```dart
//   /// AtharTextField(
//   ///   variant: AtharTextFieldVariant.borderless,
//   ///   size: AtharTextFieldSize.large,
//   ///   hint: 'عنوان المهمة',
//   ///   maxLines: null,
//   /// )
//   /// ```
//   borderless,
// }

// enum AtharTextFieldSize { small, medium, large }

// /// ستايل مخصص لحقل الإدخال
// class AtharTextFieldStyle {
//   const AtharTextFieldStyle({
//     this.backgroundColor,
//     this.borderColor,
//     this.focusedBorderColor,
//     this.errorBorderColor,
//     this.borderRadius,
//     this.borderWidth,
//     this.contentPadding,
//     this.textStyle,
//     this.hintStyle,
//     this.labelStyle,
//   });

//   final Color? backgroundColor,
//       borderColor,
//       focusedBorderColor,
//       errorBorderColor;
//   final double? borderRadius, borderWidth;
//   final EdgeInsetsGeometry? contentPadding;
//   final TextStyle? textStyle, hintStyle, labelStyle;
// }

// /// حقل الإدخال الموحد
// ///
// /// ```dart
// /// AtharTextField(
// ///   label: 'البريد الإلكتروني',
// ///   hint: 'أدخل بريدك الإلكتروني',
// ///   prefixIcon: Icons.email,
// ///   keyboardType: TextInputType.emailAddress,
// /// )
// /// ```
// class AtharTextField extends StatefulWidget {
//   const AtharTextField({
//     super.key,
//     this.controller,
//     this.focusNode,
//     this.label,
//     this.hint,
//     this.helperText,
//     this.errorText,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.prefix,
//     this.suffix,
//     this.variant = AtharTextFieldVariant.outlined,
//     this.size = AtharTextFieldSize.medium,
//     this.customStyle,
//     this.keyboardType,
//     this.textInputAction,
//     this.textCapitalization = TextCapitalization.none,
//     this.obscureText = false,
//     this.autocorrect = true,
//     this.enableSuggestions = true,
//     this.maxLines = 1,
//     this.minLines,
//     this.maxLength,
//     this.inputFormatters,
//     this.validator,
//     this.onChanged,
//     this.onSubmitted,
//     this.onTap,
//     this.onEditingComplete,
//     this.enabled = true,
//     this.readOnly = false,
//     this.autofocus = false,
//     this.showCursor = true,
//     this.textAlign = TextAlign.start,
//     this.textDirection,
//     this.expands = false,
//     this.initialValue,
//   });

//   final TextEditingController? controller;
//   final FocusNode? focusNode;
//   final String? label, hint, helperText, errorText, initialValue;
//   final IconData? prefixIcon, suffixIcon;
//   final Widget? prefix, suffix;
//   final AtharTextFieldVariant variant;
//   final AtharTextFieldSize size;
//   final AtharTextFieldStyle? customStyle;
//   final TextInputType? keyboardType;
//   final TextInputAction? textInputAction;
//   final TextCapitalization textCapitalization;
//   final bool obscureText, autocorrect, enableSuggestions;
//   final int? maxLines, minLines, maxLength;
//   final List<TextInputFormatter>? inputFormatters;
//   final String? Function(String?)? validator;
//   final ValueChanged<String>? onChanged, onSubmitted;
//   final VoidCallback? onTap, onEditingComplete;
//   final bool enabled, readOnly, autofocus, showCursor, expands;
//   final TextAlign textAlign;
//   final TextDirection? textDirection;

//   // Factory constructors للأنواع الشائعة
//   factory AtharTextField.email({
//     Key? key,
//     TextEditingController? controller,
//     String? label,
//     String? hint,
//     String? errorText,
//     ValueChanged<String>? onChanged,
//     String? Function(String?)? validator,
//   }) => AtharTextField(
//     key: key,
//     controller: controller,
//     label: label ?? 'البريد الإلكتروني',
//     hint: hint ?? 'example@email.com',
//     errorText: errorText,
//     prefixIcon: Icons.email_outlined,
//     keyboardType: TextInputType.emailAddress,
//     onChanged: onChanged,
//     validator: validator,
//   );

//   factory AtharTextField.password({
//     Key? key,
//     TextEditingController? controller,
//     String? label,
//     String? hint,
//     String? errorText,
//     ValueChanged<String>? onChanged,
//     String? Function(String?)? validator,
//     bool obscureText = true,
//   }) => AtharTextField(
//     key: key,
//     controller: controller,
//     label: label ?? 'كلمة المرور',
//     hint: hint ?? '••••••••',
//     errorText: errorText,
//     prefixIcon: Icons.lock_outlined,
//     obscureText: obscureText,
//     onChanged: onChanged,
//     validator: validator,
//   );

//   factory AtharTextField.phone({
//     Key? key,
//     TextEditingController? controller,
//     String? label,
//     String? hint,
//     String? errorText,
//     ValueChanged<String>? onChanged,
//     String? Function(String?)? validator,
//   }) => AtharTextField(
//     key: key,
//     controller: controller,
//     label: label ?? 'رقم الهاتف',
//     hint: hint ?? '+966 5X XXX XXXX',
//     errorText: errorText,
//     prefixIcon: Icons.phone_outlined,
//     keyboardType: TextInputType.phone,
//     onChanged: onChanged,
//     validator: validator,
//   );

//   factory AtharTextField.search({
//     Key? key,
//     TextEditingController? controller,
//     String? hint,
//     ValueChanged<String>? onChanged,
//     VoidCallback? onTap,
//   }) => AtharTextField(
//     key: key,
//     controller: controller,
//     hint: hint ?? 'بحث...',
//     prefixIcon: Icons.search,
//     variant: AtharTextFieldVariant.filled,
//     onChanged: onChanged,
//     onTap: onTap,
//   );

//   factory AtharTextField.multiline({
//     Key? key,
//     TextEditingController? controller,
//     String? label,
//     String? hint,
//     int maxLines = 5,
//     int? minLines,
//     int? maxLength,
//     ValueChanged<String>? onChanged,
//   }) => AtharTextField(
//     key: key,
//     controller: controller,
//     label: label,
//     hint: hint,
//     maxLines: maxLines,
//     minLines: minLines ?? 3,
//     maxLength: maxLength,
//     keyboardType: TextInputType.multiline,
//     textInputAction: TextInputAction.newline,
//     onChanged: onChanged,
//   );

//   /// حقل بدون إطار - مناسب للعناوين وحقول التحرير المباشر
//   /// ```dart
//   /// AtharTextField.borderless(
//   ///   controller: _titleController,
//   ///   hint: 'عنوان المهمة',
//   ///   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//   ///   maxLines: null,
//   /// )
//   /// ```
//   factory AtharTextField.borderless({
//     Key? key,
//     TextEditingController? controller,
//     FocusNode? focusNode,
//     String? hint,
//     TextStyle? textStyle,
//     TextStyle? hintStyle,
//     int? maxLines,
//     int? minLines,
//     TextInputType? keyboardType,
//     ValueChanged<String>? onChanged,
//     bool autofocus = false,
//     String? initialValue,
//   }) => AtharTextField(
//     key: key,
//     controller: controller,
//     focusNode: focusNode,
//     hint: hint,
//     variant: AtharTextFieldVariant.borderless,
//     maxLines: maxLines,
//     minLines: minLines,
//     keyboardType: keyboardType,
//     onChanged: onChanged,
//     autofocus: autofocus,
//     initialValue: initialValue,
//     customStyle: AtharTextFieldStyle(
//       textStyle: textStyle,
//       hintStyle: hintStyle,
//       contentPadding: EdgeInsets.zero,
//     ),
//   );

//   @override
//   State<AtharTextField> createState() => _AtharTextFieldState();
// }

// class _AtharTextFieldState extends State<AtharTextField> {
//   late FocusNode _focusNode;
//   bool _isFocused = false;
//   bool _obscureText = true;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = widget.focusNode ?? FocusNode();
//     _focusNode.addListener(_onFocusChange);
//     _obscureText = widget.obscureText;
//   }

//   @override
//   void dispose() {
//     if (widget.focusNode == null) _focusNode.dispose();
//     super.dispose();
//   }

//   void _onFocusChange() {
//     setState(() => _isFocused = _focusNode.hasFocus);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final style = _resolveStyle(colors);
//     final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
//     final isBorderless = widget.variant == AtharTextFieldVariant.borderless;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // لا نعرض الـ label في وضع borderless (يُستخدم hint بدلاً منه)
//         if (widget.label != null && !isBorderless) ...[
//           Text(
//             widget.label!,
//             style: style.labelStyle.copyWith(
//               color: hasError
//                   ? colors.error
//                   : (_isFocused ? colors.primary : colors.textSecondary),
//             ),
//           ),
//           AtharGap.xs,
//         ],
//         // في وضع borderless لا نحتاج AnimatedContainer
//         if (isBorderless)
//           _buildTextFormField(colors, style, hasError, isBorderless)
//         else
//           AnimatedContainer(
//             duration: AtharAnimations.fast,
//             decoration: _buildDecoration(colors, style, hasError),
//             child: _buildTextFormField(colors, style, hasError, isBorderless),
//           ),
//         if (widget.helperText != null || hasError) ...[
//           AtharGap.xxs,
//           Text(
//             hasError ? widget.errorText! : widget.helperText!,
//             style: AtharTypography.caption.copyWith(
//               color: hasError ? colors.error : colors.textTertiary,
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildTextFormField(
//     AtharColors colors,
//     _TFStyle style,
//     bool hasError,
//     bool isBorderless,
//   ) {
//     return TextFormField(
//       controller: widget.controller,
//       focusNode: _focusNode,
//       initialValue: widget.controller == null ? widget.initialValue : null,
//       keyboardType: widget.keyboardType,
//       textInputAction: widget.textInputAction,
//       textCapitalization: widget.textCapitalization,
//       obscureText: widget.obscureText ? _obscureText : false,
//       autocorrect: widget.autocorrect,
//       enableSuggestions: widget.enableSuggestions,
//       maxLines: widget.obscureText ? 1 : widget.maxLines,
//       minLines: widget.minLines,
//       maxLength: widget.maxLength,
//       inputFormatters: widget.inputFormatters,
//       validator: widget.validator,
//       onChanged: widget.onChanged,
//       onFieldSubmitted: widget.onSubmitted,
//       onTap: widget.onTap,
//       onEditingComplete: widget.onEditingComplete,
//       enabled: widget.enabled,
//       readOnly: widget.readOnly,
//       autofocus: widget.autofocus,
//       showCursor: widget.showCursor,
//       textAlign: widget.textAlign,
//       textDirection: widget.textDirection,
//       expands: widget.expands,
//       style: style.textStyle.copyWith(
//         color: widget.enabled ? colors.textPrimary : colors.textDisabled,
//       ),
//       decoration: InputDecoration(
//         hintText: widget.hint,
//         hintStyle: style.hintStyle.copyWith(color: colors.textTertiary),
//         contentPadding: style.contentPadding,
//         isDense: true,
//         filled: widget.variant == AtharTextFieldVariant.filled,
//         fillColor: widget.variant == AtharTextFieldVariant.filled
//             ? (widget.enabled
//                   ? colors.surfaceContainerLow
//                   : colors.surfaceContainer)
//             : Colors.transparent,
//         border: InputBorder.none,
//         enabledBorder: InputBorder.none,
//         focusedBorder: InputBorder.none,
//         errorBorder: InputBorder.none,
//         focusedErrorBorder: InputBorder.none,
//         disabledBorder: InputBorder.none,
//         // في وضع borderless لا نعرض الأيقونات تلقائياً إلا إذا حُددت
//         prefixIcon: widget.prefixIcon != null
//             ? Icon(
//                 widget.prefixIcon,
//                 size: style.iconSize,
//                 color: hasError
//                     ? colors.error
//                     : (_isFocused ? colors.primary : colors.textTertiary),
//               )
//             : widget.prefix,
//         suffixIcon: _buildSuffixIcon(colors, style, hasError),
//         counterText: '',
//       ),
//     );
//   }

//   BoxDecoration _buildDecoration(
//     AtharColors colors,
//     _TFStyle style,
//     bool hasError,
//   ) {
//     Color borderColor = hasError
//         ? colors.error
//         : (_isFocused
//               ? colors.primary
//               : (widget.customStyle?.borderColor ?? colors.border));
//     if (!widget.enabled) borderColor = colors.borderLight;

//     switch (widget.variant) {
//       case AtharTextFieldVariant.outlined:
//         return BoxDecoration(
//           color: widget.enabled ? colors.surface : colors.surfaceContainer,
//           borderRadius: BorderRadius.circular(style.borderRadius),
//           border: Border.all(
//             color: borderColor,
//             width: _isFocused ? 2 : style.borderWidth,
//           ),
//         );
//       case AtharTextFieldVariant.filled:
//         return BoxDecoration(
//           color: widget.enabled
//               ? colors.surfaceContainerLow
//               : colors.surfaceContainer,
//           borderRadius: BorderRadius.circular(style.borderRadius),
//           border: hasError
//               ? Border.all(color: colors.error, width: style.borderWidth)
//               : null,
//         );
//       case AtharTextFieldVariant.underlined:
//         return BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: borderColor,
//               width: _isFocused ? 2 : style.borderWidth,
//             ),
//           ),
//         );
//       case AtharTextFieldVariant.borderless:
//         // لا decoration - يجب أن لا يُستدعى هذا الـ case
//         // لأن borderless لا يُغلف بـ AnimatedContainer
//         return const BoxDecoration();
//     }
//   }

//   Widget? _buildSuffixIcon(AtharColors colors, _TFStyle style, bool hasError) {
//     if (widget.obscureText) {
//       return IconButton(
//         icon: Icon(
//           _obscureText
//               ? Icons.visibility_outlined
//               : Icons.visibility_off_outlined,
//           size: style.iconSize,
//           color: colors.textTertiary,
//         ),
//         onPressed: () => setState(() => _obscureText = !_obscureText),
//         splashRadius: 20,
//       );
//     }
//     if (widget.suffixIcon != null) {
//       return Icon(
//         widget.suffixIcon,
//         size: style.iconSize,
//         color: hasError ? colors.error : colors.textTertiary,
//       );
//     }
//     return widget.suffix;
//   }

//   _TFStyle _resolveStyle(AtharColors colors) {
//     final custom = widget.customStyle;
//     switch (widget.size) {
//       case AtharTextFieldSize.small:
//         return _TFStyle(
//           AtharRadii.sm,
//           1,
//           custom?.contentPadding ??
//               const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           custom?.textStyle ?? AtharTypography.bodySmall,
//           custom?.hintStyle ?? AtharTypography.bodySmall,
//           custom?.labelStyle ?? AtharTypography.labelSmall,
//           18,
//         );
//       case AtharTextFieldSize.medium:
//         return _TFStyle(
//           custom?.borderRadius ?? AtharRadii.sm,
//           custom?.borderWidth ?? 1,
//           custom?.contentPadding ??
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//           custom?.textStyle ?? AtharTypography.bodyMedium,
//           custom?.hintStyle ?? AtharTypography.bodyMedium,
//           custom?.labelStyle ?? AtharTypography.labelMedium,
//           20,
//         );
//       case AtharTextFieldSize.large:
//         return _TFStyle(
//           custom?.borderRadius ?? AtharRadii.md,
//           custom?.borderWidth ?? 1,
//           custom?.contentPadding ??
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           custom?.textStyle ?? AtharTypography.bodyLarge,
//           custom?.hintStyle ?? AtharTypography.bodyLarge,
//           custom?.labelStyle ?? AtharTypography.labelLarge,
//           24,
//         );
//     }
//   }
// }

// class _TFStyle {
//   final double borderRadius, borderWidth, iconSize;
//   final EdgeInsetsGeometry contentPadding;
//   final TextStyle textStyle, hintStyle, labelStyle;
//   const _TFStyle(
//     this.borderRadius,
//     this.borderWidth,
//     this.contentPadding,
//     this.textStyle,
//     this.hintStyle,
//     this.labelStyle,
//     this.iconSize,
//   );
// }
//-----------------------------------------------------------------------
