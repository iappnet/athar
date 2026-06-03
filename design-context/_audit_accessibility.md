# PR5 Accessibility Settings — Audit
Date: 2026-06-01
Status: SIGNED OFF ✅ — 2026-06-01

## Designer Sign-Off Notes

All 10 open questions resolved by design authority (2026-06-01):

1. Spec: `handoff_v2/PACKAGE_C_DECISIONS.md #4` (path corrected — handoff_v2/, not handoff_v2-2/).
2. Flag names confirmed: `reduceMotion`, `disableGyroscope`, `easternNumerals`.
3. Defaults: all three = `false`. `reduceMotion` OR'd with `MediaQuery.disableAnimations` is a PR8 consumer concern, not PR5.
4. Placement: dedicated "Accessibility" section, AFTER Security/Privacy, BEFORE Sync & Account.
5. Icons (Material rounded, implementer discretion): `reduceMotion` → `motion_photos_off`; `disableGyroscope` → `screen_rotation`; `easternNumerals` → `tag`.
6. `easternNumerals`: STORE + TOGGLE ONLY in PR5. Zero screen consumption. Numeral-conversion util may be added but no wiring.
7. `reduceMotion`: STORE + TOGGLE ONLY in PR5. No `OilBottleAnimation` wiring (deferred to PR8).
8. System Reduce-Motion OR: at the consumer (PR8), not PR5.
9. ARB strings: drafted in PR5 — designer reviews copy.
10. `easternNumerals` Arabic tile label: "الأرقام العربية".

---

## 1. Files Inspected

| Path | Lines Read | Notes |
|------|-----------|-------|
| `lib/features/settings/data/models/user_settings.dart` | 1–325 | Full file — UserSettings Isar model |
| `lib/features/settings/data/models/user_settings.g.dart` | 1–50 | Isar generated schema (partial) |
| `lib/features/settings/data/repositories/settings_repository_impl.dart` | 1–50 | Persistence pattern |
| `lib/features/settings/presentation/pages/general_settings_page.dart` | 1–1145 | Full file — main settings UI |
| `lib/features/settings/presentation/cubit/settings_cubit.dart` | 1–445 | Full file — cubit with all toggle methods |
| `lib/features/settings/presentation/cubit/settings_state.dart` | 1–43 | Full file — SettingsLoaded props list |
| `lib/features/settings/presentation/widgets/settings_body.dart` | 1–3 | Stub — only a comment, no content |
| `lib/features/focus/presentation/widgets/oil_animation.dart` | 1–444 | Full file — gyroscope + animation logic |
| `lib/features/focus/presentation/widgets/fluid_engine.dart` | 1–210 | Active code section (rest is commented out) |
| `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` | 1–60 | Partial — isHijriMode consumption confirmed |
| `design-context/_audit_design_system.md` | 1–30 | Partial — prior design audit reference |

**Spec files searched:**
- `handoff_v2-2/PACKAGE_C_DECISIONS.md` — NOT FOUND. Directory `handoff_v2-2/` does not exist in the project root. It is referenced in CLAUDE.md as a design authority but is absent from the repository.
- `handoff_v2-2/SKILL.md` — NOT FOUND (directory absent).
- `handoff_v2-2/COMPONENT_SPECS.md` — NOT FOUND (directory absent).
- No file with "Accessibility" in its name was found under `design-context/` or the project root.

**Consequence:** All accessibility decisions in this audit are derived from the Flutter codebase state alone. There is no designer spec to validate against for PR5. This is a blocker — see Section 9 (Open Questions).

---

## 2. Current Settings Structure

The effective settings UI lives entirely in:
`lib/features/settings/presentation/pages/general_settings_page.dart` (1145 lines)

`lib/features/settings/presentation/pages/settings_page.dart` is a stub (12 lines, `Center(child: Text('Settings Page'))`).
`lib/features/settings/presentation/widgets/settings_body.dart` is a stub (3 lines, comment only).

### Existing Sections (in render order)

| Section | Key | Widget Pattern |
|---------|-----|---------------|
| Profile card | hardcoded | `_ProfileCard` custom widget |
| Appearance | `l10n.appearance` | `_SettingsCard` → `_LanguageTile`, `_ThemeTile` |
| Prayer & Worship | `l10n.prayerSettings` | `_SettingsCard` → `_SwitchTile` (nested conditionals), `_NavTile` |
| Productivity / Reminders | `l10n.reminders` | `_SettingsCard` → `_SwitchTile` (task, Hijri), `_NavTile` (SmartZones) |
| Security | `l10n.privacy` | `_SettingsCard` → `_SwitchTile` (biometric) |
| Sync & Account | `l10n.syncAndData` | Conditional on `AuthAuthenticated`; `_SwitchTile`, `_NavTile` |
| Account Settings | `l10n.accountSettings` | `_NavTile` items (profile, Pro, reset password, delete, logout) |
| About | `l10n.aboutApp` | `_NavTile`, `_InfoTile` |

### Toggle Render Pattern
All boolean settings use `_SwitchTile`, which is a `ListTile` with:
- `leading: _IconBox` (36×36 rounded box with icon)
- `trailing: Switch.adaptive(activeTrackColor: const Color(0xFF1A6B3C))`
- `contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h)` — note: NOT `EdgeInsetsDirectional` (see Section 6c)

Navigation items use `_NavTile` (ListTile + `Icons.chevron_right_rounded` trailing).

There is **no dedicated "Accessibility" section** in the current settings page.

---

## 3. UserSettings Fields — Existing vs New

### All Existing Fields

| Field | Type | Default | Isar Annotation |
|-------|------|---------|----------------|
| `id` | `Id` | `Isar.autoIncrement` | — |
| `isDarkMode` | `bool` | `false` | implicit |
| `isAutoModeEnabled` | `bool` | `false` | implicit |
| `themePreference` | `ThemePreference` | `system` | `@Enumerated(EnumType.name)` |
| `didMigrateThemePreference` | `bool` | `false` | implicit |
| `isPrayerEnabled` | `bool` | `false` | implicit |
| `isPrayerCardEnabled` | `bool` | `false` | implicit |
| `isPrayerNotificationsEnabled` | `bool` | `false` | implicit |
| `enablePrayerReminders` | `bool` | `true` | implicit |
| `didMigratePrayerFeatureSettings` | `bool` | `false` | implicit |
| `isAutoSyncEnabled` | `bool` | `false` | implicit |
| `isBiometricEnabled` | `bool` | `false` | implicit |
| `isHijriMode` | `bool` | `false` | implicit |
| `isTasksKanbanView` | `bool` | `false` | implicit |
| `workPeriods` | `List<TimeRange>?` | `null` | implicit (embedded) |
| `sleepPeriods` | `List<TimeRange>?` | `null` | implicit |
| `quietPeriods` | `List<TimeRange>?` | `null` | implicit |
| `familyPeriods` | `List<TimeRange>?` | `null` | implicit |
| `freePeriods` | `List<TimeRange>?` | `null` | implicit |
| `workCategoryId` / `familyCategoryId` / `freeCategoryId` / `quietCategoryId` / `sleepCategoryId` | `int?` | `null` | implicit |
| `workDays` | `List<int>?` | `null` | implicit |
| `latitude` / `longitude` | `double?` | `null` | implicit |
| `cityName` | `String?` | `null` | implicit |
| `prayerTimeAdjustmentMinutes` | `int` | `0` | implicit |
| `isAthkarEnabled` | `bool` | `true` | implicit |
| `isMedicationNotificationsEnabled` | `bool` | `true` | implicit |
| `isTaskRemindersEnabled` | `bool` | `true` | implicit |
| `taskReminderMinutesBefore` | `int` | `30` | implicit |
| `respectQuietPeriodsForTasks` | `bool` | `true` | implicit |
| `isAppointmentRemindersEnabled` | `bool` | `true` | implicit |
| `defaultAppointmentReminderMinutes` | `int` | `60` | implicit |
| `appointmentMultipleReminders` | `bool` | `true` | implicit |
| `prayerCardDisplayMode` | `PrayerCardDisplayMode` | `dashboardOnly` | `@Enumerated(EnumType.name)` |
| `athkarDisplayMode` | `AthkarDisplayMode` | `independent` | `@Enumerated(EnumType.name)` |
| `athkarSessionViewMode` | `AthkarSessionViewMode` | `list` | `@Enumerated(EnumType.name)` |
| `isHabitRemindersEnabled` | `bool` | `true` | implicit |
| `defaultHabitReminderTime` | `DateTime?` | `null` | implicit |
| `isAthkarRemindersEnabled` | `bool` | `true` | implicit |
| `morningAthkarTime` / `eveningAthkarTime` / `sleepAthkarTime` | `String` | `'06:00'` / `'17:00'` / `'22:00'` | implicit |
| `isAssetRemindersEnabled` | `bool` | `true` | implicit |
| `assetReminderDaysBefore` | `int` | `7` | implicit |
| `assetWarrantyReminders` / `assetMaintenanceReminders` / `assetInsuranceReminders` / `assetLicenseReminders` | `bool` | `true` | implicit |
| `isProjectRemindersEnabled` | `bool` | `true` | implicit |
| `projectReminderDaysBefore` | `int` | `7` | implicit |
| `projectReminderHoursBefore` | `int` | `24` | implicit |
| `projectDailyReminders` | `bool` | `false` | implicit |
| `projectWeeklySummary` | `bool` | `false` | implicit |
| `sampleDataShown` / `sampleDataDismissed` | `bool` | `false` | implicit |
| `hideNavOnScroll` | `bool` | `false` | implicit |
| `lastSyncAt` | `DateTime?` | `null` | implicit |
| `lastSyncError` | `String?` | `null` | implicit |

### PR5 Target Fields — Status Check

| Field Name | Exists in Model? | Notes |
|-----------|-----------------|-------|
| `reduceMotion` | **NO** — does not exist | Must be added in PR5 |
| `disableGyroscope` | **NO** — does not exist | Must be added in PR5 |
| `easternNumerals` | **NO** — does not exist | Must be added in PR5 |

None of the three accessibility fields exist anywhere in the codebase. A codebase-wide search confirmed zero matches for `reduceMotion`, `reduce_motion`, `disableGyroscope`, `gyroscope` (other than hardware sensor usage in oil_animation.dart), `easternNumerals`, `eastern_numerals`, and `arabicNumerals`.

---

## 4. Persistence Pattern

### How existing toggles are saved

Pattern observed in `settings_cubit.dart` (lines 64–433) and `settings_repository_impl.dart` (lines 19–49):

1. `_repository.getSettings()` — fetches the single `UserSettings` Isar document (`findFirst()`). Creates a default if none exists.
2. Mutate the field directly on the returned object (e.g., `currentSettings.isPrayerEnabled = enabled`).
3. `_repository.updateSettings(currentSettings)` — calls `_isar.writeTxn(() => _isar.userSettings.put(settings))`. This is an upsert by `id`.
4. Reactive stream `watchSettings()` fires, `SettingsCubit` emits `SettingsLoaded(settings)`.

### Pattern PR5 must follow

Each new field requires:

1. Add field to `UserSettings` in `user_settings.dart` with a typed default (e.g., `bool reduceMotion = false;`).
2. Add field to the constructor with its default.
3. Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate `user_settings.g.dart`.
4. Add a dedicated toggle method in `SettingsCubit`:
   ```
   Future<void> toggleReduceMotion(bool value) async {
     final s = await _repository.getSettings();
     s.reduceMotion = value;
     await _repository.updateSettings(s);
   }
   ```
5. Add the new field to the `SettingsLoaded.props` list in `settings_state.dart` so BlocBuilder rebuilds when it changes.
6. Add a `_SwitchTile` entry under a new `_SectionHeader` (or existing section) in `general_settings_page.dart`.
7. Add localization strings for the tile title and subtitle to `app_ar.arb` and `app_en.arb`, then run `flutter gen-l10n`.

---

## 5. Cross-Screen Dependencies

| Flag | Screen / Consumer | PR where wired | Read exists now? |
|------|-------------------|---------------|-----------------|
| `reduceMotion` | `OilBottleAnimation` — `AnimationController.repeat()` should stop or freeze when true | Deferred to PR5 or later | No — animation always runs unconditionally |
| `reduceMotion` | `FluidEngine` / `FluidPainter` — particle physics loop runs regardless | Deferred to PR5 or later | No |
| `disableGyroscope` | `OilBottleAnimation._startGyroscope()` — opens a `gyroscopeEventStream` subscription unconditionally | Deferred to PR5 or later | No — gyro always starts in `initState()` |
| `easternNumerals` | `DualCalendarWidget` — uses `DateFormat` from `intl`; no eastern numeral switch | Deferred to PR5 or later | No |
| `easternNumerals` | Prayer time display (prayer_day_view, prayer_week_view, prayer_month_view) — uses `isHijriMode` for Hijri/Gregorian toggle but no eastern numeral format flag | Deferred to PR5 or later | No |
| `easternNumerals` | Stats counters, habit counts, focus timer — no numeral format switching exists anywhere | Deferred to later PR | No |

**Critical note on `disableGyroscope`:** `oil_animation.dart` lines 64–73 subscribe to `gyroscopeEventStream` inside `initState()` without any guard. If `disableGyroscope` is true, this subscription must not be opened. The wiring cannot be done retroactively without passing the flag into `OilBottleAnimation` at construction time. PR5 must also update `focus_body.dart` (or wherever `OilBottleAnimation` is instantiated) to pass `disableGyroscope` as a constructor parameter.

---

## 6. Gap Tables

### 6a. Visual / Layout Gaps

| Gap | Location | Detail |
|-----|----------|--------|
| No "Accessibility" section exists | `general_settings_page.dart` | The entire section needs to be added after the Privacy section (current last functional section before About) |
| No icon-to-section mapping defined for accessibility | — | Designer must specify icons for `reduceMotion`, `disableGyroscope`, `easternNumerals` tiles |
| `_SwitchTile.trailing` uses `Switch.adaptive` with hardcoded `activeTrackColor: const Color(0xFF1A6B3C)` | `general_settings_page.dart` line 893–896 | Hardcoded. No token used. Every new switch inherits the same hardcoded color. |
| `settings_page.dart` is a stub (12 lines) | `presentation/pages/settings_page.dart` | If this is routed from anywhere, it shows a blank screen. Relationship to `general_settings_page.dart` is unclear. |

### 6b. Token Gaps (hardcoded values in existing settings)

All hardcoded — no `AtharTypography` or `AtharColors` tokens are used anywhere in `general_settings_page.dart`:

| Hardcoded Value | Location | Should Be |
|----------------|----------|-----------|
| `fontFamily: 'Cairo'` | Lines 43, 383, 387, 392, 406, 428, 438, 562, 577, etc. (20+ instances) | `AtharTypography.fontFamilyAr` or a text-style token |
| `fontSize: 20` (AppBar title) | Line 44 | Typography token |
| `fontSize: 15` (_SwitchTile title) | Line 879 | Typography token |
| `fontSize: 12` (_SwitchTile subtitle) | Line 887 | Typography token |
| `fontSize: 13` (_SectionHeader) | Line 800 | Typography token |
| `const Color(0xFF1A6B3C)` | Lines 91, 102, 113, 125, 148, 302, 351, 558, 565 (9+ instances) | `AtharColors.primary` or `colorScheme.primary` |
| `const Color(0xFF0288D1)` | Lines 136, 216, 272, 322 | No design token mapped |
| `const Color(0xFF00897B)` | Line 148 | No design token mapped |
| `const Color(0xFF1565C0)` | Line 162 | No design token mapped |
| `const Color(0xFF6D4C41)` | Line 173 | No design token mapped |
| `const Color(0xFF7B1FA2)` | Line 183 | No design token mapped |
| `const Color(0xFFC62828)` | Line 200 | No design token mapped |
| `const Color(0xFF5C35C9)` | Line 1069 | No design token mapped |
| `const Color(0xFFF57C00)` | Line 311 | No design token mapped |
| `const Color(0xFF546E7A)` | Line 360 | No design token mapped |
| `const Color(0xFF636E72)` | Lines 647, 1072 | No design token mapped |
| `Colors.grey.shade100 / .shade300 / .shade400 / .shade500` | Multiple `_LangOption`, `_ThemeOption` | No design tokens — raw Material greys |
| `Colors.red.shade600` | Lines 329, 333, 340 | No design token for destructive actions |

### 6c. RTL Gaps (EdgeInsets)

| Usage | Location | Status |
|-------|----------|--------|
| `EdgeInsetsDirectional.only(bottom: 8.h, start: 4.w)` in `_SectionHeader` | Line 795 | CORRECT — uses DirectionalEdgeInsets |
| `EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)` for ListView padding | Line 68 | ACCEPTABLE — symmetric is RTL-safe |
| `EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h)` in `_SwitchTile.contentPadding` | Line 872 | ACCEPTABLE — symmetric is RTL-safe |
| `EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h)` in `_NavTile.contentPadding` | Line 928 | ACCEPTABLE — symmetric is RTL-safe |
| `EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h)` in `_InfoTile.contentPadding` | Line 978 | ACCEPTABLE — symmetric is RTL-safe |
| `const EdgeInsets.symmetric(horizontal: 12, vertical: 10)` (email container) | Line 443 | ACCEPTABLE |
| `const EdgeInsets.symmetric(horizontal: 16, vertical: 8)` (FilledButton in ProfileCard) | Line 602 | ACCEPTABLE |
| `const EdgeInsets.symmetric(horizontal: 20)` in `_ThemeTile` sheet | Lines 680, 1034 | ACCEPTABLE |
| `const EdgeInsets.symmetric(horizontal: 20)` in `_LangOption` contentPadding | Line 746 | ACCEPTABLE — symmetric |
| `const EdgeInsets.symmetric(horizontal: 20)` in `_ThemeOption` contentPadding | Line 1096 | ACCEPTABLE — symmetric |

No `EdgeInsets.only(left/right)` violations found in the settings page. RTL posture is clean for the existing layout.

However: `Icons.chevron_right_rounded` is used as the trailing arrow in all `_NavTile` instances (line 951). In RTL, this icon should point left (`Icons.chevron_left_rounded`). This is a pre-existing RTL gap not specific to PR5.

### 6d. Dark-Mode Gaps

| Issue | Evidence |
|-------|----------|
| `Switch.adaptive(activeTrackColor: const Color(0xFF1A6B3C))` | Line 893 — hardcoded color, will look the same in dark mode regardless of colorScheme |
| `CircleAvatar(backgroundColor: const Color(0xFF1A6B3C).withValues(alpha: 0.12))` | Line 558 — hardcoded, not adaptive |
| `ProfileCard` border color uses `colorScheme.outlineVariant.withValues(alpha: 0.5)` | Line 551 — CORRECT, adaptive |
| `_SettingsCard` border color uses `colorScheme.outlineVariant.withValues(alpha: 0.5)` | Line 824 — CORRECT, adaptive |
| `Colors.grey.shade100 / .shade300 / .shade400 / .shade500` in pickers | Multiple locations — hardcoded, not adaptive to dark mode |
| `_Divider` color uses `colorScheme.outlineVariant.withValues(alpha: 0.5)` | Line 840 — CORRECT, adaptive |
| Multiple icon colors hardcoded as `const Color(0xFF...)` | All `_SwitchTile` and `_NavTile` icon colors — not adaptive |

---

## 7. AdaptiveShell + RULE 1 Compliance

**RULE 1** requires window-based `LayoutBuilder` rather than `context.isTablet` for adaptive layouts.

**Finding:** `general_settings_page.dart` contains **no `LayoutBuilder`** and **no `context.isTablet` check**. The page uses a single-column `ListView` with no tablet-specific layout.

- There is no two-column or master-detail layout for iPad.
- `Scaffold` → `ListView` is a phone-only layout that will render as a narrow single column on iPad.
- This is a pre-existing gap, not introduced by PR5, but PR5 must not make it worse. Any new tiles added must not assume a fixed column count.
- The page does NOT violate RULE 1 (no `context.isTablet` found), but it is also fully non-adaptive. PR5 should not add a `LayoutBuilder` unless tablet layout is explicitly in scope — that would be scope creep.

---

## 8. Risk Register

| Risk | Severity | Mitigation |
|------|----------|-----------|
| `disableGyroscope` flag requires passing a parameter into `OilBottleAnimation` which starts the gyro sensor unconditionally in `initState()` | HIGH | PR5 must add a `bool disableGyroscope` parameter to `OilBottleAnimation` constructor and guard `_startGyroscope()` behind it. Also requires the Focus page or `focus_body.dart` to read `SettingsCubit` state and pass the flag. |
| `reduceMotion` flag requires `AnimationController` in `OilBottleAnimation` and `FluidEngine` to respond at runtime | HIGH | `AnimationController.stop()` / `repeat()` calls are simple, but the flag must be piped from settings into the widget. `OilBottleAnimation` currently has no way to receive settings state. |
| Adding `reduceMotion`, `disableGyroscope`, `easternNumerals` to `UserSettings` invalidates the existing Isar schema | MEDIUM | `build_runner` must be re-run. Isar handles new fields gracefully by assigning them their default values for existing records. No migration flag is needed unless the default must differ from the schema default. |
| `easternNumerals` requires a numeral conversion utility that does not yet exist | MEDIUM | A utility function converting ASCII digits 0–9 to Arabic-Indic ٠–٩ must be written. Multiple screens consume numeric strings. Scope is large; PR5 may need to limit wiring to the settings toggle only, deferring screen-level consumption to a subsequent PR. |
| `handoff_v2-2/PACKAGE_C_DECISIONS.md` spec file is missing | HIGH | Designer must confirm all three accessibility flag names, defaults, and UX copy before any implementation. See Section 9. |
| `settings_page.dart` stub may be the route target | LOW | Verify in `app.dart` routes whether `/settings` pushes `SettingsPage` or `GeneralSettingsPage`. If the stub is the target, the settings page is not reachable. |
| `_NavTile` trailing chevron does not flip in RTL | LOW | Pre-existing bug. PR5 should not fix it (scope creep) but must not introduce new directional icons either. |
| All icon colors in settings are hardcoded hex values | LOW | Pre-existing token gap. PR5 must use the same hardcoded pattern for consistency until a token pass is done on settings (out of PR5 scope). |

---

## 9. Open Questions for Designer

1. **Spec location:** `handoff_v2-2/PACKAGE_C_DECISIONS.md` was not found in the repository. Where is the Accessibility section spec? Implementation cannot begin without it.

2. **Exact flag names:** Are the three fields to be named `reduceMotion`, `disableGyroscope`, and `easternNumerals`? Or are designer-preferred names different?

3. **Default values:** Should `reduceMotion` default to `false` (opt-in) or be read from the system's `MediaQuery.disableAnimations`? Should `disableGyroscope` default to `false`? Should `easternNumerals` default to `false` or auto-detect from locale (`ar` → `true`)?

4. **Section placement:** Should the three accessibility toggles form their own "Accessibility" section, or be merged into an existing section (e.g., "Appearance")?

5. **Icon choice:** Which icons should `reduceMotion`, `disableGyroscope`, and `easternNumerals` tiles use?

6. **`easternNumerals` scope for PR5:** Should the toggle only be persisted in PR5 (with no screen-level wiring), or must at minimum one screen (calendar, prayer times, focus timer) consume it in the same PR?

7. **`reduceMotion` scope for PR5:** Should `OilBottleAnimation` respond to the flag in PR5, or is that deferred to a later PR?

8. **System accessibility integration:** Should `reduceMotion` honor `MediaQuery.of(context).disableAnimations` (iOS Reduce Motion) in addition to the in-app toggle? If yes, the logic must OR both sources.

9. **Localization strings:** Provide the Arabic (`app_ar.arb`) and English (`app_en.arb`) strings for the section header and all three tile titles and subtitles.

10. **`easternNumerals` naming in Arabic UI:** Should the tile use the term "الأرقام الهندية" (Eastern Arabic / Arabic-Indic numerals) or another phrase?

---

## 10. Validation + Screenshot Checklist

The following must be verified on simulator/device after PR5 implementation:

**Settings page — new Accessibility section:**
- [ ] Accessibility section header appears between Privacy and Sync sections (or at designer-specified location)
- [ ] Three toggles render: Reduce Motion, Disable Gyroscope, Eastern Numerals
- [ ] Each toggle persists across app restarts (kill app, reopen, verify toggle state retained)
- [ ] In Arabic locale: section header and tile labels display in Arabic
- [ ] In English locale: section header and tile labels display in English
- [ ] Toggle state reads correctly from `SettingsLoaded` state (not from a stale local variable)

**reduceMotion:**
- [ ] When `reduceMotion = true`, `OilBottleAnimation` in Focus page shows a static/frozen state (no AnimationController ticking)
- [ ] When `reduceMotion = false`, animation plays normally
- [ ] Toggle change takes effect without requiring app restart (hot reload / live state update)

**disableGyroscope:**
- [ ] When `disableGyroscope = true`, oil surface does not respond to physical device tilt
- [ ] When `disableGyroscope = false`, gyroscope-driven tilt is active (on real device)
- [ ] On simulator (no gyroscope hardware), both states show identical idle animation — no crash

**easternNumerals:**
- [ ] When `easternNumerals = true`, numerals in at least one consumer screen (TBD per designer) display as ٠١٢٣٤٥٦٧٨٩
- [ ] When `easternNumerals = false`, numerals display as 0123456789
- [ ] If screen-level wiring is deferred, confirm the toggle at least saves/restores without error

**RTL layout:**
- [ ] All new tiles display correctly in RTL (Arabic) — icon on right, text on left, toggle on left
- [ ] No directional icon issues introduced by PR5

**Dark mode:**
- [ ] New tiles display correctly in dark mode (section header, title, subtitle, icon box background all use adaptive `colorScheme` values)

**iPad:**
- [ ] Settings page on iPad (landscape and portrait) — new tiles appear in the same single-column list without overflow or misalignment
