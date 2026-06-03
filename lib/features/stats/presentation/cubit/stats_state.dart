import 'package:athar/features/stats/domain/models/stats_data.dart';
import 'package:equatable/equatable.dart';

enum StatsPeriod { today, last7Days, last30Days }

extension StatsPeriodExt on StatsPeriod {
  int get rangeDays => switch (this) {
        StatsPeriod.today => 1,
        StatsPeriod.last7Days => 7,
        StatsPeriod.last30Days => 30,
      };
}

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {
  const StatsInitial();
}

class StatsLoading extends StatsState {
  final StatsPeriod period;

  const StatsLoading({this.period = StatsPeriod.last7Days});

  @override
  List<Object?> get props => [period];
}

class StatsLoaded extends StatsState {
  final StatsData data;
  final StatsPeriod period;

  const StatsLoaded({required this.data, required this.period});

  int get rangeDays => period.rangeDays;

  @override
  List<Object?> get props => [data, period];
}

class StatsError extends StatsState {
  final String message;
  final StatsPeriod period;

  const StatsError(this.message, {this.period = StatsPeriod.last7Days});

  @override
  List<Object?> get props => [message, period];
}
