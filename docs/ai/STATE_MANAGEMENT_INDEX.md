<!--
CANONICAL-FOR: Cubit tree, BlocProvider scope, cubit instance disambiguation
OWNER:         Claude Code
PRECEDENCE:    5 (Tier 2 — load for any cubit change)
LAST-UPDATED:  2026-06-01 · Stage A
LOADS-AT:      Tier 2 (any cubit change)
-->

# Athar — State Management Index

## Global Cubits (app.dart MultiBlocProvider)

All provided at app root. Accessed via `context.read<XCubit>()` anywhere below `AtharApp`.

| Cubit | Init call | State class | Purpose |
|-------|-----------|-------------|---------|
| `AuthCubit` | none | `AuthState` | Auth status, user object |
| `PrayerCubit` | `loadPrayerTimes()` | `PrayerState` | Prayer schedule, countdown, nafl |
| `TaskCubit` | `watchTasks(DateTime.now())` | `TaskState` | Task list, widget actions |
| `HabitCubit` | `loadHabits()` | `HabitState` | Habit list, streaks, widget actions |
| `DhikrCubit` | — | `DhikrState` | Morning/evening dhikr counter |
| `FocusCubit` | — | `FocusState` | Pomodoro timer, session log |
| `HealthCubit` | — | `HealthState` | Steps, sleep from platform |
| `StatsCubit` | — | `StatsState` | Analytics data |
| `SyncCubit` | `startSync()` | `SyncState` | Isar→Supabase sync status |
| `SettingsCubit` | `loadSettings()` | `SettingsState` | User preferences |
| `CategoryCubit` | — | (inline state) | Task/habit categories |
| `SubscriptionCubit` | `loadStatus()` | `SubscriptionState` | RevenueCat pro status |
| `NotificationsCubit` | — | `NotificationsState` | In-app notification feed |
| `CalendarCubit` | — | `CalendarState` | Appointments, events |
| `LocaleCubit` | — | `LocaleState` | App language (ar/en/system) |
| `CelebrationCubit` | — | `CelebrationState` | Confetti trigger |
| `SpaceCubit` | — | `SpaceState` | Collaborative workspaces |
| `SpaceMembersCubit` | — | `SpaceMembersState` | Space member management |
| `ListCubit` | — | `ListState` | Task lists within spaces |
| `AssetsCubit` | — | `AssetsState` | Financial assets |

## Local Cubits (page-level, shadow globals)

### MainPage (`lib/features/home/presentation/pages/main_page.dart`)
Provides these **over** the global ones — nearest ancestor wins:
- `TaskCubit` (created via `getIt<TaskCubit>()`, calls `..watchTasks(DateTime.now())`)
- `HabitCubit` (created via `getIt<HabitCubit>()`, does NOT call `loadHabits()`)
- `ModuleCubit` (**ALSO in global MultiBlocProvider** — MainPage's instance shadows the global one)
- `HealthCubit` (**ALSO in global MultiBlocProvider** — MainPage's instance shadows the global one)
- `TimelineCubit` (local; calls `..loadGlobalTimeline()`)

### UnifiedTasksPage (`lib/features/task/presentation/pages/unified_tasks_page.dart`)
Provides `TaskCubit` (created via `getIt<TaskCubit>()`, NO `watchTasks()` called).
**This cubit is effectively empty.** The page shows tasks via `TimelineCubit`.

## Key Cubit Details

### TaskCubit
**File**: `lib/features/task/presentation/cubit/task_cubit.dart`

Internal cache: `List<TaskModel> _cachedTasks` — populated by Isar stream from `watchTasks()`.

Critical methods:
- `watchTasks(DateTime)` — subscribes Isar stream; populates `_cachedTasks`
- `addTask(TaskModel)` — writes to Isar; stream fires → display updates via TimelineCubit
- `toggleTaskCompletionByUuid(String uuid, bool isDone)` — **known bug**: skips if uuid not in `_cachedTasks` (Phase 5 fix pending)
- `processWidgetPendingActions()` — called from `app.dart` onResume; uses `DeepLinkService.navigatorKey.currentContext` → finds MainPage's TaskCubit

States: `TaskInitial`, `TaskLoading`, `TaskLoaded`, `TaskError`

### HabitCubit
**File**: `lib/features/habits/presentation/cubit/habit_cubit.dart`

Internal cache: `List<HabitModel> _habits` — populated by `loadHabits()`.

Critical methods:
- `loadHabits()` — reads from Isar; emits `HabitLoaded`
- `addHabit(HabitModel)` — writes to Isar, calls `loadHabits()` at end
- `completeHabitByUuid(String uuid)` — **known bug**: cache-only lookup (Phase 5 fix pending)
- `incrementHabitProgressByUuid(String uuid)` — **known bug**: cache-only lookup (Phase 5 fix pending)
- `processWidgetPendingActions()` — reads habit pending queue; dispatches complete/increment

States: `HabitInitial`, `HabitLoading`, `HabitLoaded`, `HabitError`

### TimelineCubit
**File**: `lib/features/home/presentation/cubit/timeline_cubit.dart`

Subscribes to `_taskRepository.watchTasksByDate(DateTime.now())`.
This is the **canonical display path** for today's tasks in `UnifiedTasksView`.
Does not interact with TaskCubit's cache.

### PrayerCubit
**File**: `lib/features/prayer/presentation/cubit/prayer_cubit.dart`

Reads locale from `FlutterSecureStorage('preferred_locale')` independently.
Calls `WidgetDataService.pushPrayerData()` with full v6 schema on every load.
Computes `isDuhaTime`, `isQiyamTime`, current/next/prev prayer.

### LocaleCubit
**File**: `lib/core/presentation/cubit/locale_cubit.dart`

`setLocale(Locale?)`:
- null → delete `preferred_locale` key (system default)
- locale → write `locale.languageCode` (`'ar'` or `'en'`)
- **Does NOT call WidgetDataService** — widget locale only updates on next task/habit data push (Phase 5 bug)

### StatsCubit
**File**: `lib/features/stats/presentation/cubit/stats_cubit.dart`

Delegates to `GetStatsUseCase`. Supabase-only, no Isar caching.
States: `StatsInitial`, `StatsLoading`, `StatsLoaded`, `StatsError`

## BlocListener Patterns

Pages use `BlocListener` for side effects (SnackBars, navigation):

```dart
// Error display pattern (habit_page.dart, task_page.dart)
BlocListener<HabitCubit, HabitState>(
  listener: (context, state) {
    if (state is HabitError) AtharSnackbar.error(context, state.message);
  },
)

// Navigation on auth state
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is Authenticated) Navigator.pushReplacementNamed(context, '/home');
    if (state is Unauthenticated) Navigator.pushReplacementNamed(context, '/login');
  },
)
```

## buildWhen Guards

Use `buildWhen` to prevent unnecessary rebuilds. Pattern:
```dart
BlocBuilder<TaskCubit, TaskState>(
  buildWhen: (prev, curr) => curr is TaskLoaded || curr is TaskError,
  builder: (context, state) { ... },
)
```

## Common Mistakes

1. **Reading from wrong TaskCubit**: `context.read<TaskCubit>()` inside MainPage subtree gets MainPage's instance. The global one (from app.dart) is shadowed.
5. **ModuleCubit and HealthCubit have the same trap**: Both are provided globally in `app.dart` AND locally in `MainPage`. `context.read<ModuleCubit>()` inside MainPage subtree gets MainPage's instance. Any change targeting the global cubit will not affect the local one.
2. **Expecting addHabit to update via stream**: Habits use `loadHabits()` at the end of write, not an Isar stream. No stream subscription for habits.
3. **Calling processWidgetPendingActions on global cubit**: The navigator context resolves to MainPage's cubits — which is correct. But if the cubit hasn't called `watchTasks()` yet, the cache may be empty.
4. **HabitCubit in UnifiedTasksPage**: Does not exist — tasks page uses TimelineCubit for display.
