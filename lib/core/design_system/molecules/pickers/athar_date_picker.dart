import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class AtharDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const AtharDatePicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<AtharDatePicker> createState() => _AtharDatePickerState();
}

class _AtharDatePickerState extends State<AtharDatePicker> {
  late DateTime _selectedDate;
  bool _isHijriMode = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final gregorianText = DateFormat('d MMMM yyyy', 'ar').format(_selectedDate);
    final hijriDate = HijriCalendar.fromDate(_selectedDate);
    HijriCalendar.setLocal('ar');
    final hijriText = hijriDate.toFormat("dd MMMM yyyy");

    return Container(
      padding: AtharSpacing.allXl,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: AtharRadii.radiusXxxs,
            ),
          ),

          // Toggle (Hijri / Gregorian)
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: AtharRadii.card,
            ),
            child: Row(
              children: [
                _buildToggleBtn(
                  colorScheme,
                  l10n.datePickerGregorian,
                  !_isHijriMode,
                  false,
                ),
                _buildToggleBtn(
                  colorScheme,
                  l10n.datePickerHijri,
                  _isHijriMode,
                  true,
                ),
              ],
            ),
          ),

          AtharGap.xl,

          // Selected date (primary)
          Text(
            _isHijriMode ? hijriText : gregorianText,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              fontFamily: 'Calibri',
              fontFamilyFallback: AtharTypography.fontFallback,
            ),
          ),
          // Corresponding date (secondary)
          Text(
            l10n.datePickerCorresponding(
              _isHijriMode ? gregorianText : hijriText,
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: colorScheme.outline,
              fontFamily: 'Calibri',
              fontFamilyFallback: AtharTypography.fontFallback,
            ),
          ),

          AtharGap.xl,

          // Calendar
          SizedBox(
            height: 300.h,
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),

          AtharGap.md,

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onDateSelected(_selectedDate);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: AtharRadii.card),
              ),
              child: Text(
                l10n.datePickerConfirm,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Calibri',
                  fontFamilyFallback: AtharTypography.fontFallback,
                ),
              ),
            ),
          ),
          AtharGap.xl,
        ],
      ),
    );
  }

  Widget _buildToggleBtn(
    ColorScheme colorScheme,
    String label,
    bool isActive,
    bool hijriValue,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isHijriMode = hijriValue;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.surface : Colors.transparent,
            borderRadius: AtharRadii.radiusSm,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? colorScheme.primary : colorScheme.outline,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              fontFamily: 'Calibri',
              fontFamilyFallback: AtharTypography.fontFallback,
            ),
          ),
        ),
      ),
    );
  }
}
