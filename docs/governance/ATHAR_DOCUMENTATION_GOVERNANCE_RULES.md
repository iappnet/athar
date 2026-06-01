<!--
CANONICAL-FOR: Documentation governance rules — header format, precedence ladder, mandatory update protocol
OWNER:         Claude Design
PRECEDENCE:    off-ladder (governance authority)
LAST-UPDATED:  2026-06-01 · Stage A
LOADS-AT:      off-ladder (read when governance process is in question)
-->

# Athar — Documentation Governance Rules

**Author:** Claude Design
**Date:** 2026-06-01
**Status:** Proposal — planning only.
**Owns:** the **lifecycle**, the **update rules**, and the **drift-prevention guarantees**. This is the rulebook the other five files assume.

---

## 1. Document lifecycle

Every file is in exactly one state. Transitions are one-directional except Draft→Active.

```
   DRAFT ──▶ ACTIVE (canonical or supporting) ──▶ SUPERSEDED ──▶ ARCHIVED ──▶ (rarely) DELETED
     ▲           │
     └───────────┘  (a living file is edited in place; it stays ACTIVE)
```

| State | Meaning | Where it lives | Who triggers entry |
|---|---|---|---|
| **Draft** | Being written, not yet authoritative | working location | author |
| **Active** | Current truth (canonical) or a sanctioned pointer (supporting) | LIVING/SOURCE zones | owner |
| **Superseded** | Replaced by a newer canonical, but kept for context with a stale banner | still in place, banner added | owner |
| **Archived** | Frozen history, never auto-loaded | `docs/history/**` | Claude Code, on Product-Owner approval |
| **Deleted** | Truly empty or duplicate-with-zero-value | gone | Product Owner only |

**One-way-door rule:** Archiving is irreversible in practice. Before a file is archived, any *unique, still-live* decision it holds must already be extracted into the canonical file for that domain. "Archive" must never be the act that loses a decision.

**Delete is rare.** Only two classes qualify: genuinely empty files (`missing_translations.txt`) and exact duplicates whose canonical twin is verified identical (`auto_checkpoint.md`). Everything else is archived, not deleted — history is preserved.

---

## 2. The mandatory header (every LIVING + SOURCE file)

Every active file carries this block at the very top. It makes drift visible at a glance and tells an agent whether to trust the file.

```markdown
<!--
CANONICAL-FOR: <domain name>            (or: SUPPORTING — see <canonical file>)
OWNER:         <Claude Code | Claude Design | Product Owner>
PRECEDENCE:    <level 1–7 from CANONICAL_SOURCE_MAP, or "off-ladder">
LAST-UPDATED:  <YYYY-MM-DD> · <commit/PR>
LOADS-AT:      <Tier 0 | 1 | 2 | 3>
-->
```

For SOURCE mirrors, add one line: `SYNCED-FROM: <source commit/date>`.

A file with no header is treated as **untrusted** until one is added. A reviewer (or `/drift-check`) can scan headers alone to find stale or unowned files.

---

## 2b. Tombstone & alias rules (rename without breaking memory)

A living file is **never bare-renamed**. To adopt a cleaner name, use the **Tombstone Migration**:

1. **Create** the new canonical file at its path/name with full content + header. Its header adds:
   `LEGACY-ALIASES: <old name(s)>` and `CANONICAL-SINCE: <date>`.
2. **Tombstone** the old file in place — replace its body with a redirect, keep it forever:
   ```
   # Moved
   Canonical file: docs/status/ROADMAP.md
   Legacy file retained for historical compatibility. Do not update this file.
   ```
3. **Repoint** all *new/active* references to the new name. Historical artifacts (old PR reports, prompts) are left untouched — they still resolve to the live tombstone.
4. **Record** the mapping (old → new, date) in `docs/governance/MIGRATION_REPORT.md`.

**Tombstone rules:**
- A tombstone is **immutable** and **never auto-loaded** (Tier 3 by nature).
- A tombstone is **never deleted** — it is the bridge that keeps history valid.
- Exactly one canonical file claims a domain; the tombstone explicitly disclaims it ("Do not update").
- Why this beats a bare rename: future readers get clean, non-temporal names; past readers' references never dead-link. Both at once.

---

## 3. Update rules (per the failure modes the audit found)

These rules are written against the *actual* drift that occurred, so each one closes a real hole.

1. **Status updates ship inside the work, not after it.**
   A PR is "done" only when its `ROADMAP.md` row and `MIGRATION_STATE.md` evidence line are updated in the same change.
   *(Closes: PR4a still listed as "remaining" after it shipped.)*

2. **Fixing a bug includes closing its entry.**
   The same change that fixes a bug moves its `KNOWN_PROBLEMS.md` line to "Resolved" naming the fixing PR.
   *(Closes: B2 ThemeMode listed OPEN after PR-THEME fixed it — the single highest-risk drift.)*

3. **A supporting file may not carry canonical content — only a pointer.**
   If `PROGRAM_IMPLEMENTATION_STATUS.md` grows a PR table, that table is deleted and replaced with a pointer to `ROADMAP.md`.
   *(Closes: 5 files all claiming the roadmap.)*

4. **Living files never carry a point-in-time name.**
   `ROADMAP_AFTER_PR4A.md` → `NEXT_STEPS.md`. The "as of PR4a" is *content*, not *filename*.
   *(Closes: a file permanently named for a moment that has passed.)*

5. **Design specs are edited only at SOURCE; the repo mirror is replaced wholesale.**
   No agent hand-edits `docs/design-specs/`. Sync replaces the folder and stamps `_SYNC.md`.
   *(Closes: root/ vs handoff_v2-2/ divergence; the 313/104-line PRAYER_CARD split.)*

6. **`CHECKPOINT.md` is the final action of every session and wins on "current state."**
   No other file's "current" claim is trusted over CHECKPOINT.
   *(Closes: four files giving conflicting "next PR" signals on resume.)*

7. **Pre-PR1/Phase-0 documents are stamped stale the moment they stop describing reality.**
   A stale banner is added before the content can mislead; the file is then a candidate for archive.
   *(Closes: "Stats is a stub", "Cairo + Inter fonts" read as current.)*

8. **One concept, one filename.** Before creating a doc, check the Canonical Source Map. If the domain already has a canonical file, edit it — do not create a sibling.

---

## 4. Drift-prevention guarantees (structural, not vigilance-based)

Vigilance fails; structure holds. These are the mechanical guarantees that make drift hard to create.

| Guarantee | Mechanism |
|---|---|
| **No two files can own a domain** | Canonical Source Map is the registry; creating a second owner is a reviewable violation |
| **Supporting files cannot silently drift** | They contain pointers, not copies — there is nothing to drift |
| **Mirrors cannot diverge file-by-file** | The mirror is replaced wholesale + provenance-stamped, never patched |
| **Staleness is visible without reading content** | The mandatory header (OWNER/LAST-UPDATED/PRECEDENCE) is scannable |
| **History cannot pollute the present** | `docs/history/**` is never auto-loaded (enforced by `CONTEXT_TIERS.md`) |
| **A decision can't be lost on archive** | Extraction-before-archive is a required step in the lifecycle |
| **Resume can't read a stale "current"** | The precedence ladder puts CHECKPOINT above all plan files |

### The drift-check gate (`/drift-check`)
Before any PR sign-off, Claude Code runs a lightweight check that the four **Tier-0** files agree:
- `CHECKPOINT.md` current PR == `ROADMAP.md` active PR
- every `KNOWN_PROBLEMS.md` "open" item is genuinely open (not fixed by a shipped PR)
- `ROADMAP.md` % matches its own PR table
- no Tier-0 file references an archived path as if it were live

The check is **five reads, no writes**. It is the cheapest possible insurance against the exact failures this audit found.

---

## 5. Ownership & change protocol

| Action | Who may do it | Approval needed |
|---|---|---|
| Edit `CLAUDE.md` | Product Owner (Code drafts) | Product Owner |
| Edit `ROADMAP.md` / `MIGRATION_STATE.md` / `CHECKPOINT.md` / `NEXT_STEPS.md` | Claude Code | none (within agreed scope) |
| Edit `docs/ai/*` indexes | Claude Code | none |
| Edit a design spec | Claude Design @ SOURCE | Design authority |
| Sync the spec mirror | Claude Code (mechanical) | confirms `_SYNC.md` |
| Rule on an audit open-question | Claude Design | Design authority |
| Archive a file | Claude Code | Product Owner sign-off |
| Delete a file | Product Owner | Product Owner |
| Add a new domain | proposer → registered in Canonical Source Map | Design + Code agree |

**Cross-domain edits** (a change that touches a domain you don't own) are made as a *request* to the owner, never a direct edit. Example: Claude Code wanting a spec change opens it with Claude Design; it does not edit `docs/design-specs/`.

---

## 6. Cadence

| Trigger | Action |
|---|---|
| End of every session | Update `CHECKPOINT.md` (mandatory final action) |
| Every commit/tag | Update `MIGRATION_STATE.md` evidence ledger |
| PR sign-off | Update `ROADMAP.md` row; run `/drift-check`; archive the PR's working docs; promote its audit to `history/pr-audits/` |
| End of a PR arc | Refresh `NEXT_STEPS.md` |
| Design decision made | Claude Design updates the decision log at SOURCE; mirror re-synced |
| Quarterly (or every ~5 PRs) | Sweep: confirm header dates, archive anything newly superseded, prune `docs/history/` index |

---

## 7. The one-paragraph version (for `CLAUDE.md`)

> Every fact has one home (see `CANONICAL_SOURCE_MAP.md`). Update that home *inside* the change that makes the fact true — never later. Supporting files point; they never copy. Design specs are edited only at SOURCE and mirrored read-only. `CHECKPOINT.md` is written last each session and wins on "what's current." History lives in `docs/history/` and is never auto-loaded. When in doubt, the precedence ladder decides; a file that contradicts a higher one is stale, not a second opinion.
