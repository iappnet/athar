// lib/core/design_system/widgets/adaptive_shell.dart
// Responsive breakpoint system for the app shell.
// Uses LayoutBuilder at the scaffold level so Split View and Stage Manager
// width changes reflect immediately — does not read MediaQuery.size directly.

import 'package:flutter/material.dart';

/// Canonical breakpoints for the AdaptiveShell.
///
/// Widths defined per IPAD_OPTIMIZATION.md:
///   phone          < 600dp  — bottom dock (LiquidGlassNavBar + FAB)
///   tabletCompact  600–839dp — NavigationRail, 72pt, icons only
///   tabletExpanded 840–1199dp — NavigationRail, 240pt, labels visible
///   desktop        ≥ 1200dp  — rail + sidebar (fallback: expanded rail)
enum ShellBreakpoint {
  phone,
  tabletCompact,
  tabletExpanded,
  desktop;

  static ShellBreakpoint fromWidth(double width) {
    if (width < 600) return ShellBreakpoint.phone;
    if (width < 840) return ShellBreakpoint.tabletCompact;
    if (width < 1200) return ShellBreakpoint.tabletExpanded;
    return ShellBreakpoint.desktop;
  }

  /// True for phone-width (< 600dp). Uses bottom dock navigation.
  bool get isPhone => this == ShellBreakpoint.phone;

  /// True for any tablet or desktop width. Uses NavigationRail.
  bool get isTablet =>
      this == ShellBreakpoint.tabletCompact ||
      this == ShellBreakpoint.tabletExpanded ||
      this == ShellBreakpoint.desktop;

  /// True for 600–839dp. Rail is icon-only (72pt) by default.
  bool get usesCompactRail => this == ShellBreakpoint.tabletCompact;

  /// True for ≥ 840dp. Rail may show labels (240pt when expanded).
  bool get usesExpandedRail =>
      this == ShellBreakpoint.tabletExpanded || this == ShellBreakpoint.desktop;
}

/// Thin [LayoutBuilder] wrapper that resolves the current [ShellBreakpoint]
/// and exposes it to [builder] without reading MediaQuery.size directly.
///
/// Place this at the outermost scaffold-decision level so that iPad Split View
/// and Stage Manager width changes are reflected immediately in the layout branch.
///
/// Usage:
/// ```dart
/// AdaptiveShell(
///   builder: (context, breakpoint) {
///     return Scaffold(
///       body: breakpoint.isTablet ? railLayout : phoneLayout,
///       bottomNavigationBar: breakpoint.isPhone ? navBar : null,
///     );
///   },
/// )
/// ```
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, ShellBreakpoint breakpoint) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ShellBreakpoint.fromWidth(constraints.maxWidth);
        return builder(context, breakpoint);
      },
    );
  }
}
