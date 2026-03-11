import 'package:flutter/material.dart';

/// ===================================================================
/// ATHAR DIRECTIONALITY EXTENSIONS
/// ===================================================================
/// Extensions لدعم RTL/LTR
/// ===================================================================

/// Extension للتعامل مع اتجاه النص
extension AtharDirectionalityExtension on BuildContext {
  // ─────────────────────────────────────────────────────────────────
  // DIRECTION CHECKS
  // ─────────────────────────────────────────────────────────────────

  /// هل الاتجاه من اليمين لليسار؟
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;

  /// هل الاتجاه من اليسار لليمين؟
  bool get isLTR => Directionality.of(this) == TextDirection.ltr;

  /// اتجاه النص الحالي
  TextDirection get textDirection => Directionality.of(this);

  // ─────────────────────────────────────────────────────────────────
  // DIRECTIONAL VALUES
  // ─────────────────────────────────────────────────────────────────

  /// الحصول على قيمة حسب الاتجاه
  /// 
  /// مثال:
  /// ```dart
  /// final padding = context.directional(rtl: 16.0, ltr: 8.0);
  /// ```
  T directional<T>({required T rtl, required T ltr}) {
    return isRTL ? rtl : ltr;
  }

  /// بداية الاتجاه (يمين في RTL، يسار في LTR)
  double startOf(double value) => value;

  /// نهاية الاتجاه (يسار في RTL، يمين في LTR)
  double endOf(double value) => value;

  // ─────────────────────────────────────────────────────────────────
  // ALIGNMENT
  // ─────────────────────────────────────────────────────────────────

  /// محاذاة البداية
  AlignmentDirectional get alignStart => AlignmentDirectional.centerStart;

  /// محاذاة النهاية
  AlignmentDirectional get alignEnd => AlignmentDirectional.centerEnd;

  /// محاذاة أعلى البداية
  AlignmentDirectional get alignTopStart => AlignmentDirectional.topStart;

  /// محاذاة أعلى النهاية
  AlignmentDirectional get alignTopEnd => AlignmentDirectional.topEnd;

  /// محاذاة أسفل البداية
  AlignmentDirectional get alignBottomStart => AlignmentDirectional.bottomStart;

  /// محاذاة أسفل النهاية
  AlignmentDirectional get alignBottomEnd => AlignmentDirectional.bottomEnd;

  // ─────────────────────────────────────────────────────────────────
  // TEXT ALIGNMENT
  // ─────────────────────────────────────────────────────────────────

  /// محاذاة نص البداية
  TextAlign get textAlignStart => isRTL ? TextAlign.right : TextAlign.left;

  /// محاذاة نص النهاية
  TextAlign get textAlignEnd => isRTL ? TextAlign.left : TextAlign.right;
}

// ═══════════════════════════════════════════════════════════════════════
// DIRECTIONAL EDGE INSETS
// ═══════════════════════════════════════════════════════════════════════

/// EdgeInsets تدعم RTL/LTR تلقائياً
/// 
/// مثال:
/// ```dart
/// Padding(
///   padding: AtharEdgeInsets.start(16),
///   child: Text('نص'),
/// )
/// ```
class AtharEdgeInsets {
  AtharEdgeInsets._();

  /// مسافة من البداية فقط
  static EdgeInsetsDirectional start(double value) {
    return EdgeInsetsDirectional.only(start: value);
  }

  /// مسافة من النهاية فقط
  static EdgeInsetsDirectional end(double value) {
    return EdgeInsetsDirectional.only(end: value);
  }

  /// مسافة من الأعلى فقط
  static EdgeInsetsDirectional top(double value) {
    return EdgeInsetsDirectional.only(top: value);
  }

  /// مسافة من الأسفل فقط
  static EdgeInsetsDirectional bottom(double value) {
    return EdgeInsetsDirectional.only(bottom: value);
  }

  /// مسافة أفقية (بداية ونهاية)
  static EdgeInsetsDirectional horizontal(double value) {
    return EdgeInsetsDirectional.symmetric(horizontal: value);
  }

  /// مسافة رأسية (أعلى وأسفل)
  static EdgeInsetsDirectional vertical(double value) {
    return EdgeInsetsDirectional.symmetric(vertical: value);
  }

  /// مسافة من جميع الاتجاهات
  static EdgeInsetsDirectional all(double value) {
    return EdgeInsetsDirectional.all(value);
  }

  /// مسافة متماثلة
  static EdgeInsetsDirectional symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsetsDirectional.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  /// مسافة مخصصة
  static EdgeInsetsDirectional only({
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) {
    return EdgeInsetsDirectional.only(
      start: start,
      top: top,
      end: end,
      bottom: bottom,
    );
  }

  /// مسافة من البداية والنهاية مختلفة
  static EdgeInsetsDirectional startEnd({
    required double start,
    required double end,
  }) {
    return EdgeInsetsDirectional.only(start: start, end: end);
  }

  /// تحويل EdgeInsets عادي إلى Directional
  static EdgeInsetsDirectional fromLTRB(
    double left,
    double top,
    double right,
    double bottom,
    BuildContext context,
  ) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return EdgeInsetsDirectional.only(
      start: isRTL ? right : left,
      top: top,
      end: isRTL ? left : right,
      bottom: bottom,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DIRECTIONAL BORDER RADIUS
// ═══════════════════════════════════════════════════════════════════════

/// BorderRadius تدعم RTL/LTR
class AtharBorderRadius {
  AtharBorderRadius._();

  /// حواف البداية فقط
  static BorderRadiusDirectional start(double radius) {
    return BorderRadiusDirectional.only(
      topStart: Radius.circular(radius),
      bottomStart: Radius.circular(radius),
    );
  }

  /// حواف النهاية فقط
  static BorderRadiusDirectional end(double radius) {
    return BorderRadiusDirectional.only(
      topEnd: Radius.circular(radius),
      bottomEnd: Radius.circular(radius),
    );
  }

  /// حواف الأعلى فقط
  static BorderRadiusDirectional top(double radius) {
    return BorderRadiusDirectional.only(
      topStart: Radius.circular(radius),
      topEnd: Radius.circular(radius),
    );
  }

  /// حواف الأسفل فقط
  static BorderRadiusDirectional bottom(double radius) {
    return BorderRadiusDirectional.only(
      bottomStart: Radius.circular(radius),
      bottomEnd: Radius.circular(radius),
    );
  }

  /// جميع الحواف
  static BorderRadiusDirectional all(double radius) {
    return BorderRadiusDirectional.all(Radius.circular(radius));
  }

  /// حواف مخصصة
  static BorderRadiusDirectional only({
    double topStart = 0,
    double topEnd = 0,
    double bottomStart = 0,
    double bottomEnd = 0,
  }) {
    return BorderRadiusDirectional.only(
      topStart: Radius.circular(topStart),
      topEnd: Radius.circular(topEnd),
      bottomStart: Radius.circular(bottomStart),
      bottomEnd: Radius.circular(bottomEnd),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DIRECTIONAL POSITIONED
// ═══════════════════════════════════════════════════════════════════════

/// Positioned تدعم RTL/LTR
/// 
/// مثال:
/// ```dart
/// Stack(
///   children: [
///     AtharPositioned.start(
///       start: 16,
///       top: 16,
///       child: Icon(Icons.star),
///     ),
///   ],
/// )
/// ```
class AtharPositioned extends StatelessWidget {
  const AtharPositioned({
    super.key,
    this.start,
    this.top,
    this.end,
    this.bottom,
    this.width,
    this.height,
    required this.child,
  });

  final double? start;
  final double? top;
  final double? end;
  final double? bottom;
  final double? width;
  final double? height;
  final Widget child;

  /// إنشاء مع بداية فقط
  factory AtharPositioned.start({
    Key? key,
    required double start,
    double? top,
    double? bottom,
    double? width,
    double? height,
    required Widget child,
  }) {
    return AtharPositioned(
      key: key,
      start: start,
      top: top,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  /// إنشاء مع نهاية فقط
  factory AtharPositioned.end({
    Key? key,
    required double end,
    double? top,
    double? bottom,
    double? width,
    double? height,
    required Widget child,
  }) {
    return AtharPositioned(
      key: key,
      end: end,
      top: top,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  /// ملء العرض
  factory AtharPositioned.fill({
    Key? key,
    double? start,
    double? top,
    double? end,
    double? bottom,
    required Widget child,
  }) {
    return AtharPositioned(
      key: key,
      start: start ?? 0,
      top: top ?? 0,
      end: end ?? 0,
      bottom: bottom ?? 0,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: start,
      top: top,
      end: end,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DIRECTIONAL ROW
// ═══════════════════════════════════════════════════════════════════════

/// Row تعكس اتجاهها تلقائياً في RTL
/// 
/// ملاحظة: Row العادي يعكس اتجاهه تلقائياً
/// هذا Widget للحالات الخاصة
class AtharRow extends StatelessWidget {
  const AtharRow({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textBaseline,
    required this.children,
    this.reversed = false,
  });

  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextBaseline? textBaseline;
  final List<Widget> children;
  
  /// عكس الترتيب يدوياً
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    final shouldReverse = reversed ? !isRTL : isRTL;
    
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textBaseline: textBaseline,
      textDirection: shouldReverse ? TextDirection.rtl : TextDirection.ltr,
      children: children,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ICON DIRECTION HELPER
// ═══════════════════════════════════════════════════════════════════════

/// دالة لعكس أيقونات الأسهم حسب الاتجاه
/// 
/// مثال:
/// ```dart
/// Icon(AtharIcons.backArrow(context))
/// Icon(AtharIcons.forwardArrow(context))
/// ```
class AtharIcons {
  AtharIcons._();

  /// سهم الرجوع (يتغير حسب الاتجاه)
  static IconData backArrow(BuildContext context) {
    return context.isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios;
  }

  /// سهم التقدم (يتغير حسب الاتجاه)
  static IconData forwardArrow(BuildContext context) {
    return context.isRTL ? Icons.arrow_back_ios : Icons.arrow_forward_ios;
  }

  /// سهم الرجوع (Material)
  static IconData backArrowMaterial(BuildContext context) {
    return context.isRTL ? Icons.arrow_forward : Icons.arrow_back;
  }

  /// سهم التقدم (Material)
  static IconData forwardArrowMaterial(BuildContext context) {
    return context.isRTL ? Icons.arrow_back : Icons.arrow_forward;
  }

  /// شيفرون البداية
  static IconData chevronStart(BuildContext context) {
    return context.isRTL ? Icons.chevron_right : Icons.chevron_left;
  }

  /// شيفرون النهاية
  static IconData chevronEnd(BuildContext context) {
    return context.isRTL ? Icons.chevron_left : Icons.chevron_right;
  }

  /// سهم قائمة منسدلة للبداية
  static IconData dropdownStart(BuildContext context) {
    return context.isRTL ? Icons.arrow_right : Icons.arrow_left;
  }

  /// سهم قائمة منسدلة للنهاية
  static IconData dropdownEnd(BuildContext context) {
    return context.isRTL ? Icons.arrow_left : Icons.arrow_right;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TRANSFORM HELPER
// ═══════════════════════════════════════════════════════════════════════

/// Extension لعكس Widget أفقياً في RTL
extension AtharTransformExtension on Widget {
  /// عكس الـ Widget أفقياً إذا كان RTL
  Widget flipInRTL(BuildContext context) {
    if (context.isRTL) {
      return Transform.scale(
        scaleX: -1,
        child: this,
      );
    }
    return this;
  }

  /// عكس الـ Widget أفقياً دائماً
  Widget flipHorizontally() {
    return Transform.scale(
      scaleX: -1,
      child: this,
    );
  }
}
