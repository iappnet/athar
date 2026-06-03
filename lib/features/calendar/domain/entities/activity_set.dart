import 'package:equatable/equatable.dart';

/// Dot-presence flags for a single calendar day.
/// Five fixed sources in display order: task, habit, appointment, medicine, prayer.
class ActivitySet extends Equatable {
  final bool hasTask;
  final bool hasHabit;
  final bool hasAppointment;
  final bool hasMedicine;
  final bool hasPrayer;

  const ActivitySet({
    this.hasTask = false,
    this.hasHabit = false,
    this.hasAppointment = false,
    this.hasMedicine = false,
    this.hasPrayer = false,
  });

  static const ActivitySet empty = ActivitySet();

  bool get isEmpty =>
      !hasTask && !hasHabit && !hasAppointment && !hasMedicine && !hasPrayer;

  int get dotCount =>
      (hasTask ? 1 : 0) +
      (hasHabit ? 1 : 0) +
      (hasAppointment ? 1 : 0) +
      (hasMedicine ? 1 : 0) +
      (hasPrayer ? 1 : 0);

  @override
  List<Object?> get props =>
      [hasTask, hasHabit, hasAppointment, hasMedicine, hasPrayer];
}
