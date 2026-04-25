// lib/features/settings/presentation/cubit/settings_cubit.dart
// ✅ النسخة المحدثة مع دوال إدارة التنبيهات عند تغيير الإعدادات
// ✅✅ + دالة toggleHideNavOnScroll الجديدة

import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/habit_notification_scheduler.dart';
import 'package:athar/core/services/prayer_notification_scheduler.dart';
import 'package:athar/features/settings/data/models/time_range.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/biometric_service.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;
  final BiometricService _biometricService;

  StreamSubscription? _settingsSubscription;

  SettingsCubit(this._repository, this._biometricService)
    : super(SettingsInitial());

  // ═══════════════════════════════════════════════════════════════════
  // 🎬 التحميل والمراقبة
  // ═══════════════════════════════════════════════════════════════════

  Future<void> loadSettings() async {
    if (state is! SettingsLoaded) emit(SettingsLoading());

    await _settingsSubscription?.cancel();

    _settingsSubscription = _repository.watchSettings().listen((settings) {
      emit(SettingsLoaded(settings));
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // ✅✅✅ دوال إدارة التنبيهات - الإصلاح الرئيسي
  // ═══════════════════════════════════════════════════════════════════

  /// ✅ تفعيل/تعطيل مواقيت الصلاة مع إدارة التنبيهات
  Future<void> togglePrayerEnabled(bool enabled) async {
    try {
      final currentSettings = await _repository.getSettings();
      currentSettings.isPrayerEnabled = enabled;

      final prayerScheduler = getIt<PrayerNotificationScheduler>();

      if (!enabled) {
        // ❌ إلغاء جميع تنبيهات الصلاة
        await prayerScheduler.disableNotifications();
        if (kDebugMode) {
          print('🔕 Prayer notifications cancelled');
        }
      } else {
        // ✅ إعادة جدولة التنبيهات
        await prayerScheduler.initializeScheduling();
        if (kDebugMode) {
          print('🔔 Prayer notifications scheduled');
        }
      }

      await _repository.updateSettings(currentSettings);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling prayer: $e');
      }
    }
  }

  /// ✅ تفعيل/تعطيل تذكيرات الصلاة (قبل 15 دقيقة)
  Future<void> togglePrayerReminders(bool enabled) async {
    try {
      final currentSettings = await _repository.getSettings();
      currentSettings.enablePrayerReminders = enabled;

      // إعادة جدولة لتطبيق التغيير
      if (currentSettings.isPrayerEnabled) {
        final prayerScheduler = getIt<PrayerNotificationScheduler>();
        await prayerScheduler.scheduleSevenDays();
      }

      await _repository.updateSettings(currentSettings);

      if (kDebugMode) {
        print(
          enabled
              ? '🔔 Prayer reminders enabled'
              : '🔕 Prayer reminders disabled',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling prayer reminders: $e');
      }
    }
  }

  /// ✅ تفعيل/تعطيل الأذكار مع إدارة التنبيهات
  Future<void> toggleAthkarEnabled(bool enabled) async {
    try {
      final currentSettings = await _repository.getSettings();
      currentSettings.isAthkarEnabled = enabled;

      final habitScheduler = getIt<HabitNotificationScheduler>();

      if (!enabled) {
        // ❌ إلغاء جميع تنبيهات الأذكار
        await habitScheduler.cancelAllAthkar();
        if (kDebugMode) {
          print('🔕 Athkar notifications cancelled');
        }
      } else {
        // ✅ إعادة جدولة التنبيهات
        await habitScheduler.scheduleAllAthkar();
        if (kDebugMode) {
          print('🔔 Athkar notifications scheduled');
        }
      }

      await _repository.updateSettings(currentSettings);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling athkar: $e');
      }
    }
  }

  /// ✅ تفعيل/تعطيل تنبيهات العادات
  Future<void> toggleHabitsRemindersEnabled(bool enabled) async {
    try {
      final currentSettings = await _repository.getSettings();
      currentSettings.isHabitRemindersEnabled = enabled;

      final habitScheduler = getIt<HabitNotificationScheduler>();

      if (!enabled) {
        // ❌ إلغاء جميع تنبيهات العادات
        await habitScheduler.cancelAllHabits();
        if (kDebugMode) {
          print('🔕 Habit notifications cancelled');
        }
      } else {
        // ✅ إعادة جدولة التنبيهات
        await habitScheduler.scheduleAllHabits();
        if (kDebugMode) {
          print('🔔 Habit notifications scheduled');
        }
      }

      await _repository.updateSettings(currentSettings);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling habits: $e');
      }
    }
  }

  /// ✅ تفعيل/تعطيل تنبيهات المهام
  Future<void> toggleTaskRemindersEnabled(bool enabled) async {
    try {
      final currentSettings = await _repository.getSettings();
      currentSettings.isTaskRemindersEnabled = enabled;

      // المهام تُجدول فردياً عند إنشائها
      // لكن يمكن إلغاء جميعها هنا
      if (!enabled) {
        // يمكن استدعاء TaskNotificationScheduler.cancelAll() هنا
        if (kDebugMode) {
          print('🔕 Task reminders disabled (new tasks won\'t have reminders)');
        }
      }

      await _repository.updateSettings(currentSettings);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling task reminders: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🔐 البصمة
  // ═══════════════════════════════════════════════════════════════════

  Future<bool> toggleBiometric(bool enable) async {
    if (enable) {
      final success = await _biometricService.authenticate();
      if (success) {
        final currentSettings = await _repository.getSettings();
        currentSettings.isBiometricEnabled = true;
        await _repository.updateSettings(currentSettings);
        return true;
      } else {
        return false;
      }
    } else {
      final currentSettings = await _repository.getSettings();
      currentSettings.isBiometricEnabled = false;
      await _repository.updateSettings(currentSettings);
      return true;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // 📿 الأذكار
  // ═══════════════════════════════════════════════════════════════════

  Future<void> toggleAthkarFeature(bool isEnabled) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      currentSettings.isAthkarEnabled = isEnabled;
      await updateSettings(currentSettings);
    }
  }

  Future<void> updateAthkarDisplayMode(AthkarDisplayMode mode) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      currentSettings.athkarDisplayMode = mode;
      await updateSettings(currentSettings);
    }
  }

  Future<void> updateAthkarSessionViewMode(AthkarSessionViewMode mode) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      currentSettings.athkarSessionViewMode = mode;
      await updateSettings(currentSettings);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ⏰ الفترات الزمنية
  // ═══════════════════════════════════════════════════════════════════

  Future<void> updateFamilyPeriods(List<TimeRange> newPeriods) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.familyPeriods = newPeriods;
    await _repository.updateSettings(currentSettings);
  }

  Future<void> updateFreePeriods(List<TimeRange> newPeriods) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.freePeriods = newPeriods;
    await _repository.updateSettings(currentSettings);
  }

  Future<void> updateWorkPeriods(List<TimeRange> newPeriods) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.workPeriods = newPeriods;
    await _repository.updateSettings(currentSettings);
  }

  Future<void> updateQuietPeriods(List<TimeRange> newPeriods) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.quietPeriods = newPeriods;
    await _repository.updateSettings(currentSettings);
  }

  Future<void> updateSleepPeriods(List<TimeRange> newPeriods) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.sleepPeriods = newPeriods;
    await _repository.updateSettings(currentSettings);
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🏷️ التصنيفات
  // ═══════════════════════════════════════════════════════════════════

  Future<void> mapZoneToCategory({
    required String zoneType,
    required int categoryId,
  }) async {
    final currentSettings = await _repository.getSettings();

    switch (zoneType) {
      case 'work':
        currentSettings.workCategoryId = categoryId;
        break;
      case 'family':
        currentSettings.familyCategoryId = categoryId;
        break;
      case 'free':
        currentSettings.freeCategoryId = categoryId;
        break;
      case 'quiet':
        currentSettings.quietCategoryId = categoryId;
        break;
    }

    await _repository.updateSettings(currentSettings);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ⚙️ إعدادات عامة
  // ═══════════════════════════════════════════════════════════════════

  Future<void> updateSettings(UserSettings settings) async {
    try {
      await _repository.updateSettings(settings);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating settings: $e');
      }
    }
  }

  Future<void> updateWorkDays(List<int> days) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.workDays = List.from(days);
    await _repository.updateSettings(currentSettings);
  }

  Future<void> toggleHijriMode(bool value) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.isHijriMode = value;
    await _repository.updateSettings(currentSettings);
  }

  Future<void> toggleAutoSync(bool isEnabled) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.isAutoSyncEnabled = isEnabled;
    await _repository.updateSettings(currentSettings);
  }

  Future<void> toggleAutoMode(bool value) async {
    await _repository.toggleAutoMode(value);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ✅✅✅ 🎨 إخفاء شريط التنقل عند التمرير - الدالة الجديدة ✅✅✅
  // ═══════════════════════════════════════════════════════════════════

  /// تفعيل/تعطيل إخفاء شريط التنقل عند التمرير
  Future<void> toggleHideNavOnScroll(bool value) async {
    try {
      final currentSettings = await _repository.getSettings();
      currentSettings.hideNavOnScroll = value;
      await _repository.updateSettings(currentSettings);

      if (kDebugMode) {
        print(
          value
              ? '🔽 Hide nav on scroll enabled'
              : '🔼 Hide nav on scroll disabled',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling hide nav on scroll: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🧹 التنظيف
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }
}

