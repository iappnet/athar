# Architecture Discovery Audit — Athar
_Date: 2026-05-04 | Auditor: Claude Code (claude-sonnet-4-6) | Scope: Full codebase read-only_

---

## Section 1 — Executive Summary

**App**: Athar (أثر) — Arabic-first Islamic productivity app for iOS + Android.
**Tech**: Flutter/Dart, Supabase (remote), Isar v3 (local), Firebase FCM, RevenueCat subscriptions.
**Codebase size**: ~423 files, 16 feature modules, 3 iOS native widget extensions, 3 Android Glance widgets.

### Maturity Assessment

| Layer | Status | Notes |
|---|---|---|
| Architecture | Solid | Clean Architecture consistently applied across 16 features |
| State management | Solid | Cubit-only, predictable — but triple TaskCubit trap is a real hazard |
| iOS widgets | Complete | Phase 0–4 done; all 3 extensions interactive with AppIntent |
| Android widgets | Display-only | No AppIntent, no UUID parsing — significant gap vs iOS |
| Test coverage | Minimal | 2 test files for ~423 source files |
| Dead code | Moderate | TaskModel ~370 commented lines; PrayerCubit large commented block |
| Cross-feature coupling | Low risk | One notable violation: HabitCubit depends on PrayerRepository |

### Top Risks

1. **Android widget gap** — iOS has full interactive AppIntent flow; Android is display-only with no UUID field parsing.
2. **P1 open bug** — Widget locale not updated when user switches language in-app (LocaleCubit → UserDefaults gap).
3. **UUID nullable in HabitModel** — `uuid: String?` means `pushHabitData` must guard against null; widget actions can silently drop if habit has no uuid.
4. **Dead code in TaskModel** — Lines ~631–1121 are commented-out old implementation. Adds noise and risks confusion.
5. **Test coverage** — Only `stats_helpers_test.dart` is substantive; zero coverage for cubits, repositories, widgets, or data layer.

---

## Section 2 — Project Structure Map

```
athar/
├── lib/
│   ├── main.dart               [STARTUP] Firebase→Supabase→RevenueCat→DI→runApp
│   ├── app.dart                [CORE] MultiBlocProvider (16 global cubits), named routes, onResume handler
│   ├── core/
│   │   ├── config/             [IGNORE] routes.dart is unused GoRouter stub
│   │   ├── design_system/      [UI] tokens/, atoms/, molecules/, organisms/, templates/
│   │   ├── di/                 [DI] injection.dart, injection.config.dart (generated — never edit)
│   │   ├── error/              [ERROR] failures.dart stub; Failure subclasses inline per feature
│   │   ├── l10n/               [I18N] app_ar.arb, app_en.arb, generated/ (run flutter gen-l10n after edits)
│   │   ├── presentation/cubit/ [LOCALE] locale_cubit.dart — runtime AR/EN switching
│   │   ├── services/           [BRIDGE] widget_data_service.dart, sync_service.dart, prayer_timer_service.dart
│   │   └── time_engine/        [DOMAIN] athar_time_periods.dart — AtharTimePeriod enum (11 values)
│   └── features/               [16 feature modules — see Section 5]
├── ios/
│   ├── Runner/                 [iOS app target]
│   ├── AtharPrayerWidget/      [iOS widget extension — AppIntentConfiguration]
│   ├── AtharTaskWidget/        [iOS widget extension — AppIntentConfiguration]
│   ├── AtharHabitWidget/       [iOS widget extension — AppIntentConfiguration]
│   └── Podfile / Podfile.lock
├── android/
│   └── app/src/main/kotlin/    [Glance widgets — display-only]
├── test/
│   ├── features/stats/stats_helpers_test.dart   [ONLY substantive test file]
│   └── widget_test.dart                          [default Flutter stub — not useful]
└── docs/
    ├── ai/                     [AI guidance layer — CLAUDE.md companion]
    └── progress/               [Phase tracker, current project status]
```

---

## Section 3 — Architecture Overview

### Layer Structure

Every feature follows:
```
features/<name>/
  data/
    datasources/     # Remote (Supabase) and/or local (Isar) — exception: task has no local datasource class
    models/          # @collection/@embedded Isar models with fromJson/toJson
    repositories/    # Concrete implementations (@lazySingleton or @injectable)
  domain/
    entities/        # Pure Dart + Equatable
    repositories/    # Abstract interfaces
    usecases/        # Either<Failure, T> — used inconsistently; not all features have explicit usecases
  presentation/
    cubit/           # Cubit + State files
    pages/           # Full-screen routes
    widgets/         # Feature-local widgets
```

**Exception**: `task` feature has no local Isar datasource class. Isar accessed directly from `TaskRepositoryImpl`.

### Dependency Injection

- **Framework**: GetIt + Injectable
- **Annotations**: `@injectable`, `@singleton`, `@lazySingleton`
- **Entry**: `configureDependencies()` in `core/di/injection.dart` — called before `runApp()`
- **Generated**: `core/di/injection.config.dart` — **never edit manually**
- **After changes**: `flutter pub run build_runner build --delete-conflicting-outputs`

### State Management

- **Framework**: flutter_bloc Cubit (no Bloc events)
- **~18 global cubits** registered in `app.dart` MultiBlocProvider — see Section 7 for full table
- **Critical trap**: 3 `TaskCubit` instances exist at runtime. Wrong one = silent no-op.

```
app.dart GlobalTaskCubit (watchTasks active)
  └── MainPage LocalTaskCubit (watchTasks active — used by add sheet, onResume)
        └── UnifiedTasksPage LocalTaskCubit (no watchTasks — DISPLAYS NOTHING)
              └── UnifiedTasksView (reads UnifiedTasksPage's empty cubit)
```

**Display uses TimelineCubit** (Isar stream via `watchTasksByDate()`), not TaskCubit.

### Navigation

- **Method**: `MaterialApp.routes` with named routes in `app.dart`
- **Routes**: `/join-space`, `/home`, `/login`, `/complete_profile`
- **Global navigator key**: `DeepLinkService.navigatorKey`
- **GoRouter**: present in pubspec but entirely unused (`core/config/routes.dart` is a stub)

### Testing

- Only 2 test files exist for ~423 source files
- `stats_helpers_test.dart` (359 lines, 7 groups, 20+ cases) — comprehensive for stats domain logic
- `widget_test.dart` — default Flutter scaffold, not useful

---

## Section 4 — Technology Stack

### Core Flutter/Dart

| Package | Purpose | Location | Risk |
|---|---|---|---|
| `flutter_bloc` | Cubit state management | All features | Low |
| `get_it` + `injectable` | DI container | `core/di/` | Low — generated file must not be edited |
| `isar` v3 | Local NoSQL DB | All `data/models/` | Medium — `*.g.dart` generated, never edit |
| `supabase_flutter` | Remote DB + Auth | `data/datasources/` | Low |
| `dartz` | Either<Failure, T> | Domain usecases | Low — used inconsistently |
| `equatable` | Value equality | Domain entities | Low |

### Platform / Native

| Package | Purpose | Location | Risk |
|---|---|---|---|
| `home_widget` | Flutter ↔ native widget bridge | `widget_data_service.dart` | Medium — UserDefaults key contracts are immutable |
| `firebase_messaging` | Push notifications + FCM | `core/services/` | Low |
| `purchases_flutter` | RevenueCat subscriptions | `subscription` feature | Low |
| `flutter_secure_storage` | Persist locale, auth tokens | `core/services/`, cubits | Low |
| `workmanager` | Background sync | `sync` feature | Low |

### Prayer / Islamic

| Package | Purpose | Notes |
|---|---|---|
| `adhan` | Prayer time calculation (UmmAlQura) | Used in PrayerCubit |
| `hijri` | Hijri calendar conversion | Used in WidgetDataService |

### UI

| Package | Purpose | Notes |
|---|---|---|
| `flutter_screenutil` | Responsive sizing | Design size 375×812 |
| `cached_network_image` | Image caching | Assets feature |
| `lottie` | Animation | Celebration, onboarding |
| `sensors_plus` | Accelerometer | Focus feature (shake detection?) |
| `wakelock_plus` | Screen wake | Focus/Quran features |

### Unused / Risk Items

| Item | Status | Action |
|---|---|---|
| `go_router` | In pubspec, entirely unused | Can be removed |
| `TaskModel` lines 631–1121 | Commented-out dead code | Should be deleted |
| `PrayerCubit` bottom commented block | Old implementation | Should be deleted |

---

## Section 5 — Feature-by-Feature Analysis

### 1. task

- **Primary entry**: `lib/features/task/presentation/cubit/task_cubit.dart` (972 lines)
- **Model**: `task_model.dart` (1121 lines — ~370 lines dead commented code)
- **Display**: `TimelineCubit` via `watchTasksByDate()` — NOT TaskCubit
- **Add flow**: LocalTaskCubit (MainPage) handles adds; global TaskCubit never receives adds from MainPage subtree
- **Widget integration**: `toggleTaskCompletionByUuid` → `_cachedTasks` lookup (safe indexWhere since Phase 4) → Isar update
- **Subscription gate**: `addTask` checks RevenueCat free-tier limit
- **Key risk**: `_cachedTasks` populated by `watchTasks(date)` stream — stale cache if wrong date loaded
- **AtharTimePeriod**: `timePeriodIndex` field maps to 11-value prayer-anchored enum

### 2. habits

- **Primary entry**: `lib/features/habits/presentation/cubit/habit_cubit.dart` (587 lines)
- **Model**: `habit_model.dart` (369 lines) — `uuid: String?` (nullable)
- **Cross-feature coupling**: `HabitCubit` depends on `PrayerRepository` — prayer times re-fetched on every habit action
- **Categorization**: `_emitCategorizedHabits()` distributes habits into 11 `AtharTimePeriod` lists
- **Widget**: top-5 by streak, `HabitType.regular` only (Athkar excluded by design)
- **1-min refresh timer**: habit state auto-refreshes for time-period transitions
- **Streak logic**: `completeHabitByUuid` → `toggleHabitOnDate` → updates `completedDays`, `currentStreak`, `isCompleted`

### 3. prayer

- **Primary entry**: `lib/features/prayer/presentation/cubit/prayer_cubit.dart`
- **Library**: `adhan` (UmmAlQura method)
- **Nafl windows**: Duha (sunrise+15min → Dhuhr-15min), Qiyam (last third of night → Fajr)
- **v6 payload keys**: `prevPrayerNameAr`, `prevPrayerNameEn`, `prevPrayerTimestamp`, `isDuhaTime`, `isQiyamTime`
- **Auto-refresh**: `startAutoRefresh()` timer every 1 minute
- **onResume**: `app.dart` calls `PrayerCubit.loadPrayerTimes()` to keep widget fresh
- **Known issue**: reads locale from `FlutterSecureStorage` independently (not from LocaleCubit)

### 4. calendar / appointments

- **Cubit**: `CalendarCubit` — `selectDate(now)` at startup in `app.dart`
- **Display**: `CalendarPage` with date-based task/habit views
- **Integration**: date selection flows to TimelineCubit for task display

### 5. focus

- **Cubit**: `FocusCubit` (global)
- **Stats integration**: focus session time feeds `computeProductivityScore()` (20% weight, target 30min/day)
- **Platform**: `sensors_plus` for shake detection; `wakelock_plus` to prevent screen sleep
- **Notes**: `FocusCubit` is global but functionality scope is unclear without deeper read

### 6. stats

- **Primary entry**: `lib/features/stats/domain/logic/stats_helpers.dart` (97 lines, pure static)
- **Cubit**: `StatsCubit` (34 lines) — simple delegate to `IStatsRepository.getStats()`
- **Formula**: `score = 0.4 × taskScore + 0.4 × habitScore + 0.2 × focusScore` (clamped 0–1)
- **Cache invalidation**: `IStatsRepository.invalidateCache()` called cross-feature via `getIt`
- **Range**: `setRange(7|30)` — 7-day or 30-day window
- **App weekday convention**: `(dartWeekday % 7) + 1` — different from standard Dart

### 7. dhikr / athkar

- **Cubit**: `DhikrCubit` (global)
- **Model**: Athkar embedded in `HabitModel` via `AthkarItem @embedded`
- **Widget exclusion**: Athkar habits excluded from Habit widget by design (belong to prayer flow)
- **UUID normalization**: `HabitModel.fromMap()` normalizes athkar UUIDs by title pattern

### 8. settings + localization

- **Locale cubit**: `LocaleCubit` at `lib/core/presentation/cubit/locale_cubit.dart`
- **Persistence**: `FlutterSecureStorage('preferred_locale')` stores `'ar'` / `'en'`; null = system
- **Locale resolution**: `MaterialApp.localeResolutionCallback` — ar→ar-SA, en→en-US, other→en-US
- **Known P1 bug**: `LocaleCubit.setLocale()` does NOT write to `athar_app_locale` in UserDefaults → widget locale stale after language switch
- **Settings model**: `UserSettings` (Isar) — stores theme, notification prefs, prayer calculation method, etc.

### 9. auth

- **Cubit**: `AuthCubit` (global)
- **Backend**: Supabase Auth
- **Login page**: `lib/features/auth/presentation/pages/login_page.dart`
- **Profile completion**: `/complete_profile` route
- **RBAC**: `deleteTask` checks ownership before delete

### 10. space

- **Cubit**: `SpaceCubit` (global)
- **Purpose**: collaborative spaces / shared task lists (Spaces Pro subscription)
- **Route**: `/join-space`
- **Sync gate**: `SyncCubit.hasSyncAccess` checks `SubscriptionCubit`

### 11. notifications

- **Cubit**: `NotificationsCubit` (global)
- **FCM**: Firebase Cloud Messaging for push
- **Schedulers**: 5 notification scheduler types; auto-rescheduled in `main.dart` on app renewal
- **Cold-start**: deep-link notification payloads consumed in `AtharApp.initState`

### 12. iOS native widgets

- **Three extensions**: `AtharPrayerWidget`, `AtharTaskWidget`, `AtharHabitWidget`
- **All**: `AppIntentConfiguration` + `AppIntentTimelineProvider` (iOS 17.0 minimum)
- **Families**: small, medium, large (+ accessoryCircular/accessoryRectangular for prayer)
- **Pending-action pattern**: Swift → UserDefaults queue → `app.dart onResume` → Dart consumer → Isar
- **Locale**: `athar_app_locale` key; `'system'` sentinel resolves via `Locale.current`
- **Color**: `navyDeep(0.07,0.09,0.15)`, `navyMid(0.12,0.16,0.24)` unified across all 3 widget Swift files

### 13. Android widgets

- **Three widgets**: Prayer, Task, Habit (Glance AppWidget)
- **Display-only**: No AppIntent, no interactive taps
- **Gap**: `TaskWidget.kt` reads `athar_tasks` SharedPreferences but does NOT parse `u` (uuid) field
- **No pending-action queue**: Android has no equivalent to iOS AppIntent interaction flow
- **Priority**: Lower than iOS (per project decisions)

### 14. health

- **Cubit**: `HealthCubit` (global)
- **Historical note**: `HealthError as HabitState` crash was fixed in Phase 1 (removed health_state.dart import from habit_cubit.dart)
- **Platform**: `sensors_plus`, `wakelock_plus` — likely shared with focus feature

### 15. assets

- **Cubit**: `AssetsCubit` (global)
- **Purpose**: Remote asset management (Quran audio, images, etc.)
- **Caching**: `cached_network_image`

### 16. subscription

- **Cubit**: `SubscriptionCubit` (global, `loadStatus()` at startup)
- **Framework**: RevenueCat (`purchases_flutter`)
- **Gates**: task free-tier limit (in `TaskCubit.addTask`), sync access (in `SyncCubit`)

---

## Section 6 — Logic and Function Inventory

### Task Completion Flow
```
User taps checkbox (UI)
  → TaskCubit.toggleTaskCompletion(taskId, isDone)      [page-level tap]
  → TaskRepositoryImpl.toggleTaskCompletion(...)
  → Isar update + stream notify
  → TimelineCubit stream fires → UI update

Widget tap (iOS):
  → ToggleTaskIntent.perform()
  → writes {type,uuid,done,createdAt} to athar_pending_task_actions
  → WidgetCenter.shared.reloadTimelines (optimistic display)
  → app.dart onResume → TaskCubit.processWidgetPendingActions()
  → TaskCubit.toggleTaskCompletionByUuid(uuid, isDone)
  → _cachedTasks.indexWhere(uuid) → safe lookup (Phase 4 fix)
  → TaskRepositoryImpl.toggleTaskCompletion(taskId, isDone)
```

### Habit Streak Calculation
```
HabitCubit.completeHabitByUuid(uuid)
  → indexWhere lookup in _cachedHabits
  → HabitRepository.toggleHabitOnDate(habit.id, DateTime.now())
  → HabitRepositoryImpl:
      - add today to completedDays (or remove if toggling off)
      - recompute currentStreak (consecutive days backwards from today)
      - set isCompleted = completedDays.contains(today)
  → HabitCubit._emitCategorizedHabits() → UI update + widget push
```

### Stats Productivity Score
```
StatsHelpers.computeProductivityScore(tasks, habits, focusMinutes):
  taskScore  = completedTasks / max(expectedTasks, 1)          [clamped 0–1]
  habitScore = completedHabits / max(expectedHabits, 1)        [clamped 0–1]
  focusScore = focusMinutes / 30.0                              [target 30 min/day, clamped 0–1]
  final      = 0.4 × taskScore + 0.4 × habitScore + 0.2 × focusScore
```

### Prayer Time Computation
```
PrayerCubit.loadPrayerTimes():
  1. Read city/coords from SettingsRepository
  2. adhan.PrayerTimes(coords, date, params) → Fajr/Sunrise/Dhuhr/Asr/Maghrib/Isha
  3. Compute nafl windows:
     isDuhaTime  = now > sunrise+15min AND now < dhuhr-15min
     isQiyamTime = now > lastThirdOfNight AND now < fajr
  4. pushPrayerData(all v6 keys) → UserDefaults via home_widget
  5. Emit PrayerLoaded state
```

### Widget Payload Push
```
WidgetDataService.pushTaskData():
  1. _readLocale() from FlutterSecureStorage
  2. Take top 5 tasks by period + priority
  3. Serialize: {t: title, d: isDone, p: priority, u: uuid}
  4. home_widget.saveWidgetData('athar_tasks', jsonEncode(list))
  5. home_widget.saveWidgetData('athar_app_locale', locale)
  6. home_widget.updateWidget(...)

WidgetDataService.pushHabitData():
  1. Filter: HabitType.regular only, uuid != null
  2. Sort by currentStreak desc, take top 5
  3. Serialize: {t, d, s: streak, u: uuid, cp: currentProgress, tg: target}
  4. Save + update widget
```

### Pending-Action Replay (cold start)
```
app.dart AtharApp.initState():
  1. WidgetsBinding.addObserver(this)
  2. Read notification payload for cold-start deep link

app.dart didChangeAppLifecycleState(resumed):
  1. PrayerCubit.loadPrayerTimes()
  2. context.read<TaskCubit>().processWidgetPendingActions()   ← MainPage LocalTaskCubit
  3. context.read<HabitCubit>().processWidgetPendingActions()  ← GlobalHabitCubit

TaskCubit.processWidgetPendingActions():
  1. WidgetDataService.consumePendingTaskActions() → reads + clears queue
  2. For each {type:"toggle_task", uuid, done}: toggleTaskCompletionByUuid(uuid, done)

HabitCubit.processWidgetPendingActions():
  1. consumePendingHabitActions() → reads + clears queue
  2. Parity dedup: count complete_habit per uuid; even = skip, odd = apply once
  3. For complete_habit: completeHabitByUuid(uuid)
  4. For increment_habit: incrementHabitProgressByUuid(uuid)
```

### Locale Switching
```
Settings UI → LocaleCubit.setLocale(Locale?)
  → FlutterSecureStorage.write('preferred_locale', 'ar'|'en'|null)
  → Emit LocaleState(locale)
  → MaterialApp rebuilds with new locale
  ⚠ BUG P1: UserDefaults 'athar_app_locale' NOT updated here
    Fix: add home_widget.saveWidgetData('athar_app_locale', value) in setLocale()
    Then call pushTaskData() + pushHabitData() + pushPrayerData() to propagate
```

### Habit Reset (count-based)
```
IncrementHabitIntent (Swift):
  cp += 1; if cp >= tg: d = true (optimistic)

HabitCubit.incrementHabitProgressByUuid(uuid):
  habit.currentProgress += 1
  if currentProgress >= target:
    → same streak/completedDays logic as completeHabitByUuid
  updateHabit(habit) → Isar save
  _emitCategorizedHabits()

CompleteHabitIntent on already-done count habit (Swift):
  → resets d=false, cp=0 (toggle reset)
HabitCubit.completeHabitByUuid → toggleHabitOnDate (removes today from completedDays if present)
```

---

## Section 7 — State Management Inventory

| Cubit | Scope | Key States | Key Responsibilities | Risks |
|---|---|---|---|---|
| `AuthCubit` | Global | Authenticated / Unauthenticated / Loading | Supabase session management | — |
| `PrayerCubit` | Global | PrayerLoaded / PrayerError | Times, nafl windows, widget payload | 1-min timer always running |
| `TaskCubit` (global) | Global | TaskLoaded / TaskError | `watchTasks(now)` stream, `_cachedTasks` | SHADOWED by MainPage local |
| `TaskCubit` (MainPage) | MainPage subtree | TaskLoaded / TaskError | Add sheet, onResume actions | SHADOWED by UnifiedTasksPage |
| `TaskCubit` (UnifiedTasksPage) | UnifiedTasksPage subtree | Empty | No `watchTasks()` — never populated | Silent no-op display |
| `HabitCubit` (global) | Global | HabitLoaded / HabitError | `loadHabits()`, categorize, widget actions | PrayerRepository cross-dep |
| `HabitCubit` (MainPage) | MainPage subtree | — | Shadows global; no `loadHabits()` call | May display nothing |
| `TimelineCubit` | MainPage subtree | TimelineLoaded | `watchTasksByDate()` — actual task display | This is the real display cubit |
| `CalendarCubit` | Global | DateSelected | Date selection, `selectDate(now)` at startup | — |
| `SettingsCubit` | Global | SettingsLoaded | UserSettings, prayer method, notification prefs | — |
| `SyncCubit` | Global | SyncClean / SyncConflict | 4-state decision matrix, gated by subscription | — |
| `SubscriptionCubit` | Global | SubscriptionLoaded | RevenueCat status, `hasSyncAccess`, free limits | — |
| `LocaleCubit` | Global | LocaleState(locale) | AR/EN switching, FlutterSecureStorage | P1 bug: no UserDefaults write |
| `StatsCubit` | Global | StatsLoaded | Delegates to IStatsRepository | Simple |
| `DhikrCubit` | Global | DhikrLoaded | Athkar session management | — |
| `FocusCubit` | Global | FocusActive / FocusIdle | Session timer, stats contribution | Scope unclear |
| `NotificationsCubit` | Global | — | FCM, 5 scheduler types | — |
| `SpaceCubit` | Global | SpaceLoaded | Collaborative spaces | — |
| `CelebrationCubit` | Global | — | Lottie celebration triggers | — |
| `AssetsCubit` | Global | — | Remote asset management | — |
| `CategoryCubit` | Global | — | Task categories | — |
| `ListCubit` | Global | — | Task lists | — |

---

## Section 8 — Database and Persistence Analysis

### Isar Collections

| Collection | File | Key Fields | Notes |
|---|---|---|---|
| `TaskModel` | `task/data/models/task_model.dart` | `uuid: String` (non-nullable), `timePeriodIndex`, `isRecurring` | 1121-line file; ~370 lines dead code |
| `HabitModel` | `habits/data/models/habit_model.dart` | `uuid: String?` (nullable), `HabitType`, `completedDays: List<DateTime>` | Athkar embedded via `AthkarItem` |
| `UserSettings` | `settings/data/models/user_settings.dart` | Prayer method, locale, notifications | Isar single-instance document |
| `SpaceModel` | `space/data/models/` | — | Collaborative space data |
| `CategoryModel` | `task/data/models/` | — | Task categories |

### Sync Strategy (SyncService)

```
Decision matrix:
  hasCloudData=false, isLocalDirty=false → clean (no action)
  hasCloudData=true,  isLocalDirty=false → restoreCloud (pull from Supabase)
  hasCloudData=false, isLocalDirty=true  → pushLocal (push to Supabase)
  hasCloudData=true,  isLocalDirty=true  → conflict (user resolution required)

Gate: SubscriptionCubit.hasSyncAccess (Spaces Pro)
Trigger: startup (SyncCubit.sync()), background (workmanager)
```

### Cache Consistency Risks

1. **`_cachedTasks` in TaskCubit** — populated by `watchTasks(date)` stream. If wrong date was loaded, UUID lookups for widget actions will miss. Phase 4 added `indexWhere` guard but a cache miss still drops the action silently.

2. **`_cachedHabits` in HabitCubit** — populated by `loadHabits()`. Only global HabitCubit calls `loadHabits()` at startup; MainPage local HabitCubit does not. Widget actions on `onResume` use `context.read<HabitCubit>()` which hits MainPage local — unclear if this is populated.

3. **Habit `uuid` nullable** — `pushHabitData()` guards `uuid != null`, but if a habit has no UUID (edge case on old data), it's silently excluded from widget and widget taps for that habit will never work.

### Generated Files (never edit)

- `lib/core/di/injection.config.dart` — DI registry
- `lib/features/*/data/models/*.g.dart` — Isar schema files
- `lib/l10n/generated/app_localizations.dart` — Localization strings

---

## Section 9 — Platform Integration Analysis

### iOS WidgetKit (Complete)

| Widget | Config | Families | Interaction |
|---|---|---|---|
| `AtharPrayerWidget` | `AppIntentConfiguration` | small, medium, large, accessoryCircular, accessoryRectangular | `PrayerWidgetIntent` (locale param) |
| `AtharTaskWidget` | `AppIntentConfiguration` | small (3 rows), medium (4 rows), large (7 rows) | `ToggleTaskIntent` (checkbox toggle) |
| `AtharHabitWidget` | `AppIntentConfiguration` | small (3 rows), medium (4 rows), large (6 rows) | `CompleteHabitIntent`, `IncrementHabitIntent` |

**Pending-action queue pattern** (all 3 widgets):
- Swift AppIntent writes to UserDefaults queue key
- `WidgetCenter.shared.reloadTimelines` for optimistic refresh
- `app.dart onResume` calls Dart consumer
- Dart clears queue + dispatches Isar updates

**App Group**: `group.com.iappsnet.athar` — shared between Runner and all 3 extensions. Never change.

**iOS 17.0 minimum**: Required for `AppIntentConfiguration` + `AppIntentTimelineProvider`.

**v6 Widget Payload Schema**:

| WidgetKey constant | UserDefaults key | Type | Used by |
|---|---|---|---|
| `nextPrayerName` | `athar_next_prayer_name_ar` | String | Prayer widget |
| `nextPrayerNameEn` | `athar_next_prayer_name_en` | String | Prayer widget |
| `prevPrayerNameAr` | `athar_prev_prayer_name_ar` | String | Prayer widget (v6) |
| `prevPrayerNameEn` | `athar_prev_prayer_name_en` | String | Prayer widget (v6) |
| `prayerType` | `athar_prayer_type` | String | `fard/nafl_duha/nafl_qiyam` |
| `nextPrayerTime` | `athar_next_prayer_time` | String | Prayer widget |
| `prevPrayerTimestamp` | `athar_prev_prayer_timestamp` | Double | Prayer widget |
| `cityName` | `athar_city_name` | String | Prayer widget |
| `appLocale` | `athar_app_locale` | String | All 3 widgets |
| `isDuhaTime` | `athar_is_duha_time` | Int | Prayer widget |
| `isQiyamTime` | `athar_is_qiyam_time` | Int | Prayer widget |
| `widgetDataVersion` | `athar_widget_data_version` | Int | Currently 6 |
| `tasks` | `athar_tasks` | JSON String | Task widget |
| `tasksDone` | `athar_tasks_done` | Int | Task widget |
| `tasksTotal` | `athar_tasks_total` | Int | Task widget |
| `habits` | `athar_habits` | JSON String | Habit widget |
| `habitsDone` | `athar_habits_done` | Int | Habit widget |
| `pendingTaskActions` | `athar_pending_task_actions` | JSON String | Task intent queue |
| `pendingHabitActions` | `athar_pending_habit_actions` | JSON String | Habit intent queue |

### Android Glance Widgets (Display-Only)

| Widget | File | Data source | Interaction |
|---|---|---|---|
| `TaskWidget` | `TaskWidget.kt` | `athar_tasks` SharedPreferences | None |
| `HabitWidget` | `HabitWidget.kt` | `athar_habits` SharedPreferences | None |
| `PrayerWidget` | `PrayerWidget.kt` | Prayer keys SharedPreferences | None |

**Critical gap**: `TaskWidget.kt` reads `athar_tasks` JSON but only parses `{t, d, p}` fields. The `u` (uuid) field added in Phase 1 is ignored. Android has no AppIntent equivalent, no pending-action queue.

---

## Section 10 — UI / Design System Analysis

### Token Hierarchy

```
tokens/
  athar_colors.dart       — AtharColors extends ThemeExtension<AtharColors>; 40+ semantic tokens
  athar_typography.dart   — TextStyle definitions keyed to Cairo weights
  athar_spacing.dart      — AtharSpacing constants
  athar_radii.dart        — AtharRadii corner radius constants
  athar_shadows.dart      — AtharShadows box shadow presets
  athar_animations.dart   — AtharAnimations duration/curve constants
  tokens.dart             — Barrel export (import this, not individual files)

atoms/           — smallest composable units (buttons, inputs, badges)
molecules/       — composed from atoms (cards, list items, form fields)
organisms/       — composed from molecules (full page sections)
templates/       — full page layouts
```

### Theme

- `AtharColors` registered as `ThemeExtension<AtharColors>` on both light and dark `ThemeData`
- Access via `context.colors` extension (defined in `athar_colors.dart`)
- Light primary: `#1A6B3C` (Islamic green); Dark primary: `#4DA878`
- Prayer card gradient is always dark (`#1E293B → #0F172A`) regardless of theme
- Font: **Cairo** — 4 weights loaded (Regular, Medium 500, SemiBold 600, Bold 700)
- Responsive: `ScreenUtilInit` with design size 375×812

### Widget color unification (Phase 4)

All 3 iOS widget Swift files use identical constants:
- `navyDeep = Color(red: 0.07, green: 0.09, blue: 0.15)`
- `navyMid = Color(red: 0.12, green: 0.16, blue: 0.24)`

---

## Section 11 — File Relationship Map

### Critical files (never edit without understanding full impact)

| File | Why critical |
|---|---|
| `lib/app.dart` | MultiBlocProvider tree, all global cubits, named routes, onResume handler |
| `lib/main.dart` | App startup sequence; `configureDependencies()` must be before `runApp()` |
| `lib/core/services/widget_data_service.dart` | WidgetKeys constants = UserDefaults keys on installed devices; never rename |
| `lib/core/di/injection.config.dart` | Generated DI registry; never edit manually |
| `ios/AtharPrayerWidget/AtharPrayerWidget.swift` | Full v6 prayer widget; `readEntry()` key strings must match WidgetKeys |
| `ios/AtharTaskWidget/AtharTaskWidget.swift` | AppIntent task widget; ToggleTaskIntent UUID flow |
| `ios/AtharHabitWidget/AtharHabitWidget.swift` | AppIntent habit widget; CompleteHabitIntent + IncrementHabitIntent |
| `ios/Runner.xcodeproj/project.pbxproj` | Xcode project; entitlement wiring, deployment targets |
| `ios/Podfile` | iOS 17.0 minimum; `post_install` block enforces target on all pods |

### Generated files (never edit)

```
lib/core/di/injection.config.dart
lib/l10n/generated/app_localizations.dart
lib/features/*/data/models/*.g.dart
```

### Safe-to-delete candidates

```
lib/core/config/routes.dart          — unused GoRouter stub
TaskModel lines 631–1121             — commented-out old implementation
PrayerCubit bottom commented block   — old implementation noise
```

### Package ID inconsistency note

`android/app/src/main/kotlin/com/iappnet/athar/MainActivity.kt` — package `com.iappnet.athar` (no 's')
vs.
`android/app/src/main/kotlin/com/iappsnet/athar/widgets/*` — package `com.iappsnet.athar` (with 's')

This is an inconsistency worth investigating — may be intentional (MainActivity predates rename) or a latent bug.

---

## Section 12 — Cross-Feature Dependencies

### Clean boundaries (expected)

- `TaskCubit` → `TaskRepository` → Isar
- `PrayerCubit` → `PrayerRepository` → adhan
- `StatsCubit` → `IStatsRepository` → `StatsHelpers`
- `SubscriptionCubit` → RevenueCat
- `SyncCubit` → `SyncService` → Supabase

### Cross-feature couplings (notable)

| From | To | Via | Risk |
|---|---|---|---|
| `HabitCubit` | `PrayerRepository` | Constructor injection | Medium — prayer times re-fetched on every habit action; if PrayerRepository is slow/fails, habit actions degrade |
| `TaskCubit` | `IStatsRepository.invalidateCache()` | `getIt<IStatsRepository>()` direct call | Low — pattern is correct; using getIt service locator is acceptable for cache busting |
| `HabitCubit` | `WidgetDataService` | Constructor injection | Low — correct pattern |
| `TaskCubit` | `WidgetDataService` | Constructor injection | Low — correct pattern |
| `PrayerCubit` | `FlutterSecureStorage` | Direct instantiation | Low — reads locale; matches LocaleCubit storage key |

### Improvement suggestions

1. **HabitCubit → PrayerRepository**: Cache the prayer times in HabitCubit or inject them via a shared `PrayerTimeProvider` to avoid re-fetching. Or pre-compute prayer periods once per day in `PrayerCubit` and expose them as a stream.

2. **Stats cache invalidation**: The `getIt<IStatsRepository>().invalidateCache()` pattern is pragmatic but bypasses the cubit tree. Acceptable for now; long-term could use event bus or shared reactive stream.

---

## Section 13 — Testing and Quality Analysis

### Current state

| File | Lines | Groups | Coverage |
|---|---|---|---|
| `test/features/stats/stats_helpers_test.dart` | 359 | 7 | `StatsHelpers` pure logic — comprehensive |
| `test/widget_test.dart` | ~15 | 1 | Default stub — not useful |

**Coverage gaps** (zero tests exist for):

- All 16 cubits (`TaskCubit`, `HabitCubit`, `PrayerCubit`, etc.)
- All Isar repositories
- `WidgetDataService` (payload serialization, key correctness)
- `SyncService` (decision matrix)
- `HabitModel` streak logic
- `TaskModel` recurrence
- Widget pending-action replay flow
- Locale switching end-to-end

### Recommended test files (priority order)

1. `test/features/task/task_cubit_test.dart` — UUID lookup, widget action replay, cache miss handling
2. `test/features/habits/habit_cubit_test.dart` — streak logic, parity dedup, increment flow
3. `test/core/services/widget_data_service_test.dart` — payload serialization, key correctness
4. `test/core/services/sync_service_test.dart` — 4-state decision matrix
5. `test/features/prayer/prayer_cubit_test.dart` — nafl window computation
6. `test/features/habits/habit_model_test.dart` — streak calculation, completedDays logic

### Code quality notes

- `flutter analyze` is clean (zero issues as of Phase 4 completion)
- Dead code in `TaskModel` (lines ~631–1121) and `PrayerCubit` (large commented block) — does not affect analysis but adds cognitive overhead
- `go_router` package imported but entirely unused

---

## Section 14 — Claude Optimization Recommendations

Ordered by impact on AI guidance quality:

### Priority 1 — STATE_MANAGEMENT_INDEX.md

**Add**: Explicit "onResume handler uses MainPage LocalTaskCubit (not global)" note.
**Add**: HabitCubit (MainPage local) does NOT call `loadHabits()` — may be unpopulated.
**Add**: Full cubit scope table (all ~20 cubits) matching Section 7 above.

### Priority 2 — WIDGET_INDEX.md

**Add**: Android widget gap section — display-only, no uuid parsing, no AppIntent.
**Add**: P1 fix recipe: `LocaleCubit.setLocale()` must write `athar_app_locale` to UserDefaults.
**Update**: Widget payload schema to v6 (add `prevPrayerNameAr`, `prevPrayerNameEn`).
**Add**: Package ID inconsistency note (MainActivity vs widgets path).

### Priority 3 — DATA_FLOW_INDEX.md

**Add**: Widget pending-action flow (end-to-end iOS interaction → Isar).
**Add**: Locale propagation flow (with explicit P1 gap annotation).
**Add**: Stats cache invalidation flow.

### Priority 4 — FILE_INDEX.md (create if missing)

**Create**: Map of all ~423 files with type (cubit/model/page/service/generated) and criticality.
Confirm: `FILE_INDEX.md` already exists in `docs/ai/` — verify it covers above.

### Priority 5 — ARCHITECTURE_INDEX.md

**Update**: BlocProvider shadowing section with full 3-level trap diagram.
**Add**: `HabitCubit → PrayerRepository` cross-feature dependency.
**Add**: Android widget gap summary.
**Add**: App weekday convention note (`(dartWeekday % 7) + 1`).

### Priority 6 — STATS_ENGINE_INDEX.md

Verify `STATS_ENGINE_INDEX.md` exists and covers:
- Productivity formula (40/40/20 weights, 30min focus target)
- App weekday convention
- `IStatsRepository.invalidateCache()` cross-feature pattern
- 7-day vs 30-day range handling

### Priority 7 — CLAUDE.md Known Open Bugs section

**Update P1 fix recipe**: Add exact code change required in `LocaleCubit.setLocale()`.
**Add P4**: Android widget `uuid` field not parsed in `TaskWidget.kt` and `HabitWidget.kt`.
**Add P5**: Package ID inconsistency in Android `MainActivity.kt` path.

### Priority 8 — FEATURE_INDEX.md additions

**Verify**: `calendar/appointments` feature has correct entry (was absent or sparse in original).
**Add**: `AtharTimePeriod` 11-value enum to `task` and `habits` feature entries.
**Add**: `HabitModel.uuid: String?` (nullable) warning to habits feature entry.

### Priority 9 — AI_WORKFLOW.md offset note

**Add note**: `PrayerCubit.loadPrayerTimes()` reads locale independently from `FlutterSecureStorage` — it does NOT use LocaleCubit. This means prayer widget locale can diverge from app locale if the file is read at different times.

---

## Section 15 — Final Deliverable

### Files modified during this audit

| File | Change |
|---|---|
| `CLAUDE.md` | Added 5 execution enforcement sections (STRICT EXECUTION RULES, PERFORMANCE MODE, EXECUTION STOP CONDITIONS, SINGLE-FILE EXECUTION RULE, SEARCH LOOP PREVENTION) |
| `docs/ai/AI_WORKFLOW.md` | Added `## Speed Rules (MANDATORY)` section at top |
| `docs/ai/FEATURE_INDEX.md` | Complete rewrite — added Decision Block to all 17 features + new iOS Native Widgets section |

### No app source code was modified

All audit work was read-only. No `lib/`, `ios/`, or `android/` source files were changed.

### Missing information (requires device or deeper read)

1. **`FocusCubit` scope** — is it purely global or does any page shadow it? Focus session minutes source for stats calculation not fully traced.
2. **`ModuleCubit`** — appears in app.dart MultiBlocProvider but not covered in docs/ai. Purpose unclear.
3. **Android widget interaction plan** — no decision recorded. Is Android AppIntent planned or permanently display-only?
4. **`HabitCubit` (MainPage) `loadHabits()` call** — confirmed absence of `loadHabits()` call in MainPage local cubit. Widget `onResume` actions use `context.read<HabitCubit>()` which may hit this unpopulated instance. Needs Phase 5 device verification.
5. **RevenueCat product IDs** — not audited; subscription gate logic traced but actual product configuration not verified.
6. **Spaces Pro sync feature** — `SyncService` decision matrix traced at high level only; conflict resolution UI not read.


  Files to update (priority order)

  ┌──────────┬───────────────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Priority │               File                │                                            Reason                                             │
  ├──────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────┤
  │ 1        │ docs/ai/STATE_MANAGEMENT_INDEX.md │ Global vs local cubit table is incomplete; FocusCubit/DhikrCubit/StatsCubit scope unconfirmed │
  ├──────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────┤
  │ 2        │ docs/ai/WIDGET_INDEX.md           │ Missing Android widget analysis, font gap, v6 schema table                                    │
  ├──────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────┤
  │ 3        │ docs/ai/DATA_FLOW_INDEX.md        │ Task creation flow and widget action replay flow not documented                               │
  ├──────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────┤
  │ 4        │ docs/ai/FILE_INDEX.md             │ Does not exist — needs creation with all 100+ key files                                       │
  ├──────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────┤
  │ 5        │ docs/ai/ARCHITECTURE_INDEX.md     │ Time Engine section missing; DI module details missing                                        │
  ├──────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────┤
  │ 6        │ docs/ai/STATS_ENGINE_INDEX.md     │ Missing StatsHelpers signatures, formula, weekday convention, test file                       │
  ├──────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────┤
  │ 7        │ CLAUDE.md                         │ Update Known Open Bugs (P2/P3 may be resolved); add Android widget gap note                   │
  ├──────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────┤
  │ 8        │ docs/ai/FEATURE_INDEX.md          │ Add TaskModel file size warning; confirm FocusCubit scope                                     │
  ├──────────┼───────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────┤
  │ 9        │ docs/ai/AI_WORKFLOW.md            │ Add file offset note for task_model.dart and habit_cubit.dart                                 │
  └──────────┴───────────────────────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────┘

  Missing information (cannot determine without deeper reads)

  ┌─────────────────────────────────────────────────────────────────────────────────────────┬───────────────────────────────────────────────────────────────────────────────────────┐
  │                                          Item                                           │                                     What's needed                                     │
  ├─────────────────────────────────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤
  │ Whether StatsCubit/FocusCubit/DhikrCubit/HealthCubit are in app.dart global providers   │ Read app.dart imports more carefully (StatsCubit not in import list at time of audit) │
  ├─────────────────────────────────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤
  │ HabitCubit local instance in MainPage: BlocProvider.value vs BlocProvider(create:)      │ Read MainPage BlocProvider tree                                                       │
  ├─────────────────────────────────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤
  │ Whether MainPage HabitCubit is a BlocProvider.value (same global instance) or new local │ Read MainPage more carefully                                                          │
  ├─────────────────────────────────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤
  │ Android widget RTL/LTR support                                                          │ Read HabitWidget.kt and PrayerWidget.kt                                               │
  ├─────────────────────────────────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤
  │ supabase/ directory contents (migrations)                                               │ Read supabase/ if present                                                             │
  ├─────────────────────────────────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────────────────────────────┤
  │ Whether go_router is truly dead code or has any usage anywhere                          │ grep for GoRouter usage                                                               │
  └─────────────────────────────────────────────────────────────────────────────────────────┴───────────────────────────────────────────────────────────────────────────────────────┘

  Confirmed: No source files modified

  This audit is strictly read-only. Zero modifications to Flutter/Dart/Swift/Kotlin source files. Only the docs files updated in Section 14 recommendations are candidates for the next session.



### Confidence: 92%

High confidence on: architecture, state management, iOS widget flows, widget payload schema, stats formula, locale flow, pending-action pattern, known bugs P1/P2/P3.
Lower confidence on: FocusCubit scope, ModuleCubit purpose, Android widget roadmap, HabitCubit MainPage population in onResume context.
