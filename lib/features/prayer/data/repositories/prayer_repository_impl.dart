import 'package:adhan/adhan.dart' as adhan;
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/prayer_repository.dart';
import 'package:athar/features/prayer/domain/entities/prayer_time.dart';

@LazySingleton(as: PrayerRepository)
class PrayerRepositoryImpl implements PrayerRepository {
  final SettingsRepository _settingsRepository;

  PrayerRepositoryImpl(this._settingsRepository);

  @override
  Future<List<PrayerTime>> getPrayerTimesForDate(DateTime date) async {
    try {
      // 1. جلب الإعدادات المحفوظة
      final settings = await _settingsRepository.getSettings();

      // 2. استخدام إحداثيات المستخدم
      final coordinates = adhan.Coordinates(
        settings.latitude ?? 24.7136,
        settings.longitude ?? 46.6753,
      );

      // 3. إعدادات الحساب
      final params = adhan.CalculationMethod.umm_al_qura.getParameters();
      params.madhab = adhan.Madhab.shafi;

      // 4. تطبيق التعديلات من الإعدادات
      final adjustment = settings.prayerTimeAdjustmentMinutes;
      params.adjustments.fajr = adjustment;
      params.adjustments.dhuhr = adjustment;
      params.adjustments.asr = adjustment;
      params.adjustments.maghrib = adjustment;
      params.adjustments.isha = adjustment;

      final dateComponents = adhan.DateComponents(
        date.year,
        date.month,
        date.day,
      );

      // 5. ✅ احصل على adhan.PrayerTimes (هنا في Data layer - مسموح!)
      final adhanPrayerTimes = adhan.PrayerTimes(
        coordinates,
        dateComponents,
        params,
      );

      // 6. ✅ حوّل إلى PrayerTime (entity محلي) قبل الإرجاع
      return PrayerTime.fromAdhanPrayerTimes(adhanPrayerTimes);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting prayer times: $e');
      }
      rethrow;
    }
  }

  @override
  Future<PrayerTime?> getNextPrayer() async {
    try {
      final now = DateTime.now();
      final todayPrayers = await getPrayerTimesForDate(now);

      // البحث عن أول صلاة بعد الآن
      try {
        return todayPrayers.firstWhere((p) => p.time.isAfter(now));
      } catch (_) {
        // إذا انتهت صلوات اليوم، نُرجع فجر الغد
        final tomorrowPrayers = await getPrayerTimesForDate(
          now.add(const Duration(days: 1)),
        );

        // فجر الغد هو الصلاة القادمة
        return tomorrowPrayers.first.copyWith(isNext: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting next prayer: $e');
      }
      return null;
    }
  }
}

// import 'package:adhan/adhan.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:injectable/injectable.dart';
// import '../../domain/repositories/prayer_repository.dart';

// @LazySingleton(as: PrayerRepository)
// class PrayerRepositoryImpl implements PrayerRepository {
//   final SettingsRepository _settingsRepository; // ✅ حقن الإعدادات

//   PrayerRepositoryImpl(this._settingsRepository);

//   @override
//   Future<PrayerTimes> getPrayerTimes(DateTime date) async {
//     // 1. جلب الإعدادات المحفوظة
//     final settings = await _settingsRepository.getSettings();

//     // 2. استخدام إحداثيات المستخدم (أو الرياض كقيمة افتراضية إذا لم تحدد)
//     final coordinates = Coordinates(
//       settings.latitude ?? 24.7136,
//       settings.longitude ?? 46.6753,
//     );

//     // 3. إعدادات الحساب (يمكن أيضاً جلبها من Settings لو أردت دقة أعلى)
//     final params = CalculationMethod.umm_al_qura.getParameters();
//     params.madhab = Madhab.shafi;

//     final dateComponents = DateComponents(date.year, date.month, date.day);

//     return PrayerTimes(coordinates, dateComponents, params);
//   }
// }
