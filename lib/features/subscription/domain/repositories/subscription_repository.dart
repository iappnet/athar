import '../entities/subscription_status.dart';

abstract class SubscriptionRepository {
  /// Current subscription status (single fetch).
  Future<SubscriptionStatus> getStatus();

  /// Live stream — emits whenever RevenueCat CustomerInfo changes.
  Stream<SubscriptionStatus> watchStatus();

  /// Restore previous purchases (Apple requirement).
  Future<SubscriptionStatus> restorePurchases();
}
