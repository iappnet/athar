# AdaptiveShell Rollout Status

**Date:** 2026-06-01  
**Source of truth:** `IPAD_OPTIMIZATION.md` (3-layer spec)  
**Infrastructure status:** `AdaptiveShell` + `ShellBreakpoint` COMPLETE (PR2 Layer 1)

---

## Infrastructure Layer (Layer 1) — COMPLETE ✅

| Component | File | Status | Notes |
|-----------|------|--------|-------|
| `ShellBreakpoint` enum | `adaptive_shell.dart` | ✅ Complete | phone / tabletCompact / tabletExpanded / desktop |
| `AdaptiveShell` LayoutBuilder widget | `adaptive_shell.dart` | ✅ Complete | `LayoutBuilder` (Split View / Stage Manager safe) |
| Shell wired into `MainPage` | `main_page.dart` | ✅ Complete | Wraps outermost Scaffold |
| Phone branch: `LiquidGlassNavBar` at bottom | `main_page.dart` | ✅ Complete | Glass dock, `extendBody: true` |
| Tablet compact rail (600–839dp): icon-only 72pt | `main_page.dart` | ✅ Complete | No expand toggle in compact mode |
| Tablet expanded rail (840dp+): togglable 72→200pt | `main_page.dart` | ✅ Complete | Chevron toggle, landscape auto-expand |
| RTL rail placement (trailing edge) | `main_page.dart` | ✅ Complete | `Row(isRTL ? [content, rail] : [rail, content])` |
| RTL chevron flip + animation | `main_page.dart` | ✅ Complete | `AnimatedRotation` |
| Tablet FAB (FloatingActionButton.large) | `main_page.dart` | ✅ Complete | Replaces dock FAB pill on tablet |
| FAB pill shape (22px pill, forest gradient) | `liquid_glass_nav_bar.dart` | ✅ Complete | Phone only |
| Stage Manager / Split View compatibility | `adaptive_shell.dart` | ✅ Complete | `LayoutBuilder` handles width changes |
| Sidebar collapse (<600dp Stage Manager window) | `adaptive_shell.dart` | ✅ Complete | Falls through to phone branch |

---

## Screen Rollout — Per-Screen Tablet Layouts (Layer 2)

### Dashboard

**Spec:** `IPAD_OPTIMIZATION.md §1` — 2-col portrait / 3-col landscape; prayer card capped at 480pt  
**Target file:** `lib/features/home/presentation/pages/dashboard_page.dart`

| Feature | Status | Notes |
|---------|--------|-------|
| Content width capping (`isTablet ? maxContentWidth`) | Partial | Pre-existing; not spec-compliant multi-col |
| 2-col portrait layout (40%/60%) | Not Started | |
| 3-col landscape layout (28%/42%/30%) | Not Started | |
| Prayer card capped at 480pt | Not Started | |

**Overall: Not Started** (has only a basic width cap)

---

### Prayer

**Spec:** No dedicated tablet spec in IPAD_OPTIMIZATION.md (prayer appears as a card in Dashboard)  
**Target file:** `lib/core/design_system/molecules/cards/next_prayer_card.dart`

| Feature | Status | Notes |
|---------|--------|-------|
| Prayer card forest gradient (PR3) | ✅ Complete | `[0xFF0F3D2E, 0xFF1A5A45]` |
| Max width cap on tablet | Not Started | Spec says cap at 480pt inside Dashboard column |
| Tablet layout integration | Not Started | Dependent on Dashboard 2/3-col layout |

**Overall: Partial** (card redesigned; tablet sizing not implemented)

---

### Tasks

**Spec:** `IPAD_OPTIMIZATION.md §2` — master-detail pane; no push on iPad; Hero transition; right-rail at ≥1200dp  
**Target files:** `lib/features/task/presentation/pages/`

| Feature | Status | Notes |
|---------|--------|-------|
| Content width capping | Partial | Pre-existing `maxContentWidth` cap |
| `TaskMasterDetailPage` widget | Not Started | |
| Selected task side pane | Not Started | |
| Empty state for side pane | Not Started | |
| Hero title transition (phone→tablet split) | Not Started | |
| Right-rail (3rd column at ≥1200dp) | Not Started | |

**Overall: Not Started** (has only a basic width cap)

---

### Habits

**Spec:** `IPAD_OPTIMIZATION.md §3` — 2-col portrait / 3-col landscape `ResponsiveGrid`; permanent right pane  
**Target files:** `lib/features/habits/presentation/pages/habit_page.dart` + `habit_details_page.dart`

| Feature | Status | Notes |
|---------|--------|-------|
| Content width capping | Partial | Pre-existing `maxContentWidth` cap |
| 2-col grid (`tabletColumns: 2`) | Not Started | |
| 3-col grid (`desktopColumns: 3`) | Not Started | |
| `HabitDetailsBody` scaffold-less widget | Not Started | |
| Permanent right pane on landscape | Not Started | |

**Overall: Not Started** (has only a basic width cap)

---

### Calendar

**Spec:** `IPAD_OPTIMIZATION.md §4` — week view portrait; full month grid landscape + side timeline  
**Target file:** `lib/features/calendar/presentation/pages/calendar_page.dart`

| Feature | Status | Notes |
|---------|--------|-------|
| Content width capping | Partial | Pre-existing `maxContentWidth` cap |
| Week view default (portrait tablet) | Not Started | |
| Full month grid (landscape) | Not Started | |
| Side timeline of selected day | Not Started | |
| Multi-source day dots (task/habit/prayer/health) | Not Started | Requires `TimelineItem` cubit unification |
| Synced month grid ↔ side timeline selection | Not Started | |

**Overall: Not Started** (has only a basic width cap; PR4a/PR4b will address)

---

### Athkar / Dhikr

**Spec:** No explicit tablet spec in IPAD_OPTIMIZATION.md  
**Target files:** `lib/features/dhikr/`

| Feature | Status | Notes |
|---------|--------|-------|
| Tablet layout | Not Started | No spec; no current tablet handling |

**Overall: Not Started** (no spec; deferred until PR7 or dedicated review)

---

### Stats

**Spec:** `IPAD_OPTIMIZATION.md §6` — 2-col chart grid portrait / 3-col dashboard landscape; sparkline rail  
**Target file:** `lib/features/stats/presentation/pages/stats_page.dart`

| Feature | Status | Notes |
|---------|--------|-------|
| Content width capping | Not Started | NO current tablet handling |
| 2-col chart grid (`ResponsiveGrid`) | Not Started | |
| 3-col landscape + sparkline rail | Not Started | |

**Overall: Not Started** (PR6 will address)

---

### Settings

**Spec:** `IPAD_OPTIMIZATION.md §7` — two-pane: category list 280pt + content pane  
**Target files:** `lib/features/settings/presentation/pages/settings_page.dart` + sub-pages

| Feature | Status | Notes |
|---------|--------|-------|
| Content width capping | Not Started | NO current tablet handling |
| Category list pane (280pt leading edge) | Not Started | |
| Content pane (trailing) | Not Started | |
| `selectedCategory` local state | Not Started | |
| Deep-link pre-selection on iPad | Not Started | |
| Phone: push navigation unchanged | ✅ Current behavior | No regression |

**Overall: Not Started** (phone layout intact; tablet two-pane not implemented)

---

### Widgets (iOS Widgets)

**Spec:** Visual-only refresh assigned to PR9 (separate from IPAD_OPTIMIZATION.md)  
**Target files:** `ios/AtharPrayerWidget/`, `ios/AtharTaskWidget/`, `ios/AtharHabitWidget/`

| Feature | Status | Notes |
|---------|--------|-------|
| Interactive widget infrastructure (Phases 2–4) | ✅ Complete | AppIntent, pending-action queue |
| Visual v2 refresh | Not Started | PR9 |

**Overall: Infrastructure Complete, Visual Refresh Not Started**

---

### Onboarding

**Spec:** `IPAD_OPTIMIZATION.md §9` — centered card 560pt portrait / 2-col 960pt landscape  
**Target file:** `lib/features/home/presentation/pages/onboarding_page.dart` (Variant A exists)

| Feature | Status | Notes |
|---------|--------|-------|
| Variant A (current) | ✅ Exists | Must not regress |
| Centered card 560pt (portrait iPad) | Not Started | |
| 2-col 960pt (landscape iPad) | Not Started | |
| Variants B/C/D | Not Started | PR-ONBOARD-AB |

**Overall: Not Started for tablet** (Variant A exists for phone; tablet adaptation is PR-ONBOARD-AB scope)

---

## Layer 3 — iPad-Only Affordances (cross-cutting)

| Affordance | Spec ref | Status | Planned artifact |
|------------|----------|--------|-----------------|
| Hover states (`MouseRegion`) | §10.1 | Not Started | `PR-IPAD-LAYER3` |
| Keyboard shortcuts | §10.2 | Not Started | `lib/core/keyboard/athar_shortcuts.dart` does not exist |
| Context menus (`CupertinoContextMenu`) | §10.3 | Not Started | `PR-IPAD-LAYER3` |
| Drag-and-drop (internal + external) | §10.4 | Not Started | `PR-IPAD-LAYER3` |
| Apple Pencil / Scribble | §10.5 | Not Started | `PR-IPAD-LAYER3` |
| Stage Manager / Split View | §10.6 | ✅ Complete | AdaptiveShell `LayoutBuilder` |
| External display validation | §10.7 | Deferred | Device QA gate |
| Stage Manager small window collapse | §10.8 | ✅ Complete | AdaptiveShell phone branch |

---

## Dormant Legacy Files

| File | Status | Action needed |
|------|--------|---------------|
| `lib/core/layouts/adaptive_scaffold.dart` | Dormant — `AdaptiveShell` is the replacement | Remove in PR-CLEANUP |
| `lib/features/home/presentation/pages/home_page_responsive.dart` | Uses `AdaptiveScaffold` — likely orphaned | Verify usage, remove in PR-CLEANUP |

---

## Summary Matrix

| Screen / Area | Layer 1 (shell) | Layer 2 (screen layout) | Layer 3 (affordances) | Overall |
|---------------|-----------------|------------------------|----------------------|---------|
| Shell / MainPage | ✅ Complete | ✅ (NavigationRail is tablet layout) | — | ✅ |
| Dashboard | ✅ (shell routes correctly) | Not Started | Not Started | Partial |
| Prayer card | ✅ (shell routes correctly) | Not Started (cap/sizing) | Not Started | Partial |
| Tasks | ✅ | Not Started | Not Started | Not Started |
| Habits | ✅ | Not Started | Not Started | Not Started |
| Calendar | ✅ | Not Started | Not Started | Not Started |
| Athkar / Dhikr | ✅ | Not Started (no spec) | Not Started | Not Started |
| Stats | ✅ | Not Started | Not Started | Not Started |
| Settings | ✅ | Not Started | Not Started | Not Started |
| Focus | ✅ | Not Started | Not Started | Not Started |
| Spaces | ✅ | Not Started | Not Started | Not Started |
| Onboarding | ✅ | Not Started | Not Started | Not Started |
| iOS Widgets | N/A | N/A | N/A | Infra ✅ / Visual PR9 |
| Hover states | — | — | Not Started | Not Started |
| Keyboard shortcuts | — | — | Not Started | Not Started |
| Context menus | — | — | Not Started | Not Started |
| Drag-and-drop | — | — | Not Started | Not Started |

---

## Recommended Rollout Plan

The per-screen tablet work should be added to the existing feature PRs (not a new PR), following IPAD_OPTIMIZATION.md's recommended order:

| Priority | Screen | Where to add tablet branch | Spec ref |
|----------|--------|---------------------------|----------|
| 1 | Settings | PR5 (Accessibility Settings) — touch same file | §7 |
| 2 | Dashboard | Add to PR4a scope or a new PR-DASHBOARD-TABLET | §1 |
| 3 | Calendar | PR4b (already planned for calendar rebuild) | §4 |
| 4 | Habits | Add tablet branch during PR-HABITS-REDESIGN | §3 |
| 5 | Stats | PR6 (Stats redesign already includes this) | §6 |
| 6 | Tasks | Add tablet branch during future task redesign | §2 |
| 7 | Focus | PR8 (720pt cap is simple) | §5 |
| 8 | Spaces | Future spaces PR | §8 |
| 9 | Onboarding | PR-ONBOARD-AB | §9 |
| — | Layer 3 affordances | Dedicated `PR-IPAD-LAYER3` (after screens settled) | §10 |
