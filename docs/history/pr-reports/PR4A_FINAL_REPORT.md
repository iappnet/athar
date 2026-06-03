# PR4a Final Report — Calendar Visual Refresh

**Status:** ✅ Code-complete · 2 device-QA gates deferred  
**Implementation commit:** `85ada1e`  
**Sign-off commit:** `1beff60`  
**Tag:** `athar-v2-pr4a-complete` → `1beff60` (local + remote ✅)  
**Date:** 2026-06-01  
**Branch:** `feat/athar-v2-pr1-tokens-theme`

---

## Files Changed

| File | Change type | Lines Δ |
|------|------------|---------|
| `lib/features/calendar/presentation/pages/calendar_page.dart` | Modified | +102 / -142 |
| `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` | Modified | +224 / -135 |
| `VERIFICATION_PR4A.md` | Created | +226 |

3 files changed, 552 insertions(+), 277 deletions(−).

---

## Architectural Changes

### RULE 1 Violations Fixed (P0 — mandatory)

1. **`calendar_page.dart`** — `context.isTablet` removed; replaced with `LayoutBuilder(constraints.maxWidth >= 600)`. Device-based predicate eliminated; window-based predicate installed.

2. **`dual_calendar_widget.dart`** — hardcoded `childAspectRatio: 0.85` removed; replaced with a `LayoutBuilder`-computed ratio derived from the width-based cell height tiers (54/64/72 pt). The aspect ratio is now a function of the container width, not a magic constant.

**Why RULE 1 matters:** `AdaptiveShell` uses `LayoutBuilder` (window-based). `context.isTablet` uses `MediaQuery.shortestSide >= 600` (device-based). In iPad Split View or Stage Manager, a narrow window on a tablet device causes the two predicates to disagree, producing the wrong layout. Window-width is the only reliable signal.

### Three-tier cell height system introduced

```
constraints.maxWidth < 360 → 54pt (compact)
constraints.maxWidth < 480 → 64pt (default)
constraints.maxWidth >= 480 → 72pt (tablet)
```

Cell aspect ratio is computed at runtime from `(cellHeight / (cellHeight + spacingConstant))`.

### RTL-aware navigation chevrons

`Icons.arrow_back_ios` / `Icons.arrow_forward_ios` (fixed-direction) replaced with `Icons.chevron_left` / `Icons.chevron_right` in a `Directionality`-aware `Row`. In RTL (`ar`), the row reversal makes chevron_right appear on the left and chevron_left on the right — correct arrow semantics without icon-flipping logic.

---

## Token Migration (P1)

| Before (hardcoded) | After (token) | Token |
|-------------------|--------------|-------|
| `fontSize: 10` | `AtharTypography.sizeXxs` | `sizeXxs` |
| `fontSize: 11` | `AtharTypography.sizeXs` | `sizeXs` |
| `fontSize: 12` | `AtharTypography.sizeSm` | `sizeSm` |
| `fontSize: 13` | `AtharTypography.sizeMd` | `sizeMd` |
| `fontSize: 14` | `AtharTypography.sizeLg` | `sizeLg` |
| `fontSize: 16` | `AtharTypography.sizeXl` | `sizeXl` |
| `EdgeInsets.all(4)` | `AtharSpacing.xs` | `xs` |
| `EdgeInsets.symmetric(...)` | `AtharSpacing`/`AtharGap` variants | various |

8 hardcoded font sizes and 5 hardcoded spacing values replaced. All calls to `responsive_helper.dart` removed (no remaining usage in calendar files).

---

## Today State (P1)

| Property | Light | Dark |
|----------|-------|------|
| Background | `colorScheme.primary @ 0.08` | `colorScheme.primary @ 0.13` |
| Border | none | none |
| Numeral colour | `colorScheme.primary` | `colorScheme.primary` |
| Numeral weight | `FontWeight.bold` | `FontWeight.bold` |

Selected (non-today) numeral: `FontWeight.bold`, default colour.  
Unselected: `FontWeight.normal`, default colour.

---

## RTL + Locale Date (P2)

- Navigation row uses `Directionality`-aware child ordering — no explicit `TextDirection` hacks.
- Day-events header date now locale-aware: `DateFormat.yMMMMEEEEd('ar')` in Arabic locale, `DateFormat.yMMMMEEEEd('en')` in English.

---

## Container Shape + Shadow (P3)

| Property | Before | After |
|----------|--------|-------|
| Bottom radius | `BorderRadius.vertical(bottom: 30.r)` | flat (removed) |
| Shadow blur | 10 | 8 |
| Shadow offset | (0, 5) | (0, 3) |
| Shadow alpha | 0.05 | 0.06 |

---

## PR4a Scope Enforcement

All of the following were explicitly deferred to PR4b. `// PR4b.` comments placed where deferred work will land:
- `DualDate` value object
- `CalendarCell` widget refactor
- `DualMonthSwitcher`
- `activityByDate` map in `CalendarCubit`
- Simultaneous Hijri + Gregorian display
- CalendarCubit 4-source fan-in

---

## Deferred QA Gates

See `CURRENT_MIGRATION_STATE.md` → **Deferred QA Bucket** for full tracking.

| Gate | Risk | Candidate fix |
|------|------|--------------|
| G1 — iPhone SE (375×667) calendar overflow | 6-row month at 64pt/cell = 384pt may exceed 667pt screen | Widen compact tier: `width < 360` → `width < 390` |
| G2 — Today-state dark mode legibility | `primary @ 0.13` may not read on dark forest surface | Raise alpha: `0.13` → `0.15` |

Both fixes are one-line, low-risk, no re-audit required. Gate status: **UNVERIFIED** — must be confirmed on a physical device before applying.

---

## Verification Summary

**`flutter analyze`:** 0 issues  
**`flutter test`:** 45/45 passed (16 golden + 28 stats + 1 config)  
**Golden tests affected:** 0 (calendar has no golden suite; PR3 goldens unchanged)  
**Rollback point:** `fd018a0` (pre-implementation, pre-PR4a) — all PR4a changes are in `85ada1e` only

---

## Risks

| Risk | Severity | Notes |
|------|----------|-------|
| G1 — iPhone SE overflow | Low | One-line fix available; no re-audit needed |
| G2 — Dark today alpha | Low | One-line fix available; no re-audit needed |
| `// PR4b.` tech debt markers | Low | Deferred scope clearly marked; no code smell |
| `responsive_helper.dart` import removed | None | File still exists; other callers unaffected |
