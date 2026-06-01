# PR3 Blockers and Open Assumptions

**Date:** 2026-05-13  
**Type:** Pre-implementation gate document — no code modified  
**Authority:** Synthesized from all PR3 pre-implementation documents  
**Purpose:** Single source of truth for what blocks PR3, what assumptions are being made, and the safe-to-start verdict.

---

## Part 1 — Hard Blockers

These items MUST be resolved before the specified phase can begin. Code cannot be written without these answers.

---

### BLOCKER-1 · adhanMoment Arabic Unicode string

| Field | Detail |
|---|---|
| **Blocks** | Phase 7 (adhanMoment state + UI) |
| **From** | Q3 in `QUESTIONS_PR3.md` |
| **What is needed** | The exact Unicode codepoints for `ٱللَّٰهُ أَكْبَرُ` from an authoritative source (product owner or religious advisor) |
| **Why it blocks** | This is the most sacred UI text in the app. Incorrect diacritics = incorrect Arabic = unacceptable religious error. Cannot be inferred. |
| **Current status** | UNRESOLVED |
| **Who can resolve** | Product owner / religious authority |

---

### BLOCKER-2 · adhanMoment time boundary (±2 min or 0 to +2 min)

| Field | Detail |
|---|---|
| **Blocks** | Phase 7 (adhanMoment state detection in `PrayerTimerService`) |
| **From** | Q3 in `QUESTIONS_PR3.md` |
| **What is needed** | Confirmation: does the `adhanMoment` window start 2 minutes BEFORE adhan time (−2 to +2 min) or only AFTER (0 to +2 min)? |
| **Why it blocks** | The state machine boundary logic in `_emitStatus()` differs fundamentally between the two options. Also affects whether the countdown ticks to 0:02:00 vs showing "ALLAHU AKBAR" 2 minutes early. |
| **Current status** | UNRESOLVED |
| **Who can resolve** | Product owner |

---

### BLOCKER-3 · numericMono font — JetBrainsMono vs Calibri

| Field | Detail |
|---|---|
| **Blocks** | Phase 3 (hero countdown at 64px) |
| **From** | Q1 in `QUESTIONS_PR3.md` |
| **What is needed** | Designer or product owner confirms: use JetBrainsMono (per COMPONENT_SPECS §5) or Calibri (per Package A Decision #1) for the 64px countdown? |
| **Why it blocks** | If JetBrainsMono: must bundle TTF files + pubspec declaration before countdown ships. If Calibri: must update `numericMono.fontFamily`. Without resolution, countdown will silently render in system monospace (Menlo/Courier) at 64px — visually prominent regression. |
| **Current status** | UNRESOLVED |
| **Who can resolve** | Designer (COMPONENT_SPECS author) + product owner (brand decision) |

---

### BLOCKER-4 · Compact/expanded toggle approval + affordance

| Field | Detail |
|---|---|
| **Blocks** | Phase 6 (expanded mode) |
| **From** | Q8 in `QUESTIONS_PR3.md`; Approval Item A6 |
| **What is needed** | (a) Approval to implement compact/expanded toggle. (b) Specified toggle affordance: chevron? header tap? dedicated button? |
| **Why it blocks** | The expand/collapse gesture must not conflict with the full-card InkWell (PrayerDetailsPage). Hit-test priority cannot be designed without knowing the toggle trigger. |
| **Current status** | UNRESOLVED |
| **Who can resolve** | Designer (A6) + interaction designer (Q8) |

---

### BLOCKER-5 · Nafl badges placement confirmation

| Field | Detail |
|---|---|
| **Blocks** | Phase 4 final layout (nafl badge position in new vertical layout) |
| **From** | Q2 in `QUESTIONS_PR3.md`; Approval Item A3 |
| **What is needed** | Designer confirms: keep badges on card? If yes, which placement option (A: above hero / B: inline with label / C: below countdown)? |
| **Why it blocks** | The badge position interacts with the centered hero Column. The layout cannot be finalized without knowing whether a badge element appears above/within/below the hero. |
| **Current status** | UNRESOLVED |
| **Who can resolve** | Designer (A3) |

---

### BLOCKER-6 · iPhone SE height acceptance

| Field | Detail |
|---|---|
| **Blocks** | Phase 3 (hero countdown — the component that makes the card tall) from shipping to production |
| **From** | Q5 in `QUESTIONS_PR3.md`; Approval Item A9 |
| **What is needed** | Product owner explicitly accepts that the PR3 card occupies ~55% of iPhone SE viewport, or requests a max-height constraint / small-screen variant |
| **Why it blocks** | Without sign-off, shipping a card that dominates the smallest supported screen may be rejected at review. Implementing a max-height constraint after Phase 3 is a retroactive change. |
| **Current status** | UNRESOLVED |
| **Who can resolve** | Product owner (A9) |

---

## Part 2 — Open Assumptions

These are assumptions currently being made in the implementation plan. Each assumption is explicit, not hidden. If any assumption is wrong, the corresponding phases must be redesigned.

---

### ASSUMPTION-1 · Sunrise = `PrayerType.sunrise` in `allPrayers`

**Assumed:** `widget.allPrayers` contains a `Prayer` with `type == PrayerType.sunrise` and it can be read directly in the card without any service change.  
**Confidence:** HIGH (confirmed by reading prayer_cubit.dart and the sunrise exclusion filter which implies it IS in allPrayers)  
**Risk if wrong:** Sunrise/sunset row will crash on `firstWhereOrNull` returning null; row will silently not render  
**Mitigation:** Guard with null check; fallback to hidden row

---

### ASSUMPTION-2 · Sunset = Maghrib time

**Assumed:** In the Umm al-Qura calculation method, the Maghrib prayer time equals sunset. Displaying Maghrib time as "sunset" in the sunrise/sunset row is correct.  
**Confidence:** HIGH (confirmed resolved as Approval Item A4)  
**Risk if wrong:** Wrong time displayed in the sunset position  
**Mitigation:** None needed — this is confirmed

---

### ASSUMPTION-3 · iOS widget does NOT consume `timeLeft` string

**Assumed:** The iOS widget reads `WidgetKeys.remainingSeconds` (int) for countdown display, NOT the `timeLeft` string. Therefore changing `_formatDuration()` to H:MM:SS format is safe and does not break the widget.  
**Confidence:** HIGH (confirmed by reading widget_data_service.dart — only int key pushed for remaining time)  
**Risk if wrong:** iOS widget countdown display breaks after `_formatDuration` format change  
**Mitigation:** Verify `WidgetKeys.remainingSeconds` is the only widget countdown input before committing format change

---

### ASSUMPTION-4 · `fullDate`/`fullDateEn` have no other consumers

**Assumed:** The combined `fullDate` and `fullDateEn` fields on `PrayerTimerStatus` are consumed only by `next_prayer_card.dart`. They will coexist with new `hijriDate`/`gregorianDate` split fields and not be removed.  
**Confidence:** MEDIUM (only verified next_prayer_card as consumer; other files not grep-checked)  
**Risk if wrong:** Removing `fullDate` breaks an unknown consumer  
**Mitigation:** Keep `fullDate`/`fullDateEn` permanently; never remove. Zero cost to keeping them.

---

### ASSUMPTION-5 · `AtharAnimations.createController()` is the correct animation pattern

**Assumed:** Using `AtharAnimations.createController()` factory in `NextPrayerCard` (as used in LiquidGlassNavBar) is the correct approach for the pulse animation.  
**Confidence:** MEDIUM  
**Risk if wrong:** Animation pattern mismatch or controller lifecycle issue  
**Mitigation:** Review LiquidGlassNavBar implementation before Phase 5

---

### ASSUMPTION-6 · `BackdropFilter` will not cause performance issues on city pill

**Assumed:** `BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8))` on the small city pill widget is acceptable performance (pill is ~60×26pt, not full-card).  
**Confidence:** HIGH (BackdropFilter on small elements is standard iOS/Flutter glass pattern)  
**Risk if wrong:** Frame rate drop on lower-end Android  
**Mitigation:** Profile after city pill implementation on mid-range Android

---

### ASSUMPTION-7 · No 5-prayer strip navigation (read-only chips)

**Assumed:** Tapping a prayer chip in the expanded 5-prayer strip does NOT navigate. The full-card InkWell already provides navigation to PrayerDetailsPage. Chip taps are ignored or absorbed.  
**Confidence:** MEDIUM (no spec contradicts this; recommended in QUESTIONS_PR3.md Q7)  
**Risk if wrong:** Users expect tap action on chips; navigation to past/future prayers from chips  
**Mitigation:** Confirm with Q7 resolution before Phase 6; default to read-only is safest

---

### ASSUMPTION-8 · H:MM:SS format uses no Arabic-Indic conversion (colons are universal)

**Assumed:** The `:` colon character in `"1:14:32"` is universal and should not be converted to Arabic-Indic. Only digits undergo `_toArabicNumerals()`.  
**Confidence:** MEDIUM (current `_toArabicNumerals()` converts digits `0-9` only; `:` is not in the conversion map)  
**Risk if wrong:** Designer expects Latin digits in countdown even in Arabic locale (Eastern Numerals not applied to countdown)  
**Mitigation:** Confirmed pending designer input (see R-B3 in Risk Register)

---

## Part 3 — Partially Resolved Items

These items have a clear direction but need explicit sign-off before final implementation.

| Item | Current Direction | Needs |
|---|---|---|
| A7 · Progress bar fill color | HTML says teal gradient. Direction clear. | Explicit designer "yes" before Phase 4 |
| Q4 · Dhikr CTA | HTML says no persistent pill. Current conditional `🤲` is correct approach. | Explicit designer "confirmed, move position only" |
| Q6 · Active window 64px display | Recommendation: "الآن" at 64px for justStarted; elapsed for current | Product owner confirmation |
| A8 · Sunrise/sunset row format | HTML shows simple text row (no SVG arc). Resolved. | No further approval needed |

---

## Part 4 — Safe-to-Start Verdict

### Overall: **CONDITIONAL GREEN — Phase 1 and 2 are safe to start**

---

### Phase 1 — Domain changes: **SAFE TO START**

All Phase 1 changes are additive and non-breaking:
- Add `secondsRemaining` to `PrayerTimerStatus` ✅
- Add `hijriDate` + `gregorianDate` to `PrayerTimerStatus` ✅
- Change `_formatDuration` to H:MM:SS ✅ (only one consumer; iOS widget uses int, not string)
- Add split date computation to `PrayerTimerService` ✅
- Add `sizeDisplay64` to `AtharTypography` ✅
- Add missing l10n keys (sunset, enableLocation, expand, collapse) ✅

None of these are blocked by open questions.

---

### Phase 2 — Surface + loading/error states: **SAFE TO START**

Changes are visual upgrades with no behavioral impact:
- Upgrade shadow to HTML two-shadow values ✅
- Add Stack + gradient glass overlay (NO BackdropFilter on card) ✅
- Upgrade loading state to skeleton shimmer ✅
- Upgrade error to `ErrorState.inline` ✅
- Add permission-denied specific text ✅

---

### Phase 3 — Header: **SAFE TO START (with one condition)**

- Split date header ✅ (depends on Phase 1 domain changes)
- Frosted city pill ✅ (BackdropFilter on pill only)
- City padding RTL bug fix ✅

**Condition:** Phase 1 domain changes must be committed first.

---

### Phase 4 — Hero layout: **BLOCKED on Q1 (font)**

Phase 4 includes the 64px countdown. Cannot ship without knowing font.

**Blocked items:**
- Q1: JetBrainsMono vs Calibri for `numericMono` (BLOCKER-3)
- A3: Nafl badge placement in new layout (BLOCKER-5) — can proceed without badge resolution but final badge position will need a follow-up commit
- Q5: iPhone SE height sign-off (BLOCKER-6) — can implement and build; cannot merge to production without sign-off

**Partial start allowed:** Hero layout restructure (Row → Column) can begin. 64px countdown text can be stubbed with a placeholder size pending Q1 resolution.

---

### Phase 5 — Animations: **SAFE TO START after Phase 4**

No unresolved blockers. `AtharAnimations` infrastructure exists. Depends on Phase 4 completion.

---

### Phase 6 — Expanded mode: **BLOCKED on A6 + Q8**

- A6: Compact/expanded approval not received (BLOCKER-4)
- Q8: Toggle affordance not specified (BLOCKER-4)
- `WidgetKeys.prayerCardVariant`: key string must be finalized (R-B4)

**Do not start Phase 6 until all three are resolved.**

---

### Phase 7 — adhanMoment state: **BLOCKED on Q3**

- BLOCKER-1: Sacred Arabic text required
- BLOCKER-2: Time boundary required

**Do not start Phase 7 until both are resolved.**

---

## Part 5 — Final Verdict Table

| Metric | Value | Basis |
|---|---|---|
| **Implementation readiness %** | ~47% | Full verification table in `PR3_IMPLEMENTATION_READINESS_VERIFICATION.md §6` |
| **Reusable infrastructure %** | ~68% | Migration matrix Section 7 |
| **Hidden complexity level** | MEDIUM-HIGH | Switch cascade, font gap, sacred text, hit-test layering |
| **Highest-risk subsystem** | `next_prayer_card.dart` hero rebuild | Complete structural change; 20% current readiness |
| **Most dangerous assumption** | iOS widget does not consume `timeLeft` string | If wrong, `_formatDuration` change breaks widget |
| **Recommended first phase** | Phase 1 (domain) | Additive, unblocked, enables all later phases |
| **Hard blockers** | 6 (see Part 1) | Q1, Q3×2, A3, A6+Q8, A9 |
| **Safe-to-start verdict** | **YES for Phases 1–3** | Unblocked, additive, no open questions |
| **Blocked phases** | Phase 4 (Q1), Phase 6 (A6+Q8), Phase 7 (Q3) | Do not start until resolved |

---

## Part 6 — Resolution Checklist

Before each phase, verify:

**Before Phase 4 (hero countdown):**
- [ ] Q1 resolved: font family confirmed for `numericMono`
- [ ] If JetBrainsMono: TTF files added to `assets/fonts/` + `pubspec.yaml` declaration
- [ ] `sizeDisplay64 = 64.0` added to `AtharTypography`
- [ ] Phase 1 and Phase 2 committed and passing `flutter analyze`

**Before Phase 6 (expanded mode):**
- [ ] A6 approved: product owner confirms compact/expanded toggle feature
- [ ] Q8 answered: toggle affordance specified
- [ ] `WidgetKeys.prayerCardVariant` string finalized (never-rename contract acknowledged)
- [ ] Phase 4 and Phase 5 committed and device-tested on D1 + D2

**Before Phase 7 (adhanMoment):**
- [ ] Q3a: Exact Arabic Unicode string for Allahu Akbar provided by authoritative source
- [ ] Q3b: Time boundary confirmed (±2 min or 0 to +2 min)
- [ ] Q3c: Haptic feedback decision (yes/no/pattern)
- [ ] `prayerCardAllahuAkbar` l10n key added with authoritative string
- [ ] `PrayerTimerLabel.adhanMoment` added and ALL switch expressions updated

**Before any phase merges to main:**
- [ ] `flutter analyze` passes with zero issues
- [ ] Full-card InkWell → PrayerDetailsPage tap confirmed working
- [ ] Dhikr button: visible in justStarted/current, absent in upcoming
- [ ] Progress bar fill direction correct in L1 (RTL fills right-to-left) and L2 (LTR fills left-to-right)
