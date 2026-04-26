import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/hijri_service.dart';
import '../../../../core/services/prayer_service.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrayerDayView extends StatelessWidget {
  final DateTime date;

  const PrayerDayView({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final prayerService = getIt<PrayerService>();
    final hijriService = getIt<HijriService>();

    final settingsState = context.watch<SettingsCubit>().state;
    Coordinates myCoordinates;

    if (settingsState is SettingsLoaded) {
      myCoordinates = Coordinates(
        settingsState.settings.latitude ?? 24.7136,
        settingsState.settings.longitude ?? 46.6753,
      );
    } else {
      myCoordinates = Coordinates(24.7136, 46.6753);
    }

    final prayers = prayerService.getPrayerTimes(date, myCoordinates);

    final isToday =
        date.day == DateTime.now().day && date.month == DateTime.now().month;

    PrayerTime? nextPrayer;
    if (isToday) {
      final now = DateTime.now();
      final upcoming = prayers.where((p) => p.time.isAfter(now));
      nextPrayer = upcoming.isEmpty ? null : upcoming.first;
    }

    return Padding(
      padding: AtharSpacing.allXl,
      child: Column(
        children: [
          // Date header
          Container(
            padding: AtharSpacing.allXl,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: AtharRadii.radiusLg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
                AtharGap.hSm,
                Column(
                  children: [
                    Text(
                      hijriService.getDayAndHijriMonth(date),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      DateFormat('d MMMM yyyy', 'ar').format(date),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          AtharGap.xl,

          // Prayer list
          Expanded(
            child: ListView.separated(
              itemCount: prayers.length,
              separatorBuilder: (context, index) => AtharGap.md,
              itemBuilder: (context, index) {
                final prayer = prayers[index];
                final isNext =
                    nextPrayer != null && prayer.type == nextPrayer.type;

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isNext ? colorScheme.primary : colorScheme.surface,
                    borderRadius: AtharRadii.card,
                    border: Border.all(
                      color: isNext
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                    boxShadow: [
                      if (isNext)
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            prayer.name == l10n.prayerSunrise
                                ? Icons.wb_sunny_outlined
                                : Icons.access_time,
                            color: isNext
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            size: 20.sp,
                          ),
                          AtharGap.hMd,
                          Text(
                            prayer.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: isNext
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isNext
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        DateFormat('h:mm a', 'ar').format(prayer.time),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isNext
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/services/hijri_service.dart';
// import '../../../../core/services/prayer_service.dart';
// import 'package:adhan/adhan.dart'; // ✅ إضافة استيراد adhan للإحداثيات
// import 'package:flutter_bloc/flutter_bloc.dart'; // ✅ لاستخدام context.read/watch

// class PrayerDayView extends StatelessWidget {
//   final DateTime date;

//   const PrayerDayView({super.key, required this.date});

//   @override
//   Widget build(BuildContext context) {
//     final prayerService = getIt<PrayerService>();
//     final hijriService = getIt<HijriService>();

//     // حساب المواقيت لهذا التاريخ
//     // final prayerTimes = prayerService.getPrayerTimes(date);

//     // 1. ✅ جلب الإعدادات الحالية للوصول للإحداثيات
//     final settingsState = context.watch<SettingsCubit>().state;
//     Coordinates myCoordinates;

//     if (settingsState is SettingsLoaded) {
//       myCoordinates = Coordinates(
//         settingsState.settings.latitude ?? 24.7136, // الرياض كقيمة احتياطية فقط
//         settingsState.settings.longitude ?? 46.6753,
//       );
//     } else {
//       myCoordinates = Coordinates(24.7136, 46.6753);
//     }

//     // 2. ✅ تمرير الإحداثيات للدالة
//     final prayers = prayerService.getPrayerTimes(date, myCoordinates);

//     // قائمة الصلوات
//     // final prayers = [
//     //   PrayerItem(name: 'الفجر', time: prayerTimes.fajr),
//     //   PrayerItem(name: 'الشروق', time: prayerTimes.sunrise),
//     //   PrayerItem(name: 'الظهر', time: prayerTimes.dhuhr),
//     //   PrayerItem(name: 'العصر', time: prayerTimes.asr),
//     //   PrayerItem(name: 'المغرب', time: prayerTimes.maghrib),
//     //   PrayerItem(name: 'العشاء', time: prayerTimes.isha),
//     // ];

//     // تحديد الصلاة القادمة (لتمييزها) - فقط إذا كان التاريخ هو اليوم
//     final isToday =
//         date.day == DateTime.now().day && date.month == DateTime.now().month;

//     PrayerTime? nextPrayer;
//     if (isToday) {
//       final now = DateTime.now();
//       try {
//         nextPrayer = prayers.firstWhere((p) => p.time.isAfter(now));
//       } catch (_) {}
//     }

//     return Padding(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         children: [
//           // رأس الصفحة: التاريخ
//           Container(
//             padding: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(16.r),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.calendar_today,
//                   color: AppColors.primary,
//                   size: 20.sp,
//                 ),
//                 SizedBox(width: 8.w),
//                 Column(
//                   children: [
//                     Text(
//                       hijriService.getDayAndHijriMonth(date),
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14.sp,
//                         fontFamily: 'Cairo',
//                         color: AppColors.primary,
//                       ),
//                     ),
//                     Text(
//                       DateFormat('d MMMM yyyy', 'ar').format(date),
//                       style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           SizedBox(height: 20.h),

//           // قائمة الصلوات
//           Expanded(
//             child: ListView.separated(
//               itemCount: prayers.length,
//               separatorBuilder: (context, index) => SizedBox(height: 12.h),
//               itemBuilder: (context, index) {
//                 final prayer = prayers[index];
//                 // final isNext = nextPrayer == prayer;
//                 final isNext =
//                     nextPrayer != null && prayer.type == nextPrayer.type;

//                 return Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.w,
//                     vertical: 12.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isNext ? AppColors.primary : Colors.white,
//                     borderRadius: BorderRadius.circular(12.r),
//                     border: Border.all(
//                       color: isNext ? AppColors.primary : Colors.grey.shade200,
//                     ),
//                     boxShadow: [
//                       if (isNext)
//                         BoxShadow(
//                           color: AppColors.primary.withValues(alpha: 0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             // أيقونة مختلفة للشروق
//                             prayer.name == 'الشروق'
//                                 ? Icons.wb_sunny_outlined
//                                 : Icons.access_time,
//                             color: isNext
//                                 ? Colors.white
//                                 : AppColors.textPrimary,
//                             size: 20.sp,
//                           ),
//                           SizedBox(width: 12.w),
//                           Text(
//                             prayer.name,
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               fontWeight: isNext
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                               color: isNext
//                                   ? Colors.white
//                                   : AppColors.textPrimary,
//                               fontFamily: 'Cairo',
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         DateFormat('h:mm a', 'ar').format(prayer.time),
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                           color: isNext ? Colors.white : AppColors.textPrimary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
