import 'dart:convert';

import 'package:athar/core/time_engine/athar_time_calculator.dart';
import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

/// Keys written to native shared storage (Android SharedPreferences /
/// iOS UserDefaults via App Group).  Keep in sync with the native widget code.
///
/// VERSIONING: widgetDataVersion tracks the payload schema.
///   v1 (original): nameAr, nameEn, nextPrayerTime, cityName
///   v2 (current):  + prayerType, prayerTimestamp, appLocale, lastUpdatedAt
///
/// BACKWARD COMPAT: all v1 keys are preserved unchanged.
abstract final class WidgetKeys {
  // ── v1 Prayer keys (backward-compatible, do NOT rename) ────────────────────
  static const nextPrayerNameAr = 'athar_next_prayer_name_ar';
  static const nextPrayerNameEn = 'athar_next_prayer_name_en';
  /// ISO-8601 string of the next prayer time (e.g. "2026-04-29T15:30:00.000")
  static const nextPrayerTime = 'athar_next_prayer_time';
  /// City name as entered/detected by the user (may be Arabic or Latin)
  static const cityName = 'athar_city_name';

  // ── v2 Prayer keys ─────────────────────────────────────────────────────────
  /// PrayerType enum name: "fajr" | "sunrise" | "dhuhr" | "asr" | "maghrib" | "isha"
  static const nextPrayerType = 'athar_next_prayer_type';
  /// Unix epoch in milliseconds (double) — convenient for native countdown math
  static const nextPrayerTimestamp = 'athar_next_prayer_timestamp';
  /// "ar" or "en" — app language at the moment the data was pushed
  static const appLocale = 'athar_app_locale';
  /// ISO-8601 of when Flutter last pushed data — lets widget show "stale" badge if old
  static const lastUpdatedAt = 'athar_last_updated_at';
  /// Integer schema version. Increment when adding required new keys.
  static const widgetDataVersion = 'athar_widget_data_version';

  // ── v3 Prayer keys ─────────────────────────────────────────────────────────
  /// Seconds remaining until the next prayer time (integer)
  static const remainingSeconds = 'athar_remaining_seconds';
  /// Full date in Arabic — day name + Hijri + Gregorian
  static const currentDateAr = 'athar_current_date_ar';
  /// Full date in English — abbreviated day + Gregorian + Hijri
  static const currentDateEn = 'athar_current_date_en';

  // ── v4 Prayer keys ─────────────────────────────────────────────────────────
  /// Unix epoch in milliseconds (double) of the previous prayer — used with
  /// nextPrayerTimestamp to compute elapsed/total progress for the widget bar.
  static const prevPrayerTimestamp = 'athar_prev_prayer_timestamp';

  // ── v5 Prayer keys ─────────────────────────────────────────────────────────
  /// 1 when Duha nafl window is active (15 min after sunrise to 15 min before Dhuhr), else 0
  static const isDuhaTime = 'athar_is_duha_time';
  /// 1 when Qiyam al-Layl window is active (last third of night), else 0
  static const isQiyamTime = 'athar_is_qiyam_time';

  // ── v6 Prayer keys ─────────────────────────────────────────────────────────
  /// Arabic name of the prayer that most recently started (used to show "صلاة جارية")
  static const prevPrayerNameAr = 'athar_prev_prayer_name_ar';
  /// English name of the prayer that most recently started
  static const prevPrayerNameEn = 'athar_prev_prayer_name_en';

  // ── Task keys ──────────────────────────────────────────────────────────────
  static const tasks = 'athar_tasks';
  static const tasksTotal = 'athar_tasks_total';
  static const tasksDone = 'athar_tasks_done';
  static const currentPeriod = 'athar_current_period';

  // ── Habit keys ─────────────────────────────────────────────────────────────
  static const habits = 'athar_habits';
  static const habitsTotal = 'athar_habits_total';
  static const habitsDone = 'athar_habits_done';

  // ── Pending action keys (widget → Flutter) ─────────────────────────────────
  static const pendingTaskActions  = 'athar_pending_task_actions';
  static const pendingHabitActions = 'athar_pending_habit_actions';
}

@lazySingleton
class WidgetDataService {
  // ── iOS App Group (must match the entitlement added in Xcode) ──────────────
  static const _iosGroupId = 'group.com.iappsnet.athar';

  // ── Android fully-qualified receiver class names ───────────────────────────
  static const _androidPrayerReceiver =
      'com.iappsnet.athar.widgets.PrayerWidgetReceiver';
  static const _androidTaskReceiver =
      'com.iappsnet.athar.widgets.TaskWidgetReceiver';
  static const _androidHabitReceiver =
      'com.iappsnet.athar.widgets.HabitWidgetReceiver';

  // ── iOS Widget Extension bundle names ─────────────────────────────────────
  static const _iosPrayerWidget = 'AtharPrayerWidget';
  static const _iosTaskWidget = 'AtharTaskWidget';
  static const _iosHabitWidget = 'AtharHabitWidget';

  /// Call once from main() before runApp().
  Future<void> init() async {
    await HomeWidget.setAppGroupId(_iosGroupId);
  }

  // ── Prayer data ────────────────────────────────────────────────────────────

  Future<void> pushPrayerData({
    required String nameAr,
    required String nameEn,
    /// PrayerType.name value — "fajr", "dhuhr", "maghrib", etc.
    required String prayerType,
    required DateTime time,
    required String city,
    /// Time of the prayer that immediately preceded [time] — used to compute
    /// elapsed/total progress in the widget progress bar.
    DateTime? prevTime,
    /// Arabic name of the previous prayer (used for "صلاة جارية" current-prayer state)
    String prevNameAr = '',
    /// English name of the previous prayer
    String prevNameEn = '',
    /// App locale at call time — "ar", "en", or "system"
    String locale = 'system',
    bool isDuhaTime = false,
    bool isQiyamTime = false,
  }) async {
    try {
      final now = DateTime.now();
      final remaining = time.isAfter(now)
          ? time.difference(now).inSeconds
          : 0;
      final dateAr = _buildDateAr(now);
      final dateEn = _buildDateEn(now);

      await Future.wait([
        // v1 keys — backward-compatible
        HomeWidget.saveWidgetData<String>(WidgetKeys.nextPrayerNameAr, nameAr),
        HomeWidget.saveWidgetData<String>(WidgetKeys.nextPrayerNameEn, nameEn),
        HomeWidget.saveWidgetData<String>(WidgetKeys.nextPrayerTime, time.toIso8601String()),
        HomeWidget.saveWidgetData<String>(WidgetKeys.cityName, city),
        // v2 keys
        HomeWidget.saveWidgetData<String>(WidgetKeys.nextPrayerType, prayerType),
        HomeWidget.saveWidgetData<double>(
            WidgetKeys.nextPrayerTimestamp, time.millisecondsSinceEpoch.toDouble()),
        HomeWidget.saveWidgetData<String>(WidgetKeys.appLocale, locale),
        HomeWidget.saveWidgetData<String>(
            WidgetKeys.lastUpdatedAt, now.toIso8601String()),
        HomeWidget.saveWidgetData<int>(WidgetKeys.widgetDataVersion, 6),
        // v3 keys
        HomeWidget.saveWidgetData<int>(WidgetKeys.remainingSeconds, remaining),
        HomeWidget.saveWidgetData<String>(WidgetKeys.currentDateAr, dateAr),
        HomeWidget.saveWidgetData<String>(WidgetKeys.currentDateEn, dateEn),
        // v4 keys
        HomeWidget.saveWidgetData<double>(
            WidgetKeys.prevPrayerTimestamp,
            prevTime != null ? prevTime.millisecondsSinceEpoch.toDouble() : 0.0),
        // v5 keys — nafl windows
        HomeWidget.saveWidgetData<int>(WidgetKeys.isDuhaTime, isDuhaTime ? 1 : 0),
        HomeWidget.saveWidgetData<int>(WidgetKeys.isQiyamTime, isQiyamTime ? 1 : 0),
        // v6 keys — previous prayer name for current-prayer state
        HomeWidget.saveWidgetData<String>(WidgetKeys.prevPrayerNameAr, prevNameAr),
        HomeWidget.saveWidgetData<String>(WidgetKeys.prevPrayerNameEn, prevNameEn),
      ]);
      if (kDebugMode) {
        print('[WidgetDataService] pushPrayerData OK'
            ' | nameAr=$nameAr | ts=${time.millisecondsSinceEpoch}'
            ' | city=$city | locale=$locale');
      }
      await _updatePrayerWidget();
    } catch (e) {
      if (kDebugMode) print('[WidgetDataService] pushPrayerData FAILED: $e');
    }
  }

  String _buildDateAr(DateTime now) {
    final dayName = DateFormat('EEEE', 'ar').format(now);
    final gregorian = DateFormat('d MMMM', 'ar').format(now);
    final hijri = HijriCalendar.fromDate(now);
    HijriCalendar.setLocal('ar');
    final hijriStr = hijri.toFormat("dd MMMM yyyy");
    return '$dayName، $hijriStr - $gregorian';
  }

  String _buildDateEn(DateTime now) {
    final dayName = DateFormat('EEE', 'en_US').format(now);
    final gregorian = DateFormat('d MMM', 'en_US').format(now);
    final hijri = HijriCalendar.fromDate(now);
    HijriCalendar.setLocal('en');
    final hijriStr = hijri.toFormat("dd MMMM yyyy");
    // Do not reset to 'ar' here — _buildDateAr() sets its own locale before use.
    return '$dayName, $gregorian · $hijriStr';
  }

  // ── Task data ──────────────────────────────────────────────────────────────

  Future<void> pushTaskData(List<TaskModel> allTasks) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final period = AtharTimeCalculator.approximatePeriod(now);
      final locale = await _readLocale();

      // Today's active tasks
      final todayTasks = allTasks
          .where((t) =>
              _sameDay(t.date, today) &&
              t.deletedAt == null &&
              !t.isSampleData)
          .toList();

      // Priority: tasks assigned to current period. Fallback: all unfinished.
      var widgetCandidates = todayTasks
          .where((t) => t.timePeriod == period && !t.isCompleted)
          .toList();

      if (widgetCandidates.isEmpty) {
        widgetCandidates = todayTasks
            .where((t) => !t.isCompleted)
            .toList()
          ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
      }

      final topFive = widgetCandidates.take(5).toList();
      final tasksJson = jsonEncode(topFive
          .map((t) => {
                't': t.title,
                'd': t.isCompleted,
                'p': t.priority.index,
                'u': t.uuid,
              })
          .toList());

      await Future.wait([
        HomeWidget.saveWidgetData<String>(WidgetKeys.tasks, tasksJson),
        HomeWidget.saveWidgetData<int>(
            WidgetKeys.tasksTotal, todayTasks.length),
        HomeWidget.saveWidgetData<int>(
            WidgetKeys.tasksDone,
            todayTasks.where((t) => t.isCompleted).length),
        HomeWidget.saveWidgetData<int>(
            WidgetKeys.currentPeriod, period.index),
        HomeWidget.saveWidgetData<String>(WidgetKeys.appLocale, locale),
      ]);
      if (kDebugMode) {
        print('[WidgetDataService] pushTaskData OK'
            ' | items=${topFive.length}/${todayTasks.length}'
            ' | done=${todayTasks.where((t) => t.isCompleted).length}'
            ' | json=${tasksJson.substring(0, tasksJson.length.clamp(0, 120))}');
      }
      await _updateTaskWidget();
    } catch (e) {
      if (kDebugMode) print('[WidgetDataService] pushTaskData FAILED: $e');
    }
  }

  // ── Habit data ─────────────────────────────────────────────────────────────

  Future<void> pushHabitData(List<HabitModel> allHabits) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final locale = await _readLocale();

      bool activeToday(HabitModel h) =>
          h.deletedAt == null &&
          (h.startDate == null || !h.startDate!.isAfter(today)) &&
          (h.endDate == null || !h.endDate!.isBefore(today));

      final todayRegular =
          allHabits.where((h) => h.type == HabitType.regular && activeToday(h)).toList();
      final todayAthkar =
          allHabits.where((h) => h.type == HabitType.athkar && activeToday(h)).toList();

      final done = todayRegular.where((h) => h.isCompleted).length;

      // Regular: uncompleted first, then by streak descending
      final sortedRegular = [...todayRegular]
        ..sort((a, b) {
          if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
          return b.currentStreak.compareTo(a.currentStreak);
        });

      // Athkar: uncompleted first, no streak sorting needed
      final sortedAthkar = [...todayAthkar]
        ..sort((a, b) => a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1));

      // Regular fills first slots; Athkar appended; cap at 5; skip null uuid
      final top = [...sortedRegular, ...sortedAthkar]
          .take(5)
          .where((h) => h.uuid != null)
          .toList();

      final habitsJson = jsonEncode(top
          .map((h) => {
                't': h.title,
                'd': h.isCompleted,
                's': h.currentStreak,
                'u': h.uuid,
                'cp': h.currentProgress,
                'tg': h.target,
                'tp': h.type == HabitType.athkar ? 'a' : 'r',
              })
          .toList());

      await Future.wait([
        HomeWidget.saveWidgetData<String>(WidgetKeys.habits, habitsJson),
        HomeWidget.saveWidgetData<int>(WidgetKeys.habitsTotal, todayRegular.length),
        HomeWidget.saveWidgetData<int>(WidgetKeys.habitsDone, done),
        HomeWidget.saveWidgetData<String>(WidgetKeys.appLocale, locale),
      ]);
      if (kDebugMode) {
        print('[WidgetDataService] pushHabitData OK'
            ' | items=${top.length}/${todayRegular.length + todayAthkar.length}'
            ' | done=$done'
            ' | json=${habitsJson.substring(0, habitsJson.length.clamp(0, 120))}');
      }
      await _updateHabitWidget();
    } catch (e) {
      if (kDebugMode) print('[WidgetDataService] pushHabitData FAILED: $e');
    }
  }

  // ── Locale-only push ──────────────────────────────────────────────────────

  /// Updates only the locale key in UserDefaults and triggers all three widgets
  /// to re-render with the new language. Called by LocaleCubit.setLocale().
  Future<void> pushLocaleOnly(String localeCode) async {
    try {
      await HomeWidget.saveWidgetData<String>(WidgetKeys.appLocale, localeCode);
      await Future.wait([
        _updatePrayerWidget(),
        _updateTaskWidget(),
        _updateHabitWidget(),
      ]);
    } catch (e) {
      if (kDebugMode) print('WidgetDataService: pushLocaleOnly failed: $e');
    }
  }

  // ── Widget update triggers ─────────────────────────────────────────────────

  Future<void> _updatePrayerWidget() => HomeWidget.updateWidget(
        iOSName: _iosPrayerWidget,
        qualifiedAndroidName: _androidPrayerReceiver,
      );

  Future<void> _updateTaskWidget() => HomeWidget.updateWidget(
        iOSName: _iosTaskWidget,
        qualifiedAndroidName: _androidTaskReceiver,
      );

  Future<void> _updateHabitWidget() => HomeWidget.updateWidget(
        iOSName: _iosHabitWidget,
        qualifiedAndroidName: _androidHabitReceiver,
      );

  // ── Pending task actions (widget → Flutter) ───────────────────────────────

  /// Reads and clears the pending-task-actions queue written by ToggleTaskIntent.
  /// Returns decoded actions; caller is responsible for dispatching them.
  Future<List<Map<String, dynamic>>> consumePendingTaskActions() async {
    try {
      final json = await HomeWidget.getWidgetData<String>(
          WidgetKeys.pendingTaskActions);
      if (json == null || json.isEmpty || json == '[]') return [];
      final decoded = jsonDecode(json);
      if (decoded is! List) return [];
      await HomeWidget.saveWidgetData<String>(
          WidgetKeys.pendingTaskActions, '[]');
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // ── Pending habit actions (widget → Flutter) ──────────────────────────────

  /// Reads and clears the pending-habit-actions queue written by CompleteHabitIntent
  /// and IncrementHabitIntent. Caller dispatches each action to HabitCubit.
  Future<List<Map<String, dynamic>>> consumePendingHabitActions() async {
    try {
      final json = await HomeWidget.getWidgetData<String>(
          WidgetKeys.pendingHabitActions);
      if (json == null || json.isEmpty || json == '[]') return [];
      final decoded = jsonDecode(json);
      if (decoded is! List) return [];
      await HomeWidget.saveWidgetData<String>(
          WidgetKeys.pendingHabitActions, '[]');
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // Reads the user's preferred locale from secure storage.
  // Mirrors the same read that PrayerCubit performs.
  // Returns 'ar', 'en', or 'system' (when key is absent = system default).
  Future<String> _readLocale() async {
    try {
      const storage = FlutterSecureStorage();
      return await storage.read(key: 'preferred_locale') ?? 'system';
    } catch (_) {
      return 'system';
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
