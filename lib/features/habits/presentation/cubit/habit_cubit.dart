import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/habit_notification_scheduler.dart';
import 'package:athar/features/health/presentation/cubit/health_state.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/habit_model.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../../prayer/domain/repositories/prayer_repository.dart';
import '../../../settings/data/models/user_settings.dart';
import '../../domain/utils/athkar_visibility_helper.dart';
// ✅ استيراد مصدر البيانات المركزي (للثوابت)
import '../../../../core/constants/athkar_data.dart';
import '../../../prayer/domain/entities/prayer_time.dart'; // ✅ إضافة
import '../../../prayer/domain/utils/prayer_list_helper.dart'; // ✅ إضافة

import 'habit_state.dart';

@injectable
class HabitCubit extends Cubit<HabitState> {
  final HabitRepository _habitRepository;
  final PrayerRepository _prayerRepository;
  final SettingsRepository _settingsRepository;

  StreamSubscription? _habitsSubscription;
  StreamSubscription? _settingsSubscription;
  Timer? _refreshTimer;

  List<HabitModel> _cachedHabits = [];

  HabitCubit(
    this._habitRepository,
    this._prayerRepository,
    this._settingsRepository,
  ) : super(HabitInitial());

  Future<void> loadHabits() async {
    emit(HabitLoading());

    try {
      await _habitRepository.ensureSystemHabits();
    } catch (e) {
      debugPrint("Error ensuring system habits: $e");
    }

    await _habitsSubscription?.cancel();
    await _settingsSubscription?.cancel();
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _refreshVisibleHabits();
    });

    _habitsSubscription = _habitRepository.watchHabits().listen((
      allHabits,
    ) async {
      _cachedHabits = allHabits;
      await _refreshVisibleHabits();
    });

    _settingsSubscription = _settingsRepository.watchSettings().listen((
      _,
    ) async {
      await _refreshVisibleHabits();
    });
  }

  Future<void> resetHabitAthkar(HabitModel habit) async {
    try {
      await _habitRepository.resetAthkarToDefault(habit.id);
      await loadHabits();
    } catch (e) {
      emit(HabitError("فشل تحديث الأذكار: $e"));
    }
  }

  // ignore: unintended_html_in_doc_comment
  /// ✅ الحل الصحيح: استخدام List<PrayerTime> مباشرة
  Future<void> _refreshVisibleHabits() async {
    try {
      final now = DateTime.now();
      final settings = await _settingsRepository.getSettings();

      // ✅ استخدام getPrayerTimesForDate
      final prayerTimesList = await _prayerRepository.getPrayerTimesForDate(
        now,
      );

      await _checkAndResetHabits(_cachedHabits, now, prayerTimesList);
      _emitCategorizedHabits(_cachedHabits, prayerTimesList, settings, now);
    } catch (e) {
      debugPrint("Error refreshing habits: $e");
    }
  }

  // ✅✅ هذه الدالة هي مكان التعديل الجوهري
  void _emitCategorizedHabits(
    List<HabitModel> habits,
    List<PrayerTime> prayerTimesList, // ✅ تغيير النوع
    UserSettings settings,
    DateTime now,
  ) {
    final bool isAthkarEnabled = settings.isAthkarEnabled;
    final athkarMode = settings.athkarDisplayMode;

    // ✅ إنشاء helper للوصول السهل
    final prayerTimes = PrayerListHelper(prayerTimesList);

    List<HabitModel> cardList = [];
    List<HabitModel> dawnList = [];
    List<HabitModel> bakurList = [];
    List<HabitModel> morningList = [];
    List<HabitModel> noonList = [];
    List<HabitModel> afternoonList = [];
    List<HabitModel> maghribList = [];
    List<HabitModel> ishaList = [];
    List<HabitModel> nightList = [];
    List<HabitModel> lastThirdList = [];
    List<HabitModel> anyTimeList = [];

    habits.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });

    for (var habit in habits) {
      // 1. استثناءات عامة
      if (habit.period == HabitPeriod.postPrayer) continue;
      if (habit.endDate != null && now.isAfter(habit.endDate!)) continue;

      // 🛑 [جديد] 2. إخفاء أذكار الصلاة دائماً من القائمة الرئيسية
      // لأن مكانها هو بطاقة الصلاة القادمة فقط
      if (habit.uuid == AthkarData.prayerAthkarId) {
        continue;
      }

      // 🌙 [جديد] 3. المنطق الذكي لأذكار النوم (باستخدام أوقات الصلاة الحقيقية)
      if (habit.uuid == AthkarData.sleepAthkarId) {
        // وقت البداية: بعد العشاء بـ 40 دقيقة
        final sleepStartTime = prayerTimes.isha.add(
          const Duration(minutes: 40),
        );

        // وقت النهاية: قبل الفجر بـ 30 دقيقة
        final sleepEndTime = prayerTimes.fajr.subtract(
          const Duration(minutes: 30),
        );

        // التحقق: هل الوقت الحالي يقع في الليل؟
        // بما أن "الليل" يلتف حول منتصف الليل، فالشرط هو:
        // إما أننا بعد العشاء (في نفس اليوم) OR قبل الفجر (في الصباح الباكر لليوم)
        final isAfterIsha = now.isAfter(sleepStartTime);
        final isBeforeFajr = now.isBefore(sleepEndTime);

        // إذا لم يتحقق أي من الشرطين (أي نحن في النهار)، نخفي العادة
        if (!isAfterIsha && !isBeforeFajr) {
          continue;
        }
        // إذا تحقق الشرط، سيسمح للعادة بالمرور ليتم تصنيفها في القوائم بالأسفل
      }

      bool isAthkarTimeValid = true;

      // منطق الأوقات للأذكار الأخرى (الصباح والمساء)
      if (habit.type == HabitType.athkar) {
        if (!isAthkarEnabled) continue;

        if (habit.period == HabitPeriod.morning ||
            habit.period == HabitPeriod.dawn ||
            habit.period == HabitPeriod.bakur) {
          isAthkarTimeValid = AthkarVisibilityHelper.isMorningAthkarTime(
            prayerTimes.fajr,
            prayerTimes.asr,
          );
        } else if (habit.period == HabitPeriod.afternoon ||
            habit.period == HabitPeriod.maghrib ||
            habit.period == HabitPeriod.isha) {
          isAthkarTimeValid = AthkarVisibilityHelper.isEveningAthkarTime(
            prayerTimes.asr,
          );
        }
      }

      if (habit.type == HabitType.athkar && !isAthkarTimeValid) continue;

      // 4. منطق الأذكار المستقلة
      if (habit.type == HabitType.athkar &&
          athkarMode == AthkarDisplayMode.independent) {
        cardList.add(habit);
        continue;
      }

      // 5. التوزيع الزمني
      switch (habit.period) {
        case HabitPeriod.dawn:
          dawnList.add(habit);
          break;
        case HabitPeriod.bakur:
          bakurList.add(habit);
          break;
        case HabitPeriod.morning:
          morningList.add(habit);
          break;
        case HabitPeriod.noon:
          noonList.add(habit);
          break;
        case HabitPeriod.afternoon:
          afternoonList.add(habit);
          break;
        case HabitPeriod.maghrib:
          maghribList.add(habit);
          break;
        case HabitPeriod.isha:
          ishaList.add(habit);
          break;
        case HabitPeriod.night:
          nightList.add(habit);
          break;
        case HabitPeriod.lastThird:
          lastThirdList.add(habit);
          break;
        default:
          anyTimeList.add(habit);
      }
    }

    emit(
      HabitLoaded(
        habits,
        cardAthkar: cardList,
        dawnHabits: dawnList,
        bakurHabits: bakurList,
        morningHabits: morningList,
        noonHabits: noonList,
        afternoonHabits: afternoonList,
        maghribHabits: maghribList,
        ishaHabits: ishaList,
        nightHabits: nightList,
        lastThirdHabits: lastThirdList,
        anyTimeHabits: anyTimeList,
      ),
    );
  }

  Future<void> _checkAndResetHabits(
    List<HabitModel> habits,
    DateTime now,
    List<PrayerTime> prayerTimesList, // ✅ تغيير النوع
  ) async {
    // ✅ إنشاء helper
    final prayerTimes = PrayerListHelper(prayerTimesList);
    for (var habit in habits) {
      bool shouldReset = false;

      if (habit.period == HabitPeriod.postPrayer) {
        final currentPrayer = prayerTimes.currentPrayer();
        final currentPrayerTime = currentPrayer?.time;
        if (habit.lastUpdated != null &&
            currentPrayerTime != null &&
            habit.lastUpdated!.isBefore(currentPrayerTime)) {
          shouldReset = true;
        }
      } else if (_shouldResetRegularHabit(habit, now)) {
        shouldReset = true;
      }

      if (shouldReset) {
        habit.isCompleted = false;
        habit.currentProgress = 0;
        habit.lastUpdated = now;

        if (habit.frequency == HabitFrequency.weekly) {
          habit.nextResetDate = now.add(const Duration(days: 7));
        } else if (habit.frequency == HabitFrequency.monthly) {
          habit.nextResetDate = now.add(const Duration(days: 30));
        }

        if (habit.type == HabitType.athkar) {
          for (var item in habit.athkarItems) {
            item.currentCount = 0;
            item.isDone = false;
          }
        }
        await _habitRepository.updateHabit(habit);
      }
    }
  }

  bool _shouldResetRegularHabit(HabitModel habit, DateTime now) {
    if (habit.lastUpdated == null) return false;
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return !_isSameDay(habit.lastUpdated!, now);
      case HabitFrequency.weekly:
      case HabitFrequency.monthly:
        if (habit.nextResetDate != null && now.isAfter(habit.nextResetDate!)) {
          return true;
        }
        return false;
    }
  }

  // ✅ استخدام البيانات المركزية
  Future<HabitModel> getOrCreatePostPrayerHabit() async {
    try {
      final existing = _cachedHabits.firstWhere(
        (h) => h.period == HabitPeriod.postPrayer,
      );
      return existing;
    } catch (_) {
      final athkarItems = _getPrayerAthkarItems();
      final newHabit = HabitModel(title: "أذكار ما بعد الصلاة")
        ..type = HabitType.athkar
        ..period = HabitPeriod.postPrayer
        ..frequency = HabitFrequency.daily
        ..createdAt = DateTime.now()
        ..athkarItems = athkarItems;

      await _habitRepository.addHabit(newHabit);
      return newHabit;
    }
  }

  List<AthkarItem> _getPrayerAthkarItems() {
    final sourceList = AthkarData.allAthkar
        .where((d) => d.timings.contains(DhikrTiming.prayer))
        .toList();

    return sourceList.map((source) {
      return AthkarItem()
        ..text = source.text
        ..targetCount = source.count
        ..currentCount = 0
        ..isDone = false;
    }).toList();
  }

  Future<void> incrementAthkarProgress(HabitModel habit, int itemIndex) async {
    if (itemIndex < 0 || itemIndex >= habit.athkarItems.length) return;
    final item = habit.athkarItems[itemIndex];
    if (item.isDone) return;
    item.currentCount++;
    if (item.currentCount >= item.targetCount) {
      item.currentCount = item.targetCount;
      item.isDone = true;
    }
    int totalItems = habit.athkarItems.length;
    int completedItems = habit.athkarItems.where((i) => i.isDone).length;
    habit.currentProgress = completedItems;
    habit.target = totalItems;
    if (completedItems == totalItems) {
      habit.isCompleted = true;
      habit.lastCompletionDate = DateTime.now();
    }
    habit.lastUpdated = DateTime.now();
    await _habitRepository.updateHabit(habit);
  }

  // داخل HabitCubit
  Future<void> addHabit(HabitModel habit) async {
    try {
      await _habitRepository.addHabit(habit);
      // ✅ جدولة التذكير فوراً
      if (habit.reminderEnabled && habit.reminderTime != null) {
        await getIt<HabitNotificationScheduler>().scheduleHabit(habit);
      }
      await loadHabits(); // تحديث القائمة
    } catch (e) {
      emit(HealthError("فشل إضافة العادة") as HabitState);
    }
  }

  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _habitRepository.updateHabit(habit);
      // ✅ إلغاء القديم وجدولة الجديد لضمان الدقة
      await getIt<HabitNotificationScheduler>().cancelHabit(habit.uuid!);
      if (habit.reminderEnabled && habit.reminderTime != null) {
        await getIt<HabitNotificationScheduler>().scheduleHabit(habit);
      }
      await loadHabits();
    } catch (e) {
      emit(HealthError("فشل تحديث العادة") as HabitState);
    }
  }

  Future<void> deleteHabit(int id) async {
    await _habitRepository.deleteHabit(id);
  }

  Map<DateTime, int> getHeatmapData(List<HabitModel> habits) {
    final Map<DateTime, int> data = {};
    for (var habit in habits) {
      for (var date in habit.completedDays) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        if (data.containsKey(normalizedDate)) {
          data[normalizedDate] = data[normalizedDate]! + 1;
        } else {
          data[normalizedDate] = 1;
        }
      }
    }
    return data;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isHabitCompletedOnDate(HabitModel habit, DateTime date) {
    return habit.completedDays.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  Future<void> toggleHabitOnDate(int habitId, DateTime date) async {
    try {
      final habitIndex = _cachedHabits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) return;

      final habit = _cachedHabits[habitIndex];
      bool wasCompleted = isHabitCompletedOnDate(habit, date);

      if (wasCompleted) {
        habit.completedDays.removeWhere(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        );
        if (habit.currentStreak > 0) habit.currentStreak--;
        if (_isSameDay(date, DateTime.now())) {
          habit.isCompleted = false;
          habit.currentProgress = 0;
          if (habit.type == HabitType.athkar) {
            for (var item in habit.athkarItems) {
              item.isDone = false;
            }
          }
        }
      } else {
        habit.completedDays.add(date);
        habit.currentStreak++;
        if (_isSameDay(date, DateTime.now())) {
          habit.isCompleted = true;
          habit.currentProgress = habit.target;
          habit.lastCompletionDate = DateTime.now();
        }
      }

      habit.lastUpdated = DateTime.now();
      await _habitRepository.updateHabit(habit);

      _cachedHabits[habitIndex] = habit;
      final settings = await _settingsRepository.getSettings();
      final prayerTimesList = await _prayerRepository.getPrayerTimesForDate(
        DateTime.now(),
      );

      _emitCategorizedHabits(
        _cachedHabits,
        prayerTimesList, // ✅ تمرير List<PrayerTime> مباشرة
        settings,
        DateTime.now(),
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // Future<void> toggleHabit(int id) async ... (يمكنك إضافتها إذا كانت تستخدم للتبديل السريع)

  @override
  Future<void> close() {
    _habitsSubscription?.cancel();
    _settingsSubscription?.cancel();
    _refreshTimer?.cancel();
    return super.close();
  }
}
