// lib/features/calendar/presentation/cubit/calendar_cubit.dart

import 'dart:async';

import 'package:athar/core/services/appointment_notifier.dart';
import 'package:athar/features/calendar/domain/entities/calendar_item.dart';
import 'package:athar/features/health/domain/repositories/health_repository.dart';
import 'package:athar/features/task/domain/repositories/task_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'calendar_state.dart';

@injectable
class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit(
    this._taskRepository,
    this._healthRepository,
    this._appointmentNotifier,
  ) : super(const CalendarLoading()) {
    // Re-fetch whenever HealthCubit confirms an appointment mutation.
    // AppointmentNotifier is a lazySingleton broadcast stream — no global
    // HealthCubit promotion required, and no state-string matching needed.
    _appointmentSub = _appointmentNotifier.stream.listen((_) {
      final s = state;
      if (s is CalendarLoaded) selectDate(s.selectedDate);
    });
  }

  final TaskRepository _taskRepository;
  final HealthRepository _healthRepository;
  final AppointmentNotifier _appointmentNotifier;
  StreamSubscription<void>? _appointmentSub;

  Future<void> selectDate(DateTime date) async {
    emit(const CalendarLoading());
    try {
      final normalised = DateTime(date.year, date.month, date.day);

      final tasks = await _taskRepository.getTasksForDay(normalised);
      final appointments =
          await _healthRepository.getAppointmentsForDay(normalised);

      final items = <CalendarItem>[
        ...tasks.map(CalendarTask.new),
        ...appointments.map(CalendarAppointment.new),
      ];

      // Tasks first (alphabetical); appointments come pre-sorted from Isar.
      items.sort((a, b) {
        if (a is CalendarTask && b is CalendarAppointment) return -1;
        if (a is CalendarAppointment && b is CalendarTask) return 1;
        if (a is CalendarTask && b is CalendarTask) {
          return a.task.title.compareTo(b.task.title);
        }
        return 0;
      });

      emit(CalendarLoaded(selectedDate: normalised, items: items));
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _appointmentSub?.cancel();
    return super.close();
  }
}
