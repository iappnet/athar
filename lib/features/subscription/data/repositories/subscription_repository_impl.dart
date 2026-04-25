import 'dart:async';

import 'package:athar/core/config/subscription_config.dart';
import 'package:athar/features/subscription/domain/entities/subscription_status.dart';
import 'package:athar/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

@LazySingleton(as: SubscriptionRepository)
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final StreamController<SubscriptionStatus> _controller =
      StreamController<SubscriptionStatus>.broadcast();

  SubscriptionRepositoryImpl() {
    Purchases.addCustomerInfoUpdateListener((info) {
      _controller.add(_map(info));
    });
  }

  @override
  Future<SubscriptionStatus> getStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return _map(info);
    } catch (_) {
      return SubscriptionStatus.free;
    }
  }

  @override
  Stream<SubscriptionStatus> watchStatus() => _controller.stream;

  @override
  Future<SubscriptionStatus> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    return _map(info);
  }

  // ── private ──────────────────────────────────────────────────────────────

  SubscriptionStatus _map(CustomerInfo info) {
    final e = info.entitlements.all;

    final hasSpacesPro =
        e[SubscriptionConfig.entitlementSpacesPro]?.isActive == true;
    final hasSyncPro =
        e[SubscriptionConfig.entitlementSyncPro]?.isActive == true;
    final hasHealthPack =
        e[SubscriptionConfig.entitlementHealthPack]?.isActive == true;
    final hasAssetsPack =
        e[SubscriptionConfig.entitlementAssetsPack]?.isActive == true;

    DateTime? parseExp(String? raw) =>
        raw != null ? DateTime.tryParse(raw) : null;

    return SubscriptionStatus(
      hasSpacesPro: hasSpacesPro,
      hasSyncPro: hasSyncPro,
      hasHealthPack: hasHealthPack,
      hasAssetsPack: hasAssetsPack,
      spacesProExpirationDate:
          parseExp(e[SubscriptionConfig.entitlementSpacesPro]?.expirationDate),
      syncProExpirationDate:
          parseExp(e[SubscriptionConfig.entitlementSyncPro]?.expirationDate),
    );
  }
}
