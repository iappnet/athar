# Current Flutter UI Audit — Athar

_Phase 2 output. Generated: 2026-05-06. Evidence-based only._

**Flutter project:** `/Users/itech/Development/new_projects/athar/`
**Files inspected:** feature directory listings, key token files, CLAUDE.md, BUGFIX_PHASE_STATUS.md, manifest.json, selected Dart files

---

## 1. App Shell / Navigation

**Files:** `liquid_glass_nav_bar.dart`, `main_page.dart`, `adaptive_scaffold.dart`

- **Current style:** LiquidGlassNavBar — bottom navigation with 4 tabs + centered elevated FAB (`+` add button)
- **Components:** `AdaptiveScaffold` at `lib/core/layouts/adaptive_scaffold.dart` supports NavigationRail on tablet
- **Adaptive state:** `AdaptiveScaffold` exists but it's in `core/layouts/`, not `core/design_system/widgets/` as IPAD spec requires. Whether `main_page.dart` uses it or its own Scaffold is not confirmed without reading main_page.
- **Central NavBar add:** Critical — `+` FAB is the ONLY add entry point for tasks and habits. Page-level FABs are forbidden.
- **RTL/LTR:** Tab order may need RTL review
- **iPad:** NavigationRail branch exists in AdaptiveScaffold but per IPAD spec, a new `AdaptiveShell` widget is required
- **Coverage by design system:** Partially — REDESIGN_AUDIT §11 targets `liquid_glass_nav_bar.dart` for backdrop filter, 5-destination update
- **Risk:** Central NavBar `+` dispatch logic in `main_page.dart` — redesign must not break it

---

## 2. Dashboard

**Files:** `dashboard_page.dart`, `home_page.dart`, `home_page_responsive.dart`, `home_header.dart`, `daily_timeline_widget.dart`, `smart_habits_strip.dart`, `my_day_list.dart`

- **Current style:** Single-column scroll. Uses `home_page.dart`, `home_page_responsive.dart`, and `dashboard_page.dart` — 3 duplicate/overlapping files
- **Components:** Home header (greeting), prayer card (`SmartPrayerCardWrapper`), smart habits strip, daily timeline, my day list
- **Prayer card integration:** `SmartPrayerCardWrapper` — checks `isPrayerEnabled` + `isPrayerCardEnabled` (Phase 8.1)
- **Data states:** Greeting driven by `DateTime.hour` (not `AtharTimeCalculator`) — **needs fixing per REDESIGN_AUDIT**
- **Localization:** Header has hardcoded Color values
- **RTL/LTR:** Extensive fixes applied (Phase 4b) but 88 files still have hardcoded Colors
- **iPad:** IPAD spec requires 2-col (portrait) and 3-col (landscape) layouts — not implemented
- **Coverage by design system:** Target is `Dashboard.jsx` — refactor (not greenfield)
- **Risk if redesigned:** Prayer card behavior (smart wrapper guard), habit strip data, timeline ordering

---

## 3. Prayer Card

**Files:** `next_prayer_card.dart`, `smart_prayer_wrapper.dart`, `prayer_body.dart`, `prayer_day_view.dart`, `prayer_week_view.dart`, `prayer_month_view.dart`

- **Current style:** Fixed night-sky gradient (`prayerCardGradient: #1E293B → #0F172A`), shows next prayer name + countdown
- **Components:** `NextPrayerCard`, `SmartPrayerCardWrapper` (visibility guard)
- **Visibility logic:** `isPrayerEnabled` (master) + `isPrayerCardEnabled` (sub) + `prayerCardDisplayMode` (location) — Phase 8.1
- **Data states:** PrayerLoaded / PrayerLoading / PrayerInitial / PrayerError all handled
- **Missing per design spec:**
  - Compact (next-only) vs expanded (all-5) variants with persisted user preference
  - H:MM:SS countdown in JetBrains Mono (font not confirmed)
  - Sunrise/sunset arc visualization
  - Progress bar
  - Hijri-prominent date display
  - All-5-prayers strip with past/next visual states
- **RTL:** Arabic-Indic numeral formatting not confirmed as systematic
- **Risk:** Any change to `SmartPrayerCardWrapper` could break Phase 8.1 prayer toggle architecture

---

## 4. Prayer Screens

**Files:** `prayer_page.dart`, `prayer_details_page.dart`, `prayer_body.dart`, `prayer_day_view.dart`, `prayer_week_view.dart`, `prayer_month_view.dart`

- **Current style:** Unknown without reading files
- **Components:** Day/week/month views of prayer times
- **Data states:** Driven by `PrayerCubit`
- **Coverage by design system:** Target exists in Dashboard.jsx section + REDESIGN_AUDIT §2
- **Risk:** Prayer scheduler architecture must survive any visual refactor

---

## 5. Prayer Settings / Toggles / Notifications

**Files:** `general_settings_page.dart`, `settings_cubit.dart`, `user_settings.dart`

- **Current state (Phase 8.1):**
  - Master toggle: Prayer Times (`isPrayerEnabled`)
    - Sub: Prayer Card (`isPrayerCardEnabled`)
    - Sub: Prayer Notifications (`isPrayerNotificationsEnabled`)
      - Sub-sub: 15-min Reminder (`enablePrayerReminders`)
      - Location navigation (when master ON)
- **Architecture:** Recently refined with migration guard (`didMigratePrayerFeatureSettings`)
- **Risk:** VERY HIGH — do not refactor prayer toggle hierarchy without deep understanding of Phase 6/8/8.1 fixes

---

## 6. Tasks

**Files:** `task_page.dart`, `unified_tasks_page.dart`, `task_details_page.dart`, `unified_add_sheet.dart`, `add_task_sheet.dart`, `task_tile.dart`

- **Current style:** List view with filter chips (timeline-based via `TimelineCubit`)
- **3 TaskCubit instances:** global, MainPage-local, UnifiedTasksPage-local (effectively empty, display via TimelineCubit)
- **Add flow:** `unified_add_sheet.dart` — async save, `_isSaving` guard (Phase 1/3 fix)
- **Components:** `task_tile.dart` (molecules), bulk actions bar, attachments widget, Kanban board, recurrence picker
- **Data states:** Loading, loaded (timeline), error
- **iPad:** IPAD spec requires master-detail layout — not implemented
- **Missing per design spec:**
  - Quick-add row at top
  - Smart-time chips parsed via `SmartTimeParser`
  - Visual hover states
- **Risk if redesigned:** Must not create page-level FAB. Must not break central NavBar add dispatch. `TimelineCubit` must remain the display source.

---

## 7. Habits

**Files:** `habit_page.dart`, `habit_details_page.dart`, `habit_tile.dart`, `habit_heatmap.dart`, `habit_section_list.dart`, `habit_form_dialog.dart`

- **Current style:** List of habit tiles, section-grouped
- **Add flow:** `habit_form_dialog.dart` — async save, `_isSaving` guard (Phase 2 fix)
- **Components:** `minimal_habit_tile.dart` (molecules), `habit_heatmap.dart`, `habit_section_list.dart`
- **Athkar:** Separate rendering path via `athkar_card.dart` + `athkar_session_sheet.dart`
- **iOS widget bridge:** Phase 5 — `pushHabitData()` includes both regular + Athkar habits with `tp` field
- **Data states:** HabitLoaded / HabitError / HabitFreeLimitReached
- **iPad:** IPAD spec requires 2-col grid + permanent right analytics pane — not implemented
- **Missing per design spec:**
  - Streak ring visual (not confirmed)
  - Grid layout (currently list)
  - `AppTypography.numericMono` for streak chip numbers
- **Athkar gating:** Conditional on `isAthkarEnabled` setting

---

## 8. Athkar

**Files:** `athkar_card.dart`, `athkar_session_sheet.dart` (in habits/presentation/widgets/)

- **Current style:** Card + bottom sheet for dhikr session
- **Distinct from habits:** `HabitType.athkar` in Isar model, fixed items, counter-based
- **`lib/features/dhikr/`:** Exists but internal structure not audited
- **Interaction:** Counter tap (haptic feedback not confirmed)
- **Missing per design spec:**
  - No explicit Athkar spec in design system (appears only as "Dhikr ribbon / sheet" in REDESIGN_AUDIT)
  - Relationship between `dhikr/` feature and habits presentation athkar is unclear — possibly overlapping

---

## 9. Calendar

**Files:** `calendar_page.dart`, `calendar_body.dart`, `dual_calendar_widget.dart`

- **Current style:** Calendar with Hijri/Gregorian toggle (not simultaneous)
- **Components:** `dual_calendar_widget.dart` — toggle between Hijri and Gregorian view
- **`package:hijri`:** In pubspec (v3.0.0), `HijriService` exists
- **Data states:** Driven by `CalendarCubit`
- **Activity dots:** Source unclear — calendar likely doesn't fan-in from tasks/habits/prayer
- **Critical gap:** Current toggle behavior is **fundamentally different** from design spec (simultaneous display). This is a near-complete rebuild of the calendar grid component.
- **iPad:** IPAD spec requires month view (left) + day timeline (right) — not implemented

---

## 10. Focus

**Files:** `focus_page.dart`, `fluid_engine.dart`, `focus_body.dart`, `liquid_background.dart`, `liquid_physics.dart`, `oil_animation.dart`

- **Current style:** Oil animation timer with fluid background
- **`oil_animation.dart`:** Has `sensors_plus` import — gyroscope coupling partially implemented
- **`liquid_physics.dart`:** Physics simulation exists
- **Assessment:** Focus screen has significant existing oil animation work. Full audit against FOCUS_OIL_SPEC.md spec needed:
  - Is fill = `1 - (timeRemaining/sessionDuration)` implemented?
  - Are 4 time-pressure tiers (100–66%, 66–33%, 33–10%, <10%) implemented?
  - Dynamic Island halo? Drip column? Surface meniscus? Wall film?
  - Reduce Motion fallback?
- **`sensors_plus`:** In pubspec (found via oil_animation.dart import) ✅
- **Missing per spec:** Reduce Motion flag in SettingsCubit, Disable Gyroscope toggle, Dynamic Island vs notch detection
- **Risk if redesigned:** Complex physics/animation code — regression risk on 60fps target

---

## 11. Stats

**Files:** `stats_page.dart`, `statistics_card.dart`, `stats_weekly_focus_chart.dart`

- **Current style:** Mostly stub — limited live data
- **`stats_cubit.dart`:** Essentially empty per REDESIGN_AUDIT
- **`IStatsRepository`:** Nearly empty
- **Charts:** `fl_chart` package available
- **Assessment:** Stats is not just a visual refactor — it requires a data layer build:
  - `StatsRepository` methods aggregating from tasks, habits, focus, prayer
  - `StatsLoaded(period, KPIs)` state
- **iPad:** 2-col chart grid (portrait), 3-col with sparklines (landscape) — not implemented

---

## 12. Sync

**Files:** sync feature — no UI, service layer only

- `SyncCubit` + `SyncService` — background sync
- `lastSyncAt`, `lastSyncError` in UserSettings
- `SyncStatusCard` not confirmed as a widget
- No sync status screen found

---

## 13. Subscription / Paywall / Free Limits

**Files:** `lib/features/subscription/presentation/`

- `SubscriptionCubit` — `@lazySingleton` (Phase 1 fix — critical)
- Free limits: 20 tasks, 5 habits
- Entitlements: `spaces_pro`, `sync_pro`, `health_pack`, `assets_pack`
- Paywall page exists but visual not audited
- Task/Habit cubits emit `TaskFreeLimitReached` / `HabitFreeLimitReached` states

---

## 14. Settings

**Files:** `settings_page.dart`, `general_settings_page.dart`, `location_settings_page.dart`, `smart_zones_page.dart`

- **Current style:** List pages with section headers, switch tiles, nav tiles
- **Structure (Phase 8.1):** Prayer master → (card, notifications → reminder), location
- **Components:** `settings_tile.dart` (molecules)
- **Missing per design spec:**
  - "Modules" section (toggle prayer, dhikr, habits, health, assets, spaces) as a unified block — currently individual fields
  - `ModuleFlags` object — not implemented; individual booleans instead
  - iPad two-pane layout — not implemented

---

## 15. Health

**Files:** `lib/features/health/presentation/` (pages + widgets + cubit)

- Medicine tracking, appointment tracking
- Add flows fixed (Phase 3) — async save guards
- Not audited in detail

---

## 16. Spaces / Projects / Modules

**Files:** `lib/features/space/presentation/` (cubit, pages, widgets)

- Rich data layer: `space_model.dart`, `space_member_model.dart`, `module_model.dart`, `module_permission_model.dart`, `invitation_model.dart`
- Presentation not audited in detail
- IAM: `PermissionService`, `SpaceRole` (owner/admin/member), `DelegationMode`
- iPad: 3-column permission matrix — not implemented

---

## 17. iOS Home Screen Widgets

**Files:** `ios/AtharPrayerWidget/`, `ios/AtharTaskWidget/AtharTaskWidget.swift`, `ios/AtharHabitWidget/AtharHabitWidget.swift`

### Prayer Widget
- `AtharPrayerWidget.swift` — shows next prayer + countdown
- Phase 8.1 does not affect widget directly (isPrayerCardEnabled is app UI only, widget has own data)

### Task Widget
- Phase 4: `resolvedLang()` fixed — uses `Locale.current.language.languageCode?.identifier`
- Small widget: short labels "Tasks"/"المهام", `.lineLimit(1)` to prevent badge clipping
- Medium/large: full labels

### Habit Widget
- Phase 4: Same locale fix
- Phase 5: Athkar habits shown as read-only rows, `tp` field (`a`/`r`)
- `WHabit.isAthkar` computed property, `athkarRow()` renders without Button(intent:...)
- Regular habits still show interactive toggle button

---

## 18. Forms / Bottom Sheets

### Add Task (`unified_add_sheet.dart`, `add_task_sheet.dart`)
- Phase 1/3 fixed: async, `_isSaving` guard, state-check on error
- Smart-time chip parsing not confirmed

### Add Habit (`habit_form_dialog.dart`)
- Phase 2 fixed: async save, `_isSaving` guard, only pops on `HabitLoaded`

### Add Medicine / Appointment
- Phase 3 fixed: async, state checks

### Create Space / Module
- Phase 3 fixed: async, `ctx.mounted` guard

---

## 19. Empty States

- No dedicated `EmptyState` widget confirmed
- Some screens likely have inline empty state text
- iPad master-detail detail pane empty state required per IPAD spec but not implemented

---

## 20. Error States

- Inline error widgets confirmed in prayer card (`Container` with `cs.errorContainer`)
- Cubit error states exist (`TaskError`, `HabitError`, `HabitFreeLimitReached`, etc.)
- No systematic `ErrorState` design widget found

---

## 21. Loading States

- `athar_skeleton.dart` exists
- Prayer card uses `CircularProgressIndicator` directly (not skeleton)
- Not confirmed as systematically used across all screens

---

## 22. Localization Behavior

- ARB files exist for AR and EN
- `LocaleCubit` with `FlutterSecureStorage`
- `MaterialApp.localeResolutionCallback` wired
- **Open bug (KNOWN_PROBLEMS P1):** `LocaleCubit.setLocale()` does not update `athar_app_locale` in UserDefaults → iOS widget locale not updated on language change

---

## 23. RTL / LTR Behavior

- Phase 4b applied `EdgeInsetsDirectional` fixes
- 88 files still have hardcoded `Color(0x...)` (many may also have directional issues)
- `directionality_extensions.dart` exists
- Calendar dual-display spec requires primary/secondary numeral swap in RTL — not implemented

---

## UI Coverage Summary

| Surface | Exists | Design Spec Covered | Needs New Build |
|---|---|---|---|
| App shell / nav | ✅ | 🔶 Partial | Navigation Rail branch |
| Dashboard | ✅ | 🔶 Partial | iPad layout, duplicate cleanup |
| Prayer card | ✅ | 🔶 Partial | Compact/expanded, arc, progress bar |
| Prayer screens | ✅ | 🔶 Partial | Visual refresh |
| Prayer settings | ✅ | ✅ Covered | (Phase 8.1 done) |
| Tasks | ✅ | 🔶 Partial | iPad master-detail, smart-time chips |
| Habits | ✅ | 🔶 Partial | Grid view, streak ring, iPad layout |
| Athkar | ✅ | 🔶 Partial | Spec unclear |
| Calendar | ✅ | ❌ Not covered | Dual-display rebuild required |
| Focus | ✅ | 🔶 Partial | Full spec audit needed |
| Stats | ⚠️ Stub | ❌ Not covered | Data layer + visual build |
| Sync | ✅ (service) | ❓ Unclear | Status card |
| Subscription | ✅ | ❓ Unclear | Visual audit needed |
| Settings | ✅ | 🔶 Partial | iPad two-pane, Modules block |
| Health | ✅ | 🔶 Partial | Visual refresh |
| Spaces | ✅ | 🔶 Partial | iPad 3-col permission matrix |
| Onboarding | ✅ (in home/) | 🔶 Partial | Move to dedicated feature folder |
| iOS Widgets | ✅ | 🔶 Partial | Widget design spec missing |
| Empty states | ❌ | ❌ Not covered | Build EmptyState widget |
| Error states | ⚠️ Inline | ❌ Not covered | Build ErrorState widget |
| Loading states | ⚠️ Partial | 🔶 Partial | Systematic usage |
