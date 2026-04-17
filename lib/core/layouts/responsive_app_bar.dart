// lib/core/layouts/responsive_app_bar.dart
// ✅ AppBar متجاوب يتكيف مع حجم الشاشة

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/responsive_helper.dart';

/// AppBar متجاوب مع دعم:
/// - عنوان مركزي للتابلت
/// - أيقونات متناسقة
/// - ارتفاع ديناميكي
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final bool extendBehind;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.flexibleSpace,
    this.bottom,
    this.extendBehind = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: _buildTitle(context, isTablet, colorScheme),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 1,
      leading: _buildLeading(context, colorScheme),
      actions: _buildActions(context, isTablet, colorScheme),
      flexibleSpace: flexibleSpace,
      bottom: bottom,
    );
  }

  Widget _buildTitle(
    BuildContext context,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isTablet ? 22 : 18.sp,
        fontWeight: FontWeight.bold,
        color: foregroundColor ?? colorScheme.onSurface,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, ColorScheme colorScheme) {
    if (leading != null) return leading;

    if (showBackButton && Navigator.canPop(context)) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: foregroundColor ?? colorScheme.onSurface,
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      );
    }

    return null;
  }

  List<Widget>? _buildActions(
    BuildContext context,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    if (actions == null || actions!.isEmpty) return null;

    // في التابلت، نضيف padding إضافي
    if (isTablet) {
      return [
        ...actions!,
        const SizedBox(width: 16),
      ];
    }

    return actions;
  }
}

/// SliverAppBar متجاوب للصفحات القابلة للتمرير
class ResponsiveSliverAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double? expandedHeight;
  final Widget? flexibleContent;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ResponsiveSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight,
    this.flexibleContent,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    final defaultExpandedHeight = isTablet ? 180.0 : 140.0;

    return SliverAppBar(
      expandedHeight: expandedHeight ?? defaultExpandedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: 0,
      leading: leading,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 48 : 16,
          vertical: 16,
        ),
        title: _buildFlexibleTitle(context, isTablet, colorScheme),
        background: flexibleContent ?? _buildDefaultBackground(colorScheme),
      ),
    );
  }

  Widget _buildFlexibleTitle(
    BuildContext context,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    if (subtitle == null) {
      return Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 20 : 16.sp,
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? colorScheme.onSurface,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 20 : 16.sp,
            fontWeight: FontWeight.bold,
            color: foregroundColor ?? colorScheme.onSurface,
          ),
        ),
        Text(
          subtitle!,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12.sp,
            color: (foregroundColor ?? colorScheme.onSurface).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultBackground(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.surface,
          ],
        ),
      ),
    );
  }
}
