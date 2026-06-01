<!--
CANONICAL-FOR: Feature file map, mandatory start files, decision blocks for all 16 features
OWNER:         Claude Code
PRECEDENCE:    5 (Tier 2 — load when touching any feature module)
LAST-UPDATED:  2026-06-01 · Stage A
LOADS-AT:      Tier 2 (any screen PR)
-->

# Athar — Feature Index

Each entry lists key files, models, cubit, repository, and non-obvious dependencies.
Each entry includes a **Decision Block** — use it to stop searching and start executing.

---

## auth
**Path**: `lib/features/auth/`
- Cubit: `auth_cubit.dart` / `auth_state.dart`
- Repository: `auth_repository.dart` (abstract) + `auth_repository_impl.dart`
- Datasource: `auth_remote_source.dart` (Supabase)
- Pages: `login_page.dart`, `complete_profile_page.dart`, `onboarding_page.dart`
- Note: `home/data/` contains a second `auth_remote_source.dart` and `auth_repository_impl.dart` — these are separate concerns (home-level user profile)

**MANDATORY START FILE**: `auth_repository_impl.dart` (start here — no alternative entry allowed for auth data issues)

**Execution Path**:
1. Start: `auth_repository_impl.dart`
2. Auth state issue → `auth_cubit.dart`
3. Login/signup UI → `login_page.dart`
4. Profile completion → `complete_profile_page.dart`
STOP. First selected path executes immediately.

**Do NOT search**: `home/data/auth_repository_impl.dart` unless the issue is home-level user profile loading.

---

## home
**Path**: `lib/features/home/`
- Cubits: `home_cubit.dart`, `timeline_cubit.dart`
- `TimelineCubit`: subscribes to `TaskRepository.watchTasksByDate(DateTime.now())`; this is the live display path for `UnifiedTasksView` — NOT TaskCubit
- Repository: `i_auth_repository.dart` + `auth_repository_impl.dart` (home-level user data)
- Pages: `main_page.dart` (tab shell, provides local TaskCubit + HabitCubit), `splash_page.dart`

**MANDATORY START FILE**: `main_page.dart` (start here — no alternative entry allowed for home/navigation issues)

**Execution Path**:
1. Start: `main_page.dart`
2. Task display on home → `timeline_cubit.dart` (NOT task_cubit)
3. Tab/navigation state → `home_cubit.dart`
4. Add sheet → `unified_add_sheet.dart` (triggered from MainPage NavBar `+`)
STOP. First selected path executes immediately.

**Do NOT search**: global `task_cubit.dart` for home display issues — `UnifiedTasksView` uses `TimelineCubit`.

---

## prayer
**Path**: `lib/features/prayer/`
- Cubit: `prayer_cubit.dart` / `prayer_state.dart`
- Repository: `prayer_repository.dart` + `prayer_repository_impl.dart`
- Datasource: `prayer_remote_source.dart` + Isar local
- Domain models: `prayer_timer_status.dart`, `prayer_times_model.dart`
- Services used: `PrayerService` (adhan library), `PrayerTimerService`, `PrayerConflictService`
- Schedulers: `PrayerNotificationScheduler`
- Widget payload: v6 schema written by `WidgetDataService.pushPrayerData()` — includes nafl window flags
- Note: `PrayerCubit` reads `FlutterSecureStorage('preferred_locale')` independently for widget locale

**MANDATORY START FILE**: `prayer_cubit.dart` (start here — no alternative entry allowed for prayer state/timing issues)

**Execution Path**:
1. Start: `prayer_cubit.dart`
2. Prayer time data issue → `prayer_repository_impl.dart`
3. Nafl/Duha/Qiyam window logic → `prayer_timer_service.dart` (core/services/)
4. Widget push issue → `widget_data_service.dart` (`pushPrayerData`)
5. Notification scheduling → `PrayerNotificationScheduler`
STOP. First selected path executes immediately.

**Do NOT search**: `dhikr` feature unless Athkar links to prayer times explicitly. Do NOT search `focus` or `task` features.

---

## dhikr
**Path**: `lib/features/dhikr/`
- Cubit: `dhikr_cubit.dart` / `dhikr_state.dart`
- Repositories: `i_dhikr_repository.dart` (abstract) + `dhikr_repository.dart` (also serves as impl) + `dhikr_repository_impl.dart`
- Static data: `core/constants/athkar_data.dart` — fixed UUIDs (`fixed-morning-athkar`, `fixed-evening-athkar`, etc.)
- Datasource: `dhikr_remote_source.dart` + Isar local
- Note: Athkar are explicitly NOT included in the Habit widget — they belong to the dhikr/prayer flow

**MANDATORY START FILE**: `dhikr_cubit.dart` (start here — no alternative entry allowed)

**Execution Path**:
1. Start: `dhikr_cubit.dart`
2. Static data / fixed UUIDs → `core/constants/athkar_data.dart`
3. Persistence issue → `dhikr_repository_impl.dart`
STOP. First selected path executes immediately.

**Do NOT search**: `habits` feature. Athkar are never in the habit widget.

---

## habits
**Path**: `lib/features/habits/`
- Cubit: `habit_cubit.dart` / `habit_state.dart`
- Repository: `habit_repository.dart` + `habit_repository_impl.dart`
- Datasource: `habit_remote_source.dart` + Isar local
- Model: `habit_model.dart` (`@collection`; `uuid` is `String?`, auto-generated in constructor)
- Key methods:
  - `loadHabits()` — loads all non-deleted habits
  - `addHabit(HabitModel)` → saves to Isar, then calls `loadHabits()`
  - `toggleHabitOnDate(String uuid, DateTime)` — used by widget complete action
  - `completeHabitByUuid(String uuid)` — cache lookup via `indexWhere` → `toggleHabitOnDate`
  - `incrementHabitProgressByUuid(String uuid)` — cache lookup via `indexWhere` → `updateHabit`
  - `processWidgetPendingActions()` — reads `athar_pending_habit_actions`, dispatches with parity dedup
- Widget: Habit widget shows only `HabitType.regular` habits (Athkar excluded)
- Scheduler: `HabitNotificationScheduler`
- Pages: `habit_page.dart`, `habit_form_dialog.dart` (bottom sheet)
- Critical: `HabitFormSheet.show(context)` uses `BlocProvider.value` with parent context's HabitCubit

**MANDATORY START FILE**: `habit_cubit.dart` (state/actions) · `habit_repository_impl.dart` (data)

**Execution Path**:
1. Start: `habit_cubit.dart`
2. State/action issue → `habit_cubit.dart` (`completeHabitByUuid`, `incrementHabitProgressByUuid`, `processWidgetPendingActions`)
3. Data/model issue → `habit_repository_impl.dart` → `habit_model.dart`
4. UI issue → `habit_page.dart` or `habit_form_dialog.dart`
5. Widget interaction issue → `AtharHabitWidget.swift` + `widget_data_service.dart`
STOP. First selected path executes immediately.

**Do NOT search**: `dhikr` (Athkar excluded), `health` (separate feature), `task` feature unless the issue is explicitly cross-feature.

---

## task
**Path**: `lib/features/task/`
- Cubit: `task_cubit.dart` / `task_state.dart`
- Repository: `task_repository.dart` + `task_repository_impl.dart`
- Datasource: `task_remote_source.dart` (Supabase only — **no local Isar datasource class**)
- Model: `task_model.dart` (`@collection`; `uuid` is `String`, non-nullable)
- Key methods:
  - `watchTasks(DateTime)` — subscribes to Isar stream for given day
  - `addTask(TaskModel)` → saves to Isar, triggers stream → TimelineCubit updates
  - `toggleTaskCompletionByUuid(String uuid, bool isDone)` — cache lookup via `indexWhere` (safe, no StateError) → `toggleTaskCompletion`
  - `processWidgetPendingActions()` — reads `athar_pending_task_actions`, dispatches
  - `getTaskByUuid(String uuid)` — if task UUID lookup is needed, look in `task_repository_impl.dart` first
- Widget: `ToggleTaskIntent` writes to `athar_pending_task_actions`; Flutter consumes on resume
- Scheduler: `TaskNotificationScheduler`
- Pages: `unified_tasks_page.dart` (display via TimelineCubit), `unified_add_sheet.dart` (add bottom sheet)
- Critical: `UnifiedTasksPage` creates a `TaskCubit` (no `watchTasks()` call). Display is via `TimelineCubit`, NOT this cubit. However, this TaskCubit IS used for action dispatch: postpone, bulk complete, and mutations. It is not dead — it is action-only, not display.

**MANDATORY START FILE**: `task_repository_impl.dart` (data lookup) · `task_cubit.dart` (state/actions)

**Execution Path**:
1. Start: `task_repository_impl.dart` for data access/lookup issues
2. State/update/toggle issue → `task_cubit.dart`
3. Display issue → `timeline_cubit.dart` (NOT UnifiedTasksPage's local cubit — it is intentionally empty)
4. Creation/save flow → `unified_add_sheet.dart` (entry via MainPage NavBar `+`)
5. Widget interaction → `AtharTaskWidget.swift` + `widget_data_service.dart`
STOP. First selected path executes immediately.

**Do NOT search**: UnifiedTasksPage's local TaskCubit for display issues (it has no `watchTasks()` call — display is TimelineCubit). Do NOT use UnifiedTasksPage's TaskCubit for display. DO use it for action dispatch (postpone, bulk ops). Do NOT search global TaskCubit for MainPage add-sheet actions. Do NOT search `habit` or `prayer` features.

---

## calendar / appointments
**Path**: `lib/features/calendar/`
- Cubit: `calendar_cubit.dart` / `calendar_state.dart`
- Repository: `i_calendar_repository.dart` + `calendar_repository_impl.dart`
- Datasource: `calendar_remote_source.dart` (Supabase)
- Scheduler: `AppointmentNotificationScheduler`
- Model: `appointment_model.dart` (Supabase; also covers medicines)

**MANDATORY START FILE**: `calendar_cubit.dart` (start here — no alternative entry allowed)

**Execution Path**:
1. Start: `calendar_cubit.dart`
2. Data/model issue → `calendar_repository_impl.dart` → `appointment_model.dart`
3. Notification scheduling → `AppointmentNotificationScheduler`
STOP. First selected path executes immediately.

**Do NOT search**: `task` or `habit` features unless calendar explicitly integrates them.

---

## focus
**Path**: `lib/features/focus/`
- Cubit: `focus_cubit.dart` / `focus_state.dart`
- Repository: `i_focus_repository.dart` + `focus_repository.dart`
- Datasource: `focus_remote_source.dart` + Isar local
- Service: `FocusModeService`
- Handles Pomodoro timers, focus session logging

**MANDATORY START FILE**: `focus_cubit.dart` (start here — no alternative entry allowed)

**Execution Path**:
1. Start: `focus_cubit.dart`
2. Timer/session logic → `FocusModeService`
3. Data persistence → `focus_repository.dart`
STOP. First selected path executes immediately.

**Do NOT search**: `task`, `habit`, or `prayer` features unless cross-feature integration is explicit.

---

## health
**Path**: `lib/features/health/`
- Cubit: `health_cubit.dart` / `health_state.dart`
- Repository: `health_repository.dart` + `health_repository_impl.dart`
- Platform plugin: `health` package (HealthKit / HealthConnect)
- No Supabase datasource
- Critical: importing `health_state.dart` in `habit_cubit.dart` used to cause `HealthError as HabitState` crash — this was fixed; do not re-import it

**MANDATORY START FILE**: `health_cubit.dart` (start here — no alternative entry allowed)

**Execution Path**:
1. Start: `health_cubit.dart`
2. Platform data → `health_repository_impl.dart` (uses `health` plugin, no Supabase)
STOP. First selected path executes immediately.

**Do NOT search**: `habit_cubit.dart` for health issues — they are entirely separate. Never import `health_state.dart` into any other feature.

---

## assets
**Path**: `lib/features/assets/`
- Cubit: `assets_cubit.dart` / `assets_state.dart`
- Repository: `assets_repository.dart` + `assets_repository_impl.dart`
- Datasource: `assets_remote_source.dart` (Supabase)
- Scheduler: `AssetNotificationScheduler`
- Handles financial assets, documents, property records

**MANDATORY START FILE**: `assets_cubit.dart` (start here — no alternative entry allowed)

**Execution Path**:
1. Start: `assets_cubit.dart`
2. Data issue → `assets_repository_impl.dart`
3. Notification → `AssetNotificationScheduler`
STOP. First selected path executes immediately.

**Do NOT search**: unrelated features.

---

## space
**Path**: `lib/features/space/`
- Cubits: `space_cubit.dart`, `module_cubit.dart`, `list_cubit.dart`, `inbox_cubit.dart`, `join_space_cubit.dart`, `space_members_cubit.dart`
- Repositories: `space_repository.dart`, `module_repository.dart`, `list_repository.dart`, `invitation_repository.dart`
- Datasource: `space_remote_source.dart` (Supabase)
- IAM: `core/iam/` provides RBAC (RoleService, PermissionService, PermissionCache)
- Space creation via `_showCreateSpaceDialog()` from MainPage — no page-level FAB
- Scheduler: `ProjectNotificationScheduler`

**MANDATORY START FILE**: `space_cubit.dart` (start here — no alternative entry allowed)

**Execution Path**:
1. Start: `space_cubit.dart` for space-level issues
2. Permissions/RBAC → `core/iam/` (RoleService, PermissionService)
3. Task lists within a space → `list_cubit.dart`
4. Space modules/sections → `module_cubit.dart` (**Note**: ModuleCubit is also in global MultiBlocProvider; MainPage's local instance shadows it — see STATE_MANAGEMENT_INDEX)
5. Invitations → `invitation_repository.dart`
6. Join space flow → `join_space_cubit.dart`
7. Member management → `space_members_cubit.dart`
8. In-space inbox → `inbox_cubit.dart`
STOP. First selected path executes immediately.

**Do NOT search**: `task` or `habit` features. Space creation entry point is `_showCreateSpaceDialog()` in `main_page.dart`, not a page-level FAB.

---

## stats
**Path**: `lib/features/stats/`
- Cubit: `stats_cubit.dart` / `stats_state.dart`
- Repository: `i_stats_repository.dart` + `stats_repository_impl.dart`
- Datasource: `stats_remote_source.dart` (Supabase)
- Domain: `stats_helpers.dart` (computation logic), `stats_data.dart` (domain model), `stats_entity.dart` (entity)
- Use case: `get_stats_usecase.dart`
- See `STATS_ENGINE_INDEX.md` for deep details

**MANDATORY START FILE**: `stats_cubit.dart` (state) · `stats_helpers.dart` (computation)

**Execution Path**:
1. Start: `stats_cubit.dart`
2. Computation/calculation wrong → `stats_helpers.dart`
3. Data model issue → `stats_entity.dart` → `stats_data.dart`
4. Remote fetch → `stats_repository_impl.dart` → `stats_remote_source.dart`
5. Use-case chain → `get_stats_usecase.dart`
STOP. First selected path executes immediately.

**Do NOT search**: individual feature repositories (task, habit, etc.) unless `stats_helpers.dart` explicitly pulls from them. See `STATS_ENGINE_INDEX.md` for full computation breakdown.

---

## subscription
**Path**: `lib/features/subscription/`
- Cubit: `subscription_cubit.dart` / `subscription_state.dart`
- Repository: `subscription_repository.dart` + `subscription_repository_impl.dart`
- Provider: RevenueCat (`purchases_flutter`); key in `core/config/subscription_config.dart`
- Loaded at startup; gate pro features by checking `SubscriptionCubit` state

**MANDATORY START FILE**: `subscription_cubit.dart` (start here — no alternative entry allowed)

**Execution Path**:
1. Start: `subscription_cubit.dart`
2. Pro feature gate → check `SubscriptionCubit` state from context
3. Config/key → `core/config/subscription_config.dart`
STOP. First selected path executes immediately.

**Do NOT search**: unrelated features.

---

## sync
**Path**: `lib/features/sync/`
- Cubit: `sync_cubit.dart` / `sync_state.dart`
- Repository: `sync_repository.dart` + `sync_repository_impl.dart`
- Service: `core/services/sync_service.dart`
- Isar → Supabase; background via `workmanager`
- Sync page was deleted; sync is background-only

**MANDATORY START FILE**: `core/services/sync_service.dart` (start here — no alternative entry allowed)

**Execution Path**:
1. Start: `sync_service.dart`
2. Trigger/scheduling → `sync_cubit.dart`
3. Data operations → `sync_repository_impl.dart`
STOP. First selected path executes immediately.

**Do NOT search**: `sync_page.dart` (deleted — does not exist). Sync has no UI page.

---

## settings / localization
**Path**: `lib/features/settings/`
- Cubits: `settings_cubit.dart`, `category_cubit.dart`
- Repositories: `settings_repository.dart` + `settings_repository_impl.dart`, `category_repository.dart`
- Datasource: `settings_remote_source.dart`
- Models: `user_settings.dart` + `user_settings.g.dart` (generated — do not edit)
- Handles: user profile, notification preferences, language (delegates to `LocaleCubit`), categories
- Locale cubit: `lib/core/presentation/cubit/locale_cubit.dart` — language switching, stored in `FlutterSecureStorage('preferred_locale')`

**MANDATORY START FILE**: `settings_cubit.dart` (settings) · `locale_cubit.dart` (localization)

**Execution Path**:
1. Start: `settings_cubit.dart` for user preferences
2. Language switch → `locale_cubit.dart` (in `lib/core/presentation/cubit/`) → `FlutterSecureStorage('preferred_locale')`
3. Widget locale update → `widget_data_service.dart` (`_readLocale()`) — **known bug P1: widget locale not updated on language change**
4. User profile / notification prefs → `settings_repository_impl.dart`
5. Categories → `category_cubit.dart` → `category_repository.dart`
STOP. First selected path executes immediately.

**Do NOT search**: per-feature cubits for locale issues — locale is managed globally by `LocaleCubit`.

---

## notifications
**Path**: `lib/features/notifications/`
- Cubit: `notifications_cubit.dart` / `notifications_state.dart`
- Repository: `notifications_repository.dart` + `notifications_repository_impl.dart`
- Datasource: `notifications_remote_source.dart` (Supabase)
- Central service: `core/services/local_notification_service.dart`
- FCM: `core/services/fcm_service.dart`
- Handles in-app notification feed; push payloads routed via `_handleAutoRenewal` in `main.dart`

**MANDATORY START FILE**: `core/services/local_notification_service.dart` (scheduling) · `notifications_cubit.dart` (in-app feed)

**Execution Path**:
1. Start: `local_notification_service.dart` for scheduling/display issues
2. In-app feed → `notifications_cubit.dart` → `notifications_repository_impl.dart`
3. Push/FCM → `core/services/fcm_service.dart`
4. Feature-specific scheduling → that feature's own `*NotificationScheduler`
STOP. First selected path executes immediately.

**Do NOT search**: unrelated feature-specific schedulers unless the issue is in that specific feature's notification logic.

---

## iOS Native Widgets
**Path**: `ios/Athar*Widget/` + `lib/core/services/widget_data_service.dart`
- Flutter data push: `widget_data_service.dart` — `pushPrayerData()`, `pushTaskData()`, `pushHabitData()`
- Swift display: `ios/AtharPrayerWidget/AtharPrayerWidget.swift`, `ios/AtharTaskWidget/AtharTaskWidget.swift`, `ios/AtharHabitWidget/AtharHabitWidget.swift`
- App Group: `group.com.iappsnet.athar` (shared UserDefaults) — **never change this**
- WidgetKeys: constants class in `widget_data_service.dart` — **never rename existing keys**
- Pending action queues: `athar_pending_task_actions`, `athar_pending_habit_actions`
- Dart-side action processing: `task_cubit.dart` (`processWidgetPendingActions`), `habit_cubit.dart` (`processWidgetPendingActions`)
- Called from: `app.dart` `onResume` handler

**MANDATORY START FILE**:
- Flutter data issue → `widget_data_service.dart` (start here — no alternative entry allowed for data push)
- Swift display/layout → corresponding `Athar*Widget.swift`
- Swift tap/intent → `AppIntent` class inside the corresponding `.swift` file
- Dart action processing → `task_cubit.dart` or `habit_cubit.dart`

**Execution Path**:
1. Data not updating in widget → `widget_data_service.dart` (`push*Data` methods)
2. Widget display wrong → `Athar*Widget.swift` (layout/view code)
3. Widget tap not working → Swift `AppIntent` (`ToggleTaskIntent`, `CompleteHabitIntent`, `IncrementHabitIntent`)
4. App not consuming widget actions → `app.dart` `onResume` → cubit `processWidgetPendingActions()`
STOP. First selected path executes immediately.

**Do NOT search**: full feature repositories or full feature pages unless the pending-action queue is involved. Never rename `WidgetKeys` constants. Never change App Group ID.

---

## Android Widgets

**Path**: `android/app/src/main/kotlin/com/iappsnet/athar/widgets/`

Files:
- `TaskWidget.kt` + `TaskWidgetReceiver.kt`
- `HabitWidget.kt` + `HabitWidgetReceiver.kt`
- `PrayerWidget.kt` + `PrayerWidgetReceiver.kt`

**Display-only**: No AppIntent, no interactive taps, no UUID field parsed, no pending-action queue. Data flows one direction only (Flutter → SharedPreferences → Glance widget display).

**Data source**: `SharedPreferences` via `home_widget` package — same key names as iOS UserDefaults (`athar_tasks`, `athar_habits`, etc.) but no `u` (uuid) field is read.

**MANDATORY START FILE**: The specific widget file matching the symptom (`TaskWidget.kt`, `HabitWidget.kt`, or `PrayerWidget.kt`). No alternative entry allowed.

**Execution Path**:
1. Display issue → corresponding `*Widget.kt`
2. Data not updating → `widget_data_service.dart` (`pushTaskData` / `pushHabitData` / `pushPrayerData`)
STOP. First selected path executes immediately.

**Do NOT search**: iOS widget Swift files for Android issues — the platforms share key names only, not code. Do NOT expect AppIntent or pending-action patterns in Android.
