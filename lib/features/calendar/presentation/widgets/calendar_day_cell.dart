import 'package:athar/core/design_system/tokens/athar_colors.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:athar/features/calendar/domain/entities/activity_set.dart';
import 'package:athar/features/calendar/domain/entities/dual_date.dart';
import 'package:athar/features/calendar/domain/entities/hijri_abbreviations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Renders a single day cell with both Gregorian and Hijri numerals.
/// Layout per CALENDAR_CELL_SPEC §1 (top-center primary, bottom-center secondary).
/// CALENDAR_CELL_SPEC is the numeral-position authority; CALENDAR_FOCUS_REDESIGN is superseded.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.dualDate,
    required this.primaryHijri,
    required this.isToday,
    required this.isSelected,
    required this.isOtherMonth,
    required this.activity,
    required this.easternNumerals,
    required this.cellHeight,
    required this.onTap,
  });

  final DualDate dualDate;
  final bool primaryHijri;
  final bool isToday;
  final bool isSelected;
  final bool isOtherMonth;
  final ActivitySet activity;
  final bool easternNumerals;
  final double cellHeight;
  final VoidCallback onTap;

  String _fmt(int n) {
    if (!easternNumerals) return n.toString();
    const e = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? e[d] : c;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bool isBoundary =
        dualDate.isFirstOfHijriMonth && !isSelected;

    // Background color per state table.
    Color bgColor;
    if (isSelected) {
      bgColor = colors.primary;
    } else if (isToday) {
      bgColor = colors.primary.withValues(alpha: 0.08);
    } else {
      bgColor = Colors.transparent;
    }

    // Primary ink (large numeral).
    Color primaryInk;
    if (isSelected) {
      primaryInk = colors.onPrimary;
    } else if (isToday) {
      primaryInk = colors.primary;
    } else if (isOtherMonth) {
      primaryInk = colors.textTertiary;
    } else {
      primaryInk = colors.textPrimary;
    }

    // Secondary ink (small numeral / abbreviation / dots).
    Color secondaryInk;
    if (isSelected) {
      secondaryInk = colors.onPrimary.withValues(alpha: 0.78);
    } else if (isOtherMonth) {
      secondaryInk = colors.textTertiary;
    } else {
      secondaryInk = colors.primary;
    }

    final int primaryNum =
        primaryHijri ? dualDate.hijri.hDay : dualDate.gregorian.day;
    final int secondaryNum =
        primaryHijri ? dualDate.gregorian.day : dualDate.hijri.hDay;

    // Boundary abbreviation — replaces secondary numeral when isFirstOfHijriMonth.
    String? boundaryAbbr;
    if (isBoundary) {
      final hMonth = dualDate.hijri.hMonth;
      boundaryAbbr = primaryHijri
          ? HijriAbbreviations.getArabic(hMonth)
          : HijriAbbreviations.getLatin(hMonth);
    }

    final bool boldPrimary = isToday || isSelected;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Stack(
          children: [
            // Hijri-month boundary hairline (top edge, 2pt, 4pt inset).
            if (isBoundary)
              Positioned(
                top: 0,
                left: 4,
                right: 4,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: colors.primaryLight,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

            // Primary numeral — top-center, 4pt from top.
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _fmt(primaryNum),
                  style: TextStyle(
                    fontSize: AtharTypography.sizeMd.sp,
                    fontWeight: boldPrimary
                        ? AtharTypography.bold
                        : AtharTypography.regular,
                    color: primaryInk,
                    height: 1.1,
                  ),
                ),
              ),
            ),

            // Activity dots — middle row (~24pt from top).
            if (!isSelected && !activity.isEmpty)
              Positioned(
                top: 24,
                left: 0,
                right: 0,
                child: _ActivityDotsRow(
                  activity: activity,
                  colors: colors,
                ),
              ),

            // Secondary slot — bottom-center, 3pt from bottom.
            Positioned(
              bottom: 3,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  boundaryAbbr ?? _fmt(secondaryNum),
                  style: TextStyle(
                    fontSize: AtharTypography.sizeXxs.sp,
                    fontWeight: AtharTypography.medium,
                    color: secondaryInk,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityDotsRow extends StatelessWidget {
  const _ActivityDotsRow({required this.activity, required this.colors});

  final ActivitySet activity;
  final AtharColors colors;

  @override
  Widget build(BuildContext context) {
    final dots = <Color>[];
    if (activity.hasTask) dots.add(colors.info);
    if (activity.hasHabit) dots.add(colors.success);
    if (activity.hasAppointment) dots.add(colors.warning);
    if (activity.hasMedicine) dots.add(colors.secondary);
    if (activity.hasPrayer) dots.add(colors.primary);

    final bool overflow = dots.length > 4;
    final visible = overflow ? dots.take(4).toList() : dots;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...visible.map(
          (c) => Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
        ),
        if (overflow)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 1),
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 7,
                color: colors.textTertiary,
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}
