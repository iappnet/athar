import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import '../../../../core/constants/athkar_data.dart';
import '../../data/models/dhikr_model.dart';
import '../cubit/dhikr_cubit.dart';
import 'dhikr_reader_screen.dart';

class AthkarSetScreen extends StatelessWidget {
  const AthkarSetScreen({super.key});

  int _countForTiming(DhikrTiming timing) =>
      AthkarData.allAthkar.where((s) => s.timings.contains(timing)).length;

  int _minsForTiming(DhikrTiming timing) {
    final totalTaps = AthkarData.allAthkar
        .where((s) => s.timings.contains(timing))
        .fold<int>(0, (sum, s) => sum + s.count);
    return (totalTaps * 3 / 60).ceil().clamp(1, 60);
  }

  String _setName(DhikrCategory category, AppLocalizations l10n) {
    switch (category) {
      case DhikrCategory.morning:
        return l10n.morningAthkar;
      case DhikrCategory.evening:
        return l10n.eveningAthkar;
      case DhikrCategory.prayer:
        return l10n.afterPrayerAthkar;
      case DhikrCategory.sleep:
        return l10n.sleepAthkar;
      case DhikrCategory.custom:
        return l10n.athkar;
    }
  }

  void _openReader(BuildContext context, DhikrCategory category) {
    final cubit = getIt<DhikrCubit>()..loadAthkar(category);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => cubit,
          child: DhikrReaderScreen(category: category),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    final isEnabled =
        settingsState is SettingsLoaded ? settingsState.settings.isAthkarEnabled : true;
    if (!isEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final sets = [
      _SetData(DhikrCategory.morning, DhikrTiming.morning,
          Icons.wb_sunny_rounded, AtharColors.athkarMorning),
      _SetData(DhikrCategory.evening, DhikrTiming.evening,
          Icons.nights_stay_rounded, AtharColors.athkarEvening),
      _SetData(DhikrCategory.prayer, DhikrTiming.prayer,
          Icons.mosque_rounded, AtharColors.athkarPrayer),
      _SetData(DhikrCategory.sleep, DhikrTiming.sleep,
          Icons.bedtime_rounded, AtharColors.athkarSleep),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          l10n.athkarSetScreenTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AtharSpacing.lg),
          children: [
            AtharGap.md,
            for (final s in sets)
              _SetCard(
                name: _setName(s.category, l10n),
                icon: s.icon,
                iconColor: s.color,
                count: _countForTiming(s.timing),
                mins: _minsForTiming(s.timing),
                onTap: () => _openReader(context, s.category),
                l10n: l10n,
                colorScheme: colorScheme,
              ),
          ],
        ),
      ),
    );
  }
}

class _SetData {
  final DhikrCategory category;
  final DhikrTiming timing;
  final IconData icon;
  final Color color;
  const _SetData(this.category, this.timing, this.icon, this.color);
}

class _SetCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color iconColor;
  final int count;
  final int mins;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  const _SetCard({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.mins,
    required this.onTap,
    required this.l10n,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(AtharSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 26.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 17.sp,
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
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text('·',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: colorScheme.onSurfaceVariant)),
                      SizedBox(width: 8.w),
                      Text(
                        l10n.athkarApproxMins(mins),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
