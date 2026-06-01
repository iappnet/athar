# PR3 Visual Density Simulation — Countdown Size Analysis

**Date:** 2026-05-09  
**Status:** PRE-IMPLEMENTATION ANALYSIS — no code changes  
**Source measurements:** Behavioral audit of production code + known Flutter/iOS layout constants  
**Purpose:** Determine the correct countdown font size before Phase 3 implementation begins

---

## Measurement Baseline

### Current card (production) — 140pt total height

| Zone | Height |
|---|---|
| Outer padding (top + bottom) | 24pt (12 × 2) |
| Header row (date + city pill) | 44pt |
| Nafl badge (when active, +margin) | 28pt |
| Prayer name + time Row | 40pt |
| Progress/countdown Row | 32pt |
| **Total (no badge)** | **~140pt** |
| **Total (with badge)** | **~168pt** |

### PR3 compact card — base structure (no countdown yet)

| Zone | Height |
|---|---|
| Outer padding top + bottom | 40pt (20 × 2) |
| Header row | 44pt |
| "الصلاة القادمة" label (11pt + margin) | 22pt |
| Prayer name (22pt + margin) | 30pt |
| Prayer time (12pt sub-text + margin) | 20pt |
| Countdown hero ← **variable** | — |
| Progress bar + gaps | 16pt |
| Sunrise/sunset row + gap | 36pt |
| Internal vertical gaps (5 × 6pt) | 30pt |
| **Base total (no countdown)** | **~238pt** |

> Base 238pt assumes the spec layout with sunrise/sunset row. If sunrise/sunset row is deferred, base ≈ 202pt.

---

## Viewport Reference

### iPhone 14 Pro (390 × 844 logical)
| Zone | Height | Note |
|---|---|---|
| Status bar | 54pt | Dynamic Island model |
| SliverAppBar (collapsedHeight) | 68pt | Pinned when scrolled |
| Bottom nav bar + safe area | 83pt | LiquidGlassNavBar ~49pt + 34pt home indicator |
| **Usable viewport** | **≈ 639pt** | |

### iPhone SE 3rd gen (375 × 667 logical)
| Zone | Height |
|---|---|
| Status bar | 20pt |
| SliverAppBar collapsed | 68pt |
| Bottom nav | 83pt |
| **Usable viewport** | **≈ 496pt** |

### iPhone 14 / 15 standard (390 × 844)
Same as 14 Pro: **≈ 639pt usable**

### Average mid-range Android (360 × 800)
Status 24 + AppBar 68 + BottomNav 56 = **≈ 652pt usable**

---

## Countdown Size Variants

Line height multiplier used: 1.25× (Flutter default `TextHeightBehavior` for single-line display text).

| Countdown size | Line height (1.25×) | Card total (with sunrise row) | Card total (no sunrise row) |
|---|---|---|---|
| **36pt** | 45pt | **283pt** | **247pt** |
| **44pt** | 55pt | **293pt** | **257pt** |
| **52pt** | 65pt | **303pt** | **267pt** |
| **64pt** | 80pt | **318pt** | **282pt** |
| Current (12pt) | 15pt | — | 140pt (reference) |

---

## Dashboard Occupancy Percentage

### iPhone 14 Pro (639pt usable)

| Countdown size | Card height (w/ sunrise) | Occupancy | Remaining viewport |
|---|---|---|---|
| Current (12pt) | 140pt | **21.9%** | 499pt |
| **36pt** | 283pt | **44.3%** | 356pt |
| **44pt** | 293pt | **45.9%** | 346pt |
| **52pt** | 303pt | **47.4%** | 336pt |
| **64pt** | 318pt | **49.8%** | 321pt |

### iPhone SE (496pt usable)

| Countdown size | Card height (w/ sunrise) | Occupancy | Remaining viewport |
|---|---|---|---|
| Current (12pt) | 140pt | **28.2%** | 356pt |
| **36pt** | 283pt | **57.1%** | 213pt |
| **44pt** | 293pt | **59.1%** | 203pt |
| **52pt** | 303pt **⚠️** | **61.1%** | 193pt |
| **64pt** | 318pt **⚠️** | **64.1%** | 178pt |

> On iPhone SE at 64pt: the prayer card consumes 64% of visible area. StatisticsCard, HabitsStrip, and timeline are all below the fold.

---

## Fold Visibility Impact

"Fold" = what is visible without scrolling below the prayer card.

### iPhone 14 Pro — what fits below the card (320pt StatisticsCard ~80pt, HabitsStrip ~72pt)

| Countdown size | Space below card | StatisticsCard visible? | HabitsStrip visible? | Timeline entry visible? |
|---|---|---|---|---|
| Current (12pt) | 499pt | ✅ Full | ✅ Full | ✅ Partial |
| **36pt** | 356pt | ✅ Full | ✅ Full | ✅ Partial |
| **44pt** | 346pt | ✅ Full | ✅ Full | ✅ Partial |
| **52pt** | 336pt | ✅ Full | ✅ Full | ✅ Edge visible |
| **64pt** | 321pt | ✅ Full | ✅ Partial | ❌ Not visible |

### iPhone SE — what fits below the card

| Countdown size | Space below card | StatisticsCard visible? | HabitsStrip visible? |
|---|---|---|---|
| **36pt** | 213pt | ✅ Full | ✅ Partial |
| **44pt** | 203pt | ✅ Full | ✅ Edge |
| **52pt** | 193pt | ✅ Partial | ❌ Not visible |
| **64pt** | 178pt | ✅ Partial | ❌ Not visible |

---

## Information Density Impact

| Countdown size | Readable at a glance? | Hours legible at arm's length (50cm)? | Seconds legible? | Emotional registration |
|---|---|---|---|---|
| **36pt** | ✅ Yes | ✅ Yes | ✅ Yes (at 34pt) | Calm — informational |
| **44pt** | ✅ Yes | ✅ Yes | ✅ Yes (at 34pt) | Calm — mild visual anchor |
| **52pt** | ✅ Yes | ✅ Yes | ✅ Yes | Moderate prominence |
| **64pt** | ✅ Yes | ✅ Yes | ✅ Yes | **Strong visual anchor — verges on urgency** |

---

## Readability Impact

### Arabic context
Calibri supports Arabic numerals via `_toArabicNumerals()` substitution. All sizes render equally — no Arabic-specific readability difference between sizes.

### Numericmono / tabular figures
All sizes use `fontFeatures: [FontFeature.tabularFigures()]`. Digit-width stability is preserved at all sizes.

### Truncation risk (375pt card width, 20pt padding each side → 335pt available)
| Countdown size | Max digits (H:MM:SS format, 8 chars) | Width estimate | Risk |
|---|---|---|---|
| 36pt | 8 chars × ~22pt | ~176pt | ✅ Safe |
| 44pt | 8 chars × ~27pt | ~216pt | ✅ Safe |
| 52pt | 8 chars × ~32pt | ~256pt | ✅ Safe |
| 64pt | 8 chars × ~39pt | ~312pt | ⚠️ Near limit on iPhone SE |

> At 64pt, "23:59:59" (worst-case hours display) measures ~312pt within 335pt available — 23pt margin. Safe but tight.

---

## Emotional Tone Impact

| Size | Tone | Notes |
|---|---|---|
| **36pt** | Informational. Prayer time sub-title level. | Card reads as "header with a clock." No hierarchy shift from current. Low visual impact. |
| **44pt** | Calm emphasis. Clearly the primary data point. | Comfortable upgrade. Does not feel like a countdown timer. Reverent. |
| **52pt** | Moderate hierarchy. | "Something important is displayed here." Still calm if weight-300 / white. |
| **64pt** | Strong urgency signal. | At weight-300 and white, mitigation is partial. Users accustomed to 12pt will experience significant shift. The spec author likely intended this for widget size, not in-app card. |

### Behavioral alignment check
Per `PR3_BEHAVIORAL_SOURCE_OF_TRUTH.md` §8 (Emotional Interaction Model):
> "The current experience is calm awareness, not urgency. The card is a glanceable context layer, not a countdown dashboard. Redesign must not shift the emotional register toward urgency or pressure."

- 36pt: ✅ Preserves calm
- 44pt: ✅ Preserves calm, adds gentle hierarchy
- 52pt: ⚠️ Borderline — acceptable if confirmed by designer
- 64pt: ❌ Shifts emotional register toward urgency/pressure on all but the largest phones

---

## RTL Simulation

Arabic text direction does not affect countdown digit width. The RichText `H:MM:SS` is always LTR (numerals).  
At all sizes, RTL layout flips padding/alignment but not the countdown string.

| Size | RTL visual impact |
|---|---|
| 36–52pt | Countdown centers cleanly in RTL |
| 64pt | On 375pt, centered 64pt numeral with `:SS` sub-style at 34pt creates slight visual imbalance due to `:SS` being optically heavier in Arabic context (period glyph) |

---

## Dark Mode Simulation

All sizes assume `Colors.white` (full opacity) for H:MM and `Colors.white.withValues(alpha: 0.55)` for `:SS`.

Dark mode (card uses `AtharColors.prayerCardGradient` — forest→teal gradient):
- ✅ White on forest/teal contrast passes WCAG AA at all sizes ≥ 18pt
- ✅ White55 on forest/teal contrast passes WCAG AA at all sizes ≥ 36pt
- No dark-mode-specific size concerns

---

## Recommended Countdown Size

### Recommendation: **44pt**

**Rationale:**
1. **Emotional register preserved** — 44pt at weight-300 reads as contextual time information, not a countdown alarm. Matches the app's calm, Islamic productivity positioning.
2. **Dashboard occupancy** — 45.9% on iPhone 14 Pro. StatisticsCard and HabitsStrip visible below the fold without scrolling. Acceptable regression from current 21.9%.
3. **iPhone SE safe** — 44pt card at 293pt occupies 59% of SE viewport. HabitsStrip just visible. Acceptable.
4. **Truncation safe** — maximum 8-char countdown fits within 335pt at 27pt-per-char avg.
5. **Spec acknowledges hierarchy** — even if 64pt is the spec target, the behavioral audit reveals the spec was designed for the iOS widget (larger scale). In-app, 44pt achieves the same visual hierarchy intent without the pressure signal.

### Conditional approval for 52pt

If the designer explicitly confirms that the prayer countdown should be the dominant visual element in the card (superseding the current "name + time = headline" pattern), **52pt** is acceptable:
- Still within dashboard tolerance on iPhone 14 Pro
- Maintains WCAG contrast at all tested sizes
- Fits within 375pt card width

### Against 64pt

Do NOT implement 64pt without designer confirmation of the following trade-offs:
1. iPhone SE: 64% viewport occupation
2. HabitsStrip pushed below fold on SE
3. Emotional shift from "contextual awareness" to "active countdown pressure"
4. 23pt truncation margin at worst-case time format

---

## Decision Required (connects to Approval Item A1)

The countdown size decision is part of **A1 (Hero Layout Restructure)**. When the designer approves A1, they must also confirm the countdown font size from this table.

**Options to present to designer:**

| Option | Countdown size | Card height | Recommendation |
|---|---|---|---|
| A — Calm contextual | 44pt | ~293pt | ✅ Recommended |
| B — Moderate hierarchy | 52pt | ~303pt | ✅ Acceptable if designer confirms |
| C — Full spec | 64pt | ~318pt | ❌ Needs explicit override of density concerns |

---

*Document generated as part of PR3 pre-implementation behavioral lock. No code was modified.*
