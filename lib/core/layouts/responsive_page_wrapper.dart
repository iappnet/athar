// lib/core/layouts/responsive_page_wrapper.dart
// ✅ أغلفة للصفحات والمحتوى المتجاوب

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/responsive_helper.dart';

/// غلاف للصفحات يضمن:
/// - محتوى محدود العرض في التابلت
/// - padding مناسب
/// - توسيط المحتوى
class ResponsivePageWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;
  final bool center;
  final Color? backgroundColor;
  final ScrollPhysics? physics;

  const ResponsivePageWrapper({
    super.key,
    required this.child,
    this.maxWidth = 900,
    this.padding,
    this.center = true,
    this.backgroundColor,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: isTablet ? 32 : 16.w,
      vertical: isTablet ? 24 : 16.h,
    );

    Widget content = Padding(
      padding: padding ?? defaultPadding,
      child: child,
    );

    if (isTablet && center) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }

    if (backgroundColor != null) {
      content = Container(
        color: backgroundColor,
        child: content,
      );
    }

    return content;
  }
}

/// غلاف للفورم (عرض أضيق)
class ResponsiveFormWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const ResponsiveFormWrapper({
    super.key,
    required this.child,
    this.maxWidth = 450,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsivePageWrapper(
      maxWidth: maxWidth,
      padding: padding,
      child: child,
    );
  }
}

/// حاوية محتوى مع تصميم Card
class ContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;

  const ContentCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      margin: margin ?? EdgeInsets.symmetric(
        horizontal: isTablet ? 0 : 8.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border ?? Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: elevation ?? 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? EdgeInsets.all(isTablet ? 20 : 16.w),
          child: child,
        ),
      ),
    );
  }
}

/// شبكة متجاوبة للكاردات
class ResponsiveCardGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio,
    this.padding,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final columns = isTablet ? tabletColumns : mobileColumns;

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// قائمة متجاوبة (تتحول لـ Grid في التابلت)
class ResponsiveList extends StatelessWidget {
  final List<Widget> children;
  final bool useGrid;
  final int tabletColumns;
  final double spacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveList({
    super.key,
    required this.children,
    this.useGrid = true,
    this.tabletColumns = 2,
    this.spacing = 12,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    if (isTablet && useGrid) {
      return _buildGrid(context);
    }

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: children.length,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (_, index) => children[index],
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: children.map((child) {
        return SizedBox(
          width: _calculateItemWidth(context),
          child: child,
        );
      }).toList(),
    );
  }

  double _calculateItemWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 
        (padding?.horizontal ?? 0) - 
        (spacing * (tabletColumns - 1)) -
        100; // للـ NavigationRail
    return (availableWidth / tabletColumns).clamp(200, 500);
  }
}

/// قسم مع عنوان
class ResponsiveSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets? padding;
  final EdgeInsets? titlePadding;

  const ResponsiveSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.padding,
    this.titlePadding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = ResponsiveHelper.isTablet(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: titlePadding ?? EdgeInsets.symmetric(
              horizontal: isTablet ? 8 : 4.w,
              vertical: 8.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12.sp,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}
