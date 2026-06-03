import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/prayer_service.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../../../features/settings/presentation/cubit/settings_state.dart';
import '../../../../features/prayer/domain/entities/prayer_time.dart';

class PrayerWeekView extends StatelessWidget {
  const PrayerWeekView({super.key});

  @override
  Widget build(BuildContext context) {
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

    return ListView.builder(
      padding: AtharSpacing.allXl,
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = DateTime.now().add(Duration(days: index));
        final isToday = index == 0;
        return _buildDayRow(context, date, isToday, myCoordinates);
      },
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    DateTime date,
    bool isToday,
    Coordinates coordinates,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final prayerService = getIt<PrayerService>();
    final prayersList = prayerService.getPrayerTimes(date, coordinates);

    final times = <PrayerType, DateTime>{};
    for (final prayer in prayersList) {
      times[prayer.type] = prayer.time;
    }

    final dayName = DateFormat('EEEE', 'ar').format(date);
    final dayDate = DateFormat('d/M', 'en').format(date);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: isToday
            ? colorScheme.primary.withValues(alpha: 0.05)
            : colorScheme.surface,
        borderRadius: AtharRadii.card,
        border: Border.all(
          color: isToday
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          // Day header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayName,
                style: TextStyle(
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: AtharTypography.fontFallback,
                  fontWeight: FontWeight.bold,
                  color: isToday ? colorScheme.primary : colorScheme.onSurface,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                dayDate,
                style: TextStyle(
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: AtharTypography.fontFallback,
                  color: colorScheme.outline,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          AtharGap.sm,

          // Five prayer times
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeItem(
                colorScheme,
                l10n.prayerFajrShort,
                times[PrayerType.fajr]!,
              ),
              _buildTimeItem(
                colorScheme,
                l10n.prayerDhuhrShort,
                times[PrayerType.dhuhr]!,
              ),
              _buildTimeItem(
                colorScheme,
                l10n.prayerAsrShort,
                times[PrayerType.asr]!,
              ),
              _buildTimeItem(
                colorScheme,
                l10n.prayerMaghribShort,
                times[PrayerType.maghrib]!,
              ),
              _buildTimeItem(
                colorScheme,
                l10n.prayerIshaShort,
                times[PrayerType.isha]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(ColorScheme colorScheme, String label, DateTime time) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AtharTypography.fontFamily,
            fontFamilyFallback: AtharTypography.fontFallback,
            fontSize: 10.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AtharGap.xxxs,
        Text(
          DateFormat('h:mm', 'en').format(time),
          style: TextStyle(
            fontFamily: AtharTypography.fontFamily,
            fontFamilyFallback: AtharTypography.fontFallback,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
