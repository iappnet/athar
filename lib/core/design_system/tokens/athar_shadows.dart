import 'package:flutter/material.dart';

/// ===================================================================
/// ATHAR SHADOWS - Design System Shadow Tokens
/// ===================================================================
/// نظام الظلال الموحد لتطبيق أثر
/// يُستخدم للـ BoxShadow
/// ===================================================================

/// قيم الظلال الثابتة
///
/// مثال الاستخدام:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: AtharShadows.md,
///   ),
/// )
/// ```
abstract class AtharShadows {
  // ─────────────────────────────────────────────────────────────────
  // SHADOW LEVELS - مستويات الظلال
  // ─────────────────────────────────────────────────────────────────

  /// بدون ظل
  static const List<BoxShadow> none = [];

  /// ظل خفيف جداً - للـ hover states
  /// elevation: ~1
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  /// ظل خفيف - للبطاقات المرفوعة قليلاً
  /// elevation: ~2
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 2,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  /// ظل متوسط - للبطاقات العادية
  /// elevation: ~4
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// ظل كبير - للعناصر المرتفعة
  /// elevation: ~8
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  /// ظل كبير جداً - للـ modals و dialogs
  /// elevation: ~16
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  /// ظل ضخم - للعناصر العائمة
  /// elevation: ~24
  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 32,
      spreadRadius: 0,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 14,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────
  // USE CASE SHADOWS - ظلال حسب الاستخدام
  // ─────────────────────────────────────────────────────────────────

  /// للبطاقات - ظل خفيف
  static const List<BoxShadow> card = sm;

  /// للبطاقات عند الضغط - ظل أقل
  static const List<BoxShadow> cardPressed = xs;

  /// للبطاقات عند التحويم - ظل أكبر
  static const List<BoxShadow> cardHover = md;

  /// للبطاقات المرتفعة
  static const List<BoxShadow> cardElevated = md;

  /// للأزرار المرتفعة
  static const List<BoxShadow> button = sm;

  /// للأزرار عند الضغط
  static const List<BoxShadow> buttonPressed = xs;

  /// للـ FAB (Floating Action Button)
  static const List<BoxShadow> fab = lg;

  /// للـ FAB عند الضغط
  static const List<BoxShadow> fabPressed = md;

  /// للـ Bottom Navigation
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, -4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, -2),
    ),
  ];

  /// للـ App Bar
  static const List<BoxShadow> appBar = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// للـ Dialog
  static const List<BoxShadow> dialog = xl;

  /// للـ Bottom Sheet
  static const List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, -8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      spreadRadius: 0,
      offset: Offset(0, -4),
    ),
  ];

  /// للـ Drawer
  static const List<BoxShadow> drawer = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(4, 0),
    ),
  ];

  /// للـ Dropdown / Popup Menu
  static const List<BoxShadow> dropdown = md;

  /// للـ Tooltip
  static const List<BoxShadow> tooltip = sm;

  /// للـ Snackbar
  static const List<BoxShadow> snackbar = md;

  /// للصور
  static const List<BoxShadow> image = sm;

  /// للـ Avatar
  static const List<BoxShadow> avatar = sm;

  /// للـ Sticky Header
  static const List<BoxShadow> stickyHeader = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// للـ Input Focus
  static const List<BoxShadow> inputFocus = [
    BoxShadow(
      color: Color(0x291A6B3C), // Primary color with opacity
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────
  // DARK MODE SHADOWS - ظلال الوضع الداكن
  // ─────────────────────────────────────────────────────────────────

  /// ظل خفيف للوضع الداكن
  static const List<BoxShadow> darkSm = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// ظل متوسط للوضع الداكن
  static const List<BoxShadow> darkMd = [
    BoxShadow(
      color: Color(0x50000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  /// ظل كبير للوضع الداكن
  static const List<BoxShadow> darkLg = [
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────
  // COLORED SHADOWS - ظلال ملونة
  // ─────────────────────────────────────────────────────────────────

  /// إنشاء ظل ملون
  ///
  /// مثال:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     boxShadow: AtharShadows.colored(Colors.blue),
  ///   ),
  /// )
  /// ```
  static List<BoxShadow> colored(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 8,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: color.withValues(alpha: opacity * 0.5),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// ظل ملون للـ Primary
  static List<BoxShadow> get primary => colored(const Color(0xFF1A6B3C));

  /// ظل ملون للـ Success
  static List<BoxShadow> get success => colored(const Color(0xFF00B894));

  /// ظل ملون للـ Warning
  static List<BoxShadow> get warning => colored(const Color(0xFFFDCB6E));

  /// ظل ملون للـ Error
  static List<BoxShadow> get error => colored(const Color(0xFFFF7675));

  /// ظل ملون للـ Info
  static List<BoxShadow> get info => colored(const Color(0xFF74B9FF));

  // ─────────────────────────────────────────────────────────────────
  // INNER SHADOWS - ظلال داخلية
  // ─────────────────────────────────────────────────────────────────

  /// ظل داخلي خفيف
  static const List<BoxShadow> innerSm = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      spreadRadius: -2,
      offset: Offset(0, 2),
    ),
  ];

  /// ظل داخلي متوسط
  static const List<BoxShadow> innerMd = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      spreadRadius: -4,
      offset: Offset(0, 4),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────
  // HELPER METHODS - دوال مساعدة
  // ─────────────────────────────────────────────────────────────────

  /// إنشاء ظل مخصص
  static List<BoxShadow> custom({
    Color color = const Color(0x1A000000),
    double blurRadius = 8,
    double spreadRadius = 0,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: color,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        offset: offset,
      ),
    ];
  }

  /// دمج ظلين
  static List<BoxShadow> combine(
    List<BoxShadow> shadow1,
    List<BoxShadow> shadow2,
  ) {
    return [...shadow1, ...shadow2];
  }
}

// ═══════════════════════════════════════════════════════════════════════
// EXTENSION - للاستخدام مع BuildContext
// ═══════════════════════════════════════════════════════════════════════

/// Extension للوصول السهل للظلال
///
/// مثال الاستخدام:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: context.shadows.card,
///   ),
/// )
/// ```
extension AtharShadowsExtension on BuildContext {
  /// الوصول للظلال
  AtharShadowsHelper get shadows => const AtharShadowsHelper();
}

/// Helper class للوصول للظلال
///
/// ملاحظة: هذا الـ class عام (public) لأنه يُستخدم في public API
class AtharShadowsHelper {
  const AtharShadowsHelper();

  List<BoxShadow> get none => AtharShadows.none;
  List<BoxShadow> get xs => AtharShadows.xs;
  List<BoxShadow> get sm => AtharShadows.sm;
  List<BoxShadow> get md => AtharShadows.md;
  List<BoxShadow> get lg => AtharShadows.lg;
  List<BoxShadow> get xl => AtharShadows.xl;
  List<BoxShadow> get xxl => AtharShadows.xxl;
  List<BoxShadow> get card => AtharShadows.card;
  List<BoxShadow> get cardHover => AtharShadows.cardHover;
  List<BoxShadow> get button => AtharShadows.button;
  List<BoxShadow> get fab => AtharShadows.fab;
  List<BoxShadow> get dialog => AtharShadows.dialog;
  List<BoxShadow> get bottomSheet => AtharShadows.bottomSheet;
  List<BoxShadow> get dropdown => AtharShadows.dropdown;
  List<BoxShadow> get bottomNav => AtharShadows.bottomNav;
  List<BoxShadow> get appBar => AtharShadows.appBar;
}
