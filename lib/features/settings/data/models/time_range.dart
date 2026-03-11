import 'package:isar/isar.dart';
import 'package:flutter/material.dart';

part 'time_range.g.dart'; // سيتم توليده بواسطة Isar

@embedded
class TimeRange {
  // وقت البداية
  int startHour;
  int startMinute;

  // وقت النهاية
  int endHour;
  int endMinute;

  // ✅ الحقل الجديد: لكل فترة تصنيفها الخاص
  int? categoryId;

  TimeRange({
    this.startHour = 7,
    this.startMinute = 0,
    this.endHour = 15,
    this.endMinute = 0,
    this.categoryId, // ✅
  });

  /// دالة ذكية للتحقق مما إذا كان الوقت الحالي (أو أي وقت) يقع ضمن هذه الفترة
  bool contains(DateTime time) {
    // تحويل الأوقات إلى دقائق منذ بداية اليوم لسهولة المقارنة
    final currentMinutes = time.hour * 60 + time.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    if (endMinutes > startMinutes) {
      // الحالة الطبيعية: الفترة في نفس اليوم (مثلاً 9:00 ص إلى 5:00 م)
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // حالة "الوردية الليلية": الفترة تعبر منتصف الليل (مثلاً 10:00 م إلى 4:00 ص)
      // نتحقق: هل الوقت بعد البداية (في الليل)؟ أّو قبل النهاية (في الصباح)؟
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }

  // تحويل من TimeOfDay
  factory TimeRange.fromTimeOfDay(
    TimeOfDay start,
    TimeOfDay end, {
    int? categoryId,
  }) {
    return TimeRange(
      startHour: start.hour,
      startMinute: start.minute,
      endHour: end.hour,
      endMinute: end.minute,
      categoryId: categoryId, // ✅
    );
  }
}
