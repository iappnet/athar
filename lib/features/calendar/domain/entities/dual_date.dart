import 'package:equatable/equatable.dart';
import 'package:hijri/hijri_calendar.dart';

class DualDate extends Equatable {
  /// Midnight-normalized Gregorian day. This is the identity key.
  final DateTime gregorian;

  /// Hijri conversion of [gregorian].
  final HijriCalendar hijri;

  /// True when this day is the 1st of a Hijri month — drives the boundary
  /// hairline + month-name abbreviation in the calendar cell.
  final bool isFirstOfHijriMonth;

  const DualDate({
    required this.gregorian,
    required this.hijri,
    required this.isFirstOfHijriMonth,
  });

  factory DualDate.from(DateTime day) {
    final g = DateTime(day.year, day.month, day.day);
    final h = HijriCalendar.fromDate(g);
    return DualDate(gregorian: g, hijri: h, isFirstOfHijriMonth: h.hDay == 1);
  }

  @override
  List<Object?> get props => [gregorian];
}
