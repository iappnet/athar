// lib/features/habits/presentation/widgets/habit_heatmap.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Part 3 | File 4
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/design_system.dart';

// ✅ OLD: import '../../../../core/design_system/themes/app_colors.dart';

class HabitHeatmap extends StatelessWidget {
  final Map<DateTime, int> datasets;

  const HabitHeatmap({super.key, required this.datasets});

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors & l10n from context
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        // ✅ AppColors.surface → colors.surface
        color: colors.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: AtharShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // ✅ l10n: "خارطة الالتزام"
            l10n.habitHeatmapTitle,
            style: AtharTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              // ✅ AppColors.textPrimary → colors.textPrimary
              color: colors.textPrimary,
            ),
          ),
          AtharGap.md,
          HeatMap(
            datasets: datasets,
            colorMode: ColorMode.opacity,
            showText: false,
            scrollable: true,
            startDate: DateTime.now().subtract(const Duration(days: 90)),
            endDate: DateTime.now().add(const Duration(days: 10)),
            colorsets: {
              // ✅ AppColors.primary → colors.primary
              1: colors.primary.withValues(alpha: 0.2),
              3: colors.primary.withValues(alpha: 0.4),
              5: colors.primary.withValues(alpha: 0.6),
              7: colors.primary.withValues(alpha: 0.8),
              10: colors.primary,
            },
            onClick: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  // ✅ l10n: "إنجازات يوم: {day}/{month}"
                  content: Text(
                    l10n.habitHeatmapDayAchievements(
                      value.day.toString(),
                      value.month.toString(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
