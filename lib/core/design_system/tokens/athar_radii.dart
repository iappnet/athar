import 'package:flutter/material.dart';

/// ===================================================================
/// ATHAR RADII - Design System Border Radius Tokens
/// ===================================================================
/// نظام الحواف الموحد لتطبيق أثر
/// يُستخدم للـ BorderRadius
/// ===================================================================

/// قيم أنصاف الأقطار (الحواف) الثابتة
///
/// مثال الاستخدام:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AtharRadii.md,
///   ),
/// )
/// ```
abstract class AtharRadii {
  // ─────────────────────────────────────────────────────────────────
  // RADIUS VALUES - قيم نصف القطر
  // ─────────────────────────────────────────────────────────────────

  /// 0 - بدون حواف
  static const double none = 0.0;

  /// 2.0 - حواف دقيقة جداً
  static const double xxxs = 2.0;

  /// 4.0 - حواف دقيقة
  static const double xxs = 4.0;

  /// 6.0 - حواف صغيرة جداً
  static const double xs = 6.0;

  /// 8.0 - حواف صغيرة
  static const double sm = 8.0;

  /// 12.0 - حواف متوسطة (الأكثر استخداماً)
  static const double md = 12.0;

  /// 16.0 - حواف كبيرة
  static const double lg = 16.0;

  /// 20.0 - حواف كبيرة جداً
  static const double xl = 20.0;

  /// 24.0 - حواف ضخمة
  static const double xxl = 24.0;

  /// 32.0 - حواف دائرية جزئياً
  static const double xxxl = 32.0;

  /// 999.0 - دائري بالكامل (للأزرار الدائرية والـ pills)
  static const double full = 999.0;

  // ─────────────────────────────────────────────────────────────────
  // BORDER RADIUS PRESETS - BorderRadius جاهزة
  // ─────────────────────────────────────────────────────────────────

  /// BorderRadius.zero - بدون حواف
  static const BorderRadius radiusNone = BorderRadius.zero;

  /// BorderRadius.circular(2)
  static const BorderRadius radiusXxxs = BorderRadius.all(
    Radius.circular(xxxs),
  );

  /// BorderRadius.circular(4)
  static const BorderRadius radiusXxs = BorderRadius.all(Radius.circular(xxs));

  /// BorderRadius.circular(6)
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));

  /// BorderRadius.circular(8)
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));

  /// BorderRadius.circular(12)
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));

  /// BorderRadius.circular(16)
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));

  /// BorderRadius.circular(20)
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));

  /// BorderRadius.circular(24)
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));

  /// BorderRadius.circular(32)
  static const BorderRadius radiusXxxl = BorderRadius.all(
    Radius.circular(xxxl),
  );

  /// BorderRadius.circular(999) - دائري بالكامل
  static const BorderRadius radiusFull = BorderRadius.all(
    Radius.circular(full),
  );

  // ─────────────────────────────────────────────────────────────────
  // USE CASE PRESETS - قوالب حسب الاستخدام
  // ─────────────────────────────────────────────────────────────────

  /// للبطاقات - BorderRadius.circular(12)
  static const BorderRadius card = radiusMd;

  /// للبطاقات الصغيرة - BorderRadius.circular(8)
  static const BorderRadius cardSmall = radiusSm;

  /// للبطاقات الكبيرة - BorderRadius.circular(16)
  static const BorderRadius cardLarge = radiusLg;

  /// للأزرار - BorderRadius.circular(8)
  static const BorderRadius button = radiusSm;

  /// للأزرار الدائرية - BorderRadius.circular(999)
  static const BorderRadius buttonRounded = radiusFull;

  /// لحقول الإدخال - BorderRadius.circular(8)
  static const BorderRadius input = radiusSm;

  /// للصور - BorderRadius.circular(12)
  static const BorderRadius image = radiusMd;

  /// للصور المصغرة - BorderRadius.circular(8)
  static const BorderRadius thumbnail = radiusSm;

  /// للـ Avatar - BorderRadius.circular(999)
  static const BorderRadius avatar = radiusFull;

  /// للـ Chips - BorderRadius.circular(999)
  static const BorderRadius chip = radiusFull;

  /// للـ Badge - BorderRadius.circular(999)
  static const BorderRadius badge = radiusFull;

  /// للـ Tooltip - BorderRadius.circular(8)
  static const BorderRadius tooltip = radiusSm;

  /// للـ Snackbar - BorderRadius.circular(8)
  static const BorderRadius snackbar = radiusSm;

  /// للـ Dialog - BorderRadius.circular(20)
  static const BorderRadius dialog = radiusXl;

  /// للـ Bottom Sheet - الحواف العلوية فقط
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );

  /// للـ Bottom Sheet الصغير
  static const BorderRadius bottomSheetSmall = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  /// للـ Modal
  static const BorderRadius modal = radiusXl;

  /// للـ Popup Menu
  static const BorderRadius popupMenu = radiusMd;

  /// للـ Dropdown
  static const BorderRadius dropdown = radiusSm;

  /// للـ FAB (Floating Action Button)
  static const BorderRadius fab = radiusLg;

  /// للـ FAB Extended
  static const BorderRadius fabExtended = radiusFull;

  /// للـ Navigation Bar items
  static const BorderRadius navItem = radiusMd;

  /// للـ Tab indicator
  static const BorderRadius tabIndicator = radiusFull;

  /// للـ Progress indicator
  static const BorderRadius progress = radiusFull;

  /// للـ Slider thumb
  static const BorderRadius sliderThumb = radiusFull;

  /// للـ Switch track
  static const BorderRadius switchTrack = radiusFull;

  // ─────────────────────────────────────────────────────────────────
  // PARTIAL RADIUS - حواف جزئية
  // ─────────────────────────────────────────────────────────────────

  /// الحواف العلوية فقط - md
  static const BorderRadius topMd = BorderRadius.only(
    topLeft: Radius.circular(md),
    topRight: Radius.circular(md),
  );

  /// الحواف العلوية فقط - lg
  static const BorderRadius topLg = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  /// الحواف العلوية فقط - xl
  static const BorderRadius topXl = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  /// الحواف السفلية فقط - md
  static const BorderRadius bottomMd = BorderRadius.only(
    bottomLeft: Radius.circular(md),
    bottomRight: Radius.circular(md),
  );

  /// الحواف السفلية فقط - lg
  static const BorderRadius bottomLg = BorderRadius.only(
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );

  /// الحواف اليمنى فقط (للـ RTL: اليسرى)
  static const BorderRadius endMd = BorderRadius.only(
    topRight: Radius.circular(md),
    bottomRight: Radius.circular(md),
  );

  /// الحواف اليسرى فقط (للـ RTL: اليمنى)
  static const BorderRadius startMd = BorderRadius.only(
    topLeft: Radius.circular(md),
    bottomLeft: Radius.circular(md),
  );

  // ─────────────────────────────────────────────────────────────────
  // HELPER METHODS - دوال مساعدة
  // ─────────────────────────────────────────────────────────────────

  /// إنشاء BorderRadius مخصص
  static BorderRadius circular(double radius) {
    return BorderRadius.all(Radius.circular(radius));
  }

  /// إنشاء BorderRadius للحواف العلوية
  static BorderRadius top(double radius) {
    return BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
  }

  /// إنشاء BorderRadius للحواف السفلية
  static BorderRadius bottom(double radius) {
    return BorderRadius.only(
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
  }

  /// إنشاء BorderRadius للحواف اليسرى
  static BorderRadius left(double radius) {
    return BorderRadius.only(
      topLeft: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
    );
  }

  /// إنشاء BorderRadius للحواف اليمنى
  static BorderRadius right(double radius) {
    return BorderRadius.only(
      topRight: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
  }

  /// إنشاء BorderRadius مخصص لكل زاوية
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// EXTENSION - للاستخدام مع BuildContext
// ═══════════════════════════════════════════════════════════════════════

/// Extension للوصول السهل للحواف
///
/// مثال الاستخدام:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: context.radii.card,
///   ),
/// )
/// ```
extension AtharRadiiExtension on BuildContext {
  /// الوصول لقيم الحواف
  AtharRadiiHelper get radii => const AtharRadiiHelper();
}

/// Helper class للوصول للحواف
///
/// ملاحظة: هذا الـ class عام (public) لأنه يُستخدم في public API
class AtharRadiiHelper {
  const AtharRadiiHelper();

  // القيم
  double get none => AtharRadii.none;
  double get xxs => AtharRadii.xxs;
  double get xs => AtharRadii.xs;
  double get sm => AtharRadii.sm;
  double get md => AtharRadii.md;
  double get lg => AtharRadii.lg;
  double get xl => AtharRadii.xl;
  double get xxl => AtharRadii.xxl;
  double get xxxl => AtharRadii.xxxl;
  double get full => AtharRadii.full;

  // BorderRadius
  BorderRadius get radiusSm => AtharRadii.radiusSm;
  BorderRadius get radiusMd => AtharRadii.radiusMd;
  BorderRadius get radiusLg => AtharRadii.radiusLg;
  BorderRadius get radiusXl => AtharRadii.radiusXl;
  BorderRadius get radiusFull => AtharRadii.radiusFull;
  BorderRadius get card => AtharRadii.card;
  BorderRadius get button => AtharRadii.button;
  BorderRadius get input => AtharRadii.input;
  BorderRadius get dialog => AtharRadii.dialog;
  BorderRadius get bottomSheet => AtharRadii.bottomSheet;
  BorderRadius get avatar => AtharRadii.avatar;
  BorderRadius get chip => AtharRadii.chip;
}
