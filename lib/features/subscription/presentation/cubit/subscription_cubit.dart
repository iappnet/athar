import 'dart:async';

import 'package:athar/core/config/subscription_config.dart';
import 'package:athar/features/subscription/domain/entities/subscription_status.dart';
import 'package:athar/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

part 'subscription_state.dart';

@injectable
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _repository;
  StreamSubscription<SubscriptionStatus>? _statusSubscription;

  SubscriptionCubit(this._repository) : super(SubscriptionInitial());

  /// Called once at app start — fetches status and listens for live updates.
  Future<void> loadStatus() async {
    emit(SubscriptionLoading());
    try {
      final status = await _repository.getStatus();
      if (isClosed) return;
      emit(SubscriptionLoaded(status));

      _statusSubscription?.cancel();
      _statusSubscription = _repository.watchStatus().listen((s) {
        if (isClosed) return;
        emit(SubscriptionLoaded(s));
      });
    } catch (_) {
      if (isClosed) return;
      emit(const SubscriptionError('تعذر تحميل حالة الاشتراك'));
    }
  }

  // ── Paywall presentation ─────────────────────────────────────────────────

  /// Shows the RevenueCat paywall for [entitlementId].
  /// Returns `true` if the user purchased or restored.
  Future<bool> presentPaywall(
    BuildContext context,
    String entitlementId,
  ) async {
    emit(SubscriptionPurchasing());
    try {
      // Fetch the specific offering explicitly to avoid ambiguity
      // with the 'default' empty offering on the device.
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering(entitlementId);

      if (kDebugMode) {
        debugPrint('RevenueCat offering for $entitlementId: ${offering?.identifier}');
        debugPrint('All offerings: ${offerings.all.keys.toList()}');
      }

      final result = await RevenueCatUI.presentPaywallIfNeeded(
        entitlementId,
        offering: offering,
        displayCloseButton: true,
      );
      final purchased =
          result == PaywallResult.purchased || result == PaywallResult.restored;
      await loadStatus();
      return purchased;
    } catch (e) {
      if (isClosed) return false;
      if (kDebugMode) debugPrint('Paywall error: $e');
      emit(const SubscriptionError('حدث خطأ أثناء عرض شاشة الاشتراك'));
      return false;
    }
  }

  Future<bool> presentSpacesPaywall(BuildContext context) =>
      presentPaywall(context, SubscriptionConfig.entitlementSpacesPro);

  Future<bool> presentSyncPaywall(BuildContext context) =>
      presentPaywall(context, SubscriptionConfig.entitlementSyncPro);

  Future<bool> presentHealthPaywall(BuildContext context) =>
      presentPaywall(context, SubscriptionConfig.entitlementHealthPack);

  Future<bool> presentAssetsPaywall(BuildContext context) =>
      presentPaywall(context, SubscriptionConfig.entitlementAssetsPack);

  // ── Restore ──────────────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    emit(SubscriptionLoading());
    try {
      final status = await _repository.restorePurchases();
      if (isClosed) return;
      emit(SubscriptionRestored(status));
      emit(SubscriptionLoaded(status));
    } catch (_) {
      if (isClosed) return;
      emit(const SubscriptionError('فشل استعادة المشتريات'));
    }
  }

  // ── Customer Center ──────────────────────────────────────────────────────

  Future<void> presentCustomerCenter(BuildContext context) async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (_) {}
  }

  // ── Synchronous access helpers (used by other cubits via getIt) ──────────

  T _access<T>(T defaultVal, T Function(SubscriptionStatus) fn) {
    final s = state;
    return s is SubscriptionLoaded ? fn(s.status) : defaultVal;
  }

  bool get hasSpacesPro => _access(false, (s) => s.hasSpacesPro);
  bool get hasSyncPro => _access(false, (s) => s.hasSyncPro);
  bool get hasHealthPack => _access(false, (s) => s.hasHealthPack);
  bool get hasAssetsPack => _access(false, (s) => s.hasAssetsPack);
  bool get hasUnlimitedTasksAndHabits =>
      _access(false, (s) => s.hasUnlimitedTasksAndHabits);
  bool get hasSyncAccess => _access(false, (s) => s.hasSyncAccess);

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
