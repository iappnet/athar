# Required UIKit Components — Athar

_Phase 4 output. Generated: 2026-05-06. Audit-only — no Dart code._

For each component: whether it exists, what must be created/extended, and implementation risk.

---

## 1. AppScaffold / AdaptiveShell

**Purpose:** Replace bare `Scaffold` + `LiquidGlassNavBar` pattern with responsive container picking chrome by width.

**Variants:**
- Phone (`shortestSide < 600`): Bottom LiquidGlassNavBar
- iPad portrait (`600–839`): Compact NavigationRail (72pt, icons only)
- iPad landscape (`840–1199`): Expanded NavigationRail (240pt, labels + active highlight)
- iPad landscape full (`≥1200`): Expanded rail + sidebar (3-column)

**States:** Normal, with FAB, with drawer

**AR/EN:** Rail label text from ARB files

**RTL/LTR:** Rail goes on leading edge; Flutter's `Row` + inherited `Directionality` handles auto-flip

**Data requirements:** `currentIndex`, `List<NavDestination>`, `onDestinationSelected`, `body`, `fab`

**Screens using it:** ALL screens

**Exists in design system:** Specified in IPAD_OPTIMIZATION.md §Layer 1

**Must be created/extended:** `AdaptiveScaffold` at `lib/core/layouts/adaptive_scaffold.dart` is partial. A new `AdaptiveShell` at `lib/core/design_system/widgets/adaptive_shell.dart` is called for by spec. **Architectural decision needed:** merge or alias.

**Implementation risk:** HIGH — affects every screen. Must use `LayoutBuilder` not `MediaQuery.size.width`. FAB (`+`) must move to rail `leading:` on tablet.

---

## 2. AppNavigationShell

**Purpose:** Wraps the adaptive shell with app-level cubit providers and lifecycle management.

**Variants:** Phone shell, tablet shell

**States:** Loading cubits, ready

**Exists in design system:** Implied by SKILL.md §2.7

**Must be created:** Currently `main_page.dart` acts as this — should be formalized

**Implementation risk:** MEDIUM — any change to main_page.dart risks breaking central NavBar add dispatch

---

## 3. DashboardCard

**Purpose:** Generic card container for dashboard sections (prayer, tasks strip, habits strip).

**Variants:** With title, without title; with action button, without; compact, expanded

**States:** Normal, loading (skeleton), error

**AR/EN:** Title strings from ARB

**RTL/LTR:** `EdgeInsetsDirectional`, text alignment from `Directionality`

**Exists in design system:** Implied via `comp-cards.html` (not read)

**Must be created/extended:** `athar_card.dart` exists — needs design spec compliance audit

**Implementation risk:** LOW

---

## 4. PrayerCard

**Purpose:** Displays next prayer with live countdown, all-5 strip, Hijri date, sunrise/sunset arc.

**Variants:**
- Compact: next prayer only, countdown, Hijri date
- Expanded: all 5 prayers with past/next states, arc, progress bar

**States:** Loading, loaded (compact), loaded (expanded), error

**AR/EN:** Prayer names in Arabic; time format respects locale

**RTL/LTR:** Hijri date position; Arabic-Indic numeral option

**Data requirements:** `nextPrayerName`, `timeUntilNext`, `todayPrayers`, `hijriDate`, `sunrise`, `sunset`

**Screens using it:** Dashboard

**Exists in design system:** Specified in `preview/comp-prayer-card.html` (not read) + `Dashboard.jsx` section

**Must be created/extended:** `next_prayer_card.dart` exists — needs compact/expanded variants, arc, progress bar, mono countdown font

**Implementation risk:** HIGH — must not break `SmartPrayerCardWrapper` toggle guards (Phase 8.1)

---

## 5. PrayerTimeRow

**Purpose:** Single row in the all-5-prayers strip showing prayer name, time, and past/current/next state.

**Variants:** Past, current (highlighted), next, future

**States:** Default, loading, athan playing

**AR/EN:** Prayer name in locale font; time in tabular mono

**RTL/LTR:** Auto-flip

**Exists in design system:** In `prayer_day_view.dart` implicitly

**Must be created/extended:** Current `prayer_day_view.dart` — extract `PrayerTimeRow` as standalone molecule

**Implementation risk:** LOW

---

## 6. PrayerToggleTile

**Purpose:** Settings tile for prayer-related toggles with proper visual hierarchy (master → sub → sub-sub).

**Variants:** Master toggle, sub-toggle (indented), sub-sub-toggle (more indented)

**States:** On, off, disabled (parent off)

**AR/EN:** All strings from ARB

**RTL/LTR:** Auto-flip

**Exists in design system:** Currently using generic `_SwitchTile` in `general_settings_page.dart`

**Must be created/extended:** Create dedicated `PrayerToggleTile` with visual hierarchy indentation

**Implementation risk:** MEDIUM — must honor Phase 8.1 toggle hierarchy

---

## 7. TaskCard / TaskTile

**Purpose:** Displays a task with title, due date/time, priority, space, completion state.

**Variants:** List tile (current), grid card, compact row, completed (strikethrough)

**States:** Default, selected, completed, overdue, loading, hover (iPad)

**AR/EN:** Smart-time display ("بعد العصر", "Tomorrow morning")

**RTL/LTR:** Auto-flip; icon mirroring for direction indicators

**Data requirements:** Task entity, space info, priority, due time, completion state

**Screens using it:** Task list, Dashboard, Calendar

**Exists in design system:** `molecules/tiles/task_tile.dart` exists

**Must be created/extended:** Add hover state, grid card variant, swipe-to-complete, iPad context menu

**Implementation risk:** MEDIUM — task cubit instance multiplicity (3 cubits)

---

## 8. HabitCard / HabitTile

**Purpose:** Displays a habit with streak, completion state, progress indicator.

**Variants:** List tile (current), grid tile (new), streak ring display, count-based vs check-based

**States:** Default, completed, streak milestone, hover (iPad)

**AR/EN:** Habit name, streak count in numericMono

**RTL/LTR:** Auto-flip

**Data requirements:** HabitModel, current streak, today's completion, target vs current count

**Screens using it:** Habit page, Dashboard habits strip, iOS widget

**Exists in design system:** `molecules/tiles/minimal_habit_tile.dart` exists

**Must be created/extended:** Grid variant, streak ring visual, numericMono font, hover state

**Implementation risk:** MEDIUM

---

## 9. AthkarProgressCard

**Purpose:** Shows dhikr session (morning/evening/sleep) with counter progress, individual item rows.

**Variants:** Card summary, expanded session, individual item row

**States:** Default, in-progress, complete, counter increment animation

**AR/EN:** Dhikr text is always Arabic; UI labels in locale

**RTL/LTR:** Arabic text always RTL regardless of locale

**Data requirements:** Athkar session, items with count/target, last completed time

**Screens using it:** Habits page (athkar_card.dart), dhikr bottom sheet

**Exists in design system:** Not explicitly specified in design system docs

**Must be created/extended:** `athkar_card.dart` exists — needs formal design spec before modification

**Implementation risk:** HIGH — Athkar is not a habit clone; spec must come from designer first

---

## 10. StatsMetricCard

**Purpose:** Shows a single KPI metric (value, label, trend arrow, sparkline).

**Variants:** Large (primary KPI), medium (secondary), compact (grid item)

**States:** Loading (skeleton), loaded, error, empty

**AR/EN:** Metric label in locale; value in JetBrains Mono tabular

**RTL/LTR:** Auto-flip; trend arrows mirror

**Data requirements:** `metricValue`, `metricLabel`, `trend`, `period`

**Screens using it:** Stats page

**Exists in design system:** In `StatsScreen.jsx` (not read)

**Must be created/extended:** `statistics_card.dart` exists — likely needs rebuild for live data + design spec

**Implementation risk:** HIGH — data layer (StatsRepository) must be built first

---

## 11. ChartCard

**Purpose:** Wraps a chart widget with title, period selector, and contextual data.

**Variants:** Bar chart, line chart, heatmap, pie/donut

**States:** Loading, loaded, empty, error

**AR/EN:** Chart labels in locale; values in mono font

**RTL/LTR:** Axis orientation flips in RTL (`fl_chart` supports this)

**Data requirements:** Chart data from `StatsRepository`

**Screens using it:** Stats page, potentially dashboard

**Exists in design system:** In `StatsScreen.jsx` (not read)

**Must be created/extended:** `stats_weekly_focus_chart.dart` exists — generalize as `ChartCard`

**Implementation risk:** HIGH — data layer dependency

---

## 12. CalendarDayCell

**Purpose:** Displays both Gregorian and Hijri numerals simultaneously in a calendar grid cell.

**Variants:** Normal, today, selected, first-of-Hijri-month (hairline + month name), activity dots

**States:** Default, today (forest tint), selected (forest solid), first-of-Hijri-month

**AR/EN:** Gregorian numeral (EN context), Hijri numeral in Arabic-Indic digits

**RTL/LTR:** In RTL, Hijri numeral is primary (top-right), Gregorian secondary (bottom-left)

**Data requirements:** `DualDate` value object (Gregorian + Hijri + isFirstOfHijriMonth), activity dots array

**Screens using it:** Calendar page

**Exists in design system:** Specified in CALENDAR_FOCUS_REDESIGN.md §A

**Must be created:** Does NOT exist — net-new widget required

**Implementation risk:** HIGH — fundamental calendar behavior change

---

## 13. DualCalendarHeader

**Purpose:** Two-row month switcher: Gregorian pills (top) + Hijri pills (bottom), scrolling independently.

**Variants:** Month picker row (Gregorian), month picker row (Hijri), today button, year picker

**States:** Month selected, scroll position

**AR/EN:** Month names in locale font; Hijri names always in Arabic

**RTL/LTR:** Scroll direction honors directionality

**Data requirements:** Current Gregorian month, current Hijri month(s), onMonthSelected callback

**Screens using it:** Calendar page

**Exists in design system:** Specified in CALENDAR_FOCUS_REDESIGN.md §A

**Must be created:** Does NOT exist — net-new widget required

**Implementation risk:** HIGH — requires DualDate architecture

---

## 14. SettingsSection

**Purpose:** Groups related settings with a section header.

**Variants:** With header, without header; with trailing action, without

**States:** Default

**AR/EN:** Header title from ARB

**RTL/LTR:** Auto-flip

**Exists in design system:** Used in `general_settings_page.dart` as `_SectionHeader`

**Must be created/extended:** Formalize `_SectionHeader` as public `SettingsSection`

**Implementation risk:** LOW

---

## 15. SettingsToggleTile

**Purpose:** Toggle switch row with icon, title, optional subtitle, optional indentation level.

**Variants:** Standard, indented (sub-setting), more-indented (sub-sub-setting)

**States:** On, off, disabled

**AR/EN:** Title/subtitle from ARB

**RTL/LTR:** Auto-flip

**Exists in design system:** Currently `_SwitchTile` in `general_settings_page.dart`

**Must be created/extended:** Formalize as public `SettingsToggleTile` with indentation prop

**Implementation risk:** LOW

---

## 16. BottomSheetForm

**Purpose:** Standard modal bottom sheet with header (title + close button + optional action), scrollable content, sticky footer (save/cancel).

**Variants:** Fixed height, flexible, full-screen

**States:** Normal, saving (spinner on save button), error (inline)

**AR/EN:** All strings from ARB

**RTL/LTR:** Header layout flips; `EdgeInsetsDirectional`

**Screens using it:** Add task, add habit, add medicine, add appointment, create space/module

**Exists in design system:** Individual sheets exist; no `BottomSheetForm` base widget

**Must be created/extended:** Extract common pattern from `unified_add_sheet.dart`, `habit_form_dialog.dart`

**Implementation risk:** MEDIUM — must preserve Phase 1/2/3 async save guards

---

## 17. PrimaryButton

**Purpose:** Main action button with gradient fill.

**Variants:** Large (full-width), medium (auto-width), small

**States:** Default, loading (spinner replaces text), disabled, pressed (scale 0.98)

**AR/EN:** Label from ARB

**RTL/LTR:** Icon position flips

**Exists in design system:** `atoms/buttons/app_button.dart` exists

**Must be created/extended:** Verify gradient fill uses `primaryGradient` token; verify loading state

**Implementation risk:** LOW

---

## 18. SecondaryButton

**Purpose:** Outlined or filled secondary action button.

**Variants:** Outlined, filled secondary

**States:** Default, loading, disabled, pressed

**Exists in design system:** `atoms/buttons/app_button.dart` likely includes this

**Must be created/extended:** Audit `app_button.dart` for secondary variant compliance

**Implementation risk:** LOW

---

## 19. EmptyState

**Purpose:** Displays when a list/screen has no content.

**Variants:** Feature-specific (tasks, habits, stats, calendar), generic

**States:** Default, with CTA button, without CTA

**AR/EN:** Title and description from ARB. "Warm one-liner" tone.

**RTL/LTR:** Auto-flip

**Data requirements:** Feature icon (48-64px), title, description, optional onAction callback

**Screens using it:** Tasks (empty), Habits (empty), Calendar (empty), Stats (empty), iPad master-detail detail pane

**Exists in design system:** Not found as a widget

**Must be created:** Net-new — does NOT exist as a shared component

**Implementation risk:** LOW

---

## 20. ErrorState

**Purpose:** Displays when a screen fails to load data.

**Variants:** Full-page, inline card, compact

**States:** With retry button, without retry

**AR/EN:** Error message from ARB or cubit state

**RTL/LTR:** Auto-flip

**Screens using it:** All screens that load data

**Exists in design system:** Not found as a systematic widget

**Must be created:** Net-new — inline error in prayer card only

**Implementation risk:** LOW

---

## 21. LoadingState

**Purpose:** Displays while data is loading.

**Variants:** Full-page shimmer skeleton, card skeleton, list skeleton, inline spinner

**States:** Loading

**Screens using it:** All data screens

**Exists in design system:** `athar_skeleton.dart` exists (molecules/skeletons/)

**Must be created/extended:** Ensure skeleton patterns exist for all major screen types

**Implementation risk:** LOW

---

## 22. PaywallCard

**Purpose:** Displays subscription upgrade prompt when feature limit is reached.

**Variants:** In-page card, bottom sheet, full-screen modal

**States:** Default, loading (checking entitlements), confirmed

**AR/EN:** Copy from ARB, feature names in locale

**RTL/LTR:** Auto-flip

**Data requirements:** `SubscriptionCubit` entitlements

**Screens using it:** When `TaskFreeLimitReached` or `HabitFreeLimitReached` emitted; subscription page

**Exists in design system:** `SettingsScreen.jsx` references it (not read)

**Must be created/extended:** Subscription page exists — audit for design spec compliance

**Implementation risk:** MEDIUM — must not bypass free-limit check

---

## 23. SyncStatusCard

**Purpose:** Shows last sync time, sync status, and error if any.

**Variants:** Banner (top of settings), compact indicator, full card

**States:** Syncing, synced (time ago), error, offline

**AR/EN:** Status text from ARB

**RTL/LTR:** Auto-flip

**Data requirements:** `SyncCubit` state, `lastSyncAt`, `lastSyncError`

**Screens using it:** Settings page, potentially dashboard

**Exists in design system:** Not found anywhere

**Must be created:** Net-new

**Implementation risk:** LOW

---

## 24. WidgetCard Visual Language (iOS)

**Purpose:** Defines the visual language for all 3 iOS home screen widget families.

**Variants:** Small, medium, large × Prayer/Task/Habit

**States:** Data loaded, no data, error, loading (placeholder)

**AR/EN:** Labels localized per device language (Phase 4 fix)

**Dark/Light mode:** iOS handles automatically via WidgetKit `AccessibilityProperties`

**Exists in design system:** NOT SPECIFIED — no widget visual design spec found

**Must be created:** Designer must create widget visual specs before implementation is touched

**Implementation risk:** VERY HIGH — any change to widget Swift code risks breaking `WidgetKeys` or App Group

---

## 25. FormField / Input Components

**Purpose:** Text input with label, placeholder, validation, error state.

**Variants:** Single-line, multi-line, date picker, time picker, reminder picker

**States:** Default, focused (primary border), filled, error, disabled

**AR/EN:** Placeholder from ARB; validation messages from ARB

**RTL/LTR:** `TextDirection` from `Directionality`; input padding flips

**Exists in design system:** `app_text_field.dart`, `athar_text_field.dart`, `time_slot_picker.dart`, `reminder_picker_widget.dart`, `athar_date_picker.dart`

**Must be created/extended:** Add `CupertinoTextField` variant for Pencil support; audit error state styling

**Implementation risk:** MEDIUM — `CupertinoTextField` vs `TextField` is a behavioral change on iOS

---

## 26. Modal / Sheet Headers

**Purpose:** Standardized header for bottom sheets and dialogs.

**Variants:** With close button (X), with back arrow, with title + trailing action, drag handle only

**States:** Default

**AR/EN:** Title from ARB

**RTL/LTR:** X/back button on correct side per directionality

**Exists in design system:** Inline in each sheet — not a standalone widget

**Must be created/extended:** Extract from `unified_add_sheet.dart` as `AtharSheetHeader`

**Implementation risk:** LOW

---

## 27. Section Headers

**Purpose:** Visual section divider with label for list screens.

**Variants:** With label, with label + trailing action, divider-only

**States:** Default, sticky (pinned while scrolling)

**AR/EN:** Label from ARB

**RTL/LTR:** Auto-flip

**Exists in design system:** `_SectionHeader` in settings; `habit_section_list.dart`

**Must be created/extended:** Formalize as `AtharSectionHeader`

**Implementation risk:** LOW

---

## 28. Badge / Chip Components

**Purpose:** Status badges, filter chips, role chips, smart-time chips.

**Variants:** Status badge (colored dot + text), filter chip (selectable), role chip (Owner/Admin/Member/Viewer), smart-time chip (task scheduling)

**States:** Default, selected, disabled

**AR/EN:** Text from ARB

**RTL/LTR:** Auto-flip

**Exists in design system:** `athar_selection.dart` exists — contents unknown

**Must be created/extended:** Add role chip variants, smart-time chip (requires SmartTimeParser integration)

**Implementation risk:** MEDIUM — smart-time chip must use `SmartTimeParser`, not regex in widget

---

## Component Priority Matrix

| Priority | Component | Why First |
|---|---|---|
| 1 | EmptyState | Required by iPad master-detail (blocks all tablet layouts) |
| 2 | ErrorState | Required by all data screens |
| 3 | AdaptiveShell | Required by all iPad layouts (blocks all tablet work) |
| 4 | PrayerCard (compact/expanded) | Dashboard hero; high user visibility |
| 5 | CalendarDayCell + DualCalendarHeader | Largest single behavioral gap |
| 6 | DashboardCard | Unblocks Dashboard redesign |
| 7 | TaskCard variants | Tasks is primary feature |
| 8 | HabitCard grid variant | Habits secondary feature |
| 9 | BottomSheetForm base | Unblocks all add-flow redesigns |
| 10 | StatsMetricCard + ChartCard | Blocked on StatsRepository anyway |
