# Athar Redesign — Final Package Manifest

**Package version:** v2 · canonical
**Locked:** 2026-05-08
**Status:** implementation-ready

### Changelog

- **2026-05-08** — Bottom-nav shape locked (see *Bottom nav (locked)* below). FAB is a **standalone pill outside** the liquid-glass bar, **right of bar in LTR / left of bar in RTL**. Updates: `PACKAGE_C_DECISIONS.md` #2, `REDESIGN_AUDIT.md` §11, `IPAD_OPTIMIZATION.md` rail rule, `preview/comp-nav.html`. No PR resequencing.
- **2026-05-07** — Typography authority lockdown (Calibri sole canonical for Arabic + English).

---

## Required read order (Claude Code)

1. `INVESTIGATION_RECONCILIATION.md` — locks all decisions; supersedes older specs.
2. `DESIGN_SYSTEM_GAP_VALIDATION.md` — **typography authority lockdown** (Calibri sole canonical, Arabic + English).
3. `INVESTIGATION_REPORT.md` — read-only codebase audit (source of truth for what exists).
4. `PACKAGE_A_DECISIONS.md`
5. `PACKAGE_C_DECISIONS.md`
6. `REDESIGN_AUDIT.md`
7. `IPAD_OPTIMIZATION.md`
8. `THEME_DARK_SPEC.md`
9. `SKILL.md`
10. `colors_and_type.css`
11. `Athar Brand System.html`
12. Component specs: `COMPONENT_SPECS.md`, `PRAYER_CARD_SPEC.md`, `CALENDAR_CELL_SPEC.md`, `ATHKAR_SPEC.md`, `IOS_WIDGETS_SPEC.md`, `STATS_KPI_SPEC.md`, `FOCUS_OIL_SPEC.md`, `CALENDAR_FOCUS_REDESIGN.md`, `ONBOARDING_AB_SPEC.md`.
13. Visual references: `ui_kits/athar_app/index.html`, `preview/*.html`.

---

## Entry points

- **Main implementation handoff:** `CLAUDE_CODE_PROMPT.md`
- **Main onboarding spec:** `ONBOARDING_AB_SPEC.md`
- **Main showcase entry:** `ui_kits/athar_app/index.html` (full mobile UI kit)
- **Brand showcase entry:** `Athar Brand System.html`
- **Component previews:** `preview/*.html` (19 files, offline-readable)

---

## Package structure

```
handoff_v2/
├── CLAUDE_CODE_PROMPT.md             ← paste into Claude Code
├── INVESTIGATION_RECONCILIATION.md   ← locked decisions (read first)
├── DESIGN_SYSTEM_GAP_VALIDATION.md   ← typography authority lockdown
├── INVESTIGATION_REPORT.md           ← read-only codebase audit
├── REDESIGN_AUDIT.md                 ← per-screen ticket map
├── ONBOARDING_AB_SPEC.md             ← 4-variant A/B/C/D plan
├── IPAD_OPTIMIZATION.md
├── THEME_DARK_SPEC.md
├── SKILL.md                          ← design-system rules
├── HANDOFF.md                        ← original handoff overview
├── README.md
├── PACKAGE_A_DECISIONS.md
├── PACKAGE_C_DECISIONS.md
├── COMPONENT_SPECS.md
├── PRAYER_CARD_SPEC.md
├── CALENDAR_CELL_SPEC.md
├── CALENDAR_FOCUS_REDESIGN.md
├── ATHKAR_SPEC.md
├── IOS_WIDGETS_SPEC.md
├── STATS_KPI_SPEC.md
├── FOCUS_OIL_SPEC.md
├── FINAL_PACKAGE_MANIFEST.md         ← this file
├── colors_and_type.css               ← CSS tokens (port to Dart)
├── Athar Brand System.html           ← brand showcase
│
├── assets/
│   ├── audio/adhan.mp3               ← Hamad Al-Daghriri recitation (Android raw / convert to CAF for iOS)
│   └── brand/                        ← logo, wordmarks, app icon (10 files)
│
├── fonts/                            ← Calibri Light/Regular/Bold TTFs
│
├── design-context/                   ← original Dart token files (15 files)
│
├── preview/                          ← 19 component previews (offline)
│
├── ui_kits/athar_app/                ← full JSX mobile UI kit (13 files)
│
└── ipad/                             ← iPad layout primitives
```

---

## Onboarding variants summary

| Variant | Slides | Visuals | Setup | Status |
|---|---|---|---|---|
| **A — Existing (control)** | 4 | original | none | UNTOUCHED — UX authority |
| **B — Existing-restyled** | 4 | new tokens | none | structure/pacing/nav match A exactly |
| **C — Short** | 2 | new tokens | none | ultra-low-friction |
| **D — Expanded** | 6 | new tokens | location + notifications + lightweight modules + reduced spaces step | calm + emotionally grounded |

**Locked sub-decisions:**
- Variant D Dhikr default = **OFF** (do not auto-enable spiritual modules).
- Variant D Spaces step **reduced**: "Just for me" pre-selected; "Create shared space" removed (deferred in-product); only "Just for me" + "Join with code" visible.
- Routing: 25/25/25/25 deterministic by `device_id` hash via new `OnboardingVariantService`.
- Persistence: existing `onboarding_seen` key (gate) + new `onboarding_variant` key (assignment).
- Analytics: **Supabase events only** — no Firebase, no Mixpanel, no new SDKs.
- QA override: `--dart-define=ONBOARDING_VARIANT=existing|existing_restyled|short|expanded`.

---

## Implementation phases (PR sequence)

| PR | Scope |
|---|---|
| PR1 | Tokens & Theme — port `colors_and_type.css` values into existing Dart token files |
| PR-THEME | Wire `UserSettings.isAutoModeEnabled` → `ThemeMode.system` (3 lines in `app.dart:162–172`) |
| PR2 | Rename `adaptive_scaffold.dart` → `adaptive_shell.dart`; implement breakpoints |
| PR3 | Prayer card refresh — reuse `UserSettings.prayerCardDisplayMode`; compact/expanded as widget-local state |
| PR-ADHAN | Bundle `adhan.mp3` (Android raw) + convert to `adhan.caf` (iOS Resources); fail build if absent |
| PR4a | Calendar visual refresh — keep toggle widget; extend `CalendarCubit.selectDate` to fan-in 4 sources (tasks + appointments + habits + prayer adherence) |
| PR4b | Calendar dual-display rebuild — `DualDate` VO + new `CalendarCell` + `DualMonthSwitcher`; delete `dual_calendar_widget.dart` |
| PR5 | Settings: Accessibility section (Reduce Motion, Disable Gyroscope, Eastern Numerals OFF default) |
| PR6 | Stats redesign — refactor visuals + extend `StatsRepository` (cubit + page exist) |
| PR7 | Athkar feature (NET-NEW; curated sets v1) — pause for designer review before screens |
| PR8 | Focus screen oil-fill — respect Reduce Motion; carve-out for `oil_animation.dart` + `fluid_engine.dart` |
| PR9 | iOS widgets refresh — visuals only; App Group + WidgetKeys exist |
| PR-ONBOARD-AB | Four-variant onboarding test — DO NOT modify `onboarding_page.dart` |
| PR-CLEANUP | Hardcoded color sweep for files NOT touched by other PRs |

After each PR: run analyzer + `flutter test`; open with before/after screenshots; designer approval gate.

---

## Adhan asset wiring

- **Source:** `assets/audio/adhan.mp3` (Hamad Al-Daghriri recitation, included in package)
- **Android:** copy to `android/app/src/main/res/raw/adhan.mp3`. `RawResourceAndroidNotificationSound('adhan')` resolves automatically.
- **iOS:** convert with `afconvert -f caff -d LEI16@22050 adhan.mp3 adhan.caf`, place at `ios/Runner/Resources/adhan.caf`, add to Copy Bundle Resources.
- **Build gate:** PR-ADHAN must fail with a clear error if either platform file is missing.
- **User-selectable adhan tracks:** v2 (out of scope for this handoff).

---

## Verified package contents

✅ All 19 specs included
✅ `INVESTIGATION_REPORT.md` included (was missing from v1, added)
✅ `DESIGN_SYSTEM_GAP_VALIDATION.md` added — locks Calibri as sole canonical brand font for both Arabic and English
✅ All 4 onboarding variants documented in `ONBOARDING_AB_SPEC.md`
✅ Design tokens (`colors_and_type.css` + 15 Dart context files)
✅ All 19 component previews in `preview/`
✅ Full JSX UI kit in `ui_kits/athar_app/`
✅ Brand assets (10 files in `assets/brand/`)
✅ Audio asset (`assets/audio/adhan.mp3`)
✅ Calibri TTFs (Light + Regular + Bold)
✅ Brand showcase (`Athar Brand System.html`)

## Bottom nav (locked)

The bottom nav is a **liquid-glass tab bar** holding **only the four
destinations** (Dashboard / Tasks / Habits / Spaces). The quick-add
**"+" FAB is a separate floating pill *outside* the bar**, sitting
beside it with a small gap.

| Direction | Bar position | FAB position |
|---|---|---|
| **LTR (English)** | Leading (left) | **Trailing — right of the bar** |
| **RTL (Arabic)** | Leading (right) | **Trailing — left of the bar** |

**Bar treatment** (liquid glass): 28px backdrop blur · 180% saturation ·
layered translucent fill (`.42 → .22` vertical) · top specular highlight ·
1px inner-ring edge · soft outer shadow.

**FAB treatment:** 64×64, 22px radius, `primary` linear gradient
(`#2F7A5E → #0F3D2E`), `shadow.lg` ambient + brand-tinted drop, white
"+" glyph.

**Rules:**
- **Never centered.** No notch, no `BottomNavigationBar`.
- **Never forked.** Refactor `liquid_glass_nav_bar.dart` in place; the
  FAB is its sibling widget, not a child.
- **Direction-driven.** Layout flows from inherited `Directionality` —
  do not hard-code `left:` / `right:`.
- On tablet+, the same FAB widget moves into
  `NavigationRail.leading:` (per `IPAD_OPTIMIZATION.md`); the bar itself
  is hidden on tablet because the rail replaces it.

**Reference mock:** `preview/comp-nav.html` (shows both LTR and RTL
side-by-side over a tinted ground so the glass refraction reads).

---

## Typography authority (locked)

**Calibri is the sole canonical brand typeface for the entire Athar
experience — Arabic AND English, across UI, headings, body text,
onboarding, widgets, showcase, and specs.** Cairo and Inter are NOT
design-authority fonts; they may appear only as last-resort emergency
technical fallbacks at the OS level if Calibri itself fails to load.
See `DESIGN_SYSTEM_GAP_VALIDATION.md` for the full lockdown statement
and the list of every file updated.

If the bundled Calibri TTFs in `fonts/` lack full Arabic glyph
coverage, that is a **font-asset-supply gap** (resolve by sourcing a
Calibri build with Arabic coverage), NOT a typography-authority
limitation. Implementation phases unchanged.

## Verified contradictions cleared

✅ `prayerCardVariant` references in `PRAYER_CARD_SPEC.md`, `IOS_WIDGETS_SPEC.md`, `PACKAGE_A_DECISIONS.md` — all corrected to point at the existing `UserSettings.prayerCardDisplayMode` + widget-local compact/expanded state.
✅ `lib/features/onboarding/` reference in `IPAD_OPTIMIZATION.md` — corrected to point at the in-place page + new variant pages.
✅ Three-variant routing (33/33/34) replaced with four-variant (25/25/25/25) throughout.
✅ Remaining mentions of `prayerCardVariant` / `features/onboarding/` are intentional — they appear only in the original `INVESTIGATION_REPORT.md` (read-only audit), the `INVESTIGATION_RECONCILIATION.md` table that explicitly tells Claude Code NOT to use them, and the `CLAUDE_CODE_PROMPT.md` "do not introduce" rules.

---

## Remaining blockers (non-blocking for handoff, tracked)

1. **Variant B animation parity** — should restyled hero animations match Variant A's exact pacing, or be richer? Spec recommends strict parity (animation is part of pacing). Designer to confirm.
2. **Hardcoded Arabic literal** at `habit_cubit.dart:321` (`"أذكار ما بعد الصلاة"`) — needs ARB extraction.
3. **Subscription paywall copy** — Arabic translations + design sign-off pending.
4. **Habit widget empty state** — what shows when only `HabitType.athkar` habits exist?
5. **Error-state pattern** — pick canonical pattern (snackbar / screen / dialog) and document in `SKILL.md`.
6. **Loading skeleton coverage** — `AtharSkeleton` exists but most features use `CircularProgressIndicator`.
7. **iOS CAF conversion** — must run `afconvert` on macOS before iOS build; document in repo's `ios/README.md`.

None block PR1–PR-ADHAN. Items 2–6 surface during their respective PRs.

---

## Final readiness verdict

**READY FOR CLAUDE CODE.** Package is canonical, self-contained, offline-readable, governance-aligned, and contradictions are resolved. Open `CLAUDE_CODE_PROMPT.md`, paste into Claude Code with both repos mounted, follow the read order.
