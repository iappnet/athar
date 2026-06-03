<!--
CANONICAL-FOR: docs/design-specs/ mirror provenance and sync state
OWNER:         Claude Code
LAST-UPDATED:  2026-06-02 · B2 complete — design-spec mirror synced; PRAYER_CARD_SPEC reconciled
LOADS-AT:      Tier 3 (reference only)
-->

# Design Specs Mirror — Sync Record

**Mirror location:** `docs/design-specs/` (inside athar Flutter project, git-tracked)  
**Authoritative base:** `/Users/itech/Development/new_projects/Athar Design System/handoff_v2-2/`  
**Sync date:** 2026-06-01 (Stage B2 initial) · 2026-06-02 (B2 complete)  
**Rule:** All files in this directory are READ-ONLY mirrors. No hand edits. If a spec changes, re-copy from the authoritative base and update this file.

**Sync log:**
- `2026-06-02` — design-specs mirror synced from handoff_v2-2 base @ 2026-06-02; PRAYER_CARD_SPEC reconciled from design SOURCE v2.2 @ 2026-06-01.
- `2026-06-02` — PRAYER_CARD_SPEC + IOS_WIDGETS_SPEC re-synced from SOURCE 2026-06-02: post-prayer window corrected from flat 40 min to dynamic formula (P9-C resolution). Canonical: `prayer_timer_service.dart:50–58`. PRAYER_CARD_SPEC §4/§10/§11/§12 updated; IOS_WIDGETS_SPEC §1e added.
- `2026-06-02` — ONBOARDING_AB_SPEC corrected (3 items, OQ rulings): (1) Variant B+C routing: SplashPage → /login (OQ3). (2) Variant D step 05: joinByCode → joinSpace(token) (OQ4). (3) Variant D step 02 module step: 6 toggles → 2 real toggles (Prayer+Dhikr) + 2 chips (Tasks+Habits always-included) + Health/Assets removed (OQ1).

---

## File Provenance

| File | Source | Notes |
|------|--------|-------|
| `ATHKAR_SPEC.md` | `handoff_v2-2/` | Read-only mirror |
| `CALENDAR_CELL_SPEC.md` | athar project root (PR4b) | Richer than handoff_v2-2 copy (131 vs 128 lines) — PR4b-annotated version used |
| `CALENDAR_FOCUS_REDESIGN.md` | athar project root (PR4b) | Richer than handoff_v2-2 copy (212 vs 194 lines) — PR4b-annotated version used |
| `CLAUDE_CODE_PROMPT.md` | `handoff_v2-2/` | Read-only mirror |
| `COMPONENT_SPECS.md` | `handoff_v2-2/` | Read-only mirror |
| `DESIGN_SYSTEM_GAP_VALIDATION.md` | `handoff_v2-2/` | Read-only mirror |
| `DUAL_DATE_SPEC.md` | athar project root (PR4b) | PR4b value object spec; no handoff_v2-2 counterpart |
| `FINAL_PACKAGE_MANIFEST.md` | `handoff_v2-2/` | Read-only mirror |
| `FOCUS_OIL_SPEC.md` | `handoff_v2-2/` | Read-only mirror |
| `HANDOFF.md` | `handoff_v2-2/` | Read-only mirror |
| `HIJRI_MONTH_ABBREVIATIONS.md` | athar project root (PR4b) | PR4b abbreviation table; no handoff_v2-2 counterpart |
| `INVESTIGATION_RECONCILIATION.md` | `handoff_v2-2/` | Read-only mirror |
| `INVESTIGATION_REPORT.md` | `handoff_v2-2/` | Read-only mirror |
| `IOS_WIDGETS_SPEC.md` | `handoff_v2-2/`; §1e added 2026-06-02 (post-prayer window, dynamic formula) | Read-only mirror |
| `IPAD_OPTIMIZATION.md` | `handoff_v2-2/` | Read-only mirror |
| `ONBOARDING_AB_SPEC.md` | `handoff_v2-2/` | Read-only mirror |
| `PACKAGE_A_DECISIONS.md` | `handoff_v2-2/` | Read-only mirror |
| `PACKAGE_C_DECISIONS.md` | `handoff_v2-2/` | Read-only mirror |
| `PRAYER_CARD_SPEC.md` | design SOURCE v2.2 @ 2026-06-01 (designer-provided, reconciled); §4/§10/§11/§12 corrected 2026-06-02 (flat 40 min → dynamic formula) | Supersedes handoff_v2-2 (104-line, stale 64px) and root (313-line, duplicated §8–10). Archives in `docs/history/handoff-duplicates/`. Read-only mirror. |
| `README.md` | `handoff_v2-2/` | Read-only mirror |
| `REDESIGN_AUDIT.md` | `handoff_v2-2/` | Read-only mirror |
| `SKILL.md` | `handoff_v2-2/` | Read-only mirror |
| `STATS_KPI_SPEC.md` | `handoff_v2-2/` | Read-only mirror |
| `THEME_DARK_SPEC.md` | `handoff_v2-2/` | Read-only mirror |

---

## PRAYER_CARD_SPEC Reconciliation Status

**Status: RESOLVED — 2026-06-01**

| Version | Location | Lines | Disposition |
|---------|----------|-------|-------------|
| **v2.2 CANONICAL** | `docs/design-specs/PRAYER_CARD_SPEC.md` | 330 | ✅ Active — read-only mirror |
| handoff_v2-2 copy | `docs/history/handoff-duplicates/handoff_v2-2_PRAYER_CARD_SPEC.md` | 104 | 🗄 Archived — stale (64px countdown) |
| athar root copy | `docs/history/handoff-duplicates/root_PRAYER_CARD_SPEC.md` | 313 | 🗄 Archived — superseded (duplicated §8–10 block) |
| design SOURCE | `/Athar Design System/PRAYER_CARD_SPEC.md` | 101 | Source only — not mirrored |

v2.2 fixes: shadow 20/8, RTL rescue, duplicate §8–10 removed, 44px countdown locked.

---

## Re-sync Procedure

If a spec is updated by the designer:
1. Designer updates the file in `/Athar Design System/handoff_v2-2/`
2. Copy to `docs/design-specs/` (overwrite)
3. Update `Last-Updated` in this file
4. Commit with message: `docs(design-specs): re-sync <filename> from handoff_v2-2`
