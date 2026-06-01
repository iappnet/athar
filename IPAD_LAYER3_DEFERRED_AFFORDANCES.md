# iPad Layer 3 — Deferred Affordances

**Date:** 2026-06-01  
**Source spec:** `IPAD_OPTIMIZATION.md §10`  
**Status:** Deferred — not started. Standalone sweep PR after Layer 2 is stable.

---

## Decision

Layer 3 affordances are a **cross-cutting sweep** that touches every screen simultaneously. They must not be started until:

1. All Layer 2 per-screen tablet layouts are stable (screens know their final structure)
2. Hover targets, keyboard-navigable items, and drag sources are locked into their final widget tree positions
3. A dedicated `PR-IPAD-LAYER3` is planned and scoped

**Do NOT start Layer 3 now.** No Layer 3 work in PR4a, PR4b, PR5, PR6, PR7, PR8, PR9, or any current PR.

---

## Affordance Inventory

### 10.1 — Hover States

**Spec:** `IPAD_OPTIMIZATION.md §10.1`  
**Pattern:**
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
**Required targets:** task tile, habit tile, prayer row, member row, space tile, calendar day cell, settings category row  
**Current state:** NOT STARTED — no `MouseRegion` in any feature file  
**Why deferred:** Each tile's final visual design must be stable before hover states are added. Adding hover to a tile that is redesigned in PR4a–PR9 forces double touch.  
**When to start:** After all per-screen feature PRs are merged (post-PR-IPAD-LAYER2).

---

### 10.2 — Keyboard Shortcuts

**Spec:** `IPAD_OPTIMIZATION.md §10.2`  
**Required artifact:** `lib/core/keyboard/athar_shortcuts.dart` — does NOT exist.  
**Planned shortcuts:**

| Shortcut | Intent |
|----------|--------|
| `⌘ N` | New task (active space) |
| `⌘ ⇧ N` | New habit |
| `⌘ F` | Start focus session |
| `⌘ ,` | Open settings |
| `⌘ 1`–`⌘ 5` | Switch tab 1–5 |
| `⌘ K` | Quick search (command palette — net-new) |
| `J` / `K` | Next / previous item in master list |
| `Space` | Toggle complete on selected task / habit |
| `⌘ ⏎` | Start focus from selected task |
| `⌘ ⌫` | Delete selected (with confirm) |
| `Esc` | Clear selection / close detail pane |

**Current state:** NOT STARTED — `lib/core/keyboard/` directory does not exist.  
**Why deferred:** `J`/`K` navigation requires master-detail lists (Tasks, Habits) to exist first. `Space` requires task/habit selection state. `⌘ K` is a net-new feature (command palette). All depend on final widget tree.  
**Architecture:** `Shortcuts` + `Actions` at shell level, decoupled from widgets; cubits handle intents.

---

### 10.3 — Context Menus

**Spec:** `IPAD_OPTIMIZATION.md §10.3`  
**Pattern:** `CupertinoContextMenu` on iPad only, long-press / right-click.  
**Required targets:**

| Target | Actions |
|--------|---------|
| Task tile | Edit · Duplicate · Move to space · Schedule focus · Delete |
| Habit tile | Edit · Reset streak · Delete |
| Calendar day | Add task here · Add habit log · View details |
| Member row | Change role · Remove |

**Current state:** NOT STARTED  
**Why deferred:** Each tile's final design and action set must be locked before adding context menus. Premature wiring to unstable widget trees creates merge conflicts.

---

### 10.4 — Drag-and-Drop

**Spec:** `IPAD_OPTIMIZATION.md §10.4`  
**Two flavors:**

**A — Internal:**
- Task → habit zone = "convert to habit?" prompt
- Task → calendar day = schedule for that day
- Task → space tile = move to space (permission-checked)
- Habit tile → reorder within its category

**B — External (accept drops from other apps):**
- Image/PDF dropped on task attachment field = upload
- URL dropped on task = capture as link
- Package: `desktop_drop` (works on iPadOS via drag-and-drop bridge)

**Current state:** NOT STARTED  
**Why deferred:** Requires stable master-detail / task-tile widget tree. `desktop_drop` adds a pubspec dependency — needs product decision. Internal drag requires `CalendarCubit` to accept task-scheduling via date drag (not currently in state).

---

### 10.5 — Apple Pencil / Scribble

**Spec:** `IPAD_OPTIMIZATION.md §10.5`  
**Change:** Replace `TextField` with `CupertinoTextField` on text inputs (task title, note body, dhikr custom text) → Scribble works natively.  
**For handwritten notes (if scoped):** `flutter_quill` with Pencil pressure — not currently planned.

**Current state:** NOT STARTED  
**Why deferred:** Each form's input widgets must be stable before swapping TextField → CupertinoTextField. This sweep touches all text inputs in all features.

---

### 10.6 — Stage Manager / Split View (ALREADY DONE)

**Spec:** `IPAD_OPTIMIZATION.md §10.6`  
**Current state:** ✅ COMPLETE — `AdaptiveShell` uses `LayoutBuilder`; width changes reflect immediately.  
**Remaining:** Device QA — test Split View ½ width on iPad Pro 12.9" in simulator. This is a QA gate, not an implementation gap.

---

### 10.7 — External Display (Device QA Only)

**Spec:** `IPAD_OPTIMIZATION.md §10.7`  
**Current state:** Implementation complete (no screen reads `MediaQuery.size` at shell level). Device QA deferred to pre-release gate.

---

### 10.8 — Sidebar Collapse in Stage Manager Small Windows (ALREADY DONE)

**Spec:** `IPAD_OPTIMIZATION.md §10.8`  
**Current state:** ✅ COMPLETE — `AdaptiveShell` phone branch activates when `constraints.maxWidth < 600`, even on iPad Stage Manager.

---

## When to Start Layer 3

**Trigger conditions (all must be true):**
1. PR5 (Settings), PR6 (Stats), PR4b (Calendar) merged and stable
2. Tasks and Habits feature PRs have shipped tablet layouts (Layer 2)
3. Dashboard tablet layout shipped
4. Product owner confirms `⌘ K` command palette is in scope

**Estimated PRs before Layer 3 can start:** PR5, PR6, PR4b, PR-DASHBOARD-TABLET (4 PRs). Estimated timeline: not before Q3 2026.

**Owner:** Dedicated `PR-IPAD-LAYER3` PR — one engineer, full sweep of all screens.
