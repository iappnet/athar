<!--
CANONICAL-FOR: Target documentation directory architecture for Stage B (clean structure)
OWNER:         Claude Design
PRECEDENCE:    off-ladder (governance reference — describes post-Stage-B target state)
LAST-UPDATED:  2026-06-01 · Stage A
LOADS-AT:      off-ladder (read when planning Stage B moves)
-->

# Athar — Final Documentation Architecture

**Author:** Claude Design (design authority)
**Date:** 2026-06-01
**Status:** Proposal — architecture & planning only. No file is moved, renamed, or deleted by this document.
**Companion files:** `ATHAR_FINAL_KNOWLEDGE_ARCHITECTURE.md` (logical domains), `ATHAR_CANONICAL_SOURCE_MAP.md` (lookup), `ATHAR_DOCUMENTATION_GOVERNANCE_RULES.md` (rules), `ATHAR_AI_CONTEXT_STRATEGY.md` (loading), `ATHAR_DOCUMENTATION_MIGRATION_PLAN.md` (transition).

> This file owns the **physical layout**: the folder tree, the `.claude/` structure, file-naming conventions, and the source-vs-mirror rule for design specs. It does **not** restate domain ownership (see Knowledge Architecture) or loading tiers (see AI Context Strategy).

---

## 1. Design goals (what the layout must guarantee)

1. **A small, fixed set of always-true "living" files** at predictable paths — so an agent never hunts for the truth.
2. **A large, immutable "history" tree** that is never auto-loaded and never edited — so the past is preserved without polluting the present.
3. **Design specs have exactly one source and one repo mirror** — so the `root/ vs handoff_v2-2/` class of drift cannot recur.
4. **Stable, intent-named files** — never point-in-time names (`ROADMAP_AFTER_PR4A`) for living docs, so a file never becomes "named for a moment that has passed."
5. **The same five paths are canonical for the life of the project** — the system survives PR6 → PR40 without re-architecture.

---

## 2. The three zones

Every documentation file belongs to exactly one zone. The zone determines its path, mutability, and whether AI may auto-load it.

| Zone | Meaning | Mutability | Auto-loaded? |
|---|---|---|---|
| **LIVING** | Current truth. ~20 files. | Edited in place | Yes (per tier) |
| **SOURCE** | Design specs authored by the designer. | Edited at source only | On demand (design PRs) |
| **HISTORY** | Frozen artifacts: completed PR reports, superseded audits, session snapshots, change logs. | Immutable | Never |

The single most important structural rule: **a file moves from LIVING/SOURCE into HISTORY exactly once, and never moves back.** Promotion to history is a one-way door (see Governance §Lifecycle).

---

## 3. Target folder tree (Flutter repo: `/athar/`)

```
/athar/
│
├── CLAUDE.md                          ⟵ LIVING · always loaded · session contract
├── README.md                          ⟵ LIVING · minimal project readme
│
├── docs/
│   ├── status/                        ⟵ LIVING · the "truth" tier (was scattered at root)
│   │   ├── ROADMAP.md                 ⟵ SSOT: PR sequence + % + blockers   (was IMPLEMENTATION_MASTER_STATUS.md)
│   │   ├── MIGRATION_STATE.md         ⟵ SSOT: branch evidence + RULE 1/2 + Deferred QA   (was CURRENT_MIGRATION_STATE.md)
│   │   └── NEXT_STEPS.md              ⟵ next-arc guidance, living   (was ROADMAP_AFTER_PR4A.md)
│   │
│   ├── progress/
│   │   └── CHECKPOINT.md              ⟵ LIVING · session resume · single file · Tier 0
│   │
│   ├── ai/                            ⟵ LIVING · Claude Code reference indexes
│   │   ├── KNOWN_PROBLEMS.md          ⟵ Tier 0
│   │   ├── AI_WORKFLOW.md
│   │   ├── FEATURE_INDEX.md           ⟵ (absorbs FILE_INDEX.md)
│   │   ├── ARCHITECTURE_INDEX.md
│   │   ├── STATE_MANAGEMENT_INDEX.md
│   │   ├── DATA_FLOW_INDEX.md
│   │   ├── STATS_ENGINE_INDEX.md
│   │   ├── SUPABASE_INDEX.md
│   │   ├── WIDGET_INDEX.md
│   │   └── PROJECT_MAP.md
│   │
│   ├── governance/                    ⟵ LIVING · the rules-of-the-system (this audit's output lands here)
│   │   ├── DOCUMENTATION_ARCHITECTURE.md   ⟵ this file (installed copy)
│   │   ├── KNOWLEDGE_ARCHITECTURE.md
│   │   ├── CANONICAL_SOURCE_MAP.md
│   │   ├── GOVERNANCE_RULES.md
│   │   ├── AI_CONTEXT_STRATEGY.md
│   │   └── MIGRATION_PLAN.md
│   │
│   ├── design-specs/                  ⟵ SOURCE-MIRROR · the ONE repo copy of design specs (was handoff_v2-2/)
│   │   ├── _SYNC.md                   ⟵ records source commit/date this mirror was synced from
│   │   ├── HANDOFF.md
│   │   ├── INVESTIGATION_RECONCILIATION.md
│   │   ├── SKILL.md
│   │   ├── REDESIGN_AUDIT.md
│   │   ├── colors_and_type.css
│   │   ├── THEME_DARK_SPEC.md
│   │   ├── DESIGN_SYSTEM_GAP_VALIDATION.md
│   │   ├── PACKAGE_A_DECISIONS.md
│   │   ├── PACKAGE_C_DECISIONS.md
│   │   ├── COMPONENT_SPECS.md
│   │   ├── STATS_KPI_SPEC.md          ⟵ PR6
│   │   ├── CALENDAR_CELL_SPEC.md      ⟵ PR4b
│   │   ├── CALENDAR_FOCUS_REDESIGN.md ⟵ PR4b
│   │   ├── DUAL_DATE_SPEC.md          ⟵ PR4b (moves here from root)
│   │   ├── ATHKAR_SPEC.md             ⟵ PR7
│   │   ├── FOCUS_OIL_SPEC.md          ⟵ PR8
│   │   ├── IOS_WIDGETS_SPEC.md        ⟵ PR9
│   │   ├── ONBOARDING_AB_SPEC.md      ⟵ PR-ONBOARD-AB
│   │   ├── IPAD_OPTIMIZATION.md
│   │   ├── PRAYER_CARD_SPEC.md        ⟵ re-synced from source (resolves 313/104 conflict)
│   │   ├── FINAL_PACKAGE_MANIFEST.md
│   │   └── INVESTIGATION_REPORT.md    ⟵ read-only codebase audit
│   │
│   ├── design-context/                ⟵ LIVING (active only) · pre-implementation audits
│   │   ├── _audit_<pr>.md             ⟵ the audit for each in-flight PR
│   │   └── (signed-off audits promote to docs/history/pr-audits/)
│   │
│   └── history/                       ⟵ HISTORY · immutable · never auto-loaded
│       ├── ARCHIVE_INDEX.md           ⟵ the only file here that is maintained
│       ├── pr-reports/                ⟵ completed PR reports + verification + sign-offs
│       ├── pr-audits/                 ⟵ audits of shipped PRs
│       ├── handoff-duplicates/        ⟵ root copies of design specs
│       ├── widget-phase/              ⟵ Phase 0–5 widget history
│       ├── phase0-audits/             ⟵ pre-PR1 design-context
│       ├── session-reports/           ⟵ one-off snapshots
│       └── change-logs/               ⟵ the 21 dated change logs
│
└── .claude/                           ⟵ LIVING · Claude Code operational config
    ├── settings.local.json
    ├── CONTEXT_TIERS.md               ⟵ NEW · the canonical loading manifest (Tier 0–3)
    └── commands/
        ├── analyze-feature.md
        ├── audit-stats.md
        ├── audit-widget.md
        ├── fix-bug.md
        ├── update-ai-index.md
        └── drift-check.md             ⟵ NEW · pre-sign-off Tier-0 agreement check
```

### What changed vs today and why

- **`docs/status/` collects the three roadmap/state files** that were loose at repo root. They were hard to find among ~63 root files; grouping them makes the truth tier obvious.
- **Root is nearly empty** (`CLAUDE.md`, `README.md` only). The ~60 loose root `.md` files are either promoted into `docs/status|governance` or moved to `docs/history/`.
- **`handoff_v2-2/` becomes `docs/design-specs/`** — one mirror, inside the repo's `docs/` tree, with a `_SYNC.md` provenance stamp. The `/Athar Design System/` root copies are archived to `docs/history/handoff-duplicates/`.
- **`docs/governance/` is new** — it holds this six-file system so the rules live *with* the project, not in a chat.
- **`.claude/CONTEXT_TIERS.md` + `commands/drift-check.md` are new** — they make the loading model and the drift gate executable, not just documented.

> **The tree shows the adopted canonical names** (`ROADMAP.md`, `MIGRATION_STATE.md`, `NEXT_STEPS.md`, `ARCHIVE_INDEX.md`, `design-specs/`). They are reached via **Tombstone Migration**, not bare rename (see `GOVERNANCE_RULES.md` §2b and `MIGRATION_PLAN.md` Rev 3): the new file is created at the canonical path, the old file (`IMPLEMENTATION_MASTER_STATUS.md`, `CURRENT_MIGRATION_STATE.md`, `ROADMAP_AFTER_PR4A.md`) is **retained in place as an immutable redirect**, and all *new* references repoint to the new name. Nothing in project history breaks — old references still resolve to a live tombstone. This happens in Stage B, after the Stage-A gate.

---

## 4. The `.claude/` structure

| File | Purpose | Owner |
|---|---|---|
| `settings.local.json` | Permissions, tool prefs (unchanged) | Human |
| `CONTEXT_TIERS.md` | The authoritative Tier 0–3 file list (mirrors `AI_CONTEXT_STRATEGY.md`, kept terse for fast load) | Claude Code |
| `commands/*.md` | Slash commands (`/analyze-feature`, `/audit-stats`, `/audit-widget`, `/fix-bug`, `/update-ai-index`) | Claude Code |
| `commands/drift-check.md` | NEW `/drift-check` — verifies the four Tier-0 files agree before a PR sign-off | Claude Code |

`.claude/` is for **machine-operational** config (how the agent runs). Human-readable governance lives in `docs/governance/`. Keeping these separate prevents the "is this a rule or a setting?" ambiguity.

---

## 5. The SOURCE → MIRROR rule for design specs (root-cause fix)

The design-spec duplication (`root/` vs `handoff_v2-2/`, and the 313/104/308-line `PRAYER_CARD_SPEC`) exists because specs were **copied between locations with no provenance**. The fix is structural:

```
SOURCE  (Designer's workspace, "Athar Design System" project)
        handoff_v2/  ← the ONE place specs are authored & edited
            │
            │  one-way sync (designer publishes; commit/date recorded)
            ▼
MIRROR  (Flutter repo)
        docs/design-specs/  ← read-only in the repo; never hand-edited
            _SYNC.md  ← "synced from SOURCE @ <commit/date>"
```

Rules:
1. **Specs are authored only at SOURCE.** Claude Code never edits a file under `docs/design-specs/`; it only consumes them.
2. **The MIRROR is replaced wholesale on each sync**, never patched in place — so it cannot diverge file-by-file.
3. **`_SYNC.md` records the source commit/date.** Any agent can see whether the mirror is current.
4. **There is exactly one mirror.** The `/Athar Design System/` repo-root spec copies are retired to history.
5. **Conflicts (like `PRAYER_CARD_SPEC`) are resolved by re-syncing from SOURCE**, never by choosing between two stale repo copies.

This converts "which copy is canonical?" from a recurring judgment call into a mechanical fact.

---

## 6. File-naming conventions

> **Naming + migration rule:** living docs use stable, intent-revealing names that never carry a PR number or date. Existing files that don't yet follow this (`IMPLEMENTATION_MASTER_STATUS.md`, `CURRENT_MIGRATION_STATE.md`, `ROADMAP_AFTER_PR4A.md`) are migrated to clean names **via Tombstone Migration, never bare rename** — the old file is retained as an immutable redirect so historical references never break (see `GOVERNANCE_RULES.md` §2b, `MIGRATION_PLAN.md` Rev 3). The `CANONICAL-FOR` header carries the authoritative semantic regardless of filename.

| Rule | Example (good) | Example (avoid) |
|---|---|---|
| **Living docs use stable, intent names** — never a PR number or date | `ROADMAP.md`, `NEXT_STEPS.md` | `ROADMAP_AFTER_PR4A.md` |
| **History snapshots are stamped** — PR tag and/or date | `docs/history/pr-reports/PR4A_FINAL_REPORT.md`, `docs/history/change-logs/CHANGE_LOG_2026-06-01_PR_THEME_COMPLETE.md` | `FINAL_REPORT.md` (ambiguous) |
| **One concept = one filename across the tree** | `KNOWN_PROBLEMS.md` (one) | two files both tracking bugs |
| **Specs named by feature, not by PR** | `STATS_KPI_SPEC.md` | `PR6_SPEC.md` (PR numbers churn) |
| **Audits named by feature + `_audit_` prefix** | `_audit_stats.md` | `stats_notes.md` |

The naming rule that prevents the most future pain: **a living file never carries a point-in-time token** — `ROADMAP.md`, not `ROADMAP_AFTER_PR4A.md`. Existing files reach this via Tombstone Migration: the clean name becomes canonical, the old name survives as a live redirect — so future clarity and past continuity are both preserved.

---

## 7. Cross-references

- **Which file owns which domain →** `CANONICAL_SOURCE_MAP.md`
- **Why each file is where it is, and who edits it →** `KNOWLEDGE_ARCHITECTURE.md`
- **When a file may move zones →** `GOVERNANCE_RULES.md` (Lifecycle)
- **What an agent loads and when →** `AI_CONTEXT_STRATEGY.md`
- **How to get from today's tree to this one →** `MIGRATION_PLAN.md`
