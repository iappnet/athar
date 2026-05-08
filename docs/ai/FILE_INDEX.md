# Athar — File Index

High-risk or non-obvious files. For a complete listing, use `find lib/ -name "*.dart"` or SocratiCode.

---

## Entry Points

| File | Purpose | Risk |
|------|---------|------|
| `lib/main.dart` | Firebase/Supabase/RevenueCat init, DI, runApp, notification auto-renewal handler | Startup ordering is critical; background init order matters |
| `lib/app.dart` | AtharApp widget, global MultiBlocProvider (18+ cubits), MaterialApp routes, `onResume` handler | BlocProvider list must stay in sync with all cubits used globally |
| `lib/core/di/injection.config.dart` | Generated DI wiring — never edit | Regenerate after any @injectable annotation change |

---

## Core Services (high-change-frequency)

| File | Main Class | Used By | Risk |
|------|-----------|---------|------|
| `lib/core/services/widget_data_service.dart` | `WidgetDataService` | PrayerCubit, TaskCubit, HabitCubit, app.dart onResume | WidgetKeys constants are canonical — never rename |
| `lib/core/services/sync_service.dart` | `SyncService` | SyncCubit | Touches all feature repositories; ordering matters |
| `lib/core/services/local_notification_service.dart` | `LocalNotificationService` | All schedulers, main.dart | Cold-start payload consumption; global channel setup |
| `lib/core/services/prayer_timer_service.dart` | `PrayerTimerService` | PrayerCubit | Runs a periodic timer; must be cancelled on dispose |
| `lib/core/services/deep_link_service.dart` | `DeepLinkService` | app.dart, notification tap handlers | Holds global navigator key; null context = no active route |
| `lib/core/presentation/cubit/locale_cubit.dart` | `LocaleCubit` | MaterialApp, SettingsPage | Does NOT update widget locale on change (Phase 5 bug P1) |

---

## Feature-Critical Files

### Task Feature
| File | Notes |
|------|-------|
| `lib/features/task/presentation/cubit/task_cubit.dart` | `_cachedTasks` cache; `toggleTaskCompletionByUuid` has cache-miss bug (P2) |
| `lib/features/task/data/repositories/task_repository_impl.dart` | Isar writes done here; `task_remote_source.dart` is Supabase-only |
| `lib/features/task/presentation/pages/unified_tasks_page.dart` | Creates empty TaskCubit; display is via TimelineCubit |
| `lib/features/task/presentation/widgets/unified_add_sheet.dart` | Add task bottom sheet; uses `parentContext.read<TaskCubit>()` (MainPage's) |
| `lib/features/home/presentation/cubit/timeline_cubit.dart` | Isar stream watcher; canonical display path for UnifiedTasksView |

### Habit Feature
| File | Notes |
|------|-------|
| `lib/features/habits/presentation/cubit/habit_cubit.dart` | `_habits` cache; `completeHabitByUuid`/`incrementHabitProgressByUuid` have cache-miss bugs (P3) |
| `lib/features/habits/data/repositories/habit_repository_impl.dart` | `getHabitByUuid` at line 215 — use as fallback for P3 fix |
| `lib/features/habits/data/models/habit_model.dart` | `uuid` is `String?`; auto-generated in constructor; `HabitType` enum defines `regular` vs `athkar` |
| `lib/features/habits/presentation/widgets/habit_form_dialog.dart` | `HabitFormSheet.show(context)` — uses `BlocProvider.value` with parent HabitCubit |

### Prayer Feature
| File | Notes |
|------|-------|
| `lib/features/prayer/presentation/cubit/prayer_cubit.dart` | Reads locale independently; calls `pushPrayerData` on every load; computes nafl windows |
| `lib/features/prayer/domain/models/prayer_timer_status.dart` | `isCurrentPrayerWindow` state for "صلاة جارية" display |

### Home / Navigation
| File | Notes |
|------|-------|
| `lib/features/home/presentation/pages/main_page.dart` | Tab shell; provides local TaskCubit + HabitCubit that SHADOW globals; `_handleFabPressed` routes `+` taps |
| `lib/core/design_system/widgets/context_aware_fab.dart` | `ContextAwareFabController`; routes `FabContext.tasks` → `onAddTask?.call()` |
| `lib/core/design_system/widgets/liquid_glass_nav_bar.dart` | Bottom nav bar with central `+` button |

---

## Design System Files

| File | Notes |
|------|-------|
| `lib/core/design_system/tokens/tokens.dart` | Barrel export — import this, not individual token files |
| `lib/core/design_system/tokens/athar_colors.dart` | Brand color palette |
| `lib/core/design_system/tokens/athar_spacing.dart` | `AtharSpacing.xs/sm/md/lg/xl` — use instead of raw numbers |
| `lib/core/design_system/tokens/athar_typography.dart` | Text styles; Cairo font |

---

## iOS Widget Files

| File | Notes |
|------|-------|
| `ios/AtharPrayerWidget/AtharPrayerWidget.swift` | v6 payload; no interaction; `resolvedLocale()` handles system sentinel |
| `ios/AtharTaskWidget/AtharTaskWidget.swift` | `ToggleTaskIntent`; writes to `athar_pending_task_actions` |
| `ios/AtharHabitWidget/AtharHabitWidget.swift` | `CompleteHabitIntent` + `IncrementHabitIntent`; writes to `athar_pending_habit_actions` |
| `ios/Runner.xcodeproj/project.pbxproj` | All three extensions must appear as targets; entitlements must be wired for Debug + Release + Profile |
| `ios/Podfile` | `platform :ios, '17.0'`; post-install sets all targets to 17.0 |

---

## Generated Files (Never Edit)

| Pattern | Tool | Regenerate with |
|---------|------|----------------|
| `lib/core/di/injection.config.dart` | injectable_generator | `build_runner build` |
| `lib/**/*.g.dart` | isar_generator | `build_runner build` |
| `lib/l10n/generated/app_localizations*.dart` | flutter gen-l10n | `flutter gen-l10n` |
| `lib/features/settings/data/models/user_settings.g.dart` | isar_generator | `build_runner build` |

---

## Dead / Stub Files (Do Not Use)

| File | Status |
|------|--------|
| `lib/core/config/routes.dart` | GoRouter stub — not wired; all routing in `app.dart` |
| `lib/core/error/failures.dart` | Stub — actual Failure types defined inline per feature |
