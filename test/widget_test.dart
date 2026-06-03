import 'package:athar/app.dart' show AtharApp;
import 'package:athar/core/services/onboarding_variant_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AtharApp can be instantiated', () {
    expect(
      const AtharApp(
        hasSeenOnboarding: true,
        onboardingVariant: OnboardingVariant.existing,
      ),
      isNotNull,
    );
  });
}
