# /audit-widget [prayer|task|habit]

Audit a native iOS or Android widget end-to-end: data push, UserDefaults keys, display, locale/RTL, pending actions.

## Cap

Max 3 source file reads for a full widget audit. Choose path by symptom — do NOT read all files by default.

## Symptom → Start File

| Symptom | Start file (Read 1) |
|---|---|
| Data not updating in widget | `lib/core/services/widget_data_service.dart` |
| Display/layout wrong (iOS) | `ios/Athar*Widget/Athar*Widget.swift` |
| Display/layout wrong (Android) | `android/.../widgets/*Widget.kt` |
| Tap / AppIntent not working | Swift `AppIntent` class inside `Athar*Widget.swift` |
| App not consuming widget actions | `task_cubit.dart` or `habit_cubit.dart` (`processWidgetPendingActions`) |

## Steps

1. `docs/ai/WIDGET_INDEX.md` — get WidgetKeys schema, known issues, data push overview (doc read, not a file read).
2. `docs/ai/KNOWN_PROBLEMS.md` — check for widget-specific open bugs (doc read).
3. Read the start file that matches the symptom. (File read 1 of 3.)
4. If a second file is needed AND the symptom points to it: read that file only. (File read 2 of 3.)
5. If a third file is needed AND confirmed necessary: read it. (File read 3 of 3.)
6. Report all issues with file + line references.
7. Update `docs/ai/WIDGET_INDEX.md` if new issues or schema changes found.

## Constraints

- Do NOT read `task_cubit.dart`, `habit_cubit.dart`, and `app.dart` together unless all three have confirmed issues.
- Do NOT read iOS and Android widget files together — choose the platform matching the symptom.
- Do NOT read `widget_data_service.dart` unless the issue is confirmed to be on the Flutter data push side.
- Never rename `WidgetKeys` constants.
- Never change App Group ID `group.com.iappsnet.athar`.
