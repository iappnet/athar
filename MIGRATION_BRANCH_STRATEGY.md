# Migration Branch Strategy — Athar v2 Design System

**Date:** 2026-05-09  
**Status:** Active — migration in progress

---

## Branch Model

### Canonical Migration Branch

```
feat/athar-v2-pr1-tokens-theme
```

This is the **long-running governed migration branch**. All v2 redesign work happens here. It is NOT a short-lived feature branch. It will remain open until the full migration program is complete.

### Stable Legacy Baseline

```
main  (commit 32e59c3)
```

`main` is the stable, shipped legacy baseline. **Do NOT merge the migration branch into `main`** until all of the following are complete:

- All 14 migration PRs implemented and checkpointed on the migration branch
- Full visual validation (all screens, light + dark)
- Full regression validation (all features, all flows)
- Physical device validation (Phase 5 — interactive widgets, locale, cold-start)
- Full QA pass
- Designer approval on final state

### Branch Governance Rules

| Rule | Rationale |
|------|-----------|
| All migration work on `feat/athar-v2-pr1-tokens-theme` | Single, traceable migration history |
| `main` stays at `32e59c3` until migration merge | Legacy users stay on stable app; migration is isolated |
| Each PR is a checkpoint on the migration branch, NOT a merge to `main` | PRs are logical milestones, not shipping units |
| GitHub PRs opened for review/record only — not merged to `main` | Design and code review visibility without main contamination |
| Git tags created at every PR completion | Granular rollback points |
| No hotfixes to migration branch — hotfixes go to `main` directly | Migration branch is v2 only |

---

## PR Checkpoint Model

Each PR in the migration sequence is a **logical migration checkpoint**:

1. Implementation complete on migration branch
2. `flutter analyze` → 0 issues
3. `flutter test` → all green
4. Change log created in `docs/ai/change-logs/`
5. Governance docs updated
6. Git tag created: `athar-v2-<pr-id>-complete`
7. GitHub PR opened for designer/stakeholder review
8. Screenshot checklist documented
9. **Do NOT merge to `main`**
10. Start next PR on the same migration branch

---

## Git Tag Strategy

Tags are created at each PR completion. They serve as stable rollback points within the migration branch.

### Existing Tags

| Tag | Commit | Description |
|-----|--------|-------------|
| `athar-v2-pr1-complete` | `72f902d` | PR1 complete — tokens, Calibri font, all governance docs |

### Planned Tags

| Tag | Created when |
|-----|-------------|
| `athar-v2-prtheme-complete` | PR-THEME implementation + governance done |
| `athar-v2-pr2-complete` | PR2 AdaptiveShell complete |
| `athar-v2-pr3-complete` | PR3 Prayer card complete |
| `athar-v2-pradhan-complete` | PR-ADHAN audio bundle complete |
| `athar-v2-pr4a-complete` | PR4a Calendar visual complete |
| `athar-v2-pr4b-complete` | PR4b Calendar dual-display complete |
| `athar-v2-pr5-complete` | PR5 Accessibility settings complete |
| `athar-v2-pr6-complete` | PR6 Stats redesign complete |
| `athar-v2-pr7-complete` | PR7 Athkar feature complete |
| `athar-v2-pr8-complete` | PR8 Focus oil-fill complete |
| `athar-v2-pr9-complete` | PR9 iOS widgets refresh complete |
| `athar-v2-pronboard-complete` | PR-ONBOARD-AB complete |
| `athar-v2-prcleanup-complete` | PR-CLEANUP complete |
| `athar-v2-migration-qa-complete` | Full QA + device validation complete |
| `athar-v2-migration-ready` | Pre-merge final state — ready for `main` |

---

## Rollback Strategy

### Roll back to any PR checkpoint

```bash
# View all migration tags
git tag --list | grep "athar-v2"

# Roll back working tree to a specific checkpoint (non-destructive)
git checkout athar-v2-pr1-complete

# Create a recovery branch from any checkpoint
git checkout -b recovery/pr1-state athar-v2-pr1-complete
```

### Roll back the migration branch to a checkpoint

```bash
# DESTRUCTIVE — only if migration branch is broken beyond repair
git checkout feat/athar-v2-pr1-tokens-theme
git reset --hard athar-v2-pr1-complete
git push --force-with-lease origin feat/athar-v2-pr1-tokens-theme
```

### Emergency rollback — revert `main` if migration accidentally merged

```bash
git checkout main
git revert <merge-commit-hash>
```

---

## Merge Gate Checklist (Migration → `main`)

Do NOT merge until every item below is checked:

- [ ] All 14 PRs implemented and tagged on migration branch
- [ ] `flutter analyze`: 0 issues
- [ ] `flutter test`: all green
- [ ] Physical device: Task widget interactive tap → Isar committed → widget refreshes
- [ ] Physical device: Habit widget boolean + count-based taps
- [ ] Physical device: Prayer widget RTL + LTR + both locales
- [ ] Physical device: Cold-start pending-action replay (kill app after widget tap, reopen)
- [ ] Visual regression: all screens light mode
- [ ] Visual regression: all screens dark mode
- [ ] Visual regression: prayer card unchanged (navy gradient)
- [ ] RTL validation: all screens in Arabic
- [ ] LTR validation: all screens in English
- [ ] Onboarding: all four variants reachable (A/B/C/D)
- [ ] Onboarding: Variant A unchanged vs. baseline
- [ ] B1: Calibri App Store licence confirmed by designer
- [ ] Designer final approval on all screens
- [ ] No open P1/P2 bugs in `KNOWN_PROBLEMS.md`

---

## Hotfix Strategy

If a critical bug is found in `main` while migration is in progress:

1. Branch from `main`: `git checkout -b hotfix/<issue> main`
2. Fix and merge hotfix back to `main`
3. Cherry-pick the fix onto the migration branch: `git cherry-pick <commit>`
4. Document the cherry-pick in the next change log
5. Do NOT apply migration branch work to hotfix branch

---

## State Diagram

```
main (32e59c3) ─────────────────────────────────────────────────────► stable legacy
                                                                        (no touches)
         │
         └── feat/athar-v2-pr1-tokens-theme ──────────────────────────► v2 migration
               │
               ├── [tag: athar-v2-pr1-complete] ✅ 72f902d
               │    PR1: tokens + Calibri + governance
               │
               ├── [tag: athar-v2-prtheme-complete] (planned)
               │    PR-THEME: ThemeMode wiring
               │
               ├── [tag: athar-v2-pr2-complete] (planned)
               │    PR2: AdaptiveShell + nav bar
               │
               ├── ... (11 more checkpoints)
               │
               ├── [tag: athar-v2-migration-qa-complete] (planned)
               │    Full QA + device validation
               │
               └── [tag: athar-v2-migration-ready] (planned)
                    ──────────────────────────────────► MERGE TO MAIN
```
