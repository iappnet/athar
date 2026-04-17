// lib/features/focus/presentation/cubit/focus_cubit.dart
// ✅ النسخة المُحسَّنة مع تنبيه انتهاء الوقت + إبقاء الشاشة مضاءة

import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/local_notification_service.dart';
import 'package:athar/features/focus/data/repositories/focus_repository.dart';
import 'package:athar/features/focus/presentation/cubit/focus_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// ═══════════════════════════════════════════════════════════════════
// Ticker (إذا لم يكن في ملف منفصل)
// ═══════════════════════════════════════════════════════════════════

class Ticker {
  const Ticker();

  Stream<int> tick({required int ticks}) {
    return Stream.periodic(
      const Duration(seconds: 1),
      (x) => ticks - x - 1,
    ).take(ticks);
  }
}

// ═══════════════════════════════════════════════════════════════════
// FocusCubit المُحسَّن
// ═══════════════════════════════════════════════════════════════════

@injectable
class FocusCubit extends Cubit<FocusState> {
  final Ticker _ticker;
  final FocusRepository _repository;

  StreamSubscription<int>? _tickerSubscription;

  // ═══════════════════════════════════════════════════════════════════
  // إعدادات المدة
  // ═══════════════════════════════════════════════════════════════════

  static const Map<String, int> presets = {
    'pomodoro': 25 * 60, // 25 دقيقة
    'short': 15 * 60, // 15 دقيقة
    'long': 45 * 60, // 45 دقيقة
    'hour': 60 * 60, // ساعة
  };

  int _selectedDuration = presets['pomodoro']!;
  String? _currentTaskName;
  DateTime? _sessionStartTime;
  int _pauseCount = 0;

  FocusCubit(this._repository)
    : _ticker = const Ticker(),
      super(FocusInitial(presets['pomodoro']!));

  // ═══════════════════════════════════════════════════════════════════
  // إعداد المدة
  // ═══════════════════════════════════════════════════════════════════

  /// تعيين مدة من الإعدادات المسبقة
  void setDuration(String preset) {
    _selectedDuration = presets[preset] ?? presets['pomodoro']!;
    emit(FocusInitial(_selectedDuration));
  }

  /// تعيين مدة مخصصة (بالدقائق)
  void setCustomDuration(int minutes) {
    _selectedDuration = minutes * 60;
    emit(FocusInitial(_selectedDuration));
  }

  /// تعيين المهمة المرتبطة
  void setTask(String? taskName) {
    _currentTaskName = taskName;
  }

  /// الحصول على المدة الحالية بالدقائق
  int get currentDurationMinutes => _selectedDuration ~/ 60;

  // ═══════════════════════════════════════════════════════════════════
  // التحكم بالمؤقت
  // ═══════════════════════════════════════════════════════════════════

  Future<void> startTimer() async {
    int duration = state.duration == 0 ? _selectedDuration : state.duration;
    _sessionStartTime = DateTime.now();
    _pauseCount = 0;

    // ✅ تفعيل WakeLock لإبقاء الشاشة مضاءة
    await _enableWakeLock();

    emit(FocusRunning(duration));

    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: duration)
        .listen(
          (duration) {
            if (duration > 0) {
              emit(FocusRunning(duration));
            } else {
              _completeSession();
            }
          },
          onDone: () {
            // التأكد من إكمال الجلسة
            if (state is FocusRunning) {
              _completeSession();
            }
          },
        );
  }

  void pauseTimer() {
    if (state is FocusRunning) {
      _tickerSubscription?.pause();
      _pauseCount++;
      emit(FocusPaused(state.duration));
    }
  }

  void resumeTimer() {
    if (state is FocusPaused) {
      _tickerSubscription?.resume();
      emit(FocusRunning(state.duration));
    }
  }

  Future<void> resetTimer() async {
    _tickerSubscription?.cancel();
    _sessionStartTime = null;
    _pauseCount = 0;

    // ✅ تعطيل WakeLock
    await _disableWakeLock();

    emit(FocusInitial(_selectedDuration));
  }

  // ═══════════════════════════════════════════════════════════════════
  // إكمال الجلسة
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _completeSession() async {
    _tickerSubscription?.cancel();

    // 1. تعطيل WakeLock
    await _disableWakeLock();

    // 2. حفظ الجلسة
    await _saveSessionData();

    // 3. تنبيه المستخدم
    await _notifyCompletion();

    // 4. تحديث الحالة
    emit(const FocusCompleted());
  }

  Future<void> _saveSessionData() async {
    try {
      // حساب المدة الفعلية
      final actualDuration = _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!).inSeconds
          : _selectedDuration;

      await _repository.saveSession(actualDuration);

      if (kDebugMode) {
        print('✅ Focus session saved: ${actualDuration ~/ 60} minutes');
        if (_currentTaskName != null) {
          print('   Task: $_currentTaskName');
        }
        print('   Pauses: $_pauseCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving focus session: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ✅✅✅ تنبيه انتهاء الوقت - الإصلاح الرئيسي
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _notifyCompletion() async {
    try {
      // 1. اهتزاز قوي (نمط متكرر)
      await _vibrateCompletion();

      // 2. صوت نظام (بدون package إضافي)
      await _playSystemSound();

      // 3. إشعار محلي
      await _showCompletionNotification();

      if (kDebugMode) {
        print('🔔 Focus completion notification sent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error notifying completion: $e');
      }
    }
  }

  /// ✅ اهتزاز قوي عند الانتهاء
  Future<void> _vibrateCompletion() async {
    try {
      // نمط اهتزاز: اهتزاز - توقف - اهتزاز - توقف - اهتزاز
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Vibration not available: $e');
      }
    }
  }

  /// ✅ تشغيل صوت النظام
  Future<void> _playSystemSound() async {
    try {
      // استخدام SystemSound من Flutter (لا يحتاج package إضافي)
      await SystemSound.play(SystemSoundType.alert);

      // تكرار الصوت 3 مرات
      for (int i = 0; i < 2; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        await SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ System sound not available: $e');
      }
    }
  }

  /// ✅ إظهار إشعار محلي
  Future<void> _showCompletionNotification() async {
    try {
      final notificationService = getIt<LocalNotificationService>();

      final minutes = _selectedDuration ~/ 60;
      final taskInfo = _currentTaskName != null
          ? '\nالمهمة: $_currentTaskName'
          : '';

      // استخدام showNow بدلاً من showInstant (حسب الكود الموجود)
      await notificationService.showNow(
        id: 999999, // ID ثابت لإشعارات التركيز
        title: 'انتهى وقت التركيز! 🎉',
        body: 'أحسنت! أكملت $minutes دقيقة من التركيز$taskInfo',
        payload: 'focus:completed',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error showing notification: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // WakeLock - إبقاء الشاشة مضاءة
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _enableWakeLock() async {
    try {
      await WakelockPlus.enable();
      if (kDebugMode) {
        print('🔆 WakeLock enabled - screen will stay on');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ WakeLock not available: $e');
      }
    }
  }

  Future<void> _disableWakeLock() async {
    try {
      await WakelockPlus.disable();
      if (kDebugMode) {
        print('🔅 WakeLock disabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error disabling WakeLock: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // التنظيف
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> close() async {
    _tickerSubscription?.cancel();
    await _disableWakeLock();
    return super.close();
  }
}

//---------------------------------------------------------------------------
// import 'dart:async';
// import 'package:athar/features/focus/presentation/cubit/focus_state.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';
// import '../../data/ticker.dart';
// import '../../data/repositories/focus_repository.dart';

// // --- Cubit ---
// @injectable // لا تنس هذا لتسجيله
// class FocusCubit extends Cubit<FocusState> {
//   final Ticker _ticker;
//   final FocusRepository _repository; // <--- إضافة المستودع
//   StreamSubscription<int>? _tickerSubscription;

//   // المدة الافتراضية: 25 دقيقة (1500 ثانية)
//   static const int _defaultDuration = 25 * 60;
//   //  25 * 60;

//   FocusCubit(this._repository)
//     : _ticker = const Ticker(),
//       super(const FocusInitial(_defaultDuration));

//   void startTimer() {
//     // إذا بدأنا، نستخدم الوقت الحالي في الحالة، وإذا كان منتهياً نبدأ من جديد
//     int duration = state.duration == 0 ? _defaultDuration : state.duration;

//     emit(FocusRunning(duration));

//     _tickerSubscription?.cancel();
//     _tickerSubscription = _ticker.tick(ticks: duration).listen((duration) {
//       if (duration > 0) {
//         emit(FocusRunning(duration));
//       } else {
//         // --- التعديل هنا: انتهى الوقت ---
//         _completeSession();
//         emit(const FocusCompleted());
//         _tickerSubscription?.cancel();
//       }
//     });
//   }

//   // دالة لحفظ الجلسة
//   Future<void> _completeSession() async {
//     // نحفظ المدة الأصلية (25 دقيقة)
//     // await _repository.saveSession(25 * 60);
//     await _repository.saveSession(_defaultDuration);
//   }

//   void pauseTimer() {
//     if (state is FocusRunning) {
//       _tickerSubscription?.pause();
//       emit(FocusPaused(state.duration));
//     }
//   }

//   void resumeTimer() {
//     if (state is FocusPaused) {
//       _tickerSubscription?.resume();
//       emit(FocusRunning(state.duration));
//     }
//   }

//   void resetTimer() {
//     _tickerSubscription?.cancel();
//     emit(const FocusInitial(_defaultDuration));
//   }

//   @override
//   Future<void> close() {
//     _tickerSubscription?.cancel();
//     return super.close();
//   }
// }
