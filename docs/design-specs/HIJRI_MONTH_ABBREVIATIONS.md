# Hijri Month Abbreviations — Calendar Boundary Cells

**Author:** Claude Design (design authority)
**Date:** 2026-06-01
**Resolves:** open decision **`PR4b-abbr`** (the 3-letter Hijri month abbreviation table)
**Consumed by:** `CALENDAR_CELL_SPEC.md` (boundary/adjacent-month cells) + `DUAL_DATE_SPEC.md` (PR4b)
**Scope:** abbreviations shown **only** in leading/trailing (other-month) calendar cells. The in-month header always uses the **full** month name — never abbreviate the primary header.

---

## The table

| # | Hijri month (Arabic, full) | Transliteration | **Latin (3-char)** | **Arabic compact** |
|---|---|---|---|---|
| 1 | محرم | Muḥarram | `Muh` | محرم |
| 2 | صفر | Ṣafar | `Saf` | صفر |
| 3 | ربيع الأول | Rabīʿ al-Awwal | `Rb1` | ربيع ١ |
| 4 | ربيع الآخر | Rabīʿ al-Ākhir (al-Thānī) | `Rb2` | ربيع ٢ |
| 5 | جمادى الأولى | Jumādā al-Ūlā | `Jm1` | جمادى ١ |
| 6 | جمادى الآخرة | Jumādā al-Ākhirah (al-Thāniyah) | `Jm2` | جمادى ٢ |
| 7 | رجب | Rajab | `Raj` | رجب |
| 8 | شعبان | Shaʿbān | `Sha` | شعبان |
| 9 | رمضان | Ramaḍān | `Ram` | رمضان |
| 10 | شوال | Shawwāl | `Shw` | شوال |
| 11 | ذو القعدة | Dhū al-Qaʿdah | `DhQ` | ذو القعدة |
| 12 | ذو الحجة | Dhū al-Ḥijjah | `DhH` | ذو الحجة |

All 12 Latin tokens are exactly 3 characters and mutually unique.

---

## Design rulings (the *why*, so this never gets re-litigated)

### Latin abbreviations
- **Fixed 3 characters, Title-case, no trailing period.** Uniform width keeps boundary cells visually even.
- **The two Rabīʿ and two Jumādā months disambiguate with a trailing ordinal digit (`1`/`2`), not letters.** Letter-only truncation collides (`Rab`/`Rab`, `Jum`/`Jum`); the digit guarantees uniqueness *and* the fixed 3-char width. `Rb1 Rb2 Jm1 Jm2`.
- **`Dhū al-Qaʿdah` / `Dhū al-Ḥijjah` → `DhQ` / `DhH`** — `Dh` + the capital initial of the distinguishing word (`Q`/`H`). Reads cleanly, stays 3 chars.
- Collision check (all unique): `Muh Saf Rb1 Rb2 Jm1 Jm2 Raj Sha Ram Shw DhQ DhH`. Note `Sha` (Shaʿbān) ≠ `Shw` (Shawwāl).

### Arabic abbreviations
- **Arabic is *not* truncated to 3 letters.** Letter-count truncation is non-idiomatic and unreadable in Arabic script (it breaks ligatures and connected forms). Instead, Arabic boundary cells use the **shortest unambiguous whole-word form.**
- Most months are already short and stand alone (محرم، صفر، رجب، شعبان، رمضان، شوال).
- **The two Rabīʿ and two Jumādā disambiguate with the Eastern-Arabic ordinal digit `١`/`٢`** (`ربيع ١`، `ربيع ٢`، `جمادى ١`، `جمادى ٢`).
- **`ذو القعدة` / `ذو الحجة` stay whole** — they are visually distinct and short enough for a boundary label. *Only* if a cell is truly width-constrained, fall back to `ذو ق` / `ذو ح` with a thin space (`U+2009`). Prefer the whole form.

### Numerals (ties to existing settings)
- Ordinal digits follow the active numeral system: **Arabic-primary → `١`/`٢`** (and respects `easternNumerals`); **Latin → `1`/`2`**.
- Which script's abbreviation is shown follows `isHijriMode` / the dual-display primary, consistent with `DUAL_DATE_SPEC.md`.

### Usage rules
1. Abbreviations appear **only** in other-month (leading/trailing) cells of the dual calendar grid — never in the in-month header, never in the selected-day detail.
2. The full month name is always used for the header and any standalone month label.
3. Latin tokens never localize case (always Title-case); Arabic forms never reorder (RTL shaping handles direction).
4. Boundary cells render the abbreviation in the dimmed/other-month treatment per `CALENDAR_CELL_SPEC.md`.

---

## Optional alternative (if you prefer Roman ordinals)

If the team prefers Roman numerals for the paired months, swap `Rb1/Rb2/Jm1/Jm2` → `RbI/RbII/JmI/JmII`. **Not recommended** — `RbII`/`JmII` are 4 chars and break the fixed-width rule. The digit form is the design default. Say the word if you want the Roman variant instead.
