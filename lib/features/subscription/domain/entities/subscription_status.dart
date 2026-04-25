import 'package:equatable/equatable.dart';

class SubscriptionStatus extends Equatable {
  /// Subscription — unlocks Spaces + Sync + unlimited tasks/habits.
  final bool hasSpacesPro;

  /// Standalone Sync subscription — unlocks cloud sync without Spaces.
  final bool hasSyncPro;

  /// One-time purchase — unlocks the Health module.
  final bool hasHealthPack;

  /// One-time purchase — unlocks the Assets module.
  final bool hasAssetsPack;

  /// Expiry for spaces_pro (null when not subscribed).
  final DateTime? spacesProExpirationDate;

  /// Expiry for the standalone sync_pro subscription.
  final DateTime? syncProExpirationDate;

  const SubscriptionStatus({
    this.hasSpacesPro = false,
    this.hasSyncPro = false,
    this.hasHealthPack = false,
    this.hasAssetsPack = false,
    this.spacesProExpirationDate,
    this.syncProExpirationDate,
  });

  static const free = SubscriptionStatus();

  // ── Derived access helpers ────────────────────────────────────────────────

  /// Sync is available with either a Spaces Pro or a standalone Sync subscription.
  bool get hasSyncAccess => hasSpacesPro || hasSyncPro;

  /// Task and habit free limits are lifted when the user holds any paid entitlement.
  bool get hasUnlimitedTasksAndHabits =>
      hasSpacesPro || hasSyncPro || hasHealthPack || hasAssetsPack;

  /// True if the user has never purchased anything.
  bool get isFullyFree =>
      !hasSpacesPro && !hasSyncPro && !hasHealthPack && !hasAssetsPack;

  @override
  List<Object?> get props => [
    hasSpacesPro,
    hasSyncPro,
    hasHealthPack,
    hasAssetsPack,
    spacesProExpirationDate,
    syncProExpirationDate,
  ];
}
