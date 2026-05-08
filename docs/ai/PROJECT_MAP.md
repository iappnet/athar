# Athar — Project Map

## Top-Level Layout

```
athar/
├── lib/                 # All Dart/Flutter source
│   ├── main.dart        # Entry point: Firebase, Supabase, RevenueCat, DI, then runApp
│   ├── app.dart         # AtharApp: MultiBlocProvider (18+ cubits) + MaterialApp routes
│   ├── core/            # Shared infrastructure (no feature logic)
│   └── features/        # 16 feature modules
├── ios/                 # iOS runner + 3 widget extensions
│   ├── Runner/
│   ├── AtharPrayerWidget/
│   ├── AtharTaskWidget/
│   └── AtharHabitWidget/
├── android/             # Android runner + 4 widget types
├── test/                # Unit/widget tests (currently minimal)
├── docs/                # Project documentation
│   ├── ai/              # ← This directory: AI-targeted reference docs
│   └── progress/        # Phase tracker, checkpoints, project status
├── .claude/commands/    # Slash command definitions for Claude Code
├── CLAUDE.md            # Primary instructions for Claude Code
└── pubspec.yaml         # Dependencies
```

## `lib/core/` Folder Responsibilities

| Folder | Purpose |
|--------|---------|
| `di/` | GetIt + Injectable wiring; `injection.dart` (entry) + `injection.config.dart` (generated) |
| `config/` | App-wide constants, RevenueCat key, GoRouter stub (not used) |
| `constants/` | `athkar_data.dart` — static Islamic dhikr with fixed UUIDs |
| `design_system/` | Atomic design: tokens → atoms → molecules → organisms → templates + shared widgets |
| `error/` | `failures.dart` stub; actual Failure subclasses are inline per feature |
| `iam/` | RBAC for space feature: RoleService, PermissionService, PermissionCache |
| `layouts/` | Responsive scaffold wrappers |
| `models/` | Shared data models (e.g. `UploadQueueModel`) |
| `presentation/cubit/` | Global cubits: `LocaleCubit` (language), `CelebrationCubit` (confetti) |
| `services/` | 25+ singletons: notifications, sync, prayer, widget bridge, deep links, FCM |
| `time_engine/` | Prayer time logic: `AtharTimeCalculator`, `AtharTimePeriods`, time parsers |
| `utils/` | Pure utilities: extensions, icon registry, navigation helpers |

## `lib/features/` Modules

| Module | Primary Cubit(s) | Data Sources | Notes |
|--------|-----------------|--------------|-------|
| `auth` | `AuthCubit` | Supabase only | Login, signup, profile |
| `home` | `HomeCubit`, `TimelineCubit` | Isar (via watch) | Main page + daily timeline |
| `prayer` | `PrayerCubit` | Isar + Supabase + `prayer_service` | Prayer times, nafl detection |
| `dhikr` | `DhikrCubit` | Isar + Supabase + static `athkar_data.dart` | Morning/evening dhikr, counter |
| `habits` | `HabitCubit` | Isar + Supabase | Daily habits, streaks, widget actions |
| `task` | `TaskCubit` | Isar + Supabase | Today's tasks, widget actions; **no local Isar datasource class** |
| `calendar` | `CalendarCubit` | Supabase | Appointments, events |
| `focus` | `FocusCubit` | Isar + Supabase | Pomodoro / focus sessions |
| `health` | `HealthCubit` | HealthKit/HealthConnect | Steps, sleep (platform plugin) |
| `assets` | `AssetsCubit` | Supabase | Financial assets, documents |
| `space` | `SpaceCubit`, `ModuleCubit`, `ListCubit`, `InboxCubit`, `JoinSpaceCubit`, `SpaceMembersCubit` | Supabase | Collaborative workspaces |
| `stats` | `StatsCubit` | Supabase + `StatsRepository` | Analytics: tasks, habits, focus, prayer |
| `subscription` | `SubscriptionCubit` | RevenueCat | Pro feature gating |
| `sync` | `SyncCubit` | `SyncService` | Isar → Supabase background sync |
| `settings` | `SettingsCubit`, `CategoryCubit` | Supabase + SecureStorage | User preferences, categories |
| `notifications` | `NotificationsCubit` | Supabase | In-app notification feed |

## iOS Widget Extensions

| Extension | File | Purpose |
|-----------|------|---------|
| `AtharPrayerWidget` | `ios/AtharPrayerWidget/AtharPrayerWidget.swift` | Prayer countdown, nafl badges |
| `AtharTaskWidget` | `ios/AtharTaskWidget/AtharTaskWidget.swift` | Today's tasks + interactive checkbox |
| `AtharHabitWidget` | `ios/AtharHabitWidget/AtharHabitWidget.swift` | Today's habits + complete/increment |

All share App Group `group.com.iappsnet.athar`. Flutter bridge: `WidgetDataService`.

## Navigation

Defined in `app.dart` using named routes:
- `/home` → `MainPage` (tab shell)
- `/login` → `LoginPage`
- `/complete_profile` → `CompleteProfilePage`
- `/join-space` → `JoinSpaceScreen`

Global navigator key: `DeepLinkService.navigatorKey`. No GoRouter in production.

## Startup Sequence

1. `main()`: dotenv → Firebase → Supabase → RevenueCat → `configureDependencies()`
2. `runApp(AtharApp())`
3. After first frame (`_initBackground`): WidgetDataService.init → SpaceRepository.initDefaultData → SyncService → HabitRepository.ensureSystemHabits → intl → DeepLinkService → LocalNotificationService → FCMService → schedulers
