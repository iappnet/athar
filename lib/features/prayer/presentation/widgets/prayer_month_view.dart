// lib/features/prayer/presentation/widgets/prayer_month_view.dart
// ✅ عرض أوقات الصلاة للشهر

import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/prayer_service.dart';
import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';

class PrayerMonthView extends StatefulWidget {
  const PrayerMonthView({super.key});

  @override
  State<PrayerMonthView> createState() => _PrayerMonthViewState();
}

class _PrayerMonthViewState extends State<PrayerMonthView> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // ═══════════════════════════════════════════════════════════
        // شريط التنقل بين الأشهر
        // ═══════════════════════════════════════════════════════════
        _buildMonthNavigator(colorScheme, l10n),

        AtharGap.md,

        // ═══════════════════════════════════════════════════════════
        // عناوين أيام الأسبوع
        // ═══════════════════════════════════════════════════════════
        _buildWeekdayHeaders(colorScheme),

        AtharGap.sm,

        // ═══════════════════════════════════════════════════════════
        // شبكة الأيام
        // ═══════════════════════════════════════════════════════════
        Expanded(child: _buildMonthGrid(colorScheme)),

        // ═══════════════════════════════════════════════════════════
        // عرض أوقات الصلاة لليوم المحدد
        // ═══════════════════════════════════════════════════════════
        if (_selectedDay != null) ...[
          AtharGap.md,
          _buildSelectedDayPrayers(colorScheme, l10n),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // شريط التنقل بين الأشهر
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMonthNavigator(ColorScheme colorScheme, AppLocalizations l10n) {
    final hijri = HijriCalendar.fromDate(_currentMonth);
    HijriCalendar.setLocal('ar');

    return Container(
      margin: AtharSpacing.allXl,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.card,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الشهر السابق
          IconButton(
            icon: Icon(Icons.chevron_right, color: colorScheme.primary),
            onPressed: () => _changeMonth(-1),
          ),

          // عرض الشهر
          Expanded(
            child: Column(
              children: [
                // الشهر الهجري
                Text(
                  hijri.toFormat("MMMM yyyy"),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                AtharGap.xxs,
                // الشهر الميلادي
                Text(
                  DateFormat('MMMM yyyy', 'ar').format(_currentMonth),
                  style: TextStyle(fontSize: 14.sp, color: colorScheme.outline),
                ),
              ],
            ),
          ),

          // زر الشهر التالي
          IconButton(
            icon: Icon(Icons.chevron_left, color: colorScheme.primary),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // عناوين أيام الأسبوع
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildWeekdayHeaders(ColorScheme colorScheme) {
    // أيام الأسبوع بالعربي (تبدأ من الأحد)
    final weekdays = ['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];

    return Padding(
      padding: AtharSpacing.allXl,
      child: Row(
        children: weekdays.map((day) {
          final isWeekend = day == 'جمع' || day == 'سبت';
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isWeekend ? colorScheme.primary : colorScheme.outline,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // شبكة الأيام
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMonthGrid(ColorScheme colorScheme) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    // حساب يوم البداية (الأحد = 0)
    final startWeekday = firstDay.weekday % 7;

    final days = <Widget>[];

    // أيام فارغة قبل بداية الشهر
    for (int i = 0; i < startWeekday; i++) {
      days.add(const SizedBox());
    }

    // أيام الشهر
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      days.add(_buildDayCell(date, colorScheme));
    }

    return Padding(
      padding: AtharSpacing.allXl,
      child: GridView.count(
        crossAxisCount: 7,
        mainAxisSpacing: 4.h,
        crossAxisSpacing: 4.w,
        childAspectRatio: 1,
        children: days,
      ),
    );
  }

  Widget _buildDayCell(DateTime date, ColorScheme colorScheme) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isSelected =
        _selectedDay != null &&
        date.year == _selectedDay!.year &&
        date.month == _selectedDay!.month &&
        date.day == _selectedDay!.day;
    final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
    final isFriday = date.weekday == DateTime.friday;

    // الحصول على التاريخ الهجري
    final hijri = HijriCalendar.fromDate(date);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = date;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : isToday
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: AtharRadii.radiusSm,
          border: Border.all(
            color: isToday && !isSelected
                ? colorScheme.primary
                : isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // اليوم الميلادي
            Text(
              _toArabicNumerals(date.day.toString()),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isToday || isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isSelected
                    ? colorScheme.onPrimary
                    : isPast
                    ? colorScheme.outline.withValues(alpha: 0.5)
                    : isFriday
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            // اليوم الهجري
            Text(
              _toArabicNumerals(hijri.hDay.toString()),
              style: TextStyle(
                fontSize: 10.sp,
                color: isSelected
                    ? colorScheme.onPrimary.withValues(alpha: 0.7)
                    : colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // عرض أوقات الصلاة لليوم المحدد
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSelectedDayPrayers(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final prayerService = getIt<PrayerService>();

    // الحصول على الإحداثيات
    final settingsState = context.watch<SettingsCubit>().state;
    Coordinates coordinates;

    if (settingsState is SettingsLoaded) {
      coordinates = Coordinates(
        settingsState.settings.latitude ?? 24.7136,
        settingsState.settings.longitude ?? 46.6753,
      );
    } else {
      coordinates = Coordinates(24.7136, 46.6753); // الرياض افتراضياً
    }

    final prayers = prayerService.getPrayerTimes(_selectedDay!, coordinates);
    final hijri = HijriCalendar.fromDate(_selectedDay!);
    HijriCalendar.setLocal('ar');

    return Container(
      margin: AtharSpacing.allXl,
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.card,
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عنوان اليوم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE', 'ar').format(_selectedDay!),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    "${hijri.toFormat("dd MMMM")} - ${DateFormat('d MMMM', 'ar').format(_selectedDay!)}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close, color: colorScheme.outline),
                onPressed: () {
                  setState(() {
                    _selectedDay = null;
                  });
                },
              ),
            ],
          ),

          AtharGap.md,

          // قائمة الصلوات (أفقية)
          SizedBox(
            height: 80.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: prayers.length,
              separatorBuilder: (_, _) => AtharGap.hSm,
              itemBuilder: (context, index) {
                final prayer = prayers[index];
                final isSunrise = prayer.type == PrayerType.sunrise;

                return Container(
                  width: 70.w,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSunrise
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: AtharRadii.radiusMd,
                    border: Border.all(
                      color: isSunrise
                          ? colorScheme.outlineVariant
                          : colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // اسم الصلاة
                      Text(
                        _getPrayerShortName(prayer.type, l10n),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: isSunrise
                              ? colorScheme.outline
                              : colorScheme.primary,
                        ),
                      ),
                      AtharGap.xxs,
                      // الوقت
                      Text(
                        DateFormat('h:mm', 'ar').format(prayer.time),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        DateFormat('a', 'ar').format(prayer.time),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // الدوال المساعدة
  // ═══════════════════════════════════════════════════════════════════

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + delta,
        1,
      );
      _selectedDay = null; // إلغاء التحديد عند تغيير الشهر
    });
  }

  String _getPrayerShortName(PrayerType type, AppLocalizations l10n) {
    switch (type) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
    }
  }

  String _toArabicNumerals(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }
}
