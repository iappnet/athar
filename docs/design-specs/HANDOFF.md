# HANDOFF — Athar Redesign

> **You are Claude Code.** Read this file completely before doing anything.
> This is the contract. Everything else is reference material.

---

## 0 · The two locations

You need both open at the same time:

1. **Flutter repo** — `iappnet/athar` on GitHub. Where Dart code lives.
   You write changes here.
2. **Design workspace** — the `Athar Design System` project (this folder).
   Where the visual targets, tokens, and specs live. You read from here.

If either is missing, stop and ask.

---

## 1 · Read in this order (non-negotiable)

1. `SKILL.md` — house rules, vocabulary, do-nots.
2. `colors_and_type.css` — the only source of truth for color & type tokens.
3. `PACKAGE_A_DECISIONS.md` — eight resolved designer decisions. Authoritative.
4. `REDESIGN_AUDIT.md` — per-screen ticket list mapping mockups → Dart files.
5. `CALENDAR_FOCUS_REDESIGN.md` — Calendar (dual Hijri/Gregorian) + Focus brief.
6. `FOCUS_OIL_SPEC.md` — full spec for the Focus oil-fill animation (the hero).
7. `IPAD_OPTIMIZATION.md` — adaptive shell, breakpoints, per-screen iPad layouts.
8. `COMPONENT_SPECS.md` — EmptyState, ErrorState, SyncStatusCard, role chips, numericMono, ModuleFlags, PrayerToggleTile, form primitives.
9. `PRAYER_CARD_SPEC.md` — readable spec for the prayer card (compact + expanded).
10. `CALENDAR_CELL_SPEC.md` — pixel-exact dual-numeral cell + DualCalendarHeader.
11. `ATHKAR_SPEC.md` — full UX spec for the athkar feature (net-new).
12. `IOS_WIDGETS_SPEC.md` — three widgets × three sizes, gated on `isPrayerEnabled`.
13. `STATS_KPI_SPEC.md` — Tier-1 + Tier-2 KPIs, components, period selector.
14. `design-context/_manifest.json` — what's already in the codebase.
15. `design-context/_core_extract.dart` — current theme/token values.

Visual targets (look at these — port the visuals, not the JS code):
- `Athar Brand System.html` — palette, type, logo, motion principles.
- `ui_kits/athar_app/index.html` — every screen, in iPhone form factor.
- `ipad/*.html` — iPad portrait + landscape compositions.
- `preview/*.html` — individual component specs (prayer card, buttons, chips, …).

---

## 2 · Architecture rules (one-liners — break any of these and the PR is rejected)

- Clean Architecture per feature: `domain` / `data` / `presentation`.
- State: `flutter_bloc` Cubits only. No `setState` in feature widgets.
- DI: `GetIt` + `injectable`. Every service registered, no `new` in widgets.
- Storage: Isar local → Supabase sync. Never bypass the repository.
- Tokens only: no raw hex, no raw `EdgeInsets.all(16)` — use `AppColors` /
  `AppSpacing` / `AppText`.
- Permission-gate every space-scoped write through `SpacePermissionGuard`.
- Notifications go through per-domain schedulers (`PrayerScheduler`,
  `HabitScheduler`, etc.) — never call `flutter_local_notifications` directly
  from a widget.
- All user-facing strings live in `app_ar.arb` + `app_en.arb`. No hardcoded
  copy in widgets.
- Every screen wraps in `AdaptiveShell` (see `IPAD_OPTIMIZATION.md`) and uses
  `LayoutBuilder` for breakpoints — never check `Platform.isIPad` for layout.
- RTL: use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end` —
  never `left`/`right`.

---

## 3 · Build order

Do not skip ahead. Each step must be merged + reviewed before the next.

1. **Tokens & theme** — port `colors_and_type.css` into `app_colors.dart` /
   `app_text.dart` / `app_spacing.dart`. Wire Calibri (light/regular/bold).
2. **AdaptiveShell** — `lib/core/widgets/adaptive_shell.dart` per
   `IPAD_OPTIMIZATION.md`. Verify on iPhone, iPad portrait, iPad landscape.
3. **Dashboard** — including the new prayer card (`comp-prayer-card.html`).
4. **Tasks** — list, sheet, sections.
5. **Habits** — grid, streak ring, weekly view.
6. **Calendar** — dual Hijri+Gregorian per `CALENDAR_FOCUS_REDESIGN.md`.
7. **Focus** — oil-fill animation per `FOCUS_OIL_SPEC.md`. **This is the hero;
   take the time to get it right.**
8. **Stats** — charts, exports.
9. **Settings** — feature toggles, profile, motion prefs.
10. **Spaces** — share, members, permissions.
11. **Onboarding** — first-run flow.

---

## 4 · Per-feature workflow (mandatory)

For **every** feature, follow this:

### Step A — Audit
Before touching code, write `design-context/_audit_<feature>.md`:
1. **Files inspected** (paths + line ranges).
2. **What's already there** matching the spec (✅).
3. **Gaps** — exact file/line where each change goes (❌).
4. **Open questions** — anything ambiguous; do not guess.

Push the audit. **Wait for designer sign-off** before Step B.

### Step B — Implement
Per the audit, smallest-PR-possible. One feature per PR.

### Step C — Definition of Done
Tick every box before opening the PR:

- [ ] Builds clean, no analyzer warnings.
- [ ] Dark mode + light mode pixel-checked.
- [ ] RTL (Arabic) + LTR (English) pixel-checked.
- [ ] iPhone 12 + iPad 11" portrait + iPad 12.9" landscape.
- [ ] No hardcoded hex / spacing / strings.
- [ ] Every mutation is permission-gated.
- [ ] Every notification routes through a scheduler.
- [ ] Cubit unit tests for new state transitions.
- [ ] Golden test for at least the iPhone variant.

---

## 5 · Hero details — do not skim

- **Prayer card** (Dashboard) — forest→teal glass gradient, live H:MM:SS
  countdown in mono numerals, Hijri-prominent date, all-five-prayers strip
  with past/next states, sunrise/sunset arc, progress bar. Reference:
  `preview/comp-prayer-card.html`, `ui_kits/athar_app/Dashboard.jsx`.
- **Calendar** — dual Hijri + Gregorian numerals **in every cell**
  simultaneously (Apple Calendar style), not a toggle. Hairline marks the
  first day of each Hijri month. Day sheet shows both:
  `Wed, 15 Jan · ١٥ رجب`. Spec: `CALENDAR_FOCUS_REDESIGN.md`.
- **Focus** — oil barrel filling from bottom, drips from Dynamic Island,
  gyroscope sloshing, four time-pressure tiers. Spec: `FOCUS_OIL_SPEC.md`.
  Performance budget: 60 fps on iPhone 12.
- **iPad** — `AdaptiveShell` is mandatory. Phone = bottom tabs; iPad portrait
  = sidebar + content; iPad landscape = sidebar + content + detail (split
  view). Spec: `IPAD_OPTIMIZATION.md`.

---

## 6 · When in doubt

- **Visual unclear?** Open the matching `preview/*.html` or
  `ui_kits/athar_app/*.jsx`. If still unclear, ask in the audit's Open
  Questions section. Do not guess.
- **Architecture unclear?** Re-read `SKILL.md`. If still unclear, ask.
- **Token missing?** Add it to `colors_and_type.css` first, then
  `app_*.dart`. Never bypass.
- **Spec contradicts code?** The spec wins. Open a question.

---

## 7 · The prompt to start

You can begin with:

> Read `HANDOFF.md`, then `SKILL.md`, then `colors_and_type.css`, then
> `REDESIGN_AUDIT.md`. Produce `design-context/_audit_tokens.md` covering
> Step 1 (Tokens & theme). Do not write any Dart yet.

That kicks off Phase 1. Each subsequent phase follows the same audit-first
pattern.
