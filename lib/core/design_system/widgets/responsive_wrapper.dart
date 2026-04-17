// lib/core/widgets/responsive_wrapper.dart
// ✅ Widget لتغليف المحتوى بشكل متجاوب

import 'package:athar/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

/// Widget لتغليف المحتوى وتحديد أقصى عرض له
/// يُستخدم لجعل الفورم والمحتوى يظهر بشكل جيد على iPad
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;
  final bool centerContent;
  final Color? backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 500,
    this.padding,
    this.centerContent = true,
    this.backgroundColor,
  });

  /// Factory للفورم (أقصى عرض 450)
  factory ResponsiveWrapper.form({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return ResponsiveWrapper(
      key: key,
      maxWidth: 450,
      padding: padding,
      child: child,
    );
  }

  /// Factory للمحتوى العام (أقصى عرض 600)
  factory ResponsiveWrapper.content({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return ResponsiveWrapper(
      key: key,
      maxWidth: 600,
      padding: padding,
      child: child,
    );
  }

  /// Factory للكارد (أقصى عرض 500)
  factory ResponsiveWrapper.card({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return ResponsiveWrapper(
      key: key,
      maxWidth: 500,
      padding: padding,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان موبايل، نرجع الـ child مباشرة
    if (ResponsiveHelper.isMobile(context)) {
      if (padding != null) {
        return Padding(padding: padding!, child: child);
      }
      return child;
    }

    // إذا كان تابلت، نضيف constraints
    Widget content = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: padding,
      child: child,
    );

    if (centerContent) {
      content = Center(child: content);
    }

    if (backgroundColor != null) {
      content = Container(
        color: backgroundColor,
        width: double.infinity,
        child: content,
      );
    }

    return content;
  }
}

/// Widget للصفحات الكاملة (Scaffold) مع دعم responsive
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final double maxBodyWidth;
  final bool extendBodyBehindAppBar;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.maxBodyWidth = 800,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    Widget bodyContent = body;

    // في التابلت، نحدد أقصى عرض للمحتوى
    if (isTablet) {
      bodyContent = Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxBodyWidth),
          child: body,
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: bodyContent,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}

/// Widget لعرض layout مختلف بين الموبايل والتابلت
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;

  const ResponsiveLayout({super.key, required this.mobile, this.tablet});

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Widget للشبكة المتجاوبة
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
    );

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - (spacing * (columns - 1))) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((child) {
              return SizedBox(width: itemWidth, child: child);
            }).toList(),
          );
        },
      ),
    );
  }
}
