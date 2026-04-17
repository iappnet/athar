// lib/core/utils/responsive_helper.dart
// ✅ أداة مساعدة للتصميم المتجاوب - النسخة المحسّنة

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أنواع الأجهزة المدعومة
enum DeviceType {
  mobile, // هاتف (< 600)
  tablet, // آيباد / تابلت (600 - 1200)
  desktop, // سطح المكتب (> 1200)
}

/// أحجام الشاشة التفصيلية
enum ScreenSize {
  small, // < 360
  medium, // 360 - 600
  large, // 600 - 900
  xlarge, // > 900
}

/// أداة مساعدة للتصميم المتجاوب
class ResponsiveHelper {
  // ═══════════════════════════════════════════════════════════════════
  // الثوابت - Breakpoints
  // ═══════════════════════════════════════════════════════════════════

  /// الحد الأدنى لعرض التابلت
  static const double tabletBreakpoint = 600;

  /// الحد الأدنى لعرض الديسكتوب
  static const double desktopBreakpoint = 1200;

  /// أقصى عرض للمحتوى الرئيسي
  static const double maxContentWidth = 900;

  /// أقصى عرض للفورم
  static const double maxFormWidth = 450;

  /// أقصى عرض للكارد
  static const double maxCardWidth = 500;

  /// أقصى عرض للـ Dialog
  static const double maxDialogWidth = 400;

  // ═══════════════════════════════════════════════════════════════════
  // التحقق من نوع الجهاز
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على نوع الجهاز (يستخدم shortestSide للدقة)
  static DeviceType getDeviceType(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final width = MediaQuery.of(context).size.width;

    // استخدام shortestSide للتابلت (يعمل في كل الاتجاهات)
    if (shortestSide >= tabletBreakpoint) {
      if (width >= desktopBreakpoint) {
        return DeviceType.desktop;
      }
      return DeviceType.tablet;
    }
    return DeviceType.mobile;
  }

  /// الحصول على حجم الشاشة التفصيلي
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return ScreenSize.small;
    if (width < 600) return ScreenSize.medium;
    if (width < 900) return ScreenSize.large;
    return ScreenSize.xlarge;
  }

  /// هل الجهاز تابلت؟
  static bool isTablet(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.tablet || type == DeviceType.desktop;
  }

  /// هل الجهاز موبايل؟
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// هل الجهاز ديسكتوب؟
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// هل الشاشة أفقية؟
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// هل الشاشة عمودية؟
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // ═══════════════════════════════════════════════════════════════════
  // الأبعاد
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على عرض الشاشة
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// الحصول على ارتفاع الشاشة
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// الحصول على أقصر بُعد (للـ rotation)
  static double shortestSide(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide;
  }

  /// الحصول على أطول بُعد
  static double longestSide(BuildContext context) {
    return MediaQuery.of(context).size.longestSide;
  }

  /// الحصول على نسبة العرض للارتفاع
  static double aspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }

  // ═══════════════════════════════════════════════════════════════════
  // القيود (Constraints)
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على أقصى عرض للمحتوى
  static double getMaxContentWidth(BuildContext context) {
    if (isTablet(context)) {
      return maxContentWidth;
    }
    return double.infinity;
  }

  /// الحصول على أقصى عرض للفورم
  static double getMaxFormWidth(BuildContext context) {
    if (isTablet(context)) {
      return maxFormWidth;
    }
    return double.infinity;
  }

  /// الحصول على أقصى عرض للـ Dialog
  static double getMaxDialogWidth(BuildContext context) {
    final width = screenWidth(context);
    if (isTablet(context)) {
      return maxDialogWidth;
    }
    return width * 0.9;
  }

  /// الحصول على عرض الكارد المناسب
  static double getCardWidth(BuildContext context, {int columns = 2}) {
    if (!isTablet(context)) return double.infinity;

    final availableWidth = screenWidth(context) - 100; // للـ NavigationRail
    final spacing = 16.0 * (columns - 1);
    return (availableWidth - spacing) / columns;
  }

  // ═══════════════════════════════════════════════════════════════════
  // الشبكة (Grid)
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على عدد الأعمدة في الشبكة
  static int getGridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return desktop;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// الحصول على نسبة العرض للارتفاع للكارد
  static double getCardAspectRatio(
    BuildContext context, {
    double mobile = 1.0,
    double tablet = 1.2,
  }) {
    if (isTablet(context)) {
      return tablet;
    }
    return mobile;
  }

  // ═══════════════════════════════════════════════════════════════════
  // المسافات (Spacing)
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على الـ padding المناسب للشاشة
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    return EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h);
  }

  /// الحصول على الـ padding المناسب للكارد
  static EdgeInsets getCardPadding(BuildContext context) {
    if (isTablet(context)) {
      return const EdgeInsets.all(20);
    }
    return EdgeInsets.all(16.w);
  }

  /// الحصول على المسافة بين العناصر
  static double getSpacing(
    BuildContext context, {
    double mobile = 12,
    double tablet = 16,
    double desktop = 20,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return desktop;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// الحصول على المسافة الصغيرة
  static double getSmallSpacing(BuildContext context) {
    return getSpacing(context, mobile: 8, tablet: 10, desktop: 12);
  }

  /// الحصول على المسافة الكبيرة
  static double getLargeSpacing(BuildContext context) {
    return getSpacing(context, mobile: 20, tablet: 28, desktop: 36);
  }

  // ═══════════════════════════════════════════════════════════════════
  // الخطوط (Typography)
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على حجم الخط
  static double getFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    double? desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// الحصول على حجم العنوان الرئيسي
  static double getTitleSize(BuildContext context) {
    return getFontSize(context, mobile: 18.sp, tablet: 22, desktop: 24);
  }

  /// الحصول على حجم العنوان الفرعي
  static double getSubtitleSize(BuildContext context) {
    return getFontSize(context, mobile: 14.sp, tablet: 16, desktop: 18);
  }

  /// الحصول على حجم النص العادي
  static double getBodySize(BuildContext context) {
    return getFontSize(context, mobile: 14.sp, tablet: 15, desktop: 16);
  }

  /// الحصول على حجم النص الصغير
  static double getCaptionSize(BuildContext context) {
    return getFontSize(context, mobile: 12.sp, tablet: 13, desktop: 14);
  }

  // ═══════════════════════════════════════════════════════════════════
  // الأيقونات
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على حجم الأيقونة
  static double getIconSize(
    BuildContext context, {
    double mobile = 24,
    double tablet = 28,
    double desktop = 32,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return desktop;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.mobile:
        return mobile.sp;
    }
  }

  /// الحصول على حجم الأيقونة الصغيرة
  static double getSmallIconSize(BuildContext context) {
    return getIconSize(context, mobile: 18, tablet: 20, desktop: 22);
  }

  /// الحصول على حجم الأيقونة الكبيرة
  static double getLargeIconSize(BuildContext context) {
    return getIconSize(context, mobile: 32, tablet: 40, desktop: 48);
  }

  // ═══════════════════════════════════════════════════════════════════
  // الأزرار
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على ارتفاع الزر
  static double getButtonHeight(BuildContext context) {
    if (isTablet(context)) return 52;
    return 48.h;
  }

  /// الحصول على حجم الـ FAB
  static double getFabSize(BuildContext context) {
    if (isTablet(context)) return 64;
    return 56.w;
  }

  /// الحصول على نصف قطر الحدود
  static double getBorderRadius(
    BuildContext context, {
    double mobile = 12,
    double tablet = 16,
  }) {
    if (isTablet(context)) return tablet;
    return mobile;
  }

  // ═══════════════════════════════════════════════════════════════════
  // بناء مشروط (Conditional Building)
  // ═══════════════════════════════════════════════════════════════════

  /// بناء widget مختلف حسب نوع الجهاز
  static Widget buildResponsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// تنفيذ كود مختلف حسب نوع الجهاز
  static T valueByDevice<T>({
    required BuildContext context,
    required T mobile,
    required T tablet,
    T? desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// تنفيذ callback حسب نوع الجهاز
  static void executeByDevice({
    required BuildContext context,
    VoidCallback? onMobile,
    VoidCallback? onTablet,
    VoidCallback? onDesktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        onDesktop?.call();
        break;
      case DeviceType.tablet:
        onTablet?.call();
        break;
      case DeviceType.mobile:
        onMobile?.call();
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Navigation
  // ═══════════════════════════════════════════════════════════════════

  /// هل نستخدم NavigationRail؟
  static bool useNavigationRail(BuildContext context) {
    return isTablet(context);
  }

  /// هل نستخدم Drawer؟
  static bool useDrawer(BuildContext context) {
    return isMobile(context);
  }

  /// الحصول على عرض الـ NavigationRail
  static double getNavigationRailWidth(BuildContext context) {
    if (isLandscape(context) && isTablet(context)) {
      return 200; // extended
    }
    return 72; // compact
  }

  // ═══════════════════════════════════════════════════════════════════
  // Safe Area
  // ═══════════════════════════════════════════════════════════════════

  /// الحصول على الـ padding الآمن
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// الحصول على ارتفاع الـ Status Bar
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// الحصول على ارتفاع الـ Bottom Bar
  static double getBottomBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
}

// ═══════════════════════════════════════════════════════════════════
// Extensions للسهولة
// ═══════════════════════════════════════════════════════════════════

extension ResponsiveContext on BuildContext {
  // نوع الجهاز
  DeviceType get deviceType => ResponsiveHelper.getDeviceType(this);
  ScreenSize get screenSize => ResponsiveHelper.getScreenSize(this);

  // التحقق
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  bool get isPortrait => ResponsiveHelper.isPortrait(this);

  // الأبعاد
  double get screenWidth => ResponsiveHelper.screenWidth(this);
  double get screenHeight => ResponsiveHelper.screenHeight(this);
  double get shortestSide => ResponsiveHelper.shortestSide(this);

  // القيود
  double get maxContentWidth => ResponsiveHelper.getMaxContentWidth(this);
  double get maxFormWidth => ResponsiveHelper.getMaxFormWidth(this);

  // المسافات
  EdgeInsets get screenPadding => ResponsiveHelper.getScreenPadding(this);
  EdgeInsets get cardPadding => ResponsiveHelper.getCardPadding(this);
  double get spacing => ResponsiveHelper.getSpacing(this);
  double get smallSpacing => ResponsiveHelper.getSmallSpacing(this);
  double get largeSpacing => ResponsiveHelper.getLargeSpacing(this);

  // الخطوط
  double get titleSize => ResponsiveHelper.getTitleSize(this);
  double get subtitleSize => ResponsiveHelper.getSubtitleSize(this);
  double get bodySize => ResponsiveHelper.getBodySize(this);
  double get captionSize => ResponsiveHelper.getCaptionSize(this);

  // الأيقونات
  double get iconSize => ResponsiveHelper.getIconSize(this);
  double get smallIconSize => ResponsiveHelper.getSmallIconSize(this);
  double get largeIconSize => ResponsiveHelper.getLargeIconSize(this);

  // الأزرار
  double get buttonHeight => ResponsiveHelper.getButtonHeight(this);
  double get fabSize => ResponsiveHelper.getFabSize(this);

  // Navigation
  bool get useNavigationRail => ResponsiveHelper.useNavigationRail(this);
  bool get useDrawer => ResponsiveHelper.useDrawer(this);
  double get navigationRailWidth =>
      ResponsiveHelper.getNavigationRailWidth(this);

  // Grid
  int gridColumns({int mobile = 1, int tablet = 2, int desktop = 3}) =>
      ResponsiveHelper.getGridColumns(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}

// ═══════════════════════════════════════════════════════════════════
// Widget مساعد للبناء المشروط
// ═══════════════════════════════════════════════════════════════════

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, context.deviceType);
  }
}

/// Widget لبناء مختلف حسب الجهاز
class DeviceBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const DeviceBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.buildResponsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

// // lib/core/utils/responsive_helper.dart
// // ✅ أداة مساعدة للتصميم المتجاوب

// import 'package:flutter/material.dart';

// /// أنواع الأجهزة المدعومة
// enum DeviceType {
//   mobile,   // هاتف
//   tablet,   // آيباد / تابلت
// }

// /// أداة مساعدة للتصميم المتجاوب
// class ResponsiveHelper {
//   // ═══════════════════════════════════════════════════════════════════
//   // الثوابت
//   // ═══════════════════════════════════════════════════════════════════

//   /// الحد الأدنى لعرض التابلت
//   static const double tabletBreakpoint = 600;

//   /// الحد الأدنى لعرض الديسكتوب
//   static const double desktopBreakpoint = 1200;

//   /// أقصى عرض للمحتوى في التابلت
//   static const double maxContentWidth = 600;

//   /// أقصى عرض للفورم
//   static const double maxFormWidth = 450;

//   /// أقصى عرض للكارد
//   static const double maxCardWidth = 500;

//   // ═══════════════════════════════════════════════════════════════════
//   // التحقق من نوع الجهاز
//   // ═══════════════════════════════════════════════════════════════════

//   /// الحصول على نوع الجهاز
//   static DeviceType getDeviceType(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     if (width >= tabletBreakpoint) {
//       return DeviceType.tablet;
//     }
//     return DeviceType.mobile;
//   }

//   /// هل الجهاز تابلت؟
//   static bool isTablet(BuildContext context) {
//     return getDeviceType(context) == DeviceType.tablet;
//   }

//   /// هل الجهاز موبايل؟
//   static bool isMobile(BuildContext context) {
//     return getDeviceType(context) == DeviceType.mobile;
//   }

//   /// هل الشاشة أفقية؟
//   static bool isLandscape(BuildContext context) {
//     return MediaQuery.of(context).orientation == Orientation.landscape;
//   }

//   // ═══════════════════════════════════════════════════════════════════
//   // الأبعاد الديناميكية
//   // ═══════════════════════════════════════════════════════════════════

//   /// الحصول على عرض الشاشة
//   static double screenWidth(BuildContext context) {
//     return MediaQuery.of(context).size.width;
//   }

//   /// الحصول على ارتفاع الشاشة
//   static double screenHeight(BuildContext context) {
//     return MediaQuery.of(context).size.height;
//   }

//   /// الحصول على أقصى عرض للمحتوى
//   static double getMaxContentWidth(BuildContext context) {
//     if (isTablet(context)) {
//       return maxContentWidth;
//     }
//     return double.infinity;
//   }

//   /// الحصول على أقصى عرض للفورم
//   static double getMaxFormWidth(BuildContext context) {
//     if (isTablet(context)) {
//       return maxFormWidth;
//     }
//     return double.infinity;
//   }

//   /// الحصول على عدد الأعمدة في الشبكة
//   static int getGridCrossAxisCount(BuildContext context, {int mobileCount = 1, int tabletCount = 2}) {
//     if (isTablet(context)) {
//       return tabletCount;
//     }
//     return mobileCount;
//   }

//   /// الحصول على الـ padding المناسب
//   static EdgeInsets getScreenPadding(BuildContext context) {
//     if (isTablet(context)) {
//       return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
//     }
//     return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
//   }

//   /// الحصول على حجم الخط المناسب
//   static double getFontSize(BuildContext context, {required double mobile, required double tablet}) {
//     if (isTablet(context)) {
//       return tablet;
//     }
//     return mobile;
//   }

//   // ═══════════════════════════════════════════════════════════════════
//   // بناء مشروط
//   // ═══════════════════════════════════════════════════════════════════

//   /// بناء widget مختلف حسب نوع الجهاز
//   static Widget buildResponsive({
//     required BuildContext context,
//     required Widget mobile,
//     Widget? tablet,
//   }) {
//     if (isTablet(context) && tablet != null) {
//       return tablet;
//     }
//     return mobile;
//   }

//   /// تنفيذ كود مختلف حسب نوع الجهاز
//   static T valueByDevice<T>({
//     required BuildContext context,
//     required T mobile,
//     required T tablet,
//   }) {
//     if (isTablet(context)) {
//       return tablet;
//     }
//     return mobile;
//   }
// }

// // ═══════════════════════════════════════════════════════════════════
// // Extension للسهولة
// // ═══════════════════════════════════════════════════════════════════

// extension ResponsiveContext on BuildContext {
//   bool get isTablet => ResponsiveHelper.isTablet(this);
//   bool get isMobile => ResponsiveHelper.isMobile(this);
//   bool get isLandscape => ResponsiveHelper.isLandscape(this);
//   double get screenWidth => ResponsiveHelper.screenWidth(this);
//   double get screenHeight => ResponsiveHelper.screenHeight(this);
//   DeviceType get deviceType => ResponsiveHelper.getDeviceType(this);
// }
