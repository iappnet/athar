# /update-ai-index

Update the AI knowledge layer after significant code changes.

## Steps

1. Run `codebase_update` via SocratiCode to re-index changed files
2. Review `docs/ai/KNOWN_PROBLEMS.md` — mark resolved bugs as RESOLVED, add any new issues found
3. If new features were added, update `docs/ai/FEATURE_INDEX.md` (FILE_INDEX.md merged here in B1)
4. If data flows changed, update `docs/ai/DATA_FLOW_INDEX.md`
5. If new cubits were added or cubit responsibilities changed, update `docs/ai/STATE_MANAGEMENT_INDEX.md`
6. If widget keys or payload schema changed, update `docs/ai/WIDGET_INDEX.md`
7. If CLAUDE.md needs updating (new invariants, new commands), edit it — keep it under 500 lines

## When to run

- After completing a feature phase
- After fixing Phase 5 device bugs
- After any change to widget payload schema (WidgetKeys)
- After any change to BlocProvider tree in main_page.dart or app.dart
