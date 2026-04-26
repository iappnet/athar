import 'package:adhan/adhan.dart';
import 'athar_time_periods.dart';

class AtharTimeCalculator {
  /// الدالة الرئيسية: تحديد الفترة الحالية بدقة
  /// [now]: الوقت الحالي
  /// [prayerTimes]: مواقيت الصلاة لليوم
  /// [nextFajr]: فجر اليوم التالي (لحساب الثلث الأخير بدقة)
  static AtharTimePeriod getCurrentPeriod({
    required DateTime now,
    required PrayerTimes prayerTimes,
    required DateTime nextFajr, // ضروري لحساب الليل
    DateTime? workStartTime, // اختياري (الافتراضي 8:00 ص)
  }) {
    // 1. تعريف الحدود الزمنية
    final sunrise = prayerTimes.sunrise;
    final dhuhrBuffer = prayerTimes.dhuhr.subtract(const Duration(minutes: 15));
    final ishaEnd = prayerTimes.isha.add(
      const Duration(minutes: 90),
    ); // ساعة ونصف

    // حساب الثلث الأخير (الليل من المغرب إلى الفجر يقسم على 3)
    // المدة الكلية لليل
    final nightDuration = nextFajr.difference(prayerTimes.maghrib);
    // بداية الثلث الأخير = الفجر - (مدة الليل / 3)
    final lastThirdStart = nextFajr.subtract(
      Duration(seconds: (nightDuration.inSeconds / 3).round()),
    );

    // 2. منطق البكور الديناميكي (حل تعارض الشروق المتأخر)
    // الافتراضي 8:00 صباحاً
    DateTime bakurEnd = DateTime(now.year, now.month, now.day, 8, 0);
    if (workStartTime != null) {
      bakurEnd = DateTime(
        now.year,
        now.month,
        now.day,
        workStartTime.hour,
        workStartTime.minute,
      );
    }

    // إذا كان الشروق متأخراً (بعد 8:00)، نلغي البكور عملياً بجعل نهايته نفس بدايته
    if (sunrise.isAfter(bakurEnd)) {
      bakurEnd = sunrise;
    }

    // 3. منطق الليل القصير (حل تعارض الصيف الأوروبي)
    // إذا كانت نهاية العشاء (ساعة ونصف) تتجاوز بداية الثلث الأخير
    DateTime effectiveIshaEnd = ishaEnd;
    if (ishaEnd.isAfter(lastThirdStart)) {
      // ندمج الليل: العشاء ينتهي عند بداية الثلث الأخير مباشرة
      effectiveIshaEnd = lastThirdStart;
    }

    // --- شجرة القرارات (Checking Sequence) ---

    // 1. الثلث الأخير (أولوية قصوى إذا كنا بعد منتصف الليل)
    if (now.isAfter(lastThirdStart) && now.isBefore(nextFajr)) {
      return AtharTimePeriod.lastThird;
    }

    // 2. الفجر
    if (now.isAfter(prayerTimes.fajr) && now.isBefore(sunrise)) {
      return AtharTimePeriod.dawn;
    }

    // 3. البكور (فقط إذا كان هناك وقت بين الشروق و 8:00)
    if (now.isAfter(sunrise) && now.isBefore(bakurEnd)) {
      return AtharTimePeriod.bakur;
    }

    // 4. الصباح (يبدأ من نهاية البكور الديناميكية)
    if (now.isAfter(bakurEnd) && now.isBefore(dhuhrBuffer)) {
      return AtharTimePeriod.morning;
    }

    // 5. الظهيرة
    if (now.isAfter(prayerTimes.dhuhr) && now.isBefore(prayerTimes.asr)) {
      return AtharTimePeriod.noon;
    }

    // 6. العصر
    if (now.isAfter(prayerTimes.asr) && now.isBefore(prayerTimes.maghrib)) {
      return AtharTimePeriod.afternoon;
    }

    // 7. المغرب
    if (now.isAfter(prayerTimes.maghrib) && now.isBefore(prayerTimes.isha)) {
      return AtharTimePeriod.maghrib;
    }

    // 8. العشاء
    if (now.isAfter(prayerTimes.isha) && now.isBefore(effectiveIshaEnd)) {
      return AtharTimePeriod.isha;
    }

    // 9. الليل (الفترة الفاصلة بين العشاء والثلث الأخير)
    // لن يتم الوصول لهنا إذا تم دمج الليل في الخطوة 3
    if (now.isAfter(effectiveIshaEnd) && now.isBefore(lastThirdStart)) {
      return AtharTimePeriod.night;
    }

    // حالة افتراضية (نادراً ما تحدث إذا كانت التواريخ دقيقة)
    // قد تكون في الدقائق الـ 15 قبل الظهر (وقت كراهة/انتقال)
    if (now.isAfter(dhuhrBuffer) && now.isBefore(prayerTimes.dhuhr)) {
      // يمكن اعتبارها تبع الصباح أو فترة مهملة، سنلحقها بالصباح
      return AtharTimePeriod.morning;
    }

    return AtharTimePeriod.undefined;
  }

  /// Approximate period from clock hour only — used when prayer times are unavailable.
  /// Maps to greeting-friendly buckets: dawn/morning/noon/afternoon/maghrib/night.
  static AtharTimePeriod approximatePeriod([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 7)  return AtharTimePeriod.dawn;
    if (hour >= 7 && hour < 12) return AtharTimePeriod.morning;
    if (hour >= 12 && hour < 15) return AtharTimePeriod.noon;
    if (hour >= 15 && hour < 18) return AtharTimePeriod.afternoon;
    if (hour >= 18 && hour < 21) return AtharTimePeriod.maghrib;
    if (hour >= 21 || hour < 4)  return AtharTimePeriod.night;
    return AtharTimePeriod.undefined;
  }

  /// دالة مساعدة لمعرفة هل الوقت الحالي هو وقت "الضحى" شرعاً
  static bool isDuhaTime(DateTime now, DateTime sunrise, DateTime dhuhr) {
    final start = sunrise.add(const Duration(minutes: 15));
    final end = dhuhr.subtract(const Duration(minutes: 15));
    return now.isAfter(start) && now.isBefore(end);
  }

  /// دالة مساعدة لمعرفة وقت "الضحى الكبير" (للتذكيرات)
  static DateTime getBigDuhaTime(DateTime sunrise) {
    // نفترض أنه الساعة 10:00 صباحاً كمعيار ثابت، أو يمكن حسابه كمنتصف
    return DateTime(sunrise.year, sunrise.month, sunrise.day, 10, 0);
  }
}
