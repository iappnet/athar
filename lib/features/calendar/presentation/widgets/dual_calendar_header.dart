import 'package:athar/core/design_system/tokens/athar_colors.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// Calendar header per CALENDAR_CELL_SPEC §2 (title + chevron navigation).
/// DualMonthSwitcher (pill rows) is deferred; chevron nav is kept.
class DualCalendarHeader extends StatelessWidget {
  const DualCalendarHeader({
    super.key,
    required this.focusedMonth,
    required this.primaryHijri,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime focusedMonth;
  final bool primaryHijri;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    // Gregorian title string.
    final gregStr =
        DateFormat('MMMM yyyy', locale == 'ar' ? 'ar' : 'en').format(focusedMonth);

    // Hijri span — the Hijri month at the 1st and 15th of the Gregorian month,
    // to capture both Hijri months that may span a Gregorian month.
    final hijriFirst = HijriCalendar.fromDate(focusedMonth);
    final mid = DateTime(focusedMonth.year, focusedMonth.month, 15);
    final hijriMid = HijriCalendar.fromDate(mid);
    final String hijriStr;
    if (hijriFirst.hMonth == hijriMid.hMonth) {
      hijriStr = '${hijriFirst.longMonthName} ${hijriFirst.hYear}';
    } else {
      hijriStr =
          '${hijriFirst.longMonthName} – ${hijriMid.longMonthName} ${hijriMid.hYear}';
    }

    final String primaryTitle = primaryHijri ? hijriStr : gregStr;
    final String secondaryTitle = primaryHijri ? gregStr : hijriStr;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          color: colors.textSecondary,
          iconSize: 24,
          onPressed: onPrevMonth,
        ),
        Expanded(
          child: Column(
            children: [
              // Eyebrow.
              Text(
                l10n.calendarTitle,
                style: TextStyle(
                  fontSize: AtharTypography.sizeXs.sp,
                  color: colors.textTertiary,
                  fontWeight: AtharTypography.regular,
                ),
              ),
              const SizedBox(height: 2),
              // Primary title.
              Text(
                primaryTitle,
                style: TextStyle(
                  fontSize: AtharTypography.sizeLg.sp,
                  fontWeight: AtharTypography.bold,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AtharSpacing.xxxs),
              // Secondary (Hijri span or Gregorian span).
              Text(
                secondaryTitle,
                style: TextStyle(
                  fontSize: AtharTypography.sizeXs.sp,
                  color: colors.primary,
                  fontWeight: AtharTypography.semiBold,
                ),
                textAlign: TextAlign.center,
                textDirection:
                    primaryHijri ? TextDirection.ltr : TextDirection.rtl,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: colors.textSecondary,
          iconSize: 24,
          onPressed: onNextMonth,
        ),
      ],
    );
  }
}
