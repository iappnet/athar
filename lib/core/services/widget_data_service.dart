import 'dart:convert';

import 'package:athar/core/time_engine/athar_time_calculator.dart';
import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';

/// Keys written to native shared storage (Android SharedPreferences /
/// iOS UserDefaults via App Group).  Keep in sync with the native widget code.
abstract final class WidgetKeys {
  static const nextPrayerNameAr = 'athar_next_prayer_name_ar';
  static const nextPrayerNameEn = 'athar_next_prayer_name_en';
  static const nextPrayerTime = 'athar_next_prayer_time';
  static const cityName = 'athar_city_name';

  static const tasks = 'athar_tasks';
  static const tasksTotal = 'athar_tasks_total';
  static const tasksDone = 'athar_tasks_done';
  static const currentPeriod = 'athar_current_period';

  static const habits = 'athar_habits';
  static const habitsTotal = 'athar_habits_total';
  static const habitsDone = 'athar_habits_done';
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
    required DateTime time,
    required String city,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>(WidgetKeys.nextPrayerNameAr, nameAr),
        HomeWidget.saveWidgetData<String>(WidgetKeys.nextPrayerNameEn, nameEn),
        HomeWidget.saveWidgetData<String>(
            WidgetKeys.nextPrayerTime, time.toIso8601String()),
        HomeWidget.saveWidgetData<String>(WidgetKeys.cityName, city),
      ]);
      await _updatePrayerWidget();
    } catch (e) {
      if (kDebugMode) print('WidgetDataService: pushPrayerData failed: $e');
    }
  }

  // ── Task data ──────────────────────────────────────────────────────────────

  Future<void> pushTaskData(List<TaskModel> allTasks) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final period = AtharTimeCalculator.approximatePeriod(now);

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
          .map((t) => {'t': t.title, 'd': t.isCompleted, 'p': t.priority.index})
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
      ]);
      await _updateTaskWidget();
    } catch (e) {
      if (kDebugMode) print('WidgetDataService: pushTaskData failed: $e');
    }
  }

  // ── Habit data ─────────────────────────────────────────────────────────────

  Future<void> pushHabitData(List<HabitModel> allHabits) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todayHabits = allHabits
          .where((h) =>
              h.deletedAt == null &&
              h.type == HabitType.regular &&
              (h.startDate == null || !h.startDate!.isAfter(today)) &&
              (h.endDate == null || !h.endDate!.isBefore(today)))
          .toList();

      final done = todayHabits.where((h) => h.isCompleted).length;

      // Top 5 by streak, uncompleted first
      final sorted = [...todayHabits]
        ..sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return b.currentStreak.compareTo(a.currentStreak);
        });

      final top = sorted.take(5).toList();
      final habitsJson = jsonEncode(top
          .map((h) => {
                't': h.title,
                'd': h.isCompleted,
                's': h.currentStreak,
              })
          .toList());

      await Future.wait([
        HomeWidget.saveWidgetData<String>(WidgetKeys.habits, habitsJson),
        HomeWidget.saveWidgetData<int>(WidgetKeys.habitsTotal, todayHabits.length),
        HomeWidget.saveWidgetData<int>(WidgetKeys.habitsDone, done),
      ]);
      await _updateHabitWidget();
    } catch (e) {
      if (kDebugMode) print('WidgetDataService: pushHabitData failed: $e');
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

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
