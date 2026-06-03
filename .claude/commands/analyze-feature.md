# /analyze-feature [feature-name]

Analyze a feature module end-to-end: data flow, cubit behavior, known issues, and improvement opportunities.

## Cap

Max 2 source file reads. Stop after reading 2 files — report from what you have.

## Steps

1. `docs/ai/FEATURE_INDEX.md` — get the MANDATORY START FILE for this feature. Note the Execution Path.
2. `docs/ai/KNOWN_PROBLEMS.md` — check for open issues in this feature (doc read, not a file read).
3. `docs/ai/DATA_FLOW_INDEX.md` — check the feature's data flow (doc read, not a file read).
4. Read the MANDATORY START FILE. (File read 1 of 2.)
5. If a second read is needed AND the Execution Path explicitly points to a second file: read that file only. (File read 2 of 2.) Do NOT read both cubit and repository by default — read the one the symptom points to.
6. Report:
   - Current data flows (working / broken)
   - Cubit state transitions
   - Open bugs
   - Code quality issues (error handling, missing null guards, etc.)
   - Suggestions (if asked)

## Non-negotiable constraints

- Do not rename `WidgetKeys` constants
- Do not edit `*.g.dart` files
- Do not add page-level FABs to TaskPage or HabitPage

## Usage

```
/analyze-feature task
/analyze-feature habits
/analyze-feature prayer
```
