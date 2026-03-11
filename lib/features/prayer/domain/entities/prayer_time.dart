import 'package:equatable/equatable.dart';
import 'package:adhan/adhan.dart' as adhan;

/// أنواع الصلوات
enum PrayerType {
  fajr, // الفجر - 0
  sunrise, // الشروق - 1
  dhuhr, // الظهر - 2
  asr, // العصر - 3
  maghrib, // المغرب - 4
  isha, // العشاء - 5
}

/// ✅ كيان وقت الصلاة (Domain Entity)
///
/// هذا هو النوع المحلي الذي يجب استخدامه في جميع أنحاء التطبيق.
/// يعمل كـ adapter بين adhan package والتطبيق.
class PrayerTime extends Equatable {
  final PrayerType type;
  final DateTime time;
  final String nameArabic;
  final String nameEnglish;
  final bool isNext; // هل هي الصلاة القادمة؟

  const PrayerTime({
    required this.type,
    required this.time,
    required this.nameArabic,
    required this.nameEnglish,
    this.isNext = false,
  });

  /// ✅ تحويل من adhan.Prayer إلى PrayerTime
  factory PrayerTime.fromAdhan(adhan.Prayer adhanPrayer, DateTime time) {
    late PrayerType type;
    late String nameArabic;
    late String nameEnglish;

    switch (adhanPrayer) {
      case adhan.Prayer.fajr:
        type = PrayerType.fajr;
        nameArabic = 'الفجر';
        nameEnglish = 'Fajr';
        break;
      case adhan.Prayer.sunrise:
        type = PrayerType.sunrise;
        nameArabic = 'الشروق';
        nameEnglish = 'Sunrise';
        break;
      case adhan.Prayer.dhuhr:
        type = PrayerType.dhuhr;
        nameArabic = 'الظهر';
        nameEnglish = 'Dhuhr';
        break;
      case adhan.Prayer.asr:
        type = PrayerType.asr;
        nameArabic = 'العصر';
        nameEnglish = 'Asr';
        break;
      case adhan.Prayer.maghrib:
        type = PrayerType.maghrib;
        nameArabic = 'المغرب';
        nameEnglish = 'Maghrib';
        break;
      case adhan.Prayer.isha:
        type = PrayerType.isha;
        nameArabic = 'العشاء';
        nameEnglish = 'Isha';
        break;
      default:
        type = PrayerType.fajr;
        nameArabic = 'الفجر';
        nameEnglish = 'Fajr';
    }

    return PrayerTime(
      type: type,
      time: time,
      nameArabic: nameArabic,
      nameEnglish: nameEnglish,
    );
  }

  /// ✅ إنشاء قائمة من adhan.PrayerTimes
  static List<PrayerTime> fromAdhanPrayerTimes(adhan.PrayerTimes prayerTimes) {
    return [
      PrayerTime.fromAdhan(adhan.Prayer.fajr, prayerTimes.fajr),
      PrayerTime.fromAdhan(adhan.Prayer.sunrise, prayerTimes.sunrise),
      PrayerTime.fromAdhan(adhan.Prayer.dhuhr, prayerTimes.dhuhr),
      PrayerTime.fromAdhan(adhan.Prayer.asr, prayerTimes.asr),
      PrayerTime.fromAdhan(adhan.Prayer.maghrib, prayerTimes.maghrib),
      PrayerTime.fromAdhan(adhan.Prayer.isha, prayerTimes.isha),
    ];
  }

  /// ✅ نسخ مع تعديل
  PrayerTime copyWith({
    PrayerType? type,
    DateTime? time,
    String? nameArabic,
    String? nameEnglish,
    bool? isNext,
  }) {
    return PrayerTime(
      type: type ?? this.type,
      time: time ?? this.time,
      nameArabic: nameArabic ?? this.nameArabic,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      isNext: isNext ?? this.isNext,
    );
  }

  /// ✅ اسم مختصر (للعرض)
  String get name => nameArabic;

  @override
  List<Object?> get props => [type, time, nameArabic, nameEnglish, isNext];

  @override
  String toString() =>
      '$nameArabic ($nameEnglish) at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}
