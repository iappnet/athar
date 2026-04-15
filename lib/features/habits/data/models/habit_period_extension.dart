// lib/features/habits/data/models/habit_period_extension.dart
// ═══════════════════════════════════════════════════════════════════════════
// Bridge بين HabitPeriod و AtharTimePeriod لتوحيد نظام الأوقات الشرعية
// ═══════════════════════════════════════════════════════════════════════════

import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:athar/features/habits/data/models/habit_model.dart';

/// تحويل [HabitPeriod] إلى [AtharTimePeriod] الموحد.
///
/// - القيم المتطابقة تُربط مباشرة (dawn, bakur, morning, ...)
/// - `anyTime` و `postPrayer` ليس لهما مقابل دقيق، فيُرجعان `undefined`
///   لأنهما يعبّران عن "غير محدد" أو "بعد أي صلاة".
extension HabitPeriodToAthar on HabitPeriod {
  AtharTimePeriod toAtharPeriod() {
    switch (this) {
      case HabitPeriod.dawn:
        return AtharTimePeriod.dawn;
      case HabitPeriod.bakur:
        return AtharTimePeriod.bakur;
      case HabitPeriod.morning:
        return AtharTimePeriod.morning;
      case HabitPeriod.noon:
        return AtharTimePeriod.noon;
      case HabitPeriod.afternoon:
        return AtharTimePeriod.afternoon;
      case HabitPeriod.maghrib:
        return AtharTimePeriod.maghrib;
      case HabitPeriod.isha:
        return AtharTimePeriod.isha;
      case HabitPeriod.night:
        return AtharTimePeriod.night;
      case HabitPeriod.lastThird:
        return AtharTimePeriod.lastThird;
      case HabitPeriod.anyTime:
      case HabitPeriod.postPrayer:
        return AtharTimePeriod.undefined;
    }
  }

  /// هل الفترة مرتبطة بصلاة/وقت شرعي محدد؟
  bool get hasPrayerAnchor {
    return this != HabitPeriod.anyTime && this != HabitPeriod.postPrayer;
  }
}

/// الاتجاه العكسي: محاولة تحويل [AtharTimePeriod] إلى [HabitPeriod] الأقرب.
extension AtharPeriodToHabit on AtharTimePeriod {
  HabitPeriod toHabitPeriod() {
    switch (this) {
      case AtharTimePeriod.dawn:
        return HabitPeriod.dawn;
      case AtharTimePeriod.bakur:
        return HabitPeriod.bakur;
      case AtharTimePeriod.morning:
        return HabitPeriod.morning;
      case AtharTimePeriod.noon:
        return HabitPeriod.noon;
      case AtharTimePeriod.afternoon:
        return HabitPeriod.afternoon;
      case AtharTimePeriod.maghrib:
        return HabitPeriod.maghrib;
      case AtharTimePeriod.isha:
        return HabitPeriod.isha;
      case AtharTimePeriod.night:
        return HabitPeriod.night;
      case AtharTimePeriod.lastThird:
        return HabitPeriod.lastThird;
      case AtharTimePeriod.duha:
        // لا يوجد مقابل مباشر في HabitPeriod — نرجع للبكور كأقرب فترة
        return HabitPeriod.bakur;
      case AtharTimePeriod.undefined:
        return HabitPeriod.anyTime;
    }
  }
}
