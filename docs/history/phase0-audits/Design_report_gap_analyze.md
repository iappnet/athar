# Design Gap Analysis — Master Report

**Project:** Athar (أثر) — Islamic Productivity App  
**Date:** 2026-05-06  
**Auditor:** Claude Code (audit-only session)  
**Design System:** `/Users/itech/Development/new_projects/Athar Design System/`  
**Flutter Project:** `/Users/itech/Development/new_projects/athar/`

---

## 1. Executive Summary

Athar is a mature Flutter application with a well-structured token system and clean architecture. The design system is ambitious and detailed. The gap between the two is **significant but addressable** — provided implementation follows the prescribed audit-first order and respects the critical constraints detailed in Phase 8.x bug-fix history.

**The three most critical findings are:**

1. **Calendar is fundamentally wrong** relative to the design spec. The app has a Hijri/Gregorian toggle; the spec requires simultaneous dual display (Apple Calendar style). This is not a visual refresh — it is a near-complete calendar widget rebuild requiring new value objects, new cell widgets, and calendar cubit changes. It must be treated as a new feature, not a refactor.

2. **88 files have hardcoded colors** that bypass the token system and break dark mode. No visual redesign can land reliably until this is cleaned up. This is Phase A prerequisite work.

3. **Prayer architecture is more granular than the design system expects.** The app has a 4-level prayer toggle hierarchy (master → card → notifications → 15-min reminder) from recent Phase 8.1 work. The design system's `REDESIGN_AUDIT.md` references a simple `modules.prayer` boolean. Any design work on prayer settings must honor the existing 4-level architecture.

**Readiness verdict: PARTIALLY READY — design gaps must be fixed first.**

Specific design additions required (EmptyState, ErrorState, CalendarDayCell, PrayerCard variants, Athkar spec, iOS widget specs) before implementation of those areas can begin.

---

## 2. Design System Coverage Summary

| Token/Concept | Coverage | Notes |
|---|---|---|
| Color tokens (light) | ✅ Full | Exact match CSS ↔ Dart |
| Color tokens (dark) | ✅ Full | Both themes defined |
| Prayer gradient | ✅ Full | Static const, correct |
| Spacing | ✅ Full | 12 steps, exact match |
| Radius | ✅ Full | 9 steps, confirmed |
| Shadows | ✅ Full | Two-layer system |
| Motion | ✅ Full | 3 durations + custom cubic |
| Typography scale | ⚠️ Partial | Scale matches; font conflict (Calibri vs Cairo) |
| Font families | ❌ Conflict | Design says Calibri primary; Flutter uses Cairo |
| Icon spec | ❓ Unclear | No icon sheet found |
| Components | ⚠️ Partial | Some exist, many missing |
| Empty states | ❌ Missing | No spec in design system |
| Error states | ❌ Missing | No spec in design system |
| iOS widget specs | ❌ Missing | No design for any widget size |
| Athkar spec | ❌ Missing | Not designed |
| Calendar dual display | ⚠️ Spec exists | Implementation missing in Flutter |
| AdaptiveShell | ⚠️ Spec exists | Implementation incomplete |
| Stats visual spec | ⚠️ In JSX | Not read; cubit stub |

---

## 3. Current Flutter UI Coverage Summary

| Surface | Exists | Token Compliant | Design Spec Met | Gap |
|---|---|---|---|---|
| App navigation bar | ✅ | ⚠️ 88 hardcoded files | ⚠️ Partial | Backdrop, 5 dests, new brand |
| AdaptiveShell (iPad) | ⚠️ Partial | — | ❌ Not complete | NavigationRail branch not per spec |
| Dashboard | ✅ | ⚠️ Partial | ⚠️ Partial | 3 dup pages, greeting bug, iPad layouts |
| Prayer card | ✅ | ⚠️ Partial | ⚠️ Partial | Compact/expanded, arc, progress bar |
| Prayer settings | ✅ | ✅ | ✅ | Phase 8.1 complete |
| Tasks | ✅ | ⚠️ Partial | ⚠️ Partial | Quick-add, smart-time, iPad master-detail |
| Habits | ✅ | ⚠️ Partial | ⚠️ Partial | Grid view, streak ring, iPad |
| Athkar | ✅ | ❓ | ❌ No spec | Needs designer spec first |
| Calendar | ✅ | ⚠️ Partial | ❌ Toggle ≠ Dual | Near-complete rebuild needed |
| Focus | ✅ | ⚠️ Partial | ❓ Partial | Full spec audit needed |
| Stats | ⚠️ Stub | ⚠️ Partial | ❌ Stub | Data layer + visual build |
| Settings | ✅ | ⚠️ Partial | ⚠️ Partial | iPad two-pane, Modules block |
| Spaces | ✅ | ⚠️ Partial | ⚠️ Partial | iPad 3-col permission matrix |
| Onboarding | ✅ (wrong folder) | ⚠️ Partial | ⚠️ Partial | Move to dedicated feature |
| Subscription | ✅ | ❓ | ❓ | Visual not audited |
| iOS Widgets | ✅ | N/A | ⚠️ Partial | No visual spec; 3 known bugs |
| Empty states | ❌ | N/A | ❌ | Net-new component needed |
| Error states | ⚠️ Inline only | N/A | ❌ | Systematic widget needed |
| Loading states | ⚠️ Partial | N/A | ⚠️ Partial | Skeleton not systematically used |

---

## 4. Major Gaps

### Gap 1: Calibri Font (CRITICAL)
The design system CSS defines `--font-ar: 'Calibri', 'Cairo', 'Inter'` — Calibri is the primary brand font for Arabic. The Flutter project uses Cairo as primary. Calibri is present in the design system `fonts/` folder (3 weights: light/regular/bold) but **not in `pubspec.yaml`**. Every Arabic text render is technically incorrect per the design spec. This must be resolved before Phase A token migration.

### Gap 2: Calendar Dual Display (CRITICAL)
The app currently toggles between Hijri-only and Gregorian-only views. The design spec (CALENDAR_FOCUS_REDESIGN.md §A) requires both numerals visible simultaneously in every day cell — like Apple Calendar's alternate calendar overlay. New components required: `DualDate` value object, `CalendarCell` widget, `DualMonthSwitcher`. New behavior: RTL positions swap Hijri/Gregorian priority. First-of-Hijri-month cells show month name + hairline. Calendar fan-in from tasks/habits/prayer requires `TimelineItem` entity.

### Gap 3: Stats Data Layer (HIGH)
Stats cubit is a stub. `IStatsRepository` is nearly empty. No KPI definitions. Charts (`fl_chart`) are available but no live data to show. This is not a visual refactor — it's a data architecture build followed by a visual build.

### Gap 4: 88 Hardcoded Color Files (HIGH)
88 files use `Color(0x...)` or `Colors.*` hardcoded values that bypass the `AtharColors` token system. These files will not respond to dark mode changes, theme updates, or the forest-green brand update. Must be systematically cleaned before any other visual work.

### Gap 5: Missing UIKit Components (HIGH)
EmptyState, ErrorState, AdaptiveShell (spec-compliant), PrayerCard compact/expanded variants, CalendarDayCell, DualCalendarHeader, AthkarProgressCard, iOS widget specs, SyncStatusCard — all missing from design system and/or Flutter.

### Gap 6: Athkar Has No Design Spec (HIGH)
The Athkar feature (`athkar_card.dart`, `athkar_session_sheet.dart`, `lib/features/dhikr/`) exists in Flutter but has zero coverage in the design system. REDESIGN_AUDIT.md mentions "Dhikr ribbon / sheet" only in passing. A dedicated Athkar UX spec must be created by the designer before any Athkar redesign.

### Gap 7: iOS Widget Visual Specs (HIGH)
Three iOS widgets (Prayer/Task/Habit) each have 3 size variants (small/medium/large) with no design spec in the design system. Recent Phase 4/5 fixes addressed locale and Athkar inclusion but the visual design for these widgets is unspecced.

---

## 5. High-Risk Areas

| Area | Risk Level | Reason |
|---|---|---|
| Calendar rebuild | VERY HIGH | Near-complete widget rebuild; DualDate entity; cubit fan-in |
| Prayer toggle hierarchy | CRITICAL | Phase 8.1 recently refined; 4-level hierarchy; save-ordering constraints |
| Central NavBar `+` dispatch | CRITICAL | Phase 1/2/3 fixes; SubscriptionCubit singleton; _isSaving guards |
| Athkar redesign | HIGH | No spec; not a habit clone; must not be merged with habits |
| iOS widget changes | HIGH | WidgetKeys must not be renamed; App Group must not change |
| Stats data layer | HIGH | No repository implementation; cross-domain fan-in complexity |
| Font migration (Calibri) | HIGH | All Arabic text renders affected; layout shifts likely |
| Hardcoded color cleanup | MEDIUM | 88 files; risk of missed replacements |
| AdaptiveShell | MEDIUM | Affects every screen; must use LayoutBuilder not MediaQuery |
| Focus oil animation | MEDIUM | Complex physics/animation; 60fps budget; partial existing implementation |

---

## 6. Missing UIKit Components

### Tier 1 — Blocking (must exist before implementation begins in those areas)
| Component | Blocking What |
|---|---|
| EmptyState | iPad master-detail pane; all list screens |
| ErrorState | All data screens |
| AdaptiveShell (spec-compliant) | All iPad layouts |
| CalendarDayCell | Calendar rebuild |
| DualCalendarHeader | Calendar rebuild |
| PrayerCard compact + expanded spec | Dashboard redesign |
| AthkarProgressCard spec | Athkar redesign |
| iOS widget visual specs | iOS widget redesign |

### Tier 2 — Required but not immediately blocking
| Component | For |
|---|---|
| numericMono text style | Habit streak, stats, timer |
| SyncStatusCard | Settings, dashboard |
| Role chip variants | Spaces |
| SmartTimeChip | Task add sheet |
| ModuleFlags settings block | Settings redesign |
| PrayerToggleTile hierarchy | Settings redesign |

### Tier 3 — Quality improvements
| Component | For |
|---|---|
| AtharSheetHeader (extract) | All bottom sheets |
| BottomSheetForm base | All add flows |
| AtharSectionHeader (formalize) | All list screens |
| StatsMetricCard | Stats page |
| ChartCard | Stats page |
| PaywallCard spec | Subscription |

---

## 7. UX Gaps

1. **Prayer card user preference (compact/expanded)** — No persistence mechanism defined. Where in UserSettings does this live? Not currently in the model.

2. **Smart-time input in add sheets** — `SmartTimeParser` exists in time engine but no UI chip widget uses it in add task/habit sheets.

3. **Eastern Arabic numerals** — No `useEasternNumerals` preference in UserSettings. No `NumberFormat` formatting in any confirmed widget.

4. **Focus Reduce Motion** — Full Focus spec requires `SettingsCubit.reduceMotion` flag. Not implemented. Where in Settings?

5. **Disable Gyroscope** — Independent toggle from Reduce Motion. Not implemented. Where in Settings?

6. **Widget locale bug** — `LocaleCubit.setLocale()` does not update `athar_app_locale` in UserDefaults. iOS widget language doesn't change when user changes app language. (KNOWN_PROBLEMS P1.)

7. **Calendar `TimelineItem`** — No unified timeline entity for cross-domain calendar dots. Tasks/habits/prayer don't fan into calendar.

8. **Stats period selector** — What time periods can be selected? Day/Week/Month/Year? Not defined.

---

## 8. Visual Gaps

1. **Prayer countdown font** — Spec calls for JetBrains Mono tabular. Not confirmed in `next_prayer_card.dart` (file read in session context but font override not seen in comments that were visible).

2. **Habit streak ring** — Visual ring spec not confirmed to design target.

3. **Habit grid layout** — Currently a list. Design spec shows grid.

4. **Dashboard greeting** — Uses `DateTime.hour < 12` instead of `AtharTimeCalculator`. Results in imprecise Islamic time period greetings.

5. **Bottom nav backdrop filter** — REDESIGN_AUDIT §11 specifies `BackdropFilter(blur: 20)` over forest-green tinted surface. Not confirmed as current implementation.

6. **Loading/skeleton states** — `athar_skeleton.dart` exists but not confirmed as systematically used. Prayer card uses inline `CircularProgressIndicator`.

---

## 9. Localization / RTL Gaps

1. **88 hardcoded-color files** — Many also likely have `EdgeInsets.left/right` violations. Systematic audit needed.

2. **Calendar RTL** — Hijri numeral primary position (top-right) in RTL vs secondary (bottom-left in LTR). Not implemented — new CalendarCell must handle this.

3. **Calibri** — 3 weights in design system folder vs Cairo's 4 weights in Flutter. If Calibri is adopted, Arabic text at `fontWeight: 700` (SemiBold 600 and Bold 700) needs checking.

4. **Widget locale P1 bug** — iOS widgets don't pick up language change from in-app toggle.

5. **Eastern Arabic numerals** — Not implemented anywhere. Should prayer times show `٣:٤٥` or `3:45` in Arabic locale?

---

## 10. iOS Widget Gaps

1. **No visual design spec** — Zero coverage in design system for any widget size or variant.

2. **Widget locale P1** — `athar_app_locale` not updated by `LocaleCubit.setLocale()`.

3. **Widget cache misses (P2/P3)** — `toggleTaskCompletionByUuid` and habit completion/increment cache misses drop widget actions.

4. **Widget dark mode** — WidgetKit handles light/dark automatically but the visual design for dark widget has not been audited.

5. **Widget medium/large variants** — Current Phase 4/5 fixes audited small widget behavior. Medium and large are unaudited.

6. **Prayer widget relationship to isPrayerCardEnabled** — Phase 8.1 added `isPrayerCardEnabled` to the app. The iOS prayer widget has its own data path and is not gated by this setting. Is this correct? Should the widget respect `isPrayerCardEnabled`? Unclear.

---

## 11. Prayer / Athkar / Calendar / Stats Special Risks

### Prayer
- 4-level toggle hierarchy is more granular than any other app feature
- Save-ordering constraint: must save to Isar before calling any scheduler
- Scheduler ID range 100000–199999 must not collide
- Auto-renewal mechanism (`handleAutoRenewal`) must survive any design changes
- Phase 8.1 migration (`didMigratePrayerFeatureSettings`) is a one-time flag — cannot be reset

### Athkar
- Not a habit clone — architectural, data model, and UI distinction is critical
- `HabitType.athkar` vs `HabitType.regular` affects iOS widget rendering
- The relationship between `lib/features/dhikr/` and the athkar components in `lib/features/habits/presentation/widgets/` is architecturally unclear — must be resolved before redesign
- Haptic feedback on counter increment must be preserved

### Calendar
- This is the highest-implementation-risk area in the entire app
- `package:hijri ^3.0.0` must stay — do not remove or downgrade
- `HijriService` must stay
- `isHijriMode` UserSettings field behavior changes: from "toggle view" to "set primary numeral position" — existing users with `isHijriMode: true` will see a behavior change
- Fan-in from tasks/habits/prayer requires touching `CalendarCubit`, which must remain subscription-aware

### Stats
- Not just visual — requires net-new `StatsRepository` implementation
- Must fan in from: `TaskRepository`, `HabitRepository`, `FocusCubit.history`, `PrayerRepository`
- Must respect subscription gates (some stats may be pro-only)
- Must not create a 4th source of truth for task/habit data

---

## 12. Recommended Implementation Roadmap

| Phase | Scope | Risk | Est. PRs |
|---|---|---|---|
| A | Tokens + font decision + hardcoded color cleanup (88 files) | MEDIUM | 2-3 |
| B | Shared UIKit: EmptyState, ErrorState, AdaptiveShell, AtharSheetHeader, SyncStatusCard | LOW-MEDIUM | 2-3 |
| C | Dashboard: merge 3 pages, fix greeting, prayer card refresh, iPad layouts | MEDIUM | 1-2 |
| D | Tasks + Habits: token refresh, grid habits, iPad master-detail | MEDIUM | 2 |
| E | Prayer + Athkar: card variants, Athkar (blocked on spec) | HIGH | 2 |
| F | Settings + Forms: iPad two-pane, Modules block, Reduce Motion | LOW-MEDIUM | 2 |
| G | Calendar: full rebuild + DualDate + CalendarCell + fan-in | VERY HIGH | 3-4 |
| G | Stats: data layer + charts | HIGH | 2-3 |
| H | iOS Widgets: widget bugs (P1/P2/P3) + visual (blocked on spec) | HIGH | 1-2 |
| I | Polish: accessibility, hover, keyboard shortcuts, drag-and-drop | LOW | 3-4 |

**Total estimated PRs:** 20–28  
**Estimated to be blocked on designer input:** Phases E (Athkar), G (Calendar spec sign-off), H (widget visual specs), and Calibri decision

---

## 13. Required Next Action for Claude Design

**Immediate (within 1 sprint):**

1. **Calibri decision:** Confirm or deny Calibri as the required Arabic font. If confirmed, provide all weights needed. If Cairo is accepted, update `colors_and_type.css` to remove Calibri.

2. **Add EmptyState to UIKit:** Feature-specific variants (Tasks empty, Habits empty, Stats empty, Calendar empty) + generic + iPad detail-pane variant.

3. **Add ErrorState to UIKit:** Full-page, inline card, compact variants.

4. **Confirm PrayerCard spec:** Extract compact + expanded specs from `comp-prayer-card.html` as a readable component spec in `design-context/`. Include arc design, progress bar, Hijri date placement.

5. **Confirm AdaptiveShell location:** Is it `lib/core/design_system/widgets/adaptive_shell.dart` (new file) or rename of `lib/core/layouts/adaptive_scaffold.dart`?

**Before Calendar work begins:**

6. **Calendar dual display sign-off:** Provide a written spec decision on `isHijriMode` behavior (toggle gone? primary numeral choice?). Sign off on `DualDate` entity definition.

7. **Confirm CalendarCell exact pixel spec:** Gregorian numeral size (14px?), Hijri numeral size (10px?), relative positions (top-right / bottom-left), hairline color token, first-of-Hijri-month cell layout.

**Before Athkar work begins:**

8. **Create Athkar UX spec:** Counter interaction model, session flow, card visual hierarchy, relationship between `dhikr/` feature folder and habits presentation widgets.

**Before iOS widget work begins:**

9. **Create iOS widget visual specs:** All 3 widgets × 3 sizes (small/medium/large). Include layout, typography, icon usage, data fields shown per size.

**Before Stats work begins:**

10. **Define KPI list:** Which metrics are shown, which are pro-only, what time periods are available.

---

## 14. Final Implementation Readiness Verdict

### **PARTIALLY READY — DESIGN GAPS MUST BE FIXED FIRST**

**Ready now (Phase A):**
- Token migration (colors, spacing, radii, shadows) — all tokens match, just need to replace hardcoded values
- Font decision (blocks everything, must be first)

**Blocked on designer decisions:**
- Calibri decision → blocks all typography work
- Athkar spec → blocks all Athkar UI work
- Calendar dual-display spec sign-off → blocks all calendar work
- iOS widget visual specs → blocks widget visual work
- PrayerCard compact/expanded spec → blocks dashboard prayer card work
- EmptyState + ErrorState UIKit additions → blocks iPad master-detail and systematic empty/error handling
- Stats KPI definitions → blocks stats data layer work

**What can proceed immediately (after token/font decision):**
1. Phase A: Token cleanup in 88 files (hardcoded colors → tokens)
2. Phase B: EmptyState + ErrorState + AtharSheetHeader + SyncStatusCard (low-risk UIKit)
3. Phase C: Dashboard page consolidation (merge 3 dup pages), greeting fix, iPad layout stubs

**What must wait:**
- Calendar → designer spec required
- Athkar → designer spec required
- Full prayer card → designer spec required (comp-prayer-card.html content)
- iOS widgets → designer spec required
- Stats → KPI definitions required

---

*Audit completed: 2026-05-06*  
*No Dart code was modified during this audit.*  
*No UI implementation was started.*  
*All output files are in `design-context/` and `docs/ai/change-logs/`.*
