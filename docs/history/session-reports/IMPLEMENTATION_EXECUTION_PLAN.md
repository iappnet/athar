# Implementation Execution Plan
**Date:** 2026-05-07  
**Source:** handoff_v2/FINAL_PACKAGE_MANIFEST.md + CLAUDE_CODE_PROMPT.md  
**Status:** Pre-implementation. No Dart files modified.

---

## Phase Map

```
PR1 (Tokens & Theme)      ← START HERE
  └─ PR-THEME (ThemeMode.system wiring)
       └─ PR2 (AdaptiveShell)
            └─ PR3 (Prayer card refresh)
                 └─ PR-ADHAN (Bundle adhan audio)
                      └─ PR4a (Calendar visual refresh)
                           └─ PR4b (Calendar dual-display rebuild)
                                └─ PR5 (Settings Accessibility)
                                     └─ PR6 (Stats redesign)
                                          └─ PR7 (Athkar feature)
                                               └─ PR8 (Focus oil-fill)
                                                    └─ PR9 (iOS widgets)
                                                         └─ PR-ONBOARD-AB (Onboarding variants)
                                                              └─ PR-CLEANUP (Color sweep)
```

All PRs after PR1 depend on PR1 being merged first (token values must be correct). Within that constraint, several PRs are independent and could run in parallel (PR-ADHAN, PR5, PR6 do not depend on each other).

---

## PR1 — Tokens & Theme (CURRENT TARGET)

**Scope:** Update token values in 2 Dart files + pubspec font registration + copy TTF assets. No structural changes.

**Safety rating:** 🟡 MEDIUM — color values change everywhere; font change is visually global

**Files:**
1. `lib/core/design_system/tokens/athar_colors.dart` — update `.light` and `.dark` color values
2. `lib/core/design_system/tokens/athar_typography.dart` — update `fontFamilyAr`, `fontFamilyEn`, add `numericMono`
3. `pubspec.yaml` — add Calibri font entries
4. `assets/fonts/calibri-light.ttf` (NEW — copy from handoff_v2)
5. `assets/fonts/calibri-regular.ttf` (NEW — copy from handoff_v2)
6. `assets/fonts/calibri-bold.ttf` (NEW — copy from handoff_v2)

**Files confirmed NO change needed in PR1:**
- `athar_spacing.dart` — values already match CSS spec exactly
- `athar_radii.dart` — values already match CSS spec exactly
- `athar_shadows.dart` — approximately matches, no PR1 action
- `athar_animations.dart` — fast/base/slow durations already match CSS spec
- `themes/app_colors.dart` — flat utility class, already has green primary; PR1 does not touch
- `themes/typography.dart` — empty stub, leave as-is
- `themes/athar_light_theme.dart` / `athar_dark_theme.dart` — reference `AtharColors.light/.dark` by field; will automatically reflect value updates
- All feature files

**Validation:** `flutter analyze --no-pub` (zero errors) + `flutter pub get` + screenshot of primary button, nav bar active tab, form field focus ring, dark/light mode

**Approval gate:** Designer reviews before/after screenshots of: button, nav bar, prayer card (should be unchanged), form field, dark mode primary surface

**Rollback:** Revert `athar_colors.dart` and `athar_typography.dart` to pre-PR1 values; remove Calibri entries from pubspec; delete Calibri TTF files

---

## PR-THEME — ThemeMode.system Wiring

**Scope:** 3-line change in `lib/app.dart:162–172`. One ARB key added to both `.arb` files. Settings UI change to visually disable manual dark toggle when auto is on.

**Safety rating:** 🟢 LOW — isolated, easily reversible

**Dependencies:** PR1 must be merged (color tokens must be correct first)

**Files:**
1. `lib/app.dart` — 3-line logic change
2. `lib/l10n/app_en.arb` — add `"settingsFollowingSystem": "Following system"`
3. `lib/l10n/app_ar.arb` — add Arabic equivalent
4. `lib/features/settings/presentation/pages/general_settings_page.dart` — visually disable manual dark toggle when `isAutoModeEnabled`
5. Run `flutter gen-l10n`

**Rollback:** Revert `app.dart` 3 lines; remove ARB keys; remove UI disable logic

---

## PR2 — AdaptiveShell

**Scope:** Rename `lib/core/layouts/adaptive_scaffold.dart` → `lib/core/design_system/widgets/adaptive_shell.dart`. Update all imports. Implement breakpoints per `IPAD_OPTIMIZATION.md`.

**Safety rating:** 🟡 MEDIUM — import rename touches many files; breakpoint logic is new

**Dependencies:** PR1 must be merged

**Files:**
- New: `lib/core/design_system/widgets/adaptive_shell.dart`
- Delete: `lib/core/layouts/adaptive_scaffold.dart`
- Update: all files that import `adaptive_scaffold.dart` (check via grep)

**Rollback:** Revert rename; restore old import paths

---

## PR3 — Prayer Card Refresh

**Scope:** Rebuild per `PRAYER_CARD_SPEC.md`. Compact/expanded variants as local widget state. Phase 8.1 hierarchy must not regress.

**Safety rating:** 🔴 HIGH — touches 3 prayer hierarchy enforcement points; any regression breaks prayer notification scheduling and card visibility

**Dependencies:** PR1, PR2

**Critical constraint:** Do NOT regress:
- `smart_prayer_wrapper.dart:30` (`isPrayerEnabled` guard)
- `smart_prayer_wrapper.dart:33` (`isPrayerCardEnabled` guard)
- `prayer_notification_scheduler.dart:35,209,271` (notification guards)
- `prayer_conflict_service.dart:16` (conflict guard)

**Files:**
- `lib/core/design_system/molecules/cards/next_prayer_card.dart`
- `lib/core/design_system/molecules/cards/smart_prayer_wrapper.dart`

**Approval gate:** Designer visual review + QA test prayer toggle hierarchy (turn isPrayerEnabled OFF, confirm card AND notifications disappear)

---

## PR-ADHAN — Bundle Adhan Audio

**Scope:** Copy `adhan.mp3` to Android raw resources. Convert to `adhan.caf` and add to iOS target. Verify notification channel resolves file.

**Safety rating:** 🟡 MEDIUM — iOS Copy Bundle Resources phase must be correctly updated in Xcode; incorrect placement is a silent failure

**Dependencies:** PR1 (but can run in parallel with PR3 and later)

**Files:**
- NEW: `android/app/src/main/res/raw/adhan.mp3`
- NEW: `ios/Runner/Resources/adhan.caf`
- `ios/Runner.xcodeproj/project.pbxproj` — add `adhan.caf` to Copy Bundle Resources

**Conversion command:** `afconvert -f caff -d LEI16@22050 adhan.mp3 adhan.caf` (macOS only)

**Build gate requirement:** PR description must include evidence that both files are present and that the notification service references resolve correctly.

---

## PR4a — Calendar Visual Refresh

**Scope:** Rebuild calendar chrome + headers + dot legend. Extend `CalendarCubit.selectDate` to include habits and prayer completions (4 sources total). Keep existing `DualCalendarWidget` toggle.

**Safety rating:** 🟡 MEDIUM — new data sources in `CalendarCubit` require new repository queries

**Dependencies:** PR1, PR2

**Files:**
- `lib/features/calendar/presentation/cubit/calendar_cubit.dart`
- `lib/features/calendar/presentation/cubit/calendar_state.dart`
- `lib/features/calendar/presentation/widgets/calendar_body.dart`
- `lib/features/calendar/presentation/pages/calendar_page.dart`
- Possibly: `lib/features/habits/domain/repositories/habit_repository.dart` (new query method)

---

## PR4b — Calendar Dual-Display Rebuild

**Scope:** Introduce `DualDate` VO, new `CalendarCell`, `DualMonthSwitcher`. Both numerals always render. Delete `dual_calendar_widget.dart` after migration.

**Safety rating:** 🔴 HIGH — deletes existing widget; `isHijriMode` semantics change from "toggle mode" to "which numeral is primary"

**Dependencies:** PR4a must be merged

**New files:**
- `lib/features/calendar/domain/entities/dual_date.dart`
- `lib/features/calendar/presentation/widgets/calendar_cell.dart`
- `lib/features/calendar/presentation/widgets/dual_month_switcher.dart`

**Delete:**
- `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart`

---

## PR5 — Settings: Accessibility Section

**Scope:** New section above About in Settings. Houses Reduce Motion toggle, Disable Gyroscope toggle, Eastern Numerals toggle (default OFF).

**Safety rating:** 🟢 LOW — additive only; new fields in `UserSettings` require Isar migration (build_runner)

**Dependencies:** PR1

**After PR5:** `flutter pub run build_runner build --delete-conflicting-outputs`

**New fields in `UserSettings`:**
- `bool reduceMotion = false`
- `bool disableGyroscope = false`
- `bool easternNumerals = false`

---

## PR6 — Stats Redesign

**Scope:** Per `STATS_KPI_SPEC.md`. Refactor `StatisticsPage` visuals. Extend `StatsRepository` to fan-in tasks/habits/focus/prayer. KPI grid + insights + per-space breakdown + custom date range.

**Safety rating:** 🟡 MEDIUM — `StatsRepository` currently has minimal implementation; data fan-in is significant logic work

**Dependencies:** PR1, PR2; can run in parallel with PR3/PR-ADHAN

---

## PR7 — Athkar Feature (Net-new)

**Scope:** Per `ATHKAR_SPEC.md`. Curated sets only in v1. **Must open visual mock for designer review before implementing screens.**

**Safety rating:** 🟡 MEDIUM — net-new UI; existing `HabitType.athkar` enum and `athkar_card.dart` exist; careful not to duplicate

**Dependencies:** PR1, designer visual approval of mock first

**Approval gate:** Designer reviews visual mock before any code is written for Athkar screens

---

## PR8 — Focus Screen Oil-Fill

**Scope:** Per `FOCUS_OIL_SPEC.md`. Custom painter. Respect `MediaQuery.disableAnimations`.

**Safety rating:** 🟡 MEDIUM — `oil_animation.dart` and `fluid_engine.dart` are carve-outs (do NOT migrate their colors to flat tokens without designer review)

**Dependencies:** PR1, PR5 (Reduce Motion from PR5 must be in `UserSettings` before PR8 can read it)

---

## PR9 — iOS Widgets Refresh

**Scope:** Visual refresh only. App Group, WidgetKeys, Swift files all exist. Gated on `isPrayerEnabled`.

**Safety rating:** 🟡 MEDIUM — any Swift change requires device test; widget extensions are not testable in simulator for all cases

**Dependencies:** PR1, PR3 (prayer card visual reference)

**Hard rule:** Never rename `WidgetKeys` constants. Never change `group.com.iappsnet.athar`.

---

## PR-ONBOARD-AB — Four-Variant Onboarding A/B/C/D

**Scope:** Add three new onboarding variants. Variant A (existing 4-slide) UNTOUCHED. `OnboardingVariantService` with 25/25/25/25 routing.

**Safety rating:** 🔴 HIGH — touches startup/routing logic; any regression in Variant A is a critical UX failure; analytics events introduce Supabase table dependency

**Dependencies:** PR1 (for visual tokens used in Variants B/C/D)

**Critical constraint:** `onboarding_page.dart` behavior must not regress. Variant A is the UX canonical baseline.

**New files:**
- `lib/features/home/presentation/pages/onboarding_restyled_page.dart` (Variant B)
- `lib/features/home/presentation/pages/onboarding_short_page.dart` (Variant C)
- `lib/features/home/presentation/pages/onboarding_expanded_page.dart` (Variant D)
- `lib/core/services/onboarding_variant_service.dart`

**Approval gate:** All four variants must be demo'd to designer/product before merge. Variant governance rule applies.

---

## PR-CLEANUP — Hardcoded Color Sweep

**Scope:** Replace `Color(0x…)` literals in files NOT touched by other PRs. Run last.

**Safety rating:** 🟡 MEDIUM — many files; visual regression risk is distributed

**Carve-outs (do NOT touch):**
- `features/focus/presentation/widgets/oil_animation.dart`
- `features/focus/presentation/widgets/fluid_engine.dart`

**Top targets:**
- `core/services/prayer_timer_service.dart`
- `core/services/local_notification_service.dart`
- `core/design_system/widgets/athar_feedback.dart`
- `core/design_system/themes/app_theme.dart`

---

## PR Dependencies Summary

```
PR1 ← prerequisite for everything
PR-THEME ← depends on PR1
PR2 ← depends on PR1
PR3 ← depends on PR1, PR2
PR-ADHAN ← depends on PR1 (can parallel with PR3)
PR4a ← depends on PR1, PR2
PR4b ← depends on PR4a
PR5 ← depends on PR1 (can parallel with PR3, PR-ADHAN)
PR6 ← depends on PR1, PR2 (can parallel with PR3)
PR7 ← depends on PR1 + designer mock approval
PR8 ← depends on PR1, PR5
PR9 ← depends on PR1, PR3
PR-ONBOARD-AB ← depends on PR1
PR-CLEANUP ← depends on all other PRs being merged (runs last)
```

---

## Migration Strategy

**Token values:** Update in-place. Existing field names remain unchanged. No structural changes to Dart classes. All consumers of `context.colors.*` and `AtharTypography.*` automatically get new values.

**Font migration:** Add Calibri to pubspec alongside existing Cairo entries. Update `fontFamilyAr` and `fontFamilyEn` constants. Cairo remains loadable as fallback via `fontFallback` list.

**No generated file impact in PR1:** `UserSettings` not modified in PR1. No `build_runner` needed for PR1.

---

## Rollback Strategy

**PR1 rollback:** Git revert the two token files (`athar_colors.dart`, `athar_typography.dart`), remove Calibri TTF files from `assets/fonts/`, remove Calibri entries from `pubspec.yaml`. All downstream files continue working with old token values. Zero data loss.

**Later PR rollback:** Each PR is isolated. Reverting a single PR should not cascade failures to earlier PRs (architecture is designed for this).

---

## Validation Strategy

### Per-PR validation (applies to all PRs)
1. `flutter analyze --no-pub` — zero issues
2. `flutter test` — all tests pass
3. Before/after screenshots (light + dark mode)
4. Designer approval of screenshots before merge

### PR1-specific validation
1. Verify primary green (#1A6B3C) renders correctly on all primary surfaces
2. Verify Calibri TTF loads (English + Arabic text test)
3. Verify Arabic text fallback (if Calibri Arabic glyphs are missing, Cairo must render)
4. Verify prayer card gradient unchanged (critical — `prayerCardGradient` must remain `#1E293B → #0F172A`)
5. Verify dark mode primary is green (#2E8B57), not purple
6. Verify no analyzer errors from the new `numericMono` style

---

## Screenshot / Review Checkpoints

| PR | Required screenshots |
|----|---------------------|
| PR1 | Primary button light, primary button dark, nav bar active state, form field focused, prayer card (should be UNCHANGED) |
| PR-THEME | Settings page showing "Following system" helper text; dark/light toggle disabled state |
| PR2 | iPad layout on breakpoint threshold |
| PR3 | Prayer card compact, prayer card expanded, prayer card hidden state (isPrayerEnabled=false) |
| PR4a | Calendar with 4-source dots visible, calendar header |
| PR4b | Calendar cell with simultaneous Hijri + Gregorian numerals |
| PR5 | New Accessibility section in Settings |
| PR8 | Focus screen with oil fill; focus screen with Reduce Motion ON (no fill animation) |
| PR-ONBOARD-AB | All 4 variants side-by-side |

---

## Designer Approval Gates

| Gate | Required before |
|------|----------------|
| PR1 screenshots approved | PR1 merge |
| PR3 prayer card design validated | PR3 merge |
| PR7 Athkar mock approved | PR7 implementation begins |
| PR-ONBOARD-AB all 4 variants validated | PR-ONBOARD-AB merge |
| Any behavioral deviation in B/C/D from Variant A | PR-ONBOARD-AB merge |

---

## User Approval Gates

| Gate | Required before |
|------|----------------|
| PR1 diff list approval | PR1 implementation begins |
| Each subsequent PR diff list | Each PR implementation begins |

---

## Safe vs. Dangerous Phases

### Safe (isolated, easily reversible)
- PR-THEME (3-line fix)
- PR-ADHAN (file copy + Xcode project update)
- PR5 (additive settings section)

### Medium (broad visual impact but no logic changes)
- PR1 (value-only token update — global visual change)
- PR2 (rename + import update)
- PR6 (stats redesign — isolated feature)
- PR9 (Swift visual refresh)

### Dangerous (logic cascades, deletion, or multi-system impact)
- PR3 (prayer hierarchy — 3 enforcement points must survive)
- PR4b (deletes `dual_calendar_widget.dart`; `isHijriMode` semantics change)
- PR-ONBOARD-AB (startup routing; Variant A regression risk)

---

## Isolated vs. Cascading Phases

### Isolated (change is self-contained)
- PR-ADHAN (asset bundle only)
- PR5 (new settings section only)
- PR-THEME (3 lines + ARB keys)

### Cascading (changes affect multiple downstream files)
- PR1 (token values cascade to every widget that uses them — intended, this is the point)
- PR2 (import rename cascades to all files importing `adaptive_scaffold.dart`)
- PR4b (deletion of `dual_calendar_widget.dart` cascades to all consumers)

---

## Estimated Impact Scope per Phase

| PR | Files touched | Lines changed (approx) | Visual impact |
|----|--------------|------------------------|---------------|
| PR1 | 6 (2 Dart + pubspec + 3 TTF) | ~80 value lines | Global — every screen |
| PR-THEME | 4 | ~10 | Settings page + ThemeMode |
| PR2 | ~10–20 (imports) | ~5 + breakpoint logic | iPad layout |
| PR3 | 2 | ~200 | Prayer card |
| PR-ADHAN | 3 | ~5 | Zero UI |
| PR4a | ~5 | ~150 | Calendar screen |
| PR4b | ~5 new + 1 delete | ~400 | Calendar screen |
| PR5 | ~3 | ~100 | Settings page |
| PR6 | ~5–8 | ~500 | Stats screen |
| PR7 | ~10+ | ~1000+ | Athkar/Habits screen |
| PR8 | ~3 | ~300 | Focus screen |
| PR9 | ~3 (Swift) | ~200 | iOS widgets |
| PR-ONBOARD-AB | ~8+ | ~1500+ | Startup + onboarding |
| PR-CLEANUP | ~20+ | ~300 | Distributed |

---

## Highest Risk Phase

**PR-ONBOARD-AB** is the highest-risk phase:
- Touches startup routing (`main.dart` and `app.dart`)
- Any regression in `onboarding_page.dart` breaks Variant A (canonical baseline)
- Supabase analytics table may need to be created
- Four new page variants + new service = large surface area
- Routing logic error = new installs never see onboarding

**Second highest:** PR4b — deletes a widget that may have undiscovered consumers; `isHijriMode` semantics change from toggle to "primary numeral" has downstream implications in all calendar consumers.

---

## Recommended First Implementation Step (after approval)

**Step 1:** Copy Calibri TTF files from `handoff_v2/fonts/` to `assets/fonts/` in Flutter repo.  
**Step 2:** Add Calibri font entries to `pubspec.yaml`.  
**Step 3:** Update `AtharColors.light` values in `athar_colors.dart`.  
**Step 4:** Update `AtharColors.dark` values in `athar_colors.dart`.  
**Step 5:** Update `AtharTypography.fontFamilyAr`, `fontFamilyEn`, add `numericMono` to `athar_typography.dart`.  
**Step 6:** Run `flutter pub get`.  
**Step 7:** Run `flutter analyze --no-pub`.  
**Step 8:** Screenshot primary button, nav bar, form field, prayer card (light + dark).  
**Step 9:** Submit for designer approval.
