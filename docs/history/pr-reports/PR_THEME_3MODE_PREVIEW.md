# PR-THEME-3MODE Implementation Preview

**Prepared:** 2026-05-09  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Supersedes:** PR-THEME (commit `14c13d6`) — extends its `ThemeMode.system` base  
**Status:** PREVIEW ONLY — no code modified

---

## Current Behavior (Post PR-THEME — commit `14c13d6`)

```dart
// app.dart:163–165
final isDark = settingsState is SettingsLoaded
    ? settingsState.settings.isDarkMode
    : false;

// app.dart:172
themeMode: isDark ? ThemeMode.dark : ThemeMode.system,
```

**Effective modes:**

| `isDarkMode` | Result | How user reaches it |
|---|---|---|
| `false` (default) | `ThemeMode.system` | Toggle OFF in Settings |
| `true` | `ThemeMode.dark` | Toggle ON in Settings |

**Problem:** There is no explicit light mode option. Users on a dark-system device who
want to lock the app to light cannot do so. The two-state boolean maps to only
system-or-dark, leaving `ThemeMode.light` unreachable.

---

## Target Behavior — 3 Explicit Options

| Option | ThemeMode | Meaning |
|--------|-----------|---------|
| **System** (default) | `ThemeMode.system` | Follow device OS appearance |
| **Light** | `ThemeMode.light` | Always light, regardless of OS |
| **Dark** | `ThemeMode.dark` | Always dark, regardless of OS |

All three options persisted in Isar, survives app restart.

---

## Recommended Data Model — Enum

### Why enum over String

The codebase already uses `@Enumerated(EnumType.name)` in
`user_settings.dart` for three other settings:
- `PrayerCardDisplayMode` (lines 100–102)
- `AthkarDisplayMode` (lines 104–105)
- `AthkarSessionViewMode` (lines 107–108)

Using a named-string enum:
- Matches the established pattern exactly — zero new patterns to introduce
- Compile-time safety (no typo risk)
- `EnumType.name` stores the string name ("light"/"dark"/"system") in Isar,
  making the DB human-readable and safe for future renaming if needed
- Clean `switch` expression in `app.dart`

### Proposed Enum

```dart
// to be added at top of user_settings.dart, with other enum declarations
enum ThemePreference { system, light, dark }
```

Default: `ThemePreference.system` — matches PR-THEME intent (follow OS by default).

### Proposed UserSettings field

```dart
// in UserSettings class — after isDarkMode (line 21)
@Enumerated(EnumType.name)
ThemePreference themePreference = ThemePreference.system;
```

**`isDarkMode` field is kept** (not removed). Removing it would break
existing serialization for in-flight records and is a breaking Isar schema
change. It is deprecated silently; `toggleDarkMode()` in SettingsCubit
becomes unused but is not deleted. It will be swept in PR-CLEANUP.

---

## Migration Strategy — From isDarkMode Boolean

### Situation

Existing Isar records on user devices have `isDarkMode` set but no
`themePreference` field (it will initialize to the default
`ThemePreference.system` when first read after the upgrade).

**Risk:** A user who previously had `isDarkMode = true` (forced dark) would
silently land on `ThemePreference.system` (follow OS). If their OS is
light, they would unexpectedly see light mode after the update.

### Migration approach — one-time boolean flag (follows prayer settings precedent)

Add a migration flag field to `UserSettings`:

```dart
bool didMigrateThemePreference = false;
```

Add `_runThemeMigrationIfNeeded()` to `SettingsCubit`, called from
`loadSettings()` after the prayer migration:

```dart
Future<void> _runThemeMigrationIfNeeded() async {
  try {
    final settings = await _repository.getSettings();
    if (settings.didMigrateThemePreference) return;

    // Carry forward from legacy isDarkMode boolean:
    // - isDarkMode=true  → ThemePreference.dark
    // - isDarkMode=false → ThemePreference.system (PR-THEME default)
    settings.themePreference =
        settings.isDarkMode ? ThemePreference.dark : ThemePreference.system;
    settings.didMigrateThemePreference = true;

    await _repository.updateSettings(settings);
  } catch (e) {
    if (kDebugMode) print('❌ Theme migration error: $e');
  }
}
```

This is structurally identical to the existing `_runPrayerMigrationIfNeeded()`.
New users (no existing record) skip the migration because
`didMigrateThemePreference` defaults to `true`... wait — it defaults to `false`,
so migration runs once on first load, reads `isDarkMode=false` (fresh record),
sets `themePreference=system`, sets flag to `true`. Correct behavior.

### New `UserSettings` fields required

```dart
// Two new fields — both require build_runner
bool didMigrateThemePreference = false;

@Enumerated(EnumType.name)
ThemePreference themePreference = ThemePreference.system;
```

---

## build_runner Requirement

**YES — required.**

`UserSettings` is an Isar `@collection` class with a `part 'user_settings.g.dart'`
directive. Adding any new field (including enum fields with `@Enumerated`)
requires regenerating `user_settings.g.dart`.

Command:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This is safe. The command only regenerates Isar adapter code. It does not
touch any other generated file in the project.

**Files auto-regenerated (do not edit manually):**
- `lib/features/settings/data/models/user_settings.g.dart`

---

## Exact Files to Modify

| # | File | Change type | Change summary |
|---|------|------------|----------------|
| 1 | `lib/features/settings/data/models/user_settings.dart` | Edit | Add `ThemePreference` enum; add `themePreference` + `didMigrateThemePreference` fields; add both to constructor |
| 2 | `lib/features/settings/data/models/user_settings.g.dart` | Auto-generated | Regenerated by build_runner — do not edit |
| 3 | `lib/features/settings/presentation/cubit/settings_cubit.dart` | Edit | Add `toggleThemePreference(ThemePreference)` method; call `_runThemeMigrationIfNeeded()` from `loadSettings()` |
| 4 | `lib/features/settings/presentation/cubit/settings_state.dart` | Edit | Add `settings.themePreference` to `SettingsLoaded.props` list |
| 5 | `lib/features/settings/presentation/pages/general_settings_page.dart` | Edit | Replace `_SwitchTile` Dark Mode with `_NavTile` + bottom-sheet picker (3 options) |
| 6 | `lib/app.dart` | Edit | Replace `isDarkMode` bool logic with `themePreference` switch |
| 7 | `lib/l10n/app_en.arb` | Edit | Remove `darkModeDesc` key (added in PR-THEME, now superseded) |
| 8 | `lib/l10n/app_ar.arb` | Edit | Same — remove `darkModeDesc` |
| 9 | `lib/l10n/generated/` (3 files) | Auto-generated | Regenerated by `flutter gen-l10n` — do not edit |

**Total hand-edited files: 7** (files 1, 3, 4, 5, 6, 7, 8)

---

## Exact Proposed Diffs

### File 1 — `user_settings.dart`

**Add enum** (at top of file with other enums, before `PrayerCardDisplayMode`):
```dart
enum ThemePreference { system, light, dark }
```

**Add fields** (immediately after `bool isAutoModeEnabled;` on line 22):
```dart
@Enumerated(EnumType.name)
ThemePreference themePreference = ThemePreference.system;
bool didMigrateThemePreference = false;
```

**Add to constructor** (after `this.isAutoModeEnabled = false,`):
```dart
this.themePreference = ThemePreference.system,
this.didMigrateThemePreference = false,
```

---

### File 3 — `settings_cubit.dart`

**Add to `loadSettings()`** (after `await _runPrayerMigrationIfNeeded();`):
```dart
await _runThemeMigrationIfNeeded();
```

**Add new method** (after `toggleDarkMode`):
```dart
Future<void> toggleThemePreference(ThemePreference preference) async {
  try {
    final currentSettings = await _repository.getSettings();
    currentSettings.themePreference = preference;
    await _repository.updateSettings(currentSettings);
  } catch (e) {
    if (kDebugMode) print('❌ Error toggling theme preference: $e');
  }
}
```

**Add migration method**:
```dart
Future<void> _runThemeMigrationIfNeeded() async {
  try {
    final settings = await _repository.getSettings();
    if (settings.didMigrateThemePreference) return;
    settings.themePreference =
        settings.isDarkMode ? ThemePreference.dark : ThemePreference.system;
    settings.didMigrateThemePreference = true;
    await _repository.updateSettings(settings);
  } catch (e) {
    if (kDebugMode) print('❌ Theme migration error: $e');
  }
}
```

---

### File 4 — `settings_state.dart`

**In `SettingsLoaded.props`**, replace:
```dart
settings.isDarkMode,
```
with:
```dart
settings.themePreference,
```

(`isDarkMode` is kept in UserSettings but no longer needs to drive rebuilds.)

---

### File 5 — `general_settings_page.dart`

**Replace** the entire `_SwitchTile` Dark Mode block:
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

**With** a `_NavTile` that opens a 3-option picker:
```dart
_NavTile(
  icon: Icons.dark_mode_outlined,
  iconColor: const Color(0xFF5C35C9),
  title: l10n.theme,
  trailing2: Text(
    _themeLabel(settings?.themePreference ?? ThemePreference.system, l10n),
    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13,
        color: Color(0xFF636E72)),
  ),
  onTap: () => _showThemePicker(context, l10n,
      settings?.themePreference ?? ThemePreference.system),
),
```

**Add helpers** at the bottom of `GeneralSettingsPage`:
```dart
String _themeLabel(ThemePreference p, AppLocalizations l10n) => switch (p) {
  ThemePreference.light  => l10n.lightMode,
  ThemePreference.dark   => l10n.darkMode,
  ThemePreference.system => l10n.systemMode,
};

void _showThemePicker(BuildContext ctx, AppLocalizations l10n,
    ThemePreference current) {
  final cubit = ctx.read<SettingsCubit>();
  showModalBottomSheet(
    context: ctx,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // drag handle
          Container(width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l10n.theme,
                  style: const TextStyle(fontFamily: 'Cairo',
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 4),
          for (final p in ThemePreference.values)
            _ThemeOption(
              label: _themeLabel(p, l10n),
              isSelected: current == p,
              onTap: () {
                cubit.toggleThemePreference(p);
                Navigator.pop(sheetCtx);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
```

**Add `_ThemeOption` widget** (mirrors `_LangOption` already in the file):
```dart
class _ThemeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ThemeOption({required this.label, required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A6B3C).withValues(alpha: 0.1)
              : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: isSelected ? const Color(0xFF1A6B3C) : Colors.grey.shade400,
          size: 22,
        ),
      ),
      title: Text(label,
        style: TextStyle(fontFamily: 'Cairo', fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? const Color(0xFF1A6B3C) : null)),
    );
  }
}
```

---

### File 6 — `app.dart`

**Replace** lines 162–165 and 172:
```dart
// BEFORE
final isDark = settingsState is SettingsLoaded
    ? settingsState.settings.isDarkMode
    : false;
// ...
themeMode: isDark ? ThemeMode.dark : ThemeMode.system,
```

**After:**
```dart
final themePreference = settingsState is SettingsLoaded
    ? settingsState.settings.themePreference
    : ThemePreference.system;
// ...
themeMode: switch (themePreference) {
  ThemePreference.light  => ThemeMode.light,
  ThemePreference.dark   => ThemeMode.dark,
  ThemePreference.system => ThemeMode.system,
},
```

The `switch` expression requires Dart 3.0+, which is already in use in this project.

---

### Files 7 & 8 — ARB files

**Remove `darkModeDesc`** from both `app_en.arb` and `app_ar.arb`.

This key was added in PR-THEME as a switch subtitle. The switch is now
replaced by a picker tile — the subtitle is no longer rendered.

**No new keys needed.** All three option labels already exist:
- `"lightMode"` — "Light Mode" / "الوضع الفاتح"
- `"darkMode"` — "Dark Mode" / "الوضع الداكن"
- `"systemMode"` — "System Default" / "حسب النظام"
- `"theme"` — "Theme" / "السمة" (for the picker title and NavTile)

Run `flutter gen-l10n` after ARB changes.

---

## UI Behavior After Change

| User action | Result |
|-------------|--------|
| Open Settings → Appearance | Sees "Theme" NavTile with current selection shown inline (e.g. "System Default") |
| Tap Theme tile | Bottom sheet opens with 3 radio options |
| Select Light | App immediately switches to light; OS dark mode has no effect |
| Select Dark | App immediately switches to dark; OS light mode has no effect |
| Select System | App follows device OS; switches live on OS change |
| Close and reopen app | Selection persisted from Isar |
| Upgrade from PR-THEME (had dark toggle ON) | Migration runs once → `ThemePreference.dark` set |
| Upgrade from PR-THEME (had dark toggle OFF) | Migration runs once → `ThemePreference.system` set |

---

## Localization Requirements

| Key | Status | Notes |
|-----|--------|-------|
| `lightMode` | ✅ Exists | "Light Mode" / "الوضع الفاتح" |
| `darkMode` | ✅ Exists | "Dark Mode" / "الوضع الداكن" |
| `systemMode` | ✅ Exists | "System Default" / "حسب النظام" |
| `theme` | ✅ Exists | "Theme" / "السمة" |
| `darkModeDesc` | ⚠️ Remove | Added in PR-THEME; no longer rendered |

**`flutter gen-l10n` required** — must be run after removing `darkModeDesc`.

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Migration runs on cold start — brief Isar write before first frame | Very Low | Same as existing prayer migration; write is async and non-blocking |
| `isDarkMode` boolean stays in model as dead code | Very Low | Non-breaking; swept in PR-CLEANUP |
| `toggleDarkMode()` in cubit becomes dead code | Very Low | Not called after this PR; swept in PR-CLEANUP |
| `build_runner` adds build step complexity | Low | One command; no conditional logic; safe |
| Dart `switch` expression requires Dart ≥3.0 | None | Project already uses Dart 3 patterns |
| RTL layout of bottom sheet picker | None | Uses `AlignmentDirectional.centerStart` and `fontFamily: 'Cairo'` — matches Language picker exactly |
| `darkModeDesc` removal could break other references | None | Key is only referenced in `general_settings_page.dart` (the file we're editing) |
| `SettingsLoaded.props` no longer includes `isDarkMode` | Very Low | `isDarkMode` is now dead state — removing from props prevents unnecessary rebuilds |

---

## Rollback Plan

1. Revert files 1, 3, 4, 5, 6, 7, 8 to their PR-THEME state
2. Re-run `flutter pub run build_runner build --delete-conflicting-outputs`
3. Re-run `flutter gen-l10n`
4. Existing Isar records: `themePreference` field will be ignored (field absent in old schema); `isDarkMode` field remains intact

Git rollback: `git revert <pr-theme-3mode-commit>` or
`git checkout athar-v2-prtheme-complete -- <list-of-files>`

---

## Sequence of Implementation Steps

1. Edit `user_settings.dart` — add enum + 2 fields + constructor params
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`
3. Verify `user_settings.g.dart` regenerated cleanly
4. Edit `settings_state.dart` — update props
5. Edit `settings_cubit.dart` — add method + migration call
6. Edit `app.dart` — replace theme reading logic
7. Edit `general_settings_page.dart` — replace switch with picker
8. Edit `app_en.arb` + `app_ar.arb` — remove `darkModeDesc`
9. Run `flutter gen-l10n`
10. Run `flutter analyze` — must be 0 issues
11. Run `flutter test` — must be 29/29

---

## Screenshot Checklist (post-implementation)

| Check | Light | Dark | System |
|-------|-------|------|--------|
| Picker opens from Settings | ✅ | ✅ | ✅ |
| NavTile shows correct current label | ✅ | ✅ | ✅ |
| App theme applies immediately on selection | ✅ | ✅ | ✅ |
| Theme persists after app restart | ✅ | ✅ | ✅ |
| Arabic RTL picker layout | ✅ | ✅ | ✅ |

---

## Summary

| Dimension | Value |
|-----------|-------|
| Files hand-edited | 7 |
| Files auto-generated | 3 (`user_settings.g.dart`, `app_localizations*.dart`) |
| New ARB keys | 0 |
| Removed ARB keys | 1 (`darkModeDesc`) |
| `build_runner` required | **Yes** |
| `flutter gen-l10n` required | **Yes** |
| New Isar fields | 2 (`themePreference`, `didMigrateThemePreference`) |
| New UserSettings enum | 1 (`ThemePreference`) |
| Migration required | Yes — one-time, follows prayer settings precedent |
| Rollback complexity | Low — 7 files + 2 regen commands |
| PR2 impact | None — this completes before PR2 starts |

---

## Approval Phrase

To start implementation, reply with:

> **"Implement PR-THEME-3MODE"**
