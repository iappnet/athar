# PR-THEME Implementation Preview

**Prepared:** 2026-05-09  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Prerequisite:** PR1 complete ✅ (`athar-v2-pr1-complete` at `72f902d`)  
**Status:** READY TO IMPLEMENT — pending approval phrase below

---

## Investigation Results

### Q1 — Where is `isAutoModeEnabled` stored?

`isAutoModeEnabled` is a field on `UserSettings` (Isar model at
`lib/features/settings/data/models/user_settings.dart:22`).

**⚠️ CRITICAL NAMING COLLISION DISCOVERED:**  
`UserSettings.isAutoModeEnabled` is **NOT** a theme setting. It controls
**Smart Zones auto-scheduling** (used in `smart_zone_helper.dart:9`,
`prayer_conflict_service.dart:97`, `task_cubit.dart:236`).

The handoff document decision B2 (locked 2026-05-07) states:
> "PR-THEME uses `UserSettings.isAutoModeEnabled`"

This is incorrect. That field is the Smart Zones auto mode toggle —
reusing it for theme mode would silently break prayer conflict detection
and task auto-scheduling for all users. The field must not be used for
theme wiring.

**Resolution:** Two implementation options identified. See Options A and B below.

---

### Q2 — Where is `isAutoModeEnabled` changed in Settings UI?

`isAutoModeEnabled` is changed in `smart_zones_page.dart:67` via
`_buildAutoModeSwitch`. It is not in `general_settings_page.dart`.
It has no connection to theme.

---

### Q3 — Where is `isDarkMode` changed?

`general_settings_page.dart:78–85` — a `_SwitchTile` in the Appearance
section calls `SettingsCubit.toggleDarkMode(v)`.

---

### Q4 — How does SettingsCubit persist theme changes?

`settings_cubit.dart:359–367` — `toggleDarkMode(bool enabled)`:
- Reads current settings from `_repository.getSettings()`
- Sets `currentSettings.isDarkMode = enabled`
- Calls `_repository.updateSettings(currentSettings)`
- Persisted to Isar local DB; `SettingsState` stream emits update

---

### Q5 — How does `app.dart` currently read theme state?

`app.dart:162–172`:
```dart
final isDark = settingsState is SettingsLoaded
    ? settingsState.settings.isDarkMode
    : false;
// ...
themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
```

Currently: `isDarkMode=false` → force light. `isDarkMode=true` → force dark.  
`ThemeMode.system` is never used. The device OS dark mode setting has zero effect.

---

### Q6 — Does Settings UI already show "Follow System"?

No. The Appearance section has only one toggle: **Dark Mode** (on/off).
There is no "Follow System" / "حسب النظام" option for theme.

Note: The `systemMode` ARB key **already exists** in both ARB files
(`app_en.arb:162` = "System Default", `app_ar.arb:168` = "حسب النظام")
and is currently used for the Language picker. It is reusable.

---

### Q7 — Does manual dark toggle exist?

Yes. `general_settings_page.dart:78–85` — `_SwitchTile` with
`l10n.darkMode` title, bound to `isDarkMode`. This is the **only**
appearance control.

---

### Q8 — Does generated localization require `gen-l10n`?

**Option A (recommended):** No new ARB keys → `gen-l10n` not required.  
**Option B:** Adds one new ARB key → `gen-l10n` must be run after.

---

### Q9 — Are there any tests around theme settings?

No. `test/` contains only:
- `test/features/stats/stats_helpers_test.dart`
- `test/widget_test.dart`

No settings tests, no theme tests. PR-THEME must verify manually.

---

### Q10 — Does PR-THEME require `build_runner`?

**Option A (recommended):** No — zero Isar model changes.  
**Option B:** Yes — adds a new `bool` field to `UserSettings` (Isar model),
which requires `flutter pub run build_runner build --delete-conflicting-outputs`.

---

## Current Behavior

```
app.dart:172  themeMode: isDark ? ThemeMode.dark : ThemeMode.light
                                                    ↑
                                          Always forces light
```

- App ignores device OS dark/light mode setting entirely
- Users can force dark via Settings toggle
- Users cannot opt into "follow system"
- `isDarkMode = false` = hard light mode
- `ThemeMode.system` is never passed to `MaterialApp`
- Dark palette from PR1 is correct and ready but never activates for
  system-dark users

---

## Target Behavior

```
app.dart:172  themeMode: isDark ? ThemeMode.dark : ThemeMode.system
                                                    ↑
                                          Follow device OS setting
```

- `isDarkMode = false` (default) → `ThemeMode.system` → follows device
- `isDarkMode = true` → `ThemeMode.dark` → forced dark override
- Device switches light↔dark → app responds without restart
- Settings toggle stays as-is; label/subtitle clarified to reflect new behavior

---

## Proposed Implementation — Option A (RECOMMENDED)

### Why Option A

- Zero new Isar fields → no `build_runner` needed
- Minimal blast radius: one line in `app.dart` + one subtitle change in settings
- One-line rollback
- No risk to Smart Zones (`isAutoModeEnabled` is untouched)
- `isDarkMode = true` users are unaffected (still forced dark)

### Files to Modify

| File | Change |
|------|--------|
| `lib/app.dart` | Line 172: change `ThemeMode.light` → `ThemeMode.system` |
| `lib/features/settings/presentation/pages/general_settings_page.dart` | Add subtitle to Dark Mode switch to clarify "off = follow system" behavior |

### No files required:
- `lib/l10n/app_en.arb` — no new keys (reuses `systemMode` via subtitle pattern)
- `lib/l10n/app_ar.arb` — no new keys
- No `gen-l10n` run required
- No `build_runner` run required
- No new Dart files

---

## Exact Proposed Diffs — Option A

### `lib/app.dart` (line 172)

**Before:**
```dart
themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
```

**After:**
```dart
themeMode: isDark ? ThemeMode.dark : ThemeMode.system,
```

That is the entire change in `app.dart`.

---

### `lib/features/settings/presentation/pages/general_settings_page.dart` (lines 78–85)

**Before:**
```dart
_SwitchTile(
  icon: Icons.dark_mode_outlined,
  iconColor: const Color(0xFF5C35C9),
  title: l10n.darkMode,
  value: settings?.isDarkMode ?? false,
  onChanged: (v) =>
      context.read<SettingsCubit>().toggleDarkMode(v),
),
```

**After:**
```dart
_SwitchTile(
  icon: Icons.dark_mode_outlined,
  iconColor: const Color(0xFF5C35C9),
  title: l10n.darkMode,
  subtitle: l10n.darkModeDesc,
  value: settings?.isDarkMode ?? false,
  onChanged: (v) =>
      context.read<SettingsCubit>().toggleDarkMode(v),
),
```

This requires adding `darkModeDesc` to both ARB files (one new key each).
**If the designer prefers no subtitle**, this second change can be skipped —
only the `app.dart` line is strictly required for correct behavior.

---

## Localization Keys to Add (Option A with subtitle)

### `app_en.arb` — add after `darkMode` key:
```json
"darkModeDesc": "Off follows your device appearance",
```

### `app_ar.arb` — add after `darkMode` key:
```json
"darkModeDesc": "حسب إعداد الجهاز عند التعطيل",
```

**If subtitle is skipped**, no ARB changes are needed and `gen-l10n` is not run.

---

## Alternative — Option B (Requires `build_runner`)

Not recommended for PR-THEME. Documented for completeness.

**What it adds:**
- New `bool isFollowSystemTheme = true` field to `UserSettings` (Isar model)
- New `toggleFollowSystemTheme(bool)` method in `SettingsCubit`
- New Settings toggle in Appearance section
- `app.dart` reads both `isFollowSystemTheme` and `isDarkMode`
- `build_runner` required after model change
- New ARB key: `followSystemTheme` + description

**Why deferred:**
- `build_runner` adds build complexity and risk in a PR meant to be one line
- Naming collision with existing `isAutoModeEnabled` field adds confusion
- Option A achieves the same observable behavior with zero new fields
- A true three-state (light / system / dark) UX belongs in PR5 (Accessibility settings)

---

## UI Behavior Change

| Scenario | Before PR-THEME | After PR-THEME |
|----------|----------------|----------------|
| Device: light, `isDarkMode=false` | App: light | App: light ✅ same |
| Device: dark, `isDarkMode=false` | App: light (ignores OS) | App: dark ✅ follows OS |
| Device: dark, `isDarkMode=true` | App: dark | App: dark ✅ same |
| Device: light, `isDarkMode=true` | App: dark | App: dark ✅ same |
| User toggles device to dark mid-session | No change | App switches ✅ live |

---

## Edge Cases

| Case | Handling |
|------|----------|
| `SettingsLoaded` not yet emitted (loading) | `isDark = false` → `ThemeMode.system` — identical to current default |
| User on iOS with "Auto" appearance | `ThemeMode.system` correctly follows iOS schedule |
| User on Android with scheduled dark mode | `ThemeMode.system` correctly follows Android schedule |
| Prayer card on new dark background (`0xFF0E1714`) | Must visually verify navy gradient contrast — may be acceptable or require later adjustment in PR3 |
| `isDarkMode=true` users after update | No behavior change — still forced dark |
| Fast toggle from dark→light on device | `MaterialApp` rebuilds via `BlocBuilder` on `SettingsCubit` stream — no restart needed |

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Prayer card gradient contrast on dark background | Low | The navy `prayerCardGradient` (`[0xFF1E293B, 0xFF0F172A]`) against `background = 0xFF0E1714` — visually similar. Screenshot required. If unacceptable, defer gradient fix to PR3. |
| No "force light" option removed | Very Low | Most users use system default. Power users can still force dark via toggle. Explicit light-force belongs in PR5 accessibility. |
| Subtitle text copy not reviewed by designer | Low | Designer must approve Arabic `darkModeDesc` before subtitle is shipped. If no approval, skip subtitle — app.dart change alone is sufficient. |
| `isAutoModeEnabled` confusion | Low | The naming collision is fully documented. PR-THEME must NOT touch `isAutoModeEnabled`. |
| Existing `isDarkMode=true` users | None | Behavior unchanged for forced-dark users. |
| No regression tests exist | Medium | Must validate manually: light mode unchanged, dark mode activates on dark-system device, toggle still persists. Screenshot checklist required. |

---

## Rollback Plan

PR-THEME is a single-argument change. Rollback is one line:

```dart
// Revert app.dart:172
themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
```

If ARB keys were added, remove `darkModeDesc` from both ARB files and re-run `gen-l10n`.

Git rollback: `git revert <pr-theme-commit>` or `git checkout athar-v2-pr1-complete -- lib/app.dart`.

---

## Validation Plan

### Before implementation
- [ ] Confirm `flutter analyze` baseline is 0 issues

### After implementation
- [ ] `flutter analyze` → 0 issues
- [ ] `flutter test` → all 29 tests green
- [ ] Simulator: light mode — no visual change from pre-PR-THEME
- [ ] Simulator: switch OS to dark → app responds correctly
- [ ] Simulator: dark mode toggle ON in Settings → force dark regardless of OS
- [ ] Simulator: dark mode toggle OFF in Settings → follow OS
- [ ] Prayer card gradient renders acceptably on dark background (screenshot)
- [ ] All text is readable in dark mode (spot check key screens)
- [ ] Arabic RTL screens in dark mode (spot check)

---

## Screenshot Checklist

| Screen | Light mode | Dark mode |
|--------|-----------|-----------|
| Dashboard / Main page | ✅ no change | ✅ must check |
| Prayer card | ✅ no change | ✅ navy gradient on dark bg |
| Settings page | ✅ no change | ✅ subtitle legible |
| Task page | ✅ no change | ✅ must check |
| Habit page | ✅ no change | ✅ must check |
| Arabic (RTL) dashboard | ✅ no change | ✅ must check |

---

## Tests to Run

```bash
flutter analyze          # must be 0 issues
flutter test             # must be 29/29 green
```

No new tests are required for this PR (one-line change). However, a
basic widget test for `themeMode` behavior would be valuable — deferred
to the test debt backlog.

---

## Scope Confirmation — No Scope Creep

PR-THEME is strictly:

| In scope | Out of scope |
|----------|-------------|
| `app.dart:172` one-line change | Navigation, routing, onboarding |
| `general_settings_page.dart` subtitle (optional) | Calendar, widgets, prayer architecture |
| ARB keys for subtitle (optional) | Any new cubit, repository, or domain class |
| No `build_runner` | `adaptive_scaffold.dart` rename (PR2) |
| No new Dart files | Any feature from PR2 onward |
| No `isAutoModeEnabled` changes | Smart Zones, prayer hierarchy |

---

## Canonical Sequence Position

```
PR1 ✅  →  PR-THEME (this PR)  →  PR2 (blocked until this merges)
```

PR2 (AdaptiveShell + nav bar) is fully blocked on PR-THEME. Completing
PR-THEME unblocks the entire remaining 12-PR sequence.

---

## Post-PR-THEME Required Actions

1. Git tag: `athar-v2-prtheme-complete`
2. Update `IMPLEMENTATION_SESSION_STATE.md` — PR-THEME complete
3. Update `IMPLEMENTATION_MASTER_STATUS.md` — PR-THEME status → ✅
4. Update `PROGRAM_IMPLEMENTATION_STATUS.md` — PR-THEME status → ✅
5. Update `docs/progress/current_project_status.md`
6. Create change log: `docs/ai/change-logs/CHANGE_LOG_2026-05-09_<time>.md`
7. Run designer screenshot review before starting PR2

---

## PR-THEME Is Safe to Implement

**Yes. Safe.** Conditions met:

- PR1 prerequisite complete ✅
- No blockers ✅
- No `build_runner` required (Option A) ✅
- One-line core change with one-line rollback ✅
- No structural changes to architecture ✅
- No risk to prayer hierarchy, Smart Zones, or widget infrastructure ✅
- `isAutoModeEnabled` naming collision is understood and avoided ✅
- Dark tokens from PR1 are correct and ready ✅

---

## Approval Phrase

To start implementation, reply with:

> **"Implement PR-THEME"**
