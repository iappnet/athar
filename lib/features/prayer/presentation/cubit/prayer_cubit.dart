import 'dart:async';
import 'package:athar/core/services/widget_data_service.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/prayer_repository.dart';
import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
import 'prayer_state.dart';

@injectable
class PrayerCubit extends Cubit<PrayerState> {
  final PrayerRepository _prayerRepository;
  final SettingsRepository _settingsRepository;
  final WidgetDataService _widgetDataService;
  Timer? _timer;

  PrayerCubit({
    required PrayerRepository prayerRepository,
    required SettingsRepository settingsRepository,
    required WidgetDataService widgetDataService,
  }) : _prayerRepository = prayerRepository,
       _settingsRepository = settingsRepository,
       _widgetDataService = widgetDataService,
       super(PrayerInitial());

  Future<void> loadPrayerTimes() async {
    try {
      emit(PrayerLoading());

      // Read app locale — stored by LocaleCubit under 'preferred_locale'.
      // null → key deleted → system default; guard against 'ar' fallback here
      // so the widget receives 'system' instead of a forced locale.
      const storage = FlutterSecureStorage();
      final locale = await storage.read(key: 'preferred_locale') ?? 'system';

      // 1. جلب الإعدادات
      final settings = await _settingsRepository.getSettings();

      // 2. جلب مواقيت اليوم
      final now = DateTime.now();
      final todayPrayers = await _prayerRepository.getPrayerTimesForDate(now);

      // 3. تحديد الصلاة القادمة والسابقة
      // prayersForProgress excludes sunrise so the widget bar always spans
      // two actual prayer times (Fajr→Dhuhr, not Sunrise→Dhuhr).
      final prayersForProgress = todayPrayers
          .where((p) => p.type != PrayerType.sunrise)
          .toList();

      PrayerTime? nextPrayer;
      PrayerTime? prevPrayer;
      try {
        final nextIdx = todayPrayers.indexWhere((p) => p.time.isAfter(now));
        nextPrayer = todayPrayers[nextIdx];
        // Find the last non-sunrise prayer before nextPrayer by time.
        final candidates = prayersForProgress
            .where((p) => !p.time.isAfter(now))
            .toList();
        prevPrayer = candidates.isNotEmpty ? candidates.last : null;
      } catch (e) {
        final tomorrowPrayers = await _prayerRepository.getPrayerTimesForDate(
          now.add(const Duration(days: 1)),
        );
        nextPrayer = tomorrowPrayers.first.copyWith(isNext: true);
        prevPrayer = prayersForProgress.isNotEmpty
            ? prayersForProgress.last
            : null;
      }

      // 4. Compute nafl windows (mirrors PrayerTimerService._emitStatus logic)
      bool isDuhaTime = false;
      bool isQiyamTime = false;
      try {
        final sunrise = todayPrayers.firstWhere(
          (p) => p.type == PrayerType.sunrise,
        );
        final dhuhr = todayPrayers.firstWhere(
          (p) => p.type == PrayerType.dhuhr,
        );
        final duhaStart = sunrise.time.add(const Duration(minutes: 15));
        final duhaEnd = dhuhr.time.subtract(const Duration(minutes: 15));
        isDuhaTime = now.isAfter(duhaStart) && now.isBefore(duhaEnd);
      } catch (_) {}
      try {
        final isha = todayPrayers.lastWhere((p) => p.type == PrayerType.isha);
        final fajr = todayPrayers.firstWhere(
          (p) => p.type == PrayerType.fajr,
        );
        final DateTime nightStart;
        final DateTime nightEnd;
        if (now.hour >= 12) {
          nightStart = isha.time;
          nightEnd = fajr.time.add(const Duration(days: 1));
        } else {
          nightStart = isha.time.subtract(const Duration(days: 1));
          nightEnd = fajr.time;
        }
        final duration = nightEnd.difference(nightStart);
        final lastThirdStart = nightEnd.subtract(
          Duration(minutes: (duration.inMinutes / 3).round()),
        );
        isQiyamTime = now.isAfter(lastThirdStart) && now.isBefore(nightEnd);
      } catch (_) {}

      // 5. إرسال الحالة
      emit(
        PrayerLoaded(
          nextPrayer: nextPrayer,
          allPrayers: todayPrayers,
          cityName: settings.cityName ?? 'Riyadh',
        ),
      );

      // Push next prayer data to home screen widget (fire-and-forget)
      unawaited(
        _widgetDataService.pushPrayerData(
          nameAr: nextPrayer.nameArabic,
          nameEn: nextPrayer.nameEnglish,
          prayerType: nextPrayer.type.name,
          time: nextPrayer.time,
          prevTime: prevPrayer?.time,
          prevNameAr: prevPrayer?.nameArabic ?? '',
          prevNameEn: prevPrayer?.nameEnglish ?? '',
          city: settings.cityName ?? 'Riyadh',
          locale: locale,
          isDuhaTime: isDuhaTime,
          isQiyamTime: isQiyamTime,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error loading prayer times: $e');
      emit(const PrayerError("فشل في تحميل مواقيت الصلاة"));
    }
  }

  /// ✅ إضافة: تحديث تلقائي كل دقيقة
  void startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      loadPrayerTimes();
    });
  }

  void stopAutoRefresh() {
    _timer?.cancel();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

// import 'dart:async';
// import 'package:adhan/adhan.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';
// import '../../../task/data/models/prayer_item.dart';
// import 'prayer_state.dart';

// @injectable
// class PrayerCubit extends Cubit<PrayerState> {
//   final SettingsRepository _settingsRepository;
//   Timer? _timer;

//   // ✅ إصلاح: إزالة الشرطة السفلية من المتغير في الـ Constructor
//   PrayerCubit({required SettingsRepository settingsRepository})
//     : _settingsRepository = settingsRepository,
//       super(PrayerInitial());

//   Future<void> loadPrayerTimes() async {
//     try {
//       // 1. جلب الإعدادات
//       final settings = await _settingsRepository.getSettings();

//       // 2. تحديد الإحداثيات
//       final myCoordinates = Coordinates(
//         settings.latitude ?? 24.7136,
//         settings.longitude ?? 46.6753,
//       );

//       final params = CalculationMethod.umm_al_qura.getParameters();
//       params.madhab = Madhab.shafi;

//       final now = DateTime.now();
//       final dateComponents = DateComponents.from(now);
//       // تعديل الوقت يدوياً إذا وجد في الإعدادات
//       params.adjustments.fajr = settings.prayerTimeAdjustmentMinutes;
//       params.adjustments.dhuhr = settings.prayerTimeAdjustmentMinutes;
//       params.adjustments.asr = settings.prayerTimeAdjustmentMinutes;
//       params.adjustments.maghrib = settings.prayerTimeAdjustmentMinutes;
//       params.adjustments.isha = settings.prayerTimeAdjustmentMinutes;

//       // كائن المواقيت من مكتبة Adhan
//       final prayerTimes = PrayerTimes(myCoordinates, dateComponents, params);

//       // 3. تحويل Adhan PrayerTimes إلى قائمتنا الخاصة List<PrayerItem>
//       final prayersList = [
//         PrayerItem(name: 'الفجر', time: prayerTimes.fajr),
//         PrayerItem(name: 'الشروق', time: prayerTimes.sunrise),
//         PrayerItem(name: 'الظهر', time: prayerTimes.dhuhr),
//         PrayerItem(name: 'العصر', time: prayerTimes.asr),
//         PrayerItem(name: 'المغرب', time: prayerTimes.maghrib),
//         PrayerItem(name: 'العشاء', time: prayerTimes.isha),
//       ];

//       // 4. تحديد الصلاة القادمة
//       PrayerItem? nextPrayerItem;
//       try {
//         // البحث عن أول صلاة وقتها بعد الآن
//         nextPrayerItem = prayersList.firstWhere((p) => p.time.isAfter(now));
//       } catch (e) {
//         // إذا لم نجد (بعد العشاء)، نحسب فجر اليوم التالي
//         final nextDayParams = CalculationMethod.umm_al_qura.getParameters();
//         final nextDayDate = DateComponents.from(
//           now.add(const Duration(days: 1)),
//         );
//         final nextDayPrayerTimes = PrayerTimes(
//           myCoordinates,
//           nextDayDate,
//           nextDayParams,
//         );

//         nextPrayerItem = PrayerItem(
//           name: 'الفجر',
//           time: nextDayPrayerTimes.fajr,
//           isNext: true,
//         );
//       }

//       // 5. إرسال الحالة الصحيحة
//       emit(
//         PrayerLoaded(
//           nextPrayer: nextPrayerItem,
//           allPrayers: prayersList, // ✅ تم تمرير القائمة المطلوبة
//           cityName: settings.cityName ?? "الرياض", // ✅ تم تمرير اسم المدينة
//         ),
//       );
//     } catch (e) {
//       emit(const PrayerError("فشل في تحميل مواقيت الصلاة"));
//     }
//   }

//   @override
//   Future<void> close() {
//     _timer?.cancel();
//     return super.close();
//   }
// }
