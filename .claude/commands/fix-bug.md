# /fix-bug [description]

Structured bug investigation and fix workflow.

## Cap

Max 2 file reads before implementation. If the target file is identified from KNOWN_PROBLEMS.md or FEATURE_INDEX.md: your next action MUST be Read on that file. Do not search further.

## Steps

1. Check `docs/ai/KNOWN_PROBLEMS.md` — is this already documented? Use listed file paths directly.
2. If not documented: check `docs/ai/FEATURE_INDEX.md` — get the MANDATORY START FILE. Stop searching.
3. If still unclear: use SocratiCode `codebase_search("symptom or symbol")` — one search only.
4. Trace the relevant flow in `docs/ai/DATA_FLOW_INDEX.md` (doc read — not a file read).
5. Read the identified target file. (File read 1 of 2.)
6. Read one additional file only if the fix requires it and the Execution Path justifies it. (File read 2 of 2.)
7. Apply the minimal fix — no surrounding cleanup, no new abstractions.
8. Run `flutter analyze` — must be zero issues.
9. If widget-related: build the affected widget extension.
10. Update `docs/ai/KNOWN_PROBLEMS.md` — mark as RESOLVED with the fix summary.

## Non-negotiable constraints

- Do not rename `WidgetKeys` constants
- Do not edit `*.g.dart` files
- Do not add page-level FABs to TaskPage or HabitPage
- Do not add features or refactoring beyond what fixes the bug
