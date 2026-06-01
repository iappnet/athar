import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/constants/athkar_data.dart';
import 'package:athar/core/time_engine/athar_time_calculator.dart';
import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';

class AthkarDashboardCard extends StatelessWidget {
  const AthkarDashboardCard({super.key});

  DhikrTiming _currentTiming() {
    final period = AtharTimeCalculator.approximatePeriod();
    switch (period) {
      case AtharTimePeriod.dawn:
      case AtharTimePeriod.bakur:
      case AtharTimePeriod.morning:
      case AtharTimePeriod.duha:
      case AtharTimePeriod.noon:
        return DhikrTiming.morning;
      default:
        return DhikrTiming.evening;
    }
  }

  int _countForTiming(DhikrTiming timing) =>
      AthkarData.allAthkar.where((s) => s.timings.contains(timing)).length;

  int _minsForTiming(DhikrTiming timing) {
    final totalTaps = AthkarData.allAthkar
        .where((s) => s.timings.contains(timing))
        .fold<int>(0, (sum, s) => sum + s.count);
    return (totalTaps * 3 / 60).ceil().clamp(1, 60);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType ||
          (curr is SettingsLoaded &&
              prev is SettingsLoaded &&
              prev.settings.isAthkarEnabled != curr.settings.isAthkarEnabled),
      builder: (context, state) {
        final isEnabled =
            state is SettingsLoaded ? state.settings.isAthkarEnabled : true;
        if (!isEnabled) return const SizedBox.shrink();

        final timing = _currentTiming();
        final l10n = AppLocalizations.of(context);
        final colorScheme = Theme.of(context).colorScheme;
        final count = _countForTiming(timing);
        final mins = _minsForTiming(timing);

        final setName = timing == DhikrTiming.morning
            ? l10n.morningAthkar
            : l10n.eveningAthkar;
        final setIcon = timing == DhikrTiming.morning
            ? Icons.wb_sunny_rounded
            : Icons.nights_stay_rounded;
        final setColor = timing == DhikrTiming.morning
            ? AppColors.athkarMorning
            : AppColors.athkarEvening;

        return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/athkar'),
          child: Container(
            padding: EdgeInsets.all(AtharSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: setColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(setIcon, color: setColor, size: 22.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.athkar,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AtharGap.xxs,
                      Text(
                        setName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Calibri',
                          fontFamilyFallback: AtharTypography.fontFallback,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      AtharGap.xxs,
                      Row(
                        children: [
                          Text(
                            l10n.athkarDhikrCount(count),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: colorScheme.onSurfaceVariant,
                              fontFeatures: [
                                const FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text('·',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: colorScheme.onSurfaceVariant)),
                          SizedBox(width: 6.w),
                          Text(
                            l10n.athkarApproxMins(mins),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: colorScheme.onSurfaceVariant,
                              fontFeatures: [
                                const FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pushNamed('/athkar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: AtharRadii.radiusMd,
                    ),
                  ),
                  child: Text(
                    l10n.habitsStartButton,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
