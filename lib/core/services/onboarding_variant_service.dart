import 'package:shared_preferences/shared_preferences.dart';

enum OnboardingVariant { existing, existingRestyled, short, expanded }

class OnboardingVariantService {
  static const _variantKey = 'onboarding_variant';
  static const _deviceIdKey = 'device_id';

  final SharedPreferences _prefs;

  OnboardingVariantService(this._prefs);

  /// Returns the variant for this device, assigning one on first call.
  ///
  /// --dart-define=ONBOARDING_VARIANT=existing|existing_restyled|short|expanded
  /// overrides the assigned variant (QA / developer testing).
  OnboardingVariant assignOrGet() {
    const override = String.fromEnvironment('ONBOARDING_VARIANT', defaultValue: '');
    if (override.isNotEmpty) {
      return OnboardingVariant.values.firstWhere(
        (v) => v.name == _snakeToCamel(override),
        orElse: () => OnboardingVariant.existing,
      );
    }

    final stored = _prefs.getString(_variantKey);
    if (stored != null) {
      return OnboardingVariant.values.firstWhere(
        (v) => v.name == stored,
        orElse: () => OnboardingVariant.existing,
      );
    }

    // First call — assign deterministically from device_id hash (25/25/25/25 split).
    // device_id must be seeded in main.dart before this call.
    final hash = _prefs.getString(_deviceIdKey)?.hashCode ?? 0;
    final bucket = hash.abs() % 4;
    final assigned = OnboardingVariant.values[bucket];
    _prefs.setString(_variantKey, assigned.name);
    return assigned;
  }

  /// Clears the stored variant so `assignOrGet` re-assigns on next call.
  /// Also clears `onboarding_seen`. For dev/QA use only.
  Future<void> reset() async {
    await _prefs.remove(_variantKey);
    await _prefs.remove('onboarding_seen');
  }

  /// 'existing_restyled' → 'existingRestyled' for dart-define matching.
  static String _snakeToCamel(String s) {
    final parts = s.split('_');
    if (parts.length <= 1) return s;
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1)).join();
  }
}
