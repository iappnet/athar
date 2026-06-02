import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CalendarStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final weekDates = List.generate(7, (index) {
      return now.add(Duration(days: index - now.weekday + 1));
    });

    return SizedBox(
      height: 70.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AtharSpacing.lg),
        itemCount: weekDates.length,
        separatorBuilder: (ctx, _) => AtharGap.hMd,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 50.w,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.onSurface : colorScheme.surface,
                borderRadius: AtharRadii.radiusLg,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.outlineVariant,
                ),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'en').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isSelected
                          ? colorScheme.onPrimary.withValues(alpha: 0.7)
                          : colorScheme.outline,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Calibri',
                      fontFamilyFallback: AtharTypography.fontFallback,
                    ),
                  ),
                  AtharGap.xxs,
                  Text(
                    "${date.day}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Calibri',
                      fontFamilyFallback: AtharTypography.fontFallback,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
