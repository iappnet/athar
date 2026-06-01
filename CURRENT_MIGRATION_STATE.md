<!--
CANONICAL-FOR: Branch state, RULE 1/2 enforcement, Deferred QA bucket
OWNER:         Claude Code
PRECEDENCE:    4 (Tier 1 — loads after Tier-0 on any PR arc)
LAST-UPDATED:  2026-06-01 · PR6 complete + Stage A
LOADS-AT:      Tier 1
-->

# Current Migration State — Athar v2 Design System

**Generated:** 2026-06-01  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Trigger:** Roadmap reconciliation audit (ROADMAP_RECONCILIATION_REPORT.md)

---

## Canonical Branch

`feat/athar-v2-pr1-tokens-theme` — long-running migration branch.  
**Do NOT merge to `main` until all design-system PRs are complete.**  
`main` baseline: `32e59c3` — no touches until migration merge gate.

---

## Completed PRs

| PR | Commit | Tag | Signed Off | Date |
|----|--------|-----|-----------|------|
| **PR1** — Tokens & Theme | `61d741a` | `athar-v2-pr1-complete` | ✅ | 2026-05-09 |
| **PR-THEME initial** — ThemeMode.system wiring | `14c13d6` | `athar-v2-prtheme-complete` | ✅ | 2026-05-09 |
| **PR-THEME-3MODE** — ThemePreference enum + 3-mode picker | `66bc884` | `athar-v2-prtheme-3mode-complete` | ✅ | 2026-05-09 |
| **PR2** — AdaptiveShell | `81af052` (impl) · `87ab36e` (governance) | `athar-v2-pr2-complete` | ✅ 6/6 CPs | 2026-05-09 |
| **PR-FONT-FALLBACK** — Cairo fallback on 38 base styles | `3872860` | (part of PR-THEME arc) | ✅ | 2026-06-01 |
| **PR3** — Prayer Card Refresh | `1cd4f80` | (in branch) | ✅ `PR3_SIGNOFF.md` | 2026-06-01 |
| **PR-THEME FINAL** — Wire AtharLightTheme/AtharDarkTheme + 88 fallbacks + RTL drawer | `bfaf863` | `athar-v2-prtheme-complete-final` | ✅ `VERIFICATION_PR_THEME.md` | 2026-06-01 |
| **PR4a** — Calendar Visual Refresh | `85ada1e` | (in branch) | ✅ code signed off · 2 device-QA gates deferred | 2026-06-01 |

---

## Verified PRs (implementation confirmed in working tree)

| PR | Evidence |
|----|---------|
| PR1 | `athar_colors.dart` (22 palette corrections), `athar_typography.dart` (Calibri + numericMono), `pubspec.yaml`, font assets |
| PR-THEME arc | `app.dart` wired to `AtharLightTheme.theme` / `AtharDarkTheme.theme`; `ThemePreference` switch confirmed; `app_theme.dart` deleted |
| PR2 | `adaptive_shell.dart` exists (79 lines); `main_page.dart` imports + uses `AdaptiveShell`; `liquid_glass_nav_bar.dart` has 22px pill + forest gradient |
| PR3 | `next_prayer_card.dart` forest gradient `[0xFF0F3D2E, 0xFF1A5A45]`; 16/16 golden tests pass |
| PR-FONT-FALLBACK | `athar_typography.dart`: `fontFallback` const + 38 base styles carry Cairo fallback |
| PR-THEME FINAL | Both theme files: 44× `fontFamilyFallback: AtharTypography.fontFallback`; `BorderRadiusDirectional` DrawerTheme; `app_theme.dart` + `athar_theme.dart` deleted |

---

## Tagged PRs (git tags → commit hashes)

| Tag | Commit | PR | Notes |
|-----|--------|----|-------|
| `athar-v2-pr1-complete` | `72f902d` | PR1 | Governance tag (after token + font implementation) |
| `athar-v2-prtheme-complete` | `14c13d6` | PR-THEME initial | ThemeMode.system wiring |
| `athar-v2-prtheme-3mode-complete` | `66bc884` | PR-THEME-3MODE | ThemePreference enum |
| `athar-v2-pr2-complete` | `87ab36e` | PR2 | Governance tag (after all 6 CPs verified) |
| `athar-v2-prtheme-complete-final` | `bfaf863` | PR-THEME FINAL | Full arc complete |
| `athar-v2-pr4a-complete` | `1beff60` | PR4a | Governance tag (sign-off commit) · pushed to remote ✅ |

---

## Signed-Off PRs

| PR | Sign-off artifact |
|----|------------------|
| PR1 | Phase tracker + IMPLEMENTATION_MASTER_STATUS.md updated |
| PR-THEME full arc | `VERIFICATION_PR_THEME.md` · `PR_THEME_FINAL_REPORT.md` |
| PR2 | `PR2_CHECKPOINTS.md` (6/6 CPs) · `PR2_PROGRESS_REPORT.md` |
| PR3 | `PR3_SIGNOFF.md` |
| PR4a | Code signed off (85ada1e) · `VERIFICATION_PR4A.md` · 2 device-QA gates deferred to physical-device pass |

---

## Active PR

**None.** PR4a complete (`athar-v2-pr4a-complete`, commits `85ada1e` + `1beff60`). 2 device-QA gates in Deferred QA Bucket below.

---

## Current Working Tree State

```
flutter analyze → 0 issues
flutter test → 45/45 passed (16 golden + 28 stats + 1 config)
```

All changes committed and pushed. Last commit: governance closure (after `1beff60` sign-off).

---

## Next Recommended PR

> **PR ordering and status live in `IMPLEMENTATION_MASTER_STATUS.md` (SINGLE SOURCE OF TRUTH).** See `ROADMAP_AFTER_PR4A.md` for current next-step guidance.

---

## Locked Governance Rules

### RULE 1 — Window-Based Layout Only (locked 2026-06-01)

Every screen-level layout decision uses `LayoutBuilder(constraints.maxWidth)` or `ShellBreakpoint.fromWidth()`.  
**NEVER use `ResponsiveHelper.isTablet()` for layout branching.**

**Why:** `AdaptiveShell` is window-based (LayoutBuilder); `ResponsiveHelper.isTablet()` is device-based (`MediaQuery.shortestSide >= 600`). In iPad Split View or Stage Manager narrow windows, a 600dp phone-width window can live on a tablet device — the two predicates disagree, producing a wrong layout. Window-width is the only reliable signal.

**How to apply:** Before writing any `if (isTablet)` layout branch, replace with:
```dart
LayoutBuilder(builder: (context, constraints) {
  final bp = ShellBreakpoint.fromWidth(constraints.maxWidth);
  return bp.isTablet ? _buildTabletLayout() : _buildPhoneLayout();
})
```
Known violation fixed: `calendar_page.dart:52` — replaced `context.isTablet` with `LayoutBuilder(constraints.maxWidth >= 600)` in commit `85ada1e` (PR4a).

---

### RULE 2 — Layer 2 Umbrella Tracker (locked 2026-06-01)

`PR-IPAD-LAYER2` is a tracking label only — NOT a standalone mega-PR.  
Each screen's tablet layout ships inside that screen's owning feature PR.

**Specific rule for PR-DASHBOARD-TABLET:** This placeholder is acceptable because Dashboard has no natural owner PR yet. **It MUST be re-evaluated for folding into a future Dashboard redesign PR once that owner exists.** Do NOT allow it to ship as a perpetually standalone PR.

**Standalone tablet PRs for Tasks/Habits/Spaces:** Do NOT create them without documented justification. Those screens fold their Layer 2 work into their owning feature PRs.

See `IPAD_LAYER2_OWNERSHIP_MAP.md` for per-screen ownership matrix.

---

## Deferred QA Bucket

**Governance rules:**
- First real QA sweep: **AFTER PR6, BEFORE PR7.** Hard ceiling: if bucket reaches **10 items before PR6 ships**, a forced intermediate sweep occurs immediately.
- All fixes in this bucket are **UNVERIFIED** — logical hypotheses, confirmed only on a physical device. Do NOT apply any fix until device validation.
- To add an item: assign an ID (PR origin + sequential number), describe the pass condition, and write the candidate fix as a hypothesis.

**Current count: 5 of 10.**

| ID | Description | Origin | Status |
|----|-------------|--------|--------|
| PR3-R1 | Forest gradient prayer card — dark mode physical device render | PR3 | Unverified |
| PR3-R2 | 44pt countdown legibility on iPhone SE (375×667) | PR3 | Unverified |
| PR4a-G1 | iPhone SE calendar overflow (6-row month) | PR4a | Unverified — see below |
| PR4a-G2 | Today-state dark alpha legibility | PR4a | Unverified — see below |
| DEVICE-1 | Forest-dark surfaces, Cairo fallback, RTL drawer, countdown tick (general device pass) | PR-THEME/PR2 | Unverified |

---

### PR4a-G1 — iPhone SE (375×667) calendar overflow

**Pass condition:** 6-row month fits with no vertical overflow AND "Day events" header is visible without scrolling.

**Why it may fail:** The 64pt cell-height tier triggers at `width >= 360`. iPhone SE is 375dp, which hits the 64pt tier. A 6-row month at 64pt/cell = 384pt of grid, which may push the header below the fold on a 667pt screen.

**Deferred QA Candidate Fix (UNVERIFIED — logical hypothesis, must be confirmed on device before applying):**
```dart
// In dual_calendar_widget.dart — widen the compact tier threshold:
// Change:  constraints.maxWidth < 360 ? 54.0
// To:      constraints.maxWidth < 390 ? 54.0
//
// Alternative: gate on height < 700 using MediaQuery if width alone is insufficient.
```

### PR4a-G2 — Today-state dark mode legibility

**Pass condition:** Today background (`colorScheme.primary @ 0.13` in dark) is visually distinct from the surface on the dark forest theme.

**Deferred QA Candidate Fix (UNVERIFIED — logical hypothesis, must be confirmed on device before applying):**
```dart
// In dual_calendar_widget.dart — raise dark alpha:
// Change:  final double todayAlpha = isDark ? 0.13 : 0.08;
// To:      final double todayAlpha = isDark ? 0.15 : 0.08;
```

---

## Open Items / Hard Blockers

| ID | Item | Gate type |
|----|------|-----------|
| B1 | Calibri App Store licence | Submission gate (not build gate) |
| B3 | Calendar dual-display (`DualDate`) designer spec | PR4b start gate |
| B4 | Adhan audio asset | PR-ADHAN build gate |
| Phase 5 | Physical device validation (all 3 iOS widgets) | Release gate |

_Device QA items (PR3-R1, PR3-R2, PR4a-G1, PR4a-G2, DEVICE-1) are tracked in the Deferred QA Bucket above._
