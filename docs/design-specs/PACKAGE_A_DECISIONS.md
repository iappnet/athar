# Package A — Designer Decisions (resolved)

> Answered 2026-05-06. Source of truth for the questions raised in
> `_handoff_to_design_tool.md`. Claude Code follows these.

| # | Decision | Resolution |
|---|---|---|
| 1 | Arabic font | **Calibri** (Light 300, Regular 400, Bold 700). **Calibri is the sole canonical brand font for both Arabic and English** — across UI, headings, body, onboarding, widgets, showcase, and specs. **Risk accepted**: legal/product owner must confirm Calibri embedding licence before App Store submission. Cairo is NOT the Arabic primary and is NOT the effective rendering font — it may remain only as a last-resort emergency technical fallback in font stacks if a glyph fails to render. If the bundled Calibri TTFs lack full Arabic glyph coverage, that is a **font-asset-supply gap** to resolve by sourcing a Calibri build with Arabic coverage — NOT a typography-authority limitation. |ys as fallback only. |
| 2 | Calendar `isHijriMode` | **Repurposed**: dual numerals always shown. `isHijriMode` selects which numeral is **primary** (large) vs **secondary** (small). Existing `true` users keep Hijri-first. |
| 3 | `AdaptiveShell` location | **Rename + move**: `lib/core/layouts/adaptive_scaffold.dart` → `lib/core/design_system/widgets/adaptive_shell.dart`. Update imports. Delete old path. |
| 4 | Reduce Motion / Disable Gyro | **New `Accessibility` section** in Settings, above `About`. Houses Reduce Motion, Disable Gyroscope, Eastern Numerals. |
| 5 | Stats KPIs | **Tier-1 + Tier-2 — full dashboard from day one.** Tier-1: Tasks completed (today + 7d), longest current habit streak, habits completion rate (7d), Focus minutes (today + 7d), prayer adherence % (7d), Athkar sessions (7d). Tier-2: per-space breakdown, mood, sleep, custom date ranges. |
| 6 | iOS widget vs `isPrayerCardEnabled` | **Gated**: iOS Prayer widget only appears if `isPrayerEnabled` master feature toggle is ON. The master `isPrayerEnabled` controls all prayer surfaces (in-app card, widget, notifications). |
| 7 | Eastern Arabic numerals | **Opt-in**, default **OFF**, lives in Accessibility. When ON, numeric formatters return Eastern digits when locale is Arabic. |
| 8 | Prayer card variant storage | **SUPERSEDED 2026-05-07.** Investigation found `UserSettings.prayerCardDisplayMode` already exists (`dashboardOnly \| dashboardAndTasks \| allPages`) and controls *where* the card surfaces. Compact/expanded is **widget-local state** mirrored to the App Group's shared `UserDefaults` for the iOS widget. Do NOT introduce a `prayerCardVariant` field. See `INVESTIGATION_RECONCILIATION.md §A3`. |

## Implications for Package B specs

- All specs use Calibri as the sole canonical brand font for both Arabic and English. Cairo is NOT a design-authority font.
- Calendar cell spec: both numerals always render; primary = larger per `isHijriMode`.
- Settings spec adds the Accessibility section.
- Stats spec covers Tier-1 + Tier-2 KPIs.
- iOS widgets spec gates on `isPrayerEnabled` master toggle and mirrors the in-app compact/expanded selection via App Group shared `UserDefaults`.
- Numeric formatters spec includes opt-in Eastern conversion path.
- Prayer card spec: compact default; widget renders the user's chosen variant.
