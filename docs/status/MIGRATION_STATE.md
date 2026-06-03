<!--
CANONICAL-FOR: Branch state, RULE 1/2 enforcement, Deferred QA bucket
OWNER:         Claude Code
PRECEDENCE:    4 (Tier 1 — loads after Tier-0 on any PR arc)
LAST-UPDATED:  2026-06-03 · PR-CLEANUP 98f4efe logged
LOADS-AT:      Tier 1
LEGACY-ALIASES: CURRENT_MIGRATION_STATE.md (root)
CANONICAL-SINCE: 2026-06-01
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
| **PR3** — Prayer Card Refresh | `1cd4f80` | (in branch) | ✅ `docs/history/pr-reports/PR3_SIGNOFF.md` | 2026-06-01 |
| **PR-THEME FINAL** — Wire AtharLightTheme/AtharDarkTheme + 88 fallbacks + RTL drawer | `bfaf863` | `athar-v2-prtheme-complete-final` | ✅ `docs/history/pr-reports/VERIFICATION_PR_THEME.md` | 2026-06-01 |
| **PR4a** — Calendar Visual Refresh | `85ada1e` | (in branch) | ✅ code signed off · 2 device-QA gates deferred | 2026-06-01 |
| **PR5** — Accessibility Settings | `6154565` | (in branch) | ✅ `flutter analyze` 0 issues · AR copy designer-approved | 2026-06-01 |
| **PR6** — Stats Redesign | `2a6a46a` | (in branch) | ✅ `flutter analyze` 0 issues · AR visual QA deferred to final sweep | 2026-06-01 |
| **PR4b** — Calendar Dual-Display | `65fc417` | (in branch) | ✅ 12/12 spec items PASS · AR visual QA deferred to final sweep | 2026-06-01 |
| **PR7** — Athkar v1 | `0b8fe34` | (in branch) | ✅ `flutter analyze` 0 new issues · 5 conformance fixes applied · AR visual QA deferred to final sweep | 2026-06-02 |
| **PR8** — Focus Oil-Fill | `2b10844` | (in branch) | ✅ `flutter analyze` 0 errors · 4 conformance deviations fixed · device QA deferred | 2026-06-02 |
| **PR9** — iOS Widget Visual Refresh | `4718207` | (in branch) | ✅ `flutter analyze` 0 errors · Prayer+Habit+Task v2 · P9-A/B/C fixes · device QA deferred | 2026-06-02 |
| **PR-ONBOARD-AB-INFRA** — A/B variant infra | `1f868f9` | (in branch) | ✅ `flutter analyze` 0 errors · device_id seed · OnboardingVariantService · 4-branch routing · analytics service · Supabase migration · dev reset tile · OPS-1 deploy step deferred | 2026-06-02 |
| **PR-ONBOARD-AB-UI** — Variants B/C/D pages + ARB + analytics wiring | `729c23d` | (in branch) | ✅ `flutter analyze` 0 errors · 3 new pages · 37 ARB keys · AR byte-verified · gen-l10n run · deferred device sweep in bucket | 2026-06-02 |
| **PR-DS-ATOMS** — DS atoms/molecules context.colors + Calibri + RTL | `028f99f` | (in branch) | ✅ `flutter analyze` 0 errors · 9 files migrated · canonical recipe established | 2026-06-02 |
| **PR-TASK-REFRESH** — Task feature UI DS refresh | `a1f28e0` | (in branch) | ✅ `flutter analyze` 0 issues · 20 files migrated · FLAG: 2 kept category hues (medicine teal + quiet zone indigo) | 2026-06-02 |
| **font-SSOT** — `AtharTypography.fontFamily` constant; 162 literal 'Calibri' → token across 35 files | `44de6f8` | (in branch) | ✅ `flutter analyze` 0 issues · no visual change · governance fix | 2026-06-02 |
| **PR-HABITS-REFRESH** — Habits feature UI DS refresh; context.colors + AtharTypography.fontFamily + RTL + AtharRadii/Spacing/Shadows/Animations; ~4.5k dead lines stripped | `c0932e3` | (in branch) | ✅ `flutter analyze` 0 issues · 8 files migrated · 3/8 UI Coverage Refresh PRs done · FLAG: athkar_card hex (0xFFFFF8E1/0xFFE8F5EF/Colors.orange), habit_page/tile gradients + streak orange — awaiting designer token | 2026-06-03 |
| **PR-HEALTH-REFRESH** — Health module UI DS refresh; 7-accent palette added to AtharColors (light+dark ThemeExtension); accent palette applied (appt types A, medicine types B, vital types C, dashboard cards D); structural rulings E/F/G/H; Tier-1 mechanical (6×AtharShadows.card, 3×AtharRadii.bottomSheet, 10×RTL, AppColors.success→context.colors.success); ~3.1k dead lines stripped | `ef13a74` | (in branch) | ✅ `flutter analyze` 0 issues · 9 files changed · 4/8 UI Coverage Refresh PRs done · accent palette is app-wide reusable (Tasks/Space/Notifications to adopt later) | 2026-06-03 |
| **PR-SPACE-REFRESH** — Space feature UI DS refresh; module-type accent palette (project→accentBlue, list→accentOrange, health→accentRed, assets→accentTeal, personal→accentBlue, shared→accentPurple); semantic (Colors.green→success, error, onPrimary); reject SnackBar→theme default; RTL fixes (8 directional conversions; DismissDirection.endToStart KEPT); AtharShadows.card; AtharRadii.bottomSheet; ~2.7k dead lines stripped | `6d3b303` | (in branch) | ✅ `flutter analyze` 0 issues · 12 files changed · 5/8 UI Coverage Refresh PRs done | 2026-06-03 |
| **PR-SETTINGS-REFRESH** — Settings UI DS refresh; AtharColors: accentGreen (#3C9A5F/#6FCB8E) + accentIndigo (#4754B5/#8A93DD) added; Cairo×42→Calibri; prayer/account icons→colorScheme.primary; athkar icons→AtharColors.athkar*; zone/smart icons→accent palette; frozen PR5 Accessibility icons untouched; Switch activeTrack→primary; dialog Colors.white→onPrimary; red.shade600→error; Colors.orange→warning; grey variants→outline/outlineVariant/surfaceContainerLow; smart_zones boxShadow→AtharShadows.card; zone colors→accentBlue/Green/Purple/Teal/Indigo; add_category Duration→AtharAnimations.normalFast; KNOWN_PROBLEMS P5+P6 logged | `0cfd53e` | (in branch) | ✅ `flutter analyze` 0 issues · 7 files changed · 6/8 UI Coverage Refresh PRs done | 2026-06-03 |
| **PR-PRAYER-DETAILS** — Prayer detail views DS refresh; RTL chevrons (locale-aware via `Localizations.localeOf`) in prayer_month_view; no-font TS→Calibri across all 4 prayer views (prayer_details_page, prayer_day_view, prayer_week_view, prayer_month_view); AtharTypography import added; isPast dimming DEFERRED; P5+P6 logged in KNOWN_PROBLEMS | `e1962c2` | (in branch) | ✅ `flutter analyze` 0 issues · 4 files changed · 7/8 UI Coverage Refresh PRs done | 2026-06-03 |
| **PR-SPLASH-ONBOARD-A** — Splash + all 4 onboarding variants DS refresh; docs/governance §8.5 Artistic-surface exception added; AtharColors.cream = Color(0xFFEDE6C8) added; splash: _kNightSky1/2/3/_kGlow/_kTagline/_kParticle named consts; progress → colorScheme.primary; Cairo×2→Calibri+fontFallback; AtharRadii.xxxs; Variant A: _visual→_buildSlides(context); forest gradient all 4 slides; per-slide accent context.colors.accentGreen/Blue/Purple/primary; icon uses accent; Cairo×6→Calibri; AtharRadii.xl/full/xxs; EdgeInsetsDirectional dots; Variants B/C/D: _kForest/Mid → AtharColors.prayerCardShadowDeep/Mid; _kCream → AtharColors.cream; _kAccents cream entry → AtharColors.cream; AtharRadii.full/lg/md/xl/xxs | `df5e268` | (in branch) | ✅ `flutter analyze` 0 issues · 7 files changed · **8/8 UI Coverage Refresh PRs done** | 2026-06-03 |
| **PR-CLEANUP-PHASE-A** — Delete ~3134 lines of commented-out dead code: main_page.dart (1636L), dashboard_page.dart (1090L), statistics_card.dart (82L), smart_habits_strip.dart (777L dead missed in earlier sweep) | `a805aa9` | (in branch) | ✅ `flutter analyze` 0 issues | 2026-06-03 |
| **PR-CLEANUP-ORPHANS** — Orphan surface token migration: accent palette (notifications: accentOrange/Blue/Red); semantic dhikr colors (shadow/outlineVariant/surfaceContainerHighest/error/success/onSurface/onSurfaceVariant); Duration migrations (snackbarVisibleShort, normalSlow×2, normalFast); AtharAnimations.standard alias added; dashboard_page 2s→snackbarVisibleShort; dhikr outline→onSurfaceVariant fix (row 3+5) | `da272da` · fix `a3b71ec` | (in branch) | ✅ `flutter analyze` 0 issues | 2026-06-03 |
| **PR-CLEANUP-HYGIENE** — Residual radii + durations in 8 already-done feature files: 10 radii (bottomSheet/xl/xxxs) across project_details, add_task_sheet, general_settings, focus_screen, liquid_background; 4 durations (normalFast/normalSlow/snackbarVisibleShort) across task_details, add_task_sheet, habit_page, smart_zones. Kept raw: 500ms (no token), 1s system/ticker, 2s artistic, 3s snackbar, focus_cubit 300ms (cubit layer boundary) | `98f4efe` | (in branch) | ✅ `flutter analyze` 0 issues · 8 files changed | 2026-06-03 |

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
| PR1 | Phase tracker + docs/status/ROADMAP.md updated |
| PR-THEME full arc | `docs/history/pr-reports/VERIFICATION_PR_THEME.md` · `docs/history/pr-reports/PR_THEME_FINAL_REPORT.md` |
| PR2 | `docs/history/pr-reports/PR2_CHECKPOINTS.md` (6/6 CPs) · `docs/history/pr-reports/PR2_PROGRESS_REPORT.md` |
| PR3 | `docs/history/pr-reports/PR3_SIGNOFF.md` |
| PR4a | Code signed off (85ada1e) · `docs/history/pr-reports/VERIFICATION_PR4A.md` · 2 device-QA gates deferred to physical-device pass |

---

## Active PR

**PR-CLEANUP** — ✅ Complete (2026-06-03) · final commit `98f4efe`. 4 commits total. All 13/14 scoped feature PRs + 8/8 UI Coverage Refresh PRs done. Remaining: PR-ADHAN (blocked on audio asset B4).

---

## Current Working Tree State

```
flutter analyze → 0 issues (pre-existing task_page.dart + project_details_page.dart warnings suppressed inline)
PR-SPACE-REFRESH complete. Last commit: 6d3b303. See CHECKPOINT.md for full state.
```

---

## Next Recommended PR

> **PR ordering and status live in `docs/status/ROADMAP.md` (SINGLE SOURCE OF TRUTH).** See `docs/status/NEXT_STEPS.md` for current next-step guidance.

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
- QA sweep timing: **END of roadmap, after the last feature PR.** No feature PR is gated by this sweep. Nothing ships to a real user or TestFlight until the sweep passes.
- All fixes in this bucket are **UNVERIFIED** — logical hypotheses, confirmed only on a physical device. Do NOT apply any fix until device validation.
- To add an item: assign an ID (PR origin + sequential number), describe the pass condition, and write the candidate fix as a hypothesis.

**Current count: 11 of 11 (ceiling raised).**

| ID | Description | Origin | Status |
|----|-------------|--------|--------|
| PR3-R1 | Forest gradient prayer card — dark mode physical device render | PR3 | Unverified |
| PR3-R2 | 44pt countdown legibility on iPhone SE (375×667) | PR3 | Unverified |
| PR4a-G1 | iPhone SE calendar overflow (6-row month) | PR4a | Unverified — see below |
| PR4a-G2 | Today-state dark alpha legibility | PR4a | Unverified — see below |
| DEVICE-1 | Forest-dark surfaces, Cairo fallback, RTL drawer, countdown tick (general device pass) | PR-THEME/PR2 | Unverified |
| PR8-perf | PR8 final-sweep (physical device): 5 visual states + gyro slosh + sudden-flip splash + 60fps iPhone 12 tripwire — highest priority | PR8 | Unverified |
| PR9-sweep | PR9 all-widget device sweep: Prayer (sm/md/lg) × ar/en · Habit (sm/md/lg) × ar/en · Task (sm/md/lg) × ar/en · Calibri renders in each extension · forest gradient parity · widgetURL deep-link · systemLarge dual-date/strip/sunrise-sunset · ring+7-day history · post-prayer label (40 min vs dynamic app window — P9-C, flag for designer) · manual Xcode font steps (OQ3) required before sweep | PR9 | Unverified |
| OPS-1 | **Apply `supabase/migrations/20260602_onboarding_events.sql` to the live Supabase project.** Until applied, all `onboarding_events` anon inserts no-op silently (by design — service catches the error). Analytics records nothing until this migration is deployed. This is a deploy step, not a code step. Must be done before the A/B test goes live. | PR-ONBOARD-AB-INFRA | ⚠️ Deploy step — not a device QA item |
| ONBOARD-sweep | **PR-ONBOARD-AB device sweep:** All 4 variants × ar/en × light/dark. Pass conditions: (1) Variant B visually matches A structure — same slide count/order/timing, only forest gradient+Calibri differ. (2) Variant D is calm, NOT enterprise-heavy — no form overload. (3) Skip-every-optional-step in D still completes (reaches /login). (4) Analytics fire per variant: `onboarding_started`, `onboarding_completed` (B/C/D); `onboarding_step_completed/skipped` (D only); `onboarding_abandoned` fires when app goes to background mid-D-flow. (5) `onboarding_seen=true` + `onboarding_variant=<variant>` written to SharedPreferences after CTA. Gate: OPS-1 must be deployed for analytics to land. | PR-ONBOARD-AB-UI | Unverified |
| SPACE-list-swipe | **`list_page.dart` swipe-to-delete: verify reveal side + icon/padding mirror correctly in ar (RTL) and en (LTR) on device.** Pass conditions: (1) In Arabic (RTL): swipe left → reveals red delete bg on the LEFT side (start edge). (2) In English (LTR): swipe right → reveals red delete bg on the RIGHT side (start edge in LTR). `DismissDirection.endToStart` is text-direction-aware; background `AlignmentDirectional.centerStart` and `EdgeInsetsDirectional.only(start:)` are set. Cannot be verified without a running app. | PR-SPACE-REFRESH | Unverified |
| SHIP-GATE | **SHIP GATE: full UI-coverage pass required before store submission.** All 8 UI Coverage Refresh PRs have now landed (PR-DS-ATOMS · PR-TASK-REFRESH · PR-HABITS-REFRESH · PR-HEALTH-REFRESH · PR-SPACE-REFRESH · PR-SETTINGS-REFRESH · PR-PRAYER-DETAILS · PR-SPLASH-ONBOARD-A ✅). PR-CLEANUP also complete. Remaining gate items: (1) Device QA sweep of all 11 deferred bucket items. (2) B1 Calibri licence confirmation. (3) PR-ADHAN audio asset. See `docs/ai/KNOWN_PROBLEMS.md` and `docs/status/ROADMAP.md`. | UI Coverage Refresh PRs complete 2026-06-03 | ⚠️ PRs shipped; QA + B1 + B4 gates remain |

---

### PR4a-G1 — iPhone SE (375×667) calendar overflow

**Pass condition:** 6-row month fits with no vertical overflow AND "Day events" header is visible without scrolling.

**Why it may fail:** The 64pt cell-height tier triggers at `width >= 360`. iPhone SE is 375dp, which hits the 64pt tier. A 6-row month at 64pt/cell = 384pt of grid, which may push the header below the fold on a 667pt screen.

**Deferred QA Candidate Fix (UNVERIFIED — logical hypothesis, must be confirmed on device before applying):**
```dart
// In calendar_page.dart _CalendarGrid LayoutBuilder — widen the compact tier threshold:
// Change:  constraints.maxWidth < 360 ? 54.0
// To:      constraints.maxWidth < 390 ? 54.0
//
// Alternative: gate on height < 700 using MediaQuery if width alone is insufficient.
// Note: dual_calendar_widget.dart was deleted in PR4b; this fix now targets _CalendarGrid.
```

### PR4a-G2 — Today-state dark mode legibility

**Pass condition:** Today background (`colorScheme.primary @ 0.13` in dark) is visually distinct from the surface on the dark forest theme.

**Deferred QA Candidate Fix (UNVERIFIED — logical hypothesis, must be confirmed on device before applying):**
```dart
// In calendar_day_cell.dart — raise dark alpha for today background:
// Change:  bgColor = colors.primary.withValues(alpha: 0.08);
// To:      bgColor = colors.primary.withValues(alpha: isDark ? 0.15 : 0.08);
// Note: dual_calendar_widget.dart was deleted in PR4b; today-state logic now lives in CalendarDayCell.
```

---

## Open Items / Hard Blockers

| ID | Item | Gate type |
|----|------|-----------|
| B1 | Calibri App Store licence | Submission gate (not build gate) |
| ~~B3~~ | ~~Calendar dual-display (`DualDate`) designer spec~~ | **Closed** — PR4b shipped `65fc417` |
| B4 | Adhan audio asset | PR-ADHAN build gate |
| Phase 5 | Physical device validation (all 3 iOS widgets) | Release gate |

_Device QA items (PR3-R1, PR3-R2, PR4a-G1, PR4a-G2, DEVICE-1) are tracked in the Deferred QA Bucket above._
