# PR3 Risk Register

**Date:** 2026-05-13  
**Type:** Pre-implementation risk identification — no code modified  
**Format:** Risk ID · Category · Severity · Likelihood · Description · Mitigation

---

## Severity Scale

| Level | Definition |
|---|---|
| CRITICAL | Causes broken builds, crashes, or silent data loss |
| HIGH | Causes visible regression, wrong behavior, or device-breaking change |
| MEDIUM | Degrades UX, performance, or correctness in edge cases |
| LOW | Cosmetic, limited scope, or well-contained |

## Likelihood Scale

| Level | Definition |
|---|---|
| CERTAIN | Will happen unless explicitly prevented |
| LIKELY | Will probably happen; requires attention |
| POSSIBLE | May happen under specific conditions |
| UNLIKELY | Known risk but low probability |

---

## Category A — Architectural Risks

### R-A1 · Switch expression exhaustiveness cascade

| Field | Detail |
|---|---|
| **Severity** | CRITICAL |
| **Likelihood** | CERTAIN |
| **Description** | Adding `PrayerTimerLabel.adhanMoment` to the enum will break ALL switch expressions on this type at compile time (no default/fallback case). There are 4+ switch expressions across the codebase. |
| **Mitigation** | Add the enum value and fix ALL switch expressions in the same commit. Never ship a partial switch fix. Use `flutter analyze` before committing. |
| **Files affected** | `next_prayer_card.dart:182`, `next_prayer_card.dart:230`, `next_prayer_card.dart:359`, `prayer_timer_service.dart`, possibly others. |

---

### R-A2 · BackdropFilter on card (vs city pill only)

| Field | Detail |
|---|---|
| **Severity** | HIGH |
| **Likelihood** | LIKELY |
| **Description** | Previous planning docs said BackdropFilter on the card container. HTML shows BackdropFilter ONLY on the city pill. If BackdropFilter is added to the card: (a) severe performance degradation on lower-end devices, (b) blurs content behind card not intended to blur, (c) does not match the HTML design. |
| **Mitigation** | CORRECTION-A in `PR3_REQUIRED_DESIGN_CORRECTIONS.md` is explicit: NO BackdropFilter on card. Use Stack + gradient containers only. |

---

### R-A3 · Full-card InkWell removed or overridden

| Field | Detail |
|---|---|
| **Severity** | CRITICAL |
| **Likelihood** | POSSIBLE |
| **Description** | The primary navigation CTA (full-card tap → PrayerDetailsPage) is implemented as the outermost `InkWell` wrapper. Restructuring the card surface (adding Stack, gradient layers, BackdropFilter) could swallow tap events if layers are not `IgnorePointer`. |
| **Mitigation** | All glass overlay layers (`IgnorePointer` gradient containers) must NOT intercept taps. Test tap navigation after every structural change to card surface. |
| **Code location** | `next_prayer_card.dart:110–114` |

---

### R-A4 · PrayerCubit `@injectable` vs `@lazySingleton`

| Field | Detail |
|---|---|
| **Severity** | HIGH |
| **Likelihood** | UNLIKELY |
| **Description** | `PrayerCubit` is `@injectable`. If a PR3 developer accidentally changes it to `@lazySingleton` (to match `PrayerTimerService` pattern), prayer state will bleed across pages and widget push will fire from the wrong context. |
| **Mitigation** | Do not change `PrayerCubit` registration. It is correctly `@injectable`. Document this explicitly in PR3 code review checklist. |

---

## Category B — State and Data Risks

### R-B1 · `fullDate` removal — silent data loss

| Field | Detail |
|---|---|
| **Severity** | HIGH |
| **Likelihood** | POSSIBLE |
| **Description** | If a developer assumes `fullDate`/`fullDateEn` are replaced by `hijriDate`/`gregorianDate` and removes them, any consumer of the old combined string will show empty or throw. |
| **Mitigation** | Migration matrix rule: NEVER remove `fullDate`/`fullDateEn`. New fields are ADDITIVE ONLY. Verify at code review. |

---

### R-B2 · `secondsRemaining` off-by-one at state transition boundaries

| Field | Detail |
|---|---|
| **Severity** | MEDIUM |
| **Likelihood** | POSSIBLE |
| **Description** | The `secondsRemaining` field is computed from the 1s timer tick. At exact state transitions (e.g., `upcoming` → `justStarted` at 0 seconds), the int value could be 0 or negative. The widget's H:MM:SS display must guard against negative values. |
| **Mitigation** | Clamp `secondsRemaining = max(0, secondsRemaining)` in the service. Handle `secondsRemaining == 0` gracefully in the widget (display "0:00:00" not crash). |

---

### R-B3 · Eastern numerals always applied to H:MM:SS countdown

| Field | Detail |
|---|---|
| **Severity** | MEDIUM |
| **Likelihood** | CERTAIN |
| **Description** | After changing `_formatDuration` to H:MM:SS colon format, `_toArabicNumerals()` will convert colons and digits to Arabic-Indic: `"١:١٤:٣٢"`. This is potentially correct behavior (Arabic locale shows Arabic-Indic), but the colon `:` character is preserved (it is not a digit). The visual may be unexpected. |
| **Mitigation** | Confirm with designer: should the H:MM:SS display use Arabic-Indic digits (`١:١٤:٣٢`) or Latin digits (`1:14:32`) in Arabic locale? If Latin is correct for the countdown specifically, `_formatDuration` output must bypass `_toArabicNumerals`. |

---

### R-B4 · Widget key string locked before feature shipped

| Field | Detail |
|---|---|
| **Severity** | CRITICAL |
| **Likelihood** | POSSIBLE |
| **Description** | The new `WidgetKeys.prayerCardVariant = 'athar_prayer_card_variant'` string will be written to iOS UserDefaults on first build that includes it. Once user devices receive this build, the string can NEVER be renamed. If the name is wrong or conflicts, migration is impossible without a reset. |
| **Mitigation** | Verify the key string follows the `athar_` prefix convention. Confirm naming before first production build. Do not add this key until the expanded mode feature is approved and the string is finalized. |

---

### R-B5 · Sunrise/sunset null crash

| Field | Detail |
|---|---|
| **Severity** | HIGH |
| **Likelihood** | POSSIBLE |
| **Description** | Reading `widget.allPrayers.firstWhere((p) => p.type == PrayerType.sunrise)` will throw `StateError: No element` if sunrise is absent (possible in locations near the poles, or in edge-case data). |
| **Mitigation** | Use `firstWhereOrNull` extension or a try/catch. If null: hide sunrise/sunset row entirely. |

---

## Category C — UI and Visual Risks

### R-C1 · 64px countdown overflows on iPhone SE

| Field | Detail |
|---|---|
| **Severity** | MEDIUM |
| **Likelihood** | POSSIBLE |
| **Description** | At 64px font size, a countdown like "12:34:56" at H:MM:SS is ~7 characters. On iPhone SE 3 (375pt wide), with card horizontal padding, the text could overflow or get clipped on very long hour values. |
| **Mitigation** | Wrap countdown in `FittedBox(fit: BoxFit.scaleDown)` or set `overflow: TextOverflow.ellipsis`. Test on D1 (SE) simulator before final. |

---

### R-C2 · RTL progress bar fill direction

| Field | Detail |
|---|---|
| **Severity** | HIGH |
| **Likelihood** | CERTAIN (current code is buggy) |
| **Description** | Current code uses `Directionality(textDirection: ui.TextDirection.rtl)` hardcoded. This means: in English (LTR) locale, progress bar fills RIGHT-TO-LEFT (wrong). This is a known bug. |
| **Mitigation** | Replace with locale-aware: `Transform.scale(scaleX: Directionality.of(context) == TextDirection.ltr ? 1 : -1)`. Test S-41 and S-42 screenshots after fix. |
| **Code location** | `next_prayer_card.dart:386` |

---

### R-C3 · City padding RTL regression

| Field | Detail |
|---|---|
| **Severity** | MEDIUM |
| **Likelihood** | CERTAIN (current code is buggy) |
| **Description** | `EdgeInsets.only(left: AtharSpacing.xxxs)` adds padding only on the left side regardless of text direction. In RTL, the padding is on the wrong side. |
| **Mitigation** | Change to `EdgeInsetsDirectional.only(start: AtharSpacing.xxxs)`. |
| **Code location** | `next_prayer_card.dart:316` |

---

### R-C4 · Nafl badge hardcoded colors not tokenized

| Field | Detail |
|---|---|
| **Severity** | LOW |
| **Likelihood** | CERTAIN |
| **Description** | Duha badge uses `Colors.orange` and Qiyam badge uses `Colors.indigo`. These are not design tokens and will not respond to theme changes. |
| **Mitigation** | Replace with `AtharColors.duha` (define if not exists) and `AtharColors.qiyam`. Add tokens in PR3 if approved. |

---

### R-C5 · `numericMono` at 64px without correct font

| Field | Detail |
|---|---|
| **Severity** | MEDIUM |
| **Likelihood** | CERTAIN (if Q1 is not resolved before Phase 3) |
| **Description** | `AtharTypography.numericMono` references `fontFamily: 'JetBrains Mono'`. If JetBrainsMono is not bundled in `pubspec.yaml`, Flutter silently falls back to system monospace (Menlo on iOS, Courier fallback). At 64px this is visually prominent and will look wrong. |
| **Mitigation** | Resolve Q1 before Phase 3. If Calibri: update `numericMono` fontFamily to Calibri. If JetBrainsMono: add TTFs to assets + pubspec. Do not ship Phase 3 without this resolved. |

---

### R-C6 · `sizeDisplay64` token missing

| Field | Detail |
|---|---|
| **Severity** | LOW |
| **Likelihood** | CERTAIN |
| **Description** | No 64px size token in `AtharTypography`. Developer may use hardcoded `64.0` or wrong token (`sizeDisplayXxl = 56.0`). |
| **Mitigation** | Add `static const double sizeDisplay64 = 64.0` to `AtharTypography` in Phase 1 before Phase 3 hero implementation. |

---

## Category D — Animation Risks

### R-D1 · AnimationController not disposed → memory leak

| Field | Detail |
|---|---|
| **Severity** | HIGH |
| **Likelihood** | LIKELY (pattern risk) |
| **Description** | Adding `SingleTickerProviderStateMixin` + `AnimationController` to `_NextPrayerCardState` requires explicit `controller.dispose()` in `dispose()`. If missed, memory leak and "disposed widget" Flutter error on navigation. |
| **Mitigation** | Add `controller.dispose()` in `_NextPrayerCardState.dispose()`. Use Dart's `late final` for controller initialization. Run extended session in profile mode to confirm no leaks. |

---

### R-D2 · Pulse animation in Arabic vs English

| Field | Detail |
|---|---|
| **Severity** | LOW |
| **Likelihood** | POSSIBLE |
| **Description** | The pulse animation (opacity oscillation when countdown < 60s) applies to the countdown text. If the countdown text is in Arabic-Indic numerals, the animation applies correctly. No locale-specific issue — opacity is locale-agnostic. |
| **Mitigation** | No action needed. Low risk confirmed. |

---

## Category E — Performance Risks

### R-E1 · `build()` called every second

| Field | Detail |
|---|---|
| **Severity** | MEDIUM |
| **Likelihood** | CERTAIN |
| **Description** | `PrayerTimerService` emits a new `PrayerTimerStatus` every second. `NextPrayerCard` is a `BlocConsumer` that rebuilds on each emission. A rebuild-heavy card (multiple layers, gradient, animation, RichText) will trigger per-second full rebuilds. |
| **Mitigation** | Use `buildWhen` in `BlocConsumer` to compare relevant fields. Only rebuild the countdown `RichText` on second change; wrap glass surface and header in `const` widgets where possible. Profile with Flutter DevTools after Phase 3. |

---

### R-E2 · ShaderMask on progress bar — GPU cost

| Field | Detail |
|---|---|
| **Severity** | LOW |
| **Likelihood** | UNLIKELY |
| **Description** | `ShaderMask` for teal→white gradient on the progress fill triggers GPU shader compilation on first render. On lower-end Android devices this may cause a single-frame jank. |
| **Mitigation** | Use `CachedShader` approach or pre-warm shader via `DartPerformance.prewarm`. Acceptable for one-time render; monitor with DevTools shader graph on Android mid-range device. |

---

## Category F — Regression Risks

### R-F1 · Dhikr button disappears in new layout

| Field | Detail |
|---|---|
| **Severity** | HIGH |
| **Likelihood** | POSSIBLE |
| **Description** | The dhikr button is currently inside `_buildProgressRow`. When the layout is rebuilt (hero Column + new structure), the dhikr button could be lost if `_buildProgressRow` is refactored away. |
| **Mitigation** | Explicitly preserve the dhikr button logic in the new layout. It must remain conditional on `status.showDhikrButton`. Position change is acceptable; disappearance is not. Test S-21–S-24 after Phase 4. |

---

### R-F2 · Dashboard scroll fold regression

| Field | Detail |
|---|---|
| **Severity** | HIGH |
| **Likelihood** | LIKELY |
| **Description** | PR3 card height increases from ~140pt to ~274pt. On iPhone SE (496pt usable), this leaves only 222pt for HabitsStrip + StatisticsCard + task list. HabitsStrip may be partially below the fold after scroll reset. |
| **Mitigation** | Take S-65 and S-66 screenshots (dashboard fold check) on D1 and D2 before and after. The card must scroll naturally — do not add max-height constraints unless designer explicitly requests them. |

---

### R-F3 · 5-prayer strip RTL order

| Field | Detail |
|---|---|
| **Severity** | MEDIUM |
| **Likelihood** | LIKELY |
| **Description** | In the expanded 5-prayer strip, prayer order must reverse in RTL. In LTR: [Fajr | Dhuhr | Asr | Maghrib | Isha]. In RTL: [Isha | Maghrib | Asr | Dhuhr | Fajr]. Failing to reverse gives an illogical time order for Arabic users. |
| **Mitigation** | Render chips from a reversed list when `Directionality.of(context) == TextDirection.rtl`. Test S-52 (expanded RTL). |

---

### R-F4 · iOS widget break from `WidgetKeys` rename

| Field | Detail |
|---|---|
| **Severity** | CRITICAL |
| **Likelihood** | UNLIKELY (but catastrophic if it happens) |
| **Description** | Any rename of existing `WidgetKeys` constants breaks all installed iOS widgets on user devices (they read from UserDefaults by the old string key and get null). |
| **Mitigation** | Never rename existing constants. New constants only. CLAUDE.md non-negotiable rule. Code review gate. |

---

## Category G — Spiritual UX Risks

### R-G1 · `adhanMoment` Arabic text wrong codepoints

| Field | Detail |
|---|---|
| **Severity** | CRITICAL |
| **Likelihood** | POSSIBLE (if inferred rather than specified) |
| **Description** | The Arabic text `ٱللَّٰهُ أَكْبَرُ` requires specific Unicode diacritics (tashkeel, madda, superscript alef). Using wrong codepoints renders incorrect Arabic for the most sacred text in the app. This is a religious correctness issue, not merely a display issue. |
| **Mitigation** | Text must come from product owner or religious authority. Do NOT infer from training data. Do NOT accept "close enough." Blocked on Q3 explicitly. |

---

### R-G2 · Dhikr button outside active window

| Field | Detail |
|---|---|
| **Severity** | HIGH |
| **Likelihood** | POSSIBLE |
| **Description** | If `status.showDhikrButton` logic is broken during refactor, the Dhikr button could show outside the active prayer window. Showing post-prayer athkar prompts when a prayer hasn't occurred is spiritually incorrect. |
| **Mitigation** | Preserve the `showDhikrButton` check verbatim. Test S-21 (visible) and S-24 (absent). Never simplify to `true`. |

---

### R-G3 · Sunrise exclusion from prayer timeline

| Field | Detail |
|---|---|
| **Severity** | MEDIUM |
| **Likelihood** | POSSIBLE |
| **Description** | `prayer_cubit.dart:48` explicitly excludes sunrise from `prayersForProgress`. If a developer adds sunrise to `allPrayers` processing without this guard, the progress bar will incorrectly show sunrise as a "prayer" period. |
| **Mitigation** | Do not touch `prayersForProgress` filter in PR3. Sunrise/sunset row reads directly from `allPrayers` — no service change needed. |

---

## Category H — Scope Creep Risks

### R-H1 · Eastern Numerals refactor during PR3

| Field | Detail |
|---|---|
| **Severity** | MEDIUM |
| **Likelihood** | POSSIBLE |
| **Description** | `_toArabicNumerals()` always-on is a known deviation from Package A Decision #7. A developer might attempt to fix this in PR3 by adding `isEasternNumeralsEnabled` check. This is OUT OF PR3 SCOPE. |
| **Mitigation** | Defer Eastern Numerals opt-in to PR-SETTINGS. Do not add `isEasternNumeralsEnabled` to `UserSettings` in PR3. |

---

### R-H2 · Witr feature added in PR3

| Field | Detail |
|---|---|
| **Severity** | MEDIUM |
| **Likelihood** | UNLIKELY |
| **Description** | S-33/S-34 in the screenshot matrix mention Witr. There is no `isWitrTime` field in `PrayerTimerStatus`. Adding Witr in PR3 without an explicit feature decision is scope creep. |
| **Mitigation** | Witr is gated on explicit product owner approval. Do NOT add `isWitrTime` in PR3. S-33/S-34 are conditional on a Witr decision that has NOT been made. |

---

### R-H3 · Dark mode wiring in PR3

| Field | Detail |
|---|---|
| **Severity** | LOW |
| **Likelihood** | UNLIKELY |
| **Description** | The prayer card uses fixed dark gradient — dark mode is "already correct" by design. However, the `ThemeMode` wiring (B2 in KNOWN_PROBLEMS) is deferred to PR-THEME. Do not wire `ThemeMode` in PR3. |
| **Mitigation** | PR3 does not touch `ThemeMode`, `isAutoModeEnabled`, or theme cubit wiring. |

---

## Risk Summary Table

| Risk ID | Category | Severity | Likelihood | Status |
|---|---|---|---|---|
| R-A1 | Architecture | CRITICAL | CERTAIN | Mitigated by migration strategy |
| R-A2 | Architecture | HIGH | LIKELY | Mitigated by CORRECTION-A |
| R-A3 | Architecture | CRITICAL | POSSIBLE | Requires explicit IgnorePointer |
| R-A4 | Architecture | HIGH | UNLIKELY | Document in code review |
| R-B1 | State/Data | HIGH | POSSIBLE | Never remove fullDate |
| R-B2 | State/Data | MEDIUM | POSSIBLE | Clamp secondsRemaining |
| R-B3 | State/Data | MEDIUM | CERTAIN | Designer confirmation needed |
| R-B4 | State/Data | CRITICAL | POSSIBLE | Finalize key string pre-prod |
| R-B5 | State/Data | HIGH | POSSIBLE | Use firstWhereOrNull |
| R-C1 | UI/Visual | MEDIUM | POSSIBLE | FittedBox on countdown |
| R-C2 | UI/Visual | HIGH | CERTAIN | Fix RTL bug in Phase 4 |
| R-C3 | UI/Visual | MEDIUM | CERTAIN | Fix city padding in Phase 3 |
| R-C4 | UI/Visual | LOW | CERTAIN | Tokenize badge colors |
| R-C5 | UI/Visual | MEDIUM | CERTAIN | Resolve Q1 before Phase 3 |
| R-C6 | UI/Visual | LOW | CERTAIN | Add sizeDisplay64 in Phase 1 |
| R-D1 | Animation | HIGH | LIKELY | Dispose in dispose() |
| R-D2 | Animation | LOW | POSSIBLE | No action needed |
| R-E1 | Performance | MEDIUM | CERTAIN | buildWhen + const widgets |
| R-E2 | Performance | LOW | UNLIKELY | Profile post-Phase 3 |
| R-F1 | Regression | HIGH | POSSIBLE | Preserve dhikr button |
| R-F2 | Regression | HIGH | LIKELY | Screenshot fold check |
| R-F3 | Regression | MEDIUM | LIKELY | Reverse strip in RTL |
| R-F4 | Regression | CRITICAL | UNLIKELY | Never rename WidgetKeys |
| R-G1 | Spiritual UX | CRITICAL | POSSIBLE | Product owner required |
| R-G2 | Spiritual UX | HIGH | POSSIBLE | Preserve showDhikrButton check |
| R-G3 | Spiritual UX | MEDIUM | POSSIBLE | Do not touch prayersForProgress |
| R-H1 | Scope Creep | MEDIUM | POSSIBLE | Defer to PR-SETTINGS |
| R-H2 | Scope Creep | MEDIUM | UNLIKELY | Gate on Witr decision |
| R-H3 | Scope Creep | LOW | UNLIKELY | Defer to PR-THEME |

---

## Highest-Risk Subsystems for PR3

1. **`PrayerTimerLabel` switch cascade (R-A1)** — CERTAIN to cause compile breaks; requires coordinated commit
2. **Sacred text Unicode (R-G1)** — Religious correctness; must not be approximated
3. **WidgetKeys lock-in (R-B4, R-F4)** — Permanent key string; once deployed cannot be renamed
4. **Full-card InkWell preservation (R-A3)** — Primary navigation CTA must survive card rebuild
5. **JetBrainsMono at 64px (R-C5)** — Visually prominent regression if font not bundled
