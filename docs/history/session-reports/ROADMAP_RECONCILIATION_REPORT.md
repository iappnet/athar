# Roadmap Reconciliation Report

**Date:** 2026-06-01
**Triggered by:** Governance contradiction — PR2 listed as "Not Started" in `phase_tracker.md` while tag `athar-v2-pr2-complete` exists
**Audit scope:** All governance files × git history × working tree

---

## 1. Audit Methodology

Evidence gathered in order:
1. `git log --oneline --all` — full commit history
2. `git tag -l` + `git rev-list -n 1 <tag>` — all tags with commit hashes
3. `git show <commit> --stat` — what each PR commit actually changed
4. Live file checks — `adaptive_shell.dart`, `main_page.dart`, `liquid_glass_nav_bar.dart`, `next_prayer_card.dart`, `app.dart`
5. Cross-read of all five governance documents

---

## 2. Repository Evidence (Ground Truth)

### 2a. Git Tags

| Tag | Commit | Date | What it marks |
|-----|--------|------|---------------|
| `athar-v2-pr1-complete` | `72f902d` | 2026-05-09 | PR1 governance commit (after tokens/typography/Calibri) |
| `athar-v2-prtheme-complete` | `14c13d6` | 2026-05-09 | PR-THEME initial: ThemeMode.system wiring |
| `athar-v2-prtheme-3mode-complete` | `66bc884` | 2026-05-09 | PR-THEME-3MODE: ThemePreference enum + 3-option picker |
| `athar-v2-pr2-complete` | `87ab36e` | 2026-05-09 | PR2 CP6: final governance update, all checkpoints verified |
| `athar-v2-prtheme-complete-final` | `bfaf863` | 2026-06-01 | PR-THEME FINAL: wire AtharLightTheme/AtharDarkTheme + 88 fallbacks + RTL drawer |

### 2b. Key Implementation Commits

| Commit | Message | Files |
|--------|---------|-------|
| `61d741a` | feat(design-system): PR1 | athar_colors.dart, athar_typography.dart, pubspec.yaml, fonts |
| `14c13d6` | feat(theme): PR-THEME — wire ThemeMode.system | app.dart |
| `66bc884` | feat(theme): PR-THEME-3MODE | user_settings.dart, settings_page.dart, app.dart |
| `81af052` | feat(design-system): PR2 CP1+CP2 | **adaptive_shell.dart** (new), **main_page.dart**, **liquid_glass_nav_bar.dart** |
| `87ab36e` | docs: PR2 CP6 | governance docs only |
| `3872860` | feat(typography): PR-FONT-FALLBACK | athar_typography.dart |
| `1cd4f80` | feat(prayer-card): PR3 | next_prayer_card.dart, smart_prayer_wrapper.dart, golden tests |
| `bfaf863` | feat(theme): PR-THEME FINAL | athar_light_theme.dart, athar_dark_theme.dart, app.dart, cleanup |

### 2c. Working Tree Verification

| Artifact | Expected | Found | Status |
|----------|----------|-------|--------|
| `lib/core/design_system/widgets/adaptive_shell.dart` | Created by PR2 | EXISTS (79 lines, `ShellBreakpoint` enum + `AdaptiveShell` widget) | ✅ |
| `main_page.dart` imports `adaptive_shell.dart` | Yes | `import '...adaptive_shell.dart'` at line 24; `AdaptiveShell(...)` at line 137 | ✅ |
| `liquid_glass_nav_bar.dart` FAB pill | `borderRadius: 22px`, gradient `#2F7A5E→#0F3D2E` | `borderRadius: BorderRadius.circular(22.r)` at line 399; gradient at line ~381 | ✅ |
| `lib/core/design_system/molecules/cards/next_prayer_card.dart` | Forest gradient, PR3 redesign | EXISTS; `prayerCardGradient: [0xFF0F3D2E, 0xFF1A5A45]` | ✅ |
| `lib/app.dart` theme wiring | `AtharLightTheme.theme / AtharDarkTheme.theme` | Lines 172–173 confirmed | ✅ |
| `lib/core/design_system/themes/app_theme.dart` | DELETED by PR-THEME FINAL | Does not exist | ✅ |

---

## 3. Full PR Status Matrix

| PR | Implemented | Committed | Tagged | Signed Off | Governance |
|----|------------|-----------|--------|-----------|------------|
| **PR1** | ✅ `61d741a` | ✅ | ✅ `athar-v2-pr1-complete` | ✅ | ✅ All docs correct |
| **PR-THEME initial** | ✅ `14c13d6` | ✅ | ✅ `athar-v2-prtheme-complete` | ✅ | ✅ |
| **PR-THEME-3MODE** | ✅ `66bc884` | ✅ | ✅ `athar-v2-prtheme-3mode-complete` | ✅ | ✅ |
| **PR2 (AdaptiveShell)** | ✅ `81af052` | ✅ | ✅ `athar-v2-pr2-complete` → `87ab36e` | ✅ 6/6 CPs | ⚠️ STALE entries in 2 docs (see §4) |
| **PR-FONT-FALLBACK** | ✅ `3872860` | ✅ | — (part of PR-THEME arc) | ✅ | ✅ |
| **PR3 (Prayer Card)** | ✅ `1cd4f80` | ✅ | — | ✅ `PR3_SIGNOFF.md` | ✅ All docs correct |
| **PR-THEME FINAL** | ✅ `bfaf863` | ✅ | ✅ `athar-v2-prtheme-complete-final` | ✅ | ✅ `VERIFICATION_PR_THEME.md` |
| **PR-ADHAN** | 🔲 Not started | — | — | — | ✅ Correctly shown as blocked |
| **PR4a** | 🔲 Not started | — | — | — | ✅ Correctly shown as pending |
| **PR4b** | 🔲 Not started | — | — | — | ✅ Correctly shown as blocked |
| **PR5** | 🔲 Not started | — | — | — | ✅ Correctly shown as pending |
| **PR6** | 🔲 Not started | — | — | — | ✅ Correctly shown as pending |
| **PR7** | 🔲 Not started | — | — | — | ✅ Correctly shown as pending |
| **PR8** | 🔲 Not started | — | — | — | ✅ Correctly shown as pending |
| **PR9** | 🔲 Not started | — | — | — | ✅ Correctly shown as pending |
| **PR-ONBOARD-AB** | 🔲 Not started | — | — | — | ✅ Correctly shown as blocked |
| **PR-CLEANUP** | 🔲 Not started | — | — | — | ✅ Correctly shown as blocked |

---

## 4. Discrepancies Found

### Discrepancy 1 — `docs/progress/phase_tracker.md` (CRITICAL)

**Lines 164–169:** Stale PR2 section, never removed when PR2 was completed:

```
### PR2 — AdaptiveShell
Status: 🔲 Not started — blocked on PR-THEME
Scope: Rename adaptive_scaffold.dart → adaptive_shell.dart; iPad breakpoints; 4-tab nav bar; FAB pill outside bar.
Prerequisite reads: IPAD_OPTIMIZATION.md, REDESIGN_AUDIT.md, preview/comp-nav.html.
```

**Lines 185–198:** Correct PR2 section (added when PR2 was completed):

```
### PR2 — AdaptiveShell
Status: ✅ Complete — tag athar-v2-pr2-complete
CP1 ✅ ... CP6 ✅
```

**Root cause:** When PR2 was completed, a NEW section was added at the bottom but the old "Not started" section was never deleted. Both exist simultaneously.

**Fix:** Delete the stale section at lines 164–169.

---

### Discrepancy 2 — `PROGRAM_IMPLEMENTATION_STATUS.md` (MAJOR)

**Lines 64–79:** Stale "Track B" quick-status mini-table:

```
| PR2 | 🟡 Ready — all spec files read; awaiting "Implement PR2" phrase |
| PR3 | 🔲 Blocked on PR2 |
```

This mini-table was never updated after PR2 and PR3 were completed. It contradicts the main PR table in the same file (lines 30–45) which correctly shows PR2 ✅ and PR3 ✅.

**Root cause:** PROGRAM_IMPLEMENTATION_STATUS.md contains two PR status views:
1. The main table (§1, lines 30–45) — updated correctly by PR-THEME governance commit
2. A secondary "Current Implementation Progress" mini-table (§2, lines 64–79) — never updated after PR2

**Fix:** Update the §2 mini-table to reflect current state.

---

### Discrepancy 3 — Minor inconsistency in numbering

In the `IMPLEMENTATION_MASTER_STATUS.md` table as updated during PR-THEME governance:
- Row 2 = PR-THEME (full arc)
- Row 2b = PR-FONT-FALLBACK (not PR-THEME-3MODE)

But PR-THEME-3MODE was a separate named tag (`athar-v2-prtheme-3mode-complete`). This is not an error — the logical consolidation is correct — but future readers should know the old 2b was PR-THEME-3MODE (now folded into the PR-THEME arc row).

**Severity:** Cosmetic. No fix required.

---

## 5. PR2 Verification — Definitive Answer

**Is PR2 actually complete?** YES, definitively.

| Evidence | Result |
|----------|--------|
| Implementation commit `81af052` exists | ✅ |
| `adaptive_shell.dart` exists in working tree (79 lines) | ✅ |
| `main_page.dart` imports and uses `AdaptiveShell` | ✅ |
| `liquid_glass_nav_bar.dart` has 22px pill shape + correct gradient | ✅ |
| Tag `athar-v2-pr2-complete` → commit `87ab36e` | ✅ |
| PR2_CHECKPOINTS.md: all 6 CPs marked ✅ | ✅ |
| `flutter analyze`: 0 issues at time of tag | ✅ |
| `flutter test`: 29/29 at time of tag | ✅ |

**Was PR2 superseded or partially reverted?** No. Working tree confirms all PR2 artifacts are present and intact.

**Was PR2 tagged incorrectly?** No. Tag points to the final governance commit after all checkpoints were verified.

**Is the tag wrong?** No.

**Are the governance files stale?** YES — two specific sections in two documents (see §4).

**Is the roadmap wrong?** The main PR tables in both IMPLEMENTATION_MASTER_STATUS.md and PROGRAM_IMPLEMENTATION_STATUS.md are correct. Only the secondary stale sections are wrong.

---

## 6. Files Requiring Correction

| File | Fix |
|------|-----|
| `docs/progress/phase_tracker.md` | Remove stale PR2 "Not started" section (lines 164–169) |
| `PROGRAM_IMPLEMENTATION_STATUS.md` | Update §2 "Track B" mini-table (lines 64–79) |

---

## 7. Files Confirmed Correct (No Change Needed)

| File | Status |
|------|--------|
| `IMPLEMENTATION_MASTER_STATUS.md` | ✅ Correct — PR table, completion %, next PR all accurate |
| `IMPLEMENTATION_SESSION_STATE.md` | ✅ Correct — all PRs accurately listed |
| `docs/progress/current_project_status.md` | ✅ Correct — PR2, PR3, PR-THEME all described accurately |
| All git tags | ✅ Correct — all point to appropriate commits |
| All implementation files | ✅ Correct — working tree matches claimed state |
