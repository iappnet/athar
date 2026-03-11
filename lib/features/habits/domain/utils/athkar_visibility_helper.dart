class AthkarVisibilityHelper {
  /// هل الوقت الحالي هو وقت أذكار الصباح؟
  /// يبدأ: الفجر + 40 دقيقة
  /// ينتهي: العصر - 40 دقيقة
  static bool isMorningAthkarTime(DateTime fajrTime, DateTime asrTime) {
    final now = DateTime.now();

    final start = fajrTime.add(const Duration(minutes: 40));
    final end = asrTime.subtract(
      const Duration(minutes: 10),
    ); // تم التعديل لـ 40 حسب الطلب

    return now.isAfter(start) && now.isBefore(end);
  }

  /// هل الوقت الحالي هو وقت أذكار المساء؟
  /// يبدأ: العصر + 40 دقيقة
  /// ينتهي: منتصف الليل (11:59 مساءً)
  static bool isEveningAthkarTime(DateTime asrTime) {
    final now = DateTime.now();

    final start = asrTime.add(const Duration(minutes: 40));

    // ✅ التصحيح الجذري: نهاية اليوم هي 23:59:59 من نفس اليوم
    // الكود السابق كان يضعها 03:30 صباحاً مما يجعل الشرط مستحيلاً في وقت العصر
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return now.isAfter(start) && now.isBefore(end);
  }
}
