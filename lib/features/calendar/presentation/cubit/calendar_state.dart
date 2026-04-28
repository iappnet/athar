part of 'calendar_cubit.dart';

sealed class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

final class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

final class CalendarLoaded extends CalendarState {
  const CalendarLoaded({
    required this.selectedDate,
    required this.items,
  });

  final DateTime selectedDate;
  final List<CalendarItem> items;

  @override
  List<Object?> get props => [selectedDate, items];
}

final class CalendarError extends CalendarState {
  const CalendarError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
