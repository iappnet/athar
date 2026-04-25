part of 'subscription_cubit.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionStatus status;
  const SubscriptionLoaded(this.status);
  @override
  List<Object?> get props => [status];
}

class SubscriptionPurchasing extends SubscriptionState {}

/// Emitted after restore completes — caller shows a snackbar.
class SubscriptionRestored extends SubscriptionState {
  final SubscriptionStatus status;
  const SubscriptionRestored(this.status);
  @override
  List<Object?> get props => [status];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
  @override
  List<Object?> get props => [message];
}
