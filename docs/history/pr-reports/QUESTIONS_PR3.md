# PR3 Open Questions

**Date:** 2026-05-13  
**Status:** Unresolved — implementation blocked on these items  
**Scope:** Only questions that are genuinely unresolved after full reconciliation.  
**Not included:** Already-resolved items (A4 resolved, A8 resolved, A7 clarified).

---

## Q1 · numericMono Font: JetBrainsMono vs Calibri

**Type:** Technical × Design conflict  
**Priority:** HIGH — affects countdown rendering

**Conflict:**  
`COMPONENT_SPECS.md §5` defines:
```dart
static const numericMono = TextStyle(
  fontFamily: 'JetBrainsMono',  // ← explicit
  fontFeatures: [FontFeature.tabularFigures()],
  fontVariations: [FontVariation('wght', 500)],
);
```

`PACKAGE_A_DECISIONS.md #1` states: "Calibri is the sole canonical brand font for both Arabic and English."

`PR1 implementation` applied `numericMono` using Calibri (because Calibri is "sole canonical").

The HTML uses `var(--font-mono)` (defined in `colors_and_type.css` as JetBrainsMono per standard naming convention).

**Question:** For the 64px countdown specifically, should the font be:
1. `JetBrainsMono` (per COMPONENT_SPECS, gives clean tabular digits)  
2. `Calibri` (per Package A Decision #1, brand-consistent)

**Impact of getting this wrong:** If JetBrainsMono is used but not bundled, runtime fallback to system monospace (Courier/Menlo) will look wrong. If Calibri is used for countdown, digits may not be tabular, creating visual jitter on 64px countdown ticks.

**What needs to happen before implementation:** Designer or product owner must confirm which font to use for `numericMono`. If JetBrainsMono, it must be added to `pubspec.yaml` and bundled in `assets/fonts/`.

---

## Q2 · Nafl Badges: Keep on Card or Remove?

**Type:** Feature × Design decision  
**Priority:** HIGH — affects real user feature

**Context:**  
- Production: Duha (orange) and Qiyam (indigo) pill badges render on the card when the user is in a voluntary prayer window
- HTML (authoritative): No badges shown on card
- Spec text: No mention of badges on card

**Two interpretations:**
1. Badges were intentionally omitted from the redesign (cleaner card)
2. Badges were accidentally omitted (they appear in the iOS widget spec and are spiritually meaningful)

**User impact if removed:** Users lose real-time awareness that Duha/Qiyam prayer is currently available. They would only know from the iOS widget.

**If kept, integration question:**  
Current production places badge BETWEEN header and status/time row. New layout has a single centered `div.hero` block. Options for badge placement in the new layout:
- A: Above `div.hero` (current behavior adapted to new layout)
- B: Inline with label text as a small pill to the right/left of "Next prayer"
- C: Below the countdown, above sunrise/sunset row

**Question to designer/product owner:**  
Do Duha and Qiyam badges stay on the in-app card in PR3? If yes, which of the three placement options is correct?

---

## Q3 · "ALLAHU AKBAR" Adhan Moment: State Machine Boundary

**Type:** Technical × Spiritual UX  
**Priority:** HIGH — state machine design

**Conflict:**  
Spec §4 states: "When prayer is 'now' (within ±2 min of adhan time): Time replaced by 'ALLAHU AKBAR'."

**Current state machine:**
- `upcoming`: any time before prayer (includes -∞ to 0 min)
- `justStarted`: 0 to 10 minutes after prayer
- `current`: 10 minutes to end of active window

**The ±2 min adhan window spans TWO existing states:**
- -2 to 0 min: currently `upcoming` (countdown ticking down to 0:02:00 → 0:00:00)
- 0 to +2 min: currently `justStarted` (shows "الآن")

**Sub-questions:**
1. Is the ±2 min window centered on adhan time (-2 to +2), or does it start at adhan time (0 to +2)?
2. During the `adhanMoment` window (before adhan time), should the progress bar still show the countdown fill, or freeze?
3. After `adhanMoment` ends (+2 min elapsed), the user transitions to `justStarted` behavior. Is this smooth or abrupt?
4. The spec says the Arabic text should be `ٱللَّٰهُ أَكْبَرُ`. The spec text says "ALLAHU AKBAR" in English caps. Is `ٱللَّٰهُ أَكْبَرُ` the correct Unicode string? (This is the most sacred UI text in the app — it requires an authoritative source, not inference.)

**Question for product owner:** Please confirm the exact Arabic Unicode string for the adhan moment, the precise time window (±2 min or 0 to +2), and whether there should be haptic feedback at the adhan moment.

---

## Q4 · "Start Dhikr" CTA: Spec Text vs HTML vs Current Behavior

**Type:** Design decision (spec contradiction)  
**Priority:** HIGH — visible feature change

**Three sources disagree:**
1. `PRAYER_CARD_SPEC.md §2 step 5`: "Start dhikr" pill always-visible in compact
2. `comp-prayer-card.html`: No CTA button rendered — compact ends at progress bar
3. Production code: Conditional `🤲` emoji button shown only during active window

**HTML (authoritative) shows no persistent CTA.** This suggests the "Start dhikr" pill was removed from the design at the HTML stage.

**Question for designer:** Is the "Start dhikr" pill:
1. **Absent** (follow HTML — no persistent CTA button)
2. **Conditional** (follow production behavior — show only during active window, as text label)
3. **Always-visible** (follow spec text §2 step 5 — add persistent pill below progress bar)

**Recommendation from reconciliation:** Follow HTML (Option 1). If a pill is desired, it should be conditional on the active window (Option 2), not persistent.

---

## Q5 · Dashboard Height Trade-Off Acceptance (iPhone SE)

**Type:** UX density decision  
**Priority:** HIGH — affects smallest supported device

**Numbers:**
- Current card height: ~140pt
- PR3 compact card estimated height: ~274pt (with 64px countdown + sunrise/sunset)
- iPhone SE 3rd gen usable viewport: ~496pt
- PR3 card occupies: **55% of the iPhone SE usable viewport**
- Remaining for HabitsStrip, StatisticsCard, and task list: **222pt** — HabitsStrip may be partially below fold

**Question:** Is the 55% viewport occupation on iPhone SE acceptable? Options:
1. Accept it — users scroll; the prayer card is the primary focus
2. Reduce card padding on small screens (`ResponsiveLayout` breakpoint)
3. Add a max-height constraint or a phone-small variant of the compact layout
4. Defer Phase 5 (expanded) until compact has been device-tested and validated

**This does NOT block Phase 2 (surface + header). It must be resolved before Phase 3 (hero countdown) can ship.**

---

## Q6 · Active Window Countdown Display Format

**Type:** Behavioral specification gap  
**Priority:** MEDIUM — affects 20–40 minute daily usage window

**Context:**  
The HTML shows the 64px countdown (H:MM:SS) in the `upcoming` state. Spec §4 describes the countdown as "live H:MM:SS" with pulse animation < 60s.

But during the active prayer window (`justStarted` and `current`), the production code shows:
- `justStarted`: "الآن" (static, no countdown)
- `current`: "منذ X د" (elapsed, not a countdown)

**The spec and HTML are designed for the `upcoming` state.** They do not specify what the 64px element shows when the user is IN the prayer window.

**Question:** During `justStarted` and `current` states, what should the 64px display show?
1. The elapsed time "منذ X د" at 64px (same semantic as current, but prominent)
2. Static "الآن" at 64px (simple, spiritual)
3. A progress-toward-end countdown (time remaining in the active window)
4. Static blank / replaced by the dhikr prompt

**Recommendation:** Option 2 ("الآن" at 64px) for `justStarted`; option 1 (elapsed time) for `current` — matches existing semantics with the new visual prominence.

---

## Q7 · Five-Prayer Strip Tap Behavior

**Type:** Feature specification gap  
**Priority:** MEDIUM — expanded mode only

**HTML shows:** Five prayer chips (past/now/next/future) in expanded mode. Past prayers have strikethrough time. Next prayer has a teal highlight.

**Not specified:** What happens when a user taps a chip?
1. Read-only display — no tap action
2. Tap past prayer → show today's tab in PrayerDetailsPage scrolled to that prayer
3. Tap any prayer → navigate to PrayerDetailsPage with that prayer pre-selected

**Recommendation:** Option 1 (read-only). The full-card InkWell already navigates to PrayerDetailsPage. Adding per-chip navigation creates overlapping tap zones.

---

## Q8 · Compact/Expanded Toggle Affordance

**Type:** Interaction design gap  
**Priority:** MEDIUM — expanded mode only

**Package A Decision #8:** "Compact/expanded is widget-local state." But it does not specify the toggle trigger.

**Question:** What triggers the compact/expanded toggle?
1. Tap anywhere on the lower half of the card
2. A dedicated chevron icon at the bottom of the card
3. The card title/header area
4. A specific "expand" label button
5. A card-corner chevron (like iOS Notification Center)

**Impact on implementation:** The `GestureDetector` / `InkWell` tap zone must not conflict with the existing full-card `InkWell` (which navigates to PrayerDetailsPage). Adding a second tap zone requires hit-test priority planning.

---

## Items Explicitly NOT In This List

These were in previous question documents but are now resolved:

| Item | Resolution |
|---|---|
| A4 — Sunset time source | ✅ Maghrib = sunset. Already in `allPrayers`. No architecture needed. |
| A8 — Sunrise arc vs text row | ✅ HTML shows simple text row. No SVG arc. |
| A7 — Progress bar semantic color | 🔄 HTML is definitive: teal gradient. Still awaiting explicit designer confirmation, but direction is clear. |
| A1 — Hero layout direction | 🔄 HTML confirms center-aligned with 64px countdown. Still needs explicit height sign-off (Q5). |
