part of 'calendar_month_cubit.dart';

sealed class CalendarMonthState extends Equatable {
  const CalendarMonthState();

  @override
  List<Object?> get props => [];
}

final class CalendarMonthLoading extends CalendarMonthState {
  const CalendarMonthLoading();
}

final class CalendarMonthLoaded extends CalendarMonthState {
  const CalendarMonthLoaded({
    required this.focusedMonth,
    required this.dualDates,
    required this.activityByDate,
    required this.primaryHijri,
  });

  /// The first day of the currently visible month.
  final DateTime focusedMonth;

  /// DualDate cache — keyed by midnight-normalized Gregorian DateTime.
  /// Covers visible month ± 1-month buffer.
  final Map<DateTime, DualDate> dualDates;

  /// Activity dot flags keyed by midnight-normalized Gregorian DateTime.
  final Map<DateTime, ActivitySet> activityByDate;

  /// True when Hijri numeral is the primary (large/top) numeral.
  /// Equals settings.isHijriMode.
  final bool primaryHijri;

  @override
  List<Object?> get props => [focusedMonth, primaryHijri];
}

final class CalendarMonthError extends CalendarMonthState {
  const CalendarMonthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
