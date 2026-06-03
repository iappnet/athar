# Design System — Gap Validation

**Locked:** 2026-05-08
**Authority:** this document overrides all earlier wording about Cairo or Inter as Arabic / English primaries.

---

## 1 · Typography authority (locked)

**Calibri is the sole canonical brand typeface across the entire Athar
experience.** It is the official typography identity for:

- Arabic text
- English text
- UI chrome
- Headings (display + headline + title scales)
- Body text
- Onboarding (variants A/B/C/D)
- iOS + Android home-screen widgets
- The showcase (`Athar Brand System.html`, `ui_kits/athar_app/`)
- All component specs (`PRAYER_CARD_SPEC.md`, `CALENDAR_CELL_SPEC.md`,
  `ATHKAR_SPEC.md`, `IOS_WIDGETS_SPEC.md`, `STATS_KPI_SPEC.md`,
  `FOCUS_OIL_SPEC.md`, `CALENDAR_FOCUS_REDESIGN.md`, `COMPONENT_SPECS.md`)

Weights in use: **Light 300 / Regular 400 / Bold 700** (locally hosted
TTFs in `fonts/`).

### What Cairo is NOT

- Cairo is **not** the Arabic primary.
- Cairo is **not** the effective rendering font for Arabic.
- Cairo is **not** the "real" Arabic font behind a Calibri label.
- Arabic does **not** "fall through" to Cairo by design intention.

Cairo may appear **only** as a last-resort emergency technical fallback
inside a CSS font stack (`'Calibri', system-ui, sans-serif`), and only
to rescue glyph rendering if Calibri itself fails to load entirely.
It carries **no design authority**, must not be referenced as the
named primary in any spec, and must not be used in the design-system
documentation as the description of how Arabic actually renders.

The same applies to Inter for English: not a design-authority font,
not the effective English face, no longer present in any canonical
font stack.

### What `system-ui` / `sans-serif` are

Pure technical safety nets that activate only if Calibri itself fails
to load. They are not part of the typography identity.

---

## 2 · Font-asset-supply gap (separate from authority)

The bundled Calibri TTFs in `handoff_v2/fonts/` (`calibri-light.ttf`,
`calibri-regular.ttf`, `calibri-bold.ttf`) may have **limited Arabic
glyph coverage**. This is a **font-asset-supply limitation**, NOT a
typography-authority limitation.

Resolution path:

1. Source or commission a Calibri build (or a licensed Calibri-family
   variant) with full Arabic glyph coverage including required
   diacritics (fatha, kasra, damma, sukun, shadda, tanwin variants)
   and Arabic-Indic digit forms if `easternNumerals` is enabled.
2. Replace the three TTFs in `fonts/` in place. No spec changes
   required \u2014 the typography authority is already Calibri.
3. Verify glyph coverage with the Athkar reader (heaviest Arabic
   surface) and the Hijri calendar pills.

Until that asset arrives, glyphs that Calibri cannot render will fall
back to `system-ui` (the platform's Arabic system face on iOS / Android
/ Web). This is a **rendering-time fallback at the OS level**, not a
design-system endorsement of any other typeface.

---

## 3 · Verified canonical files (post-lockdown)

| File | State |
|---|---|
| `colors_and_type.css` | `--font-ar`, `--font-en`, `--font-ui`, `--font-heading`, `--font-body` all = `'Calibri', system-ui, sans-serif`. Cairo + Inter Google-Fonts imports removed. |
| `ui_kits/athar_app/Primitives.jsx` | `T.font` and `T.fontAr` both = `'Calibri', system-ui, sans-serif`. |
| `ui_kits/athar_app/index.html` | Embedded primitives synced. |
| `ipad/ipad-primitives.jsx` | All six `fontFamily:` declarations = `'Calibri, system-ui, sans-serif'`. |
| `Athar Brand System.html` | Cairo + Inter Google-Fonts import removed; all body/heading/wordmark `font-family` rules now Calibri-led; copy updated. |
| `assets/brand/wordmark-ar.svg` | Calibri 700. |
| `assets/brand/wordmark-en.svg` | Calibri 700. |
| `assets/brand/lockup.svg` | Calibri 700 (Arabic) + Calibri 400 (Latin caption). |
| `assets/brand/splash.svg` | Calibri 700 (mark) + Calibri 400 (tagline). |
| `ATHKAR_SPEC.md` | Dhikr card Arabic copy = "Calibri Bold (canonical)". |
| `CALENDAR_CELL_SPEC.md` | Hijri numeral + Hijri title + Hijri pills row all = "Calibri (sole canonical font)". |
| `CLAUDE_CODE_PROMPT.md` | PR1 token-port instruction names Calibri sole canonical; Cairo demoted to OS-level fallback. |
| `SKILL.md` § 2.3 | Type rules rewritten: Calibri sole canonical for Arabic + English. |
| `README.md` | Type summary + fonts caveat both rewritten. |
| `ONBOARDING_AB_SPEC.md` | Variant-B token list updated. |
| `PACKAGE_A_DECISIONS.md` | Decision #1 + Implications row updated. |

### NOT modified (intentional)

- `design-context/athar_typography.dart`, `design-context/app_theme.dart`
  \u2014 Flutter source code, read-only reference. Locked decisions in
  `CLAUDE_CODE_PROMPT.md` PR1 instruct Claude Code to update these as
  part of token port. Per scope rule: "Do NOT modify Flutter code."
- The `INVESTIGATION_REPORT.md` codebase audit \u2014 read-only history.

---

## 4 · How to interpret older wording

If you encounter, in older docs or legacy comments:

- "Cairo for Arabic" \u2192 read as **superseded**. Calibri is canonical.
- "Calibri primary, Cairo fallback" \u2192 read as **superseded**. Cairo is
  not a fallback in any design-authority sense; it has no role in the
  type system.
- "Inter for English" \u2192 read as **superseded**. Calibri is canonical
  for English too.
- "Cairo locked here regardless of B1 outcome" (Athkar reader) \u2192
  **superseded** by this document and Package A #1.

This document and `PACKAGE_A_DECISIONS.md` #1 jointly govern. In any
conflict between an older spec and these two, **these two win.**

---

## 5 · Implementation phase impact

**None.** No PR sequence change, no new PR, no resequencing. The token
port (PR1 \u2014 Tokens & Theme) already covers Calibri adoption in Dart
land. The QA matrix in `THEME_DARK_SPEC.md` is unchanged. The
implementation phases in `FINAL_PACKAGE_MANIFEST.md` are unchanged.

This is a **documentation lockdown**, not a design change.
