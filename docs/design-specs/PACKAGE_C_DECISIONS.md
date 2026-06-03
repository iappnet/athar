# Package C — Remaining design decisions (resolved)

> Answered 2026-05-06. Source of truth alongside `PACKAGE_A_DECISIONS.md`.

| # | Decision | Resolution |
|---|---|---|
| 1 | Dark mode | **Full parity** — every screen ships light + dark in v1. Tokens already exist; see `THEME_DARK_SPEC.md` for per-screen treatments. |
| 2 | Tab bar | **Liquid-glass bottom nav with 4 tabs** (Dashboard / Tasks / Habits / Spaces). The quick-add **"+" FAB is a standalone pill *outside* the bar** — sits **right** of the bar in **English (LTR)**, **left** of the bar in **Arabic (RTL)**. Bar uses 28px backdrop blur · 180% saturation · layered translucency · top specular highlight · inner-ring edge. FAB is solid forest-green (`primary` gradient), 64×64 with 22px radius. **No centered FAB / no notch.** Reference: `preview/comp-nav.html`. |
| 3 | Calendar + Settings entry | Calendar = AppBar icon on **Dashboard + Habits**. Settings = gear icon on the AppBar. |
| 4 | Athkar inside Habits | Habit type discriminator: `Habit.type = regular \| athkar`. **Athkar habits render differently** — dhikr counter card instead of checkbox, target-count instead of binary done, swipe-through reader on tap, audio + transliteration support. Streaks, history, stats reuse Habits infrastructure. |
| 5 | Onboarding | **Minimal flow as default**, scenic onboarding as opt-in "tour" launchable from Settings → Re-do tour. Both paths must compile. |
| 6 | Empty states | **Hybrid**: commission 5 illustrations (Tasks, Habits, Calendar, Stats, Spaces). Lucide icons elsewhere (Athkar, Search, Errors, generic). Style: flat 2-color (cream + forest), centered glyph, no faces, no text inside the illustration. |
| 7 | Sound design | **Keep existing adhan** + add 3-tone calm-chime library: soft bell (notification ack), water drop (athkar +1), bowl strike (focus session end). Source: Freesound CC0 or commission ~$200. |
| 8 | Haptics | **Calm-but-present**: `HapticFeedback.lightImpact` for habit check / dhikr +1 / task complete. `HapticFeedback.mediumImpact` for prayer "ALLAHU AKBAR" + focus session end. Never heavy. Reduce Motion halves all intensities. |
| 9 | Notification voice | **Warm second-person**, Arabic + English. e.g. "حان وقت الذكر" / "Time for evening adhkar". No "Reminder:" prefixes, no all-caps. |
| 10 | Stats surface | **Stats Hub on Dashboard** (scrollable below prayer card, 3 mini-KPIs + sparklines) + "See all" → full Stats screen. Also reachable via Settings → Insights. |
| 11 | Iconography | **Lucide** — keep current set. |
| 12 | Logo in chrome | **Wordmark on Dashboard AppBar only**. Inner screens show the feature title instead. Splash + onboarding + Settings → About retain the full mark. |

## Implications for downstream specs

- `IPAD_OPTIMIZATION.md` mirror rule restated: on phone the FAB sits **outside** the liquid-glass bar (right in LTR / left in RTL); on tablet it moves into the `NavigationRail.leading:` slot. The bar itself is never forked — only the chrome wrapper changes per breakpoint.
- `STATS_KPI_SPEC.md` adds a "Dashboard rail" section: 3 KPIs only (today's tasks, habit streak, focus minutes), tap → full screen.
- New file `THEME_DARK_SPEC.md` specifies per-surface dark treatments.
- `ATHKAR_SPEC.md` reframed as "Athkar habit type spec" — UI sits inside the Habits feature, not as a separate destination.
- `COMPONENT_SPECS.md` adds an `EmptyState` illustration vs icon decision matrix per variant.
- Notification copy keys go into `app_en.arb` / `app_ar.arb` under `notif.*` namespace, with the warm-voice convention documented in `SKILL.md`.
- `SKILL.md` adds a haptics + sounds section.
