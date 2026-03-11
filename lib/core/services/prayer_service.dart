import 'package:adhan/adhan.dart' as adhan;
import 'package:injectable/injectable.dart';
import '../../features/prayer/domain/entities/prayer_time.dart';

@lazySingleton
class PrayerService {
  /// ✅ الحصول على مواقيت الصلاة ليوم محدد وموقع محدد
  /// يُرجع List<PrayerTime> بدلاً من adhan.PrayerTimes
  List<PrayerTime> getPrayerTimes(
    DateTime date,
    adhan.Coordinates coordinates,
  ) {
    // 1. إعدادات الحساب (أم القرى - مكة المكرمة)
    final params = adhan.CalculationMethod.umm_al_qura.getParameters();
    params.madhab = adhan.Madhab.shafi;

    // 2. إنشاء كائن التوقيت من adhan
    final dateComponents = adhan.DateComponents(
      date.year,
      date.month,
      date.day,
    );
    final adhanPrayerTimes = adhan.PrayerTimes(
      coordinates,
      dateComponents,
      params,
    );

    // 3. ✅ تحويل إلى PrayerTime (entity محلي)
    return PrayerTime.fromAdhanPrayerTimes(adhanPrayerTimes);
  }

  /// ✅ الحصول على اسم الصلاة بالعربي (من PrayerType بدلاً من adhan.Prayer)
  String getPrayerName(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
    }
  }

  /// ✅ الحصول على الصلاة القادمة
  PrayerTime? getNextPrayer(adhan.Coordinates coordinates) {
    final now = DateTime.now();
    final prayerTimes = getPrayerTimes(now, coordinates);

    try {
      return prayerTimes.firstWhere((p) => p.time.isAfter(now));
    } catch (_) {
      // فجر الغد
      final tomorrowPrayers = getPrayerTimes(
        now.add(const Duration(days: 1)),
        coordinates,
      );
      return tomorrowPrayers.first.copyWith(isNext: true);
    }
  }
}

// import 'package:adhan/adhan.dart';
// import 'package:injectable/injectable.dart';

// @lazySingleton
// class PrayerService {
//   // إحداثيات الرياض (افتراضياً)
//   // static const double _defaultLat = 24.7136;
//   // static const double _defaultLng = 46.6753;

//   /// الحصول على مواقيت الصلاة ليوم محدد
//   /// الحصول على مواقيت الصلاة ليوم محدد وموقع محدد
//   /// [coordinates] : الإحداثيات الحالية للمستخدم
//   PrayerTimes getPrayerTimes(DateTime date, Coordinates coordinates) {
//     // 1. إعدادات الحساب (أم القرى - مكة المكرمة)
//     final params = CalculationMethod.umm_al_qura.getParameters();
//     params.madhab =
//         Madhab.shafi; // (الشافعي والحنبلي والمالكي نفس التوقيت للعصر)

//     // 2. إنشاء كائن التوقيت
//     final dateComponents = DateComponents(date.year, date.month, date.day);

//     return PrayerTimes(coordinates, dateComponents, params);
//   }
//   // PrayerTimes getPrayerTimes(DateTime date) {
//   //   // 1. إعدادات الموقع
//   //   final myCoordinates = Coordinates(_defaultLat, _defaultLng);

//   //   // 2. إعدادات الحساب (أم القرى - مكة المكرمة)
//   //   final params = CalculationMethod.umm_al_qura.getParameters();
//   //   params.madhab =
//   //       Madhab.shafi; // (الشافعي والحنبلي والمالكي نفس التوقيت للعصر)

//   //   // 3. إنشاء كائن التوقيت
//   //   final dateComponents = DateComponents(date.year, date.month, date.day);

//   //   return PrayerTimes(myCoordinates, dateComponents, params);
//   // }

//   /// الحصول على اسم الصلاة بالعربي
//   String getPrayerName(Prayer prayer) {
//     switch (prayer) {
//       case Prayer.fajr:
//         return 'الفجر';
//       case Prayer.sunrise:
//         return 'الشروق';
//       case Prayer.dhuhr:
//         return 'الظهر';
//       case Prayer.asr:
//         return 'العصر';
//       case Prayer.maghrib:
//         return 'المغرب';
//       case Prayer.isha:
//         return 'العشاء';
//       case Prayer.none:
//         return '';
//     }
//   }

//   /// الحصول على الصلاة القادمة (تتطلب تمرير الإحداثيات الآن)
//   Prayer getNextPrayer(Coordinates coordinates) {
//     final now = DateTime.now();
//     final prayerTimes = getPrayerTimes(now, coordinates);
//     return prayerTimes.nextPrayer();
//   }

//   /// الحصول على الصلاة القادمة
//   // Prayer getNextPrayer() {
//   //   final now = DateTime.now();
//   //   final prayerTimes = getPrayerTimes(now);
//   //   return prayerTimes.nextPrayer();
//   // }
// }
