import 'package:isar/isar.dart';

part 'recurrence_pattern.g.dart';

enum RecurrenceType { none, daily, weekly, monthly, yearly, custom }

enum RecurrenceEndType { never, afterOccurrences, onDate }

@embedded
class RecurrencePattern {
  @enumerated
  RecurrenceType type = RecurrenceType.none;

  // كل كم يوم/أسبوع/شهر
  int interval = 1;

  // للتكرار الأسبوعي: أيام الأسبوع [1=الاثنين, 7=الأحد]
  List<int> weekDays = [];

  // للتكرار الشهري: أيام الشهر [1-31]
  List<int> monthDays = [];

  // كيف ينتهي التكرار
  @enumerated
  RecurrenceEndType endType = RecurrenceEndType.never;

  // عدد التكرارات (إذا كان endType = afterOccurrences)
  int? occurrences;

  // تاريخ النهاية (إذا كان endType = onDate)
  DateTime? endDate;

  // تاريخ البداية
  DateTime? startDate;

  RecurrencePattern();

  RecurrencePattern.daily({
    this.interval = 1,
    this.endType = RecurrenceEndType.never,
    this.occurrences,
    this.endDate,
    this.startDate,
  }) : type = RecurrenceType.daily,
       weekDays = [],
       monthDays = [];

  RecurrencePattern.weekly({
    required this.weekDays,
    this.interval = 1,
    this.endType = RecurrenceEndType.never,
    this.occurrences,
    this.endDate,
    this.startDate,
  }) : type = RecurrenceType.weekly,
       monthDays = [];

  RecurrencePattern.monthly({
    required this.monthDays,
    this.interval = 1,
    this.endType = RecurrenceEndType.never,
    this.occurrences,
    this.endDate,
    this.startDate,
  }) : type = RecurrenceType.monthly,
       weekDays = [];

  // ✅ دالة لحساب التواريخ القادمة
  List<DateTime> generateOccurrences({
    required DateTime from,
    int limit = 100,
  }) {
    if (type == RecurrenceType.none) return [];

    final occurrences = <DateTime>[];
    var current = startDate ?? from;

    while (occurrences.length < limit) {
      // التحقق من شرط النهاية
      if (endType == RecurrenceEndType.afterOccurrences &&
          this.occurrences != null &&
          occurrences.length >= this.occurrences!) {
        break;
      }

      if (endType == RecurrenceEndType.onDate &&
          endDate != null &&
          current.isAfter(endDate!)) {
        break;
      }

      occurrences.add(current);

      // حساب التاريخ التالي
      switch (type) {
        case RecurrenceType.daily:
          current = current.add(Duration(days: interval));
          break;

        case RecurrenceType.weekly:
          current = _nextWeeklyOccurrence(current);
          break;

        case RecurrenceType.monthly:
          current = _nextMonthlyOccurrence(current);
          break;

        case RecurrenceType.yearly:
          current = DateTime(
            current.year + interval,
            current.month,
            current.day,
          );
          break;

        case RecurrenceType.custom:
        case RecurrenceType.none:
          break;
      }
    }

    return occurrences;
  }

  DateTime _nextWeeklyOccurrence(DateTime from) {
    if (weekDays.isEmpty) {
      return from.add(Duration(days: 7 * interval));
    }

    var next = from.add(const Duration(days: 1));

    while (true) {
      if (weekDays.contains(next.weekday)) {
        return next;
      }
      next = next.add(const Duration(days: 1));

      // إذا مر أسبوع كامل، انتقل للأسبوع التالي
      if (next.difference(from).inDays >= 7) {
        from = from.add(Duration(days: 7 * interval));
        next = from.add(const Duration(days: 1));
      }
    }
  }

  DateTime _nextMonthlyOccurrence(DateTime from) {
    if (monthDays.isEmpty) {
      return DateTime(from.year, from.month + interval, from.day);
    }

    var nextMonth = from.month + interval;
    var nextYear = from.year;

    if (nextMonth > 12) {
      nextYear += nextMonth ~/ 12;
      nextMonth = nextMonth % 12;
    }

    // ابحث عن أول يوم متاح في الشهر التالي
    for (var day in monthDays) {
      try {
        return DateTime(nextYear, nextMonth, day);
      } catch (e) {
        continue; // اليوم غير موجود في هذا الشهر
      }
    }

    // إذا لم يوجد، استخدم آخر يوم في الشهر
    return DateTime(nextYear, nextMonth + 1, 0);
  }

  String getDescription() {
    switch (type) {
      case RecurrenceType.none:
        return 'لا يتكرر';
      case RecurrenceType.daily:
        return interval == 1 ? 'يومياً' : 'كل $interval أيام';
      case RecurrenceType.weekly:
        if (weekDays.isEmpty) {
          return interval == 1 ? 'أسبوعياً' : 'كل $interval أسابيع';
        }
        final dayNames = weekDays.map(_getDayName).join(', ');
        return 'كل $dayNames';
      case RecurrenceType.monthly:
        return interval == 1 ? 'شهرياً' : 'كل $interval أشهر';
      case RecurrenceType.yearly:
        return interval == 1 ? 'سنوياً' : 'كل $interval سنوات';
      case RecurrenceType.custom:
        return 'مخصص';
    }
  }

  String _getDayName(int day) {
    const names = [
      '',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return names[day];
  }

  RecurrencePattern copyWith({
    RecurrenceType? type,
    int? interval,
    List<int>? weekDays,
    List<int>? monthDays,
    RecurrenceEndType? endType,
    int? occurrences,
    DateTime? endDate,
    DateTime? startDate,
  }) {
    return RecurrencePattern()
      ..type = type ?? this.type
      ..interval = interval ?? this.interval
      ..weekDays = weekDays ?? this.weekDays
      ..monthDays = monthDays ?? this.monthDays
      ..endType = endType ?? this.endType
      ..occurrences = occurrences ?? this.occurrences
      ..endDate = endDate ?? this.endDate
      ..startDate = startDate ?? this.startDate;
  }
}
