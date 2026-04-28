import 'package:equatable/equatable.dart';
import 'package:athar/features/stats/domain/models/stats_data.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {
  const StatsInitial();
}

class StatsLoading extends StatsState {
  const StatsLoading();
}

class StatsLoaded extends StatsState {
  final StatsData data;
  final int rangeDays;

  const StatsLoaded({required this.data, required this.rangeDays});

  @override
  List<Object?> get props => [data, rangeDays];
}

class StatsError extends StatsState {
  final String message;

  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}
