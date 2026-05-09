# PR3 Approval Required Items

**Date:** 2026-05-09  
**Status:** PENDING — Implementation MUST NOT start until each item is explicitly resolved  
**Raised by:** PR3_VISUAL_READINESS_AUDIT  

---

## How to Use This File

For each item below, the designer/product owner must provide an explicit decision.  
Mark each item with: ✅ APPROVED / ❌ REJECTED / 🔄 MODIFIED  
Provide the decision text under each item.

**Zero items may be "assumed" or "inferred" by the engineer. All must be explicit.**

---

## CRITICAL ITEMS — Implementation Blocked

### A1 · Hero Layout Restructure (Prayer Name + Time → Centered Stack)

**Current behavior:**  
Prayer name and prayer time are displayed side-by-side in a `Row(spaceBetween)`:  
- Left: "المغرب" (26sp bold)  
- Right: "17:42" (26sp weight-300)

**Proposed spec behavior:**  
Center-aligned vertical hero stack:
- Label: "الصلاة القادمة" (11pt, uppercase, 55% white)
- Prayer name: 22pt bold, centered
- Prayer time: 12pt, 70% white, centered (demoted from hero to sub-text)
- Countdown: **64pt numericMono** — dominant visual element

**User muscle memory risk:** HIGH. Users who use the card as a quick prayer-time clock currently find the time prominently on the right at 26sp. After this change, the time becomes a small 12pt sub-text. The COUNTDOWN becomes the dominant element.

**Emotional design risk:** The countdown at 64pt could feel like "pressure" (a timer racing down). The weight-300 and calm typography mitigate this — but it needs visual validation.

**Question for designer:** Is the center-aligned hero the intended direction even though it demotes the prayer time from a large clock to a small label?

**Decision:** _________________

---

### A2 · CTA Contradiction — Pill vs Absent

**Current behavior:**  
Conditional `🤲` emoji circle button. Only shown when prayer window is active (`justStarted` or `current` states). Taps → DhikrBottomSheet.

**PRAYER_CARD_SPEC.md §2.5 says:**  
"Start dhikr" pill button (AppColors.cream bg, AppColors.forest ink) — listed as step 5 of the compact layout, implying it is always present.

**comp-prayer-card.html shows:**  
No CTA button rendered in either the compact or expanded variants. Neither the Arabic RTL nor English LTR preview shows any pill button.

**These are directly contradictory.** Implementing the pill-always approach changes user experience significantly — users would see a dhikr button even when not in a prayer window, potentially creating confusion about when dhikr is appropriate.

**Options:**
1. Keep current: conditional emoji button (no change needed in Phase 6)
2. Implement spec text: always-visible "Start dhikr" pill (requires Phase 6 change)
3. Always-visible pill but only tappable during active window (disabled state when inactive)

**Decision:** _________________

---

### A3 · Nafl Badges (Duha/Qiyam) — Keep or Remove from Card

**Current behavior:**  
The card shows orange (Duha) or indigo (Qiyam) pill badges when `status.isDuhaTime` or `status.isQiyamTime` is true.

**Spec says:**  
`PRAYER_CARD_SPEC.md` does not mention nafl badges. `comp-prayer-card.html` does not render them. They appear in the iOS widget spec only.

**Two interpretations:**
1. Badges are **widget-only** — they should be removed from the in-app card
2. Badges are **both places** — the spec simply omitted them (accidental omission)

**Risk of removal:** Users currently get contextual awareness of Duha/Qiyam windows via the badge. Removing it from the card reduces this awareness. They would only see it in the iOS widget.

**Decision:** _________________

---

### A4 · Sunset Time Data Source

**Current situation:**  
`PrayerTimerService` computes Duha/Qiyam using only `PrayerType.sunrise`. Sunset time is **not computed or stored** anywhere in the current service.

**Spec requires:**  
Both the compact and expanded card show "Sunset HH:MM" on the right of the sunrise/sunset row.

**Options to obtain sunset time:**
1. Parse it from the prayer API response (check if the API returns sunset)
2. Compute it from Fajr/Isha times using an approximation
3. Use a separate library (adhan package) to compute sunset

**Question:** Does the prayer API (`prayer_remote_source.dart`) already return sunset time? If yes, it needs to be threaded through. If not, what is the approved source?

**Decision:** _________________

---

### A5 · "ALLAHU AKBAR" Moment State — Tone Approval

**Proposed behavior:**  
When within ±2 minutes of the adhan time, the card's countdown area is replaced with:
- Large text: `ٱللَّٰهُ أَكْبَرُ` (Arabic, cream color, `AppText.titleM`)
- Sub-text: "Pray now" / "الصلاة الآن" (bodyS, white70)

**This is the most spiritually significant UI moment in the entire app.** The exact Arabic text, typography, size, duration, and animation must be approved by the product owner/designer, not assumed from the spec.

**Questions:**
1. Is the Arabic text `ٱللَّٰهُ أَكْبَرُ` the approved string? (Note: the spec says "ALLAHU AKBAR" in English caps — the Arabic rendering must be confirmed)
2. Should there be any animation (e.g., fade-in, gentle pulse)?
3. Should the card emit a haptic (e.g., `HapticFeedback.lightImpact()`) when entering this state?
4. Is ±2 min the correct window? (The current `justStarted` window is 0–10 min; this would overlap)

**Decision:** _________________

---

## HIGH-PRIORITY ITEMS — Phase Gated

### A6 · Compact/Expanded Mode — Implementation Approach

**Spec behavior:**  
Compact/expanded is widget-local state. User toggles it by tapping (trigger area unspecified). Variant persists to App Group's `UserDefaults` so the iOS widget shows the same variant.

**Questions:**
1. What is the tap target for the toggle? (Card title? Dedicated chevron icon? Tap anywhere on the card's lower half?)
2. Should compact be the default for all users, or respect the existing `prayerCardDisplayMode` setting?
3. Should the App Group write happen synchronously on toggle, or on app backgrounding?
4. Expanded mode significantly increases card height (~230pt vs current ~90pt). Is there a max-height constraint?

**Decision:** _________________

---

### A7 · Progress Bar Fill — Semantic Color vs Fixed Teal Gradient

**Current behavior:**  
Progress bar fill color is state-coded:
- 🟢 Green (`0xFF4CAF50`) when `justStarted` — communicates "prayer has just begun"
- 🔵 Blue (`0xFF29B6F6`) when `current` — communicates "prayer window is active"  
- 🟡 Amber when `upcoming` — communicates "counting down"

**Spec behavior:**  
Fixed `linear-gradient(90deg, #7FE3DA → #fff)` regardless of state. Teal glow applied.

**Risk:**  
Removing state-coded color removes a semantic signal. Users who rely on the green fill to know "prayer has started" will lose that visual cue. The teal gradient is aesthetically consistent but semantically neutral.

**Question:** Is this a deliberate design decision (simpler, brand-consistent, less distracting) or an oversight in the spec?

**Decision:** _________________

---

## MEDIUM-PRIORITY ITEMS — Can Be Resolved During Implementation

### A8 · "Sunrise/Sunset Arc" vs Simple Row

**PRAYER_CARD_SPEC.md §3 says:**  
"Half-circle SVG, 100pt wide × 50pt tall, centered. Sun glyph travels along the arc per current time-of-day."

**comp-prayer-card.html shows:**  
A simple text row with sunrise/sunset icons and times. No arc SVG. No moving sun glyph.

**Building a sun-arc with an animated glyph is significantly more complex** than the simple text row the HTML shows.

**Question:** Which is the implementation target — the simple text row (HTML) or the arc with moving sun glyph (spec text)?

**Decision:** _________________

---

### A9 · Dashboard Height Impact Acceptance

**Current estimate:**  
PR3 compact card will be approximately 220–240pt tall (vs current ~96pt). This increases card height by ~130%.

On a 375×812 device:
- Available height: ~698pt (minus nav + status bars)
- Card will consume ~33% of visible area
- Tasks section will require scroll to access

**Question:** Is this density/height increase acceptable, or should there be a max-height constraint on the compact card?

**Decision:** _________________

---

### A10 · HabitCubit Scope on All Pages

**Current behavior:**  
`NextPrayerCard` reads `context.read<HabitCubit>()` in `_buildProgressRow`. This works on `MainPage` (which provides a local `HabitCubit`), but `SmartPrayerCardWrapper` can also render the card on the Tasks page, Habits page, and Projects page.

**Risk:**  
If the card is rendered on a page where `HabitCubit` is not in scope, tapping the `🤲` button will throw.

**Question:** Should the `HabitCubit` read be protected with `context.maybeRead<HabitCubit>()` (null-safe), or should we ensure `HabitCubit` is always in scope for all pages where the card appears?

**This is an existing bug, not a PR3 regression.** But PR3 is an opportunity to fix it.

**Decision:** _________________

---

## INFORMATIONAL — No Action Required Before Start

### I1 · RTL Bug Fix (Will Be Fixed in PR3)

`EdgeInsets.only(left: AtharSpacing.xxxs)` in city text padding → will be changed to `EdgeInsetsDirectional.only(start: ...)` in Phase 2. No approval needed.

### I2 · Progress Bar RTL Fix (Will Be Fixed in PR3)

Hardcoded `Directionality(textDirection: ui.TextDirection.rtl)` → will be changed to locale-aware transform in Phase 4. No approval needed.

### I3 · Skeleton Loading State (Upgrade, Not Regression)

`CircularProgressIndicator` → skeleton gradient placeholder. Additive improvement. No approval needed.

---

## Approval Status Tracker

| Item | Priority | Status | Approved By |
|---|---|---|---|
| A1 — Hero layout restructure | CRITICAL | ⏳ PENDING | — |
| A2 — CTA pill vs absent | CRITICAL | ⏳ PENDING | — |
| A3 — Nafl badges keep/remove | CRITICAL | ⏳ PENDING | — |
| A4 — Sunset time data source | CRITICAL | ⏳ PENDING | — |
| A5 — ALLAHU AKBAR tone | CRITICAL | ⏳ PENDING | — |
| A6 — Compact/expanded approach | HIGH | ⏳ PENDING | — |
| A7 — Progress bar color semantic | HIGH | ⏳ PENDING | — |
| A8 — Sunrise arc vs text row | MEDIUM | ⏳ PENDING | — |
| A9 — Dashboard height acceptance | MEDIUM | ⏳ PENDING | — |
| A10 — HabitCubit scope fix | MEDIUM | ⏳ PENDING | — |

**Implementation may begin Phase 1 (domain model only) once A4, A5 are resolved.**  
**Implementation may begin Phase 2 (surface + header) once A1, A3 are resolved.**  
**Implementation may begin Phase 3 (hero countdown) once A1 is resolved.**  
**Implementation may begin Phase 5 (expanded) once A2, A6 are resolved.**  
**Implementation may begin Phase 6 (CTA) once A2 is resolved.**  
**Phase 4 (progress bar) requires A7, A8.**
