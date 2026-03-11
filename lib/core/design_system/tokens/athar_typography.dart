import 'package:flutter/material.dart';

/// ===================================================================
/// ATHAR TYPOGRAPHY - Design System Typography Tokens
/// ===================================================================
/// نظام الخطوط والنصوص الموحد لتطبيق أثر
/// ===================================================================

/// قيم الخطوط والنصوص الثابتة
///
/// مثال الاستخدام:
/// ```dart
/// Text(
///   'مرحباً',
///   style: AtharTypography.headlineMedium,
/// )
/// ```
abstract class AtharTypography {
  // ─────────────────────────────────────────────────────────────────
  // FONT FAMILIES - عائلات الخطوط
  // ─────────────────────────────────────────────────────────────────

  /// الخط الرئيسي للعربية
  static const String fontFamilyAr = 'Cairo';

  /// الخط الرئيسي للإنجليزية
  static const String fontFamilyEn = 'Inter';

  /// خط الأرقام والكود
  static const String fontFamilyMono = 'JetBrains Mono';

  /// قائمة الخطوط الاحتياطية
  static const List<String> fontFallback = ['Roboto', 'Arial', 'sans-serif'];

  // ─────────────────────────────────────────────────────────────────
  // FONT WEIGHTS - أوزان الخطوط
  // ─────────────────────────────────────────────────────────────────

  /// 100
  static const FontWeight thin = FontWeight.w100;

  /// 200
  static const FontWeight extraLight = FontWeight.w200;

  /// 300
  static const FontWeight light = FontWeight.w300;

  /// 400
  static const FontWeight regular = FontWeight.w400;

  /// 500
  static const FontWeight medium = FontWeight.w500;

  /// 600
  static const FontWeight semiBold = FontWeight.w600;

  /// 700
  static const FontWeight bold = FontWeight.w700;

  /// 800
  static const FontWeight extraBold = FontWeight.w800;

  /// 900
  static const FontWeight black = FontWeight.w900;

  // ─────────────────────────────────────────────────────────────────
  // FONT SIZES - أحجام الخطوط
  // ─────────────────────────────────────────────────────────────────

  /// 10.0 - أصغر حجم
  static const double sizeXxs = 10.0;

  /// 11.0
  static const double sizeXxsPlus = 11.0;

  /// 12.0 - صغير جداً
  static const double sizeXs = 12.0;

  /// 13.0
  static const double sizeXsPlus = 13.0;

  /// 14.0 - صغير
  static const double sizeSm = 14.0;

  /// 15.0
  static const double sizeSmPlus = 15.0;

  /// 16.0 - متوسط (الحجم الافتراضي للنص)
  static const double sizeMd = 16.0;

  /// 17.0
  static const double sizeMdPlus = 17.0;

  /// 18.0 - كبير
  static const double sizeLg = 18.0;

  /// 20.0 - كبير جداً
  static const double sizeXl = 20.0;

  /// 22.0
  static const double sizeXlPlus = 22.0;

  /// 24.0 - ضخم
  static const double sizeXxl = 24.0;

  /// 28.0 - عنوان صغير
  static const double sizeXxxl = 28.0;

  /// 32.0 - عنوان متوسط
  static const double sizeDisplay = 32.0;

  /// 36.0 - عنوان كبير
  static const double sizeDisplayMd = 36.0;

  /// 40.0 - عنوان ضخم
  static const double sizeDisplayLg = 40.0;

  /// 48.0 - عنوان عملاق
  static const double sizeDisplayXl = 48.0;

  /// 56.0 - أكبر عنوان
  static const double sizeDisplayXxl = 56.0;

  // ─────────────────────────────────────────────────────────────────
  // LINE HEIGHTS - ارتفاعات الأسطر
  // ─────────────────────────────────────────────────────────────────

  /// 1.0 - بدون مسافة إضافية
  static const double lineHeightNone = 1.0;

  /// 1.2 - للعناوين الكبيرة
  static const double lineHeightTight = 1.2;

  /// 1.3 - للعناوين
  static const double lineHeightSnug = 1.3;

  /// 1.4 - للعناوين الفرعية
  static const double lineHeightNormal = 1.4;

  /// 1.5 - للنص العادي
  static const double lineHeightBase = 1.5;

  /// 1.6 - للقراءة المريحة
  static const double lineHeightRelaxed = 1.6;

  /// 1.75 - للقراءة الطويلة
  static const double lineHeightLoose = 1.75;

  /// 2.0 - للنص المتباعد جداً
  static const double lineHeightExtraLoose = 2.0;

  // ─────────────────────────────────────────────────────────────────
  // LETTER SPACING - المسافات بين الحروف
  // ─────────────────────────────────────────────────────────────────

  /// -1.5 - مضغوط جداً
  static const double letterSpacingTightest = -1.5;

  /// -0.5 - مضغوط
  static const double letterSpacingTight = -0.5;

  /// -0.25 - مضغوط قليلاً
  static const double letterSpacingSnug = -0.25;

  /// 0.0 - عادي
  static const double letterSpacingNormal = 0.0;

  /// 0.25 - متباعد قليلاً
  static const double letterSpacingWide = 0.25;

  /// 0.5 - متباعد
  static const double letterSpacingWider = 0.5;

  /// 1.0 - متباعد جداً
  static const double letterSpacingWidest = 1.0;

  // ═══════════════════════════════════════════════════════════════════
  // TEXT STYLES - أنماط النصوص
  // ═══════════════════════════════════════════════════════════════════

  // ─────────────────────────────────────────────────────────────────
  // DISPLAY STYLES - عناوين العرض
  // ─────────────────────────────────────────────────────────────────

  /// عنوان عرض ضخم - 48px Bold
  static const TextStyle displayLarge = TextStyle(
    fontSize: sizeDisplayXl,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  /// عنوان عرض كبير - 40px Bold
  static const TextStyle displayMedium = TextStyle(
    fontSize: sizeDisplayLg,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  /// عنوان عرض متوسط - 32px Bold
  static const TextStyle displaySmall = TextStyle(
    fontSize: sizeDisplay,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingSnug,
  );

  // ─────────────────────────────────────────────────────────────────
  // HEADLINE STYLES - العناوين
  // ─────────────────────────────────────────────────────────────────

  /// عنوان كبير - 28px SemiBold
  static const TextStyle headlineLarge = TextStyle(
    fontSize: sizeXxxl,
    fontWeight: semiBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingNormal,
  );

  /// عنوان متوسط - 24px SemiBold
  static const TextStyle headlineMedium = TextStyle(
    fontSize: sizeXxl,
    fontWeight: semiBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingNormal,
  );

  /// عنوان صغير - 20px SemiBold
  static const TextStyle headlineSmall = TextStyle(
    fontSize: sizeXl,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  // ─────────────────────────────────────────────────────────────────
  // TITLE STYLES - العناوين الفرعية
  // ─────────────────────────────────────────────────────────────────

  /// عنوان فرعي كبير - 18px SemiBold
  static const TextStyle titleLarge = TextStyle(
    fontSize: sizeLg,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  /// عنوان فرعي متوسط - 16px SemiBold
  static const TextStyle titleMedium = TextStyle(
    fontSize: sizeMd,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  /// عنوان فرعي صغير - 14px SemiBold
  static const TextStyle titleSmall = TextStyle(
    fontSize: sizeSm,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  // ─────────────────────────────────────────────────────────────────
  // BODY STYLES - نص المحتوى
  // ─────────────────────────────────────────────────────────────────

  /// نص كبير - 16px Regular
  static const TextStyle bodyLarge = TextStyle(
    fontSize: sizeMd,
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
  );

  /// نص متوسط - 14px Regular
  static const TextStyle bodyMedium = TextStyle(
    fontSize: sizeSm,
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
  );

  /// نص صغير - 12px Regular
  static const TextStyle bodySmall = TextStyle(
    fontSize: sizeXs,
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
  );

  // ─────────────────────────────────────────────────────────────────
  // LABEL STYLES - التسميات
  // ─────────────────────────────────────────────────────────────────

  /// تسمية كبيرة - 14px Medium
  static const TextStyle labelLarge = TextStyle(
    fontSize: sizeSm,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  /// تسمية متوسطة - 12px Medium
  static const TextStyle labelMedium = TextStyle(
    fontSize: sizeXs,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  /// تسمية صغيرة - 10px Medium
  static const TextStyle labelSmall = TextStyle(
    fontSize: sizeXxs,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
  );

  // ═══════════════════════════════════════════════════════════════════
  // USE CASE STYLES - أنماط حسب الاستخدام
  // ═══════════════════════════════════════════════════════════════════

  /// للأزرار - 16px SemiBold
  static const TextStyle button = TextStyle(
    fontSize: sizeMd,
    fontWeight: semiBold,
    height: lineHeightNone,
    letterSpacing: letterSpacingWide,
  );

  /// للأزرار الصغيرة - 14px SemiBold
  static const TextStyle buttonSmall = TextStyle(
    fontSize: sizeSm,
    fontWeight: semiBold,
    height: lineHeightNone,
    letterSpacing: letterSpacingWide,
  );

  /// للأزرار الكبيرة - 18px SemiBold
  static const TextStyle buttonLarge = TextStyle(
    fontSize: sizeLg,
    fontWeight: semiBold,
    height: lineHeightNone,
    letterSpacing: letterSpacingWide,
  );

  /// لحقول الإدخال - 16px Regular
  static const TextStyle input = TextStyle(
    fontSize: sizeMd,
    fontWeight: regular,
    height: lineHeightBase,
    letterSpacing: letterSpacingNormal,
  );

  /// لـ placeholder - 16px Regular
  static const TextStyle placeholder = TextStyle(
    fontSize: sizeMd,
    fontWeight: regular,
    height: lineHeightBase,
    letterSpacing: letterSpacingNormal,
  );

  /// لـ hint - 14px Regular
  static const TextStyle hint = TextStyle(
    fontSize: sizeSm,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  /// لـ helper text - 12px Regular
  static const TextStyle helper = TextStyle(
    fontSize: sizeXs,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  /// لـ error text - 12px Regular
  static const TextStyle error = TextStyle(
    fontSize: sizeXs,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  /// للروابط - 16px Medium Underline
  static const TextStyle link = TextStyle(
    fontSize: sizeMd,
    fontWeight: medium,
    height: lineHeightBase,
    decoration: TextDecoration.underline,
  );

  /// للروابط الصغيرة - 14px Medium Underline
  static const TextStyle linkSmall = TextStyle(
    fontSize: sizeSm,
    fontWeight: medium,
    height: lineHeightNormal,
    decoration: TextDecoration.underline,
  );

  /// للـ caption - 12px Regular
  static const TextStyle caption = TextStyle(
    fontSize: sizeXs,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  /// للـ overline - 10px Medium Uppercase
  static const TextStyle overline = TextStyle(
    fontSize: sizeXxs,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWidest,
  );

  /// للأرقام الكبيرة - 32px Bold
  static const TextStyle numberLarge = TextStyle(
    fontSize: sizeDisplay,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  /// للأرقام المتوسطة - 24px SemiBold
  static const TextStyle numberMedium = TextStyle(
    fontSize: sizeXxl,
    fontWeight: semiBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  /// للأرقام الصغيرة - 18px SemiBold
  static const TextStyle numberSmall = TextStyle(
    fontSize: sizeLg,
    fontWeight: semiBold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  /// للـ Badge - 10px SemiBold
  static const TextStyle badge = TextStyle(
    fontSize: sizeXxs,
    fontWeight: semiBold,
    height: lineHeightNone,
    letterSpacing: letterSpacingWide,
  );

  /// للـ Chip - 12px Medium
  static const TextStyle chip = TextStyle(
    fontSize: sizeXs,
    fontWeight: medium,
    height: lineHeightNone,
    letterSpacing: letterSpacingNormal,
  );

  /// للـ Tab - 14px SemiBold
  static const TextStyle tab = TextStyle(
    fontSize: sizeSm,
    fontWeight: semiBold,
    height: lineHeightNone,
    letterSpacing: letterSpacingWide,
  );

  /// للـ AppBar Title - 18px SemiBold
  static const TextStyle appBarTitle = TextStyle(
    fontSize: sizeLg,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  /// للـ Dialog Title - 20px SemiBold
  static const TextStyle dialogTitle = TextStyle(
    fontSize: sizeXl,
    fontWeight: semiBold,
    height: lineHeightSnug,
    letterSpacing: letterSpacingNormal,
  );

  /// للـ Card Title - 16px SemiBold
  static const TextStyle cardTitle = TextStyle(
    fontSize: sizeMd,
    fontWeight: semiBold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  /// للـ List Item Title - 16px Medium
  static const TextStyle listItemTitle = TextStyle(
    fontSize: sizeMd,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  /// للـ List Item Subtitle - 14px Regular
  static const TextStyle listItemSubtitle = TextStyle(
    fontSize: sizeSm,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
  );

  /// للـ Code - 14px Mono
  static const TextStyle code = TextStyle(
    fontSize: sizeSm,
    fontWeight: regular,
    height: lineHeightRelaxed,
    letterSpacing: letterSpacingNormal,
    fontFamily: fontFamilyMono,
  );

  /// للـ Quote - 16px Italic
  static const TextStyle quote = TextStyle(
    fontSize: sizeMd,
    fontWeight: regular,
    height: lineHeightLoose,
    fontStyle: FontStyle.italic,
  );
}

// ═══════════════════════════════════════════════════════════════════════
// TEXT STYLE EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════

/// Extension لتسهيل تخصيص TextStyle
extension AtharTextStyleExtension on TextStyle {
  // ─────────────────────────────────────────────────────────────────
  // FONT FAMILY
  // ─────────────────────────────────────────────────────────────────

  /// تطبيق خط عربي (Cairo)
  TextStyle get arabic => copyWith(fontFamily: AtharTypography.fontFamilyAr);

  /// تطبيق خط إنجليزي (Inter)
  TextStyle get english => copyWith(fontFamily: AtharTypography.fontFamilyEn);

  /// تطبيق خط monospace
  TextStyle get mono => copyWith(fontFamily: AtharTypography.fontFamilyMono);

  // ─────────────────────────────────────────────────────────────────
  // FONT WEIGHT
  // ─────────────────────────────────────────────────────────────────

  /// جعل النص خفيف
  TextStyle get light => copyWith(fontWeight: AtharTypography.light);

  /// جعل النص عادي
  TextStyle get regular => copyWith(fontWeight: AtharTypography.regular);

  /// جعل النص متوسط
  TextStyle get medium => copyWith(fontWeight: AtharTypography.medium);

  /// جعل النص نصف غامق
  TextStyle get semiBold => copyWith(fontWeight: AtharTypography.semiBold);

  /// جعل النص غامق
  TextStyle get bold => copyWith(fontWeight: AtharTypography.bold);

  /// جعل النص أسود
  TextStyle get black => copyWith(fontWeight: AtharTypography.black);

  // ─────────────────────────────────────────────────────────────────
  // FONT STYLE
  // ─────────────────────────────────────────────────────────────────

  /// جعل النص مائل
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// جعل النص عادي (غير مائل)
  TextStyle get normal => copyWith(fontStyle: FontStyle.normal);

  // ─────────────────────────────────────────────────────────────────
  // TEXT DECORATION
  // ─────────────────────────────────────────────────────────────────

  /// إضافة خط تحت النص
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// إضافة خط فوق النص
  TextStyle get overlined => copyWith(decoration: TextDecoration.overline);

  /// إضافة خط يتوسط النص
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  /// إزالة الديكور
  TextStyle get noDecoration => copyWith(decoration: TextDecoration.none);

  // ─────────────────────────────────────────────────────────────────
  // COLOR
  // ─────────────────────────────────────────────────────────────────

  /// تطبيق لون مخصص
  TextStyle withColor(Color color) => copyWith(color: color);

  // ─────────────────────────────────────────────────────────────────
  // SIZE
  // ─────────────────────────────────────────────────────────────────

  /// تطبيق حجم مخصص
  TextStyle withSize(double size) => copyWith(fontSize: size);

  // ─────────────────────────────────────────────────────────────────
  // HEIGHT
  // ─────────────────────────────────────────────────────────────────

  /// تطبيق ارتفاع سطر مخصص
  TextStyle withHeight(double height) => copyWith(height: height);

  // ─────────────────────────────────────────────────────────────────
  // LETTER SPACING
  // ─────────────────────────────────────────────────────────────────

  /// تطبيق مسافة حروف مخصصة
  TextStyle withLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);
}

// ═══════════════════════════════════════════════════════════════════════
// CONTEXT EXTENSION
// ═══════════════════════════════════════════════════════════════════════

/// Extension للوصول السهل للخطوط من BuildContext
///
/// مثال الاستخدام:
/// ```dart
/// Text(
///   'مرحباً',
///   style: context.typography.headlineMedium,
/// )
/// ```
extension AtharTypographyExtension on BuildContext {
  /// الوصول لأنماط النصوص
  AtharTypographyHelper get typography => const AtharTypographyHelper();
}

/// Helper class للوصول للخطوط
///
/// ملاحظة: هذا الـ class عام (public) لأنه يُستخدم في public API
class AtharTypographyHelper {
  const AtharTypographyHelper();

  // Display
  TextStyle get displayLarge => AtharTypography.displayLarge;
  TextStyle get displayMedium => AtharTypography.displayMedium;
  TextStyle get displaySmall => AtharTypography.displaySmall;

  // Headline
  TextStyle get headlineLarge => AtharTypography.headlineLarge;
  TextStyle get headlineMedium => AtharTypography.headlineMedium;
  TextStyle get headlineSmall => AtharTypography.headlineSmall;

  // Title
  TextStyle get titleLarge => AtharTypography.titleLarge;
  TextStyle get titleMedium => AtharTypography.titleMedium;
  TextStyle get titleSmall => AtharTypography.titleSmall;

  // Body
  TextStyle get bodyLarge => AtharTypography.bodyLarge;
  TextStyle get bodyMedium => AtharTypography.bodyMedium;
  TextStyle get bodySmall => AtharTypography.bodySmall;

  // Label
  TextStyle get labelLarge => AtharTypography.labelLarge;
  TextStyle get labelMedium => AtharTypography.labelMedium;
  TextStyle get labelSmall => AtharTypography.labelSmall;

  // Use cases
  TextStyle get button => AtharTypography.button;
  TextStyle get input => AtharTypography.input;
  TextStyle get caption => AtharTypography.caption;
  TextStyle get link => AtharTypography.link;
}
