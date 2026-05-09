# PR2 Implementation Plan — AdaptiveShell

**Date:** 2026-05-09  
**PR:** PR2 — AdaptiveShell + responsive shell + 4-tab nav refactor + standalone FAB  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Status:** Awaiting "Implement PR2" approval phrase — do NOT start before it  
**Readiness report:** `PR2_FINAL_READINESS_REPORT.md`

---

## Approval Gate

Do NOT begin implementation until the user says **"Implement PR2"**.  
This document is reference material only until that phrase is received.

---

## Pre-Implementation Reads (Dart source files — 3 reads max)

Read these 3 files at implementation time before any edits:

1. `lib/features/home/presentation/pages/main_page.dart` — understand full widget tree, BlocProvider setup, current scaffold/nav structure
2. `lib/core/design_system/widgets/liquid_glass_nav_bar.dart` — understand current tab count, FAB presence (if any), internal rendering
3. `lib/core/design_system/widgets/context_aware_fab.dart` — understand current FAB structure before restyling

**Stop reading after these 3 files.** Execute immediately without additional searches.

---

## Step 1 — Create `adaptive_shell.dart` (new file)

**Path:** `lib/core/design_system/widgets/adaptive_shell.dart`

**Purpose:** Outermost responsive scaffold. `LayoutBuilder` branches to phone dock layout or NavigationRail based on available width.

**Class structure:**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:athar/core/design_system/widgets/liquid_glass_nav_bar.dart';
import 'package:athar/core/design_system/widgets/context_aware_fab.dart';

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _PhoneShell(
            body: body,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
          );
        } else if (constraints.maxWidth < 840) {
          return _RailShell(
            body: body,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: false,  // compact: 72pt, icons only
          );
        } else {
          return _RailShell(
            body: body,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            extended: true,  // expanded: 240pt, labels visible
          );
        }
      },
    );
  }
}
```

**`_PhoneShell`:** Standard `Scaffold` with `body` + bottom dock:
- Bottom dock is a `Padding` wrapping a `Row` (no fixed height container; let nav/FAB natural height apply)
- `Row` inherits `TextDirection` from `Directionality` — RTL auto-reverses FAB to left

**`_RailShell`:** `Scaffold` with `body: Row(NavigationRail, Expanded(child: body))`
- NavigationRail side: `Directionality.of(context) == TextDirection.rtl` → `isExtended` + alignment
- FAB in `leading` slot of NavigationRail
- `extended: false` → width ~72pt, icons only; `extended: true` → width ~240pt, labels shown
- 4 destinations: Dashboard / Tasks / Habits / Spaces (strings from `AppLocalizations`)

---

## Step 2 — Update `main_page.dart`

**Path:** `lib/features/home/presentation/pages/main_page.dart`

**Change:** Replace current nav/scaffold structure with `AdaptiveShell`.

**Critical constraints:**
- Preserve ALL existing `BlocProvider` / `MultiBlocProvider` wrappers exactly — do not touch the provider tree
- Continue routing to the same 4 pages as today
- Remove any dock/FAB layout that currently lives in `main_page.dart` (it moves to `AdaptiveShell._PhoneShell`)

**Pattern:**
```dart
// Outermost build returns AdaptiveShell, inside the MultiBlocProvider tree
AdaptiveShell(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (i) => setState(() => _selectedIndex = i),
  body: _pages[_selectedIndex],
)
```

---

## Step 3 — Update `liquid_glass_nav_bar.dart`

**Path:** `lib/core/design_system/widgets/liquid_glass_nav_bar.dart`

**Change:** 4 tabs only; no FAB inside bar; apply exact glass treatment.

**Glass treatment (from REDESIGN_AUDIT.md §11 + comp-nav.html):**

```dart
// Outer container
SizedBox(
  height: 64,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x6BFFFFFF), Color(0x38FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x38FFFFFF)),
          boxShadow: const [
            BoxShadow(color: Color(0x38164032), blurRadius: 24, offset: Offset(0, 8)),
            BoxShadow(color: Color(0x1A164032), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [/* 4 tab items */],
        ),
      ),
    ),
  ),
)
```

**Active tab chip:**
```dart
// Wrap active tab in:
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: const Color(0x52FFFFFF),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0x66FFFFFF)),
  ),
)
```

**4 tab destinations (in order):**
1. Dashboard (الرئيسية) — icon: `Icons.home_outlined` / `Icons.home`
2. Tasks (المهام) — icon: `Icons.check_circle_outline` / `Icons.check_circle`
3. Habits (العادات) — icon: `Icons.radio_button_unchecked` / `Icons.radio_button_checked`
4. Spaces (المساحات) — icon: `Icons.workspaces_outlined` / `Icons.workspaces`

Labels from `AppLocalizations` — never hardcoded strings.

---

## Step 4 — Update `context_aware_fab.dart`

**Path:** `lib/core/design_system/widgets/context_aware_fab.dart`

**Change:** Apply standalone FAB spec from comp-nav.html.

```dart
GestureDetector(
  onTap: onPressed,
  child: Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2F7A5E), Color(0xFF0F3D2E)],
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(color: Color(0x800F3D2E), blurRadius: 22, offset: Offset(0, 10)),
        BoxShadow(color: Color(0x380F3D2E), blurRadius: 6, offset: Offset(0, 3)),
        BoxShadow(color: Color(0x66FFFFFF), blurRadius: 0, offset: Offset(0, 1),
            spreadRadius: -1),  // specular inset (approximate)
      ],
    ),
    child: const Icon(Icons.add, color: Color(0xFFFAF7EC), size: 32),
  ),
)
```

**Note:** The exact FAB tap handler must remain compatible with the add-action routing that currently exists in `context_aware_fab.dart`. Read the file first (Step 0) and preserve the routing logic.

---

## Step 5 — Validation

Run in order after all edits:

```bash
flutter analyze      # must be 0 issues
flutter test         # must be 29/29 (or higher if new tests added)
```

Simulator validation checklist:
- [ ] Phone (375px): nav bar + FAB visible at bottom; FAB is RIGHT of bar (LTR/English)
- [ ] Switch locale to Arabic: FAB moves to LEFT of bar (RTL)
- [ ] Active tab shows glass chip + green icon
- [ ] 4 tabs: Dashboard, Tasks, Habits, Spaces — navigation works
- [ ] iPad simulator (if available): NavigationRail appears at left (LTR) / right (RTL)
- [ ] Switching tabs does not discard BlocProvider state
- [ ] No page-level FABs on Task or Habit pages

---

## Step 6 — Commit + Tag

```bash
git add \
  lib/core/design_system/widgets/adaptive_shell.dart \
  lib/features/home/presentation/pages/main_page.dart \
  lib/core/design_system/widgets/liquid_glass_nav_bar.dart \
  lib/core/design_system/widgets/context_aware_fab.dart

git commit -m "feat(design-system): PR2 — AdaptiveShell + responsive breakpoints + 4-tab nav + standalone FAB"

git tag athar-v2-pr2-complete
```

---

## Step 7 — Post-PR2 Governance

After successful commit, update these docs:

1. `IMPLEMENTATION_SESSION_STATE.md` — PR2 complete; PR3 status
2. `IMPLEMENTATION_MASTER_STATUS.md` — PR2 row → ✅ Complete
3. `docs/progress/current_project_status.md` — PR2 section
4. `docs/progress/phase_tracker.md` — PR2 complete; PR3/PR-ADHAN ready
5. `PROGRAM_IMPLEMENTATION_STATUS.md` — PR2 % complete update
6. Create `docs/ai/change-logs/CHANGE_LOG_<date>_PR2_COMPLETE.md`

---

## Non-Negotiable Rules for PR2

| Rule | Source |
|------|--------|
| `WidgetKeys` constants — never rename | CLAUDE.md |
| No page-level FABs on TaskPage or HabitPage | CLAUDE.md |
| iOS deployment target stays 17.0 | CLAUDE.md |
| `EdgeInsetsDirectional` — never `EdgeInsets.only(left/right)` | CLAUDE.md |
| `AlignmentDirectional` — never `Alignment.centerLeft/centerRight` | CLAUDE.md |
| All user-visible strings in ARB files only | CLAUDE.md |
| `injection.config.dart` — never edit directly | CLAUDE.md |
| `adaptive_scaffold.dart` — keep, do not delete in PR2 | This plan |
| All prayer hierarchy toggles — do not touch | CLAUDE.md |
| `onboarding_page.dart` Variant A — must not regress | CLAUDE.md |
| `SubscriptionCubit` stays `@lazySingleton` | CLAUDE.md |
