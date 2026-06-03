# PR3 Sign-off — Prayer Card Redesign

**Date:** 2026-06-01
**Branch:** `feat/athar-v2-pr1-tokens-theme`
**Accepted by:** Designer authority (Athar Design System)
**Status:** COMPLETE — approved for merge

---

## Accepted Deviations

| Item | Spec value | Implemented value | Decision |
|------|-----------|-------------------|----------|
| Shadow blurRadius (outer) | 42 | 20 | **Accepted** — shadow compression approved for phone DPI; 42 is excessive at mobile pixel density |
| Shadow blurRadius (inner) | 12 | 8 | **Accepted** — same rationale |
| Shadow offset (outer) | `Offset(0, 18)` | `Offset(0, 8)` | **Accepted** with compression |
| Shadow offset (inner) | `Offset(0, 4)` | `Offset(0, 2)` | **Accepted** with compression |

Shadow colors are correct and binding:
```dart
BoxShadow(color: Color(0xFF0F3D2E).withValues(alpha: 0.45), blurRadius: 20, offset: Offset(0, 8)),
BoxShadow(color: Color(0xFF1A5A45).withValues(alpha: 0.20), blurRadius: 8,  offset: Offset(0, 2)),
```

**Do not restore 42/12. These values are final.**

---

## Accepted Shadow Values (canonical)

```dart
boxShadow: [
  BoxShadow(
    color: AtharColors.prayerCardShadowDeep.withValues(alpha: 0.45),  // 0xFF0F3D2E
    blurRadius: 20,
    offset: const Offset(0, 8),
  ),
  BoxShadow(
    color: AtharColors.prayerCardShadowMid.withValues(alpha: 0.20),   // 0xFF1A5A45
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
],
```

These values are **locked**. Do not revisit in any future PR without explicit designer instruction.

---

## Live-Device QA

Live-device QA (countdown tick, 40-min transition, both locales, iPhone + iPad) is **deferred post-merge**.

It is not a merge blocker. The 16/16 golden suite (AR + EN, 8 scenarios) satisfies pre-merge visual verification.

---

## Remaining Non-Blocking Items

| Item | Owner | Target |
|------|-------|--------|
| `athar_dark_theme.dart` — 45 `fontFamily: Calibri` usages without `fontFamilyFallback: ['Cairo']` | PR-THEME | Before dark mode wires `isAutoModeEnabled → ThemeMode` |
| Calibri App Store licence (bug B1) | Legal/design | Submission gate — not a build blocker |
| ThemeMode wiring (`isAutoModeEnabled → ThemeMode`) | PR-THEME | Tracked in `KNOWN_PROBLEMS.md` bug B2 |

---

## PR3 Completion Confirmation

| Check | Status |
|-------|--------|
| All 8 `PR3_DESIGN_RULINGS.md` rulings implemented | ✅ |
| All 6 blockers (B1–B6) resolved | ✅ |
| adhanMoment absent (Phase 7 cancelled) | ✅ |
| Behavioral audit B1–B15 verified unchanged | ✅ |
| 16/16 golden tests pass (AR + EN) | ✅ |
| `flutter analyze` clean | ✅ |
| PR-FONT-FALLBACK: all 38 styles + extensions carry Cairo fallback | ✅ |
| Shadow values accepted at 20/8 | ✅ |

**PR3 is complete.**
