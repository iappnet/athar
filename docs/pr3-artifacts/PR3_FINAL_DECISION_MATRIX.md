# PR3 Final Decision Matrix — Prayer Card Refresh

> ⚠️ **AUTHORITY BANNER (added 2026-05-31 by Design).** This matrix was
> synthesized from the **older** PR3 reports and predates
> `PR3_DESIGN_RULINGS.md`. Where the two conflict, **`PR3_DESIGN_RULINGS.md`
> wins** and the rows below are stale. Specifically:
>
> | Matrix row | Status now | Ruling |
> |---|---|---|
> | **R4 "countdown = 64px"** | **WRONG — superseded** | Locked **44px** (40px under 700pt height). Rulings §B. |
> | **R5 shadow (teal `#0D7377`)** | superseded | Forest shadows `#0F3D2E` / `#1A5A45`. Rulings §E.2. |
> | Surface gradient teal `#1A6B3C→#0D7377` | superseded | Forest `#0F3D2E→#1A5A45`. Rulings §E.3. |
> | **U1** numericMono font | **RESOLVED** | **JetBrains Mono** for numerals. Rulings §A/B3. |
> | **U2 + U3** nafl badges keep + placement | **RESOLVED** | Keep; **Option A** (below countdown, above sunrise). Rulings §A/D. |
> | **U4 + U5 + U6** adhanMoment text / boundary / haptic | **DISSOLVED** | No adhanMoment state. **Phase 7 cancelled.** Rulings §C. |
> | **U7** compact/expanded toggle | **RESOLVED** | **No on-card toggle.** Compact = phone/dashboard; expanded = Prayer page + iPad. Rulings §B4. |
> | **U8** progress fill | **RESOLVED** | Teal→white gradient, directionality-aware. Rulings §E.4. |
> | **U9** iPhone SE height | **RESOLVED** | Accepted at 44px. Rulings §B6. |
> | **U11** active-window 64px display | **RESOLVED** | No countdown during active window — name promotes to 36px + "Started at" stamp. Rulings §C. |
> | **U12** countdown numerals in Arabic | **RESOLVED** | Digits convert via existing `_toArabicNumerals` when Arabic+Eastern on; colon stays. Rulings §F. |
> | **U13** dhikr CTA form | **RESOLVED** | No persistent pill; keep conditional affordance as a **text button** during active window only. Rulings §D. |
>
> **Net: of the 13 "unresolved" items, all 13 are now resolved or dissolved.**
> The Product-Owner items U4/U5/U6 are **moot** (the feature they gated no
> longer exists). The Engineering items (E1–E10) and the locked items
> (R1–R3, R6–R20) below remain valid as written. Use the **Gate 5
> pre-merge checklist** (still valid) but ignore Gates 2–4's blocked status —
> those blockers are cleared.

---

# PR3 Final Decision Matrix (original, as received from Claude Code)

**Date:** 2026-05-31  
**Synthesized from:** PR3_APPROVAL_REQUIRED_ITEMS.md · PR3_BLOCKERS_AND_OPEN_ASSUMPTIONS.md · PR3_REQUIRED_DESIGN_CORRECTIONS.md · QUESTIONS_PR3.md · PR3_RISK_REGISTER.md · PR3_TECHNICAL_RECONCILIATION_REPORT.md · PR3_IMPLEMENTATION_READINESS_VERIFICATION.md  
**Status:** PRE-IMPLEMENTATION GATE — implementation blocked until gate checklist (Section 8) is cleared

---

## Section 1 — All Resolved Decisions

These decisions are locked. They require no further input and must not be re-opened.

| ID | Decision | Authority | Notes |
|---|---|---|---|
| R1 | Sunset time source = Maghrib prayer time | CORRECTION-E · ASSUMPTION-2 | Umm al-Qura method: Maghrib ≡ sunset. Already in `allPrayers`. No API change needed. Read: `allPrayers.firstWhere((p) => p.type == PrayerType.maghrib)` |
| R2 | Sunrise/sunset display = simple text row, NOT animated SVG arc | CORRECTION-A8 · HTML primary | `comp-prayer-card.html` shows flat text row with icons + times. The `PRAYER_CARD_SPEC.md §3` SVG arc is superseded by HTML authority. |
| R3 | BackdropFilter scope = city pill ONLY, NOT card container | CORRECTION-A | Card glass effect uses Stack + layered gradient containers (CSS `::before`/`::after` pattern). `BackdropFilter(blur: 8px)` is applied to frosted city pill only (`div.loc` in HTML). |
| R4 | Hero countdown size = 64px | CORRECTION-F · HTML primary | `comp-prayer-card.html` `div.clock` is explicitly 64px. `PR3_VISUAL_DENSITY_SIMULATION.md` recommendation of 44pt is **superseded**. |
| R5 | Card shadow values = HTML two-shadow system | CORRECTION-G | Teal shadow: `Color(0xFF0D7377)` 32% alpha, blur 42, offset (0,18). Green shadow: `Color(0xFF1A6B3C)` 18% alpha, blur 12, offset (0,4). Spec text value of `0 12 28 rgba(0,0,0,0.18)` is wrong. |
| R6 | Sunrise/sunset row placement = compact AND expanded | CORRECTION-C | Row appears in BOTH variants. Phase 4 adds it for compact. Phase 5 (expanded) must NOT re-add it — expanded only inserts the 5-prayer strip between the progress bar and the sunrise/sunset row. |
| R7 | Prayer time (`.at`) hidden in expanded mode | CORRECTION-D | HTML expanded removes `div.at` entirely. The 5-prayer strip's highlighted chip communicates the next prayer time in expanded. Conditional: `if (!_isExpanded) Text(prayerTime, ...)` |
| R8 | `fullDate`/`fullDateEn` must never be removed | ASSUMPTION-4 · CORRECTION Phase 1 | New `hijriDate`/`gregorianDate` fields are ADDITIVE. Old combined fields remain permanently alongside them. |
| R9 | iOS widget does not consume `timeLeft` string | ASSUMPTION-3 | Widget reads `WidgetKeys.remainingSeconds` (int), not the formatted string. Changing `_formatDuration` to H:MM:SS format is safe. Verified via `widget_data_service.dart`. |
| R10 | Prayer card is dark-mode-correct by design | PR3_REQUIRED_DESIGN_CORRECTIONS §8 | Card uses fixed forest→teal gradient in both system themes. All text is `Colors.white*`. PR-THEME does not affect the prayer card. No dark-mode work needed in PR3. |
| R11 | 5-prayer strip is read-only (no tap navigation) | ASSUMPTION-7 | Default recommendation accepted: strip chips are display-only. Full-card InkWell already provides PrayerDetailsPage navigation. Per-chip navigation creates conflicting tap zones. |
| R12 | Eastern Numerals refactor is OUT OF PR3 SCOPE | R-H1 | `_toArabicNumerals()` always-on deviation deferred to PR-SETTINGS. Do not add `isEasternNumeralsEnabled` in PR3. |
| R13 | Witr feature is OUT OF PR3 SCOPE | R-H2 | No `isWitrTime` field in PR3. S-33/S-34 screenshots are conditional on a Witr feature decision that has not been made. |
| R14 | `PrayerCubit` registration must remain `@injectable` | R-A4 | Do not change to `@lazySingleton`. Incorrect registration would cause prayer state to bleed across pages. |
| R15 | Progress bar RTL bug fix included in PR3 | I2 (informational) | `Directionality(textDirection: ui.TextDirection.rtl)` hardcoded → replace with locale-aware `Transform.scale(scaleX:)`. No approval needed. |
| R16 | City padding RTL bug fix included in PR3 | I1 (informational) | `EdgeInsets.only(left: AtharSpacing.xxxs)` → `EdgeInsetsDirectional.only(start: AtharSpacing.xxxs)`. No approval needed. |
| R17 | Skeleton loading state replaces CircularProgressIndicator | I3 (informational) | Additive improvement. No approval needed. |
| R18 | Full-card InkWell → PrayerDetailsPage must be preserved verbatim | PR3_REQUIRED_DESIGN_CORRECTIONS §2 row 1 | Primary navigation CTA. Not in spec. Must be ADDED to new layout structure, not replaced. All glass overlay layers must be `IgnorePointer`. |
| R19 | Dark mode wiring deferred — not in PR3 | R-H3 | PR3 does not touch `ThemeMode`, `isAutoModeEnabled`, or theme cubit wiring. |
| R20 | Dynamic active window percentages preserved | PR3_REQUIRED_DESIGN_CORRECTIONS §2 row 3 | Fajr=40%, Maghrib=20%, others dynamic. Not modified in PR3. `prayer_timer_service.dart:50–58`. |

---

## Section 2 — All Unresolved Decisions

These decisions block specific implementation phases. Each must be explicitly resolved before the phase listed in the "Blocks" column.

| ID | Decision Needed | Options | Blocks Phase | Risk if Skipped |
|---|---|---|---|---|
| U1 | **numericMono font**: JetBrainsMono (per `COMPONENT_SPECS.md §5`) vs Calibri (per Package A Decision #1) for the 64px countdown | (a) JetBrainsMono — tabular digits, must bundle TTF; (b) Calibri — brand-consistent, no new asset | Phase 4 (hero countdown) | If JetBrainsMono chosen and not bundled: silent fallback to Menlo/Courier at 64px — visually prominent regression (R-C5) |
| U2 | **Nafl badges (Duha/Qiyam)**: keep on card or remove | (a) Keep — spiritually meaningful, spec omission was accidental; (b) Remove — follows HTML/spec, cleaner card | Phase 4 (hero layout finalization) | Removing existing feature without explicit sign-off; or keeping with wrong placement breaks centered hero Column |
| U3 | **Nafl badge placement** (if kept, U2=keep): which position in new vertical layout | (A) Above hero; (B) Inline with label; (C) Below countdown above sunrise | Phase 4 | Wrong placement breaks visual hierarchy of centered hero |
| U4 | **Allahu Akbar Unicode string**: exact Arabic codepoints for `ٱللَّٰهُ أَكْبَرُ` | Must come from product owner or religious authority — cannot be inferred | Phase 7 (adhanMoment) | Incorrect diacritics = incorrect Arabic = religious error in the most sacred UI text in the app (R-G1) |
| U5 | **adhanMoment time boundary**: ±2 min centered on adhan (−2 to +2) OR only after adhan (0 to +2) | (a) −2 to +2 min; (b) 0 to +2 min | Phase 7 (adhanMoment state machine) | Fundamentally different state machine logic in `_emitStatus()`. Wrong boundary shows/hides "Allahu Akbar" at wrong time |
| U6 | **adhanMoment haptic feedback**: should the device vibrate at the adhan moment? | (a) `HapticFeedback.lightImpact()`; (b) No haptic | Phase 7 | Unexpected vibration if added without approval; missing spiritual emphasis if not added |
| U7 | **Compact/expanded toggle**: approve the feature AND specify the toggle affordance | (a) Chevron icon at bottom; (b) Tap card lower half; (c) Header area tap; (d) Dedicated expand label | Phase 6 (expanded mode) | Feature cannot be designed without knowing tap target; toggle zone will conflict with full-card InkWell if not specified (R-A3) |
| U8 | **Progress bar fill color**: confirm teal gradient (HTML) over semantic state colors | (a) HTML: `linear-gradient(90deg, #7FE3DA → #fff)` fixed; (b) Keep production: green/blue/amber state-coded | Phase 4 (progress bar) | Removing state-coded color removes semantic prayer-state signal. Needs designer "yes" before replacing it |
| U9 | **iPhone SE height acceptance**: 64px card at ~274pt = 55% of iPhone SE usable viewport | (a) Accept — users scroll; (b) Add max-height constraint; (c) Small-screen padding reduction; (d) Defer expanded until compact device-validated | Phase 4 (before shipping to production) | Dashboard fold regression on smallest supported device; HabitsStrip pushed below fold (R-F2, R-C1) |
| U10 | **HabitCubit scope**: fix existing bug (`context.read<HabitCubit>()` throws on pages without local HabitCubit) | (a) `context.maybeRead<HabitCubit>()` null-safe; (b) Ensure global HabitCubit is in scope everywhere card renders | Phase 6 (expanded mode on all pages) | Existing bug; PR3 is the fix opportunity. If not fixed: card crashes on Tasks/Habits/Projects pages when dhikr button tapped |
| U11 | **Active window 64px display**: what does the 64px element show during `justStarted` and `current` states? | (a) "الآن" at 64px for justStarted, elapsed "منذ X" at 64px for current; (b) Both show "الآن"; (c) Progress-toward-window-end countdown; (d) Blank/replaced by dhikr | Phase 4 (hero, active-window states) | Spec/HTML only define upcoming state. Without decision, active-window display is guessed |
| U12 | **H:MM:SS numerals in Arabic locale**: Latin digits (`1:14:32`) or Arabic-Indic (`١:١٤:٣٢`)? | (a) Arabic-Indic applied (current `_toArabicNumerals()` behavior); (b) Latin digits for countdown specifically | Phase 1 (format change) | If wrong: 64px countdown may display unexpected character set to Arabic users (R-B3) |
| U13 | **Dhikr CTA final form**: HTML says no persistent button; spec §2 says always-visible pill | (a) Follow HTML — no persistent CTA (move conditional `🤲` only); (b) Add text label "أذكار ما بعد الصلاة" conditional on active window; (c) Always-visible pill (requires explicit designer override of HTML) | Phase 6 (CTA) | Three sources conflict. Implementing without explicit decision will be wrong against at least two of them |

---

## Section 3 — Decisions Owned by Product Owner

The product owner must resolve these. They involve Islamic correctness, business/UX acceptance, or user-facing feature scope.

| ID | Decision | Why Product Owner | Urgency |
|---|---|---|---|
| U4 | Exact Unicode string for Allahu Akbar | Religious correctness — cannot be inferred by engineering or design. Most sacred UI text in the app. | HIGH — blocks Phase 7 |
| U5 | adhanMoment time boundary (±2 or 0→+2 min) | UX policy decision about when to interrupt the countdown display | HIGH — blocks Phase 7 |
| U6 | adhanMoment haptic feedback | User-facing behavior with spiritual implications | MEDIUM — Phase 7 |
| U9 | iPhone SE height acceptance | Business acceptance of density trade-off on smallest supported device | HIGH — blocks Phase 4 from shipping |
| U11 | Active window 64px display format | Defines what users see for 20–40 minutes daily during prayer windows | MEDIUM — Phase 4 |
| A2 (ref) | Nafl badges: keep or remove from card | Feature decision with real Islamic UX implications. HTML removed them; production has them. | HIGH — blocks Phase 4 |

---

## Section 4 — Decisions Owned by Designer

The designer must resolve these. They involve visual layout, component spec, or design authority.

| ID | Decision | Why Designer | Urgency |
|---|---|---|---|
| U1 | numericMono font: JetBrainsMono vs Calibri | Conflicts between `COMPONENT_SPECS.md` (JetBrainsMono) and `PACKAGE_A_DECISIONS.md #1` (Calibri). Designer is author of both. | HIGH — blocks Phase 4 |
| U3 | Nafl badge placement (if kept) | Layout integration into centered hero Column. Affects visual hierarchy. | HIGH — Phase 4 |
| U7 | Compact/expanded toggle affordance | Interaction design. Must not conflict with full-card InkWell. | HIGH — blocks Phase 6 |
| U8 | Progress bar fill: confirm teal gradient over semantic colors | HTML is clear; needs explicit "yes" before removing a production semantic signal | MEDIUM — Phase 4 |
| U12 | H:MM:SS numerals in Arabic locale | Typography/locale decision for the dominant visual element | MEDIUM — Phase 1 |
| U13 | Dhikr CTA final form | Spec text vs HTML contradiction. Designer is author of both. | MEDIUM — Phase 6 |
| A7 (ref) | Confirm teal gradient is intentional (same as U8) | Explicit sign-off required before removing state-coded color | MEDIUM |

---

## Section 5 — Decisions Owned by Engineering

These are technical decisions that engineering can and must resolve without external input.

| ID | Decision | Resolution Path | Phase |
|---|---|---|---|
| E1 | `WidgetKeys.prayerCardVariant` string value | Must follow `athar_` prefix convention. Finalize string before Phase 6. Add key only when expanded mode is approved. Never rename after first production build (R-B4). | Phase 6 |
| E2 | `secondsRemaining` negative value guard | Clamp: `max(0, secondsRemaining)` in `PrayerTimerService`. Guard `0:00:00` display. | Phase 1 |
| E3 | `PrayerTimerLabel` switch cascade coordination | Add `adhanMoment` + fix ALL switch expressions in ONE commit. Run `flutter analyze` before commit. Files: `next_prayer_card.dart:182, 230, 359`, `prayer_timer_service.dart`, others. | Phase 7 |
| E4 | `AnimationController` dispose | Add `controller.dispose()` in `_NextPrayerCardState.dispose()`. Use `late final` initialization. | Phase 5 |
| E5 | Sunrise null safety | Use `firstWhereOrNull`. If null: hide sunrise/sunset row entirely. No crash on polar-region edge case (R-B5). | Phase 4 |
| E6 | `buildWhen` on 1-second rebuild | Add `buildWhen` to `BlocConsumer` comparing countdown fields only. Wrap glass surface and header in `const`. Profile with Flutter DevTools after Phase 3. | Phase 3 |
| E7 | `FittedBox` on 64px countdown | Wrap in `FittedBox(fit: BoxFit.scaleDown)` to prevent overflow on iPhone SE for long hour values (R-C1). | Phase 4 |
| E8 | Nafl badge color tokens | Replace `Colors.orange` / `Colors.indigo` with `AtharColors.duha` / `AtharColors.qiyam`. Define tokens if absent (R-C4). | Phase 4 |
| E9 | `sizeDisplay64` token | Add `static const double sizeDisplay64 = 64.0` to `AtharTypography` in Phase 1. Prevents hardcoded 64.0 in widget code (R-C6). | Phase 1 |
| E10 | 5-prayer strip RTL order | Render chips from reversed list when `Directionality.of(context) == TextDirection.rtl` (R-F3). | Phase 6 |

---

## Section 6 — Decisions That Changed Previous Assumptions

These items correct errors in earlier PR3 documents. Any implementation following the old plan is incorrect.

| Change ID | What the Old Plan Said | What Is Now Correct | Invalidates |
|---|---|---|---|
| CH-1 | BackdropFilter wraps the card container | BackdropFilter is on the frosted city pill ONLY. Card uses Stack + gradient containers (no blur). | PR3_VISUAL_READINESS_REPORT.md (glass card description), earlier PR3_IMPLEMENTATION_PLAN.md Phase 2 |
| CH-2 | numericMono = Calibri (PR1 applied Calibri as "sole canonical") | UNRESOLVED CONFLICT: `COMPONENT_SPECS.md §5` says JetBrainsMono; `PACKAGE_A_DECISIONS.md #1` says Calibri. PR1 applied Calibri without resolving this conflict. Must be explicitly decided before Phase 4. | PR1 assumption that numericMono = Calibri is now a known open conflict, not a settled decision |
| CH-3 | Sunrise/sunset row is added in Phase 5 (expanded mode) | Sunrise/sunset row is added in Phase 4 (COMPACT mode). Expanded mode does NOT add it again — expanded only inserts the 5-prayer strip between the progress bar and the sunrise row. | PR3_IMPLEMENTATION_PLAN.md Phase 5 step description |
| CH-4 | Prayer time (`.at`, 12px) is visible in both compact and expanded | Prayer time is HIDDEN in expanded mode. HTML expanded removes `div.at` entirely. | PR3_IMPLEMENTATION_PLAN.md Phase 3 description |
| CH-5 | A4 (Sunset time source) is a CRITICAL blocker | A4 is RESOLVED. Sunset = Maghrib. Already in `allPrayers`. Zero architecture change needed. | PR3_APPROVAL_REQUIRED_ITEMS.md A4 (listed as Critical Blocker), PR3_BLOCKERS_AND_OPEN_ASSUMPTIONS.md ASSUMPTION-2 partially |
| CH-6 | Countdown at 44pt is the recommended size (emotional tone analysis) | 64px is confirmed by HTML authority. The 44pt recommendation was a risk analysis. HTML has already made this decision. 44pt is superseded. | PR3_VISUAL_DENSITY_SIMULATION.md recommendation section |
| CH-7 | Shadow from spec: `0 12 28 rgba(0,0,0,0.18)` | HTML-extracted shadow values are the correct values (see R5 in Section 1). Spec text shadow value is wrong. | Any implementation that uses spec text shadow values |

---

## Section 7 — Decisions That Invalidate Older PR3 Reports

Each row identifies a specific older document and the part of it that is no longer authoritative.

| Document | Invalidated Section | Reason | Superseded By |
|---|---|---|---|
| `PR3_VISUAL_DENSITY_SIMULATION.md` | Recommendation section (44pt countdown) | HTML explicitly shows 64px. HTML is authoritative per spec's own statement. The recommendation was analysis of a risk that now has a design answer. | CORRECTION-F in `PR3_REQUIRED_DESIGN_CORRECTIONS.md` |
| `PR3_VISUAL_READINESS_REPORT.md` | A4 listed as MISSING / critical gap | A4 is resolved. Sunset = Maghrib. Not missing, already available. | CORRECTION-E in `PR3_REQUIRED_DESIGN_CORRECTIONS.md` |
| `PR3_IMPLEMENTATION_PLAN.md` | Phase 2: "Add BackdropFilter to card container" | BackdropFilter must NOT be on card. Only on city pill. | CORRECTION-A in `PR3_REQUIRED_DESIGN_CORRECTIONS.md` |
| `PR3_IMPLEMENTATION_PLAN.md` | Phase 5: "Add sunrise/sunset row in expanded mode" | Sunrise/sunset is added in Phase 4 (compact). Phase 5 must not re-add it. | CORRECTION-C in `PR3_REQUIRED_DESIGN_CORRECTIONS.md` |
| `PR3_APPROVAL_REQUIRED_ITEMS.md` | A4 listed as CRITICAL — "Implementation Blocked" | A4 is no longer a blocker. Should be relabeled RESOLVED. | `PR3_REQUIRED_DESIGN_CORRECTIONS.md` CORRECTION-E |
| `PR3_APPROVAL_REQUIRED_ITEMS.md` | A8 listed as MEDIUM — arc vs text row | A8 is resolved. HTML shows simple text row. No further approval needed. | `QUESTIONS_PR3.md` (A8 resolution table) |
| `PR3_VISUAL_DENSITY_SIMULATION.md` | Comparison of 44pt vs 64pt countdown with "44pt recommended" | The document's body is valid as trade-off analysis, but the conclusion is superseded. | HTML `comp-prayer-card.html` + CORRECTION-F |
| Any document that states `BackdropFilter` applies to the whole card | Any such statement | This was an incorrect reading of the CSS glass effect. CSS `backdrop-filter` is on `.loc` (city pill), not `.card`. | `PR3_REQUIRED_DESIGN_CORRECTIONS.md` CORRECTION-A · `PR3_TECHNICAL_RECONCILIATION_REPORT.md` |

---

## Section 8 — Final PR3 Implementation Gate Checklist

All items must be checked before the first line of production code is written. Items with a phase suffix may be deferred to that phase but must be resolved before that phase begins.

### Gate 0 — Pre-Code Approvals (Resolve Before ANY Code)

- [ ] **U4** — Product owner provides exact Unicode string for Allahu Akbar from authoritative religious source
- [ ] **U5** — Product owner confirms adhanMoment time boundary (±2 min or 0→+2 min)
- [ ] **U9** — Product owner explicitly accepts iPhone SE 55% viewport OR specifies max-height approach

### Gate 1 — Phase 1 (Domain) Prerequisite

- [ ] **U12** — Designer/product owner confirms H:MM:SS countdown numeral locale (Arabic-Indic or Latin for Arabic locale)
- [ ] **E9** — `sizeDisplay64 = 64.0` token added to `AtharTypography` before Phase 3 depends on it
- [ ] **E2** — `secondsRemaining` clamped to `max(0, ...)` in `PrayerTimerService`
- [ ] Phase 1 `flutter analyze` passes with zero issues before Phase 2 begins
- [ ] ALL `PrayerTimerLabel` switch expressions handle the new `adhanMoment` value (exhaustiveness enforced by compiler — verify with `flutter analyze`)

### Gate 2 — Phase 4 (Hero Layout) Prerequisites

- [ ] **U1** — Designer confirms numericMono font: JetBrainsMono or Calibri
- [ ] If JetBrainsMono: TTF files added to `assets/fonts/` AND declared in `pubspec.yaml` before Phase 4 begins
- [ ] **U2 + U3** — Designer confirms nafl badge keep/remove AND placement option (A/B/C)
- [ ] **U8** — Designer confirms teal gradient replaces semantic state colors on progress bar
- [ ] **U11** — Product owner confirms active-window 64px display format (justStarted + current states)
- [ ] Phase 1–3 committed and `flutter analyze` passes with zero issues

### Gate 3 — Phase 6 (Expanded Mode) Prerequisites

- [ ] **U7** — Designer specifies compact/expanded toggle affordance (which tap target)
- [ ] **U7** — Product owner approves compact/expanded feature
- [ ] **E1** — `WidgetKeys.prayerCardVariant` string finalized (naming reviewed; never-rename contract acknowledged)
- [ ] **U10** — `context.maybeRead<HabitCubit>()` or equivalent null-safety applied
- [ ] Phase 4–5 committed AND device-tested on at least D1 (iPhone SE) + D2 (iPhone 14 Pro) before Phase 6 begins
- [ ] **E10** — 5-prayer strip reverses chip order in RTL

### Gate 4 — Phase 7 (adhanMoment) Prerequisites

- [ ] **U4** — Authoritative Arabic Unicode string in hand and added to `app_ar.arb` as `prayerCardAllahuAkbar`
- [ ] **U5** — Time boundary confirmed and coded in `_emitStatus()`
- [ ] **U6** — Haptic decision confirmed
- [ ] **E3** — ALL switch expressions on `PrayerTimerLabel` updated in ONE commit (not split)
- [ ] `app_en.arb` has corresponding "Pray now" key

### Gate 5 — Pre-Merge to Production (Any Phase)

- [ ] `flutter analyze` — zero issues
- [ ] Full-card InkWell → PrayerDetailsPage tap tested and confirmed working
- [ ] Dhikr button visible in `justStarted`/`current`, absent in `upcoming` (preserves `status.showDhikrButton` check)
- [ ] Progress bar fill direction correct: RTL fills right-to-left; LTR fills left-to-right
- [ ] `R-A2` verified: no `BackdropFilter` on card container — only on city pill
- [ ] `R-F4` verified: no existing `WidgetKeys` constants renamed
- [ ] `R-G2` verified: dhikr button does not appear outside active prayer window
- [ ] `R-G3` verified: sunrise exclusion filter in `prayer_cubit.dart:48` untouched
- [ ] **U13** — Dhikr CTA final form confirmed and implemented (designer decision on HTML vs spec text vs conditional label)

---

## Decision Summary

| Scope | Count |
|---|---|
| Resolved decisions (locked, no further input needed) | 20 |
| Unresolved decisions (blocking implementation) | 13 |
| Product Owner owned | 6 |
| Designer owned | 7 |
| Engineering owned (self-resolving) | 10 |
| Decisions that changed previous assumptions | 7 |
| Documents partially or fully invalidated by corrections | 8 |
| Implementation gate items | 31 |

**Current safe-to-start status:**
- Phases 1–3 are safe to start after Gate 0 + Gate 1 are cleared
- Phase 4 requires Gate 2
- Phase 6 requires Gate 3
- Phase 7 requires Gate 4
- No phase may merge to production without Gate 5
