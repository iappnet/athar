# Athar — Data Flow Index

## Task: Add Task

```
User taps central NavBar + → FabContext.tasks
  → ContextAwareFabController.execute()
    → onAddTask?.call() [MainPage._openAddTaskSheet]
      → showModalBottomSheet + BlocProvider.value(value: parentContext.read<TaskCubit>())
        → unified_add_sheet.dart _handleSave()
          → taskCubit.addTask(TaskModel)  [MainPage's TaskCubit]
            → TaskRepositoryImpl.addTask()
              → Isar.writeTxn() → put(task)
              → _taskSubject stream fires
                → TimelineCubit (Isar watchTasksByDate) emits new list
                  → UnifiedTasksView rebuilds
              → TaskRemoteSource.insertTask() [background sync via SyncService]
```

**Key**: `UnifiedTasksView` is driven by `TimelineCubit`, not `TaskCubit`. The Isar write is what triggers display update.

---

## Task: Widget Toggle (iOS)

```
User taps checkbox in AtharTaskWidget
  → ToggleTaskIntent.perform()
    → writePendingAction() → athar_pending_task_actions in UserDefaults
    → optimisticallyToggle() → mutates athar_tasks JSON in UserDefaults
    → WidgetCenter.shared.reloadTimelines(ofKind: "AtharTaskWidget")

App resumes (AppLifecycleState.resumed)
  → app.dart onResume
    → ctx.read<TaskCubit>().processWidgetPendingActions()  [MainPage's TaskCubit]
      → WidgetDataService.consumePendingTaskActions()
        → reads + clears athar_pending_task_actions
      → toggleTaskCompletionByUuid(uuid, isDone)
        → _cachedTasks.indexWhere((t) => t.uuid == uuid)
          → [cache hit] _repository.toggleTaskCompletion(task.id, isDone)
          → [cache miss] BUG: skips silently — fix is repo fallback
```

---

## Habit: Add Habit

```
User taps central NavBar + → FabContext.habits
  → _openAddHabitSheet(parentContext)
    → HabitFormSheet.show(parentContext)
      → showModalBottomSheet + BlocProvider.value(value: context.read<HabitCubit>())
        → _saveHabit() in habit_form_dialog.dart
          → cubit.addHabit(newHabit)  [MainPage's HabitCubit]
            → HabitRepositoryImpl.addHabit()
              → Isar.writeTxn() → put(habit)
            → HabitCubit.loadHabits()  [called at end of addHabit()]
              → emits HabitLoaded([...habits...])
                → HabitPage rebuilds
```

---

## Habit: Widget Action (iOS)

```
User taps complete/increment in AtharHabitWidget
  → CompleteHabitIntent / IncrementHabitIntent .perform()
    → writePendingAction() → athar_pending_habit_actions in UserDefaults
    → optimisticallyUpdate() → mutates athar_habits JSON in UserDefaults
    → WidgetCenter.shared.reloadTimelines(ofKind: "AtharHabitWidget")

App resumes
  → ctx.read<HabitCubit>().processWidgetPendingActions()  [MainPage's HabitCubit]
    → WidgetDataService.consumePendingHabitActions()
    → For 'complete_habit': completeHabitByUuid(uuid)
        → cache lookup → toggleHabitOnDate(uuid, today)
    → For 'increment_habit': incrementHabitProgressByUuid(uuid)
        → cache lookup → updateHabit(modified habit)
```

---

## Prayer: Data Push to Widget

```
PrayerCubit.loadPrayerTimes()
  → computes nextPrayer, prevPrayer, nafl windows
  → WidgetDataService.pushPrayerData(nameAr, nameEn, prayerType, time, city,
                                      prevTime, prevNameAr, prevNameEn,
                                      locale, isDuhaTime, isQiyamTime)
    → HomeWidget.saveWidgetData() × 16 keys (v1–v6 schema)
    → HomeWidget.updateWidget(iOSName: 'AtharPrayerWidget')
      → iOS timeline provider gets invalidated
      → AtharPrayerWidget reads all keys from UserDefaults (App Group)
```

---

## Widget Data Push (Task/Habit)

```
HabitCubit.loadHabits() [or TaskCubit.watchTasks stream fires]
  → WidgetDataService.pushHabitData(allHabits)  [or pushTaskData(allTasks)]
    → filters: HabitType.regular only, today's date, non-deleted
    → serializes to JSON: {t, d, s, u, cp, tg}
    → HomeWidget.saveWidgetData() for habits/tasks/total/done/locale keys
    → HomeWidget.updateWidget(iOSName: 'AtharHabitWidget')
```

---

## Locale Change

```
User selects language in GeneralSettingsPage
  → LocaleCubit.setLocale(Locale?)
    → FlutterSecureStorage.write('preferred_locale', 'ar'/'en') [or delete for system]
    → emit(LocaleState(locale))
      → MaterialApp rebuilds with new locale
      → [MISSING]: WidgetDataService is NOT called here
        → athar_app_locale in UserDefaults stays stale until next pushTaskData/pushHabitData
```

---

## Sync: Isar → Supabase

```
SyncCubit.startSync() [called at startup]
  → SyncService.sync()
    → For each feature: reads Isar records with updatedAt > lastSyncedAt
    → Upserts to Supabase
    → Updates lastSyncedAt in Isar
  Background: workmanager periodic task calls SyncService.sync()
```

---

## Stats: Fetch Flow

```
StatsCubit.loadStats(DateRange)
  → GetStatsUseCase.execute(DateRange)
    → StatsRepositoryImpl.getStats(DateRange)
      → StatsRemoteSource.fetchStats(DateRange)  [Supabase aggregate query]
      → maps to StatsData domain model
  → emits StatsLoaded(StatsData)
    → StatsPage rebuilds charts
```

---

## Notification Scheduling

```
PrayerNotificationScheduler.schedule(times)
  → LocalNotificationService.schedule(id, title, body, time, payload)
    → flutter_local_notifications plugin

Auto-renewal:
  Notification fires with payload 'auto_reschedule_prayers'
  → main.dart _handleAutoRenewal(payload)
    → PrayerNotificationScheduler.schedule(next day times)
```

---

## Deep Link / Notification Tap

```
FCMService receives remote notification
  → DeepLinkService.handleDeepLink(uri)
    → DeepLinkService.navigatorKey.currentContext
      → Navigator.pushNamed(context, route, arguments: payload)
```
