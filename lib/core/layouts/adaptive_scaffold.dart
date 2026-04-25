// lib/core/layouts/adaptive_scaffold.dart
// ✅ نظام Scaffold ذكي يتكيف مع حجم الشاشة

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/responsive_helper.dart';

/// عنصر التنقل
class AdaptiveNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String route;
  final Widget? badge;

  const AdaptiveNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.route,
    this.badge,
  });
}

/// Scaffold متجاوب يتكيف تلقائياً مع:
/// - الموبايل: BottomNavigationBar
/// - التابلت: NavigationRail (جانبي)
class AdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final List<AdaptiveNavItem> destinations;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showNavigation;
  final Color? backgroundColor;
  final Widget? drawer;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showNavigation = true,
    this.backgroundColor,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (isTablet && showNavigation) {
      return _buildTabletLayout(context, colorScheme);
    } else {
      return _buildMobileLayout(context, colorScheme);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // تخطيط التابلت
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTabletLayout(BuildContext context, ColorScheme colorScheme) {
    final isLandscape = ResponsiveHelper.isLandscape(context);
    
    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      appBar: appBar,
      drawer: drawer,
      body: SafeArea(
        child: Row(
          children: [
            // المحتوى الرئيسي (يأتي أولاً لأن الواجهة RTL)
            Expanded(
              child: _buildConstrainedBody(context),
            ),
            
            // NavigationRail على اليمين (للعربية)
            _buildNavigationRail(context, colorScheme, isLandscape),
          ],
        ),
      ),
      // FAB في التابلت يكون في المحتوى
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation ?? 
          FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildNavigationRail(
    BuildContext context,
    ColorScheme colorScheme,
    bool isLandscape,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: NavigationRail(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Colors.transparent,
        elevation: 0,
        extended: isLandscape, // ممتد في الوضع الأفقي
        minExtendedWidth: 180,
        minWidth: 72,
        labelType: isLandscape 
            ? NavigationRailLabelType.none 
            : NavigationRailLabelType.all,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
          size: 26,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _buildRailLeading(context, colorScheme),
        ),
        destinations: destinations.map((item) {
          return NavigationRailDestination(
            icon: _buildNavIcon(item, false, colorScheme),
            selectedIcon: _buildNavIcon(item, true, colorScheme),
            label: Text(item.label),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRailLeading(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // شعار التطبيق أو أيقونة
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أثر',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // تخطيط الموبايل
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMobileLayout(BuildContext context, ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      appBar: appBar,
      drawer: drawer,
      body: body,
      bottomNavigationBar: showNavigation 
          ? _buildBottomNavigation(context, colorScheme)
          : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildBottomNavigation(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(destinations.length, (index) {
              final item = destinations[index];
              final isSelected = index == currentIndex;
              
              return _buildNavBarItem(
                item: item,
                isSelected: isSelected,
                colorScheme: colorScheme,
                onTap: () => onDestinationSelected(index),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required AdaptiveNavItem item,
    required bool isSelected,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.w : 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primaryContainer 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavIcon(item, isSelected, colorScheme),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Text(
                item.label,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(
    AdaptiveNavItem item, 
    bool isSelected, 
    ColorScheme colorScheme,
  ) {
    final icon = isSelected 
        ? (item.selectedIcon ?? item.icon) 
        : item.icon;
    
    return Stack(
      children: [
        Icon(
          icon,
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.onSurfaceVariant,
          size: 24.sp,
        ),
        if (item.badge != null)
          Positioned(
            right: -4,
            top: -4,
            child: item.badge!,
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // المحتوى المحدود العرض
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildConstrainedBody(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: body,
      ),
    );
  }
}
