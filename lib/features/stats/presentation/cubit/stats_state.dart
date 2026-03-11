import 'package:equatable/equatable.dart'; // يفضل استخدام Equatable للمقارنة

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object> get props => [];
}

class StatsInitial extends StatsState {
  const StatsInitial();
}

class StatsLoading extends StatsState {
  const StatsLoading();
}

class StatsLoaded extends StatsState {
  final List<int> weeklyFocus;

  const StatsLoaded(this.weeklyFocus);

  @override
  List<Object> get props => [weeklyFocus];
}

class StatsError extends StatsState {
  final String message;
  const StatsError(this.message);

  @override
  List<Object> get props => [message];
}
