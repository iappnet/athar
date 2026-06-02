import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
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
                        fontFamily: AtharTypography.fontFamily,
                        fontFamilyFallback: AtharTypography.fontFallback,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      DateFormat('d MMMM yyyy', 'ar').format(date),
                      style: TextStyle(
                        fontFamily: AtharTypography.fontFamily,
                        fontFamilyFallback: AtharTypography.fontFallback,
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
                              fontFamily: AtharTypography.fontFamily,
                              fontFamilyFallback: AtharTypography.fontFallback,
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
                          fontFamily: AtharTypography.fontFamily,
                          fontFamilyFallback: AtharTypography.fontFallback,
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
