# Project Design Context — Athar (أثر)

> ⚠️ **STALE — Phase 0 output (2026-05-06). Do not read as current state.**
> This file describes the app BEFORE v2 work began. Specific known-stale claims:
> - "`lib/features/stats/` | Stub" — FALSE. Stats fully implemented (PR6 complete, `2a6a46a`).
> - "Cairo + Inter fonts" / "Calibri NOT in project" — FALSE. Calibri added in PR1.
> Archive candidate (Stage B). For current project context, read `CLAUDE.md`.

_Phase 0 output. Generated: 2026-05-06. Do not implement — audit only._

---

## App Purpose

Athar is a bilingual (Arabic-primary, English-secondary) Islamic personal productivity app for iOS and Android. It combines daily task management, habit tracking, prayer times, dhikr/athkar, calendar, focus sessions, health tracking, family spaces, and stats into a single coherent system built on Islamic time periods.

---

## Core Domains

1. **Tasks** — Isar-backed task list, space-scoped, subscription-gated (free: 20 tasks)
2. **Habits** — Regular habits + Athkar habits (distinct type), heatmap, streak rings
3. **Prayer** — Adhan times (Adhan package), countdown, card, optional notifications. Master toggle → card toggle → notification toggle → reminder toggle
4. **Dhikr / Athkar** — Morning, evening, sleep sessions. Not a habit clone. Fixed items with progress counter.
5. **Calendar** — Dual Hijri/Gregorian. Currently toggled, target is simultaneous display
6. **Focus** — Oil-fill animation timer with gyroscope physics (hero feature)
7. **Stats** — Aggregated across domains. Cubit is mostly stub.
8. **Health** — Medicine, appointments tracking
9. **Assets** — Asset tracking with reminders
10. **Spaces / Projects** — Multi-user collaborative spaces with IAM (Owner/Admin/Member), per-module permissions
11. **Settings** — Per-feature toggles, smart zones, biometric, sync, subscription
12. **Subscription** — RevenueCat (free tier limits: 20 tasks, 5 habits; pro: spaces, sync, health pack, assets pack)
13. **Sync** — Supabase remote sync service
14. **Notifications** — Per-domain schedulers (prayer, habit, medication, appointment, asset, project)
15. **iOS Widgets** — AtharPrayerWidget, AtharTaskWidget, AtharHabitWidget (WidgetKit, AppIntentConfiguration, interactive)

---

## Current Modules / Features

| Feature Folder | Status |
|---|---|
| `lib/features/auth/` | Active |
| `lib/features/task/` | Active |
| `lib/features/habits/` | Active |
| `lib/features/prayer/` | Active (multi-toggle recently refactored) |
| `lib/features/dhikr/` | Active (bottom sheet only) |
| `lib/features/calendar/` | Active (Hijri toggle, not simultaneous) |
| `lib/features/focus/` | Active (oil animation partially implemented) |
| `lib/features/stats/` | Stub (cubit & repo mostly empty) |
| `lib/features/settings/` | Active (recently refined prayer toggles) |
| `lib/features/space/` | Active (rich data layer, presentation needs redesign) |
| `lib/features/health/` | Active |
| `lib/features/assets/` | Active |
| `lib/features/subscription/` | Active |
| `lib/features/sync/` | Active (no UI) |
| `lib/features/notifications/` | Active |
| `lib/features/home/` | Active (onboarding_page in home, not dedicated folder) |

---

## Key UI Surfaces

| Surface | File(s) |
|---|---|
| App shell / nav | `lib/core/design_system/widgets/liquid_glass_nav_bar.dart`, `lib/features/home/presentation/pages/main_page.dart` |
| Dashboard | `lib/features/home/presentation/pages/dashboard_page.dart`, `home_page.dart`, `home_page_responsive.dart` (3 dupes) |
| Prayer card | `lib/core/design_system/molecules/cards/next_prayer_card.dart`, `smart_prayer_wrapper.dart` |
| Prayer full screen | `lib/features/prayer/presentation/pages/prayer_page.dart`, `prayer_details_page.dart` |
| Task list | `lib/features/task/presentation/pages/task_page.dart`, `unified_tasks_page.dart` |
| Task add sheet | `lib/features/task/presentation/widgets/unified_add_sheet.dart`, `add_task_sheet.dart` |
| Habit list | `lib/features/habits/presentation/pages/habit_page.dart` |
| Habit add | `lib/features/habits/presentation/widgets/habit_form_dialog.dart` |
| Athkar | `lib/features/habits/presentation/widgets/athkar_card.dart`, `athkar_session_sheet.dart` |
| Calendar | `lib/features/calendar/presentation/pages/calendar_page.dart` |
| Focus | `lib/features/focus/presentation/pages/focus_page.dart` |
| Stats | `lib/features/stats/presentation/pages/stats_page.dart` |
| Settings | `lib/features/settings/presentation/pages/settings_page.dart`, `general_settings_page.dart` |
| Onboarding | `lib/features/home/presentation/pages/onboarding_page.dart` (not dedicated folder) |
| Subscription/paywall | `lib/features/subscription/presentation/` |
| Spaces | `lib/features/space/presentation/` |
| iOS Widgets | `ios/AtharPrayerWidget/`, `ios/AtharTaskWidget/`, `ios/AtharHabitWidget/` |

---

## RTL/LTR Requirements

- Primary locale: **ar-SA** (RTL)
- Secondary locale: **en-US** (LTR)
- `MaterialApp.localeResolutionCallback` maps ar→ar-SA, en→en-US, other→en-US
- `LocaleCubit` stores preference in FlutterSecureStorage
- Bug-fix history: extensive RTL fixes applied (Phase 2177ac4 — replaced `EdgeInsets.left/right` with `EdgeInsetsDirectional.start/end`)
- **88 files** still have hardcoded `Color(0x...)` or `Colors.*` — many likely also have directional violations

---

## Arabic/English Requirements

- All strings in `lib/l10n/app_ar.arb` + `lib/l10n/app_en.arb`
- Font: Cairo (AR primary, 4 weights: Regular/Medium/SemiBold/Bold), Inter (EN contexts), JetBrains Mono (numbers/timers)
- Design system spec calls for **Calibri** as primary Arabic font — not currently in Flutter project (only Cairo)
- Arabic-Indic numerals for prayer times/counters when locale is AR (optional via settings)

---

## iOS Widget Context

- App Group: `group.com.iappsnet.athar` — **never change**
- WidgetKeys constants in `widget_data_service.dart` — **never rename**
- AtharPrayerWidget, AtharTaskWidget, AtharHabitWidget
- Swift (iOS 17.0 minimum), AppIntentConfiguration, interactive widgets
- Phase 4/5 recently fixed: locale resolution, Athkar habit type display, short labels on small widget
- Widget data bridge: Flutter → UserDefaults via `widget_data_service.dart`

---

## Prayer Constraints (CRITICAL — DO NOT BREAK)

- `isPrayerEnabled` = master toggle (card + scheduling)
- `isPrayerCardEnabled` = card visibility sub-toggle
- `isPrayerNotificationsEnabled` = scheduling sub-toggle (OFF by default)
- `enablePrayerReminders` = 15-min early reminder sub-sub-toggle
- `didMigratePrayerFeatureSettings` = one-time migration flag (Phase 8.1)
- Scheduler guards: `!isPrayerEnabled || !isPrayerNotificationsEnabled`
- All scheduling via `PrayerNotificationScheduler` only
- ID range: 100000–199999 (never collide with other domains)

---

## Task Constraints (CRITICAL — DO NOT BREAK)

- 3 TaskCubit instances at runtime (global, MainPage local, UnifiedTasksPage local)
- Display is via `TimelineCubit` (Isar stream), NOT TaskCubit
- Central NavBar `+` is the ONLY add entry point — no page FABs
- `SubscriptionCubit` must be `@lazySingleton` (Phase 1 critical fix)
- Free limit: 20 tasks

---

## Habit Constraints (CRITICAL — DO NOT BREAK)

- `HabitType.regular` vs `HabitType.athkar` — distinct types, different UI
- Athkar habits have fixed UUIDs and `athkarItems` list — not editable like regular habits
- Athkar shown as read-only rows in iOS widget (Phase 5 fix)
- `habitsTotal`/`habitsDone` badge counts regular-only
- Free limit: 5 habits
- Central NavBar `+` is ONLY add entry point

---

## Athkar Constraints (CRITICAL — DO NOT BREAK)

- Athkar is NOT a habit clone — separate domain
- `lib/features/dhikr/` for the dhikr session model
- `athkar_card.dart` + `athkar_session_sheet.dart` in habits presentation
- Morning/evening/sleep sessions, fixed items with counters
- `isAthkarEnabled` toggle in settings (default: true)
- Never merge with habits in the UI

---

## Calendar Constraints (CRITICAL — DO NOT BREAK)

- `package:hijri ^3.0.0` is already a dep — confirmed
- `HijriService` exists at `lib/core/services/hijri_service.dart`
- `dual_calendar_widget.dart` currently has a **toggle** (Hijri ⇄ Gregorian)
- Design spec requires **simultaneous display** (Apple Calendar style) — this is a net-new build
- User settings: `isHijriMode` bool (toggles primary display between Hijri/Gregorian)
- `DualDate` entity needs to be created

---

## Stats Constraints

- `stats_cubit.dart` is essentially a stub
- `IStatsRepository` is nearly empty
- Charts via `fl_chart` (already in pubspec)
- Data must aggregate from tasks, habits, focus, prayer adherence
- No standalone stats data source — all fan-in from other domain repos

---

## Sync/Settings/Subscription Constraints

- `isAutoSyncEnabled` toggle in UserSettings
- `lastSyncAt`, `lastSyncError` fields
- RevenueCat entitlements: `spaces_pro`, `sync_pro`, `health_pack`, `assets_pack`
- SubscriptionCubit must be `@lazySingleton` (critical — Phase 1 fix)
- Paywall at `subscription_page.dart`

---

## Completed Bug-Fix Phases (Must Not Be Broken)

| Phase | Description |
|---|---|
| Phase 1 | `SubscriptionCubit` `@lazySingleton` fix — task add flow |
| Phase 2 | Habit add async save + `_isSaving` guard |
| Phase 3 | NavBar add targets (medicine, appointment, module, space) |
| Phase 4 | iOS Widget locale fix (device language, not app locale) |
| Phase 5 | Athkar in Habit iOS Widget (read-only rows, `tp` field) |
| Phase 6 | Prayer notifications default OFF (save-ordering fix) |
| Phase 7 | Regression verification |
| Phase 8 | Prayer card/notification separation |
| Phase 8.1 | Prayer master toggle + `isPrayerCardEnabled` + migration |

---

## Architecture Constraints

- Clean Architecture per feature: `data/` → `domain/` → `presentation/`
- State: flutter_bloc Cubits only
- DI: GetIt + Injectable (`injection.config.dart` generated — never edit directly)
- Storage: Isar local → Supabase sync
- All mutations permission-gated via `PermissionService` for space-scoped resources
- All notifications via per-domain schedulers
- All strings in ARB files
- `EdgeInsetsDirectional` everywhere (RTL compliance)
- `LayoutBuilder` for responsive — never `MediaQuery.size.width`
