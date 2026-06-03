import 'dart:async';

import 'package:athar/features/calendar/domain/entities/activity_set.dart';
import 'package:athar/features/calendar/domain/entities/dual_date.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';
import 'package:athar/features/health/domain/repositories/health_repository.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/task/domain/repositories/task_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'calendar_month_state.dart';

@injectable
class CalendarMonthCubit extends Cubit<CalendarMonthState> {
  CalendarMonthCubit(
    this._taskRepository,
    this._habitRepository,
    this._healthRepository,
    this._settingsRepository,
  ) : super(const CalendarMonthLoading());

  final TaskRepository _taskRepository;
  final HabitRepository _habitRepository;
  final HealthRepository _healthRepository;
  final SettingsRepository _settingsRepository;

  DateTime _focusedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  Future<void> loadMonth(DateTime month, {bool primaryHijri = false}) async {
    _focusedMonth = DateTime(month.year, month.month, 1);
    try {
      final data = await _computeMonthData(_focusedMonth, primaryHijri);
      if (!isClosed) emit(data);
    } catch (e) {
      if (!isClosed) emit(CalendarMonthError(e.toString()));
    }
  }

  Future<void> setFocusedMonth(DateTime month) async {
    _focusedMonth = DateTime(month.year, month.month, 1);
    final prev = state;
    final primaryHijri = prev is CalendarMonthLoaded ? prev.primaryHijri : false;
    try {
      final data = await _computeMonthData(_focusedMonth, primaryHijri);
      if (!isClosed) emit(data);
    } catch (e) {
      if (!isClosed) emit(CalendarMonthError(e.toString()));
    }
  }

  Future<void> refreshWithSettings() async {
    final settings = await _settingsRepository.getSettings();
    final primaryHijri = settings.isHijriMode;
    try {
      final data = await _computeMonthData(_focusedMonth, primaryHijri);
      if (!isClosed) emit(data);
    } catch (e) {
      if (!isClosed) emit(CalendarMonthError(e.toString()));
    }
  }

  Future<CalendarMonthLoaded> _computeMonthData(
      DateTime month, bool primaryHijri) async {
    // Buffer: previous month + visible month + next month.
    final bufferStart = DateTime(month.year, month.month - 1, 1);
    final bufferEnd = DateTime(month.year, month.month + 2, 0); // last day of next month

    // Build DualDate cache for 3-month window.
    final dualDates = <DateTime, DualDate>{};
    var day = bufferStart;
    while (!day.isAfter(bufferEnd)) {
      final key = DateTime(day.year, day.month, day.day);
      dualDates[key] = DualDate.from(day);
      day = day.add(const Duration(days: 1));
    }

    // Gather activity data concurrently.
    final settings = await _settingsRepository.getSettings();
    final prayerDotsEnabled =
        settings.isPrayerEnabled && settings.showPrayerDotsOnCalendar;

    final results = await Future.wait([
      _taskRepository.getTasksInDateRange(bufferStart, bufferEnd),
      _healthRepository.getAppointmentsInDateRange(bufferStart, bufferEnd),
      _habitRepository.hasActiveRegularHabits(),
      _healthRepository.getAllActiveMedicines(),
    ]);

    final tasks = results[0] as List;
    final appointments = results[1] as List;
    final hasHabits = results[2] as bool;
    final medicines = results[3] as List;
    final hasMedicines = medicines.isNotEmpty;

    // Index tasks by day.
    final taskDays = <DateTime>{};
    for (final t in tasks) {
      if (t.date != null) {
        final k = DateTime(t.date!.year, t.date!.month, t.date!.day);
        taskDays.add(k);
      }
    }

    // Index appointments by day.
    final apptDays = <DateTime>{};
    for (final a in appointments) {
      final k = DateTime(
          a.appointmentDate.year, a.appointmentDate.month, a.appointmentDate.day);
      apptDays.add(k);
    }

    // Build activityByDate for the 3-month buffer.
    final activityByDate = <DateTime, ActivitySet>{};
    for (final key in dualDates.keys) {
      activityByDate[key] = ActivitySet(
        hasTask: taskDays.contains(key),
        hasHabit: hasHabits,
        hasAppointment: apptDays.contains(key),
        hasMedicine: hasMedicines,
        hasPrayer: prayerDotsEnabled,
      );
    }

    return CalendarMonthLoaded(
      focusedMonth: month,
      dualDates: dualDates,
      activityByDate: activityByDate,
      primaryHijri: primaryHijri,
    );
  }
}
