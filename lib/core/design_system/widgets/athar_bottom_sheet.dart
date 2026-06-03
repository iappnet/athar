import 'package:flutter/material.dart';
import 'package:athar/core/design_system/tokens.dart';

/// Hardened modal container for all bottom-sheet presentations.
///
/// Heavy sheets (pass [actions]) use a pinned 3-part Column:
///   grabber + title (flex:none) → scrollable body (Expanded)
///   → action row (flex:none).
/// Light/option sheets (omit [actions]) use the legacy min-size structure so
/// all existing [show] and [showOptions] call sites are unchanged.
///
/// [maxHeightFraction] caps the sheet at 92 % of the safe-area height.
/// On tablet (width ≥ 600): floating card centred, maxWidth 480,
/// all 4 corners rounded with [AtharRadii.radiusLg].
class AtharBottomSheet extends StatelessWidget {
  const AtharBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showDragHandle = true,
    this.showCloseButton = false,
    this.padding,
    this.maxHeightFraction = 0.92,
    this.isScrollable = false,
  });

  final Widget child;
  final String? title;

  /// Pinned action-row widgets. When non-null/non-empty, activates the
  /// 3-part pinned structure. Leave null for light/option sheets.
  final List<Widget>? actions;
  final bool showDragHandle;
  final bool showCloseButton;

  /// Legacy path only: wraps child in [SingleChildScrollView] when [actions]
  /// is null. Ignored when [actions] is provided.
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final double maxHeightFraction;

  // ─── Static helpers ──────────────────────────────────────────────────────

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool showDragHandle = true,
    bool showCloseButton = false,
    EdgeInsetsGeometry? padding,
    double maxHeightFraction = 0.92,
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
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => AtharBottomSheet(
        title: title,
        actions: actions,
        showDragHandle: showDragHandle && enableDrag,
        showCloseButton: showCloseButton,
        padding: padding,
        maxHeightFraction: maxHeightFraction,
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
              (o) => _BottomSheetListTile(
                leadingIcon: o.icon,
                title: o.label,
                subtitle: o.subtitle,
                enabled: o.enabled,
                onTap: () => Navigator.of(context).pop(o.value),
              ),
            )
            .toList(),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final maxH = topPad + (mq.size.height - topPad) * maxHeightFraction;
    final isTablet = mq.size.width >= 600;
    final pinned = actions != null && actions!.isNotEmpty;

    Widget grabber() => Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: AtharRadii.radiusXxxs,
            ),
          ),
        );

    Widget titleRow() => Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 8, 8),
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
                      fontFamily: AtharTypography.fontFamily,
                      fontFamilyFallback: AtharTypography.fontFallback,
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
        );

    Widget content;
    if (pinned) {
      // 3-part pinned structure for heavy/accordion sheets.
      // SizedBox with a TIGHT height lets Column→Expanded work correctly.
      content = SizedBox(
        height: maxH,
        child: Column(
          children: [
            if (showDragHandle) grabber(),
            if (title != null || showCloseButton) titleRow(),
            Expanded(
              child: SingleChildScrollView(
                padding: padding ??
                    const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 0),
                child: child,
              ),
            ),
            // Pinned action row — always above keyboard.
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                24,
                12,
                24,
                24 + mq.viewInsets.bottom + mq.padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: actions!,
              ),
            ),
          ],
        ),
      );
    } else {
      // Legacy path: used by all existing show() / showOptions() call sites.
      Widget body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDragHandle) grabber(),
          if (title != null || showCloseButton) titleRow(),
          Padding(padding: padding ?? AtharSpacing.bottomSheet, child: child),
          SizedBox(height: mq.padding.bottom),
        ],
      );
      if (isScrollable) body = SingleChildScrollView(child: body);
      content = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: body,
      );
    }

    final radius = isTablet ? AtharRadii.radiusLg : AtharRadii.bottomSheet;

    Widget sheet = DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: radius,
      ),
      child: content,
    );

    if (isTablet) {
      sheet = Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
          constraints: const BoxConstraints(maxWidth: 480),
          child: sheet,
        ),
      );
    }

    return sheet;
  }
}

// ─── Option model for showOptions ────────────────────────────────────────────

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

// ─── Private tile used by showOptions ────────────────────────────────────────

class _BottomSheetListTile extends StatelessWidget {
  const _BottomSheetListTile({
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
    final cs = Theme.of(context).colorScheme;
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
                    ? cs.onSurfaceVariant
                    : cs.onSurface.withValues(alpha: 0.38),
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
                          ? cs.onSurface
                          : cs.onSurface.withValues(alpha: 0.38),
                      fontFamily: AtharTypography.fontFamily,
                      fontFamilyFallback: AtharTypography.fontFallback,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                        color: cs.outline,
                        fontFamily: AtharTypography.fontFamily,
                        fontFamilyFallback: AtharTypography.fontFallback,
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
