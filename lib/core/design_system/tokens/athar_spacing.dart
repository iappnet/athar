import 'package:flutter/material.dart';

/// ===================================================================
/// ATHAR SPACING - Design System Spacing Tokens
/// ===================================================================
/// نظام المسافات الموحد لتطبيق أثر
/// يُستخدم للـ padding, margin, gap
/// ===================================================================

/// قيم المسافات الثابتة
///
/// مثال الاستخدام:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(AtharSpacing.md),
///   child: Text('مرحباً'),
/// )
/// ```
abstract class AtharSpacing {
  // ─────────────────────────────────────────────────────────────────
  // SPACING VALUES - قيم المسافات
  // ─────────────────────────────────────────────────────────────────

  /// 2.0 - مسافة دقيقة جداً
  static const double xxxs = 2.0;

  /// 4.0 - مسافة دقيقة
  static const double xxs = 4.0;

  /// 6.0 - مسافة صغيرة جداً
  static const double xs = 6.0;

  /// 8.0 - مسافة صغيرة
  static const double sm = 8.0;

  /// 12.0 - مسافة متوسطة صغيرة
  static const double md = 12.0;

  /// 16.0 - مسافة متوسطة (الأكثر استخداماً)
  static const double lg = 16.0;

  /// 20.0 - مسافة كبيرة
  static const double xl = 20.0;

  /// 24.0 - مسافة كبيرة جداً
  static const double xxl = 24.0;

  /// 32.0 - مسافة ضخمة
  static const double xxxl = 32.0;

  /// 40.0 - مسافة ضخمة جداً
  static const double huge = 40.0;

  /// 48.0 - مسافة عملاقة
  static const double massive = 48.0;

  /// 64.0 - مسافة قسم
  static const double section = 64.0;

  // ─────────────────────────────────────────────────────────────────
  // EDGE INSETS PRESETS - قوالب EdgeInsets جاهزة
  // ─────────────────────────────────────────────────────────────────

  /// padding: 0
  static const EdgeInsets zero = EdgeInsets.zero;

  /// padding: 2 من جميع الاتجاهات
  static const EdgeInsets allXxxs = EdgeInsets.all(xxxs);

  /// padding: 4 من جميع الاتجاهات
  static const EdgeInsets allXxs = EdgeInsets.all(xxs);

  /// padding: 6 من جميع الاتجاهات
  static const EdgeInsets allXs = EdgeInsets.all(xs);

  /// padding: 8 من جميع الاتجاهات
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// padding: 12 من جميع الاتجاهات
  static const EdgeInsets allMd = EdgeInsets.all(md);

  /// padding: 16 من جميع الاتجاهات
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// padding: 20 من جميع الاتجاهات
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// padding: 24 من جميع الاتجاهات
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  /// padding: 32 من جميع الاتجاهات
  static const EdgeInsets allXxxl = EdgeInsets.all(xxxl);

  // ─────────────────────────────────────────────────────────────────
  // HORIZONTAL PRESETS - مسافات أفقية
  // ─────────────────────────────────────────────────────────────────

  /// horizontal: 4
  static const EdgeInsets horizontalXxs = EdgeInsets.symmetric(horizontal: xxs);

  /// horizontal: 8
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// horizontal: 12
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// horizontal: 16
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// horizontal: 24
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);

  /// horizontal: 32
  static const EdgeInsets horizontalXxxl = EdgeInsets.symmetric(
    horizontal: xxxl,
  );

  // ─────────────────────────────────────────────────────────────────
  // VERTICAL PRESETS - مسافات رأسية
  // ─────────────────────────────────────────────────────────────────

  /// vertical: 4
  static const EdgeInsets verticalXxs = EdgeInsets.symmetric(vertical: xxs);

  /// vertical: 8
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  /// vertical: 12
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  /// vertical: 16
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  /// vertical: 24
  static const EdgeInsets verticalXxl = EdgeInsets.symmetric(vertical: xxl);

  /// vertical: 32
  static const EdgeInsets verticalXxxl = EdgeInsets.symmetric(vertical: xxxl);

  // ─────────────────────────────────────────────────────────────────
  // USE CASE PRESETS - قوالب حسب الاستخدام
  // ─────────────────────────────────────────────────────────────────

  /// للبطاقات: horizontal: 16, vertical: 12
  static const EdgeInsets card = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// للبطاقات الصغيرة: horizontal: 12, vertical: 8
  static const EdgeInsets cardSmall = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// للبطاقات الكبيرة: horizontal: 20, vertical: 16
  static const EdgeInsets cardLarge = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );

  /// لعناصر القائمة: horizontal: 16, vertical: 12
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// للصفحات: horizontal: 16, vertical: 24
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: xxl,
  );

  /// للصفحات (أفقي فقط): horizontal: 16
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: lg);

  /// للأزرار: horizontal: 24, vertical: 12
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: xxl,
    vertical: md,
  );

  /// للأزرار الصغيرة: horizontal: 16, vertical: 8
  static const EdgeInsets buttonSmall = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );

  /// للأزرار الكبيرة: horizontal: 32, vertical: 16
  static const EdgeInsets buttonLarge = EdgeInsets.symmetric(
    horizontal: xxxl,
    vertical: lg,
  );

  /// لحقول الإدخال: horizontal: 16, vertical: 12
  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// للـ Dialog: all: 24
  static const EdgeInsets dialog = EdgeInsets.all(xxl);

  /// للـ Bottom Sheet: horizontal: 16, top: 24, bottom: 32
  static const EdgeInsets bottomSheet = EdgeInsets.only(
    left: lg,
    right: lg,
    top: xxl,
    bottom: xxxl,
  );

  /// للـ App Bar title: horizontal: 16
  static const EdgeInsets appBarTitle = EdgeInsets.symmetric(horizontal: lg);

  /// للـ Chips: horizontal: 12, vertical: 6
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: md,
    vertical: xs,
  );

  /// للـ Badge: horizontal: 8, vertical: 4
  static const EdgeInsets badge = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xxs,
  );

  /// للـ Tooltip: horizontal: 12, vertical: 8
  static const EdgeInsets tooltip = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// للـ Snackbar: horizontal: 16, vertical: 14
  static const EdgeInsets snackbar = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: 14,
  );
}

// ═══════════════════════════════════════════════════════════════════════
// ATHAR GAP - SizedBox مسبقة التعريف
// ═══════════════════════════════════════════════════════════════════════

/// SizedBox مسبقة التعريف للمسافات العمودية والأفقية
///
/// مثال الاستخدام:
/// ```dart
/// Column(
///   children: [
///     Text('عنوان'),
///     AtharGap.md,  // مسافة 12
///     Text('محتوى'),
///     AtharGap.lg,  // مسافة 16
///     ElevatedButton(...),
///   ],
/// )
/// ```
class AtharGap {
  AtharGap._(); // منع إنشاء instance

  // ─────────────────────────────────────────────────────────────────
  // VERTICAL GAPS - مسافات عمودية
  // ─────────────────────────────────────────────────────────────────

  /// SizedBox(height: 2)
  static const SizedBox xxxs = SizedBox(height: AtharSpacing.xxxs);

  /// SizedBox(height: 4)
  static const SizedBox xxs = SizedBox(height: AtharSpacing.xxs);

  /// SizedBox(height: 6)
  static const SizedBox xs = SizedBox(height: AtharSpacing.xs);

  /// SizedBox(height: 8)
  static const SizedBox sm = SizedBox(height: AtharSpacing.sm);

  /// SizedBox(height: 12)
  static const SizedBox md = SizedBox(height: AtharSpacing.md);

  /// SizedBox(height: 16)
  static const SizedBox lg = SizedBox(height: AtharSpacing.lg);

  /// SizedBox(height: 20)
  static const SizedBox xl = SizedBox(height: AtharSpacing.xl);

  /// SizedBox(height: 24)
  static const SizedBox xxl = SizedBox(height: AtharSpacing.xxl);

  /// SizedBox(height: 32)
  static const SizedBox xxxl = SizedBox(height: AtharSpacing.xxxl);

  /// SizedBox(height: 40)
  static const SizedBox huge = SizedBox(height: AtharSpacing.huge);

  /// SizedBox(height: 48)
  static const SizedBox massive = SizedBox(height: AtharSpacing.massive);

  /// SizedBox(height: 64)
  static const SizedBox section = SizedBox(height: AtharSpacing.section);

  // ─────────────────────────────────────────────────────────────────
  // HORIZONTAL GAPS - مسافات أفقية
  // ─────────────────────────────────────────────────────────────────

  /// SizedBox(width: 2)
  static const SizedBox hXxxs = SizedBox(width: AtharSpacing.xxxs);

  /// SizedBox(width: 4)
  static const SizedBox hXxs = SizedBox(width: AtharSpacing.xxs);

  /// SizedBox(width: 6)
  static const SizedBox hXs = SizedBox(width: AtharSpacing.xs);

  /// SizedBox(width: 8)
  static const SizedBox hSm = SizedBox(width: AtharSpacing.sm);

  /// SizedBox(width: 12)
  static const SizedBox hMd = SizedBox(width: AtharSpacing.md);

  /// SizedBox(width: 16)
  static const SizedBox hLg = SizedBox(width: AtharSpacing.lg);

  /// SizedBox(width: 20)
  static const SizedBox hXl = SizedBox(width: AtharSpacing.xl);

  /// SizedBox(width: 24)
  static const SizedBox hXxl = SizedBox(width: AtharSpacing.xxl);

  /// SizedBox(width: 32)
  static const SizedBox hXxxl = SizedBox(width: AtharSpacing.xxxl);

  /// SizedBox(width: 40)
  static const SizedBox hHuge = SizedBox(width: AtharSpacing.huge);

  /// SizedBox(width: 48)
  static const SizedBox hMassive = SizedBox(width: AtharSpacing.massive);

  // ─────────────────────────────────────────────────────────────────
  // DYNAMIC GAPS - مسافات ديناميكية
  // ─────────────────────────────────────────────────────────────────

  /// إنشاء مسافة عمودية بقيمة محددة
  static SizedBox vertical(double height) => SizedBox(height: height);

  /// إنشاء مسافة أفقية بقيمة محددة
  static SizedBox horizontal(double width) => SizedBox(width: width);

  /// إنشاء مسافة مربعة
  static SizedBox square(double size) => SizedBox(width: size, height: size);
}

// ═══════════════════════════════════════════════════════════════════════
// EXTENSION - للاستخدام مع BuildContext
// ═══════════════════════════════════════════════════════════════════════

/// Extension للوصول السهل للمسافات
///
/// مثال الاستخدام:
/// ```dart
/// Padding(
///   padding: context.spacing.allLg,
///   child: Text('مرحباً'),
/// )
/// ```
extension AtharSpacingExtension on BuildContext {
  /// الوصول لقيم المسافات
  AtharSpacingHelper get spacing => const AtharSpacingHelper();
}

/// Helper class للوصول للمسافات
///
/// ملاحظة: هذا الـ class عام (public) لأنه يُستخدم في public API
class AtharSpacingHelper {
  const AtharSpacingHelper();

  // القيم
  double get xxxs => AtharSpacing.xxxs;
  double get xxs => AtharSpacing.xxs;
  double get xs => AtharSpacing.xs;
  double get sm => AtharSpacing.sm;
  double get md => AtharSpacing.md;
  double get lg => AtharSpacing.lg;
  double get xl => AtharSpacing.xl;
  double get xxl => AtharSpacing.xxl;
  double get xxxl => AtharSpacing.xxxl;
  double get huge => AtharSpacing.huge;
  double get massive => AtharSpacing.massive;
  double get section => AtharSpacing.section;

  // EdgeInsets
  EdgeInsets get allSm => AtharSpacing.allSm;
  EdgeInsets get allMd => AtharSpacing.allMd;
  EdgeInsets get allLg => AtharSpacing.allLg;
  EdgeInsets get allXxl => AtharSpacing.allXxl;
  EdgeInsets get page => AtharSpacing.page;
  EdgeInsets get card => AtharSpacing.card;
  EdgeInsets get listItem => AtharSpacing.listItem;
  EdgeInsets get button => AtharSpacing.button;
  EdgeInsets get input => AtharSpacing.input;
  EdgeInsets get dialog => AtharSpacing.dialog;
}
