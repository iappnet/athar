// lib/core/widgets/time_slot_picker.dart
// ✅ واجهة اختيار الأوقات - موحدة مع TimeSlotMixin

import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ═══════════════════════════════════════════════════════════════════
// تصدير الـ classes من time_slot_mixin للاستخدام السهل
// ═══════════════════════════════════════════════════════════════════

import 'package:athar/core/time_engine/time_slot_mixin.dart';
import 'package:athar/core/design_system/tokens.dart';

// ═══════════════════════════════════════════════════════════════════
// ويدجت اختيار الوقت
// ═══════════════════════════════════════════════════════════════════

/// ويدجت اختيار الوقت بأسماء الأوقات الشرعية
/// يُرجع TimeSlotSettings للاستخدام مع TimeSlotMixin
class TimeSlotPicker extends StatefulWidget {
  final TimeSlotSettings? initialSettings;
  final ValueChanged<TimeSlotSettings> onChanged;
  final bool showCustomTime;
  final bool showPeriods;
  final bool showRelativeOptions;
  final bool showPeriodPosition;

  const TimeSlotPicker({
    super.key,
    this.initialSettings,
    required this.onChanged,
    this.showCustomTime = true,
    this.showPeriods = true,
    this.showRelativeOptions = true,
    this.showPeriodPosition = false,
  });

  @override
  State<TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  late _TimePickerMode _mode;
  ReferencePrayer? _selectedPrayer;
  AtharTimePeriod? _selectedPeriod;
  PrayerRelativeTime _relation = PrayerRelativeTime.after;
  int _offsetMinutes = 0;
  TimeOfDay? _customTime;
  PeriodPosition _periodPosition = PeriodPosition.start;

  @override
  void initState() {
    super.initState();
    _initFromSettings(widget.initialSettings);
  }

  void _initFromSettings(TimeSlotSettings? settings) {
    if (settings == null) {
      _mode = _TimePickerMode.prayer;
      return;
    }

    switch (settings.type) {
      case TimeSpecificationType.fixed:
        _mode = _TimePickerMode.custom;
        _customTime = settings.fixedTime;
        break;
      case TimeSpecificationType.relativeToPrayer:
        _mode = _TimePickerMode.prayer;
        _selectedPrayer = settings.referencePrayer;
        _relation = settings.prayerRelation ?? PrayerRelativeTime.after;
        _offsetMinutes = settings.offsetMinutes;
        break;
      case TimeSpecificationType.period:
        _mode = _TimePickerMode.period;
        _selectedPeriod = settings.period;
        _periodPosition = settings.periodPosition ?? PeriodPosition.start;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // تبويبات نوع الاختيار
        _buildModeTabs(colorScheme),

        AtharGap.lg,

        // المحتوى حسب النوع
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildModeContent(colorScheme),
        ),
      ],
    );
  }

  Widget _buildModeTabs(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AtharRadii.radiusMd,
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          _buildModeTab(
            icon: Icons.mosque_outlined,
            label: 'بالصلاة',
            mode: _TimePickerMode.prayer,
            colorScheme: colorScheme,
          ),
          if (widget.showPeriods)
            _buildModeTab(
              icon: Icons.wb_sunny_outlined,
              label: 'بالفترة',
              mode: _TimePickerMode.period,
              colorScheme: colorScheme,
            ),
          if (widget.showCustomTime)
            _buildModeTab(
              icon: Icons.access_time,
              label: 'وقت محدد',
              mode: _TimePickerMode.custom,
              colorScheme: colorScheme,
            ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required IconData icon,
    required String label,
    required _TimePickerMode mode,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _mode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _mode = mode);
          _emitChange();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: AtharRadii.radiusMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              AtharGap.hXs,
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: AtharTypography.fontFallback,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeContent(ColorScheme colorScheme) {
    switch (_mode) {
      case _TimePickerMode.prayer:
        return _buildPrayerSelector(colorScheme);
      case _TimePickerMode.period:
        return _buildPeriodSelector(colorScheme);
      case _TimePickerMode.custom:
        return _buildCustomTimePicker(colorScheme);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // اختيار بالصلاة
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPrayerSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // اختيار الصلاة
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: ReferencePrayer.values.map((prayer) {
            return _buildPrayerChip(prayer, colorScheme);
          }).toList(),
        ),

        if (_selectedPrayer != null && widget.showRelativeOptions) ...[
          AtharGap.lg,

          // قبل / بعد / عند الأذان
          Row(
            children: [
              _buildRelationChip(
                label: 'عند الأذان',
                isSelected: _offsetMinutes == 0,
                colorScheme: colorScheme,
                onTap: () {
                  setState(() {
                    _offsetMinutes = 0;
                    _relation = PrayerRelativeTime.after;
                  });
                  _emitChange();
                },
              ),
              AtharGap.hSm,
              _buildRelationChip(
                label: 'بعد',
                isSelected:
                    _relation == PrayerRelativeTime.after && _offsetMinutes > 0,
                colorScheme: colorScheme,
                onTap: () {
                  setState(() {
                    _relation = PrayerRelativeTime.after;
                    if (_offsetMinutes == 0) _offsetMinutes = 15;
                  });
                  _emitChange();
                },
              ),
              AtharGap.hSm,
              _buildRelationChip(
                label: 'قبل',
                isSelected:
                    _relation == PrayerRelativeTime.before &&
                    _offsetMinutes > 0,
                colorScheme: colorScheme,
                onTap: () {
                  setState(() {
                    _relation = PrayerRelativeTime.before;
                    if (_offsetMinutes == 0) _offsetMinutes = 15;
                  });
                  _emitChange();
                },
              ),
            ],
          ),

          // حقل الدقائق
          if (_offsetMinutes > 0) ...[
            AtharGap.md,
            _buildOffsetSlider(colorScheme),
          ],
        ],
      ],
    );
  }

  Widget _buildPrayerChip(ReferencePrayer prayer, ColorScheme colorScheme) {
    final isSelected = _selectedPrayer == prayer;
    final info = _getPrayerInfo(prayer);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPrayer = prayer);
        _emitChange();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: AtharRadii.radiusMd,
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              info.icon,
              size: 22.sp,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            AtharGap.xxs,
            Text(
              info.name,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationChip({
    required String label,
    required bool isSelected,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: AtharRadii.radiusSm,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? colorScheme.secondary
                : colorScheme.onSurfaceVariant,
            fontFamily: AtharTypography.fontFamily,
            fontFamilyFallback: AtharTypography.fontFallback,
          ),
        ),
      ),
    );
  }

  Widget _buildOffsetSlider(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الفارق:',
              style: TextStyle(
                fontSize: 13.sp,
                color: colorScheme.onSurfaceVariant,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
            Text(
              '$_offsetMinutes دقيقة',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
          ],
        ),
        Slider(
          value: _offsetMinutes.toDouble(),
          min: 5,
          max: 60,
          divisions: 11,
          label: '$_offsetMinutes دقيقة',
          onChanged: (value) {
            setState(() => _offsetMinutes = value.round());
            _emitChange();
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // اختيار بالفترة
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPeriodSelector(ColorScheme colorScheme) {
    final periods = [
      AtharTimePeriod.dawn,
      AtharTimePeriod.bakur,
      AtharTimePeriod.duha,
      AtharTimePeriod.morning,
      AtharTimePeriod.noon,
      AtharTimePeriod.afternoon,
      AtharTimePeriod.maghrib,
      AtharTimePeriod.isha,
      AtharTimePeriod.night,
      AtharTimePeriod.lastThird,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: periods.map((period) {
            return _buildPeriodChip(period, colorScheme);
          }).toList(),
        ),

        // اختيار الموقع ضمن الفترة
        if (_selectedPeriod != null && widget.showPeriodPosition) ...[
          AtharGap.lg,
          Text(
            'الموقع ضمن الفترة:',
            style: TextStyle(
              fontSize: 13.sp,
              color: colorScheme.onSurfaceVariant,
              fontFamily: AtharTypography.fontFamily,
              fontFamilyFallback: AtharTypography.fontFallback,
            ),
          ),
          AtharGap.sm,
          Row(
            children: [
              _buildPositionChip(
                label: 'البداية',
                position: PeriodPosition.start,
                colorScheme: colorScheme,
              ),
              AtharGap.hSm,
              _buildPositionChip(
                label: 'المنتصف',
                position: PeriodPosition.middle,
                colorScheme: colorScheme,
              ),
              AtharGap.hSm,
              _buildPositionChip(
                label: 'النهاية',
                position: PeriodPosition.end,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPeriodChip(AtharTimePeriod period, ColorScheme colorScheme) {
    final isSelected = _selectedPeriod == period;
    final info = _getPeriodInfo(period);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = period);
        _emitChange();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? info.color.withValues(alpha: 0.2)
              : colorScheme.surfaceContainerHighest,
          borderRadius: AtharRadii.radiusMd,
          border: Border.all(
            color: isSelected ? info.color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(info.icon, size: 18.sp, color: info.color),
            AtharGap.hXs,
            Text(
              info.name,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? info.color : colorScheme.onSurfaceVariant,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionChip({
    required String label,
    required PeriodPosition position,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _periodPosition == position;

    return GestureDetector(
      onTap: () {
        setState(() => _periodPosition = position);
        _emitChange();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.tertiaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: AtharRadii.radiusSm,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? colorScheme.tertiary
                : colorScheme.onSurfaceVariant,
            fontFamily: AtharTypography.fontFamily,
            fontFamilyFallback: AtharTypography.fontFallback,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // اختيار وقت محدد
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildCustomTimePicker(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _customTime ?? TimeOfDay.now(),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
        );

        if (time != null) {
          setState(() => _customTime = time);
          _emitChange();
        }
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AtharRadii.radiusLg,
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 28.sp, color: colorScheme.primary),
            AtharGap.hMd,
            Text(
              _customTime != null
                  ? _formatTimeOfDay(_customTime!)
                  : 'اضغط لاختيار الوقت',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _customTime != null
                    ? colorScheme.onSurface
                    : colorScheme.outline,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  // ═══════════════════════════════════════════════════════════════════
  // معلومات مساعدة
  // ═══════════════════════════════════════════════════════════════════

  _PrayerInfo _getPrayerInfo(ReferencePrayer prayer) {
    switch (prayer) {
      case ReferencePrayer.fajr:
        return _PrayerInfo('الفجر', Icons.nights_stay_outlined);
      case ReferencePrayer.sunrise:
        return _PrayerInfo('الشروق', Icons.wb_twilight);
      case ReferencePrayer.dhuhr:
        return _PrayerInfo('الظهر', Icons.wb_sunny);
      case ReferencePrayer.asr:
        return _PrayerInfo('العصر', Icons.sunny_snowing);
      case ReferencePrayer.maghrib:
        return _PrayerInfo('المغرب', Icons.wb_twilight);
      case ReferencePrayer.isha:
        return _PrayerInfo('العشاء', Icons.nightlight_round);
    }
  }

  _PeriodInfo _getPeriodInfo(AtharTimePeriod period) {
    final c = context.colors;
    final colorScheme = Theme.of(context).colorScheme;
    switch (period) {
      case AtharTimePeriod.dawn:
        return _PeriodInfo('الفجر', Icons.nights_stay_outlined, c.accentIndigo);
      case AtharTimePeriod.bakur:
        return _PeriodInfo('البكور', Icons.wb_twilight, c.accentAmber);
      case AtharTimePeriod.duha:
        return _PeriodInfo('الضحى', Icons.wb_sunny_outlined, c.accentAmber);
      case AtharTimePeriod.morning:
        return _PeriodInfo('الصباح', Icons.wb_sunny_outlined, c.accentOrange);
      case AtharTimePeriod.noon:
        return _PeriodInfo('الظهيرة', Icons.wb_sunny, c.warning);
      case AtharTimePeriod.afternoon:
        return _PeriodInfo('العصر', Icons.sunny_snowing, c.accentRed);
      case AtharTimePeriod.maghrib:
        return _PeriodInfo('المغرب', Icons.wb_twilight, c.accentPurple);
      case AtharTimePeriod.isha:
        return _PeriodInfo('العشاء', Icons.nightlight_round, c.accentIndigo);
      case AtharTimePeriod.night:
        return _PeriodInfo('الليل', Icons.dark_mode_outlined, c.accentBlue);
      case AtharTimePeriod.lastThird:
        return _PeriodInfo('الثلث الأخير', Icons.auto_awesome, c.accentTeal);
      case AtharTimePeriod.undefined:
        return _PeriodInfo('غير محدد', Icons.help_outline, colorScheme.outline);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // إرسال التغييرات
  // ═══════════════════════════════════════════════════════════════════

  void _emitChange() {
    final TimeSlotSettings settings;

    switch (_mode) {
      case _TimePickerMode.prayer:
        if (_selectedPrayer == null) return;
        settings = TimeSlotSettings.relativeToPrayer(
          prayer: _selectedPrayer!,
          relation: _relation,
          offsetMinutes: _offsetMinutes,
        );
        break;

      case _TimePickerMode.period:
        if (_selectedPeriod == null) return;
        settings = TimeSlotSettings.period(
          period: _selectedPeriod!,
          position: _periodPosition,
        );
        break;

      case _TimePickerMode.custom:
        if (_customTime == null) return;
        settings = TimeSlotSettings.fixed(_customTime!);
        break;
    }

    widget.onChanged(settings);
  }
}

enum _TimePickerMode { prayer, period, custom }

class _PrayerInfo {
  final String name;
  final IconData icon;
  _PrayerInfo(this.name, this.icon);
}

class _PeriodInfo {
  final String name;
  final IconData icon;
  final Color color;
  _PeriodInfo(this.name, this.icon, this.color);
}

// ═══════════════════════════════════════════════════════════════════
// Widget مصغر لعرض الوقت المختار
// ═══════════════════════════════════════════════════════════════════

/// Widget لعرض الوقت المختار بشكل مصغر
class TimeSlotDisplay extends StatelessWidget {
  final TimeSlotSettings? settings;
  final VoidCallback? onTap;
  final bool showIcon;

  const TimeSlotDisplay({
    super.key,
    this.settings,
    this.onTap,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayText = _getDisplayText();
    final icon = _getIcon();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AtharRadii.radiusSm,
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(icon, size: 18.sp, color: colorScheme.primary),
              AtharGap.hSm,
            ],
            Text(
              displayText,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
            if (onTap != null) ...[
              AtharGap.hSm,
              Icon(
                Icons.edit_outlined,
                size: 16.sp,
                color: colorScheme.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDisplayText() {
    final s = settings;
    if (s == null) return 'اختر الوقت';

    switch (s.type) {
      case TimeSpecificationType.fixed:
        final time = s.fixedTime;
        if (time == null) return 'غير محدد';
        final hour = time.hour;
        final minute = time.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'م' : 'ص';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$hour12:$minute $period';

      case TimeSpecificationType.relativeToPrayer:
        final prayerName = _getPrayerName(s.referencePrayer);
        if (s.offsetMinutes == 0) return prayerName;
        final relation = s.prayerRelation == PrayerRelativeTime.before
            ? 'قبل'
            : 'بعد';
        return '$relation $prayerName بـ ${s.offsetMinutes} د';

      case TimeSpecificationType.period:
        final periodName = _getPeriodName(s.period);
        switch (s.periodPosition) {
          case PeriodPosition.start:
            return 'بداية $periodName';
          case PeriodPosition.middle:
            return 'منتصف $periodName';
          case PeriodPosition.end:
            return 'نهاية $periodName';
          default:
            return periodName;
        }
    }
  }

  IconData _getIcon() {
    final s = settings;
    if (s == null) return Icons.access_time;

    switch (s.type) {
      case TimeSpecificationType.fixed:
        return Icons.access_time;
      case TimeSpecificationType.relativeToPrayer:
        return Icons.mosque_outlined;
      case TimeSpecificationType.period:
        return Icons.wb_sunny_outlined;
    }
  }

  String _getPrayerName(ReferencePrayer? prayer) {
    switch (prayer) {
      case ReferencePrayer.fajr:
        return 'الفجر';
      case ReferencePrayer.sunrise:
        return 'الشروق';
      case ReferencePrayer.dhuhr:
        return 'الظهر';
      case ReferencePrayer.asr:
        return 'العصر';
      case ReferencePrayer.maghrib:
        return 'المغرب';
      case ReferencePrayer.isha:
        return 'العشاء';
      default:
        return 'غير محدد';
    }
  }

  String _getPeriodName(AtharTimePeriod? period) {
    switch (period) {
      case AtharTimePeriod.dawn:
        return 'الفجر';
      case AtharTimePeriod.bakur:
        return 'البكور';
      case AtharTimePeriod.morning:
        return 'الصباح';
      case AtharTimePeriod.noon:
        return 'الظهيرة';
      case AtharTimePeriod.afternoon:
        return 'العصر';
      case AtharTimePeriod.maghrib:
        return 'المغرب';
      case AtharTimePeriod.isha:
        return 'العشاء';
      case AtharTimePeriod.night:
        return 'الليل';
      case AtharTimePeriod.lastThird:
        return 'الثلث الأخير';
      default:
        return 'غير محدد';
    }
  }
}

