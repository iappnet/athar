// lib/core/design_system/widgets/liquid_glass_nav_bar.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 🔮 Liquid Glass Navigation Bar
// تصميم عصري مستوحى من iOS 18 / visionOS
// ═══════════════════════════════════════════════════════════════════════════════
// المميزات:
// ✅ Glassmorphism مع BackdropFilter
// ✅ Pill-shaped container
// ✅ أيقونات Outline/Filled
// ✅ زر FAB منفصل على اليمين
// ✅ إخفاء عند التمرير (اختياري)
// ✅ دعم RTL للعربية
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens/athar_animations.dart';

/// عنصر التنقل
class LiquidNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? badge;

  const LiquidNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge,
  });
}

/// شريط التنقل الزجاجي
class LiquidGlassNavBar extends StatefulWidget {
  /// العناصر
  final List<LiquidNavItem> items;

  /// الفهرس الحالي
  final int currentIndex;

  /// عند تغيير التبويب
  final ValueChanged<int> onTap;

  /// عند الضغط على زر الإضافة
  final VoidCallback onFabPressed;

  /// لون زر الإضافة
  final Color? fabColor;

  /// أيقونة زر الإضافة
  final IconData fabIcon;

  /// إخفاء عند التمرير
  final bool hideOnScroll;

  /// ScrollController للتحكم في الإخفاء
  final ScrollController? scrollController;

  /// شفافية الخلفية (0.0 - 1.0)
  final double backgroundOpacity;

  /// قوة الـ blur
  final double blurSigma;

  const LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
    this.fabColor,
    this.fabIcon = Icons.add,
    this.hideOnScroll = false,
    this.scrollController,
    this.backgroundOpacity = 0.7,
    this.blurSigma = 20.0,
  });

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _hideController;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();

    _hideController = AnimationController(
      duration: AtharAnimations.normalSlow,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1.5)).animate(
          CurvedAnimation(
            parent: _hideController,
            curve: AtharAnimations.smooth,
          ),
        );

    if (widget.hideOnScroll && widget.scrollController != null) {
      widget.scrollController!.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (!widget.hideOnScroll) return;

    final currentPosition = widget.scrollController!.position.pixels;
    final maxPosition = widget.scrollController!.position.maxScrollExtent;

    // لا تخفي إذا كان المحتوى قصير
    if (maxPosition < 100) return;

    // تمرير للأسفل = إخفاء
    if (currentPosition > _lastScrollPosition + 10 && _isVisible) {
      _hideController.forward();
      _isVisible = false;
    }
    // تمرير للأعلى = إظهار
    else if (currentPosition < _lastScrollPosition - 10 && !_isVisible) {
      _hideController.reverse();
      _isVisible = true;
    }

    _lastScrollPosition = currentPosition;
  }

  @override
  void dispose() {
    _hideController.dispose();
    if (widget.hideOnScroll && widget.scrollController != null) {
      widget.scrollController!.removeListener(_onScroll);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassBackground = Colors.white.withValues(alpha: 0.64);
    final glassBorder = Colors.white.withValues(alpha: 0.9);
    final iconColor = const Color(0xFFB1B1B8);
    final selectedIconColor = isDark
        ? Colors.white.withValues(alpha: 0.96)
        : const Color(0xFF8D8D93);

    return SlideTransition(
      position: _slideAnimation,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // ═══════════════════════════════════════════════════════════════
              // Pill-shaped Navigation Bar
              // ═══════════════════════════════════════════════════════════════
              Expanded(
                child: ClipRRect(
                  borderRadius: AtharRadii.radiusXxxl,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blurSigma + 14,
                      sigmaY: widget.blurSigma + 14,
                    ),
                    child: Container(
                      height: 66.h,
                      decoration: BoxDecoration(
                        color: glassBackground,
                        borderRadius: AtharRadii.radiusXxxl,
                        border: Border.all(color: glassBorder, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.55),
                            blurRadius: 12,
                            spreadRadius: -2,
                            offset: const Offset(0, -1),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 30,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 1.h,
                            left: 18.w,
                            right: 18.w,
                            child: IgnorePointer(
                              child: Container(
                                height: 1.4.h,
                                decoration: BoxDecoration(
                                  borderRadius: AtharRadii.radiusFull,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0),
                                      Colors.white.withValues(alpha: 0.42),
                                      Colors.white.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: AtharRadii.radiusXxxl,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.42),
                                      Colors.white.withValues(alpha: 0.14),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              widget.items.length,
                              (index) => _buildNavItem(
                                context,
                                widget.items[index],
                                index,
                                colorScheme,
                                isDark,
                                iconColor,
                                selectedIconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // المسافة بين الشريط والزر
              AtharGap.hMd,

              // ═══════════════════════════════════════════════════════════════
              // Floating Action Button
              // ═══════════════════════════════════════════════════════════════
              _buildFab(context, colorScheme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    LiquidNavItem item,
    int index,
    ColorScheme colorScheme,
    bool isDark,
    Color iconColor,
    Color selectedIconColor,
  ) {
    final isSelected = index == widget.currentIndex;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.w : 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.38))
              : Colors.transparent,
          borderRadius: AtharRadii.radiusXl,
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.7))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الأيقونة
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? selectedIconColor : iconColor,
                    size: 24.sp,
                  ),
                  // Badge
                  if (item.badge != null)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: AtharRadii.radiusMd,
                        ),
                        child: Text(
                          item.badge!,
                          style: TextStyle(
                            color: colorScheme.onError,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Label (يظهر فقط عند الاختيار)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: selectedIconColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context, ColorScheme colorScheme, bool isDark) {
    final fabTop = const Color(0xFF1A6B3C);
    final fabMid = const Color(0xFF156035);
    final fabBottom = const Color(0xFF0D7377);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onFabPressed();
      },
      child: Container(
        width: 66.w,
        height: 66.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [fabTop, fabMid, fabBottom],
            stops: const [0.0, 0.42, 1.0],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A6B3C).withValues(alpha: 0.45),
              blurRadius: 28,
              spreadRadius: 0,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.48),
              blurRadius: 0,
              spreadRadius: 0,
              offset: const Offset(-2, -2),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.62),
            width: 1.4,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 10.h,
              child: Container(
                width: 28.w,
                height: 10.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.58),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                  borderRadius: AtharRadii.radiusXxs,
                ),
              ),
            ),
            Icon(widget.fabIcon, color: const Color(0xFFFFF7D6), size: 34.sp),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// أيقونات مخصصة للتطبيق
// ═══════════════════════════════════════════════════════════════════════════════

/// أيقونات الـ Navigation مع حالتي Outline و Filled
class AtharNavIcons {
  // Dashboard / Home
  static const IconData homeOutline = Icons.home_outlined;
  static const IconData homeFilled = Icons.home_rounded;

  // Tasks
  static const IconData tasksOutline = Icons.check_circle_outline_rounded;
  static const IconData tasksFilled = Icons.check_circle_rounded;

  // Habits
  static const IconData habitsOutline = Icons.track_changes_outlined;
  static const IconData habitsFilled = Icons.track_changes_rounded;

  // Spaces
  static const IconData spacesOutline = Icons.workspaces_outline;
  static const IconData spacesFilled = Icons.workspaces_rounded;

  // Alternative icons (briefcase style like in the image)
  static const IconData briefcaseOutline = Icons.work_outline_rounded;
  static const IconData briefcaseFilled = Icons.work_rounded;

  // Profile
  static const IconData profileOutline = Icons.person_outline_rounded;
  static const IconData profileFilled = Icons.person_rounded;

  // Chat/Messages
  static const IconData chatOutline = Icons.chat_bubble_outline_rounded;
  static const IconData chatFilled = Icons.chat_bubble_rounded;
}
