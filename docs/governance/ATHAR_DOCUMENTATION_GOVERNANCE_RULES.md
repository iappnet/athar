<!--
CANONICAL-FOR: Documentation governance rules — header format, precedence ladder, mandatory update protocol
OWNER:         Claude Design
PRECEDENCE:    off-ladder (governance authority)
LAST-UPDATED:  2026-06-02 · section 8 — Design Token SSOT rule added
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

---

## 8. Design Token Single-Source-of-Truth

### 8.1 Rule statement

**Feature code MUST NOT contain literal visual values.** Every visual constant resolves through exactly one token source:

| Category | Token source | Never write |
|----------|-------------|-------------|
| Colors | `context.colors.*` / `colorScheme.*` | `Color(0x…)`, `Colors.<named>` (except `Colors.transparent`) |
| Font family | `AtharTypography.fontFamily` | the literal `'Calibri'` |
| Spacing / gaps | `AtharSpacing.*` / `AtharGap.*` | magic pixels in brand layout (e.g. `SizedBox(height: 16)` when `AtharSpacing.md` exists) |
| Border radii | `AtharRadii.*` | `BorderRadius.circular(…)`, `Radius.circular(…)` |
| Shadows / elevation | `AtharShadows.*` | inline `BoxShadow(…)` |
| Durations / curves | `AtharAnimations.*` | inline `Duration(milliseconds: …)` |
| Text roles | `AtharTypography.<role>` / `context.textTheme.<role>` | ad-hoc `fontSize` / `fontWeight` where a clean scale role exists |

**Changing any design decision must be a one-file edit at the token source.** If changing the brand font requires touching more than `athar_typography.dart`, the single-source guarantee is broken.

### 8.2 Token file inventory — confirmed sole definitions

All six token files exist in `lib/core/design_system/tokens/`:

| File | Class | Domain | Sole definition? |
|------|-------|--------|-----------------|
| `athar_colors.dart` | `AtharColors` | Color palette | ✅ Sole (28 files still use `Color(0x…)` — target of PR-CLEANUP) |
| `athar_typography.dart` | `AtharTypography` | Font family, weights, sizes, text styles | ✅ Sole — `fontFamily = fontFamilyAr = 'Calibri'`; 0 literals remain (fixed 2026-06-02 · `44de6f8`) |
| `athar_spacing.dart` | `AtharSpacing` | Spacing constants | ✅ Sole (magic-pixel callsite count TBD — see Step-0 Verify) |
| `athar_radii.dart` | `AtharRadii` | Border radii | ✅ Sole (87 files with inline `BorderRadius.circular()` — PR-CLEANUP target) |
| `athar_animations.dart` | `AtharAnimations` | Durations, curves | ✅ Sole (28 files with inline `Duration(milliseconds:…)` — PR-CLEANUP target) |
| `athar_shadows.dart` | `AtharShadows` | Shadows / elevation | ✅ Sole (53 files with inline `BoxShadow(…)` — PR-CLEANUP target) |

No `AtharElevation` class is needed — `AtharShadows` is the elevation token.

### 8.3 Two-tier refresh recipe (all remaining UI coverage PRs)

Apply this recipe inside every per-feature refresh PR (PR-HABITS-REFRESH, PR-HEALTH-REFRESH, etc.).

**TIER 1 — Enforce silently (value-identical swap, zero visual change):**

Replace these mechanically without designer review — the token value equals the literal:

- `Color(0x…)` / `Colors.<named>` → `context.colors.*` (where a semantic mapping exists)
- `fontFamily: 'Calibri'` → `fontFamily: AtharTypography.fontFamily` (done globally 2026-06-02)
- `BorderRadius.circular(N)` → `AtharRadii.*` (where N matches a token)
- `SizedBox(height/width: N)` / `EdgeInsets.all(N)` → `AtharSpacing.*` / `AtharGap.*` (where N matches)
- `BoxShadow(…)` → `AtharShadows.*` (where the shadow matches a token tier)
- `Duration(milliseconds: N)` → `AtharAnimations.*` (where N matches a token)

**TIER 2 — Flag, do not auto-change (metric-changing values):**

These alter rendered size and may reflow text. List them per-file in the PR audit; wait for designer decision:

- Ad-hoc `fontSize: N` that would map to a `AtharTypography.<role>` (may change line metrics)
- Ad-hoc `fontWeight: FontWeight.wXXX` that deviates from the scale
- `BorderRadius.circular(N)` where N does NOT match any `AtharRadii` token (non-standard corner)
- `EdgeInsets` values that don't match any `AtharSpacing` token (brand-layout magic numbers)

### 8.4 Step-0 Verify (mandatory for every remaining refresh PR)

Before touching any Dart file in a per-feature PR, run this check and record counts in the PR audit doc:

```
Token category          | Count | Method
------------------------|-------|-------
Colors (static AppColors / Color(0x…) / Colors.named)  | grep -c
Font literals ('Calibri')                              | grep -c  (expect 0)
Magic radii (BorderRadius.circular not via AtharRadii) | grep -c
Magic spacing (SizedBox / EdgeInsets with hardcoded N) | grep -c
Inline shadows (BoxShadow outside AtharShadows)        | grep -c
Inline durations (Duration(milliseconds:) outside token)| grep -c
Ad-hoc text sizes (fontSize: N) [Tier 2 — FLAG]       | grep -c
```

Record pre-patch and post-patch counts. Tier 1 counts must go to zero for all files in scope. Tier 2 counts are listed with a designer decision for each.
