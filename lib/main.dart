// lib/main.dart

import 'package:athar/app.dart';
import 'package:athar/core/services/appointment_notification_scheduler.dart';
import 'package:athar/core/services/fcm_service.dart';
import 'package:athar/core/services/habit_notification_scheduler.dart';
import 'package:athar/core/services/local_notification_service.dart';
import 'package:athar/core/services/medication_notification_scheduler.dart';
import 'package:athar/core/services/prayer_notification_scheduler.dart';
import 'package:athar/core/services/task_notification_scheduler.dart'; // ✅ إضافة
import 'package:athar/core/services/sync_service.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:athar/core/di/injection.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athar/core/services/deep_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل ملف البيئة (.env) أولاً
  await dotenv.load(fileName: ".env");

  // تهيئة Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  // تهيئة الحقن (GetIt)
  await configureDependencies();

  // حقن البيانات الافتراضية للزوار
  await getIt<SpaceRepository>().initDefaultData();

  // بدء المزامنة في الخلفية
  getIt<SyncService>().syncTasks();

  // ترتيب الأذكار
  await getIt<HabitRepository>().ensureSystemHabits();

  // ═══════════════════════════════════════════════════════════
  // ✅✅✅ الإصلاح الجديد: تهيئة LocalNotificationService مع callback
  // ═══════════════════════════════════════════════════════════

  if (kDebugMode) {
    print('📱 Initializing LocalNotificationService...');
  }
  await getIt<LocalNotificationService>().init(
    onAutoRenewal: _handleAutoRenewal, // ✅ تمرير الـ callback
  );
  if (kDebugMode) {
    print('✅ LocalNotificationService initialized');
  }

  // تهيئة FCMService
  await getIt<FCMService>().init();

  // ✅ إضافة: إذا كان المستخدم مسجلاً، قم بتحديث الـ Token في Supabase فوراً
  final authCubit = getIt<AuthCubit>();
  final authState = authCubit.state;

  if (authState is AuthAuthenticated) {
    final userId = authState.username;
    if (kDebugMode) {
      print('🔐 User authenticated, updating FCM token for: $userId');
    }
    await getIt<FCMService>().saveFCMTokenToSupabase(userId);
  }

  // ═══════════════════════════════════════════════════════════
  // تهيئة جميع Schedulers
  // ═══════════════════════════════════════════════════════════

  // 1. PrayerNotificationScheduler
  if (kDebugMode) {
    print('🕌 Initializing PrayerNotificationScheduler...');
  }
  try {
    await getIt<PrayerNotificationScheduler>().initializeScheduling();
    if (kDebugMode) {
      print('✅ PrayerNotificationScheduler initialized');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error initializing PrayerNotificationScheduler: $e');
    }
  }

  // 2. MedicationNotificationScheduler
  if (kDebugMode) {
    print('💊 Initializing MedicationNotificationScheduler...');
  }
  try {
    await getIt<MedicationNotificationScheduler>().initializeScheduling();
    if (kDebugMode) {
      print('✅ MedicationNotificationScheduler initialized');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error initializing MedicationNotificationScheduler: $e');
    }
  }

  // 3. TaskNotificationScheduler (إذا موجود)
  try {
    if (kDebugMode) {
      print('📋 Initializing TaskNotificationScheduler...');
    }
    await getIt<TaskNotificationScheduler>().initializeScheduling();
    if (kDebugMode) {
      print('✅ TaskNotificationScheduler initialized');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ TaskNotificationScheduler not available or error: $e');
    }
  }

  // تهيئة التاريخ العربي
  await initializeDateFormatting('ar', null);

  // تهيئة خدمة الروابط
  await getIt<DeepLinkService>().init();

  runApp(const AtharApp());
}

// ═══════════════════════════════════════════════════════════
// ✅✅✅ معالج Auto-Renewal (الإصلاح الحرج)
// ═══════════════════════════════════════════════════════════

/// ✅ معالجة auto-renewal لجميع الأنظمة
Future<void> _handleAutoRenewal(String payload) async {
  if (kDebugMode) {
    print('🔄 Auto-renewal triggered with payload: $payload');
  }

  try {
    // ✅ معالجة auto-renewal للصلاة
    if (payload == 'auto_reschedule_prayers') {
      if (kDebugMode) {
        print('🕌 Rescheduling prayers...');
      }
      await getIt<PrayerNotificationScheduler>().initializeScheduling();
      if (kDebugMode) {
        print('✅ Prayers rescheduled successfully');
      }
      return;
    }

    // ✅ معالجة auto-renewal للأدوية
    if (payload == 'auto_reschedule_medications') {
      if (kDebugMode) {
        print('💊 Rescheduling medications...');
      }
      await getIt<MedicationNotificationScheduler>().initializeScheduling();
      if (kDebugMode) {
        print('✅ Medications rescheduled successfully');
      }
      return;
    }

    // ✅ معالجة auto-renewal للمهام
    if (payload == 'auto_reschedule_tasks') {
      if (kDebugMode) {
        print('📋 Rescheduling tasks...');
      }
      try {
        await getIt<TaskNotificationScheduler>().initializeScheduling();
        if (kDebugMode) {
          print('✅ Tasks rescheduled successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ TaskNotificationScheduler not available: $e');
        }
      }
      return;
    }

    // ✅ معالجة auto-renewal للمواعيد (للمستقبل)
    if (payload == 'auto_reschedule_appointments') {
      if (kDebugMode) {
        print('🏥 Rescheduling appointments...');
      }
      await getIt<AppointmentNotificationScheduler>().initializeScheduling();
      return;
    }

    // ✅ معالجة auto-renewal للعادات (للمستقبل)
    if (payload == 'auto_reschedule_habits') {
      if (kDebugMode) {
        print('💪 Rescheduling habits...');
      }
      await getIt<HabitNotificationScheduler>().initializeScheduling();
      return;
    }

    // إذا وصلنا هنا، payload غير معروف
    if (kDebugMode) {
      print('⚠️ Unknown auto-renewal payload: $payload');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ Error during auto-renewal: $e');
    }
    if (kDebugMode) {
      print('Stack trace: $stackTrace');
    }
  }
}
