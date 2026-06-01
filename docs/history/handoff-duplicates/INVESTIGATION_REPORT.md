# Athar Codebase Investigation Report

**Generated:** 2026-05-07  
**Branch:** main  
**Scope:** Read-only. No source files modified.

---

## A · Architecture & Conventions

### A1 · Feature Folders

All 16 folders are under `lib/features/`. Every folder follows the clean-arch
triple `data/ → domain/ → presentation/`. Entity files marked ❶ are placeholder
stubs (`// File: …`); the real model lives in `data/models/`.

| Feature | Domain layer | Data layer | Cubit | Primary entity / model (file:line) |
|---------|-------------|-----------|-------|-------------------------------------|
| **assets** | ✅ | ✅ | `AssetsCubit` | `AssetsEntity` stub `features/assets/domain/entities/assets_entity.dart` ❶ |
| **auth** | ✅ | ✅ | `AuthCubit` | `AuthEntity` stub `features/auth/domain/entities/auth_entity.dart` ❶ |
| **calendar** | ✅ | ✅ | `CalendarCubit` | `CalendarItem` (sealed) `features/calendar/domain/entities/calendar_item.dart` |
| **dhikr** | ✅ | ✅ | `DhikrCubit` | `DhikrEntity` stub `features/dhikr/domain/entities/dhikr_entity.dart` ❶ |
| **focus** | ✅ | ✅ | `FocusCubit` | `FocusEntity` stub `features/focus/domain/entities/focus_entity.dart` ❶ |
| **habits** | ✅ | ✅ | `HabitCubit` | `HabitModel` `features/habits/data/models/habit_model.dart:30` |
| **health** | ✅ (no `entities/` folder) | ✅ | `HealthCubit` | `AppointmentModel`, `MedicineModel`, `VitalSignModel` in `data/models/` |
| **home** | ✅ | ✅ | `HomeCubit`, `TimelineCubit` | `DailyItem`, `User` `features/home/domain/entities/` |
| **notifications** | ✅ | ✅ | `NotificationsCubit` | `NotificationsEntity` stub ❶ |
| **prayer** | ✅ | ✅ | `PrayerCubit` | `PrayerTime` `features/prayer/domain/entities/prayer_time.dart:18` |
| **settings** | ✅ | ✅ | `SettingsCubit`, `CategoryCubit` | `UserSettings` `features/settings/data/models/user_settings.dart:19` |
| **space** | ✅ | ✅ | `SpaceCubit`, `ListCubit`, `ModuleCubit`, `InboxCubit`, `JoinSpaceCubit`, `SpaceMembersCubit` | `SpaceEntity`, `ProjectEntity` `features/space/domain/entities/` |
| **stats** | ✅ | ✅ | `StatsCubit` | `StatsEntity` stub ❶ |
| **subscription** | ✅ | ✅ | `SubscriptionCubit` | `SubscriptionEntity`, `SubscriptionStatus` `features/subscription/domain/entities/` |
| **sync** | ✅ | ✅ | `SyncCubit` | `SyncEntity` stub ❶ |
| **task** | ✅ | ✅ | `TaskCubit` | `TaskModel` `features/task/data/models/task_model.dart:19` |

❶ = entity file is a two-line stub comment; runtime model is in `data/models/`.

---

### A2 · UserSettings

**File:** `lib/features/settings/data/models/user_settings.dart:19`  
**Persistence:** Isar only (`@collection` annotation, `Id id = Isar.autoIncrement`). Not SharedPreferences. Not Supabase (no remote sync of settings is implemented).

Full field inventory:

```
bool isDarkMode                         // dark/light theme
bool isAutoModeEnabled                  // NOT wired to ThemeMode.system (see A4)
bool isPrayerEnabled                    // master prayer toggle
bool isPrayerCardEnabled                // sub: show card
bool isPrayerNotificationsEnabled       // sub: schedule athan
bool enablePrayerReminders              // sub-sub: 15-min early reminder
bool didMigratePrayerFeatureSettings    // one-time migration flag
bool isAutoSyncEnabled
bool isBiometricEnabled
bool isHijriMode
bool isTasksKanbanView
List<TimeRange>? workPeriods, sleepPeriods, quietPeriods, familyPeriods, freePeriods
int? workCategoryId, familyCategoryId, freeCategoryId, quietCategoryId, sleepCategoryId
List<int>? workDays
double? latitude, longitude
String? cityName
int prayerTimeAdjustmentMinutes
bool isAthkarEnabled
bool isMedicationNotificationsEnabled
bool isTaskRemindersEnabled
int taskReminderMinutesBefore
bool respectQuietPeriodsForTasks
bool isAppointmentRemindersEnabled
int defaultAppointmentReminderMinutes
bool appointmentMultipleReminders
PrayerCardDisplayMode prayerCardDisplayMode   // enum: dashboardOnly|dashboardAndTasks|allPages
AthkarDisplayMode athkarDisplayMode           // enum: independent|embedded
AthkarSessionViewMode athkarSessionViewMode   // enum: list|focus
bool isHabitRemindersEnabled
DateTime? defaultHabitReminderTime
bool isAthkarRemindersEnabled
String morningAthkarTime, eveningAthkarTime, sleepAthkarTime
bool isAssetRemindersEnabled
int assetReminderDaysBefore
bool assetWarrantyReminders, assetMaintenanceReminders, assetInsuranceReminders, assetLicenseReminders
bool isProjectRemindersEnabled
int projectReminderDaysBefore, projectReminderHoursBefore
bool projectDailyReminders, projectWeeklySummary
bool sampleDataShown, sampleDataDismissed
bool hideNavOnScroll
DateTime? lastSyncAt
String? lastSyncError
```

---

### A3 · Locale Switching

| Step | File:line | Detail |
|------|-----------|--------|
| Storage | `lib/core/presentation/cubit/locale_cubit.dart:15` | `FlutterSecureStorage` key `'preferred_locale'` stores `'ar'`/`'en'`/null |
| Load | `locale_cubit.dart:20` | `loadLocale()` — called at startup in `main.dart` |
| Set | `locale_cubit.dart:29` | `setLocale(Locale?)` → writes storage → calls `_widgetDataService.pushLocaleOnly()` → emits `LocaleState` |
| Read in UI | `lib/app.dart:161` | `context.watch<LocaleCubit>().state.locale` passed to `MaterialApp.locale` |
| Widget push | `locale_cubit.dart:36` | Writes `WidgetKeys.appLocale` via `home_widget` — **but does NOT write `athar_app_locale` UserDefaults key separately** (Phase 5 bug, documented in KNOWN_PROBLEMS.md) |
| Resolution | `app.dart:175–179` | `localeResolutionCallback`: ar→ar-SA, en→en-US, other→en-US |

---

### A4 · Theme Mode Handling

`UserSettings` has **two** theme-related fields:
- `isDarkMode` (line 21) — actively wired
- `isAutoModeEnabled` (line 22) — exists but **not wired**

`MaterialApp.themeMode` source — `lib/app.dart:162–172`:
```dart
final isDark = settingsState is SettingsLoaded
    ? settingsState.settings.isDarkMode
    : false;
...
themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
```

`ThemeMode.system` is **never used**. `isAutoModeEnabled` is a dead field — stored in
Isar, shown in settings UI (presumably), but never applied to `MaterialApp`.

Theme definitions:
- `lib/core/design_system/themes/app_theme.dart` — barrel
- `lib/core/design_system/themes/athar_light_theme.dart`
- `lib/core/design_system/themes/athar_dark_theme.dart`

---

## B · Design System in Code

### B5 · lib/core/design_system/ Tree

**Tokens** (`tokens/`):
- `athar_colors.dart` — color tokens
- `athar_typography.dart` — font sizes, weights, TextStyle constants
- `athar_spacing.dart` — spacing scale
- `athar_radii.dart` — border radius scale
- `athar_shadows.dart` — shadow scale
- `athar_animations.dart` — duration/curve constants + `AnimationController` factory
- `tokens.dart` (barrel at `core/design_system/tokens.dart`)

**Atoms** (`atoms/`):
- `buttons/app_button.dart`
- `icons/app_icons.dart`
- `inputs/app_text_field.dart`
- `text/flex_text.dart`

**Widgets** (`widgets/`):
- `athar_button.dart`
- `athar_card.dart`
- `athar_dialog.dart`
- `athar_display.dart`
- `athar_feedback.dart`
- `athar_selection.dart`
- `athar_text_field.dart`
- `context_aware_fab.dart`
- `icon_picker.dart`
- `liquid_glass_nav_bar.dart`
- `responsive_wrapper.dart`
- `sample_data_banner.dart`
- `time_slot_picker.dart`
- `widgets.dart` (barrel)

**Molecules** (`molecules/`):
- `bars/filter_bar.dart`
- `board/kanban_board.dart`
- `cards/info_card.dart`
- `cards/next_prayer_card.dart`
- `cards/smart_prayer_wrapper.dart`
- `headers/page_header_delegate.dart`
- `pickers/athar_date_picker.dart`
- `pickers/reminder_picker_widget.dart`
- `skeletons/athar_skeleton.dart`
- `strips/calendar_strip.dart`
- `tiles/minimal_habit_tile.dart`
- `tiles/settings_tile.dart`
- `tiles/task_tile.dart`
- `tiles/unified_timeline_tile.dart`

**Organisms** (`organisms/`):
- `app_bar/athar_app_bar.dart`
- `forms/login_form.dart`

**Templates** (`templates/`):
- `auth_template.dart`

**Themes** (`themes/`):
- `app_colors.dart`, `app_theme.dart`, `athar_dark_theme.dart`, `athar_light_theme.dart`, `athar_theme.dart`, `themes.dart`, `typography.dart`

**Extensions** (`extensions/`):
- `context_extensions.dart`
- `directionality_extensions.dart`
- `extensions.dart`

---

### B6 · Hardcoded Color Literals

**Total `Color(0x…)` occurrences outside tokens/app_colors/generated:** 211

**Top 20 offending files** (count of occurrences):

| Count | File |
|-------|------|
| 27 | `features/settings/presentation/pages/general_settings_page.dart` |
| 17 | `features/focus/presentation/pages/focus_page.dart` |
| 16 | `core/design_system/molecules/tiles/task_tile.dart` |
| 14 | `features/focus/presentation/widgets/oil_animation.dart` |
| 12 | `features/space/presentation/widgets/add_module_sheet.dart` |
| 12 | `core/design_system/molecules/cards/next_prayer_card.dart` |
| 9  | `features/home/presentation/pages/splash_page.dart` |
| 9  | `features/habits/presentation/pages/habit_page.dart` |
| 9  | `core/design_system/widgets/context_aware_fab.dart` |
| 8  | `features/home/presentation/pages/onboarding_page.dart` |
| 8  | `features/habits/presentation/widgets/athkar_card.dart` |
| 7  | `core/design_system/widgets/liquid_glass_nav_bar.dart` |
| 6  | `features/focus/presentation/widgets/fluid_engine.dart` |
| 6  | `core/services/prayer_timer_service.dart` |
| 6  | `core/services/local_notification_service.dart` |
| 6  | `core/design_system/widgets/athar_feedback.dart` |
| 6  | `core/design_system/themes/app_theme.dart` |
| 4  | `core/design_system/widgets/athar_button.dart` |
| 4  | `core/design_system/themes/athar_light_theme.dart` |
| 3  | `features/habits/presentation/widgets/habit_tile.dart` |

---

### B7 · Hardcoded User-Facing Strings

Files with Arabic or English string literals in `Text()` calls not sourced from `.arb`:

| Count | File | Examples found |
|-------|------|----------------|
| 5 | `features/focus/presentation/pages/focus_page.dart` | Focus mode labels |
| 3 | `features/subscription/presentation/widgets/pro_gate_widget.dart` | Pro gate copy |
| 3 | `features/subscription/presentation/pages/subscription_page.dart` | Paywall copy |
| 3 | `features/home/presentation/pages/home_page_responsive.dart` | Home labels |
| 3 | `features/assets/presentation/widgets/add_asset_sheet.dart` | Asset form labels |
| 2 | `features/space/presentation/pages/inbox_page.dart` | Inbox labels |
| 1 | `features/space/presentation/widgets/pending_invitations_widget.dart` | Invite text |
| 1 | `features/space/presentation/pages/space_members_page.dart` | Members label |
| 1 | `features/settings/presentation/pages/settings_page.dart` | Setting label |
| 1 | `features/dhikr/presentation/pages/dhikr_page.dart` | Dhikr label |
| 1 | `features/auth/presentation/pages/auth_page.dart` | Auth label |

Notable hardcoded Arabic literal in Dart (not in ARB):
- `features/habits/presentation/cubit/habit_cubit.dart:321` — `"أذكار ما بعد الصلاة"` (habit title created in code)

---

### B8 · AppText Styles (AtharTypography)

Source: `lib/core/design_system/tokens/athar_typography.dart`

| Style name | Size | Weight | Usage |
|------------|------|--------|-------|
| `displayLarge` | 48px | Bold | Hero display |
| `displayMedium` | 40px | Bold | Large display |
| `displaySmall` | 32px | Bold | Display |
| `headlineLarge` | 28px | SemiBold | Section headings |
| `headlineMedium` | 24px | SemiBold | Card headings |
| `headlineSmall` | 20px | SemiBold | Sub-headings |
| `titleLarge` | 18px | SemiBold | List section titles |
| `titleMedium` | 16px | SemiBold | Card titles |
| `titleSmall` | 14px | SemiBold | Small titles |
| `bodyLarge` | 16px | Regular | Main body text |
| `bodyMedium` | 14px | Regular | Secondary body |
| `bodySmall` | 12px | Regular | Captions/meta |
| `labelLarge` | 14px | Medium | Form labels |
| `labelMedium` | 12px | Medium | Small labels |
| `labelSmall` | 10px | Medium | Micro labels |
| `button` | 16px | SemiBold | Primary buttons |
| `buttonSmall` | 14px | SemiBold | Small buttons |
| `buttonLarge` | 18px | SemiBold | Large buttons |
| `input` | 16px | Regular | Input fields |
| `placeholder` | 16px | Regular | Placeholder text |
| `hint` | 14px | Regular | Hint text |
| `helper` | 12px | Regular | Helper/error text |
| `error` | 12px | Regular | Error messages |
| `link` | 16px | Medium | Hyperlinks |
| `linkSmall` | 14px | Medium | Small links |
| `caption` | 12px | Regular | Image captions |
| `overline` | 10px | Medium | Uppercase labels |
| `numberLarge` | 32px | Bold | Counters, timers |
| `numberMedium` | 24px | SemiBold | Counters |
| `numberSmall` | 18px | SemiBold | Small numbers |
| `badge` | 10px | SemiBold | Notification badges |
| `chip` | 12px | Medium | Chip labels |
| `tab` | 14px | SemiBold | Tab bar labels |
| `appBarTitle` | 18px | SemiBold | AppBar titles |
| `dialogTitle` | 20px | SemiBold | Dialog headings |
| `cardTitle` | 16px | SemiBold | Card titles |
| `listItemTitle` | 16px | Medium | List item titles |
| `listItemSubtitle` | 14px | Regular | List item subtitles |
| `code` | 14px | Regular (Mono) | Code blocks |
| `quote` | 16px | Italic | Quotations |

---

## C · Feature-Specific

### C9 · Prayer Feature

**PrayerCard widget tree** (simplified):
```
SmartPrayerCardWrapper (core/design_system/molecules/cards/smart_prayer_wrapper.dart:15)
  └── BlocBuilder<SettingsCubit>           ← reads isPrayerEnabled, isPrayerCardEnabled, prayerCardDisplayMode
        └── BlocBuilder<PrayerCubit>       ← reads PrayerLoaded state
              └── NextPrayerCard           (core/design_system/molecules/cards/next_prayer_card.dart)
```

**Phase 8.1 hierarchy enforcement — two enforcers:**

1. **Widget visibility** — `smart_prayer_wrapper.dart:30–33`:
   ```dart
   if (!settings.isPrayerEnabled) return const SizedBox.shrink();      // master
   if (!settings.isPrayerCardEnabled) return const SizedBox.shrink();  // card sub
   // then checks prayerCardDisplayMode for page-type gating
   ```

2. **Notification scheduling** — `core/services/prayer_notification_scheduler.dart:35–36` (and `:209`, `:271`):
   ```dart
   if (!settings.isPrayerEnabled || !settings.isPrayerNotificationsEnabled) { ... return; }
   ```

The `enablePrayerReminders` (15-min reminder) sub-toggle is checked inside
`PrayerNotificationScheduler` separately, downstream of the guard above.

**Gap:** `isPrayerEnabled → notifications` guard also appears in
`core/services/prayer_conflict_service.dart:16`. There is no single canonical
cascade function — the hierarchy is enforced by three separate call sites.

---

### C10 · Habits Feature — Habit Entity

**Actual model:** `lib/features/habits/data/models/habit_model.dart:30`  
(The `domain/entities/habit_entity.dart` file is a 2-line stub.)

`HabitType` **already exists** as an enum:

```dart
// habit_model.dart:11
enum HabitType { regular, athkar }

// habit_model.dart:60
@Enumerated(EnumType.name)
HabitType type = HabitType.regular;
```

**Adding new types** (e.g., `HabitType.goal`) would require:
1. Extending the enum in `habit_model.dart:11`
2. Running `flutter pub run build_runner build` to regenerate `habit_model.g.dart`
3. Updating `HabitModel.fromMap()` (line 170) — it already uses `firstWhere(...orElse: () => HabitType.regular)` so unknown values fall back safely
4. Updating `habit_page.dart:705` and `:721` where `HabitType.athkar` is checked explicitly

---

### C11 · Calendar Feature — Hijri Calendar

- **Package:** `hijri: ^2.x` (in `pubspec.yaml:64` as `adhan: ^2.0.0+1` for prayer calc; `hijri` used for calendar display)
  - Actually: `hijri` package is a separate dep — used in `athar_date_picker.dart:6` (`import 'package:hijri/hijri_calendar.dart'`) and `widget_data_service.dart:8`
- **`isHijriMode`:** `UserSettings` field (bool), default `false` (Gregorian)
- **`DualCalendarWidget`** (`features/calendar/presentation/widgets/dual_calendar_widget.dart:10`):
  - Accepts `isHijriMode` prop (line 16)
  - Has an internal **toggle** (`_isGregorianPrimary`) that switches which date system is displayed
  - `didUpdateWidget` syncs from `settings.isHijriMode` (line 52–55)
  - Pressing toggle writes back `settings.isHijriMode = !_isGregorianPrimary` (line 86)
  - **Current state:** toggle-based (shows one at a time), NOT simultaneous display
  - Design spec calls for simultaneous display (both numerals in every cell) — this is a **calendar rebuild** (documented in CLAUDE.md)

- **Activity-dot data source** (`CalendarCubit.selectDate()`, `calendar_cubit.dart:36–60`):
  - Tasks: `TaskRepository.getTasksForDay(date)` → Isar
  - Appointments: `HealthRepository.getAppointmentsForDay(date)` → Isar
  - **Habits** and **prayer** completions are **NOT** included in calendar dots

---

### C12 · Tasks, Spaces, Stats

All three exist as fully implemented features:

| Feature | Cubit | Main page widget | File |
|---------|-------|-----------------|------|
| **task** | `TaskCubit` | `UnifiedTasksPage` | `features/task/presentation/pages/unified_tasks_page.dart:32` |
| **space** | `SpaceCubit` + 5 others | `SpacePage` | `features/space/presentation/pages/space_page.dart:30` |
| **stats** | `StatsCubit` | `StatisticsPage` | `features/stats/presentation/pages/stats_page.dart:17` |

**Task display note:** `UnifiedTasksPage` does not call `watchTasks()` on its local `TaskCubit`. Display is via `TimelineCubit` (Isar stream). The `TaskCubit` on `UnifiedTasksPage` is effectively empty for display purposes.

---

### C13 · Onboarding

- **File:** `lib/features/home/presentation/pages/onboarding_page.dart`
- **Step count:** **4 slides** (`_buildSlides()` at line 51 returns a list of 4 `_SlideData` objects):
  1. "Tasks & Habits / Own Your Day"
  2. "Prayer & Dhikr / Never Miss a Prayer"
  3. "Focus & Productivity / Focus on What Matters"
  4. "Get Started / Live with More Impact"
- **Persistence:** `SharedPreferences` key `'onboarding_seen'` (bool)
  - Written at `onboarding_page.dart:84` when user completes last slide
  - Read at `main.dart:106` via `OnboardingPage.hasBeenSeen()`
  - Passed as `hasSeenOnboarding` to `AtharApp`, which routes to `SplashPage` (seen) or `OnboardingPage` (not seen) at `app.dart:187–189`

---

## D · iOS Widgets + Integrations

### D14 · iOS Widget Swift Files

Three widget extension Swift files (non-Pods):

| File | Widget name | Bundle identifier |
|------|------------|-------------------|
| `ios/AtharPrayerWidget/AtharPrayerWidget.swift` | AtharPrayerWidget | (from project.pbxproj) |
| `ios/AtharTaskWidget/AtharTaskWidget.swift` | AtharTaskWidget | (from project.pbxproj) |
| `ios/AtharHabitWidget/AtharHabitWidget.swift` | AtharHabitWidget | (from project.pbxproj) |

**App Group:** `group.com.iappsnet.athar` — declared as `kGroupId` constant at line 12 of each widget file. All three access `UserDefaults(suiteName: kGroupId)`.

**WidgetKeys** (`lib/core/services/widget_data_service.dart:21–81`):

Prayer keys (v1–v6): `athar_next_prayer_name_ar`, `athar_next_prayer_name_en`,
`athar_next_prayer_time`, `athar_city_name`, `athar_next_prayer_type`,
`athar_next_prayer_timestamp`, `athar_app_locale`, `athar_last_updated_at`,
`athar_widget_data_version`, `athar_remaining_seconds`, `athar_current_date_ar`,
`athar_current_date_en`, `athar_prev_prayer_timestamp`, `athar_is_duha_time`,
`athar_is_qiyam_time`, `athar_prev_prayer_name_ar`, `athar_prev_prayer_name_en`

Task keys: `athar_tasks`, `athar_tasks_total`, `athar_tasks_done`, `athar_current_period`

Habit keys: `athar_habits`, `athar_habits_total`, `athar_habits_done`

Action keys: `athar_pending_task_actions`, `athar_pending_habit_actions`

---

### D15 · Notifications

**Package:** `flutter_local_notifications: ^21.0.0` (`pubspec.yaml:54`)

**Channels** (defined in `core/services/local_notification_service.dart`):

| Category | Channel ID | Sound |
|----------|-----------|-------|
| `prayer` | `prayer_channel` | Android: `RawResourceAndroidNotificationSound('adhan')` / iOS: `'adhan.caf'` |
| `medication` | `medication_channel` | Default system sound |
| `task` | `task_channel` | Default system sound |
| `habit` | `habit_channel` | Default system sound |
| `zone` | `zone_channel` | Default system sound |
| `general` | `general_channel` | Default system sound |

Prayer notifications use `fullScreenIntent: true` on Android (line 690).

**Adhan audio:** The `adhan` Dart package (`pubspec.yaml:64`, version `^2.0.0+1`) is used
**only for prayer time calculation** (it's a Dart port of the Adhan JS library). The
audio file `adhan.caf` (iOS) / `adhan` raw resource (Android) referenced in the
notification service **does not exist** in the repo — `assets/` contains only fonts
and `app_icon.png`, and no `.caf` file was found in `ios/Runner/`. **The prayer
notification sound will silently fall back to the system default at runtime.**  
This is a **known gap** that needs an actual adhan audio file bundled into the app.

---

### D16 · Haptics

| File | Call | Trigger |
|------|------|---------|
| `core/design_system/atoms/buttons/app_button.dart:396` | `HapticFeedback.lightImpact()` | Button press |
| `core/design_system/atoms/buttons/app_button.dart:526` | `HapticFeedback.lightImpact()` | Button variant press |
| `core/design_system/atoms/buttons/app_button.dart:599` | `HapticFeedback.mediumImpact()` | Button hold |
| `core/design_system/atoms/buttons/app_button.dart:619` | `HapticFeedback.mediumImpact()` | Button long-press |
| `core/design_system/widgets/liquid_glass_nav_bar.dart:285` | `HapticFeedback.lightImpact()` | Nav tab tap |
| `core/design_system/widgets/liquid_glass_nav_bar.dart:385` | `HapticFeedback.mediumImpact()` | Nav FAB tap |
| `core/design_system/widgets/context_aware_fab.dart:284` | `HapticFeedback.lightImpact()` | FAB tap |
| `features/home/presentation/pages/main_page.dart:104` | `HapticFeedback.selectionClick()` | Page swipe |
| `features/focus/presentation/cubit/focus_cubit.dart:230` | `HapticFeedback.heavyImpact()` | Focus session complete |

A second, commented-out block in `app_button.dart` (lines 726–1323) also has
`HapticFeedback` calls — these are dead code from a previous variant class.

---

### D17 · Accessibility — Reduce Motion / Disable Animations

**No checks found** in the Dart codebase for:
- `MediaQuery.of(context).disableAnimations`
- `AccessibilityFeatures.reduceMotion`
- Any pattern checking platform accessibility settings

All `AnimationController` instances (in `app_button.dart`, `liquid_glass_nav_bar.dart`,
`athar_button.dart`, `athar_feedback.dart`, `sample_data_banner.dart`,
`splash_page.dart`) fire unconditionally. There is no Reduce Motion path.

---

## E · Open Questions for the Designer

These are gaps the code clearly has but that no design spec addresses:

1. **Adhan sound:** Which audio file should be bundled? `.caf` for iOS, raw for
   Android? One track or multiple? User-selectable? Currently the notification
   category expects `adhan.caf` / `adhan` but no file exists.

2. **`isAutoModeEnabled` (system theme):** The field exists in UserSettings and
   is presumably exposed in settings UI, but `ThemeMode.system` is never
   applied. Does the designer want a "Follow System" option? If yes, `app.dart:172`
   must be updated.

3. **Calendar activity dots:** Habits and prayer completions are NOT in the
   calendar dot data. Is this intentional? The `CalendarCubit` only fetches
   tasks and health appointments.

4. **Simultaneous Hijri/Gregorian in calendar:** `DualCalendarWidget` is a
   toggle (one mode at a time). Design spec requires both numerals in every
   cell. The rebuild scope (DualDate VO, CalendarCell, DualMonthSwitcher) is
   substantial — needs formal sign-off.

5. **Error states in every feature:** Cubit error states carry a `message` string
   (usually from an exception `.toString()`). No design spec exists for
   feature-level error screens vs. inline snackbars vs. retry dialogs. The
   current code mixes all three approaches.

6. **Loading skeleton coverage:** `AtharSkeleton` exists but most features show
   a plain `CircularProgressIndicator` during loading. No spec defines which
   loading pattern applies where.

7. **Retry policies:** No documented policy for network retry delays, max
   retries, or offline queuing beyond the existing Supabase/Isar sync flow.

8. **Haptic intensity levels:** The code uses `lightImpact`, `mediumImpact`,
   `heavyImpact`, and `selectionClick` — but no design spec defines which
   interaction maps to which intensity.

9. **Subscription paywall copy:** `subscription_page.dart` and
   `pro_gate_widget.dart` contain hardcoded English strings not in ARBs.
   These need Arabic translations and design sign-off on the paywall layout.

10. **`HabitType` in the widget:** The iOS habit widget only shows `HabitType.regular`
    habits. What should it show if a user's only habits are `athkar`? Empty state
    needs a spec.

---

## F · Risks

### F19 · Specific Change Risks

#### New `Habit.type` field
**Risk: LOW.** `HabitType` enum already exists at `habit_model.dart:11` with
values `regular` and `athkar`. No schema change required to add a new value.
**Caution:** Adding a new enum value (e.g., `goal`) requires:
- `build_runner` rebuild (regenerates `habit_model.g.dart`)
- All `switch` statements on `HabitType` that lack a `default` clause will cause
  analyzer errors — check `habit_page.dart:705,721` and `habit_repository_impl.dart:265`
- The iOS widget Swift code reads the `type` field from JSON; if it does not
  handle the new string value it will silently skip those habits

#### `AdaptiveShell` rename
**Risk: NONE found.** The identifier `AdaptiveShell` does not exist anywhere in
the codebase. This is a proposed new name; renaming it later would require
checking all import sites. No breakage risk currently.

#### `prayerCardVariant` in UserSettings
**Risk: HIGH.** Adding any new field to `UserSettings` (`@collection`, Isar)
requires:
1. Adding the field with a default value
2. Running `build_runner` to regenerate `user_settings.g.dart`
3. Isar **does** handle adding new fields gracefully (existing records get the
   default) — but the regeneration step is mandatory before any PR
4. SettingsState `Equatable` props list in
   `features/settings/presentation/cubit/settings_state.dart:30–31` must be
   updated if the new field needs to trigger UI rebuilds

#### `themeMode` persistence (wiring `isAutoModeEnabled`)
**Risk: LOW.** The field already exists in UserSettings. The only change needed
is in `app.dart:163–172` — replace `isDark ? ThemeMode.dark : ThemeMode.light`
with a three-way check. No Isar migration required. **Verify** that the settings
UI toggle for `isAutoModeEnabled` correctly disables the manual dark toggle,
because the current UI state is unknown from code inspection alone.

#### 88-file color migration
**Risk: HIGH operational risk, LOW technical risk.** The token system is already
in place (`AtharColors`, `AtharSpacing`, etc.). The migration is mechanical —
replace `Color(0xFF…)` literals with token references. Risks:
- 211 color occurrences across at minimum 20+ files; a file-by-file PR series is
  needed to avoid massive review burden
- Focus animations (`oil_animation.dart`, `fluid_engine.dart`) use procedurally
  generated colors for visual effects — these should NOT be migrated to flat
  tokens without design review
- `app_theme.dart` and `athar_light_theme.dart` have theme-level color
  definitions that may conflict with token values if both exist simultaneously
  during migration
- Any file touched requires re-running `flutter analyze` and visual testing

---

## 5 Questions Still Unanswerable from Code Alone

1. **Is the adhan audio file meant to be bundled or downloaded?**  
   The notification service references `adhan.caf` / `adhan` but no file exists
   in the repo. It is impossible to tell from code whether this was intentionally
   removed, never added, or expected to be present in a build step.

2. **What does the settings UI look like for `isAutoModeEnabled`?**  
   The field exists in UserSettings and is persisted, but the settings page was
   not traced to confirm whether a toggle exists, whether it visually disables
   the manual dark mode toggle, and whether any user-facing label exists for it.

3. **Are all enum values in `HabitType`, `PrayerCardDisplayMode`, `AthkarDisplayMode`,
   `AthkarSessionViewMode` exposed to the user via UI, or are some backend-only?**  
   The code stores these in Isar and the models reference them, but the settings
   UI was not read in full to confirm which values are user-selectable.

4. **What is the Supabase schema for `habits` (particularly the `type` column)?**  
   `HabitModel.toMap()` serializes `type: type.name` and syncs to Supabase.
   If the Supabase `habits` table has a check constraint on the `type` column,
   adding new `HabitType` values will fail silently at sync time. The schema
   cannot be read from the Flutter code.

5. **Does the `AdaptiveShell` concept imply a wrapper widget that replaces
   `MainPage`, or a new route/scaffold type?**  
   The identifier does not exist in the codebase. Without a design spec or
   implementation plan, the scope of an `AdaptiveShell` rename/introduction
   (and which files would break) cannot be assessed.
