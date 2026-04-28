import 'dart:async';
import 'package:athar/core/services/widget_data_service.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      emit(PrayerLoading()); // ✅ إضافة loading state

      // 1. جلب الإعدادات
      final settings = await _settingsRepository.getSettings();

      // 2. ✅ جلب مواقيت اليوم (PrayerTime بدلاً من adhan.PrayerTimes)
      final now = DateTime.now();
      final todayPrayers = await _prayerRepository.getPrayerTimesForDate(now);

      // 3. تحديد الصلاة القادمة
      PrayerTime? nextPrayer;
      try {
        // البحث عن أول صلاة وقتها بعد الآن
        nextPrayer = todayPrayers.firstWhere((p) => p.time.isAfter(now));
      } catch (e) {
        // إذا لم نجد (بعد العشاء)، نحسب فجر اليوم التالي
        final tomorrowPrayers = await _prayerRepository.getPrayerTimesForDate(
          now.add(const Duration(days: 1)),
        );

        nextPrayer = tomorrowPrayers.first.copyWith(isNext: true);
      }

      // 4. ✅ إرسال الحالة (بدون dependency على task feature)
      emit(
        PrayerLoaded(
          nextPrayer: nextPrayer,
          allPrayers: todayPrayers,
          cityName: settings.cityName ?? "الرياض",
        ),
      );

      // Push next prayer data to home screen widget (fire-and-forget)
      unawaited(
        _widgetDataService.pushPrayerData(
          nameAr: nextPrayer.nameArabic,
          nameEn: nextPrayer.nameEnglish,
          time: nextPrayer.time,
          city: settings.cityName ?? 'الرياض',
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
