# Handoff to Claude Design — Athar UIKit Update Request

> ⚠️ **STALE — Phase 0 output (2026-05-06). Do not read as current state.**
> This file describes the app BEFORE v2 work began. Specific known-stale claims:
> - "Stats cubit is essentially a stub" — FALSE. Stats is fully implemented (PR6 complete, `2a6a46a`).
> - "Cairo + Inter fonts" — FALSE. Calibri added in PR1; Cairo is fallback only.
> - "88 files with hardcoded colors" — migration ongoing since PR1.
> Archive candidate (Stage B). For current handoff context, read `docs/governance/ATHAR_FINAL_KNOWLEDGE_ARCHITECTURE.md`.

_Phase 6 output. Generated: 2026-05-06._
_This document is the key handoff for Claude Design (or designer) to update the UIKit and design system based on audit findings._

---

## What the Design System Already Covers

The following are confirmed covered in `Athar Design System/colors_and_type.css` and matched in the Flutter token files:

- **Color tokens:** Primary (`#1A6B3C`), secondary (`#0D7377`), all surfaces, text hierarchy, status colors (success/warning/error/info), borders, shadows, prayer gradient (`#1E293B → #0F172A`). Light and dark mode both defined.
- **Typography scale:** 10px–56px in 15 steps; weight scale 300–900; line heights 1.2–1.75; letter spacing variants.
- **Spacing tokens:** 2px–64px in 12 steps.
- **Radius tokens:** 4px–999px in 9 steps.
- **Shadow tokens:** xs–xxl, two-layer system.
- **Motion tokens:** 150/200/300ms durations, custom cubic-bezier `(.16,1,.3,1)`.
- **Prayer card gradient:** Night-sky `#1E293B → #0F172A` — fixed for both modes.
- **Build order spec:** HANDOFF.md defines 9-step build order.
- **REDESIGN_AUDIT.md:** Per-screen ticket list for all 11 screens.
- **CALENDAR_FOCUS_REDESIGN.md:** Calendar dual Hijri spec + Focus oil spec.
- **FOCUS_OIL_SPEC.md:** Full physics spec for oil-fill animation.
- **IPAD_OPTIMIZATION.md:** AdaptiveShell + per-screen iPad layouts.
- **SKILL.md:** Architecture laws, component conventions, density rules, RTL rules.

---

## What the Current App Actually Contains (Flutter)

- 16 active feature modules (auth, task, habits, prayer, dhikr, calendar, focus, stats, settings, space, health, assets, subscription, sync, notifications, home)
- **Prayer:** 4-level toggle hierarchy (master → card → notifications → 15-min reminder). Recently refined (Phase 8.1).
- **Tasks:** 3 cubit instances at runtime. Timeline display via `TimelineCubit`. Central NavBar `+` only add path.
- **Habits:** `HabitType.regular` + `HabitType.athkar` (distinct types). Athkar is read-only in iOS widget.
- **Calendar:** Hijri/Gregorian TOGGLE — not simultaneous display. `package:hijri` in pubspec.
- **Focus:** `oil_animation.dart` with `sensors_plus` import — partial oil animation implementation exists.
- **Stats:** Cubit is essentially a stub. No live data aggregation.
- **iOS Widgets:** 3 widgets (Prayer/Task/Habit), SwiftUI + AppIntentConfiguration.
- **Onboarding:** In `home/presentation/pages/` (not dedicated feature folder per spec).
- **88 files** with hardcoded `Color(0x...)` — token migration needed.
- **Fonts:** Cairo (AR) + Inter (EN) + JetBrains Mono (numbers). Calibri NOT in project.

---

## Missing Screens

| Screen | Status |
|---|---|
| Onboarding (dedicated feature folder) | In home/ folder — not spec-compliant location |
| Stats (live data) | Visual exists but data is stub |
| Sync status page | Does not exist |
| Widget visual specs (small/medium/large) | No design spec exists |

---

## Missing Components (Must Be Added to UIKit)

### Critical — Needed for Phase A/B Work

1. **`EmptyState`** — No reusable widget. Spec: 48–64px feature glyph + warm one-liner + single CTA. Needed for: Tasks (empty), Habits (empty), Calendar (empty), Stats (empty), iPad master-detail detail pane.

2. **`ErrorState`** — No reusable widget. Needed for: all data screens. Variants: full-page, inline card, compact.

3. **`AdaptiveShell` spec** — IPAD_OPTIMIZATION.md describes it but no component spec in UIKit. The Flutter `AdaptiveScaffold` exists but doesn't match spec location. Designer needs to confirm: is the spec for a new file at `lib/core/design_system/widgets/adaptive_shell.dart` or a rename/move of existing `lib/core/layouts/adaptive_scaffold.dart`?

4. **`numericMono` text style** — Not defined in `AtharTypography`. Habit streak chip and all numeric contexts need a named JetBrains Mono tabular style.

5. **Tabular figures** — `FontFeature.tabularFigures()` not applied to any numeric text styles. Required for timers, counters, stats.

### Calendar Components (Entire Calendar Widget Family)

6. **`CalendarDayCell`** — Shows Gregorian numeral (top-right) + Hijri numeral (bottom-left) simultaneously. In RTL, positions flip. First-of-Hijri-month shows month name instead of numeral + hairline border-top. Needs design spec with exact pixel dimensions and typography.

7. **`DualCalendarHeader`** — Two independent scrollable pill rows: Gregorian months on top, Hijri months below. Tapping either re-anchors the grid. Needs design spec.

8. **`DualDate` value object** — Dart entity: `{ DateTime gregorian, HijriCalendar hijri, bool isFirstOfHijriMonth }`. Not a visual component but must be specced before CalendarCell can be built.

### Prayer Card Components

9. **`PrayerCard` compact variant** — Shows next prayer only: name, H:MM:SS countdown in JetBrains Mono tabular, Hijri-prominent date. Needs component spec from `comp-prayer-card.html` (file exists but not read during this audit).

10. **`PrayerCard` expanded variant** — All 5 prayers strip with past/current/next visual states, sunrise/sunset arc, progress bar. Needs component spec.

11. **Prayer card compact/expanded user preference** — Where is this stored? Via `SettingsCubit`? Not currently in `UserSettings`. Needs architectural decision.

### iOS Widget Visual Specs (FULLY MISSING)

12. **Widget visual specs** — No design spec exists for any of the 3 iOS widgets (Prayer/Task/Habit) in any size (small/medium/large). Designer must create these specs before any widget visual work begins. Athar widgets use WidgetKit + SwiftUI.

### Athkar / Dhikr Components

13. **`AthkarProgressCard` spec** — `athkar_card.dart` exists in Flutter but there is no design spec for Athkar UI. Designer must create explicit Athkar UX spec before any Athkar redesign. Athkar is NOT a habit clone.

14. **`AthkarSessionSheet` spec** — No design spec for the dhikr session bottom sheet.

### Stats Components

15. **`StatsMetricCard` spec** — `statistics_card.dart` exists but cubit is stub. Need KPI definitions + visual spec.

16. **`ChartCard` spec** — Bar/line/heatmap chart wrapper. Data source definitions needed.

### Settings Components

17. **`ModuleFlags` spec** — Design system references `SettingsState.modules.prayer` as a unified object. Flutter has individual booleans. Designer must specify the Modules settings section as a unified block. **Must not break Prayer Phase 8.1 hierarchy.**

18. **`PrayerToggleTile` hierarchy spec** — The indented sub-settings (Prayer Card, Prayer Notifications, 15-min Reminder) need a designed visual hierarchy spec. Currently using generic switch tiles.

### Misc Components

19. **`SyncStatusCard`** — No design spec. Needed for settings page.

20. **Role chip variants** — Owner/Admin/Member/Viewer chips for Spaces. No spec found.

---

## Missing States

| Component | Missing States |
|---|---|
| PrayerCard | Compact vs expanded variants; arc/progress design |
| TaskTile | Hover (iPad), swipe-to-complete |
| HabitTile | Grid variant, count-based progress visual |
| CalendarCell | Simultaneous dual-numeral state |
| FocusScreen | Reduce Motion fallback visual |
| All screens | Systematic EmptyState, ErrorState |
| BottomSheetForm | Loading/saving state (spinner) |

---

## Missing UX Rules

1. **Calibri font decision:** Is Calibri the required Arabic brand font? The design system CSS lists it as primary (`--font-ar: 'Calibri', 'Cairo', ...`) but it is NOT in the Flutter project. If Calibri is required, it must be added to pubspec.yaml with the 3 weights already in the design system `fonts/` folder (light, regular, bold — only 3 weights vs Cairo's 4).

2. **Athkar UX rules:** Athkar is not designed in the design system. No spec exists. Please provide:
   - Athkar progress model (counter per item, session completion)
   - Athkar card visual layout on the Habits page
   - Athkar session sheet interaction flow
   - Whether Athkar should live on the Habits page or get its own tab

3. **Calendar behavior clarification:** The current app has a Hijri/Gregorian toggle. The spec says simultaneous display. Please confirm:
   - Is the toggle (Hijri primary mode) preserved for users who prefer Hijri-only view?
   - Does `isHijriMode` setting become "Hijri as primary numeral in cell" instead of "toggle to Hijri-only"?
   - What happens to the existing `dual_calendar_widget.dart`?

4. **Focus accessibility:** Reduce Motion + Disable Gyroscope toggles are specified but not implemented. Where in Settings should these live? Under a new "Accessibility" section?

5. **Stats KPI definitions:** What KPIs are shown? (task completion rate, habit streak, focus hours, prayer adherence %, etc.) These must be defined before the data layer is built.

6. **Widget small size constraint:** iPhone SE has ~71pt for title area in small widget. Long labels clip at minimum scale factor. Phase 4 fix used short labels ("Tasks"/"Habits"). Is this the permanent solution or should there be a design spec for small widget layout?

7. **Eastern Arabic numerals:** `useEasternNumerals` preference doesn't exist in UserSettings. Is this a required feature? If yes, where in Settings?

---

## Visual Mismatches Found

| Item | Design System | Current Flutter |
|---|---|---|
| Primary font (Arabic) | Calibri (CSS primary) | Cairo |
| Calendar behavior | Simultaneous dual display | Toggle (select one) |
| Prayer card countdown | JetBrains Mono tabular | Font not confirmed |
| Prayer card arc | Sunrise/sunset arc specified | Not implemented |
| Stats | Full chart dashboard | Stub only |
| Empty states | 48-64px glyph + CTA | Not implemented |
| AdaptiveShell | New widget in design_system/widgets/ | AdaptiveScaffold in layouts/ |
| Hardcoded colors | Tokens only | 88 files with Color(0x...) |

---

## Behavioral Mismatches

| Item | Design System | Current Flutter |
|---|---|---|
| Prayer settings | `modules.prayer = true/false` | 4-level toggle hierarchy (Phase 8.1) |
| Greeting | `AtharTimeCalculator` period | `DateTime.hour < 12` check |
| Task smart-time input | `SmartTimeParser` chips in add sheet | Not implemented |
| Calendar month switcher | Dual Gregorian + Hijri pills | Single Gregorian month selector |
| Focus Reduce Motion | Flat fill bar + static drip | Not implemented |

---

## UIKit Additions Required (Summary)

### NET-NEW (does not exist at all):
- EmptyState widget
- ErrorState widget
- CalendarDayCell
- DualCalendarHeader
- DualDate value object spec
- PrayerCard compact variant spec
- PrayerCard expanded variant spec (arc + progress bar + Hijri date)
- AthkarProgressCard spec
- AthkarSessionSheet spec
- iOS Widget visual specs (all 3 widgets × 3 sizes)
- SyncStatusCard
- Role chip variants
- numericMono text style

### MUST-EXTEND (exists but needs spec update):
- AdaptiveShell/AdaptiveScaffold (architectural clarification)
- PrayerCard (moon font, arc, progress bar, variants)
- HabitCard (grid variant, streak ring)
- SettingsToggleTile (indentation levels)
- ModuleFlags block (unified settings section)
- BottomSheetForm (base extraction)

---

## High-Priority Gaps

1. **Calendar dual display** — Fundamental UX behavior change affecting every user who uses the calendar. Requires complete component rebuild. Designer must sign off on exact spec before a single line of code is changed.

2. **Calibri font** — Design system primary font not in Flutter project. Every Arabic text render is wrong per design spec. Requires immediate designer decision.

3. **Stats data layer** — Stats cubit is a stub. Cannot visually redesign until data definitions are agreed.

4. **Prayer card variants** — The hero dashboard element has no compact/expanded spec in a readable format (comp-prayer-card.html not read). This must be provided.

5. **Athkar spec** — Zero design coverage for a core daily-use feature.

6. **iOS widget specs** — Zero visual design spec for widget family.

---

## Dangerous Assumptions to Avoid

1. **Do NOT assume `modules.prayer` is a single boolean** — it is a 4-level hierarchy after Phase 8.1
2. **Do NOT assume calendar can be "refreshed"** — simultaneous dual display requires a near-complete rebuild
3. **Do NOT assume Athkar = Habit** — different data model, different interaction, different widget
4. **Do NOT assume stats just needs chart styling** — the entire data layer needs building
5. **Do NOT assume Focus is complete** — `oil_animation.dart` has partial implementation; full spec audit needed
6. **Do NOT rename `WidgetKeys` constants** — breaks installed widgets on all user devices

---

## Questions for Claude Design

1. **Calibri:** Is it the required brand font? If yes, provide all required weights (bold too? Only 3 weights in font folder). If no, is Cairo accepted as the final ship font?

2. **Athkar UX:** Please provide a dedicated Athkar design spec. What is the component hierarchy? How is it visually distinct from habits?

3. **Calendar toggle vs simultaneous:** Will `isHijriMode` still exist as a setting (Hijri as primary numeral, Gregorian as secondary — vs reverse)? Or is it removed?

4. **AdaptiveShell file location:** Should it be `lib/core/design_system/widgets/adaptive_shell.dart` (new) or is renaming/moving `lib/core/layouts/adaptive_scaffold.dart` acceptable?

5. **Prayer card:** Can you provide the contents of `preview/comp-prayer-card.html` as a spec summary? Specifically: exact layout of compact variant, exact layout of expanded variant, sunrise/sunset arc design, progress bar design.

6. **Stats KPIs:** Define the 5–10 KPIs shown on Stats page. Include: metric name, data source (which domain), calculation formula.

7. **Reduce Motion / Disable Gyroscope:** Where in Settings do these toggles live? New "Accessibility" section? Under Focus settings?

8. **iOS Widget specs:** Create visual specs for Prayer/Task/Habit × small/medium/large. Include: layout, typography, icon usage, data fields shown.

9. **Paywall:** What does the paywall card component look like? Please add it to the UIKit.

10. **Sync status:** Where does sync status appear (settings banner, dashboard indicator, or both)? What visual states are needed?

---

## Exact Requested Updates to the UIKit/Design System

### Immediate (before any Phase A coding begins):

1. Add `EmptyState` component spec to UIKit with feature-specific variants
2. Add `ErrorState` component spec to UIKit
3. Confirm Calibri vs Cairo decision and update `colors_and_type.css` font stack accordingly
4. Add `numericMono` text style to `colors_and_type.css` and `AtharTypography`
5. Add tabular figures note to all numeric text style specs

### Before Phase C (Dashboard):

6. Add `PrayerCard` compact + expanded variant specs to UIKit (extract from comp-prayer-card.html + annotate)
7. Define prayer card user preference storage (compact/expanded)

### Before Phase G (Calendar):

8. Create `CalendarDayCell` component spec with simultaneous dual-numeral layout
9. Create `DualCalendarHeader` component spec
10. Clarify `isHijriMode` behavior after simultaneous display lands
11. Define `TimelineItem` entity spec (cross-domain calendar dots)

### Before Phase E (Athkar):

12. Create dedicated Athkar/Dhikr UX spec (component hierarchy, interaction model, visual language)
13. Clarify `athkar_card.dart` (habits presentation) vs `lib/features/dhikr/` relationship

### Before Phase H (iOS Widgets):

14. Create iOS widget visual specs for all 3 widgets × 3 sizes (small/medium/large)

### Before Phase F (Settings):

15. Create `ModuleFlags` unified settings section design
16. Create `PrayerToggleTile` hierarchy visual spec (master → sub → sub-sub indentation)
17. Define Reduce Motion + Disable Gyroscope settings location

### Before Phase I (Stats):

18. Define Stats KPI list with data sources
19. Create `StatsMetricCard` component spec
20. Create `ChartCard` component spec
