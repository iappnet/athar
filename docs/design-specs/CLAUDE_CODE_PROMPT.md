# Claude Code — Implementation Prompt

> Paste the block below into Claude Code with both the Athar Flutter repo
> (`iappnet/athar`) and this design-system workspace mounted.

---

## Prompt

You are implementing the Athar app redesign in Flutter. Two sources of
truth are mounted:

1. **`iappnet/athar`** — the live Flutter repo. Edit code here.
2. **Design-system workspace** (this folder) — visual + behavioural specs.
   Do **not** edit anything here; treat as contract.

### Read in this order before writing any code

1. **`INVESTIGATION_RECONCILIATION.md`** ← READ FIRST. Locks the 5 designer decisions and overrides any older spec it conflicts with.
2. `PACKAGE_A_DECISIONS.md` — first 8 decisions.
3. `PACKAGE_C_DECISIONS.md` — 12 follow-up decisions.
4. `REDESIGN_AUDIT.md` — per-screen Dart-file ticket map.
5. `IPAD_OPTIMIZATION.md` — adaptive shell + per-screen iPad layouts.
6. `THEME_DARK_SPEC.md` — dark mode per-surface treatments.
7. `SKILL.md` — design-system rules (tokens, type, motion, RTL, haptics, sounds).
8. `colors_and_type.css` — token values to port into Dart.
9. `Athar Brand System.html` — palette + logo system.
10. Component specs: `COMPONENT_SPECS.md`, `PRAYER_CARD_SPEC.md`, `CALENDAR_CELL_SPEC.md`, `ATHKAR_SPEC.md`, `IOS_WIDGETS_SPEC.md`, `STATS_KPI_SPEC.md`, `FOCUS_OIL_SPEC.md`, `CALENDAR_FOCUS_REDESIGN.md`, `ONBOARDING_AB_SPEC.md`.
11. Visual references (open in browser, do not import): `ui_kits/athar_app/index.html`, `preview/comp-prayer-card.html`, `ipad/Athar iPad Layouts.html` (if present).

### Locked decisions (from INVESTIGATION_RECONCILIATION.md — non-negotiable)

- **Adhan audio:** source file is `assets/audio/adhan.mp3` (Hamad Al-Daghriri recitation). Bundle as `adhan.mp3` in `android/app/src/main/res/raw/` and convert to `adhan.caf` for iOS at `ios/Runner/Resources/`. Build fails if file is absent. User-selectable later.
- **Theme mode:** wire `UserSettings.isAutoModeEnabled` → `ThemeMode.system` in `lib/app.dart:162–172`. Three-way: auto (system) > manual dark > manual light.
- **Calendar dots:** include all 4 sources — tasks + appointments + **habits + prayer completions**. Extend `CalendarCubit.selectDate`.
- **Calendar dual display:** PR4a (visual refresh, keep toggle) → PR4b (rebuild simultaneous display with `DualDate` VO + new `CalendarCell` + `DualMonthSwitcher`).
- **Color migration:** scoped — replace `Color(0x…)` literals only in files touched by the active redesign PR. Cleanup-sweep PR runs last.

### Things that already exist — DO NOT rebuild

- `HabitType { regular, athkar }` enum (extend, don't recreate)
- `task`, `space`, `stats` features (redesign visuals, don't build from scratch)
- `UserSettings.prayerCardDisplayMode` enum (use this; do **not** introduce `prayerCardVariant`)
- All design-system token files (update *values*, not structure)
- `onboarding_page.dart` at `features/home/presentation/pages/` (refactor in place; do **not** create `lib/features/onboarding/`)
- iOS widgets (`AtharPrayerWidget`, `AtharTaskWidget`, `AtharHabitWidget`) + App Group `group.com.iappsnet.athar`
- `flutter_local_notifications` channels (verify, don't rewrite)
- `hijri` package (already imported)

### Implementation order (PR by PR)

**PR1 — Tokens & Theme**
- Port palette + type from `colors_and_type.css` into existing `lib/core/design_system/tokens/` files (update values, not structure). **Calibri is the sole canonical brand font** for both Arabic and English (Light 300 / Regular 400 / Bold 700 — locally hosted). Cairo and Inter are NOT design-authority fonts; they may remain only as last-resort emergency technical fallbacks at the platform level if a glyph fails to render. Add `numericMono` style.

**PR-THEME — `ThemeMode.system` wiring**
- Three-line fix in `lib/app.dart:162–172`. When `isAutoModeEnabled`, return `ThemeMode.system` and visually disable the manual dark toggle in settings (helper text "Following system" via ARB).

**PR2 — AdaptiveShell**
- Rename `lib/core/layouts/adaptive_scaffold.dart` → `lib/core/design_system/widgets/adaptive_shell.dart`. Update all imports. Implement breakpoints per `IPAD_OPTIMIZATION.md`.

**PR3 — Prayer card refresh**
- Rebuild per `PRAYER_CARD_SPEC.md`. Use existing `UserSettings.prayerCardDisplayMode`. Compact/expanded variants are local widget state. Do **not** regress Phase 8.1 hierarchy (3 enforcement points: `smart_prayer_wrapper.dart:30`, `prayer_notification_scheduler.dart:35,209,271`, `prayer_conflict_service.dart:16`).

**PR-ADHAN — Bundle adhan audio**
- Place `adhan.caf` in `ios/Runner/Resources/` (added to iOS target). Place Android raw resource at `android/app/src/main/res/raw/adhan.<ext>`. Verify both `RawResourceAndroidNotificationSound('adhan')` and the iOS `'adhan.caf'` reference resolve at runtime. **Fail the build with a clear error if the asset is missing.**

**PR4a — Calendar visual refresh**
- Rebuild visuals + headers + dot legend per `CALENDAR_CELL_SPEC.md`. **Keep the existing `DualCalendarWidget` toggle** for now. Extend `CalendarCubit.selectDate` to fan-in habits + prayer completions alongside tasks + appointments.

**PR4b (= PR-CAL) — Dual-display rebuild**
- Introduce `lib/features/calendar/domain/entities/dual_date.dart`, `presentation/widgets/calendar_cell.dart`, `presentation/widgets/dual_month_switcher.dart`. Both numerals always render; `isHijriMode` repurposed = which numeral is *primary* (larger weight). Delete `dual_calendar_widget.dart` after migrating consumers.

**PR5 — Settings: Accessibility section**
- New section above About. Houses Reduce Motion, Disable Gyroscope, Eastern Numerals (default OFF).

**PR6 — Stats redesign**
- Per `STATS_KPI_SPEC.md`. Stats feature already exists (`StatsCubit`, `StatisticsPage`). Refactor visuals + extend `StatsRepository` to fan-in tasks/habits/focus/prayer (mirrors §C3 fan-in). KPI grid + insights + per-space breakdown + custom date range + CSV/PDF export.

**PR7 — Athkar feature (net-new)**
- Per `ATHKAR_SPEC.md`. Curated sets only in v1. Open visual mock for designer review **before** implementing screens.

**PR8 — Focus screen oil-fill**
- Per `FOCUS_OIL_SPEC.md`. Custom painter, respect Reduce Motion via `MediaQuery.disableAnimations`. **Note:** `oil_animation.dart` and `fluid_engine.dart` use procedurally generated colors — do not migrate to flat tokens without designer review (see Reconciliation §D carve-out).

**PR9 — iOS widgets refresh**
- Per `IOS_WIDGETS_SPEC.md`. Refactor visuals only — App Group, WidgetKeys, and Swift files already exist. Gated on `isPrayerEnabled` master toggle. Mirror `prayerCardDisplayMode`.

**PR-ONBOARD-AB — Four-variant onboarding A/B/C/D test**
- Per `ONBOARDING_AB_SPEC.md`. **Variant A (existing 4 slides) is the canonical behavioral baseline — DO NOT modify it.** Add three new variants:
  - **B (existing-restyled):** 4 slides, same structure/pacing/nav as A, only visuals updated to new Athar tokens. `OnboardingRestyledPage` + 4 slide widgets mirroring `_buildSlides()` exactly.
  - **C (short):** 2 slides — welcome+features → Get Started. `OnboardingShortPage`.
  - **D (expanded):** 6 steps — welcome → modules → location → notifications → space → finish. `OnboardingExpandedPage`. Must remain calm and lightweight (target <90s if optional steps skipped). **Dhikr default OFF** (do not auto-enable spiritual modules during onboarding). **Spaces step is reduced**: "Just for me" pre-selected, "Create shared space" removed (deferred to in-product); only "Just for me" + "Join with code" visible.
- Add `OnboardingVariantService` for 25/25/25/25 routing using existing `SharedPreferences` infrastructure. Add `onboarding_variant` key alongside the existing `onboarding_seen` key.
- Allow `--dart-define=ONBOARDING_VARIANT=existing|existing_restyled|short|expanded` override for QA.
- **Analytics:** Supabase events only — do NOT add Firebase, Mixpanel, or any new SDK. If the app already has an analytics table, append events to it; otherwise create `onboarding_events` table per spec.
- Variant governance: any behavioral deviation in B/C/D from Variant A's calm, low-friction, spiritually-respectful feel must be flagged in the PR description and approved before merge.

**PR-CLEANUP — Hardcoded color sweep**
- Replace remaining `Color(0x…)` literals in files NOT touched by other PRs. Top targets: `core/services/prayer_timer_service.dart`, `core/services/local_notification_service.dart`, `core/design_system/widgets/athar_feedback.dart`, `core/design_system/themes/app_theme.dart`. **Carve-out:** `oil_animation.dart` and `fluid_engine.dart` are excluded — designer review required.

### Hard rules

- All hex / colors via `AppColors.*` tokens. **No hardcoded colors** in files touched by an active PR.
- All copy via `app_en.arb` / `app_ar.arb`. **No string literals in widgets.** (Includes the existing hardcoded `"أذكار ما بعد الصلاة"` at `habit_cubit.dart:321` — extract to ARB.)
- All sizing via `AppSpacing.*`. No raw pt/px in widgets.
- RTL: every custom widget honors `Directionality.of(context)`. `EdgeInsetsDirectional` not `EdgeInsets`.
- Tabular numerals: any numeric-aligned text uses `numericMono`.
- Adaptive: every screen uses `AdaptiveShell` and `LayoutBuilder` (not `MediaQuery.size`).
- Phase 8.1 prayer hierarchy is sacred — `isPrayerEnabled` master toggle cascades to all prayer surfaces (in-app, widget, notifications).
- Reuse `UserSettings.prayerCardDisplayMode` — do **not** add `prayerCardVariant`.
- Adhan asset must be bundled — build fails clearly if absent.
- One PR per phase. After each: run analyzer + `flutter test`. Open with before/after screenshots for designer.
- After any Isar / freezed / @injectable change: `flutter pub run build_runner build --delete-conflicting-outputs`.

### When you hit ambiguity

1. Re-read `INVESTIGATION_RECONCILIATION.md` first.
2. Re-read the relevant spec file.
3. If still unclear, **stop and write a short question doc** at the repo root (`QUESTIONS_<phase>.md`) listing decisions needed. Do not guess.

### Out of scope

- Visual changes not covered by a spec file.
- Refactoring unrelated to the migration.
- Backend / Supabase schema changes (separate ticket stream). **Note:** Adding new `HabitType` enum values may require a Supabase column check-constraint update — confirm before extending.
- User-selectable adhan tracks (v2).
- The 5 open gaps in `INVESTIGATION_RECONCILIATION.md §E` (paywall copy, error-state pattern, loading skeleton coverage, etc.) — track separately.
