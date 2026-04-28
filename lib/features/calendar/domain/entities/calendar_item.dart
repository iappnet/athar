// lib/features/calendar/domain/entities/calendar_item.dart
//
// Pure aggregation model — no Isar, no network dependencies.
// Aggregates tasks and health appointments into a unified list
// for a given calendar day.

import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:equatable/equatable.dart';

sealed class CalendarItem extends Equatable {
  const CalendarItem();
}

final class CalendarTask extends CalendarItem {
  const CalendarTask(this.task);

  final TaskModel task;

  @override
  List<Object?> get props => [task.uuid];
}

final class CalendarAppointment extends CalendarItem {
  const CalendarAppointment(this.appointment);

  final AppointmentModel appointment;

  @override
  List<Object?> get props => [appointment.uuid];
}
