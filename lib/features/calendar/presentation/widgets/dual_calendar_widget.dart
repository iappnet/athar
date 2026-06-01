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

  // PR4b tech debt: route through SettingsCubit rather than direct repo write.
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

    final weekDays = [
      l10n.weekdaySunAbbr,
      l10n.weekdayMonAbbr,
      l10n.weekdayTueAbbr,
      l10n.weekdayWedAbbr,
      l10n.weekdayThuAbbr,
      l10n.weekdayFriAbbr,
      l10n.weekdaySatAbbr,
    ];

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // P0 — RULE 1: LayoutBuilder drives all width-based decisions (cell height,
    // aspect ratio, future breakpoint branches). Never MediaQuery or isTablet.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cell height tiers: width < 360 → 54pt (iPhone SE overflow guard),
        // 360–839 → 64pt (phone), ≥ 840 → 72pt (tablet).
        final double targetCellHeight = constraints.maxWidth < 360
            ? 54.0
            : constraints.maxWidth < 840
                ? 64.0
                : 72.0;
        final double cellWidth =
            (constraints.maxWidth - AtharSpacing.lg * 2) / 7;
        final double cellAspectRatio = cellWidth / targetCellHeight;

        return Container(
          // P2: tokenized padding (was EdgeInsets.all(16.w))
          padding: const EdgeInsets.all(AtharSpacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            // P3: flat bottom per spec — BorderRadius.vertical(bottom: 30.r) removed
            // P3: shadow updated to token-aligned values
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Calendar header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // P2+P6: RTL-safe chevrons placed in Directionality-respecting
                  // Row. chevron_left = semantic "earlier month" — in an RTL Row
                  // this renders visually on the right, which is correct for
                  // Arabic calendar conventions. No Transform.flipX needed.
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    color: colorScheme.onSurfaceVariant,
                    iconSize: 24,
                    onPressed: () => _changeMonth(-1),
                  ),

                  InkWell(
                    onTap: _toggleCalendarMode,
                    borderRadius: AtharRadii.card,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AtharSpacing.sm,
                        vertical: AtharSpacing.xxs,
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              // P1: main title — token size (was 18.sp hardcoded)
                              Text(
                                mainTitle,
                                style: TextStyle(
                                  fontSize: AtharTypography.sizeLg.sp,
                                  fontWeight: AtharTypography.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              // P1: sub title — token size (was 12.sp hardcoded)
                              Text(
                                subTitle,
                                style: TextStyle(
                                  fontSize: AtharTypography.sizeXs.sp,
                                  color: colorScheme.primary,
                                  fontWeight: AtharTypography.semiBold,
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

                  // P6: semantic "later month" chevron
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: colorScheme.onSurfaceVariant,
                    iconSize: 24,
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
                              fontWeight: AtharTypography.bold,
                              // P1: token size (was 14.sp hardcoded)
                              fontSize: AtharTypography.sizeSm.sp,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              // P2: tokenized gap (was SizedBox(height: 10.h))
              AtharGap.md,

              // 3. Day grid — P0: LayoutBuilder-computed aspect ratio prevents
              // fixed-ratio overflow on all screen widths.
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daysInMonth + firstWeekday,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: cellAspectRatio,
                ),
                itemBuilder: (context, index) {
                  if (index < firstWeekday) return const SizedBox();

                  final day = index - firstWeekday + 1;
                  final date = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month,
                    day,
                  );
                  final isSelected =
                      DateUtils.isSameDay(date, widget.selectedDate);
                  final isToday = DateUtils.isSameDay(date, DateTime.now());

                  final hijriDate = _hijriService.toHijri(date);

                  final String primaryText =
                      _isGregorianPrimary ? "$day" : "${hijriDate.hDay}";

                  final String secondaryText =
                      _isGregorianPrimary ? "${hijriDate.hDay}" : "$day";

                  // P1+Q3: today alpha — slightly raised in dark for legibility
                  final double todayAlpha = isDark ? 0.13 : 0.08;

                  return GestureDetector(
                    onTap: () => widget.onDateSelected(date),
                    child: Container(
                      // P2: tokenized margin (was EdgeInsets.all(2.w))
                      margin: const EdgeInsets.all(AtharSpacing.xxxs),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : (isToday
                                  ? colorScheme.primary
                                        .withValues(alpha: todayAlpha)
                                  : Colors.transparent),
                        borderRadius: AtharRadii.card,
                        // P1+Q2: border removed — spec: no border on today state
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // P1: primary numeral — token size + bold on today/selected
                          Text(
                            primaryText,
                            style: TextStyle(
                              fontSize: AtharTypography.sizeMd.sp,
                              fontWeight: (isToday || isSelected)
                                  ? AtharTypography.bold
                                  : AtharTypography.regular,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : isToday
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                            ),
                          ),

                          // P1: secondary numeral — token size 10pt (captionS)
                          // PR4b: replace with DualDate.activity
                          Text(
                            secondaryText,
                            style: TextStyle(
                              fontSize: AtharTypography.sizeXxs.sp,
                              color: isSelected
                                  ? colorScheme.onPrimary.withValues(alpha: 0.7)
                                  : colorScheme.primary,
                              fontWeight: AtharTypography.medium,
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
      },
    );
  }
}
