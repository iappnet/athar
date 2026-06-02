<!--
CANONICAL-FOR: PR-ONBOARD-AB audit — evidence-based gap analysis
OWNER:         Claude Code
LAST-UPDATED:  2026-06-02 · INFRA sign-off received — implementation in progress
LOADS-AT:      Tier 1 (load during PR-ONBOARD-AB implementation)
-->

# Audit — PR-ONBOARD-AB (4-Variant Onboarding A/B)

**Date:** 2026-06-02  
**Audit type:** Read-only. Zero Dart changes this session.  
**Spec:** `docs/design-specs/ONBOARDING_AB_SPEC.md` (502 lines, fully read)  
**Status:** ✅ INFRA SIGNED OFF — implementing PR-ONBOARD-AB-INFRA

---

## Designer Sign-Off — 2026-06-02

**Signed off by:** Designer (user message)  
**Scope approved:** PR split into INFRA + UI PRs.  
**OQ rulings locked:**

| OQ | Ruling |
|----|--------|
| OQ1 (module toggles) | Deferred to UI PR — not in INFRA scope |
| OQ2 (device_id) | UUID v4 generated once, stored under `'device_id'` in SharedPreferences in `main.dart` BEFORE `assignOrGet()`. `uuid` pkg confirmed present (`^4.5.3`). |
| OQ3 (Variant A routing) | Do NOT touch `onboarding_page.dart`. All 4 INFRA branches → `OnboardingPage`. Future variants route to `/login` (Variant A's actual destination). |
| OQ4 (joinByCode) | Implicit deferred to UI PR |
| OQ5 (analytics auth) | Nullable `user_id` + `device_id`. Insert-only RLS for anon on `onboarding_events`. If anon insert blocked, buffer locally + flush on first auth. Report which path Supabase client supports. |
| OQ6 (PR split) | Approved — INFRA first, UI second |

---

## Files Inspected

| File | Lines read | Purpose |
|------|-----------|---------|
| `docs/design-specs/ONBOARDING_AB_SPEC.md` | all 502 | Spec source of truth |
| `lib/features/home/presentation/pages/onboarding_page.dart` | all 493 | Variant A (control) scaffold |
| `lib/app.dart` | 175–214 | Routing + onboarding switch |
| `lib/main.dart` | full grep | device_id / analytics seeding |
| `lib/features/settings/data/models/user_settings.dart` | all 330 | Module flag field inventory |
| `lib/features/space/presentation/cubit/join_space_cubit.dart` | grep | JoinSpace method signature |
| `lib/features/space/presentation/cubit/space_cubit.dart` | grep | createSpace signature |
| `lib/features/settings/presentation/pages/location_settings_page.dart` | existence | Variant D step 03 reuse |
| `lib/core/services/notification_service.dart` | grep | requestPermissions signature |
| `lib/core/services/location_service.dart` | grep | Geolocator usage pattern |

---

## 1 · INFRA UNKNOWNS — Verdicts

### 1A · Supabase Analytics

**VERDICT: ABSENT — net-new infra required.**

Grep for `analytics`, `logEvent`, `trackEvent`, `supabase.*insert.*event` → zero Dart source matches (only false positive in `app_localizations_en.dart`). No `analytics_events` table, no event emitter, no client helper.

Spec provision: "if none exists, creates `onboarding_events` with the schema below."  
→ Applies. The `onboarding_events` table (SQL migration) + a thin Dart `OnboardingAnalyticsService` are net-new scope.

**Open question OQ5 (see §6):** onboarding fires before auth. Can Supabase client write unauthenticated rows? `user_id` nullable per spec schema, but anon-insert policy must be confirmed.

### 1B · device_id Stability

**VERDICT: ABSENT — blocker for A/B split correctness.**

`_prefs.getString('device_id')?.hashCode ?? 0` → returns `0` on all devices (the key is never written anywhere in the codebase).  
Result: `bucket = 0 % 4 = 0` → `OnboardingVariant.existing` always.  
**The entire A/B test silently assigns every user to Variant A.**

Fix required before PR ships: seed a stable `device_id` UUID into SharedPreferences at first run, before `OnboardingVariantService.assignOrGet()` is called.

Recommended approach: `package:device_info_plus` → `iosInfo.identifierForVendor` / `androidInfo.id`, stored once under key `device_id`. Must be seeded in `main.dart` before the onboarding check.

**OQ2 below** asks designer/PM to confirm this approach.

---

## 2 · Variant A Scaffold — Confirmed ✅

| Check | Evidence | Status |
|-------|----------|--------|
| 4 slides via `_buildSlides()` | `onboarding_page.dart:51` | ✅ Confirmed |
| `onboarding_seen` SharedPreferences key | `_kOnboardingSeen = 'onboarding_seen'` (file-private) | ✅ Confirmed |
| `_markSeen()` writes bool | `onboarding_page.dart:66` | ✅ Confirmed |
| Skip button RTL-safe | `AlignmentDirectional.topEnd` | ✅ Confirmed |
| PageView tap-to-advance pacing | `onboarding_page.dart` — right/left half gesture | ✅ Confirmed |

**Discrepancies vs. spec:**

| Spec claim | Actual | Severity |
|------------|--------|----------|
| Routing after complete: `SplashPage` | Actual: `/login` route | Medium — spec discrepancy |
| `app.dart:187-189` | Actual: ~line 200-202 | Low — line number drift |
| Visual: forest v2 palette | Actual: hardcoded blue `0xFF0D47A1` / purple `0xFF4A148C` | Intentional — control is pre-brand |
| Font: Calibri | Actual: `fontFamily: 'Cairo'` | Intentional — control is pre-brand |

**Ruling on Variant A scope:** The control is intentionally untouched (pre-brand design). Do NOT update its gradients or font — that would contaminate the A/B result. The `/login` routing discrepancy should be discussed in OQ3 before touching `onboarding_page.dart`.

---

## 3 · app.dart Routing — Current vs. Required

**Current** (`app.dart:200-202`):
```dart
home: widget.hasSeenOnboarding ? const SplashPage() : const OnboardingPage()
```

**Required** (spec):
```dart
final hasSeenOnboarding = await OnboardingPage.hasBeenSeen();
final variant = OnboardingVariantService(prefs).assignOrGet();
home: hasSeenOnboarding
    ? const SplashPage()
    : switch (variant) {
        OnboardingVariant.existing         => const OnboardingPage(),
        OnboardingVariant.existingRestyled => const OnboardingRestyledPage(),
        OnboardingVariant.short            => const OnboardingShortPage(),
        OnboardingVariant.expanded         => const OnboardingExpandedPage(),
      },
```

`hasSeenOnboarding` is currently passed as a constructor param to `MyApp`. The refactor moves the lookup inline. This is a clean change; the `hasBeenSeen()` static method needs to be exposed on `OnboardingPage` (or a shared helper).

---

## 4 · Variant D Dependency Inventory (steps 02–05)

### Step 02 — 6 Module Toggles

| Spec toggle | UserSettings field | Status |
|-------------|-------------------|--------|
| Tasks | None — no `isTaskEnabled` | ❌ MISSING |
| Habits | None — no `isHabitEnabled` | ❌ MISSING |
| Prayer | `isPrayerEnabled` (cascade per Phase 8.1) | ✅ EXISTS |
| Dhikr / Athkar | `isAthkarEnabled` | ✅ EXISTS |
| Health & Appointments | No master toggle — only reminder sub-toggles (`isMedicationNotificationsEnabled`, `isAppointmentRemindersEnabled`) | ❌ MISSING |
| Assets | No master toggle — only reminder sub-toggles (`isAssetRemindersEnabled`, etc.) | ❌ MISSING |

**Conflict with spec:** Spec §"Backwards compatibility" states *"Every write in steps 02–05 uses existing UserSettings fields and cubits. No schema changes."* But 4 of the 6 toggles have no corresponding master feature flag. Either:
- **(a)** The 4 toggles are cosmetic/informational only — they display in onboarding but do not write a boolean to UserSettings. Tasks and Habits are always-on; Health and Assets are always-available but default-hidden.
- **(b)** 4 new boolean fields must be added (`isTasksEnabled`, `isHabitsEnabled`, `isHealthEnabled`, `isAssetsEnabled`) — contradicts the "no schema changes" claim.

**OQ1 below** must be resolved before implementation. This is the largest architectural unknown.

### Step 03 — Location

| Dependency | Status | Details |
|-----------|--------|---------|
| `Geolocator.requestPermission()` | ✅ EXISTS | `lib/core/services/location_service.dart:18-21` |
| `latitude`, `longitude`, `cityName` on UserSettings | ✅ EXISTS | Lines 84-86 |
| `LocationSettingsPage` widget | ✅ EXISTS | `lib/features/settings/presentation/pages/location_settings_page.dart` |
| Prayer-skip gate | Net-new — no such conditional render exists today | ❌ New logic required |

### Step 04 — Notifications

| Dependency | Status | Details |
|-----------|--------|---------|
| `NotificationService.requestPermissions()` | ✅ EXISTS | `lib/core/services/notification_service.dart:46` |
| Return type: `Future<bool>` | ✅ | Matches spec's `permissions_granted.notifications` analytic property |

### Step 05 — Space

| Dependency | Status | Details |
|-----------|--------|---------|
| `SpaceCubit.createSpace(String name, {bool isShared = false})` | ✅ EXISTS | `space_cubit.dart:76` |
| "Just for me" silent creation | ✅ Feasible | `createSpace("مساحتي", isShared: false)` |
| Code join → inline input | ✅ Feasible | `JoinSpaceCubit` + `JoinSpaceScreen` exist |
| **Spec says** `JoinSpaceCubit.joinByCode` | ❌ METHOD NAME WRONG | Actual method: `joinSpace(String token)` — spec has wrong name; call `joinSpace(token)` directly |

---

## 5 · Scope Assessment

This is a large PR. Net-new items:

| Category | Items | Estimate |
|----------|-------|---------|
| New service | `OnboardingVariantService` | 1 file |
| New pages | `OnboardingRestyledPage`, `OnboardingShortPage`, `OnboardingExpandedPage` | 3 pages |
| Expanded steps | Steps 01–06 as sub-widgets | ~6 composable widgets |
| app.dart routing refactor | 1 site | Low-risk |
| device_id seeding in `main.dart` | 1 site | `device_info_plus` dep check needed |
| Analytics service | `OnboardingAnalyticsService` + Supabase call | 1 file + SQL migration |
| ARB additions | Short (6 keys) + Expanded (~30 keys), both AR+EN | ~72 new strings |
| Possible new UserSettings fields | 0–4 depending on OQ1 ruling | Requires `build_runner` pass |
| `flutter gen-l10n` pass | After ARB additions | Standard |

**Recommendation — PR split:**

> **PR-ONBOARD-AB is too large to ship as a single PR.** Recommend two PRs:
>
> **PR-ONBOARD-AB-INFRA** (first, unblocker):
> - device_id seeding in `main.dart` (or separate init helper)
> - `OnboardingVariantService` (no UI)
> - app.dart routing switch (4 branches, all pointing to `OnboardingPage` for now)
> - Supabase `onboarding_events` migration + thin `OnboardingAnalyticsService`
> - `flutter run --dart-define=ONBOARDING_VARIANT=...` override wiring
>
> **PR-ONBOARD-AB-UI** (second, after infra):
> - Variant B (restyled), Variant C (short), Variant D (expanded steps 01–06)
> - ARB additions
> - Module toggle resolution (pending OQ1)

---

## 6 · Open Questions (OQ) — Require Designer/PM Ruling

| ID | Question | Blocks |
|----|----------|--------|
| **OQ1** | **Module toggles (Tasks, Habits, Health, Assets):** are these cosmetic/informational only (no UserSettings write), or do 4 new boolean fields need to be added? Spec says "no schema changes" but no backing fields exist. | Entire Variant D step 02 |
| **OQ2** | **device_id seeding:** approve using `device_info_plus` (already a common Flutter dep — need to confirm it's in `pubspec.yaml`) to seed a stable UUID under key `device_id` in SharedPreferences at first run? Alternatives: UUID v4 generated once and stored (simpler, no native call). | A/B split correctness — blocker |
| **OQ3** | **Variant A completion route:** current code routes to `/login`; spec says `SplashPage`. Should Variant A stay as-is (control, untouched), or should its completion route be patched? Patching changes the control. | Variant A fidelity |
| **OQ4** | **JoinSpaceCubit method name:** spec says `joinByCode(token)` but actual method is `joinSpace(String token)`. Confirm implementation should call `joinSpace(token)` and the spec name is a typo. | Variant D step 05 |
| **OQ5** | **Analytics before auth:** onboarding fires before the user is authenticated. Can `onboarding_events` rows be inserted unauthenticated (nullable `user_id`, anon-insert RLS policy)? Or defer analytics until after auth and pass the variant key as context? | Analytics scope |
| **OQ6** | **PR split approval:** approve splitting into PR-ONBOARD-AB-INFRA + PR-ONBOARD-AB-UI? Or ship as one large PR? | Roadmap scheduling |

---

## 7 · Ruled Design Decisions (record-only, do not relitigate)

| Decision | Source |
|----------|--------|
| OQ5 (spec): Variant B = strict visual-token parity with v2 forest palette. Animation + pacing IDENTICAL to Variant A — no richer motion. | ONBOARDING_AB_SPEC.md §OQ5 |
| OQ2 (spec): Dhikr/Athkar default OFF during onboarding — do not auto-enable spiritual modules | ONBOARDING_AB_SPEC.md §Locked |
| Analytics: Supabase-only. No Firebase, Mixpanel, or other SDK | ONBOARDING_AB_SPEC.md §Analytics |
| Variant D step 05: "Create a shared space" removed from onboarding. Personal-first only. | ONBOARDING_AB_SPEC.md §05 |

---

## 8 · Implementation Notes (for when sign-off arrives)

- `OnboardingPage.hasBeenSeen()` must be exposed as a `static Future<bool>` (or move the SharedPreferences lookup to a shared `OnboardingService`).
- `device_info_plus` dep: check `pubspec.yaml` before adding — may already be present.
- Prayer cascade (Variant D step 02): when Prayer toggled ON, call `SettingsCubit.togglePrayer(true)` which already handles the 4-level cascade. Do NOT call sub-toggles directly.
- Variant D step 03 location: reuse `LocationService.determinePosition()` (already wraps Geolocator + permission). Do not call Geolocator directly from the page widget.
- Variant D step 05 "Just for me": `SpaceCubit.createSpace("مساحتي", isShared: false)` — Arabic name per existing `main_page.dart:561` pattern.
- ARB: Variant A + B share keys. Only Short + Expanded need new ARB keys (~72 new strings). Run `flutter gen-l10n` once after all keys added.
- `flutter analyze` must be clean before commit (0 errors; 2 pre-existing warnings acceptable).
