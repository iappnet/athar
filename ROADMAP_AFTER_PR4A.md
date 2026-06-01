<!--
CANONICAL-FOR: Next-arc guidance; ready PRs + architecture options post-PR4a
OWNER:         Claude Code
PRECEDENCE:    4 (Tier 1 — loads after Tier-0 on any PR arc)
LAST-UPDATED:  2026-06-01 · PR5 + PR6 complete + Stage A
LOADS-AT:      Tier 1
-->

# Roadmap After PR4a — Athar v2 Design System

**As of:** 2026-06-01  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Authoritative PR sequence:** `IMPLEMENTATION_MASTER_STATUS.md` (SINGLE SOURCE OF TRUTH for order, %, and status)

---

## Completed PRs

| PR | Commit | Tag | Date |
|----|--------|-----|------|
| PR1 — Tokens & Theme | `61d741a` | `athar-v2-pr1-complete` | 2026-05-09 |
| PR-THEME arc (initial + 3MODE + FONT-FALLBACK + FINAL) | `bfaf863` (final) | `athar-v2-prtheme-complete-final` | 2026-06-01 |
| PR2 — AdaptiveShell | `87ab36e` | `athar-v2-pr2-complete` | 2026-05-09 |
| PR3 — Prayer Card Refresh | `1cd4f80` | (in branch) | 2026-06-01 |
| **PR4a — Calendar Visual Refresh** | `85ada1e` | `athar-v2-pr4a-complete` | **2026-06-01** |

---

## Active PR

**None.** PR5 (`6154565`), PR6 (`2a6a46a`), and PR4b (`65fc417`) are all complete (2026-06-01).

---

## Next Recommended PR

| PR | Status | Entry requirement |
|----|--------|------------------|
| ~~PR5 — Accessibility Settings~~ | ✅ COMPLETE `6154565` | — |
| ~~PR6 — Stats Redesign~~ | ✅ COMPLETE `2a6a46a` | — |
| ~~PR4b — Calendar Dual-Display~~ | ✅ COMPLETE `65fc417` | — |
| PR8 — Focus Oil-Fill | 🔲 Ready | Read `FOCUS_OIL_SPEC.md`; designer review |
| PR9 — iOS Widget Visual Refresh | 🔲 Ready | None |
| Deferred QA sweep | 🔲 End of roadmap | After last feature PR; gates TestFlight/release |

---

## Blocked PRs

| PR | Blocker |
|----|---------|
| ~~PR4b — Calendar Dual-Display~~ | ✅ COMPLETE `65fc417` — unblocked. |
| PR-ADHAN | Audio asset from designer (not received) |
| PR7 — Athkar Feature | Designer review required |
| PR-ONBOARD-AB | Designer approval + read `ONBOARDING_AB_SPEC.md` |
| PR-CLEANUP | All other PRs must complete first |

---

## PR4b — Architecture LOCKED (2026-06-01)

Design authority approved **Option (b): new `CalendarMonthCubit`** for month-level aggregation.

### Locked decisions

| Decision | Value |
|----------|-------|
| Architecture | Option (b) — `CalendarMonthCubit` owns month aggregation + `DualDate` cache (`Map<DateTime, DualDate>`, midnight-normalized) |
| Day-selection | `CalendarCubit` unchanged — keeps day selection |
| `activityByDate` | Built from scratch in `CalendarMonthCubit`; PR4a did NOT build a month-level map (acknowledged added scope) |
| Dot sources | **5**: tasks, habits, appointments, medicines, prayer (per-prayer timed, each of 5 daily prayers is its own time-spot) |
| Prayer dot gating | Renders only when `isPrayerEnabled && showPrayerDotsOnCalendar`; `showPrayerDotsOnCalendar` = new `UserSettings bool`, default `true`, nested in Settings→Prayer only when `isPrayerEnabled==true`; added in PR4b's `build_runner` pass |
| `isHijriMode` | Reused in place — "Hijri is primary numeral in dual display." No new field. No migration concern (pre-launch). |
| Date pickers | KEEP current show-one behavior. Do NOT migrate in PR4b. |
| Hijri boundary cell | 3-letter abbreviation table — **propose table for designer approval before using** |
| Other-month cells | Render as disabled dual-numeral cells (text3, both dimmed). NOT empty `SizedBox`. |
| `DualMonthSwitcher` | DEFERRED. Keep chevron `_changeMonth(±1)` in PR4b. |
| Numeral position | Authority: `CALENDAR_CELL_SPEC.md` (top-center / bottom-center). `CALENDAR_FOCUS_REDESIGN.md` "top-right/bottom-left" superseded. |

~~**PR4b is BLOCKED — gated behind PR5 → PR6 → post-PR6 QA sweep.**~~ ✅ PR4b complete `65fc417`.

---

## Deferred QA Bucket

**Rule:** Deferred QA sweep runs at the **END of the roadmap, after the last feature PR**. No feature PR is gated by it. Nothing ships to a real user or TestFlight until the sweep passes.

| ID | Description | Origin PR | Candidate fix |
|----|-------------|-----------|--------------|
| PR3-R1 | Forest gradient prayer card — physical device dark mode render | PR3 | Visual verify on device |
| PR3-R2 | 44pt countdown legibility on SE (375×667) | PR3 | Visual verify; font-size adjustment if needed |
| PR4a-G1 | iPhone SE calendar overflow (6-row month at 64pt) | PR4a | Widen compact tier: `width<360` → `width<390` |
| PR4a-G2 | Today-state dark alpha legibility (0.13 on dark surface) | PR4a | Raise alpha: `0.13` → `0.15` |
| DEVICE | Forest-dark surfaces, Cairo fallback, RTL drawer, countdown tick | PR-THEME/PR2 | Visual device pass |

**Current count:** 5 of 10. Ceiling not yet reached.

All fixes in this bucket are **UNVERIFIED** — logical hypotheses that must be confirmed on a physical device before applying. None are "pre-approved."

---

## Open Blockers

| ID | Description | Severity | Blocks |
|----|-------------|----------|--------|
| B1 | Calibri App Store licence — designer must confirm | Medium | App Store submission |
| B4 | Adhan audio asset (not received) | Low | PR-ADHAN |
| PR4b-abbr | 3-letter Hijri month abbreviation table — propose + get approval | Medium | PR4b cell rendering |
| PR5-copy | Designer review of 3 accessibility ARB strings | Low | PR5 commit |
| Phase 5 | Physical device validation — all 3 iOS widgets | Release gate | Release |
