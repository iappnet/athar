import 'package:athar/features/prayer/domain/entities/prayer_time.dart';

/// ✅ Repository للصلاة (Domain Layer - نظيف ومستقل)
abstract class PrayerRepository {
  /// جلب مواقيت الصلاة لتاريخ محدد
  ///
  /// يُرجع قائمة من PrayerTime (entity محلي)
  /// بدلاً من adhan.PrayerTimes (external dependency)
  Future<List<PrayerTime>> getPrayerTimesForDate(DateTime date);

  /// ✅ إضافة: جلب الصلاة القادمة مباشرة
  Future<PrayerTime?> getNextPrayer();
}

// import 'package:adhan/adhan.dart'; // تأكد أن مكتبة adhan مضافة في pubspec.yaml

// abstract class PrayerRepository {
//   /// جلب مواقيت الصلاة لتاريخ محدد بناءً على الإحداثيات والإعدادات
//   Future<PrayerTimes> getPrayerTimes(DateTime date);
// }
