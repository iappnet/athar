import 'package:flutter/material.dart';

class ConflictResult {
  final bool hasConflict;
  final String message;
  final Color color;
  final bool isStrict; // هل المنع صارم (أحمر) أم تحذير (برتقالي)؟
  // ✅ الحقل الجديد: الوقت المقترح (نهاية الصلاة أو المهمة السابقة)
  final DateTime? suggestedTime;

  ConflictResult({
    required this.hasConflict,
    this.message = '',
    this.color = Colors.transparent,
    this.isStrict = false,
    this.suggestedTime, // ✅
  });

  factory ConflictResult.none() => ConflictResult(hasConflict: false);

  factory ConflictResult.warning(String msg, {DateTime? suggestedTime}) =>
      ConflictResult(
        hasConflict: true,
        message: msg,
        color: const Color(0xFFF59E0B), // أصفر كهرماني جميل
        isStrict: false,
        suggestedTime: suggestedTime, // ✅
      );

  factory ConflictResult.alert(String msg, {required DateTime suggestedTime}) =>
      ConflictResult(
        hasConflict: true,
        message: msg,
        color: Colors.red,
        isStrict: true,
      );
}
