// lib/features/home/presentation/pages/smart_habits_strip.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.5
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

import '../../../habits/presentation/cubit/habit_cubit.dart';
import '../../../habits/presentation/cubit/habit_state.dart';
import '../../../habits/data/models/habit_model.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../../../settings/data/models/user_settings.dart';
import '../../../dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
import '../../../habits/presentation/widgets/athkar_session_sheet.dart';

class SmartHabitsStrip extends StatelessWidget {
  const SmartHabitsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors from context
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
          child: Text(
            l10n.myHabitsToday,
            // ✅ AtharTypography
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ).copyWith(color: colorScheme.onSurface),
          ),
        ),
        // ✅ SizedBox(height: 12.h) → AtharGap.md
        AtharGap.md,
        SizedBox(
          height: 90.h,
          child: BlocBuilder<HabitCubit, HabitState>(
            builder: (context, state) {
              if (state is HabitLoaded) {
                final List<HabitModel> allVisibleHabits = [
                  ...state.cardAthkar,
                  ...state.dawnHabits,
                  ...state.bakurHabits,
                  ...state.morningHabits,
                  ...state.noonHabits,
                  ...state.afternoonHabits,
                  ...state.maghribHabits,
                  ...state.ishaHabits,
                  ...state.nightHabits,
                  ...state.lastThirdHabits,
                  ...state.anyTimeHabits,
                ];

                final activeHabits = allVisibleHabits
                    .where((h) => !h.isCompleted)
                    .toSet()
                    .toList();

                if (activeHabits.isEmpty) {
                  return _buildEmptyState(context, colorScheme);
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
                  itemCount: activeHabits.length,
                  // ✅ SizedBox(width: 12.w) → AtharGap.hMd
                  separatorBuilder: (context, index) => AtharGap.hMd,
                  itemBuilder: (context, index) {
                    final habit = activeHabits[index];
                    return _buildMiniHabitCard(context, colorScheme, habit);
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMiniHabitCard(
    BuildContext context,
    ColorScheme colorScheme,
    HabitModel habit,
  ) {
    final isAthkar = habit.type == HabitType.athkar;

    return GestureDetector(
      onTap: () {
        if (isAthkar) {
          _openAthkarSheetCorrectly(context, habit);
        } else {
          context.read<HabitCubit>().toggleHabitOnDate(
            habit.id,
            DateTime.now(),
          );
        }
      },
      child: Container(
        width: 100.w,
        // ✅ EdgeInsets.all(12.w) → AtharSpacing.allMd
        padding: AtharSpacing.allMd,
        decoration: BoxDecoration(
          // ✅ AppColors.surface → colors.surface
          color: colorScheme.surface,
          // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
          borderRadius: AtharRadii.radiusLg,
          // ✅ AppColors.primary.withValues(alpha: 0.1)
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AtharSpacing.sm),
              decoration: BoxDecoration(
                // ✅ Colors.orange / AppColors.primary
                color: isAthkar
                    ? context.colors.warning.withValues(alpha: 0.1)
                    : colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAthkar ? Icons.wb_sunny_outlined : Icons.check,
                size: 18.sp,
                color: isAthkar ? context.colors.warning : colorScheme.primary,
              ),
            ),
            // ✅ SizedBox(height: 8.h) → AtharGap.sm
            AtharGap.sm,
            Text(
              habit.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // ✅ AtharTypography
              style:
                  TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      // ✅ EdgeInsets.all(12.w) → AtharSpacing.allMd
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        // ✅ Colors.green.withValues(alpha: 0.05) → colors.success
        color: context.colors.success.withValues(alpha: 0.05),
        // ✅ BorderRadius.circular(12.r) → AtharRadii.radiusMd
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: context.colors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, color: context.colors.success, size: 20.sp),
          // ✅ SizedBox(width: 8.w) → AtharGap.hSm
          AtharGap.hSm,
          Text(
            l10n.greatJobCompletedCurrentTasks,
            // ✅ AtharTypography
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ).copyWith(color: context.colors.success),
          ),
        ],
      ),
    );
  }

  void _openAthkarSheetCorrectly(BuildContext context, HabitModel habit) {
    final settingsState = context.read<SettingsCubit>().state;
    AthkarSessionViewMode viewMode = AthkarSessionViewMode.list;

    if (settingsState is SettingsLoaded) {
      viewMode = settingsState.settings.athkarSessionViewMode;
    }

    if (viewMode == AthkarSessionViewMode.list) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => BlocProvider.value(
          value: context.read<HabitCubit>(),
          child: DhikrBottomSheet(habit: habit),
        ),
      );
    } else {
      AthkarSessionSheet.show(context, habit);
    }
  }
}

