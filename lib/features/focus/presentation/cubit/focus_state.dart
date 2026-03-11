import 'package:equatable/equatable.dart';

// --- States ---
abstract class FocusState extends Equatable {
  final int duration;
  const FocusState(this.duration);
  @override
  List<Object> get props => [duration];
}

class FocusInitial extends FocusState {
  const FocusInitial(super.duration);
}

class FocusRunning extends FocusState {
  const FocusRunning(super.duration);
}

class FocusPaused extends FocusState {
  const FocusPaused(super.duration);
}

class FocusCompleted extends FocusState {
  const FocusCompleted() : super(0);
}
