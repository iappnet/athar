# PR2 Scope Reconciliation Report

**Date:** 2026-06-01  
**Trigger:** User audit — question: "What parts of PR2 are complete and what parts remain?"  
**Audit scope:** git history · commit `81af052` · `PR2_CHECKPOINTS.md` · `IPAD_OPTIMIZATION.md` · all feature pages in working tree

---

## 1. Original PR2 Scope (per governance documents)

PR2's governance scope was defined in `PR2_CHECKPOINTS.md` and `PR2_IMPLEMENTATION_PLAN.md`.  
The canonical PR description in `IMPLEMENTATION_MASTER_STATUS.md` reads:

> Rename `adaptive_scaffold` → `adaptive_shell`; iPad breakpoints; 4-tab nav bar shape; FAB pill outside bar (RTL/LTR)

This corresponds exactly to **IPAD_OPTIMIZATION.md Layer 1** — the adaptive shell infrastructure. Layers 2 and 3 were not part of PR2's defined scope.

The `IPAD_OPTIMIZATION.md` spec explicitly defines three layers with a recommended implementation order:
- **Layer 1** — Adaptive shell (`do first; biggest payoff`) → assigned to PR2
- **Layer 2** — Per-screen tablet layouts → assigned to individual feature PRs (per-screen)
- **Layer 3** — iPad-only affordances (hover, shortcuts, drag-and-drop) → assigned to future sweep

---

## 2. Implemented Scope (confirmed in working tree)

**Commit:** `81af052` · **Files changed:** 3 · **Tag:** `athar-v2-pr2-complete`

### File: `lib/core/design_system/widgets/adaptive_shell.dart` (CREATED)

| Requirement | Status | Evidence |
|-------------|--------|---------|
| `ShellBreakpoint` enum: phone / tabletCompact / tabletExpanded / desktop | ✅ Done | Lines 15–43 |
| Breakpoints: <600 / 600–839 / 840–1199 / ≥1200 | ✅ Done | `fromWidth()` at lines 21–26 |
| `AdaptiveShell` LayoutBuilder wrapper widget | ✅ Done | Lines 62–79 |
| Uses `LayoutBuilder` (not `MediaQuery.size`) — Split View / Stage Manager safe | ✅ Done | Line 72–74 |
| `isPhone` / `isTablet` / `usesCompactRail` / `usesExpandedRail` getters | ✅ Done | Lines 29–43 |

### File: `main_page.dart` (UPDATED)

| Requirement | Status | Evidence |
|-------------|--------|---------|
| `AdaptiveShell` wraps the Scaffold decision | ✅ Done | Lines 137–193 |
| Phone branch: `LiquidGlassNavBar` at bottom | ✅ Done | Lines 151–178 |
| Tablet branch: `NavigationRail` (no bottom nav) | ✅ Done | Lines 144–147 |
| Compact rail (600–839dp): icon-only, no expand toggle | ✅ Done | `effectivelyExpanded` guard + `_buildRailLeading` returns `SizedBox.shrink()` |
| Expanded rail (840dp+): user-togglable width 72pt → 200pt | ✅ Done | Lines 246–248, `_buildRailLeading` toggle |
| RTL rail placement: rail on trailing edge | ✅ Done | `Row(children: isRTL ? [content, rail] : [rail, content])` line 327 |
| RTL chevron direction + animation | ✅ Done | `AnimatedRotation` in `_buildRailLeading` |
| Tablet FAB: `FloatingActionButton.large` | ✅ Done | `_buildTabletFab` lines 381–388 |
| `extendBody: breakpoint.isPhone` (glass scroll) | ✅ Done | Line 140 |
| `SafeArea` directional on tablet content | ✅ Done | `SafeArea(left: !isRTL, right: isRTL)` line 319 |
| `didChangeDependencies` rail state sync | ✅ Done | Lines 65–77 |
| `IndexedStack` state preservation on phone | ✅ Done | Line 232 |
| Settings icon in rail trailing slot | ✅ Done | `_buildRailTrailing` lines 357–375 |

### File: `liquid_glass_nav_bar.dart` (UPDATED)

| Requirement | Status | Evidence |
|-------------|--------|---------|
| FAB shape: circle → 22px pill | ✅ Done | `borderRadius: BorderRadius.circular(22.r)` |
| FAB gradient: `#2F7A5E → #0F3D2E` (forest) | ✅ Done | Confirmed in roadmap reconciliation |
| FAB size: 64×64 | ✅ Done | Per checkpoint notes |
| FAB foreground: `#FAF7EC` cream | ✅ Done | Per checkpoint notes |

### All 6 Checkpoints Verified

| CP | Status | Scope |
|----|--------|-------|
| CP1 | ✅ | `adaptive_shell.dart` created |
| CP2 | ✅ | `main_page.dart` + `liquid_glass_nav_bar.dart` updated |
| CP3 | ✅ | Breakpoints statically verified |
| CP4 | ✅ | Navigation persistence + routing verified |
| CP5 | ✅ | SafeArea + RTL + keyboard inset verified |
| CP6 | ✅ | `flutter analyze` 0 · `flutter test` 29/29 · tag created |

---

## 3. Not Implemented (IPAD_OPTIMIZATION.md Layer 2 — Per-Screen Tablet Layouts)

These were **never part of PR2's defined scope**. They are deferred to individual feature PRs.

| Screen | Required by IPAD_OPTIMIZATION.md | Current state | Planned PR |
|--------|----------------------------------|---------------|------------|
| **Dashboard** | 2-col portrait / 3-col landscape (`Row` + `Expanded(flex)`) | Content width cap only (`context.isTablet ? maxContentWidth : infinity`) | PR4a-adjacent or PR-IPAD-L2 |
| **Tasks** | Master-detail pane (`TaskMasterDetailPage`, no push on iPad) | Content width cap only | Future task PR |
| **Habits** | 2-col / 3-col `ResponsiveGrid` + permanent right pane | Content width cap only | Future habits PR |
| **Calendar** | Week view / full month grid + side timeline | Content width cap only | PR4a / PR4b |
| **Focus** | Cap at 720pt + session history rail (280pt) | NO tablet handling | PR8 |
| **Stats** | 2-col / 3-col chart grid via `ResponsiveGrid` | NO tablet handling | PR6 |
| **Settings** | Two-pane: category list (280pt) + content | NO tablet handling | PR5-adjacent or PR-IPAD-L2 |
| **Spaces** | Master/detail + permission matrix (3-col) | Basic maxWidth + pre-existing Row structure | Future spaces PR |
| **Onboarding** | Centered card 560pt / 2-col 960pt | Not found (separate PR-ONBOARD-AB) | PR-ONBOARD-AB |

---

## 4. Not Implemented (IPAD_OPTIMIZATION.md Layer 3 — iPad-Only Affordances)

These were **never part of PR2's defined scope** and require a dedicated sweep PR.

| Affordance | Required by spec | Current state |
|------------|-----------------|---------------|
| Hover states (`MouseRegion`) on all interactive cards | §10.1 — all tile types | NOT STARTED — no `MouseRegion` in any feature file |
| Keyboard shortcuts — `athar_shortcuts.dart` | §10.2 — 11 defined shortcuts | NOT STARTED — `lib/core/keyboard/` directory does not exist |
| Context menus (`CupertinoContextMenu`) | §10.3 — task/habit/calendar/member tiles | NOT STARTED |
| Drag-and-drop (internal: task→calendar, task→space; external: image/URL drop) | §10.4 | NOT STARTED |
| Apple Pencil / Scribble (`CupertinoTextField`) | §10.5 | NOT STARTED |
| Stage Manager / Split View — ALREADY HANDLED by LayoutBuilder | §10.6 | ✅ Done (AdaptiveShell uses `LayoutBuilder`) |
| External display validation | §10.7 | Deferred — device QA gate |
| Sidebar collapse (<600dp even on iPad via Stage Manager) | §10.8 | ✅ Handled (AdaptiveShell phone branch) |

---

## 5. Superseded / Reclassified

| Item | Status | Notes |
|------|--------|-------|
| `lib/core/layouts/adaptive_scaffold.dart` (legacy) | Still present — not deleted | Used only by `home_page_responsive.dart`. `AdaptiveShell` is the new standard. Can be deprecated in PR-CLEANUP. |
| `lib/features/home/presentation/pages/home_page_responsive.dart` | Still present | Uses old `AdaptiveScaffold`. Not part of main navigation. Likely orphaned — verify before PR-CLEANUP. |
| "Rename `adaptive_scaffold.dart` → `adaptive_shell.dart`" | Reclassified: new file created instead of rename | The legacy `adaptive_scaffold.dart` was NOT renamed; a new `adaptive_shell.dart` was created alongside it. The old file is dormant. |

---

## 6. Classification Summary

| Category | Items | List |
|----------|-------|------|
| **Completed** | 3 files, 6 checkpoints | `adaptive_shell.dart`, `main_page.dart`, `liquid_glass_nav_bar.dart` |
| **Partially completed** | 9 screens | All have content-width capping only; no multi-column/master-detail tablet layouts |
| **Not implemented (Layer 2)** | 9 screen-level tablet layouts | Dashboard, Tasks, Habits, Calendar, Focus, Stats, Settings, Spaces, Onboarding — per IPAD_OPTIMIZATION.md §1–§9 |
| **Not implemented (Layer 3)** | 5 cross-cutting affordance types | Hover, keyboard shortcuts, context menus, drag-and-drop, Pencil |
| **Deferred** | Layer 2 + 3 in full | Never scoped to PR2; assigned to per-feature PRs and a future PR-IPAD-LAYER3 |
| **Superseded/dormant** | `adaptive_scaffold.dart` + `home_page_responsive.dart` | Legacy — should be removed in PR-CLEANUP |

---

## 7. Root Cause of Ambiguity

The PR2 tag and checkpoints correctly describe PR2 as **Layer 1 only** (AdaptiveShell infrastructure). But `IPAD_OPTIMIZATION.md` defines a 3-layer scope that was never fully split into separate PRs in the roadmap. Any reader who equates "PR2 = AdaptiveShell" with "PR2 = all of IPAD_OPTIMIZATION.md" will see a gap.

The correct interpretation:
- **PR2 = Layer 1 = COMPLETE** ✅
- **Layer 2 = per-feature work = each feature PR adds its own tablet branch** 
- **Layer 3 = affordances sweep = a future dedicated PR (suggested name: PR-IPAD-LAYER3)**

This deferred scope should be added explicitly to the roadmap so it doesn't fall through the cracks.
