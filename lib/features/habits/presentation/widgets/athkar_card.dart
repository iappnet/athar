// lib/features/habits/presentation/widgets/athkar_card.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Bonus | athkar_card.dart
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import '../../data/models/habit_model.dart';
import '../../../dhikr/presentation/widgets/dhikr_bottom_sheet.dart';

class AthkarCard extends StatelessWidget {
  final HabitModel habit;

  const AthkarCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isMorning = habit.period == HabitPeriod.morning;

    final cardColor = isMorning
        ? const Color(0xFFFFF8E1)
        : const Color(0xFFE8F5EF);

    final iconColor = isMorning ? Colors.orange : colorScheme.primary;

    final iconData = isMorning
        ? Icons.wb_sunny_rounded
        : Icons.nights_stay_rounded;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DhikrBottomSheet(habit: habit),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AtharSpacing.sm, horizontal: AtharSpacing.xxs),
        padding: EdgeInsets.symmetric(vertical: AtharSpacing.xl, horizontal: AtharSpacing.xxl),
        decoration: BoxDecoration(
          color: cardColor,
          // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
          borderRadius: AtharRadii.radiusLg,
          boxShadow: AtharShadows.card,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              habit.title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                // ✅ Colors.black87 → colors.textPrimary
                color: colorScheme.onSurface,
              ),
            ),
            Icon(iconData, size: 28.sp, color: iconColor),
          ],
        ),
      ),
    );
  }
}
