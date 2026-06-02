import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin analytics emitter for onboarding lifecycle events.
///
/// Writes to the Supabase `onboarding_events` table (insert-only RLS for anon).
/// user_id is nullable — rows are inserted pre-auth; user_id is backfilled
/// via the device_id column after authentication if needed.
///
/// OQ5 ruling: anon insert path is the primary strategy. If the Supabase
/// project's RLS blocks anon inserts (policy not yet applied), rows are
/// silently dropped — analytics must never crash the app. A post-auth flush
/// strategy can be layered on later if needed.
class OnboardingAnalyticsService {
  static const _table = 'onboarding_events';

  final String? deviceId;

  const OnboardingAnalyticsService({this.deviceId});

  Future<void> onboardingStarted(String variant) async {
    await _insert({
      'event_name': 'onboarding_started',
      'variant': variant,
      'properties': <String, dynamic>{},
    });
  }

  Future<void> onboardingStepCompleted({
    required String variant,
    required String step,
  }) async {
    await _insert({
      'event_name': 'onboarding_step_completed',
      'variant': variant,
      'properties': {'step': step},
    });
  }

  Future<void> onboardingStepSkipped({
    required String variant,
    required String step,
  }) async {
    await _insert({
      'event_name': 'onboarding_step_skipped',
      'variant': variant,
      'properties': {'step': step},
    });
  }

  Future<void> onboardingCompleted({
    required String variant,
    required int durationMs,
    bool locationGranted = false,
    bool notificationsGranted = false,
  }) async {
    await _insert({
      'event_name': 'onboarding_completed',
      'variant': variant,
      'properties': {
        'duration_ms': durationMs,
        'permissions_granted': {
          'location': locationGranted,
          'notifications': notificationsGranted,
        },
      },
    });
  }

  Future<void> onboardingAbandoned({
    required String variant,
    String? lastStep,
  }) async {
    await _insert({
      'event_name': 'onboarding_abandoned',
      'variant': variant,
      'properties': {'last_step': lastStep},
    });
  }

  Future<void> _insert(Map<String, dynamic> data) async {
    try {
      final client = Supabase.instance.client;
      await client.from(_table).insert({
        'user_id': client.auth.currentUser?.id,
        'device_id': deviceId,
        ...data,
      });
    } catch (e) {
      // Analytics must never crash the app.
      if (kDebugMode) debugPrint('[OnboardingAnalytics] insert failed: $e');
    }
  }
}
