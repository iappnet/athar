// lib/core/design_system/atoms/text/flex_text.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 🔤 FlexText - نص مرن لا يسبب overflow
// ═══════════════════════════════════════════════════════════════════════════════
// الاستخدام: بديل لـ Text داخل Row لمنع overflow تلقائياً
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// FlexText - نص مرن يمنع overflow تلقائياً
/// 
/// يُستخدم داخل Row بدلاً من Text العادي لضمان عدم تجاوز النص للمساحة المتاحة.
/// 
/// ## مثال الاستخدام:
/// ```dart
/// // ❌ الطريقة القديمة (قد تسبب overflow):
/// Row(
///   children: [
///     Text('نص طويل جداً قد يسبب overflow'),
///     Icon(Icons.arrow),
///   ],
/// )
/// 
/// // ✅ الطريقة الجديدة:
/// Row(
///   children: [
///     FlexText('نص طويل جداً قد يسبب overflow'),
///     Icon(Icons.arrow),
///   ],
/// )
/// ```
/// 
/// ## الخصائص:
/// - يلتف تلقائياً بـ [Flexible]
/// - يقطع النص بـ ellipsis عند الحاجة
/// - يدعم كل خصائص [Text] العادية
class FlexText extends StatelessWidget {
  /// النص المراد عرضه
  final String text;
  
  /// نمط النص
  final TextStyle? style;
  
  /// الحد الأقصى لعدد الأسطر (افتراضي: 1)
  final int maxLines;
  
  /// طريقة التعامل مع النص الطويل (افتراضي: ellipsis)
  final TextOverflow overflow;
  
  /// محاذاة النص
  final TextAlign? textAlign;
  
  /// اتجاه النص
  final TextDirection? textDirection;
  
  /// معامل المرونة (افتراضي: 1)
  final int flex;
  
  /// هل يستخدم Flexible أم Expanded
  final bool expanded;

  const FlexText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.textDirection,
    this.flex = 1,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      textDirection: textDirection,
    );

    if (expanded) {
      return Expanded(
        flex: flex,
        child: textWidget,
      );
    }

    return Flexible(
      flex: flex,
      child: textWidget,
    );
  }
}

/// ExpandedText - نص موسع يأخذ كل المساحة المتاحة
/// 
/// مثل FlexText لكن يستخدم [Expanded] بدلاً من [Flexible]
class ExpandedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final int flex;

  const ExpandedText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🔧 Extensions لتسهيل الاستخدام
// ═══════════════════════════════════════════════════════════════════════════════

extension FlexTextExtension on Text {
  /// تحويل Text إلى نص مرن
  /// 
  /// ```dart
  /// Text('نص طويل').flexible
  /// ```
  Widget get flexible => Flexible(
        child: Text(
          data ?? '',
          style: style,
          maxLines: maxLines ?? 1,
          overflow: overflow ?? TextOverflow.ellipsis,
          textAlign: textAlign,
        ),
      );

  /// تحويل Text إلى نص موسع
  /// 
  /// ```dart
  /// Text('نص طويل').expanded
  /// ```
  Widget get expanded => Expanded(
        child: Text(
          data ?? '',
          style: style,
          maxLines: maxLines ?? 1,
          overflow: overflow ?? TextOverflow.ellipsis,
          textAlign: textAlign,
        ),
      );

  /// تحويل Text إلى نص مرن مع تحديد flex
  /// 
  /// ```dart
  /// Text('نص طويل').flexWith(flex: 2)
  /// ```
  Widget flexWith({int flex = 1}) => Flexible(
        flex: flex,
        child: Text(
          data ?? '',
          style: style,
          maxLines: maxLines ?? 1,
          overflow: overflow ?? TextOverflow.ellipsis,
          textAlign: textAlign,
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// 📐 FlexRow - Row آمن مع دعم مدمج للنصوص المرنة
// ═══════════════════════════════════════════════════════════════════════════════

/// FlexRow - Row مع حماية تلقائية من overflow
/// 
/// يوفر خاصية [flexibleTextIndices] لتحديد أي عناصر نصية يجب أن تكون مرنة
class FlexRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  
  /// قائمة بأرقام العناصر التي يجب لفها بـ Flexible
  /// 
  /// مثال: [0, 2] يعني أن العنصر الأول والثالث سيكونان مرنين
  final List<int>? flexibleIndices;

  const FlexRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.flexibleIndices,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _processChildren(),
    );
  }

  List<Widget> _processChildren() {
    if (flexibleIndices == null || flexibleIndices!.isEmpty) {
      return children;
    }

    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;

      if (flexibleIndices!.contains(index)) {
        return Flexible(child: child);
      }
      return child;
    }).toList();
  }
}
