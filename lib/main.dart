// lib/main.dart

import 'dart:io';

import 'package:athar/app.dart';
import 'package:athar/core/config/subscription_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:athar/core/services/appointment_notification_scheduler.dart';
import 'package:athar/core/services/fcm_service.dart';
import 'package:athar/core/services/habit_notification_scheduler.dart';
import 'package:athar/core/services/local_notification_service.dart';
import 'package:athar/core/services/medication_notification_scheduler.dart';
import 'package:athar/core/services/prayer_notification_scheduler.dart';
import 'package:athar/core/services/task_notification_scheduler.dart';
import 'package:athar/core/services/sync_service.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:athar/core/di/injection.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athar/core/services/deep_link_service.dart';
import 'package:athar/core/services/widget_data_service.dart';
import 'package:athar/features/home/presentation/pages/onboarding_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    final isTablet =
        WidgetsBinding
                .instance
                .platformDispatcher
                .views
                .first
                .physicalSize
                .shortestSide /
            WidgetsBinding
                .instance
                .platformDispatcher
                .views
                .first
                .devicePixelRatio >=
        600;

    if (!isTablet) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.maybeGet('SUPABASE_URL');
  final supabaseAnonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');
  assert(
    supabaseUrl != null && supabaseUrl.isNotEmpty,
    'SUPABASE_URL غير موجود في ملف .env — تأكد من نسخ .env.example وتعبئة القيم',
  );
  assert(
    supabaseAnonKey != null && supabaseAnonKey.isNotEmpty,
    'SUPABASE_ANON_KEY غير موجود في ملف .env — تأكد من نسخ .env.example وتعبئة القيم',
  );

  // ── Critical init (must complete before first frame) ──────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: supabaseUrl!,
    anonKey: supabaseAnonKey!,
  );

  final rcKey = Platform.isIOS
      ? SubscriptionConfig.revenueCatIosKey
      : SubscriptionConfig.revenueCatAndroidKey;
  assert(
    rcKey.isNotEmpty,
    Platform.isIOS
        ? 'REVENUE_CAT_IOS_KEY غير موجود في ملف .env'
        : 'REVENUE_CAT_ANDROID_KEY غير موجود في ملف .env',
  );
  await Purchases.configure(PurchasesConfiguration(rcKey));
  if (kDebugMode) {
    await Purchases.setLogLevel(LogLevel.debug);
  }

  await configureDependencies();

  // First-run check: skip splash on first launch so onboarding shows immediately.
  // On all subsequent launches show the splash while background APIs warm up.
  final hasSeenOnboarding = await OnboardingPage.hasBeenSeen();

  // ── Render the app immediately — splash screen appears now ────────────────
  runApp(AtharApp(hasSeenOnboarding: hasSeenOnboarding));

  // ── Non-critical init runs concurrently after first frame ─────────────────
  // Notification permission dialog, schedulers, FCM token — all fire after
  // the user already sees the green splash screen instead of a white screen.
  _initBackground();
}

Future<void> _initBackground() async {
  await getIt<WidgetDataService>().init();
  await getIt<SpaceRepository>().initDefaultData();
  getIt<SyncService>().syncTasks();
  await getIt<HabitRepository>().ensureSystemHabits();
  await initializeDateFormatting('ar', null);
  await getIt<DeepLinkService>().init();

  if (kDebugMode) print('📱 Initializing LocalNotificationService...');
  await getIt<LocalNotificationService>().init(
    onAutoRenewal: _handleAutoRenewal,
  );
  if (kDebugMode) print('✅ LocalNotificationService initialized');

  await getIt<FCMService>().init();

  final authCubit = getIt<AuthCubit>();
  final authState = authCubit.state;
  if (authState is AuthAuthenticated) {
    if (kDebugMode) {
      print('🔐 Updating FCM token for: ${authState.username}');
    }
    await getIt<FCMService>().saveFCMTokenToSupabase(authState.username);
  }

  try {
    if (kDebugMode) print('🕌 Initializing PrayerNotificationScheduler...');
    await getIt<PrayerNotificationScheduler>().initializeScheduling();
    if (kDebugMode) print('✅ PrayerNotificationScheduler initialized');
  } catch (e) {
    if (kDebugMode) print('❌ PrayerNotificationScheduler error: $e');
  }

  try {
    if (kDebugMode) print('💊 Initializing MedicationNotificationScheduler...');
    await getIt<MedicationNotificationScheduler>().initializeScheduling();
    if (kDebugMode) print('✅ MedicationNotificationScheduler initialized');
  } catch (e) {
    if (kDebugMode) print('❌ MedicationNotificationScheduler error: $e');
  }

  try {
    if (kDebugMode) print('📋 Initializing TaskNotificationScheduler...');
    await getIt<TaskNotificationScheduler>().initializeScheduling();
    if (kDebugMode) print('✅ TaskNotificationScheduler initialized');
  } catch (e) {
    if (kDebugMode) print('⚠️ TaskNotificationScheduler not available: $e');
  }
}

Future<void> _handleAutoRenewal(String payload) async {
  if (kDebugMode) print('🔄 Auto-renewal triggered: $payload');

  try {
    if (payload == 'auto_reschedule_prayers') {
      await getIt<PrayerNotificationScheduler>().initializeScheduling();
      return;
    }
    if (payload == 'auto_reschedule_medications') {
      await getIt<MedicationNotificationScheduler>().initializeScheduling();
      return;
    }
    if (payload == 'auto_reschedule_tasks') {
      try {
        await getIt<TaskNotificationScheduler>().initializeScheduling();
      } catch (e) {
        if (kDebugMode) print('⚠️ TaskNotificationScheduler not available: $e');
      }
      return;
    }
    if (payload == 'auto_reschedule_appointments') {
      await getIt<AppointmentNotificationScheduler>().initializeScheduling();
      return;
    }
    if (payload == 'auto_reschedule_habits') {
      await getIt<HabitNotificationScheduler>().initializeScheduling();
      return;
    }
    if (kDebugMode) print('⚠️ Unknown auto-renewal payload: $payload');
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ Error during auto-renewal: $e\n$stackTrace');
    }
  }
}
