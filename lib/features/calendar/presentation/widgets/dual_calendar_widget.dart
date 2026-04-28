import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/hijri_service.dart';
import 'package:athar/core/design_system/tokens.dart';

class DualCalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  /// When provided, the widget skips its own async settings read and uses
  /// this value directly — eliminating the one-shot reactive gap.
  final bool? isHijriMode;

  const DualCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.isHijriMode,
  });

  @override
  State<DualCalendarWidget> createState() => _DualCalendarWidgetState();
}

class _DualCalendarWidgetState extends State<DualCalendarWidget> {
  late DateTime _focusedMonth;
  final HijriService _hijriService = getIt<HijriService>();
  final SettingsRepository _settingsRepo = getIt<SettingsRepository>();

  bool _isGregorianPrimary = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.selectedDate;
    if (widget.isHijriMode != null) {
      _isGregorianPrimary = !widget.isHijriMode!;
      _isLoading = false;
    } else {
      _loadCalendarPreference();
    }
  }

  @override
  void didUpdateWidget(DualCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHijriMode != null &&
        widget.isHijriMode != oldWidget.isHijriMode) {
      setState(() {
        _isGregorianPrimary = !widget.isHijriMode!;
      });
    }
  }

  Future<void> _loadCalendarPreference() async {
    final settings = await _settingsRepo.getSettings();
    if (mounted) {
      setState(() {
        _isGregorianPrimary = !settings.isHijriMode;
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
        1,
      );
    });
  }

  void _toggleCalendarMode() async {
    setState(() {
      _isGregorianPrimary = !_isGregorianPrimary;
    });

    final settings = await _settingsRepo.getSettings();
    settings.isHijriMode = !_isGregorianPrimary;
    await _settingsRepo.updateSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    if (_isLoading) return const SizedBox.shrink();

    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final hijriMonth = _hijriService.toHijri(_focusedMonth);

    final String mainTitle = _isGregorianPrimary
        ? DateFormat('MMMM yyyy', 'ar').format(_focusedMonth)
        : "${hijriMonth.longMonthName} ${hijriMonth.hYear}";

    final String subTitle = _isGregorianPrimary
        ? "${hijriMonth.longMonthName} ${hijriMonth.hYear}"
        : DateFormat('MMMM yyyy', 'ar').format(_focusedMonth);

    // Weekday abbreviations from l10n
    final weekDays = [
      l10n.weekdaySunAbbr,
      l10n.weekdayMonAbbr,
      l10n.weekdayTueAbbr,
      l10n.weekdayWedAbbr,
      l10n.weekdayThuAbbr,
      l10n.weekdayFriAbbr,
      l10n.weekdaySatAbbr,
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Calendar header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: () => _changeMonth(-1),
              ),

              InkWell(
                onTap: _toggleCalendarMode,
                borderRadius: AtharRadii.card,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          // Main title
                          Text(
                            mainTitle,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          // Sub title
                          Text(
                            subTitle,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      AtharGap.hSm,
                      Icon(
                        Icons.swap_vert_circle_outlined,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          AtharGap.xl,

          // 2. Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map(
                  (day) => SizedBox(
                    width: 40.w,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: colorScheme.outline,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 10.h),

          // 3. Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstWeekday,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox();

              final day = index - firstWeekday + 1;
              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );
              final isSelected = DateUtils.isSameDay(date, widget.selectedDate);
              final isToday = DateUtils.isSameDay(date, DateTime.now());

              final hijriDate = _hijriService.toHijri(date);

              final String primaryText = _isGregorianPrimary
                  ? "$day"
                  : "${hijriDate.hDay}";

              final String secondaryText = _isGregorianPrimary
                  ? "${hijriDate.hDay}"
                  : "$day";

              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: Container(
                  margin: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : (isToday
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent),
                    borderRadius: AtharRadii.card,
                    border: isToday && !isSelected
                        ? Border.all(color: colorScheme.primary)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Primary number
                      Text(
                        primaryText,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),

                      // Secondary number
                      Text(
                        secondaryText,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isSelected
                              ? colorScheme.onPrimary.withValues(alpha: 0.7)
                              : colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
