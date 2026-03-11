import '../entities/prayer_time.dart';

// ignore: unintended_html_in_doc_comment
/// ✅ Helper للعمل مع List<PrayerTime> بسهولة
class PrayerListHelper {
  final List<PrayerTime> prayers;

  const PrayerListHelper(this.prayers);

  /// الحصول على صلاة محددة
  PrayerTime? getPrayer(PrayerType type) {
    try {
      return prayers.firstWhere((p) => p.type == type);
    } catch (_) {
      return null;
    }
  }

  /// وقت الفجر
  DateTime get fajr => getPrayer(PrayerType.fajr)!.time;

  /// وقت الشروق
  DateTime get sunrise => getPrayer(PrayerType.sunrise)!.time;

  /// وقت الظهر
  DateTime get dhuhr => getPrayer(PrayerType.dhuhr)!.time;

  /// وقت العصر
  DateTime get asr => getPrayer(PrayerType.asr)!.time;

  /// وقت المغرب
  DateTime get maghrib => getPrayer(PrayerType.maghrib)!.time;

  /// وقت العشاء
  DateTime get isha => getPrayer(PrayerType.isha)!.time;

  /// ✅ الحصول على الصلاة الحالية
  PrayerTime? currentPrayer([DateTime? at]) {
    final now = at ?? DateTime.now();

    // الترتيب: العشاء -> الفجر -> الظهر -> العصر -> المغرب -> العشاء
    if (now.isBefore(fajr)) {
      return getPrayer(PrayerType.isha); // بعد منتصف الليل وقبل الفجر = العشاء
    } else if (now.isBefore(sunrise)) {
      return getPrayer(PrayerType.fajr);
    } else if (now.isBefore(dhuhr)) {
      return getPrayer(PrayerType.sunrise); // بين الشروق والظهر
    } else if (now.isBefore(asr)) {
      return getPrayer(PrayerType.dhuhr);
    } else if (now.isBefore(maghrib)) {
      return getPrayer(PrayerType.asr);
    } else if (now.isBefore(isha)) {
      return getPrayer(PrayerType.maghrib);
    } else {
      return getPrayer(PrayerType.isha);
    }
  }

  /// ✅ الحصول على الصلاة القادمة
  PrayerTime? nextPrayer([DateTime? at]) {
    final now = at ?? DateTime.now();

    // البحث عن أول صلاة بعد الآن (ما عدا الشروق)
    final futurePrayers = prayers
        .where((p) => p.time.isAfter(now) && p.type != PrayerType.sunrise)
        .toList();

    if (futurePrayers.isNotEmpty) {
      return futurePrayers.first;
    }

    // إذا لم نجد، الصلاة القادمة هي فجر الغد
    return null; // يجب جلب فجر الغد من خارج هذا الـ helper
  }

  /// ✅ الحصول على وقت صلاة محددة
  DateTime? timeForPrayer(PrayerType type) {
    return getPrayer(type)?.time;
  }

  /// ✅ التحقق: هل نحن في وقت الصلاة الحالية؟
  bool isInPrayerWindow(PrayerType type, {int bufferMinutes = 15}) {
    final prayer = getPrayer(type);
    if (prayer == null) return false;

    final now = DateTime.now();
    final start = prayer.time.subtract(Duration(minutes: bufferMinutes));
    final end = prayer.time.add(Duration(minutes: bufferMinutes));

    return now.isAfter(start) && now.isBefore(end);
  }
}
