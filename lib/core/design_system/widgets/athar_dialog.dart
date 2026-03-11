import 'package:flutter/material.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import '../tokens.dart';
import 'athar_button.dart';

/// ATHAR DIALOG

class AtharDialog extends StatelessWidget {
  const AtharDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.icon,
    this.iconColor,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.showCloseButton = false,
    this.barrierDismissible = true,
  });

  final String? title, message, confirmLabel, cancelLabel;
  final Widget? content;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onConfirm, onCancel;
  final bool isDestructive, showCloseButton, barrierDismissible;

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    IconData? icon,
    Color? iconColor,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    bool showCloseButton = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AtharDialog(
        title: title,
        message: message,
        content: content,
        icon: icon,
        iconColor: iconColor,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
        showCloseButton: showCloseButton,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    IconData? icon,
  }) {
    final l10n = AppLocalizations.of(context);
    return show<bool>(
      context: context,
      title: title,
      message: message,
      icon: icon,
      confirmLabel: confirmLabel ?? l10n.dialogConfirmLabel,
      cancelLabel: cancelLabel ?? l10n.dialogCancelLabel,
      isDestructive: isDestructive,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    );
  }

  static Future<void> alert({
    required BuildContext context,
    required String title,
    String? message,
    String? buttonLabel,
    IconData? icon,
  }) {
    final l10n = AppLocalizations.of(context);
    return show(
      context: context,
      title: title,
      message: message,
      icon: icon,
      confirmLabel: buttonLabel ?? l10n.dialogOkLabel,
      onConfirm: () => Navigator.of(context).pop(),
    );
  }

  static Future<void> success({
    required BuildContext context,
    required String title,
    String? message,
  }) => alert(
    context: context,
    title: title,
    message: message,
    icon: Icons.check_circle_outline,
  );

  static Future<void> error({
    required BuildContext context,
    required String title,
    String? message,
  }) => alert(
    context: context,
    title: title,
    message: message,
    icon: Icons.error_outline,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AtharRadii.xl),
      ),
      backgroundColor: colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
        child: Padding(
          padding: AtharSpacing.dialog,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCloseButton) ...[
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: IconButton(
                    icon: Icon(Icons.close, color: colorScheme.outline),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
              if (icon != null) ...[
                Container(
                  padding: AtharSpacing.allMd,
                  decoration: BoxDecoration(
                    color: (iconColor ?? colorScheme.primary).withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: iconColor ?? colorScheme.primary,
                  ),
                ),
                AtharGap.lg,
              ],
              if (title != null) ...[
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                AtharGap.sm,
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
                AtharGap.lg,
              ],
              if (content != null) ...[content!, AtharGap.lg],
              if (confirmLabel != null || cancelLabel != null)
                Row(
                  children: [
                    if (cancelLabel != null) ...[
                      Expanded(
                        child: AtharButton.outline(
                          label: cancelLabel,
                          onPressed: () {
                            onCancel?.call();
                            if (onCancel == null) Navigator.of(context).pop();
                          },
                        ),
                      ),
                      if (confirmLabel != null) AtharGap.hMd,
                    ],
                    if (confirmLabel != null)
                      Expanded(
                        child: AtharButton(
                          label: confirmLabel,
                          variant: isDestructive
                              ? AtharButtonVariant.danger
                              : AtharButtonVariant.primary,
                          onPressed: () {
                            onConfirm?.call();
                            if (onConfirm == null) Navigator.of(context).pop();
                          },
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ATHAR BOTTOM SHEET

class AtharBottomSheet extends StatelessWidget {
  const AtharBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.showCloseButton = false,
    this.padding,
    this.maxHeight,
    this.isScrollable = false,
  });

  final Widget child;
  final String? title;
  final bool showDragHandle, showCloseButton, isScrollable;
  final EdgeInsetsGeometry? padding;
  final double? maxHeight;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showDragHandle = true,
    bool showCloseButton = false,
    EdgeInsetsGeometry? padding,
    double? maxHeight,
    bool isScrollable = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => AtharBottomSheet(
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        padding: padding,
        maxHeight: maxHeight,
        isScrollable: isScrollable,
        child: child,
      ),
    );
  }

  static Future<T?> showOptions<T>({
    required BuildContext context,
    required List<AtharBottomSheetOption<T>> options,
    String? title,
  }) {
    return show<T>(
      context: context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (option) => _AtharDialogListTile(
                leadingIcon: option.icon,
                title: option.label,
                subtitle: option.subtitle,
                enabled: option.enabled,
                onTap: () => Navigator.of(context).pop(option.value),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectivePadding = padding ?? AtharSpacing.bottomSheet;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDragHandle)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        if (title != null || showCloseButton)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                if (showCloseButton)
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.outline),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
        Padding(padding: effectivePadding, child: child),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );

    if (isScrollable) {
      content = SingleChildScrollView(child: content);
    }

    return Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: content,
    );
  }
}

class AtharBottomSheetOption<T> {
  const AtharBottomSheetOption({
    required this.label,
    required this.value,
    this.icon,
    this.subtitle,
    this.enabled = true,
  });

  final String label;
  final T value;
  final IconData? icon;
  final String? subtitle;
  final bool enabled;
}

class _AtharDialogListTile extends StatelessWidget {
  const _AtharDialogListTile({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: AtharSpacing.listItem,
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                color: enabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface.withValues(alpha: 0.38),
              ),
              AtharGap.hMd,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
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
//-----------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import '../tokens.dart';
// import 'athar_button.dart';

// /// ===================================================================
// /// ATHAR DIALOG - مربع الحوار الموحد
// /// ===================================================================

// /// مربع حوار موحد
// ///
// /// ```dart
// /// AtharDialog.show(
// ///   context: context,
// ///   title: 'تأكيد الحذف',
// ///   message: 'هل أنت متأكد من حذف هذا العنصر؟',
// ///   confirmLabel: 'حذف',
// ///   cancelLabel: 'إلغاء',
// ///   isDestructive: true,
// ///   onConfirm: () => deleteItem(),
// /// );
// /// ```
// class AtharDialog extends StatelessWidget {
//   const AtharDialog({
//     super.key,
//     this.title,
//     this.message,
//     this.content,
//     this.icon,
//     this.iconColor,
//     this.confirmLabel,
//     this.cancelLabel,
//     this.onConfirm,
//     this.onCancel,
//     this.isDestructive = false,
//     this.showCloseButton = false,
//     this.barrierDismissible = true,
//   });

//   final String? title, message, confirmLabel, cancelLabel;
//   final Widget? content;
//   final IconData? icon;
//   final Color? iconColor;
//   final VoidCallback? onConfirm, onCancel;
//   final bool isDestructive, showCloseButton, barrierDismissible;

//   /// عرض مربع الحوار
//   static Future<T?> show<T>({
//     required BuildContext context,
//     String? title,
//     String? message,
//     Widget? content,
//     IconData? icon,
//     Color? iconColor,
//     String? confirmLabel,
//     String? cancelLabel,
//     VoidCallback? onConfirm,
//     VoidCallback? onCancel,
//     bool isDestructive = false,
//     bool showCloseButton = false,
//     bool barrierDismissible = true,
//   }) {
//     return showDialog<T>(
//       context: context,
//       barrierDismissible: barrierDismissible,
//       builder: (context) => AtharDialog(
//         title: title,
//         message: message,
//         content: content,
//         icon: icon,
//         iconColor: iconColor,
//         confirmLabel: confirmLabel,
//         cancelLabel: cancelLabel,
//         onConfirm: onConfirm,
//         onCancel: onCancel,
//         isDestructive: isDestructive,
//         showCloseButton: showCloseButton,
//         barrierDismissible: barrierDismissible,
//       ),
//     );
//   }

//   /// مربع حوار تأكيد
//   static Future<bool?> confirm({
//     required BuildContext context,
//     required String title,
//     String? message,
//     String confirmLabel = 'تأكيد',
//     String cancelLabel = 'إلغاء',
//     bool isDestructive = false,
//     IconData? icon,
//   }) {
//     return show<bool>(
//       context: context,
//       title: title,
//       message: message,
//       icon: icon,
//       confirmLabel: confirmLabel,
//       cancelLabel: cancelLabel,
//       isDestructive: isDestructive,
//       onConfirm: () => Navigator.of(context).pop(true),
//       onCancel: () => Navigator.of(context).pop(false),
//     );
//   }

//   /// مربع حوار تنبيه
//   static Future<void> alert({
//     required BuildContext context,
//     required String title,
//     String? message,
//     String buttonLabel = 'حسناً',
//     IconData? icon,
//   }) {
//     return show(
//       context: context,
//       title: title,
//       message: message,
//       icon: icon,
//       confirmLabel: buttonLabel,
//       onConfirm: () => Navigator.of(context).pop(),
//     );
//   }

//   /// مربع حوار نجاح
//   static Future<void> success({
//     required BuildContext context,
//     required String title,
//     String? message,
//   }) => alert(
//     context: context,
//     title: title,
//     message: message,
//     icon: Icons.check_circle_outline,
//   );

//   /// مربع حوار خطأ
//   static Future<void> error({
//     required BuildContext context,
//     required String title,
//     String? message,
//   }) => alert(
//     context: context,
//     title: title,
//     message: message,
//     icon: Icons.error_outline,
//   );

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(AtharRadii.xl),
//       ),
//       backgroundColor: colors.surface,
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
//         child: Padding(
//           padding: AtharSpacing.dialog,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (showCloseButton) ...[
//                 Align(
//                   alignment: AlignmentDirectional.topEnd,
//                   child: IconButton(
//                     icon: Icon(Icons.close, color: colors.textTertiary),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ),
//               ],
//               if (icon != null) ...[
//                 Container(
//                   padding: AtharSpacing.allMd,
//                   decoration: BoxDecoration(
//                     color: (iconColor ?? colors.primary).withValues(alpha: 0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     icon,
//                     size: 32,
//                     color: iconColor ?? colors.primary,
//                   ),
//                 ),
//                 AtharGap.lg,
//               ],
//               if (title != null) ...[
//                 Text(
//                   title!,
//                   style: AtharTypography.dialogTitle.copyWith(
//                     color: colors.textPrimary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 AtharGap.sm,
//               ],
//               if (message != null) ...[
//                 Text(
//                   message!,
//                   style: AtharTypography.bodyMedium.copyWith(
//                     color: colors.textSecondary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 AtharGap.lg,
//               ],
//               if (content != null) ...[content!, AtharGap.lg],
//               if (confirmLabel != null || cancelLabel != null)
//                 Row(
//                   children: [
//                     if (cancelLabel != null) ...[
//                       Expanded(
//                         child: AtharButton.outline(
//                           label: cancelLabel,
//                           onPressed: () {
//                             onCancel?.call();
//                             if (onCancel == null) Navigator.of(context).pop();
//                           },
//                         ),
//                       ),
//                       if (confirmLabel != null) AtharGap.hMd,
//                     ],
//                     if (confirmLabel != null)
//                       Expanded(
//                         child: AtharButton(
//                           label: confirmLabel,
//                           variant: isDestructive
//                               ? AtharButtonVariant.danger
//                               : AtharButtonVariant.primary,
//                           onPressed: () {
//                             onConfirm?.call();
//                             if (onConfirm == null) Navigator.of(context).pop();
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// ===================================================================
// /// ATHAR BOTTOM SHEET - الورقة السفلية الموحدة
// /// ===================================================================

// class AtharBottomSheet extends StatelessWidget {
//   const AtharBottomSheet({
//     super.key,
//     required this.child,
//     this.title,
//     this.showDragHandle = true,
//     this.showCloseButton = false,
//     this.padding,
//     this.maxHeight,
//     this.isScrollable = false,
//   });

//   final Widget child;
//   final String? title;
//   final bool showDragHandle, showCloseButton, isScrollable;
//   final EdgeInsetsGeometry? padding;
//   final double? maxHeight;

//   /// عرض الورقة السفلية
//   static Future<T?> show<T>({
//     required BuildContext context,
//     required Widget child,
//     String? title,
//     bool showDragHandle = true,
//     bool showCloseButton = false,
//     EdgeInsetsGeometry? padding,
//     double? maxHeight,
//     bool isScrollable = false,
//     bool isDismissible = true,
//     bool enableDrag = true,
//     bool isScrollControlled = true,
//   }) {
//     return showModalBottomSheet<T>(
//       context: context,
//       isScrollControlled: isScrollControlled,
//       isDismissible: isDismissible,
//       enableDrag: enableDrag,
//       backgroundColor: Colors.transparent,
//       builder: (context) => AtharBottomSheet(
//         title: title,
//         showDragHandle: showDragHandle,
//         showCloseButton: showCloseButton,
//         padding: padding,
//         maxHeight: maxHeight,
//         isScrollable: isScrollable,
//         child: child,
//       ),
//     );
//   }

//   /// عرض قائمة خيارات
//   static Future<T?> showOptions<T>({
//     required BuildContext context,
//     required List<AtharBottomSheetOption<T>> options,
//     String? title,
//   }) {
//     return show<T>(
//       context: context,
//       title: title,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: options
//             .map(
//               (option) => AtharListTile(
//                 leadingIcon: option.icon,
//                 title: option.label,
//                 subtitle: option.subtitle,
//                 enabled: option.enabled,
//                 onTap: () => Navigator.of(context).pop(option.value),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final effectivePadding = padding ?? AtharSpacing.bottomSheet;

//     Widget content = Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         if (showDragHandle)
//           Center(
//             child: Container(
//               margin: const EdgeInsets.only(top: 12, bottom: 8),
//               width: 32,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: colors.surfaceContainerHigh,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//         if (title != null || showCloseButton)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 if (title != null)
//                   Expanded(
//                     child: Text(
//                       title!,
//                       style: AtharTypography.titleLarge.copyWith(
//                         color: colors.textPrimary,
//                       ),
//                     ),
//                   ),
//                 if (showCloseButton)
//                   IconButton(
//                     icon: Icon(Icons.close, color: colors.textTertiary),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//               ],
//             ),
//           ),
//         Padding(padding: effectivePadding, child: child),
//         SizedBox(height: MediaQuery.of(context).padding.bottom),
//       ],
//     );

//     if (isScrollable) {
//       content = SingleChildScrollView(child: content);
//     }

//     return Container(
//       constraints: maxHeight != null
//           ? BoxConstraints(maxHeight: maxHeight!)
//           : null,
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       child: content,
//     );
//   }
// }

// /// خيار في الورقة السفلية
// class AtharBottomSheetOption<T> {
//   const AtharBottomSheetOption({
//     required this.label,
//     required this.value,
//     this.icon,
//     this.subtitle,
//     this.enabled = true,
//   });

//   final String label;
//   final T value;
//   final IconData? icon;
//   final String? subtitle;
//   final bool enabled;
// }

// /// عنصر قائمة بسيط (للاستخدام الداخلي)
// class AtharListTile extends StatelessWidget {
//   const AtharListTile({
//     super.key,
//     required this.title,
//     this.subtitle,
//     this.leadingIcon,
//     this.onTap,
//     this.enabled = true,
//   });

//   final String title;
//   final String? subtitle;
//   final IconData? leadingIcon;
//   final VoidCallback? onTap;
//   final bool enabled;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     return InkWell(
//       onTap: enabled ? onTap : null,
//       child: Padding(
//         padding: AtharSpacing.listItem,
//         child: Row(
//           children: [
//             if (leadingIcon != null) ...[
//               Icon(
//                 leadingIcon,
//                 color: enabled ? colors.textSecondary : colors.textDisabled,
//               ),
//               AtharGap.hMd,
//             ],
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: AtharTypography.bodyLarge.copyWith(
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
//-----------------------------------------------------------------------
