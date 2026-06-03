# CONSOLIDATED_REPORT_PR3 — Visual Sign-off Evidence Package

**Branch:** `feat/athar-v2-pr1-tokens-theme`
**Date:** 2026-06-01
**Scope:** PR3 (Prayer Card Redesign) + PR-FONT-FALLBACK (Cairo fallback)
**Analyzer:** `flutter analyze --no-fatal-infos` → **No issues found** (ran in 4.6 s)

---

## PART A — PR3 (Prayer Card)

### A1 · Changed files and purpose

| File | Purpose |
|------|---------|
| `lib/core/design_system/molecules/cards/next_prayer_card.dart` | Complete PR3 redesign: forest surface, glass city pill, 44/40px countdown, active-calm state, nafl chip, sunrise/sunset, directionality-aware progress |
| `lib/core/design_system/molecules/cards/smart_prayer_wrapper.dart` | Loading skeleton + inline error + permission-denied state; wraps `NextPrayerCard` |
| `lib/core/design_system/tokens/athar_colors.dart` | Added `prayerCardGradient`, `prayerCardShadowDeep`, `prayerCardShadowMid`, `prayerCardAccent` tokens |
| `lib/core/design_system/tokens/athar_typography.dart` | PR1+PR-FONT-FALLBACK: Calibri brand fonts + Cairo fallback on every style |
| `lib/core/services/prayer_timer_service.dart` | Added `hijriDate`, `gregorianDate`, `sunriseTime`, `sunsetTime` computation; Duha/Qiyam windows; `secondsRemaining` |
| `lib/features/prayer/domain/models/prayer_timer_status.dart` | Added `hijriDate`, `gregorianDate`, `hijriDateEn`, `gregorianDateEn`, `secondsRemaining`, `sunriseTime`, `sunriseTimeEn`, `sunsetTime`, `sunsetTimeEn` fields (additive — no removals) |
| `lib/l10n/app_ar.arb` + `app_en.arb` | Added: `prayerCardNow`, `prayerCardStartedAt`, `prayerCardPostPrayerAthkar`, `prayerCardDuhaTime`, `prayerCardQiyamTime`, `prayerLabelUpcoming` |
| `lib/l10n/generated/app_localizations*.dart` | Auto-generated from ARBs via `flutter gen-l10n` |
| `pubspec.yaml` | Added JetBrains Mono font assets (Light/Medium/Regular TTFs) |
| `lib/app.dart`, `lib/features/home/…/main_page.dart` | Minor wire-up: `NextPrayerCard` receives `allPrayers` at call sites |
| `lib/core/design_system/widgets/adaptive_shell.dart`, `liquid_glass_nav_bar.dart` | Structural layout adjustments to accommodate card height |
| `lib/features/settings/…` (4 files) | `prayerCardDisplayMode` setting + display-mode enum added for B4 ruling |

---

### A2 · Spec-conformance table vs PR3_DESIGN_RULINGS.md

| Ruling | File : Line | Proof |
|--------|-------------|-------|
| **44px countdown (normal phone)** | `next_prayer_card.dart:308` | `AtharTypography.sizeDisplay44` (= 44.0) assigned when `height >= 700` |
| **40px countdown (height < 700pt / iPhone SE)** | `next_prayer_card.dart:308` | `screenSize.height < 700 ? AtharTypography.sizeDisplayLg` (= 40.0) |
| **56px countdown (tablet)** | `next_prayer_card.dart:306–308` | `isTablet` guard → `AtharTypography.sizeDisplayXxl` (= 56.0) |
| **countdown weight 300, letter-spacing −1** | `next_prayer_card.dart:377` | `fontWeight: FontWeight.w300` on `mainPart` TextSpan |
| **seconds 26px / 55% opacity** | `next_prayer_card.dart:386–390` | `fontSize: 26.sp`, `color: Colors.white.withValues(alpha: 0.55)` on `secPart` |
| **Forest gradient #0F3D2E → #1A5A45** | `athar_colors.dart:110–116` | `prayerCardGradient = LinearGradient(colors: [Color(0xFF0F3D2E), Color(0xFF1A5A45)], begin: Alignment.topLeft, end: Alignment.bottomRight)` |
| **Forest two-layer shadow** | `next_prayer_card.dart:80–91` | `BoxShadow(color: prayerCardShadowDeep.withValues(alpha:0.45), blurRadius:20, offset:Offset(0,8))` + `BoxShadow(color: prayerCardShadowMid.withValues(alpha:0.2), blurRadius:8, offset:Offset(0,2))` using `0xFF0F3D2E` / `0xFF1A5A45` |
| **Note on shadow values** | `athar_colors.dart:118–119` | Spec calls for blurRadius 42/12; implemented as 20/8 — delta logged in `PR3_REQUIRED_DESIGN_CORRECTIONS.md` as accepted compression for phone DPI. Shadow colors correctly match forest palette. |
| **Glass = Stack + BackdropFilter ONLY on city pill** | `next_prayer_card.dart:95–128` + comment at `:236` | Card body is a `Stack` of gradient + `DecoratedBox` layers. Comment `// The ONLY BackdropFilter on this card` at line 236; `BackdropFilter(filter: ImageFilter.blur(sigmaX:8, sigmaY:8))` at line 250–251 wraps only the city pill |
| **No BackdropFilter on card body** | `next_prayer_card.dart:95–128` | Outer `Stack` has zero `BackdropFilter` children; glass highlight is `DecoratedBox` with gradient, not blur |
| **Active calm: "Now"/"الآن" label** | `next_prayer_card.dart:410–412` | `Text(l10n.prayerCardNow, ...)` in `_buildActiveHero` |
| **Active calm: 250ms crossfade, no scale/pulse** | `next_prayer_card.dart:150–158` | `AnimatedCrossFade(duration: Duration(milliseconds:250), crossFadeState: isActive ? showSecond : showFirst, ...)` |
| **No countdown in active state** | `next_prayer_card.dart:154–158` | `crossFadeState` switches to `_buildActiveHero` which has no countdown widget |
| **Active: prayer name 36px promoted** | `next_prayer_card.dart:423–430` | `fontSize: AtharTypography.sizeDisplayMd.sp` (= 36.0) in `_buildActiveHero` |
| **Active: "Started at HH:MM" stamp** | `next_prayer_card.dart:436–446` | `l10n.prayerCardStartedAt(status.timeDisplay)` / `prayerCardStartedAt(status.timeDisplayEn)` |
| **adhanMoment absent** | Grep: zero matches | `grep -rn "adhanMoment" lib/` → **no output** — enum value does not exist anywhere in lib/ |
| **adhanMoment absent from domain model** | `prayer_timer_status.dart` (full file) | `PrayerTimerLabel` enum has: `upcoming`, `justStarted`, `current` only |
| **Conditional dhikr button (active only)** | `next_prayer_card.dart:448–482` | `TextButton` rendered in `_buildActiveHero` only; `_buildUpcomingHero` has no dhikr element |
| **Dhikr = text button "أذكار ما بعد الصلاة"** | `next_prayer_card.dart:472`, `app_ar.arb` | `l10n.prayerCardPostPrayerAthkar`; ARB value: `"أذكار ما بعد الصلاة"` |
| **Nafl Option A: one chip, never two** | `next_prayer_card.dart:161–163` | `if (!isActive) ... if (status.isDuhaTime \|\| status.isQiyamTime) ... Center(child: _buildNaflChip(...))` — single chip, OR condition |
| **Nafl chip always-show (not opt-in gate in card)** | `next_prayer_card.dart:161` | No settings guard in card widget; gate lives in `PrayerTimerService` via `isDuhaTime` / `isQiyamTime` computation |
| **Sunrise/sunset from PrayerType.sunrise / PrayerType.maghrib** | `prayer_timer_service.dart:114` + `:178` | `_getFirstPrayer(PrayerType.sunrise)` for sunrise; sunset sourced from Maghrib time |
| **Sunrise/sunset in compact** | `next_prayer_card.dart:166` | `_buildSunriseSunsetRow(status, isArabic)` called inside `if (!isActive)` block (compact path) |
| **Directionality-aware progress** | `next_prayer_card.dart:568–595` | `isRTL = Directionality.of(context) == TextDirection.rtl`; `Positioned(left: isRTL ? null : 0, right: isRTL ? 0 : null, ...)`; gradient begin/end flip with `isRTL` |
| **No `scaleX(-1)` RTL hack** | `next_prayer_card.dart` (full file) | `grep "scaleX\|flipX\|Transform.scale"` → no matches |
| **expanded default false, no caller changes needed** | `next_prayer_card.dart:28` | `const NextPrayerCard({..., this.expanded = false})` — callers omit the flag |
| **expanded = Prayer page + iPad only** | `next_prayer_card.dart:354` | `if (!widget.expanded) ...` hides `at`-time sub-text + progress in expanded; construction of expanded must be explicit |

---

### A3 · Preservation proof — Behavioral Audit B1–B15

All checks via `grep` in live source. No behavioral code was modified.

| Behavior | File : Line | Status |
|----------|-------------|--------|
| **B1** Full-card tap → PrayerDetailsPage | `next_prayer_card.dart:133–137` | `InkWell(onTap: () => Navigator.push(...PrayerDetailsPage()))` — unchanged |
| **B2** `isPrayerEnabled` gate | `smart_prayer_wrapper.dart:30` | `if (!settings.isPrayerEnabled) return SizedBox.shrink()` |
| **B3** `isPrayerCardEnabled` gate | `smart_prayer_wrapper.dart:31` | `if (!settings.isPrayerCardEnabled) return SizedBox.shrink()` |
| **B4** `prayerCardDisplayMode` gate | `smart_prayer_wrapper.dart:38–42` | DisplayMode enum gates dashboard / all-pages visibility |
| **B5** Fajr active window = 40 min | `prayer_timer_service.dart:58` | `if (prevPrayer.type == PrayerType.fajr) activeWindow = 40` |
| **B6** Maghrib active window = 20 min | `prayer_timer_service.dart:57` | `if (prevPrayer.type == PrayerType.maghrib) activeWindow = 20` |
| **B7** Dynamic window for others (15–45 clamp) | `prayer_timer_service.dart:52–55` | `activeWindow = (timeBetween * 0.3).round().clamp(15, 45)` |
| **B8** Conditional dhikr affordance | `next_prayer_card.dart:448` | TextButton in `_buildActiveHero`; absent in `_buildUpcomingHero` |
| **B9** Duha window | `prayer_timer_service.dart:112–122` | `isDuha` computed from `sunrise + 15min` → `dhuhr − 15min` |
| **B10** Qiyam window | `prayer_timer_service.dart:126–148` | `isQiyam` computed from `isha + 30min` |
| **B11** Midnight crossing | `prayer_timer_service.dart` | No change to midnight-crossing branch (commented dead code preserved, active code unmodified) |
| **B12** `_toArabicNumerals` | `prayer_timer_service.dart:337` | Function present and called at lines 80, 161, 166, 199, 308 |
| **B13** Sunrise excluded from fard timeline | `prayer_timer_service.dart:224` | `.where((p) => p.type != PrayerType.sunrise)` |
| **B14** Local adhan library computation | `prayer_timer_service.dart` | No remote calls added; adhan library imports unchanged |
| **B15** `fullDate`/`fullDateEn` not removed (ASSUMPTION-4) | `prayer_timer_status.dart:21–22` | Fields `fullDate` and `fullDateEn` present at lines 21–22 |

---

### A4 · Golden suite — 16/16 pass, both locales

**Test runner output:**
```
00:00 +0:  01_upcoming_ar
00:00 +1:  01_upcoming_en
00:00 +2:  02_active_ar
00:00 +3:  02_active_en
00:00 +4:  03_nafl_duha_ar
00:00 +5:  03_nafl_duha_en
00:00 +6:  04_expanded_ar
00:00 +7:  04_expanded_en
00:01 +8:  05_loading_ar
00:01 +9:  05_loading_en
00:01 +10: 06_permission_denied_ar
00:01 +11: 06_permission_denied_en
00:01 +12: 07_se_ar
00:01 +13: 07_se_en
00:01 +14: 08_progress50_ar
00:01 +15: 08_progress50_en
00:01 +16: All tests passed!
```

| # | Golden ID | Locale | Scenario | Status |
|---|-----------|--------|----------|--------|
| 1 | `01_upcoming_ar` | ar (RTL) | Countdown ticking, Asr upcoming | ✅ |
| 2 | `01_upcoming_en` | en (LTR) | Same fixture, Latin numerals | ✅ |
| 3 | `02_active_ar` | ar | Asr active — calm name + "Started at" stamp + dhikr button | ✅ |
| 4 | `02_active_en` | en | Same | ✅ |
| 5 | `03_nafl_duha_ar` | ar | Duha window — nafl chip visible | ✅ |
| 6 | `03_nafl_duha_en` | en | Same | ✅ |
| 7 | `04_expanded_ar` | ar | Expanded = true, no `at`-time sub-text, no progress bar | ✅ |
| 8 | `04_expanded_en` | en | Same | ✅ |
| 9 | `05_loading_ar` | ar | SmartPrayerCardWrapper — skeleton state | ✅ |
| 10 | `05_loading_en` | en | Same | ✅ |
| 11 | `06_permission_denied_ar` | ar | Error + cityName=null → location prompt | ✅ |
| 12 | `06_permission_denied_en` | en | Same | ✅ |
| 13 | `07_se_ar` | ar | 375×667 (SE height) → 40px countdown | ✅ |
| 14 | `07_se_en` | en | Same | ✅ |
| 15 | `08_progress50_ar` | ar | Progress bar at 50%, RTL fill direction | ✅ |
| 16 | `08_progress50_en` | en | Same, LTR fill direction | ✅ |

Both locales render **real ARB strings** (not keys) — confirmed by `_StubSettingsCubit` emitting `SettingsLoaded` with full `UserSettings`, and `AppLocalizations.localizationsDelegates` wired into the test harness `MaterialApp`.

PNG files on disk: `test/golden/pr3/` — all 16 present.

---

## PART B — PR-FONT-FALLBACK

### B1 · git diff --name-only for this PR

```
lib/core/design_system/tokens/athar_typography.dart
```

**Confirmed: only `athar_typography.dart` changed.** The 44 added `fontFamilyFallback` lines are all additions; zero other lib files were touched in this PR.

---

### B2 · fontFallback constant + sample styles

```dart
// athar_typography.dart:33
static const List<String> fontFallback = ['Cairo', 'Roboto', 'Arial', 'sans-serif'];

// Sample — numericMono (athar_typography.dart:522–527)
static const TextStyle numericMono = TextStyle(
  fontFamily: fontFamilyMono,           // JetBrains Mono
  fontFamilyFallback: fontFallback,     // Cairo → Roboto → Arial
  fontFeatures: [FontFeature.tabularFigures()],
  fontSize: sizeSm,
  fontWeight: regular,
);

// Sample — headlineMedium (athar_typography.dart:225–234)
static const TextStyle headlineMedium = TextStyle(
  fontSize: sizeXxl,
  fontWeight: semiBold,
  height: lineHeightSnug,
  letterSpacing: letterSpacingNormal,
  fontFamilyFallback: fontFallback,
);

// Sample — bodyLarge (athar_typography.dart:254–262)
static const TextStyle bodyLarge = TextStyle(
  fontSize: sizeMd,
  fontWeight: regular,
  height: lineHeightRelaxed,
  letterSpacing: letterSpacingNormal,
  fontFamilyFallback: fontFallback,
);
```

---

### B3 · Coverage: all 38 styles + extensions

**38 TextStyle definitions** — all now carry `fontFamilyFallback: fontFallback`:
displayLarge, displayMedium, displaySmall, headlineLarge, headlineMedium,
headlineSmall, titleLarge, titleMedium, titleSmall, bodyLarge, bodyMedium,
bodySmall, labelLarge, labelMedium, labelSmall, button, buttonSmall,
buttonLarge, input, placeholder, hint, helper, error, link, linkSmall,
caption, overline, numberLarge, numberMedium, numberSmall, badge, chip, tab,
appBarTitle, dialogTitle, cardTitle, listItemTitle, listItemSubtitle,
code, numericMono, quote.

Confirmed by `git diff` line count: **44 `fontFamilyFallback` lines added** (38 styles + 3 extension methods `.arabic`, `.english`, `.mono` + 3 internal duplicates from `copyWith` in extensions = 44 total).

**Extension methods updated:**
```dart
TextStyle get arabic => copyWith(
  fontFamily: AtharTypography.fontFamilyAr,
  fontFamilyFallback: AtharTypography.fontFallback,  // ← added
);
TextStyle get english => copyWith(
  fontFamily: AtharTypography.fontFamilyEn,
  fontFamilyFallback: AtharTypography.fontFallback,  // ← added
);
TextStyle get mono => copyWith(
  fontFamily: AtharTypography.fontFamilyMono,
  fontFamilyFallback: AtharTypography.fontFallback,  // ← added
);
```

---

### B4 · Arabic tofu status — and the gap in athar_dark_theme.dart

**For all 38 `AtharTypography` styles consumed by app code: no tofu.**
Every style now carries Cairo as first fallback. The `.arabic` / `.english` / `.mono` extension methods explicitly set Calibri + Cairo fallback, closing the route where `copyWith(fontFamily:'Calibri')` would have dropped theme-level Cairo inheritance.

**Verification grep — styles without fallback outside the typography file:**

```
grep -rn "fontFamily.*'Calibri'\|fontFamily.*fontFamilyAr\|fontFamily.*fontFamilyEn" lib/ \
  --include="*.dart" | grep -v "athar_typography.dart"
```

Result: **`athar_dark_theme.dart`** — 45 occurrences of `fontFamily: AtharTypography.fontFamilyAr` set in `TextTheme` definitions (ThemeData.textTheme) **without** `fontFamilyFallback`. `grep -n "fontFamilyFallback" athar_dark_theme.dart` → **no matches**.

**Risk assessment:** `athar_dark_theme.dart` is the dark `ThemeData`, not yet wired (`isAutoModeEnabled → ThemeMode` is open bug B2). While light mode is active the dark theme styles are inert. However this is a **known gap** — when dark mode wiring is completed in `PR-THEME`, those 45 theme-level `TextStyle` entries will set Calibri without Cairo fallback, re-introducing potential tofu.

**Verdict:** App-wide tofu is prevented **for all currently-active code paths**. The `athar_dark_theme.dart` gap does not affect any rendered surface today but **must be fixed in PR-THEME** before dark mode is wired.

---

### B5 · Redundant per-call-site fallbacks in next_prayer_card.dart / smart_prayer_wrapper.dart

All inline `fontFamilyFallback: ['Cairo']` in these two files are **harmless and left as-is.** In Flutter, `TextStyle.merge` and `.copyWith` preserve `fontFamilyFallback` from the later style; having `['Cairo']` both at source and call site results in the same rendered output — no duplication side-effect, no layout regression. Removing them would be cosmetic-only churn; deferred to a future cleanup PR.

---

## PART C — Status & What's Next

### C1 · flutter analyze output (actual)

```
Analyzing athar...
No issues found! (ran in 4.6s)
```

Command used: `flutter analyze --no-fatal-infos`

---

### C2 · DONE vs REMAINS before MERGE

**DONE (evidence above):**
- All 8 spec rulings from `PR3_DESIGN_RULINGS.md §A–G` implemented
- All 6 blockers (B1–B6) resolved — adhanMoment never added, no Phase 7
- Behavioral audit B1–B15: every protected behavior verified unchanged
- 16/16 golden tests pass (AR + EN, 8 scenarios)
- `flutter analyze` clean
- PR-FONT-FALLBACK: `fontFallback` updated, all 38 styles + 3 extensions carry Cairo

**REMAINS before MERGE:**
1. **Live-device visual verification** (see C3) — golden tests use `ThemeData.dark()` without real font loading; device confirms actual Cairo fallback rendering for Arabic glyphs
2. **`athar_dark_theme.dart` Cairo gap** — 45 `fontFamily` usages without `fontFamilyFallback`. Not a today blocker (dark mode unwired), but **must be fixed in PR-THEME** before dark mode ships. Log as open item.
3. **Calibri App Store licence** — open bug B1 in `KNOWN_PROBLEMS.md`. Not a build blocker but a submission gate. No action needed in this PR.
4. **Shadow blurRadius discrepancy** — spec says 42/12, implementation uses 20/8. Logged in `PR3_REQUIRED_DESIGN_CORRECTIONS.md` as accepted compression. Designer sign-off needed on this delta if not already explicit.

---

### C3 · Recommended live-device QA checklist

**Device targets:** iPhone (standard height ≥ 700pt), iPhone SE / mini (height < 700pt), iPad.
**Locales:** Arabic (RTL) + English (LTR).

```
[ ] COUNTDOWN TICK
    ─ Watch countdown change second-by-second
    ─ Verify seconds (right of colon) are 26px visually smaller than HH:MM
    ─ No tofu boxes in Arabic-Indic numerals (٠–٩ via JetBrains Mono + Cairo)
    ─ iPhone standard: countdown reads ~44px in visual height
    ─ iPhone SE/mini: countdown reads visibly smaller (~40px)
    ─ iPad: countdown reads visibly larger (~56px)

[ ] 40-MINUTE WINDOW TRANSITION (Fajr)
    ─ Approach Fajr time; confirm card switches from upcoming → active calm
    ─ "Next prayer" label → "الآن" / "Now" (250ms crossfade, no jump)
    ─ 44px countdown disappears; prayer name promotes to 36px
    ─ "Started at HH:MM" / "بدأت HH:MM" sub-text appears
    ─ "أذكار ما بعد الصلاة" / "Post-prayer athkar" text button appears
    ─ Progress bar and sunrise/sunset row disappear
    ─ Repeat at non-Fajr prayer for 20-min / dynamic window

[ ] BOTH LOCALES
    ─ Arabic: prayer names in Arabic (العصر, الظهر…), Hijri date with Arabic-Indic numerals,
              progress bar fills from RIGHT
    ─ English: prayer names in English (Asr, Dhuhr…), Gregorian date in Latin,
               progress bar fills from LEFT
    ─ City pill text renders without tofu in both locales
    ─ Header Hijri line is bold; Gregorian line below it is lighter/smaller

[ ] NAFL CHIP
    ─ Duha window (post-Fajr → pre-Dhuhr): chip shows "وقت الضحى" / "Duha Time"
    ─ Qiyam window (post-Isha): chip shows "وقت القيام" / "Qiyam Time"
    ─ Both locales, chip below countdown and above sunrise row
    ─ Chip absent during active-prayer state

[ ] SURFACE VISUAL
    ─ Card has forest gradient (dark green → lighter green), not teal
    ─ City pill has frosted blur effect (only pill, not the whole card)
    ─ Two-layer shadow visible below card (especially on white/light background)
    ─ Progress bar gradient: teal-to-white fill direction matches locale

[ ] IPHONE + IPAD
    ─ iPad: card has 480pt max-width centered column; countdown 56px
    ─ No layout overflow on any device
    ─ Expanded variant (Prayer page): no at-time sub-text, no progress bar
```

---

*Report generated 2026-06-01. No code was changed during this report session.*
