# PR2 Readiness Preview — AdaptiveShell

**Prepared:** 2026-05-09  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Prerequisite:** PR1 ✅ · PR-THEME ✅ · PR-THEME-3MODE ✅  
**Status:** PREVIEW ONLY — do NOT implement yet

---

## What PR2 Changes

PR2 is the shell and navigation redesign. Canonical scope (from
`handoff_v2-2/FINAL_PACKAGE_MANIFEST.md`):

1. Rename `adaptive_scaffold.dart` → `adaptive_shell.dart`
2. iPad breakpoints — responsive layout at 600dp and 840dp
3. 4-tab bottom nav bar (Dashboard / Tasks / Habits / Spaces)
4. FAB pill outside the bar — standalone 64×64, 22px radius, `primary` gradient
5. FAB position: right of bar in LTR (English), left of bar in RTL (Arabic)
6. `shadow.lg` on FAB pill

---

## Affected Systems

| System | Impact |
|--------|--------|
| `adaptive_scaffold.dart` / `adaptive_shell.dart` | Rename + full rebuild |
| Bottom navigation bar | Shape change, 4-tab layout |
| FAB (floating action button) | Moved outside bar; becomes pill |
| Breakpoint system | New iPad/tablet layout thresholds |
| `app.dart` routes to `MainPage` | Shell wrapper may change |
| `main_page.dart` | Likely needs update for new shell |
| Safe-area padding | Must be verified for iPhone notch + iPad |
| RTL layout of FAB | Position flips on AR locale |

---

## Affected Widgets / Files (expected — requires confirmation)

Before implementation, read `handoff_v2-2/INVESTIGATION_REPORT.md` to
confirm exact current file layout.

| File (expected) | Reason |
|----------------|--------|
| `lib/features/home/presentation/pages/main_page.dart` | Hosts current nav bar and FAB |
| `lib/core/navigation/adaptive_scaffold.dart` | To be renamed → `adaptive_shell.dart` |
| `lib/app.dart` | May need shell reference update |
| Design tokens (shadow, radius) | FAB pill uses `shadow.lg`, `22px` radius |

---

## Navigation Impact

Current: bottom nav with central FAB notch (standard `BottomNavigationBar` or
`NavigationBar` with embedded FAB).

After PR2:
- 4-tab `NavigationBar` — no notch, no centered FAB slot
- FAB pill is a separate `Positioned` widget in a `Stack`, outside the bar
- Tab count: Dashboard, Tasks, Habits, Spaces — exactly 4
- No 5th tab (Settings is accessed from Dashboard or a separate route)

**Risk:** Any code that assumes a centered FAB or 5-tab bar will break.
Any page-level FAB that was suppressed by the "Central NavBar FAB only"
rule is unaffected (those pages have no FAB).

---

## Shell Impact

The `adaptive_scaffold.dart` rename is a refactor, not a logic change.
All references to it must be updated at the same time or the rename
introduces a broken import. The rename must be done atomically.

Expected import locations to update (to confirm by reading
`INVESTIGATION_REPORT.md`):
- `app.dart` or `main_page.dart` (wherever the scaffold is referenced)

---

## Responsive Layout Impact

New iPad breakpoints (from `handoff_v2-2/IPAD_OPTIMIZATION.md`):
- < 600dp (phone) — current phone layout
- 600dp–840dp (tablet portrait) — wider layout, possibly side nav
- > 840dp (tablet landscape) — full side navigation rail

This introduces conditional layout code that does not currently exist.
The breakpoint values and layout behavior must be read from
`IPAD_OPTIMIZATION.md` before implementation — do NOT guess.

---

## Safe-Area Impact

The FAB pill floats outside the nav bar. On iPhone with home indicator,
the FAB position must clear the system home indicator (SafeArea bottom
inset). On iPad, safe area behavior differs by orientation and model.

Must verify: `SafeArea` wrapping of the FAB pill position.

---

## Animation Risks

If the current nav bar uses `AnimatedContainer` or page transition
animations, PR2 may change the transition behavior. Read the current
`main_page.dart` before changing the shell — do not break existing
page switching animations.

---

## RTL Risks

The FAB pill position is explicitly spec'd:
- LTR (English): right of the bar
- RTL (Arabic): left of the bar

Implementation must use `Directionality.of(context)` or
`AlignmentDirectional` — never hardcoded `Alignment.bottomRight`.

If implemented incorrectly, the FAB will appear on the wrong side for
Arabic users.

---

## Regression Risks

| Risk | Severity |
|------|----------|
| FAB disappears or is unreachable | Critical — only add entry point for Task and Habit |
| 5th tab appears (regression) | High — must be exactly 4 tabs |
| Page-level FABs re-added | High — violates non-negotiable rule |
| iPad layout broken at 600dp | Medium |
| Safe-area overlap on iPhone | Medium |
| RTL FAB on wrong side | High |
| Existing page transitions broken | Medium |
| Prayer toggle hierarchy broken (if MainPage is restructured) | Critical |

---

## Rollout Strategy

1. Read `INVESTIGATION_REPORT.md` + `IPAD_OPTIMIZATION.md` + `REDESIGN_AUDIT.md` + `preview/comp-nav.html` in full
2. Write a pre-implementation audit doc: `design-context/_audit_shell.md`
3. Confirm exact current file structure for nav and scaffold
4. Implement rename first (atomic) — verify `flutter analyze` 0 after rename
5. Implement 4-tab nav bar (no FAB changes yet) — verify
6. Implement FAB pill — verify RTL and LTR side-by-side
7. Implement iPad breakpoints last — most complex

---

## Rollback Strategy

PR2 will produce a checkpoint tag `athar-v2-pr2-complete`. To roll back:

```bash
git checkout athar-v2-prtheme-3mode-complete -- \
  <adaptive_shell.dart> <main_page.dart> <app.dart>
# Then revert rename
mv lib/core/navigation/adaptive_shell.dart \
   lib/core/navigation/adaptive_scaffold.dart
```

The PR-THEME-3MODE state (theme, tokens, ARBs) is unaffected by PR2 rollback.

---

## Proposed File List (requires confirmation from INVESTIGATION_REPORT.md)

| File | Expected change |
|------|----------------|
| `lib/core/navigation/adaptive_scaffold.dart` | Rename → `adaptive_shell.dart`; update class name |
| `lib/features/home/presentation/pages/main_page.dart` | 4-tab bar + FAB pill |
| `lib/app.dart` | Import path update after rename |
| Any file importing `adaptive_scaffold.dart` | Import path update |

---

## Dependency on Completed PRs

| PR | Required | Status |
|----|----------|--------|
| PR1 — Tokens & Theme | ✅ | Complete |
| PR-THEME — ThemeMode.system | ✅ | Complete |
| PR-THEME-3MODE — 3-option picker | ✅ | Complete |

PR2 has no dependency on PR3 or later. PR2 unblocks PR3, PR4a, PR5, PR6, PR8, PR9.

---

## Screenshot / Spec References

| Spec | Location | Status |
|------|----------|--------|
| iPad breakpoints | `handoff_v2-2/IPAD_OPTIMIZATION.md` | ❌ NOT READ |
| FAB pill LTR+RTL layout | `handoff_v2-2/preview/comp-nav.html` | ❌ NOT READ |
| Nav bar shape | `handoff_v2-2/REDESIGN_AUDIT.md` | ❌ NOT READ |
| Current file layout | `handoff_v2-2/INVESTIGATION_REPORT.md` | ❌ NOT READ |

**All four must be read before PR2 implementation starts.**

---

## Why PR2 Is Isolated from PR3+

PR2 changes only the shell — the container that holds all feature pages.
Feature pages (Prayer card, Calendar, Stats, etc.) are redesigned in
PR3 and later. By isolating shell changes to PR2:

- Feature pages can be tested in the new shell before their own redesign
- If PR2 introduces a regression in the shell, it is caught before 12 more
  PRs are layered on top
- PR2 rollback does not undo any feature redesign work

---

## What Must NOT Be Changed During PR2

| Item | Rule |
|------|------|
| Prayer toggle hierarchy | 4-level hierarchy must survive any `main_page.dart` restructure |
| Page-level FABs | Must remain absent — NavBar FAB is still the only add point |
| `WidgetKeys` constants | Not touched in PR2 |
| App Group ID | Not touched in PR2 |
| Onboarding | Not touched in PR2 |
| Calendar | Not touched in PR2 |
| iOS widgets / Swift | Not touched in PR2 |
| `injection.config.dart` | Generated — not edited |
| Theme tokens | Already correct from PR1 — not re-touched in PR2 |

---

## Dangerous Areas

| Area | Risk | Guard |
|------|------|-------|
| Rename `adaptive_scaffold` → `adaptive_shell` | Broken imports if not atomic | Run `flutter analyze` immediately after rename |
| iPad layout at 600dp | Untested breakpoint | Test on iPad simulator at multiple orientations |
| FAB Stack positioning | Safe-area overlap | Wrap FAB in `SafeArea` or use `Padding(bottom: MediaQuery.viewPaddingOf(context).bottom)` |
| RTL FAB position | Wrong side for AR users | Use `Directionality` — never `Alignment.bottomRight` |

---

## Review Checkpoints

| Checkpoint | Before moving forward |
|------------|-----------------------|
| After rename | `flutter analyze` 0 issues |
| After 4-tab bar | Visual check: exactly 4 tabs, correct icons/labels |
| After FAB pill | RTL + LTR screenshots, safe-area clearance |
| After iPad breakpoints | iPad simulator at 600dp, 840dp, 1024dp |
| Final | `flutter analyze` + `flutter test` + change log |

---

## Approval Gates

1. Read all 4 spec files (listed above) — confirmed
2. Write `design-context/_audit_shell.md` — designer review if needed
3. User approves with phrase: **"Implement PR2"**

---

## PR2 Readiness Verdict

**NOT READY TO START.**

Blocked on reading 4 required spec files before implementation:
- `handoff_v2-2/INVESTIGATION_REPORT.md` ❌
- `handoff_v2-2/IPAD_OPTIMIZATION.md` ❌
- `handoff_v2-2/REDESIGN_AUDIT.md` ❌
- `handoff_v2-2/preview/comp-nav.html` ❌

Once these are read and the shell audit is written, PR2 is safe to
implement (no code blockers, no designer dependencies, no asset
dependencies).
