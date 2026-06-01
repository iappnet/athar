# Athar — iPad Optimization Plan

> Companion to `REDESIGN_AUDIT.md`. Same per-screen ticket format, but
> focused on making Athar a first-class iPad app — not a stretched phone.
>
> Read `SKILL.md` for architecture rules and `REDESIGN_AUDIT.md` for the
> phone redesign tickets first. This doc adds the **layout adapters,
> master-detail compositions, keyboard shortcuts, drag-and-drop, and
> Pencil affordances** that elevate iPad to perfect.

---

## TL;DR — what's already there vs. what's missing

### Already in the codebase ✅

- `lib/core/utils/responsive_helper.dart` — `DeviceType` enum (mobile / tablet / desktop), `shortestSide`-based detection (works in both orientations and Split View), `getGridColumns(mobile, tablet, desktop)`, `getSpacing`, `getCardPadding`, `getMaxContentWidth`, `getMaxFormWidth`, breakpoints `600` and `1200`.
- `lib/core/design_system/widgets/responsive_wrapper.dart` — `ResponsiveWrapper`, `ResponsiveScaffold`, `ResponsiveLayout(mobile, tablet)`, `ResponsiveGrid`. Factories `.form()` (450), `.content()` (600), `.card()` (500).
- `main.dart` — already detects iPad and unlocks all 4 orientations (locks portrait on iPhone only).
- `Platform.isIOS` + `shortestSide >= 600` is the iPad guard already in use.

### Missing ❌ (this doc's scope)

1. **Adaptive shell** — every page still hosts its own `Scaffold` with `LiquidGlassNavBar`. There's no `NavigationRail` branch.
2. **Master-detail composition** — list pages push detail pages instead of populating a side pane.
3. **Hover, keyboard shortcuts, context menus, drag-and-drop** — none of these are wired anywhere.
4. **Per-screen tablet layouts** — `ResponsiveLayout(tablet: …)` is barely used.
5. **iPad mockups** — `ui_kits/athar_app/` only has phone screens.

---

## The three layers

### Layer 1 — Adaptive shell (do first; biggest payoff)

Build `lib/core/design_system/widgets/adaptive_shell.dart`. It replaces the
phone-only `Scaffold` + `LiquidGlassNavBar` pattern with a responsive
container that picks chrome based on width:

| Width (`shortestSide`) | Chrome | Content |
|---|---|---|
| `< 600` (iPhone) | Bottom `LiquidGlassNavBar` (current) | Single-column page |
| `600 – 839` (iPad portrait, Split View 1/2) | Compact `NavigationRail` (72pt, icons only) on the leading edge | Single-column with `getMaxContentWidth` |
| `840 – 1199` (iPad portrait full / landscape Split View) | Expanded `NavigationRail` (240pt, labels + active highlight) | 2-column where the screen supports it (master-detail) |
| `≥ 1200` (12.9" iPad landscape, external display, Stage Manager) | Expanded rail + sidebar | 3-column (rail · master · detail) |

**Key implementation notes:**

- Use `LayoutBuilder` at the shell level — read `constraints.maxWidth`, not
  `MediaQuery.size.width`. This makes Split View / Stage Manager / Slide
  Over all "just work" because Flutter rebuilds with the new constraint.
- Brand the rail: active indicator = `AppColors.primary` (forest green from
  the new brand), label font = `AppTypography.bodyMedium`, icon size 24.
- Mirror for RTL: pass `Directionality.of(context) == TextDirection.rtl`
  → put the rail on the trailing edge automatically (Flutter does this if
  you put it inside a `Row` whose `textDirection` flows from inherited
  `Directionality`).
- The FAB ("+") from the bottom bar moves into the rail's `leading:` slot
  on tablet+, kept centered above the destinations.
- **One file, one place** — every feature page wraps with
  `AdaptiveShell(body: ..., destinations: ...)`. Don't fork
  `liquid_glass_nav_bar.dart`; let the shell pick chrome.

### Layer 2 — Per-screen layouts

Each redesigned screen gets a `tablet` branch via `ResponsiveLayout`. Plan
in §1–§9 below.

### Layer 3 — iPad-only affordances

Hover, shortcuts, context menus, drag-and-drop, Pencil. Plan in §10.

---

## 1. Dashboard

**Mockup target:** `ui_kits/athar_app/Dashboard.jsx` (phone) → add
`Dashboard.iPad.jsx` once iPad mockups are produced.

**Targets:** `lib/features/home/presentation/pages/dashboard_page.dart`

**Phone (`< 600`):** unchanged — single column.

**iPad portrait (`600 – 839`):** 2-column.
```
┌──────────────────────┬───────────────────────────┐
│  Greeting + period    │  Today's tasks            │
│  Prayer card          │  Smart habits strip       │
│  (compact, 1 prayer)  │  Daily timeline           │
└──────────────────────┴───────────────────────────┘
       40% width                60% width
```

**iPad landscape (`≥ 840`):** 3-column.
```
┌─────────────┬──────────────────┬────────────────┐
│ Greeting    │ Today's tasks    │ Daily timeline │
│ Prayer card │ Smart habits     │ Stats peek     │
│ (expanded)  │ (grid 2-col)     │ (sparklines)   │
└─────────────┴──────────────────┴────────────────┘
   28%              42%                30%
```

**Implementation:**
- Wrap body in `ResponsiveLayout(mobile: PhoneDashboard, tablet: TabletDashboard)`.
- Tablet variant uses `Row` with three `Expanded(flex: …)` children, each a `SingleChildScrollView`.
- Don't stretch the prayer card — cap at `480pt` and center within its column. The fixed night-sky gradient stays the same.
- Read `MediaQuery.sizeOf(context).width` once at the top of the tablet variant, switch between 2-col and 3-col based on `>= 840`.

---

## 2. Tasks

**Targets:** `lib/features/task/presentation/pages/`

**Phone:** list → push detail (current).

**iPad:** **master-detail**.
```
┌─────────────────────┬──────────────────────────────┐
│  Filter chips       │  Selected task title         │
│  ────────           │  Description                 │
│  ▣ Task one         │  Subtasks · attachments      │
│  ▣ Task two  ←sel   │  Comments / activity         │
│  ▢ Task three       │  Right-rail: due, assignee,  │
│  ▢ Task four        │              priority, space │
└─────────────────────┴──────────────────────────────┘
       360pt                   flex
```

**Implementation:**
- New `TaskMasterDetailPage` widget. Holds a single `selectedTaskId` in
  local state (or in `TaskCubit`). Tapping a row updates state — no
  navigation push.
- On phone, the master is the whole page; tapping pushes detail.
- On iPad, `selectedTaskId == null` shows a "Select a task" empty state in
  the detail pane (large feature glyph + warm copy, per SKILL §2.4).
- `Hero` wrap the task title so the transition is graceful when the user
  hits Slide Over and the layout collapses to phone-mode mid-session.
- The right-rail (due / assignee / priority / space) is a third column at
  `≥ 1200` width; below that, fold into an inline panel at top of detail.
- Permission-gate every mutation through `PermissionService.canEditTask`,
  emit error state on fail.

---

## 3. Habits

**Targets:** `lib/features/habits/presentation/pages/habit_page.dart` +
`habit_details_page.dart`.

**Phone:** vertical list of tiles, heatmap on detail page.

**iPad portrait:** 2-col grid of habit tiles + heatmap of selected habit
floats above (full-width).

**iPad landscape:** 3-col grid + permanent right pane showing the selected
habit's full analytics (heatmap, streak history, edit form).

**Implementation:**
- Use existing `ResponsiveGrid` with `mobileColumns: 1, tabletColumns: 2,
  desktopColumns: 3`.
- The right pane re-uses `habit_details_page.dart`'s body — extract its
  scaffold-less content into a `HabitDetailsBody` widget you can drop into
  either a page or a pane.

---

## 4. Calendar

**Targets:** `lib/features/calendar/presentation/pages/calendar_page.dart`

**Phone:** day view + horizontal day strip.

**iPad portrait:** week view default + day strip on leading edge.

**iPad landscape:** full month grid (left) + side timeline of selected day
(right). This is the single screen where the iPad layout is *materially
different and better*.

**Implementation:**
- The unified `TimelineItem` cubit work proposed in `REDESIGN_AUDIT.md §5`
  is a hard prerequisite — without it, the iPad month grid can't render
  multi-source dots per day.
- Month view: Flutter doesn't have a great built-in; use `table_calendar`
  package if it's already in pubspec, otherwise hand-roll a 7×6 grid.
  Month cell shows up to 4 colored dots (task / habit / prayer / health),
  overflow indicator if more.
- Synced selection: tapping a month day updates the side timeline; tapping
  an item in the timeline highlights it on the month grid.

---

## 5. Focus

**Targets:** `lib/features/focus/presentation/pages/focus_page.dart`

**Phone:** full-screen timer with fluid bg.

**iPad:** **don't stretch the fluid background.** Cap the timer
composition at `720pt` wide, center it, let the surrounding canvas show
the fluid background tinted darker. The breathing motion looks worse at
1366pt wide than at 390pt.

**iPad landscape:** add a session-history rail on the right (`280pt`,
list of past sessions today, totals at top).

**Implementation:**
- Wrap `FocusBody` in a `Center` + `ConstrainedBox(maxWidth: 720)` on
  tablet.
- Session history is a new widget reading from `FocusCubit`'s `Loaded`
  state.

---

## 6. Stats

**Targets:** `lib/features/stats/presentation/pages/stats_page.dart`

**Phone:** vertical chart stack.

**iPad portrait:** 2-col chart grid via `ResponsiveGrid`.

**iPad landscape:** 3-col dashboard with a sparkline rail on the right
(quick "this week vs last week" deltas).

**Implementation:** straightforward — wrap each chart card in
`ResponsiveGrid` and let it flow. Charts (`fl_chart`) auto-resize to the
parent.

---

## 7. Settings

**Targets:** `lib/features/settings/presentation/pages/settings_page.dart`
+ `general_settings_page.dart` + `location_settings_page.dart` +
`smart_zones_page.dart`.

**Phone:** list pushes detail page (current).

**iPad:** **two-pane** — categories on the leading edge (`280pt`),
content on the trailing. This is the canonical iOS Settings.app pattern
and the right call here.

**Implementation:**
- The current pages are already self-contained — wrap each in a
  scaffold-less body widget (`GeneralSettingsBody`, `LocationSettingsBody`,
  etc.) and the detail pane just swaps which one renders based on
  `selectedCategory`.
- Phone retains push-navigation; tablet uses local state.
- Persist `selectedCategory` in a screen-local `Cubit` so deep links
  (`/settings/location`) can pre-select on iPad.

---

## 8. Spaces

**Targets:** `lib/features/space/presentation/`

**Phone:** list pushes detail.

**iPad portrait:** master space list (`320pt`) + detail (members, modules,
permissions tabs).

**iPad landscape:** 3-column — spaces list · members list · permission
matrix. The matrix is a real grid (member × module → role chip) which is
unusable on phone but excellent on iPad.

**Implementation:**
- Permission matrix is a new widget. Use `Table` with sticky leading
  column and sticky header row. Cells are `DropdownMenu<DelegationMode>`.
- Every cell write goes through `PermissionService` and `SpaceCubit`.

---

## 9. Onboarding

**Targets:** `lib/features/onboarding/` (net-new, see `REDESIGN_AUDIT.md §10`).

**Phone:** full-screen `PageView` steps.

**iPad portrait:** centered card max `560pt`, illustration above content.

**iPad landscape:** 2-col card max `960pt` — illustration left (480pt),
content right (480pt). Keeps the orientation lock off so users on iPad
Magic Keyboard see a comfortable layout.

---

## 10. iPad-only affordances (cross-cutting)

These apply to every screen, gated behind `ResponsiveHelper.isTablet(context)` or, better, behind capability checks (mouse attached → hover; keyboard attached → shortcuts).

### 10.1 Hover states

```dart
MouseRegion(
  cursor: SystemMouseCursors.click,
  onEnter: (_) => setState(() => _hovered = true),
  onExit: (_) => setState(() => _hovered = false),
  child: AnimatedContainer(
    duration: AppAnimations.medium,
    decoration: _hovered ? AppShadows.md : AppShadows.sm,
    ...
  ),
)
```

Apply to: task tile, habit tile, prayer row, member row, space tile,
calendar day cell, settings category row.

### 10.2 Keyboard shortcuts

Build `lib/core/keyboard/athar_shortcuts.dart` that wraps the app shell
in a `Shortcuts` + `Actions` pair:

| Shortcut | Intent |
|---|---|
| `⌘ N` | New task (active space) |
| `⌘ ⇧ N` | New habit |
| `⌘ F` | Start focus session |
| `⌘ ,` | Open settings |
| `⌘ 1` … `⌘ 5` | Switch to tab 1–5 |
| `⌘ K` | Quick-search (command palette — net-new feature) |
| `J` / `K` | Next / previous item in master list |
| `Space` | Toggle complete on selected task / habit |
| `⌘ ⏎` | Start focus from selected task |
| `⌘ ⌫` | Delete selected (with confirm) |
| `Esc` | Clear selection / close detail pane |

Each shortcut dispatches an `Intent`; the relevant cubit handles it. This
keeps shortcuts decoupled from widgets — same intent works whether
triggered by keyboard or button.

### 10.3 Context menus (long-press / right-click)

Use `CupertinoContextMenu` for native iOS feel. Wrap on iPad only:

- Task tile: Edit · Duplicate · Move to space · Schedule focus · Delete
- Habit tile: Edit · Reset streak · Delete
- Calendar day: Add task here · Add habit log · View details
- Member row: Change role · Remove

### 10.4 Drag-and-drop

Two flavors:

**A. Internal** — rearrange / convert / schedule:
- Drag task → habit zone = "convert to habit?" prompt
- Drag task → calendar day = schedule for that day
- Drag task → space tile = move to space (permission-checked)
- Drag habit → reorder within its category

**B. External** — accept drops from other apps:
- Drop image / PDF on attachment field of task or asset = upload
- Drop URL on task = capture as link
- Use `DropTarget` from `desktop_drop` package (works on iPad too via
  iPadOS drag-and-drop bridge).

### 10.5 Apple Pencil

- Replace `TextField` with `CupertinoTextField` on text inputs (task
  title, note body, dhikr custom text). `CupertinoTextField` enables
  Scribble natively on iOS.
- For the new note feature (if you add one), explore `flutter_quill` with
  Pencil pressure if handwritten notes are a goal — but only if it's
  scoped, the integration is non-trivial.

### 10.6 Multitasking

- `responsive_helper.dart` already keys off `shortestSide` so Split View
  / Slide Over / Stage Manager work without changes. Verify by running
  the iOS simulator with iPad Pro 12.9" and dragging the app to half-width.
- Make sure no page calls `MediaQuery.size.width` directly — it lies
  about Split View. Use `LayoutBuilder` constraints instead.
- The `AdaptiveShell` from §Layer 1 has to use `LayoutBuilder` for the
  same reason.

### 10.7 External display + Stage Manager

- Test on iPad with external display attached. The app should render at
  the external resolution (`MediaQuery.size` reports the screen the
  flutter view is on).
- Splash logo: export at 1024 × 1024 PNG @ 3x. The new SVG logo is fine
  for in-app use, but `LaunchScreen.storyboard` needs raster.

### 10.8 Sidebar collapse (Stage Manager small windows)

When `constraints.maxWidth < 600` even on iPad (Stage Manager small
window), the `AdaptiveShell` falls through to the iPhone branch. Master-
detail screens collapse back to push-navigation automatically because
they read `ResponsiveLayout(mobile, tablet)` which uses the same helper.

---

## Cross-cutting checklist (apply per iPad PR)

Add to the existing `SKILL.md §5` checklist:

- [ ] Wrap page in `AdaptiveShell` (not a bare `Scaffold` with bottom nav)
- [ ] Use `LayoutBuilder` at adaptive boundaries — never `MediaQuery.size`
- [ ] `ResponsiveLayout(mobile: ..., tablet: ...)` for any screen with a
      different iPad composition
- [ ] Cap content with `ResponsiveWrapper.content()` (600pt) when there's
      no genuine multi-column composition
- [ ] No element exceeds its natural width — don't stretch prayer card,
      focus background, prayer rows, dialog forms
- [ ] Detail pane has an empty state when nothing is selected
- [ ] Hover state on every interactive card / row
- [ ] Context menu on long-press (CupertinoContextMenu) for tablet
- [ ] Touch targets stay ≥ 44pt — iPad doesn't relax this
- [ ] Tested in iPad portrait, iPad landscape, Split View 1/2, Slide Over
- [ ] Tested on iPad in both Arabic (RTL) and English (LTR)
- [ ] Tested with Magic Keyboard (hover + shortcuts) and finger only
- [ ] No hardcoded `360`, `390`, etc. — always tokens or
      `ResponsiveHelper.*`

---

## Recommended implementation order

1. **`AdaptiveShell` + `NavigationRail` branch** (one file, transforms
   the whole app). Validate on Dashboard.
2. **Settings two-pane** — easy win, canonical pattern, most users go to
   settings on iPad first to set up modules.
3. **Tasks master-detail** — biggest productivity payoff.
4. **Calendar month + side timeline** — most visually different and best.
5. **Habits, Stats** — `ResponsiveGrid` makes these cheap.
6. **Spaces permission matrix** — high-value for power users.
7. **Focus, Onboarding** — capping + centering only.
8. **Hover, keyboard shortcuts, context menus** — sweep across all
   screens after layouts settle.
9. **Drag-and-drop** — last; adds polish, not core function.

---

## File index for the implementing tool

In addition to what `REDESIGN_AUDIT.md` lists, hand the tool:

- `lib/core/utils/responsive_helper.dart` (read-only — already correct)
- `lib/core/design_system/widgets/responsive_wrapper.dart` (read-only — already correct)
- This file (`IPAD_OPTIMIZATION.md`) as the iPad ticket list
- `main.dart` (verify orientation lock logic survives any work)

Tell it: _"Work top-down through `IPAD_OPTIMIZATION.md` §1–§10 **after**
the matching phone screen in `REDESIGN_AUDIT.md` is complete. Layer 1
(`AdaptiveShell`) is a hard prerequisite for Layers 2 and 3. Honor the
SKILL.md `§5` checklist + the iPad checklist on every PR."_
