# Athar Redesign Audit — Mockups vs. Live Codebase

> A gap analysis between the JSX mockups in `ui_kits/athar_app/` and the
> Flutter source you uploaded as `All_Project_Code.txt`. Use it to plan the
> implementation order, route the right files to the right tool, and avoid
> rebuilding things that already exist.

Last reviewed against the codebase manifest in `design-context/_manifest.json`
and the dump in `uploads/All_Project_Code.txt`.

---

## TL;DR

> **Updated 2026-05-07** after codebase investigation. See
> `INVESTIGATION_RECONCILIATION.md` for the full diff. Onboarding is
> **not** net-new — the page exists and the persistence flag is wired.

| Mockup screen (`ui_kits/athar_app/*.jsx`) | Lives in code as | Status |
|---|---|---|
| `Dashboard.jsx` | `lib/features/home/presentation/pages/dashboard_page.dart` (+ `home_page.dart`, `main_page.dart`) | **Refactor** — exists, redesign visuals + composition |
| `TasksScreen.jsx` | `lib/features/task/` (singular `task`, not `tasks`) | **Refactor** |
| `HabitsScreen.jsx` | `lib/features/habits/` | **Refactor** |
| `CalendarScreen.jsx` | `lib/features/calendar/` | **Refactor** — split into PR4a (visuals) + PR4b (dual-display rebuild) |
| `FocusScreen.jsx` | `lib/features/focus/` | **Refactor** |
| `StatsScreen.jsx` | `lib/features/stats/` | **Refactor** (page + cubit exist; `IStatsRepository` is empty — light data work needed) |
| `SettingsScreen.jsx` | `lib/features/settings/` | **Refactor** |
| `SpacesScreen.jsx` | `lib/features/space/` (singular `space`, not `spaces`) | **Refactor** |
| `OnboardingScreen.jsx` | `lib/features/home/presentation/pages/onboarding_page.dart` (4 slides, `SharedPreferences` `onboarding_seen`) | **Refactor in place** |
| Prayer card on Dashboard | `lib/features/prayer/` | **Refactor** of `prayer_body.dart` + `prayer_*_view.dart` |
| Dhikr ribbon / sheet | `lib/features/dhikr/` | **Refactor** |
| Bottom nav | `lib/core/design_system/widgets/liquid_glass_nav_bar.dart` | **Refactor in place** |

No screen is greenfield. Every section is a visual + token + composition
refresh of an existing feature folder. The only **net-new feature** in
the redesign scope is **Athkar** (see `ATHKAR_SPEC.md`, PR7).

> **iPad work is tracked separately in `IPAD_OPTIMIZATION.md`.** It uses
> the same per-screen ticket format and assumes each screen's phone
> redesign in this doc has landed first. Layer 1 (the `AdaptiveShell`
> with `NavigationRail` branch) is a one-file global change that should
> happen alongside §1 (Dashboard) here.

---

## How to read this doc

For each mockup screen the audit lists:

1. **Mockup file** — the JSX the visual target lives in.
2. **Target Dart files** — what to edit, in priority order.
3. **Cubit / state** — does the existing state shape support the new UI, or
   does it need fields added?
4. **Net-new vs. refactor** — concrete deltas.
5. **Permission / subscription / scheduler hooks** — non-negotiable wiring
   that must survive the redesign.

The tool implementing this (Claude Code, Cursor, etc.) should treat each
section as a self-contained ticket.

---

## 1. Dashboard

**Mockup:** `ui_kits/athar_app/Dashboard.jsx`
**Targets (in order):**
1. `lib/features/home/presentation/pages/dashboard_page.dart` — primary
2. `lib/features/home/presentation/pages/home_page.dart` + `home_page_responsive.dart` — collapse to one
3. `lib/features/home/presentation/widgets/home_header.dart` (and the duplicate at `pages/home_header.dart`) — dedupe
4. `lib/features/home/presentation/widgets/daily_timeline_widget.dart` — keep, restyle
5. `lib/features/home/presentation/pages/smart_habits_strip.dart` — keep, restyle
6. `lib/features/home/presentation/pages/my_day_list.dart` — keep, restyle

**Cubits already in place:**
- `home_cubit.dart` + `home_state.dart`
- `timeline_cubit.dart` (separate — keep)
- `prayer_cubit.dart` is consumed here for the prayer card

**Refactor deltas:**
- Replace any direct `Color(0xff…)` with `AppColors.*` from `core/design_system/tokens/athar_colors.dart`.
- Greeting must come from `AtharTimeCalculator` (period → string), not
  `DateTime.hour < 12`.
- Hide the prayer card when `SettingsState.modules.prayer == false`
  (universal-by-default rule from SKILL.md §2).
- Three duplicated home pages (`home_page.dart`, `home_page_responsive.dart`,
  `dashboard_page.dart`) — keep `dashboard_page.dart`, delete the other two
  after porting unique code.
- `home_header.dart` exists in two folders — delete the `pages/` copy.

**Net-new on this screen:** none. All sub-widgets exist.

---

## 2. Prayer card (lives on Dashboard, but feature-scoped)

**Mockup:** the prayer card section of `Dashboard.jsx` + the standalone
`Prayer Card.html` exploration.

**Targets:**
1. `lib/features/prayer/presentation/widgets/prayer_body.dart`
2. `lib/features/prayer/presentation/widgets/prayer_day_view.dart`
3. `lib/features/prayer/presentation/widgets/prayer_week_view.dart`
4. `lib/features/prayer/presentation/widgets/prayer_month_view.dart`
5. `lib/features/prayer/presentation/pages/prayer_details_page.dart`

**Cubit:** `prayer_cubit.dart` already streams next-prayer + countdown.
Confirm `PrayerState` exposes:
- `nextPrayerName`
- `timeUntilNext` (Duration)
- `todayPrayers` (List<PrayerTime> with status)
- `hijriDate`
- `sunrise`, `sunset`

If any are missing, add to state — do **not** compute in widget.

**Visual deltas (from the redesigned prayer card spec):**
- Fixed night-sky gradient surface (only place in app where transparency is
  blessed besides the nav bar).
- Live H:MM:SS countdown — `StreamBuilder` on a 1-second tick, format with
  the Arabic-Indic numeral utility if locale is `ar`.
- Compact (next-only) and expanded (all 5) variants — wire to a single bool
  in widget state, persist preference via `SettingsCubit`.

**Notification scheduler:** prayer reminders go through
`prayer_notification_scheduler` only. Never call
`LocalNotificationService` directly from this widget.

---

## 3. Tasks

**Mockup:** `ui_kits/athar_app/TasksScreen.jsx`
**Feature folder:** `lib/features/task/` (singular).

**Targets:**
1. `lib/features/task/presentation/pages/` — list page, detail page (find via
   `presentation/pages/*` in the dump; refactor in place)
2. `lib/features/task/presentation/widgets/` — task tile, add/edit sheet
3. `lib/features/task/data/models/task_model.dart` — already has Isar schema,
   `attachment_model.dart`, `task_note_model.dart`

**Cubit:** task cubit exists. Verify it exposes:
- filtered lists by space + status + assignee
- `assignTask` action that goes through `PermissionService.canAssignTask`

**Refactor deltas:**
- Quick-add row at top → wire to existing `createTask` cubit method.
- Smart-time chips ("بعد العصر", "غدًا الصبح") → parse via `SmartTimeParser`,
  not regex in the widget.
- Permission-gate every mutation with `PermissionService.canCreate/canEdit/
  canDelete/canAssignTask` for the active space — emit error state on fail
  (per SKILL.md §3).
- Notifications for due-soon → through a scheduler (add
  `task_notification_scheduler.dart` if it doesn't exist; the pattern is in
  `prayer_notification_scheduler` and `habit_notification_scheduler`).

---

## 4. Habits

**Mockup:** `ui_kits/athar_app/HabitsScreen.jsx`
**Feature folder:** `lib/features/habits/`

**Targets:**
1. `lib/features/habits/presentation/pages/habit_page.dart` — main list
2. `lib/features/habits/presentation/pages/habit_details_page.dart`
3. `lib/features/habits/presentation/widgets/habit_tile.dart`
4. `lib/features/habits/presentation/widgets/habit_heatmap.dart`
5. `lib/features/habits/presentation/widgets/habit_section_list.dart`
6. `lib/features/habits/presentation/widgets/athkar_card.dart` +
   `athkar_session_sheet.dart` — religious sub-module, gate by
   `modules.dhikr == true`
7. `lib/features/habits/presentation/widgets/habit_form_dialog.dart`

**Cubit:** `habit_cubit.dart` + `habit_state.dart` — confirmed.

**Refactor deltas:**
- Heatmap colors → use `AppColors.success` ramp from tokens, never hex.
- Streak chip → use `AppTypography.numericMono` (JetBrains Mono) so digits
  align across rows.
- Notifications → `habit_notification_scheduler` (already exists, keep).
- Athkar card section is conditional: render only if user has dhikr module
  enabled (see SettingsCubit).

---

## 5. Calendar — split into PR4a + PR4b

**Mockup:** `ui_kits/athar_app/CalendarScreen.jsx`
**Feature folder:** `lib/features/calendar/`

This ticket is split because the existing `DualCalendarWidget` is
**toggle-based** (Hijri OR Gregorian, not both at once) and our design
requires simultaneous display. The visual refresh and the dual-display
rebuild are decoupled to keep PR sizes manageable.

### 5a — Visual refresh (keep toggle widget)

**Targets:**
1. `lib/features/calendar/presentation/pages/calendar_page.dart`
2. `lib/features/calendar/presentation/widgets/calendar_body.dart`
3. `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` —
   restyle only; do not rebuild yet.

**Cubit:** `calendar_cubit.dart` + `calendar_state.dart`.

**Refactor deltas:**
- Restyle headers, dot legend, surrounding chrome.
- Extend `CalendarCubit.selectDate` (currently `calendar_cubit.dart:36–60`)
  to fan in **all four** sources: tasks + appointments **+ habit
  completions + prayer adherence**. Today only tasks + appointments
  populate dot data.
- Add `TimelineItem` discriminator in `calendar/domain/entities/` if
  not present (the architecture rule is presentation stays thin).

### 5b — Dual-display rebuild (PR-CAL, own milestone)

**Net-new files:**
- `lib/features/calendar/domain/entities/dual_date.dart` — value object
  pairing Gregorian + Hijri dates.
- `lib/features/calendar/presentation/widgets/calendar_cell.dart` — cell
  that renders both numerals always; `isHijriMode` controls *which is
  primary* (larger weight), not which is shown.
- `lib/features/calendar/presentation/widgets/dual_month_switcher.dart` —
  month nav that respects whichever calendar is currently primary.

**Replaces:** `dual_calendar_widget.dart` (delete after consumer migration).

**Wiring:**
- `UserSettings.isHijriMode` semantics change from "show Hijri" to
  "Hijri is primary numeral." Both numerals always render.
- See `CALENDAR_CELL_SPEC.md` for visual rules and
  `INVESTIGATION_RECONCILIATION.md §B3` for sequencing.

---

## 6. Focus

**Mockup:** `ui_kits/athar_app/FocusScreen.jsx`
**Feature folder:** `lib/features/focus/`

**Targets:**
1. `lib/features/focus/presentation/pages/focus_page.dart`
2. `lib/features/focus/presentation/widgets/fluid_engine.dart` — keep, this is
   the signature animated background
3. `lib/features/focus/presentation/widgets/liquid_background.dart` — keep
4. `lib/features/focus/presentation/widgets/focus_b*.dart` (truncated in dump)

**Cubit:** `focus_cubit.dart` + `focus_state.dart`.

**Refactor deltas:**
- Mostly visual — the fluid background is already correct per the brand
  spec. Verify `AppAnimations.easeOutCubic` is used for any timer
  transitions, not raw curves.
- Pomodoro counts/durations should come from `SettingsCubit`, not be
  hardcoded.

---

## 7. Stats

**Mockup:** `ui_kits/athar_app/StatsScreen.jsx`
**Feature folder:** `lib/features/stats/`

**Targets:**
1. `lib/features/stats/presentation/pages/stats_page.dart`
2. `lib/features/stats/presentation/widgets/statistics_card.dart`
3. `lib/features/stats/presentation/widgets/stats_body.dart` (note: file is
   misnamed `stats_bweekly_focus_chart.dartody.dart` in the dump — fix the
   filename while you're in there)

**Cubit + repo:** `StatsCubit` exists (confirmed at
`features/stats/presentation/cubit/stats_cubit.dart`) and `StatisticsPage`
at `features/stats/presentation/pages/stats_page.dart:17` is the entry
point — but `IStatsRepository` is empty. **This is a refactor + light
data-layer build:**
- Define `StatsRepository` methods that aggregate from the same fan-in
  sources as Calendar (tasks, habits, focus, prayer adherence) — share
  the data layer with the Calendar fan-in introduced in §5a.
- Cubit emits `StatsLoaded(period, KPIs)`.
- Charts → use `fl_chart` (already in pubspec, presumably) — colors from
  `AppColors`, weights from `AppTypography`.
- See `STATS_KPI_SPEC.md` for KPI list, insights, per-space breakdown,
  custom date range, CSV/PDF export.

---

## 8. Settings

**Mockup:** `ui_kits/athar_app/SettingsScreen.jsx`
**Feature folder:** `lib/features/settings/`

**Targets:**
1. `lib/features/settings/presentation/pages/settings_page.dart`
2. `lib/features/settings/presentation/pages/general_settings_page.dart`
3. `lib/features/settings/presentation/pages/location_settings_page.dart`
4. `lib/features/settings/presentation/pages/smart_zones_page.dart`
5. `lib/features/settings/presentation/widgets/settings_body.dart`
6. `lib/features/settings/presentation/widgets/add_category_dialog.dart`
7. `lib/features/settings/presentation/widgets/delete_account_dialog.dart`

**Cubits:** `settings_cubit.dart` + `category_cubit.dart`.

**Refactor deltas:**
- The "Modules" section of the redesigned settings (toggle prayer, dhikr,
  habits, health, assets, spaces) drives universal-by-default behavior
  across the app. Confirm `SettingsState` has a `modules: ModuleFlags`
  object and that `dashboard_page` reads from it.
- Subscription cards → consume `SubscriptionCubit`, route to
  `subscription_page.dart` paywall, never block save.

---

## 9. Spaces

**Mockup:** `ui_kits/athar_app/SpacesScreen.jsx`
**Feature folder:** `lib/features/space/` (singular).

**Targets:** check `lib/features/space/presentation/` (truncated in our
visible grep output — the dump includes `space_model.dart`,
`space_member_model.dart`, `module_model.dart`, `module_permission_model.dart`,
`invitation_model.dart`, `list_item_model.dart`, `list_log_model.dart`).
The data layer is rich; presentation needs the redesign.

**Cubit:** confirm space cubit exists and exposes:
- current active space
- members + roles
- per-module permission map (`ModulePermission`)
- pending invitations

**Refactor deltas:**
- Members list with role chips (Owner / Admin / Member / Viewer) — colors
  via `AppColors.role*` if defined, otherwise add tokens for the four roles.
- Module permission grid → checkbox-per-(member×module). Writes go through
  `PermissionService` only.
- Invitation flow needs subscription gate: free tier may cap members.
  Consult `SubscriptionCubit.hasSpacesPro` before showing "Invite" CTA.

---

## 10. Onboarding (REFACTOR IN PLACE — not net-new)

**Mockup:** `ui_kits/athar_app/OnboardingScreen.jsx`
**Page:** `lib/features/home/presentation/pages/onboarding_page.dart`
**Status:** **Exists with 4 slides + persistence wired.** Do **not**
create `lib/features/onboarding/`.

**Existing flow** (verified in investigation):
- 4 slides defined in `_buildSlides()` at `onboarding_page.dart:51`:
  1. Tasks & Habits / Own Your Day
  2. Prayer & Dhikr / Never Miss a Prayer
  3. Focus & Productivity / Focus on What Matters
  4. Get Started / Live with More Impact
- Persistence: `SharedPreferences` key `'onboarding_seen'` (bool).
  - Written at `onboarding_page.dart:84` on completion of last slide.
  - Read at `main.dart:106` via `OnboardingPage.hasBeenSeen()`.
  - Routed in `app.dart:187–189` based on `hasSeenOnboarding`.

**Refactor deltas:**
- Restyle each slide per `OnboardingScreen.jsx` mockup.
- All copy via ARB. No string literals in widgets.
- Token-only colors and typography.
- Slide structure (count, content, persistence) is correct — visual
  refresh only.

**Out of scope for this PR:**
- Adding a Modules-toggle step, location step, notifications-permission
  step, or space create/join step. The current onboarding is
  intentionally lighter; if those are wanted, they're a separate ticket
  and need design specs.

---

## 11. Bottom nav

**Target:** `lib/core/design_system/widgets/liquid_glass_nav_bar.dart`
(per SKILL.md §"never fork it").

**Refactor in place — finalized shape:**
- Two floating pills at the bottom of the screen: a **liquid-glass tab bar**
  (4 destinations) + a **standalone "+" FAB outside the bar**.
- Bar treatment: `BackdropFilter(sigmaX: 28, sigmaY: 28)` + saturation
  boost, translucent white fill (`rgba(255,255,255,.42)` → `.22` vertical
  gradient), top specular highlight (radial), inner-ring 1px edge, soft
  outer shadow. Forest-green tint shows through from the page underneath.
- 4 destinations: Dashboard · Tasks · Habits · Spaces (matches Package C
  decision #2). Labels from `arb`, never hard-coded.
- Active indicator color = `AppColors.primary` (forest green); active tab
  also gets a faint glass chip (`rgba(255,255,255,.32)` + 1px inner ring)
  so the selection reads against the bar's translucency.
- **FAB is a separate widget, not inside the bar.** 64×64 pill, 22px
  radius, `primary` linear gradient (`#2F7A5E → #0F3D2E`), `shadow.lg`
  ambient + brand-tinted drop. Sits with **10px gap** beside the bar.
- **Direction:**
  - **LTR (English):** bar on the leading edge, FAB on the trailing
    (right) edge.
  - **RTL (Arabic):** mirrored via `Directionality` — bar on the leading
    (right) edge, FAB on the trailing (left) edge.
  Use `flex-direction: row-reverse`-equivalent (i.e. let the inherited
  `TextDirection` drive layout); never hard-code left/right.
- **No centered FAB, no notch, no `BottomNavigationBar`.**

Reference mock: `preview/comp-nav.html`.

---

## 12. Things that DON'T need a redesign pass

These are correct architecture pieces — verify they're consumed properly,
but don't refactor them visually:

- `lib/core/design_system/tokens/` — colors, typography, radii, shadows,
  spacing, animations. **Update token values to match new brand** (forest
  green palette, Calibri Arabic) — see migration note in §06 of
  `Athar Brand System.html`.
- `lib/features/auth/` — login/register/profile pages. Restyle inputs via
  `AppTextField` so the visual change is automatic.
- `lib/features/health/` — already token-based; only the dashboard tile
  styling on Dashboard needs touching.
- `lib/features/assets/` — same. The `assets_page.dart` list tile follows
  the global card style; restyle the card token, every page updates.
- `lib/features/notifications/` — notification center page is generic;
  restyle through the row token.
- `lib/features/dhikr/` — bottom sheet only; restyle once.
- `lib/features/subscription/` — paywall page; restyle once.
- `lib/features/sync/` — no UI, leave alone.
- All `data/`, `domain/`, `usecases/`, `repositories/` files — never touched
  by a visual redesign.

---

## Cross-cutting checklist (apply to every screen)

Lifted verbatim from `SKILL.md §5` so the implementing tool can copy it
into a PR template:

- [ ] All colors via `AppColors.*` (no `Color(0xff…)`)
- [ ] All text styles via `AppTypography.*` (no inline `TextStyle`)
- [ ] All spacing/radii/shadows via tokens (no magic dp numbers)
- [ ] All user-visible strings in `app_ar.arb` + `app_en.arb`
- [ ] `EdgeInsetsDirectional` everywhere — never `EdgeInsets.only(left/right)`
- [ ] Tested mirrored in RTL + LTR + dark mode
- [ ] Time logic via `AtharTimeCalculator` / `SmartTimeParser`
- [ ] Mutations gated by `PermissionService` for space-scoped writes
- [ ] Paid features gated by `SubscriptionCubit` flags
- [ ] Notifications scheduled via the per-domain scheduler
- [ ] No new direct `LocalNotificationService` calls
- [ ] If you added `@injectable` / Isar / freezed: ran
      `flutter pub run build_runner build --delete-conflicting-outputs`

---

## Recommended implementation order

1. **Tokens first** — update `colors_and_type.css` _values_ in
   `lib/core/design_system/tokens/athar_colors.dart` and
   `athar_typography.dart` to match the new forest-green brand. Every screen
   shifts visually for free.
2. **Bottom nav** — small surface, high impact, validates the new palette.
3. **Dashboard** — the proof case; touches prayer, habits, tasks tiles.
4. **Settings** — unblocks the Modules toggle that Dashboard reads.
5. **Tasks → Habits → Calendar → Focus → Stats → Spaces** — in any order.
6. **Onboarding** — last; depends on Settings (modules) + Spaces (create/join).

---

## File index for the implementing tool

When pointing Claude Code (or similar) at the repo, hand it:

- `iappnet/athar` repo (Flutter source)
- This workspace, with `SKILL.md` as the law
- This file (`REDESIGN_AUDIT.md`) as the per-screen ticket list
- `IPAD_OPTIMIZATION.md` as the iPad layout + affordance ticket list (apply per screen *after* its phone redesign lands)
- `Athar Brand System.html` as the visual north-star
- `colors_and_type.css` as the literal token spec sheet
- `ui_kits/athar_app/*.jsx` as the per-screen visual targets

Tell it: _"Work top-down through `REDESIGN_AUDIT.md` §1–§11. For each
section, edit the listed Dart files only. Tokens come from
`colors_and_type.css`. Visual target is the matching JSX mockup. Honor the
SKILL.md `§5` checklist on every PR. Once a screen's phone redesign is
green, port it to iPad using `IPAD_OPTIMIZATION.md` — the adaptive shell
in §Layer 1 of that doc is a hard prerequisite for all per-screen iPad
work."_
