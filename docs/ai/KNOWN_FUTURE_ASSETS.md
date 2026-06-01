# Known Future Assets

> Items that require **external files, accounts, or hardware** to complete.
> They are **explicitly out of scope** for all current design + implementation
> PRs. Track here; do not let them block design work.
>
> Last updated: 2026-06-01

---

## Parking lot

| # | Asset / task | Needed for | Owner | Gate type | Status |
|---|---|---|---|---|---|
| 1 | `adhan.mp3` (Android raw resource) | Prayer notification sound | PM / audio source | PR-ADHAN build gate | ⏸ Paused — file not yet supplied |
| 2 | `adhan.caf` (iOS) | Same, iOS | Run `afconvert -f caff -d LEI16@22050 adhan.mp3 adhan.caf` | PR-ADHAN build gate | ⏸ Paused — depends on #1 |
| 3 | **Calibri App Store embedding licence** | Legally embedding Calibri in the shipped binary | Legal / PM | App Store **submission** gate (NOT a build gate) | ⏳ Open — does not block any build |
| 4 | **Physical-device QA — iOS widget interactions** | Interactive widget taps (Task toggle, Habit boolean + count), prayer nafl badges, locale switch while widget on Home Screen | QA / product owner | Pre-**release** gate | ⏳ Deferred by product owner |
| 5 | **Physical-device QA — forest-dark surfaces** | Verify prayer card forest gradient renders correctly on device (can't replicate in golden tests); dark-mode surface validation | QA | Pre-**release** gate | ⏳ Deferred post-merge (PR3 + PR-THEME approved) |
| 6 | **Physical-device QA — Arabic rendering / Cairo fallback** | Verify no Arabic tofu on device — proves Cairo glyph resolution works at runtime (fontFamilyFallback chain) | QA | Pre-**release** gate | ⏳ Deferred post-merge (PR-FONT-FALLBACK + PR-THEME FINAL approved) |
| 7 | **Physical-device QA — RTL drawer direction** | Verify DrawerTheme `BorderRadiusDirectional` opens correctly in Arabic (RTL) layout — rounded corners on correct side | QA | Pre-**release** gate | ⏳ Deferred post-merge (PR-THEME FINAL approved) |
| 8 | **Physical-device QA — countdown tick + active prayer window** | Verify 44px countdown ticks live, 40-min post-prayer dhikr window transitions, themePreference toggle in Settings | QA | Pre-**release** gate | ⏳ Deferred post-merge |

---

## Rules

- **None of these block design or implementation PRs.** PR-THEME, PR2,
  PR4–PR9, PR-ONBOARD-AB, and PR-CLEANUP all proceed without them.
- **#1 + #2 (adhan):** PR-ADHAN stays paused until the audio file is
  provided. When it lands, drop `adhan.mp3` into `handoff_v2/assets/audio/`
  and PR-ADHAN converts + bundles it. Build must fail with a clear error if
  either platform file is missing — never ship silent fallback.
- **#3 (Calibri licence):** a submission gate only. Code ships with Calibri
  primary + Cairo fallback regardless. If licensing is denied, the fallback
  (Cairo) already covers Arabic; Latin would need a licensed alternative —
  but that is a future decision, not a current blocker.
- **#4 (device QA):** deferred per the product owner. Golden tests cover
  layout / sizing / RTL / locale. Device QA covers what goldens cannot —
  live ticking, window transitions, real font rasterization. **Must be
  re-flagged as a required gate before any release build.**

---

## How to retire an item

When an asset arrives or a gate clears, move its row out of the parking
lot and note the resolving PR + date here, so the history is auditable.

| Date | Item | Resolution |
|---|---|---|
| — | — | (none retired yet) |
