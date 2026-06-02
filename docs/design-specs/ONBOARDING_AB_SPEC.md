# Onboarding — four variants for A/B testing

> Goal: ship four onboarding flows side-by-side, route users to one
> deterministically, measure activation, then promote the winner.
> The existing 4-slide flow stays as the **canonical behavioral
> baseline (Variant A)** and is not touched. Three new variants are
> added: **Existing-Restyled (B)**, **Short (C)**, and **Expanded (D)**.

> **Locked 2026-05-07.** Variant A is the UX authority. Variants B/C/D
> may modernize visuals and onboarding depth but must not silently
> regress pacing, emotional flow, clarity, simplicity, calmness,
> spiritual atmosphere, or immersive feel. Any behavioral deviation
> from A must be explicitly documented, justified, and approved.

---

## TL;DR

| Variant | Slides | Purpose | Asks for permissions / data? |
|---|---|---|---|
| **A · Existing (control)** | 4 | Untouched canonical baseline. Behavioral authority. | No |
| **B · Existing-Restyled** | 4 | Visual modernization only. Same structure / pacing / nav / behavior as A. | No |
| **C · Short** | 2 | Ultra-low-friction entry: features intro → Get Started. | No |
| **D · Expanded** | 6 | Lightweight progressive setup. Must stay calm and emotionally grounded. | Yes (location, notifications) |

All four persist completion via the **existing** `SharedPreferences` key
`onboarding_seen`. We add one new key — `onboarding_variant` — to
remember which variant a user saw, so analytics can attribute activation.

---

## Onboarding philosophy (applies to all variants)

Athar onboarding must feel:
- calm
- immersive
- emotionally grounded
- spiritually respectful
- lightweight
- personal-first
- focused

NOT:
- enterprise-heavy
- productivity-overwhelming
- setup-heavy
- configuration-driven
- workspace-first

Onboarding should introduce the **emotional value** of Athar first,
avoid excessive feature explanation, avoid cognitive overload, and
progressively disclose complexity **later in-product** rather than
front-loading it during first-run.

The app should feel welcoming, not demanding. Onboarding is not a
feature tour, configuration wizard, productivity setup flow, or
workspace registration process.

---

## Variant A — Existing (control, untouched)

**Status:** completely unchanged. This is the live flow and the
canonical behavioral baseline. **Do not modify any aspect of it** — no
UX, no behavioral, no pacing, no navigation, no structural, no visual
changes.

- Page: `lib/features/home/presentation/pages/onboarding_page.dart`
- 4 slides, defined in `_buildSlides()` at line 51.
- Persisted via `SharedPreferences` key `onboarding_seen`.
- Routed in `app.dart:187–189`.

This variant remains the **fallback** for any user where variant
assignment fails or the variant key is missing.

---

## Variant B — Existing-Restyled (4 slides, visuals only)

**Hypothesis:** The existing flow's structure is correct, but its
visuals predate the new Athar brand system. A visual modernization
alone may improve activation without changing UX architecture.

**Hard constraint:** Preserve **exactly** the existing onboarding's
structure, pacing, transitions, behavior, and navigation flow. Only
the visual layer is touched. This is a visual modernization, not a
behavioral rewrite.

### What is preserved (must not change)

- Slide count (4) and slide order
- Slide content / copy logic
- Pacing and transition timing
- Navigation flow (Continue / Skip / final CTA)
- `onboarding_seen` persistence behavior
- Empty-state continuation logic on first dashboard load

### What changes

- Apply new Athar tokens (`AppColors.brand.forest` etc.)
- **Calibri** is the sole canonical brand font for both Arabic and English (Light 300 / Regular 400 / Bold 700)
- Improved spacing per `AppSpacing` tokens
- Improved typography hierarchy
- Improved visual polish (shadows, radii, surface treatments)
- More immersive background presentation per slide

### Files

```
lib/features/home/presentation/pages/onboarding_restyled_page.dart   // new
lib/features/home/presentation/widgets/onboarding_restyled/
    slide_01_tasks_habits.dart
    slide_02_prayer_dhikr.dart
    slide_03_focus_productivity.dart
    slide_04_get_started.dart
```

The 4 slide widgets mirror exactly the 4 `_SlideData` items in the
existing `onboarding_page.dart:51` `_buildSlides()` method. Same
titles, same subtitles (sourced via ARB), same CTA placement.

### Wiring

- Tapping the final CTA writes `onboarding_seen = true` and
  `onboarding_variant = 'existing_restyled'`, then routes to `/login`
  (matching Variant A's actual destination — not SplashPage; corrected
  2026-06-02 per OQ3 ruling).
- Skip behavior matches Variant A exactly.

---

## Variant C — Short (2 slides)

**Hypothesis:** Users abandon long onboarding. Two slides — features
intro and Get Started — get them to the dashboard fastest, where the
empty states do the teaching.

### Files

```
lib/features/home/presentation/pages/onboarding_short_page.dart      // new
lib/features/home/presentation/widgets/onboarding_short/
    slide_01_welcome.dart
    slide_02_get_started.dart
```

### Slides

#### 01 · Welcome + key Athar features
| Element | Spec |
|---|---|
| Background | Forest green (`AppColors.brand.forest`), radial highlight top-right |
| Hero mark | Athar logo, 96pt, cream tint |
| Headline | `t.onboarding_short.welcome.title` — "أهلاً بك في أثر / Welcome to Athar" |
| Subhead | `t.onboarding_short.welcome.subtitle` — one line. "Tasks, prayer, focus — in one place." |
| Feature row | 3 small icons + 1-word labels: Tasks · Prayer · Focus (calm, no chrome) |
| Primary CTA | `AppButton.primary` — "Continue / متابعة" |

#### 02 · Get Started
| Element | Spec |
|---|---|
| Background | Forest green, calm |
| Headline | `t.onboarding_short.start.title` — "Let's begin / لنبدأ" |
| Subhead | `t.onboarding_short.start.subtitle` — "Your day, gently organized." |
| Primary CTA | `AppButton.primary` — "Get Started / ابدأ" |
| Secondary | Skip link (same destination, just no completion event) |

### Wiring

- Tapping the final CTA writes `onboarding_seen = true` and
  `onboarding_variant = 'short'`, then routes to `/login` (corrected
  2026-06-02 per OQ3 ruling — all variants use Variant A's actual
  destination).
- No location / notifications / module prompts — those are deferred to
  the empty-state cards on the relevant pages (e.g. the prayer card
  shows "Set your location" when no location is set).

### Out of scope

- Permission prompts.
- Module toggles.
- Space creation.

---

## Variant D — Expanded (6 steps, lightweight + calm)

**Hypothesis:** Users who complete a guided setup have higher D7
retention because the app is configured for them out of the gate.

**Hard constraint:** The expanded flow must remain **lightweight and
emotionally calm**. It must not feel like a configuration wizard. Each
step is a single decision with skip-by-default friendliness. Total
flow time target: under 90 seconds for a user who skips optional
steps.

### Files

```
lib/features/home/presentation/pages/onboarding_expanded_page.dart       // new — PageView host
lib/features/home/presentation/widgets/onboarding_expanded/
    01_welcome_step.dart
    02_modules_step.dart
    03_location_step.dart
    04_notifications_step.dart
    05_space_step.dart
    06_finish_step.dart
```

All 6 widgets are slides inside the same `PageView`. Step state lives
in local widget state (no new cubit needed); writes go directly
through `SettingsCubit`, `LocaleCubit`, and the existing permission
services.

### Steps

#### 01 · Welcome
- Same calm look as Variant C's welcome slide, but with a "Continue" CTA.
- No data collected. Pure emotional intro.

#### 02 · Modules
- Title: "What do you want Athar to help with? / فيم تريد أن يساعدك أثر؟"
- **Corrected 2026-06-02 (OQ1 ruling):** Only 2 real toggles + 2 always-included chips.
  No new UserSettings fields (spec previously listed 6 toggles; 4 of them had no
  backing field — OQ1 resolved as cosmetic/chips-only for Tasks+Habits, not shown
  for Health+Assets).
  - **Prayer** — real toggle, default ON; writes `isPrayerEnabled` via
    `SettingsCubit.togglePrayerEnabled()` with Phase 8.1 cascade.
  - **Dhikr / Athkar** — real toggle, default OFF (locked decision); writes
    `isAthkarEnabled` via `SettingsCubit.toggleAthkarEnabled()`.
  - **Tasks** — always-included non-interactive chip (no flag write). Shown dim.
  - **Habits** — always-included non-interactive chip (no flag write). Shown dim.
  - **Health & Appointments** — NOT shown in onboarding.
  - **Assets** — NOT shown in onboarding.
- Skip allowed; defaults persist.

#### 03 · Location (only if Prayer module is ON)
- If Prayer was toggled OFF in step 02, **skip this step entirely** (the PageView advances past it).
- Title: "Set your location for accurate prayer times / حدّد موقعك"
- Two CTAs:
  - "Use current location" → triggers `geolocator` permission, writes `latitude`, `longitude`, `cityName` to UserSettings.
  - "Enter manually" → opens an inline city picker (existing `LocationSettingsPage` widget reuse).
- Skip allowed; PrayerCubit will show empty-location state.

#### 04 · Notifications
- Title: "Stay on track / لا تفوّت شيئاً"
- Subhead names the channels gently: prayer, tasks, habits, appointments.
- Single CTA: "Allow notifications" → triggers iOS/Android permission prompt via `flutter_local_notifications.requestPermissions()`.
- No inline channel toggles in this step (those live in Settings, not onboarding) — keeps the step single-decision.
- Skip allowed; permissions can be granted later from Settings.

#### 05 · Space (LIGHTWEIGHT, NOT WORKSPACE-FIRST)

**Locked decision:** Athar is personal-first, not collaboration-first.
This step **must not feel like enterprise workspace registration.**
Spaces complexity is reduced and pre-decided.

- Title: "Where will you work? / أين ستعمل؟"
- **"Just for me" is pre-selected by default** as a calm progressive-disclosure step.
- Two visible options:
  - **"Just for me"** (pre-selected) — creates a default personal space silently. No name input.
  - "Have a code? Join with a code" — collapsed link below; expands an inline code input on tap → calls `JoinSpaceCubit.joinSpace(token)` (corrected 2026-06-02; spec previously said `joinByCode` — actual method name is `joinSpace`).
- **"Create a shared space" is removed** from onboarding. Users who want to create a shared space discover it in-product later.
- Single primary CTA: "Continue / متابعة".
- Skip allowed; default personal space is created automatically either way.

#### 06 · Finish
- Title: "You're all set / كل شيء جاهز"
- Calm bullet recap of what was configured in steps 02–05 (dynamic — only shows what was actually set, no "you skipped X" guilt).
- Primary CTA: "Open Athar / افتح أثر" → writes `onboarding_seen = true`, `onboarding_variant = 'expanded'`, navigates to dashboard.

### Backwards compatibility

- Every write in steps 02–05 uses **existing** UserSettings fields and
  cubits. No schema changes.
- If the user backgrounds the app mid-flow, partial state persists
  (because we wrote through cubits) but `onboarding_seen` stays
  `false`, so they re-enter at step 01 next launch. Acceptable for v1.

---

## A/B/C/D routing

### Variant assignment

A new helper at `lib/core/services/onboarding_variant_service.dart`:

```dart
enum OnboardingVariant { existing, existingRestyled, short, expanded }

class OnboardingVariantService {
  static const _key = 'onboarding_variant';
  final SharedPreferences _prefs;

  OnboardingVariantService(this._prefs);

  /// Returns the variant for this user, assigning one on first call.
  OnboardingVariant assignOrGet() {
    final stored = _prefs.getString(_key);
    if (stored != null) {
      return OnboardingVariant.values.firstWhere(
        (v) => v.name == stored,
        orElse: () => OnboardingVariant.existing,
      );
    }
    // 25/25/25/25 split, deterministic per device.
    final hash = _prefs.getString('device_id')?.hashCode ?? 0;
    final bucket = (hash % 4).abs();
    final assigned = OnboardingVariant.values[bucket];
    _prefs.setString(_key, assigned.name);
    return assigned;
  }
}
```

### Routing in `main.dart` / `app.dart`

Replace the current `hasSeenOnboarding ? Splash : Onboarding` switch with:

```dart
final hasSeenOnboarding = await OnboardingPage.hasBeenSeen();
final variant = OnboardingVariantService(prefs).assignOrGet();

home: hasSeenOnboarding
    ? const SplashPage()
    : switch (variant) {
        OnboardingVariant.existing         => const OnboardingPage(),         // unchanged
        OnboardingVariant.existingRestyled => const OnboardingRestyledPage(),
        OnboardingVariant.short            => const OnboardingShortPage(),
        OnboardingVariant.expanded         => const OnboardingExpandedPage(),
      },
```

### Forced override (developer + QA)

For testing, allow overriding via env or developer settings page:

- `flutter run --dart-define=ONBOARDING_VARIANT=existing|existing_restyled|short|expanded` overrides the assigned variant.
- A hidden developer settings tile ("Reset onboarding") clears `onboarding_seen` and `onboarding_variant`, then restarts the app.

---

## Analytics — Supabase events only

**Locked decision:** Use **Supabase events only**. Do not add Firebase,
Mixpanel, or any other analytics SDK unless one is already present in
the live Flutter app. Keep analytics lightweight and
implementation-safe.

Emit one event per onboarding lifecycle, written to a Supabase
`analytics_events` table (or whichever table the app already uses for
event logging — Claude Code investigates and adopts that existing
table; if none exists, creates `onboarding_events` with the schema
below):

| Event | When | Properties |
|---|---|---|
| `onboarding_started` | First slide rendered | `variant: existing | existing_restyled | short | expanded` |
| `onboarding_step_completed` | (Expanded only) | `variant: expanded`, `step: 01..06` |
| `onboarding_step_skipped` | (Expanded only) | `variant: expanded`, `step: 02..05` |
| `onboarding_completed` | Final slide CTA tapped | `variant`, `duration_ms`, `permissions_granted: { location, notifications }` |
| `onboarding_abandoned` | App backgrounded mid-flow without completion | `variant`, `last_step` |

### Suggested Supabase schema (only if no existing analytics table)

```sql
create table public.onboarding_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade,
  device_id text,
  event_name text not null,
  variant text not null,
  properties jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);
create index on public.onboarding_events (user_id, created_at desc);
create index on public.onboarding_events (variant, event_name);
```

If the app already has an analytics table, append these events to it.
Claude Code's investigation step decides; do not introduce a new SDK.

### Success metrics

- **Activation:** % users who complete onboarding within 5 min of install.
- **D1 retention:** % active on day 1.
- **D7 retention:** % active on day 7.
- **Setup completeness** (expanded only): % who set location, % who allow notifications.

After 2 weeks of equal traffic split (or N=1000 per variant, whichever
comes first), the winner promotes to default; the others ship behind a
feature flag for revertibility.

---

## ARB additions

New keys per variant. All keys have `_ar` and `_en`. Variant A reuses
the existing onboarding keys (no new ARB needed). Variant B reuses
Variant A's keys exactly (it's the same copy, restyled).

```
onboarding_short.welcome.title
onboarding_short.welcome.subtitle
onboarding_short.welcome.feature_tasks
onboarding_short.welcome.feature_prayer
onboarding_short.welcome.feature_focus
onboarding_short.welcome.cta
onboarding_short.start.title
onboarding_short.start.subtitle
onboarding_short.start.cta
onboarding_short.skip

onboarding_expanded.welcome.title
onboarding_expanded.welcome.subtitle
onboarding_expanded.welcome.cta

onboarding_expanded.modules.title
onboarding_expanded.modules.subtitle
onboarding_expanded.modules.tasks_label
onboarding_expanded.modules.habits_label
onboarding_expanded.modules.prayer_label
onboarding_expanded.modules.dhikr_label
onboarding_expanded.modules.health_label
onboarding_expanded.modules.assets_label
onboarding_expanded.modules.continue_cta

onboarding_expanded.location.title
onboarding_expanded.location.subtitle
onboarding_expanded.location.use_current_cta
onboarding_expanded.location.enter_manually_cta
onboarding_expanded.location.skip

onboarding_expanded.notifications.title
onboarding_expanded.notifications.subtitle
onboarding_expanded.notifications.allow_cta
onboarding_expanded.notifications.skip

onboarding_expanded.space.title
onboarding_expanded.space.subtitle
onboarding_expanded.space.just_me_cta
onboarding_expanded.space.join_code_cta

onboarding_expanded.finish.title
onboarding_expanded.finish.subtitle
onboarding_expanded.finish.cta
onboarding_expanded.finish.recap_modules
onboarding_expanded.finish.recap_location
onboarding_expanded.finish.recap_notifications
onboarding_expanded.finish.recap_space
```

---

## PR plan

This work is one ticket, not four, because it's a coordinated A/B
rollout.

### PR-ONBOARD-AB

1. Add `OnboardingVariantService`.
2. Add `OnboardingRestyledPage` + 4 slide widgets (mirroring existing structure exactly).
3. Add `OnboardingShortPage` + 2 slide widgets.
4. Add `OnboardingExpandedPage` + 6 step widgets.
5. Update routing in `main.dart` / `app.dart`.
6. Add ARB keys (en + ar).
7. Add Supabase event emitters (no new SDK).
8. Add hidden developer "Reset onboarding" tile.
9. **Do not touch** `onboarding_page.dart` — it's the control.

### Acceptance

- All four variants reachable via `--dart-define=ONBOARDING_VARIANT=…`.
- Default routing produces ~25% per variant on fresh installs.
- Supabase events fire for every variant.
- Skipping every optional step in Variant D still completes successfully.
- Variant B is **structurally indistinguishable** from Variant A — same slide count, same copy, same nav, same pacing — only visuals differ.
- Variant D feels calm and lightweight, never enterprise-heavy.
- A user who saw Variant C and uninstalled gets the same variant on reinstall **only if** `device_id` is stable; otherwise reassigned. (Document this caveat — it's expected.)

---

## Variant governance — what may differ from Variant A

| Aspect | A (control) | B (restyled) | C (short) | D (expanded) |
|---|---|---|---|---|
| Slide count | 4 | 4 (same) | 2 | 6 |
| Copy | original | original (same) | new | new |
| Visuals | original | new tokens | new tokens | new tokens |
| Pacing | original | match A exactly | faster | match A's calm pace |
| Permission prompts | none | none | none | location + notifications |
| Module toggles | none | none | none | yes (lightweight) |
| Space step | none | none | none | yes (pre-selected "Just for me") |

Any behavioral deviation in B/C/D from Variant A's calm, low-friction,
spiritually-respectful feel must be flagged in the PR description and
approved before merge.

---

## Open questions for the designer

1. ~~Existing 4-slide content — restyle or leave?~~ **Locked:** Variant A untouched; Variant B is the restyled version with same structure.
2. ~~Variant C step 02 — Dhikr default ON or OFF?~~ **Locked:** OFF.
3. ~~Variant D step 05 — pre-select "Just for me"?~~ **Locked:** Yes, pre-selected; "Create shared space" removed from onboarding entirely.
4. ~~Analytics destination?~~ **Locked:** Supabase events only.
5. **Open:** Should Variant B's hero animations (Lottie / motion) be richer than Variant A's, or strictly visual-token parity? My take: strict parity — animation is part of pacing, and Variant B's hypothesis is "visuals only, behavior identical." Confirm.
