# Package A — Designer Decisions (resolved)

> Answered 2026-05-06. Source of truth for the questions raised in
> `_handoff_to_design_tool.md`. Claude Code follows these.

| # | Decision | Resolution |
|---|---|---|
| 1 | Arabic font | **Calibri** (Light 300, Regular 400, Bold 700). Brand-mandated. **Risk accepted**: legal/product owner must confirm Calibri embedding licence before App Store submission. Cairo stays as fallback only. |
| 2 | Calendar `isHijriMode` | **Repurposed**: dual numerals always shown. `isHijriMode` selects which numeral is **primary** (large) vs **secondary** (small). Existing `true` users keep Hijri-first. |
| 3 | `AdaptiveShell` location | **Rename + move**: `lib/core/layouts/adaptive_scaffold.dart` → `lib/core/design_system/widgets/adaptive_shell.dart`. Update imports. Delete old path. |
| 4 | Reduce Motion / Disable Gyro | **New `Accessibility` section** in Settings, above `About`. Houses Reduce Motion, Disable Gyroscope, Eastern Numerals. |
| 5 | Stats KPIs | **Tier-1 + Tier-2 — full dashboard from day one.** Tier-1: Tasks completed (today + 7d), longest current habit streak, habits completion rate (7d), Focus minutes (today + 7d), prayer adherence % (7d), Athkar sessions (7d). Tier-2: per-space breakdown, mood, sleep, custom date ranges. |
| 6 | iOS widget vs `isPrayerCardEnabled` | **Gated**: iOS Prayer widget only appears if `isPrayerEnabled` master feature toggle is ON. The master `isPrayerEnabled` controls all prayer surfaces (in-app card, widget, notifications). |
| 7 | Eastern Arabic numerals | **Opt-in**, default **OFF**, lives in Accessibility. When ON, numeric formatters return Eastern digits when locale is Arabic. |
| 8 | Prayer card variant storage | **`UserSettings.prayerCardVariant: 'compact' \| 'expanded'`** (default `'compact'`), synced via Supabase. **iOS widget uses the same variant** as the in-app card. |

## Implications for Package B specs

- All specs use Calibri primary, Cairo fallback.
- Calendar cell spec: both numerals always render; primary = larger per `isHijriMode`.
- Settings spec adds the Accessibility section.
- Stats spec covers Tier-1 + Tier-2 KPIs.
- iOS widgets spec gates on `isPrayerEnabled` master toggle and mirrors the in-app `prayerCardVariant`.
- Numeric formatters spec includes opt-in Eastern conversion path.
- Prayer card spec: compact default; widget renders the user's chosen variant.
