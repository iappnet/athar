import 'package:adhan/adhan.dart';
import 'athar_time_periods.dart';

class RelativeTimeParser {
  /// تحويل إعداد نسبي إلى وقت فعلي
  /// مثال: [prayer] = dhuhr, [relation] = after, [offset] = 20 mins
  /// النتيجة: وقت أذان الظهر + 20 دقيقة
  static DateTime? calculateActualTime({
    required ReferencePrayer prayer,
    required PrayerRelativeTime relation,
    required int offsetMinutes,
    required PrayerTimes prayerTimes,
  }) {
    DateTime baseTime;

    switch (prayer) {
      case ReferencePrayer.fajr:
        baseTime = prayerTimes.fajr;
        break;
      case ReferencePrayer.sunrise:
        baseTime = prayerTimes.sunrise;
        break;
      case ReferencePrayer.dhuhr:
        baseTime = prayerTimes.dhuhr;
        break;
      case ReferencePrayer.asr:
        baseTime = prayerTimes.asr;
        break;
      case ReferencePrayer.maghrib:
        baseTime = prayerTimes.maghrib;
        break;
      case ReferencePrayer.isha:
        baseTime = prayerTimes.isha;
        break;
    }

    if (relation == PrayerRelativeTime.after) {
      return baseTime.add(Duration(minutes: offsetMinutes));
    } else if (relation == PrayerRelativeTime.before) {
      return baseTime.subtract(Duration(minutes: offsetMinutes));
    } else if (relation == PrayerRelativeTime.iqama) {
      // يمكن وضع منطق افتراضي للإقامة (مثلاً 20 دقيقة) أو جلبه من الإعدادات
      return baseTime.add(
        Duration(minutes: offsetMinutes > 0 ? offsetMinutes : 20),
      );
    }

    return baseTime;
  }
}
