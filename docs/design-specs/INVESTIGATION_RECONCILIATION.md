# Investigation Reconciliation — what changed after the codebase audit

> Read this **before** `CLAUDE_CODE_PROMPT.md`. It is the single source of
> truth for every assumption that shifted after Claude Code's read-only
> investigation (`uploads/INVESTIGATION_REPORT.md`). Where this doc and an
> older spec disagree, **this doc wins**.

Date locked: 2026-05-07. Source: `uploads/INVESTIGATION_REPORT.md`.

---

## A · Things that already exist — DO NOT rebuild

| # | What we assumed was missing | What's actually in the code | Action |
|---|---|---|---|
| 1 | "Add `Habit.type` enum" | `enum HabitType { regular, athkar }` already exists at `lib/features/habits/data/models/habit_model.dart:11` and is persisted via Isar `@Enumerated(EnumType.name)`. | **Drop ticket.** Future additions are just enum-value extensions + `build_runner`. |
| 2 | "Build Tasks / Spaces / Stats from scratch" | All three are fully implemented. `TaskCubit` (`features/task/`), `SpaceCubit` + 5 sibling cubits (`features/space/`), `StatsCubit` (`features/stats/`). | **Convert to *redesign* tickets**, not net-new builds. Cubit/state shapes already exist. |
| 3 | "Add `prayerCardVariant` field to `UserSettings`" | `UserSettings.prayerCardDisplayMode` already exists as enum `dashboardOnly | dashboardAndTasks | allPages`. | **Reuse the existing field.** Do not introduce a parallel `prayerCardVariant`. The compact/expanded toggle is local widget state, persisted separately if needed (see §C2). |
| 4 | "Port tokens into Dart" | All token files exist: `athar_colors.dart`, `athar_typography.dart`, `athar_spacing.dart`, `athar_radii.dart`, `athar_shadows.dart`, `athar_animations.dart`. | **Update token *values***, not file structure. |
| 5 | "Onboarding — net-new feature folder" | `onboarding_page.dart` exists at `lib/features/home/presentation/pages/`, 4 slides, persisted via `SharedPreferences` key `'onboarding_seen'` (read in `main.dart:106`). | **Refactor in place.** Do *not* create `lib/features/onboarding/`. The existing flow + persistence is correct; only visuals + copy change. |
| 6 | "Build iOS widgets" | Three widget extensions exist: `AtharPrayerWidget`, `AtharTaskWidget`, `AtharHabitWidget`. App Group `group.com.iappsnet.athar`. All `WidgetKeys` defined in `widget_data_service.dart`. | **Refactor visuals only.** Widget infra, App Group, and key contract are all in place. |
| 7 | "Wire prayer notifications" | `flutter_local_notifications: ^21.0.0`, `prayer_channel` + 5 sibling channels defined in `local_notification_service.dart`. `prayer_notification_scheduler.dart` enforces the master toggle. | **Verify only.** Do not rewrite the channel system. |
| 8 | "Add `hijri` package" | Already imported and used in `athar_date_picker.dart:6` and `widget_data_service.dart:8`. | **Reuse.** |

---

## B · Three blockers we are NOT shipping without addressing

### B1 · Adhan audio — RESOLVED
- **Finding:** `local_notification_service.dart` references `adhan.caf` (iOS) and raw resource `adhan` (Android), but no audio file existed in the repo.
- **Decision:** Bundle Hamad Al-Daghriri recitation as the default. User-selectable tracks deferred to v2.
- **Asset:** `assets/audio/adhan.mp3` (mounted in this workspace, ready to copy into the Flutter repo).
- **Implementation:**
  - Copy `assets/audio/adhan.mp3` → `android/app/src/main/res/raw/adhan.mp3` in the Flutter repo.
  - Convert MP3 → CAF and place at `ios/Runner/Resources/adhan.caf`. Add to the iOS target's Copy Bundle Resources phase. (Conversion: `afconvert -f caff -d LEI16@22050 adhan.mp3 adhan.caf` on macOS.)
  - Verify `RawResourceAndroidNotificationSound('adhan')` and the iOS `'adhan.caf'` reference resolve at runtime.
  - Build must fail with a clear error if either file is absent.

### B2 · `isAutoModeEnabled` is a dead field — wire it
- **Finding:** `UserSettings.isAutoModeEnabled` is persisted but `MaterialApp.themeMode` is hardcoded to `isDark ? ThemeMode.dark : ThemeMode.light` at `lib/app.dart:162–172`. `ThemeMode.system` is never used.
- **Decision:** **Wire it.** Three-line change.
- **Implementation:**
  ```dart
  // lib/app.dart, replace lines 162-172
  final settings = settingsState is SettingsLoaded ? settingsState.settings : null;
  final themeMode = (settings?.isAutoModeEnabled ?? false)
      ? ThemeMode.system
      : (settings?.isDarkMode ?? false ? ThemeMode.dark : ThemeMode.light);
  ```
  Then in the settings UI, when `isAutoModeEnabled == true`, visually disable the manual dark-mode toggle and show the helper text "Following system" (locale-aware via ARB).

### B3 · Calendar dual display rebuild — its own milestone
- **Finding:** `DualCalendarWidget` is **toggle-based** (`_isGregorianPrimary` switches which mode is shown). Design spec calls for **simultaneous** Hijri + Gregorian numerals in every cell.
- **Decision:** This is **PR-CAL** (its own milestone) **AND** part of the Calendar redesign ticket. Do not bundle into PR4. Sequence:
  1. **PR4a — Calendar visual refresh** (chrome, headers, dot legend, activity-source extension per §C3). Keeps the existing toggle widget for now.
  2. **PR4b (= PR-CAL) — Dual-display rebuild.** Introduce `DualDate` value object, new `CalendarCell` widget, `DualMonthSwitcher`. `isHijriMode` is repurposed as "which numeral is *primary*" (larger weight), not which is shown.
- **Files in PR4b:**
  - New: `lib/features/calendar/domain/entities/dual_date.dart`
  - New: `lib/features/calendar/presentation/widgets/calendar_cell.dart`
  - New: `lib/features/calendar/presentation/widgets/dual_month_switcher.dart`
  - Replace: `dual_calendar_widget.dart` (delete after migration; rename consumers).
  - Update: `CalendarCubit` activity-source fan-in (see §C3).

---

## C · Five decisions, locked

| Q | Decision | Implementation note |
|---|---|---|
| **C1 · Adhan source** | Bundle one default `adhan.caf`. User-selectable later. | See B1. |
| **C2 · `themeMode.system`** | Wire `isAutoModeEnabled` → `ThemeMode.system`. | See B2. PR-THEME, 3-line fix. |
| **C3 · Calendar dots** | Include **all four** sources: tasks + appointments + **habits + prayer completions**. | Extend `CalendarCubit.selectDate` (currently `calendar_cubit.dart:36–60`) to also query `HabitRepository.getCompletionsForDay(date)` and `PrayerCubit` adherence. Add `TimelineItem` discriminator if not present. |
| **C4 · Dual-calendar rebuild** | Own milestone (PR4b) **and** part of Calendar redesign. Sequence PR4a → PR4b. | See B3. |
| **C5 · Color migration** | **Scoped migration only** — replace `Color(0x…)` literals only in files Claude Code touches as part of a redesign ticket. Add a follow-up "tokens cleanup" sweep ticket (PR-CLEANUP) for the remaining files. | See §D. |

---

## D · Scoped color migration — PR plan

The investigation found **211 `Color(0x…)` occurrences across 20+ files**. We are **not** running a single 88-file migration PR. Instead:

### Inline (do as part of the redesign PR)
Whenever a redesign ticket touches a file, **replace every `Color(0x…)` and inline `TextStyle` in that file** with token references. No exceptions, no half-migrations per file.

### PR-CLEANUP (follow-up ticket, after main redesign PRs)
A separate PR sweeps the remaining files. Top offenders that **will not** be touched by other tickets need to land here:

| File | Count | Reason it's not in another ticket |
|---|---|---|
| `core/services/prayer_timer_service.dart` | 6 | Service, no UI ticket. |
| `core/services/local_notification_service.dart` | 6 | Service, no UI ticket. |
| `core/design_system/widgets/athar_feedback.dart` | 6 | Widget already token-correct elsewhere. |
| `core/design_system/themes/app_theme.dart` | 6 | Theme file; cleanup, not redesign. |

### Carve-out: animation files
`features/focus/presentation/widgets/oil_animation.dart` (14 hits) and `fluid_engine.dart` (6 hits) use **procedurally generated colors for visual effects**. **Do not migrate these to flat tokens without designer review.** They are explicit exceptions. Ticket: design review + targeted token additions if needed (`AppColors.oilFillBase`, `oilFillRipple`, etc.).

---

## E · Open gaps not addressed by current specs (need decisions later)

These came out of the investigation §E. They are **not blocking** the implementation prompt, but track them:

1. **Hardcoded Arabic literal** at `habit_cubit.dart:321` (`"أذكار ما بعد الصلاة"`) — needs ARB key.
2. **Subscription paywall copy** in `subscription_page.dart` and `pro_gate_widget.dart` — needs Arabic translations + design sign-off.
3. **Habit widget empty state** — what does the iOS habit widget show if a user's only habits are `HabitType.athkar`? Spec required.
4. **Error-state pattern** — code mixes inline snackbars, error screens, and retry dialogs. Pick one canonical pattern; document in `SKILL.md`.
5. **Loading skeleton coverage** — `AtharSkeleton` exists but most features use `CircularProgressIndicator`. Pick a coverage rule.

## E2 · Onboarding A/B/C/D — four variants (LOCKED 2026-05-07)

The existing 4-slide onboarding is kept as the **canonical behavioral
baseline** (Variant A) and is not touched. Three new variants are added
for an A/B/C/D test:

- **Variant A (control):** existing 4-slide flow. UNTOUCHED. UX authority.
- **Variant B (existing-restyled):** 4 slides — same structure / pacing / nav / behavior as A, only visuals updated to new Athar tokens. Visual modernization, not a behavioral rewrite.
- **Variant C (short):** 2 slides — welcome+features → Get Started. Ultra-low-friction entry.
- **Variant D (expanded):** 6 steps — welcome → modules → location → notifications → space → finish. Lightweight, calm, emotionally grounded; under 90s when optional steps skipped.

### Locked sub-decisions

| # | Decision | Rationale |
|---|---|---|
| **D-Dhikr** | Variant D step 02: Dhikr default = **OFF** | Keep Athar universal-by-default; do not force spiritual assumptions during onboarding. Users may intentionally enable later. |
| **D-Spaces** | Variant D step 05: pre-select **"Just for me"**; **remove "Create shared space"**; keep only "Just for me" + "Join with code" | Athar is personal-first, not collaboration-first. Spaces complexity moves in-product. Reduces onboarding cognitive load. |
| **Analytics** | **Supabase events only.** No Firebase, no Mixpanel, no new SDKs. | Lightweight and implementation-safe. If app has an existing analytics table, append events; otherwise create `onboarding_events` per spec. |
| **Routing split** | 25/25/25/25 deterministic by `device_id` hash. | Equal exposure for clean comparison. |
| **Variant governance** | Any behavioral deviation in B/C/D from Variant A's calm, low-friction, spiritually-respectful feel must be flagged in the PR description and approved before merge. | Protect the emotional onboarding feel; prevent Variant D from becoming a configuration wizard. |

### Onboarding philosophy guardrails

Onboarding must feel calm, immersive, emotionally grounded, spiritually
respectful, lightweight, personal-first, focused. It is **not** a
feature tour, configuration wizard, productivity setup flow, or
workspace registration process. Introduce the emotional value of Athar
first; progressively disclose complexity later in-product.

Full spec: `ONBOARDING_AB_SPEC.md`. Routing via new
`OnboardingVariantService` + new `SharedPreferences` key
`onboarding_variant`. The existing `onboarding_seen` key still gates
whether onboarding shows at all.

---

## F · Map of every assumption change → spec file impact

| Spec file | What needs updating |
|---|---|
| `CLAUDE_CODE_PROMPT.md` | Replace `prayerCardVariant` → reuse `prayerCardDisplayMode`; drop "create Habit.type"; convert "build Stats/Tasks/Spaces" to "redesign"; drop "create `lib/features/onboarding/`"; add adhan-asset gate; add `themeMode.system` wiring; carve PR4 into PR4a + PR4b; rewrite PR10 as PR-CLEANUP scoped. |
| `REDESIGN_AUDIT.md` | §10 Onboarding — change from "NET-NEW feature" to "Refactor in place at `features/home/presentation/pages/onboarding_page.dart` (4 slides, `SharedPreferences` flag `onboarding_seen`)". §5 Calendar — split into 5a visual + 5b dual-display rebuild. §7 Stats — note cubit + repo are stubs (still true), but feature folder + page exist. |
| `PACKAGE_C_DECISIONS.md` | Add C1–C5 decisions if not already captured. |
| `PRAYER_CARD_SPEC.md` | Rename `prayerCardVariant` → use existing `prayerCardDisplayMode`; document compact/expanded as widget-local state. |
| `CALENDAR_CELL_SPEC.md` | Add note that current widget is toggle-based; rebuild scope = `DualDate` VO + new `CalendarCell` + `DualMonthSwitcher`. |
| `IOS_WIDGETS_SPEC.md` | Confirm App Group `group.com.iappsnet.athar` and existing `WidgetKeys`. Add habit-widget empty-state requirement (open question E3). |
| `THEME_DARK_SPEC.md` | Add "Auto mode follows system" — three-way: `isAutoModeEnabled` overrides `isDarkMode`. |

The prompt and audit have been updated in this round; the remaining spec edits are tracked but minor and can land alongside the implementation.
