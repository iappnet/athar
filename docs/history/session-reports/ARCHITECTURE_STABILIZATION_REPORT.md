# Architecture Stabilization Report — Theme System

**Date:** 2026-05-09  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Status:** Theme architecture stabilized — ready for PR2

---

## Final Theme Architecture

### Data layer

```
UserSettings (Isar @collection)
  └─ ThemePreference themePreference  (@Enumerated(EnumType.name), default: system)
  └─ bool didMigrateThemePreference   (migration flag, default: false)
  └─ bool isDarkMode                  (deprecated — preserved, not read)
```

### Domain / state layer

```
SettingsCubit
  └─ loadSettings()                     → calls _runThemeMigrationIfNeeded()
  └─ toggleThemePreference(preference)  → writes to Isar, stream emits
  └─ _runThemeMigrationIfNeeded()       → one-time migration from isDarkMode

SettingsLoaded.props
  └─ settings.themePreference           → drives BlocBuilder rebuilds
```

### Presentation layer

```
app.dart — MaterialApp
  └─ themeMode: switch (themePreference) {
       ThemePreference.light  → ThemeMode.light,
       ThemePreference.dark   → ThemeMode.dark,
       ThemePreference.system → ThemeMode.system,
     }

GeneralSettingsPage → Appearance section
  └─ _ThemeTile   (NavTile — shows current label, opens picker)
  └─ _ThemeOption (radio option widget — mirrors _LangOption pattern)
```

---

## Why the Enum Approach Was Chosen

### 1 — Matches established project pattern exactly

`user_settings.dart` already uses `@Enumerated(EnumType.name)` for
`PrayerCardDisplayMode`, `AthkarDisplayMode`, and `AthkarSessionViewMode`.
Adding `ThemePreference` introduces zero new patterns.

### 2 — Type safety

A `String` field (`"light"` / `"dark"` / `"system"`) has no compile-time
guard against typos. An enum makes invalid values impossible — the
compiler rejects them and the Dart `switch` expression enforces
exhaustiveness.

### 3 — Exhaustive switch in app.dart

Dart 3.0+ `switch` expressions are exhaustive. If `ThemePreference` gains
a fourth value in the future (e.g., `ThemePreference.scheduled`), the
compiler will immediately flag the `switch` in `app.dart` as incomplete,
forcing the developer to handle it. A boolean or string approach would
silently fall through.

### 4 — Human-readable Isar storage

`EnumType.name` stores `"system"`, `"light"`, `"dark"` as strings in
Isar — not integers. This means database records are human-readable during
debugging and safe for future enum renames (rename + migration vs. integer
remapping).

### 5 — Boolean was architecturally insufficient

A `bool isDarkMode` can represent at most two states. The required product
behavior has three. Extending a boolean to represent three states via two
booleans (`isDarkMode` + `isSystemMode`) produces ambiguous combinations
(`isDarkMode=true, isSystemMode=true`). The enum eliminates all ambiguity.

---

## Migration Safety

### What was migrated

Existing users had only `bool isDarkMode` (true/false). On first launch
after this PR, `_runThemeMigrationIfNeeded()` runs once:

- `isDarkMode=true` → `ThemePreference.dark` — preserves forced-dark behavior
- `isDarkMode=false` → `ThemePreference.system` — preserves follow-system behavior (set by PR-THEME)

### Why the migration is safe

1. **Additive field** — Isar handles new fields with defaults gracefully.
   New `themePreference` defaults to `ThemePreference.system` on read
   of any pre-migration record.
2. **Migration flag** — `didMigrateThemePreference` prevents the migration
   from running twice (matches pattern of `didMigratePrayerFeatureSettings`).
3. **No data deleted** — `isDarkMode` field remains in the schema. Migration
   only reads it; does not clear it.
4. **Error-isolated** — Migration is wrapped in try/catch. If it fails, the
   app continues with the safe default (`ThemePreference.system`).
5. **Idempotent** — Repeated cold starts skip migration after first run.

### Rollback safety

If this PR is reverted:
- `themePreference` field is absent from the reverted schema
- Isar ignores unknown fields on read
- `isDarkMode` field is still in all records — UI reverts correctly
- No data loss occurs

---

## Persistence Safety

Isar `EnumType.name` stores the enum `.name` string. For `ThemePreference`:

| Enum value | Stored string |
|------------|--------------|
| `ThemePreference.system` | `"system"` |
| `ThemePreference.light` | `"light"` |
| `ThemePreference.dark` | `"dark"` |

If a stored string is unrecognized (e.g., from a future rollback), the
generated adapter defaults to `ThemePreference.system` — the safe fallback:

```dart
// in user_settings.g.dart (line ~633)
themePreference: _UserSettingsthemePreferenceValueEnumMap[
    reader.readStringOrNull(offsets[57])] ??
    ThemePreference.system,
```

---

## Localization Safety

The three theme option labels use pre-existing ARB keys:
- `"lightMode"` — exists since before PR1
- `"darkMode"` — exists since before PR1
- `"systemMode"` — exists since before PR1

`darkModeDesc` (added in PR-THEME, now removed) had no references
outside `general_settings_page.dart`. Its removal is clean — no
orphaned references remain after `flutter gen-l10n`.

All localization is bilingual (AR + EN). The `_ThemeTile` picker title
uses `l10n.theme` which resolves to "Theme" in EN and "السمة" in AR.

---

## Isar Impact

| Change | Impact |
|--------|--------|
| New enum `ThemePreference` | Safe — additive type |
| New field `themePreference` with `@Enumerated(EnumType.name)` | Safe — new field with default; existing records get `ThemePreference.system` |
| New field `didMigrateThemePreference` | Safe — new bool with `false` default |
| `isDarkMode` field retained | Safe — no schema change; field stays |
| No fields removed | Safe — no breaking schema change |

Isar schema version is NOT manually managed in this project — Isar
auto-detects additive changes and handles them transparently.

---

## Rollback Boundaries

| Rollback scope | Safe | Notes |
|----------------|------|-------|
| Revert PR-THEME-3MODE commit only | ✅ | `isDarkMode` intact; `themePreference` ignored by old schema |
| Revert to `athar-v2-prtheme-complete` | ✅ | 2-state behavior restored; no data loss |
| Revert to `athar-v2-pr1-complete` | ✅ | Full PR1 state; `isDarkMode` reads correct |
| Revert to `main` | ✅ | Stable legacy baseline unchanged throughout migration |

---

## Generated-Code Impact

### `user_settings.g.dart`

Always regenerated by `build_runner`. Never edit manually. This PR adds:
- `ThemePreference` enum maps (both directions)
- `themePreference` serialization at string offset 57
- `didMigrateThemePreference` serialization at bool offset 12

### `app_localizations_*.dart`

Regenerated by `flutter gen-l10n`. This PR removes `darkModeDesc` from
generated classes. No other generated content changed.

### `injection.config.dart`

Not touched. No new injectable classes added.

---

## Future Extensibility

The `ThemePreference` enum can be extended with a fourth value
(e.g., `scheduled` — auto dark at sunset) without any migration
required for existing users — the `switch` in `app.dart` will
enforce exhaustive handling at compile time, and Isar will store the
new string name safely. A new migration step would only be needed
if the semantics of existing values change.

---

## Remaining Architectural Risks

| Risk | Severity | When to address |
|------|----------|----------------|
| `isDarkMode` and `toggleDarkMode()` are dead code | Low | PR-CLEANUP — sweep with other deprecated fields |
| `SettingsCubit.toggleDarkMode()` still exists but is uncalled | Low | PR-CLEANUP |
| No theme-specific tests exist | Medium | Test debt — add after PR2 when UI testing strategy is established |
| `settings.isAutoModeEnabled` naming confusion (Smart Zones field named ambiguously) | Low | Document only — do not rename until PR-CLEANUP (breaking field rename in Isar requires migration) |

---

## Architecture Verdict

**STABLE.**

The theme architecture is correct, type-safe, migration-safe, and
consistent with the existing codebase patterns. It can be extended
without modification by future PRs. PR2 may proceed.

---

## Next Step

**PR2 — AdaptiveShell.** Read before starting:
- `handoff_v2-2/IPAD_OPTIMIZATION.md`
- `handoff_v2-2/REDESIGN_AUDIT.md`
- `handoff_v2-2/INVESTIGATION_REPORT.md`
- `preview/comp-nav.html`
