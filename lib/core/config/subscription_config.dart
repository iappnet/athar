import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central place for all subscription-related constants.
/// Edit these values to change free-tier limits or product / entitlement
/// identifiers without touching business logic.
class SubscriptionConfig {
  // ── Free-tier limits (easy to adjust) ───────────────────────────────────
  static const int freeTasksLimit = 20;
  static const int freeHabitsLimit = 5;

  // ── RevenueCat SDK keys (loaded from .env, never hardcoded) ─────────────
  // iOS key: RevenueCat Dashboard → Project Settings → API Keys (starts with appl_)
  // Android key: same dashboard (starts with goog_)
  static String get revenueCatIosKey =>
      dotenv.get('REVENUE_CAT_IOS_KEY', fallback: '');
  static String get revenueCatAndroidKey =>
      dotenv.get('REVENUE_CAT_ANDROID_KEY', fallback: '');

  // ── Entitlement identifiers (must match RevenueCat dashboard exactly) ────
  /// Subscription — unlocks Spaces + Sync + unlimited tasks & habits.
  static const String entitlementSpacesPro = 'spaces_pro';

  /// Standalone Sync subscription — unlocks cloud sync without Spaces.
  static const String entitlementSyncPro = 'sync_pro';

  /// One-time purchase — unlocks the Health module.
  static const String entitlementHealthPack = 'health_pack';

  /// One-time purchase — unlocks the Assets module.
  static const String entitlementAssetsPack = 'assets_pack';

  // ── Product identifiers (must match App Store Connect / Play Console) ────
  static const String productSpacesMonthly =
      'com.iappsnet.athar.spaces.monthly';
  static const String productSpacesAnnual = 'com.iappsnet.athar.spaces.annual';
  static const String productSyncMonthly = 'com.iappsnet.athar.sync.monthly';
  static const String productSyncAnnual = 'com.iappsnet.athar.sync.annual';
  static const String productHealth = 'com.iappsnet.athar.health';
  static const String productAssets = 'com.iappsnet.athar.assets';
}
