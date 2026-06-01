import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:athar/features/calendar/domain/entities/activity_set.dart';
import 'package:athar/features/calendar/domain/entities/dual_date.dart';
import 'package:athar/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:athar/features/calendar/presentation/cubit/calendar_month_cubit.dart';
import 'package:athar/features/calendar/presentation/widgets/calendar_day_cell.dart';
import 'package:athar/features/calendar/presentation/widgets/dual_calendar_header.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/features/task/presentation/cubit/task_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:athar/core/utils/navigation_utils.dart';
import 'package:athar/features/calendar/domain/entities/calendar_item.dart';
import '../../../../core/design_system/molecules/tiles/task_tile.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initMonth();
  }

  void _initMonth() {
    final settings = context.read<SettingsCubit>().state;
    final primaryHijri =
        settings is SettingsLoaded ? settings.settings.isHijriMode : false;
    context
        .read<CalendarMonthCubit>()
        .loadMonth(DateTime.now(), primaryHijri: primaryHijri);
  }

  void _changeMonth(int offset) {
    final monthState = context.read<CalendarMonthCubit>().state;
    final current = monthState is CalendarMonthLoaded
        ? monthState.focusedMonth
        : DateTime(_selectedDate.year, _selectedDate.month, 1);
    final next = DateTime(current.year, current.month + offset, 1);
    context.read<CalendarMonthCubit>().setFocusedMonth(next);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: BackButton(
          color: colorScheme.onSurface,
          onPressed: () => NavigationUtils.safeBack(context),
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: AtharTypography.sizeXl.sp,
          fontWeight: AtharTypography.bold,
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth >= 600 ? 900.0 : double.infinity,
            ),
            child: Column(
              children: [
                // ── Calendar grid (BlocBuilder<CalendarMonthCubit>) ──────────
                // Month-scroll rebuilds grid only; day-tap rebuilds events only.
                BlocConsumer<SettingsCubit, SettingsState>(
                  listenWhen: (prev, curr) {
                    if (prev is SettingsLoaded && curr is SettingsLoaded) {
                      return prev.settings.isHijriMode !=
                              curr.settings.isHijriMode ||
                          prev.settings.showPrayerDotsOnCalendar !=
                              curr.settings.showPrayerDotsOnCalendar ||
                          prev.settings.isPrayerEnabled !=
                              curr.settings.isPrayerEnabled;
                    }
                    return false;
                  },
                  listener: (context, _) =>
                      context.read<CalendarMonthCubit>().refreshWithSettings(),
                  builder: (context, settingsState) {
                    final settings = settingsState is SettingsLoaded
                        ? settingsState.settings
                        : null;
                    final bool easternNumerals =
                        (settings?.easternNumerals ?? false) &&
                            locale == 'ar';

                    return BlocBuilder<CalendarMonthCubit, CalendarMonthState>(
                      builder: (context, monthState) {
                        if (monthState is CalendarMonthLoading) {
                          return const SizedBox(
                            height: 320,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (monthState is CalendarMonthError) {
                          return SizedBox(
                            height: 320,
                            child: Center(child: Text(monthState.message)),
                          );
                        }
                        if (monthState is! CalendarMonthLoaded) {
                          return const SizedBox(height: 320);
                        }
                        return _CalendarGrid(
                          monthState: monthState,
                          selectedDate: _selectedDate,
                          easternNumerals: easternNumerals,
                          onPrevMonth: () => _changeMonth(-1),
                          onNextMonth: () => _changeMonth(1),
                          onDateSelected: (date) {
                            setState(() => _selectedDate = date);
                            context.read<CalendarCubit>().selectDate(date);
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: AtharSpacing.lg),

                // ── Day-sheet header ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AtharSpacing.lg),
                  child: Row(
                    children: [
                      Text(
                        l10n.calendarDayEvents,
                        style: TextStyle(
                          fontSize: AtharTypography.sizeMd.sp,
                          fontWeight: AtharTypography.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      _DaySheetDateLabel(
                        date: _selectedDate,
                        locale: locale,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AtharSpacing.md),

                // ── Day events list (BlocBuilder<CalendarCubit>) ─────────────
                Expanded(
                  child: BlocListener<TaskCubit, TaskState>(
                    listenWhen: (prev, curr) =>
                        prev is TaskLoaded && curr is TaskLoaded,
                    listener: (context, _) =>
                        context.read<CalendarCubit>().selectDate(_selectedDate),
                    child: BlocBuilder<CalendarCubit, CalendarState>(
                      builder: (context, state) {
                        if (state is CalendarLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is CalendarError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: colorScheme.error, size: 40),
                                const SizedBox(height: AtharSpacing.sm),
                                Text(state.message,
                                    style:
                                        TextStyle(color: colorScheme.error)),
                                TextButton.icon(
                                  onPressed: () => context
                                      .read<CalendarCubit>()
                                      .selectDate(_selectedDate),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(l10n.retry),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is CalendarLoaded) {
                          if (state.items.isEmpty) {
                            return _buildEmptyState(colorScheme, l10n);
                          }
                          return ListView.separated(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            itemCount: state.items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AtharSpacing.md),
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return switch (item) {
                                CalendarTask(:final task) => TaskTile(
                                    task: task,
                                    onToggle: (_) => context
                                        .read<TaskCubit>()
                                        .toggleTaskCompletion(task),
                                    onDelete: () => context
                                        .read<TaskCubit>()
                                        .deleteTask(task.id),
                                  ),
                                CalendarAppointment(:final appointment) =>
                                  _AppointmentTile(
                                      appointment: appointment),
                              };
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 50.sp, color: cs.outlineVariant),
          const SizedBox(height: AtharSpacing.md),
          Text(l10n.calendarNoTasks,
              style: TextStyle(color: cs.outline)),
        ],
      ),
    );
  }
}

// ─── Calendar grid widget ─────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.monthState,
    required this.selectedDate,
    required this.easternNumerals,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final CalendarMonthLoaded monthState;
  final DateTime selectedDate;
  final bool easternNumerals;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final focusedMonth = monthState.focusedMonth;
    final dualDates = monthState.dualDates;
    final activityByDate = monthState.activityByDate;
    final primaryHijri = monthState.primaryHijri;

    final daysInMonth =
        DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final firstDayOfMonth =
        DateTime(focusedMonth.year, focusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    // Leading (other-month) day count.
    final leadingCount = firstWeekday;
    // Trailing to fill the last row.
    final totalCells =
        (((daysInMonth + leadingCount) / 7).ceil()) * 7;

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
      padding: const EdgeInsets.all(AtharSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
          // Header with chevrons.
          DualCalendarHeader(
            focusedMonth: focusedMonth,
            primaryHijri: primaryHijri,
            onPrevMonth: onPrevMonth,
            onNextMonth: onNextMonth,
          ),
          const SizedBox(height: AtharSpacing.xl),

          // Weekday row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((d) => SizedBox(
              width: 40.w,
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    color: colorScheme.outline,
                    fontWeight: AtharTypography.bold,
                    fontSize: AtharTypography.sizeSm.sp,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: AtharSpacing.md),

          // Day grid via LayoutBuilder for breakpoint heights.
          LayoutBuilder(
            builder: (context, constraints) {
              final double cellH = constraints.maxWidth < 360
                  ? 54.0
                  : constraints.maxWidth < 840
                      ? 64.0
                      : 72.0;
              final double cellW = (constraints.maxWidth - 14 * 1) / 7;
              final double ratio = cellW / cellH;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCells,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: ratio,
                ),
                itemBuilder: (context, index) {
                  if (index < leadingCount) {
                    // Leading other-month days.
                    final prevMonthLastDay = DateTime(
                        focusedMonth.year, focusedMonth.month, 0);
                    final day = prevMonthLastDay.day - (leadingCount - 1 - index);
                    final date = DateTime(
                        prevMonthLastDay.year, prevMonthLastDay.month, day);
                    final key = DateTime(date.year, date.month, date.day);
                    return CalendarDayCell(
                      dualDate: dualDates[key] ?? DualDate.from(date),
                      primaryHijri: primaryHijri,
                      isToday: false,
                      isSelected: false,
                      isOtherMonth: true,
                      activity: ActivitySet.empty,
                      easternNumerals: easternNumerals,
                      cellHeight: cellH,
                      onTap: () => onDateSelected(date),
                    );
                  }

                  final trailingStart = leadingCount + daysInMonth;
                  if (index >= trailingStart) {
                    // Trailing other-month days.
                    final trailingDay = index - trailingStart + 1;
                    final date = DateTime(
                        focusedMonth.year, focusedMonth.month + 1, trailingDay);
                    final key = DateTime(date.year, date.month, date.day);
                    return CalendarDayCell(
                      dualDate: dualDates[key] ?? DualDate.from(date),
                      primaryHijri: primaryHijri,
                      isToday: false,
                      isSelected: false,
                      isOtherMonth: true,
                      activity: ActivitySet.empty,
                      easternNumerals: easternNumerals,
                      cellHeight: cellH,
                      onTap: () => onDateSelected(date),
                    );
                  }

                  // In-month day.
                  final day = index - leadingCount + 1;
                  final date =
                      DateTime(focusedMonth.year, focusedMonth.month, day);
                  final key = DateTime(date.year, date.month, date.day);
                  final isSelected = DateUtils.isSameDay(date, selectedDate);
                  final isToday = DateUtils.isSameDay(date, DateTime.now());

                  return CalendarDayCell(
                    dualDate: dualDates[key] ?? DualDate.from(date),
                    primaryHijri: primaryHijri,
                    isToday: isToday,
                    isSelected: isSelected,
                    isOtherMonth: false,
                    activity: activityByDate[key] ?? ActivitySet.empty,
                    easternNumerals: easternNumerals,
                    cellHeight: cellH,
                    onTap: () => onDateSelected(date),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Day-sheet date label ─────────────────────────────────────────────────────

class _DaySheetDateLabel extends StatelessWidget {
  const _DaySheetDateLabel({required this.date, required this.locale});

  final DateTime date;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) {
        if (prev is SettingsLoaded && curr is SettingsLoaded) {
          return prev.settings.isHijriMode != curr.settings.isHijriMode ||
              prev.settings.easternNumerals != curr.settings.easternNumerals;
        }
        return false;
      },
      builder: (context, state) {
        final settings = state is SettingsLoaded ? state.settings : null;
        final primaryHijri = settings?.isHijriMode ?? false;
        final easternNumerals =
            (settings?.easternNumerals ?? false) && locale == 'ar';

        final hijri = HijriCalendar.fromDate(date);
        final hijriDay = easternNumerals
            ? _toEastern(hijri.hDay)
            : hijri.hDay.toString();
        final hijriMonthName = hijri.longMonthName;

        // CALENDAR_CELL_SPEC §3: "Wed, 15 Jan · ١٥ رجب"
        final gregStr = DateFormat(
          locale == 'ar' ? 'EEE، d MMM' : 'EEE, d MMM',
          locale,
        ).format(date);
        final hijriStr = '$hijriDay $hijriMonthName';

        final colorScheme = Theme.of(context).colorScheme;

        String label;
        TextDirection dir;
        if (primaryHijri && locale == 'ar') {
          // Hijri-first when primary + Arabic: "الأربعاء، ١٥ رجب · 15 Jan"
          label = '$hijriStr · $gregStr';
          dir = TextDirection.rtl;
        } else {
          label = '$gregStr · $hijriStr';
          dir = TextDirection.ltr;
        }

        return Text(
          label,
          style: TextStyle(
            fontSize: AtharTypography.sizeXs.sp,
            color: colorScheme.outline,
          ),
          textDirection: dir,
        );
      },
    );
  }

  static String _toEastern(int n) {
    const e = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? e[d] : c;
    }).join();
  }
}

// ─── Appointment tile ─────────────────────────────────────────────────────────

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeStr =
        DateFormat('hh:mm a', 'ar').format(appointment.appointmentDate);

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(Icons.medical_services_outlined,
                color: colorScheme.primary, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (appointment.doctorName != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      appointment.doctorName!,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              timeStr,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
