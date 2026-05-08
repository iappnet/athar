# Change Log — Phase 3 — NavBar Add Flow Audit
# 2026-05-06

---

## 1. Phase Number and Name
Phase 3 — Verify and fix remaining NavBar add targets

---

## 2. Context from Previous Phases
- Phase 1: `SubscriptionCubit` `@injectable` → `@lazySingleton`; eliminates `await .ready` infinite hang in `addTask()`
- Phase 2: `HabitFormSheet._saveHabit()` made async; `_isSaving` guard added; `await addHabit()` + state check before pop

---

## 3. All NavBar Add Targets Audited

| Target | Entry point | Before | After |
|--------|-------------|--------|-------|
| Task add | `UnifiedAddSheet(EntityType.task)` | ✅ Phase 1 fixed | No change |
| Habit add | `HabitFormSheet` | ✅ Phase 2 fixed | No change |
| Medicine add | `UnifiedAddSheet(EntityType.medicine)` | ❌ fire-and-forget | ✅ Fixed |
| Appointment add | `UnifiedAddSheet(EntityType.appointment)` | ❌ fire-and-forget | ✅ Fixed |
| Module add | `AddModuleSheet._save()` | ❌ fire-and-forget, no `_isSaving` | ✅ Fixed |
| Space create | Inline dialog `FilledButton` in `main_page.dart` | ❌ fire-and-forget | ✅ Fixed |

---

## 4. Files Modified

- `lib/features/task/presentation/widgets/unified_add_sheet.dart`
- `lib/features/space/presentation/widgets/add_module_sheet.dart`
- `lib/features/home/presentation/pages/main_page.dart`
- `docs/progress/BUGFIX_PHASE_STATUS.md`

---

## 5. Changes per File

### `unified_add_sheet.dart`
- Added import: `health_state.dart` (for `HealthError`)
- Medicine branch: `healthCubit.addMedicine(med)` → `await healthCubit.addMedicine(med)` + `if (healthCubit.state is HealthError) { _isSaving = false; return; }`
- Appointment branch: `healthCubit.addAppointment(appt)` → `await healthCubit.addAppointment(appt)` + same state check
- `navigator.pop()` at the bottom only reachable on success (no change to its position)

### `add_module_sheet.dart`
- Added `bool _isSaving = false` to `_AddModuleSheetState`
- `_save()` → `Future<void> _save() async`
- `setState(() => _isSaving = true)` at start
- `await cubit.updateModule(...)` and `await cubit.createModule(...)`
- State check: `if (cubit.state is ModuleError) { _isSaving = false; return; }`
- Only pops on success
- `try/catch` resets `_isSaving` on exception
- `_buildSaveButton`: `onPressed: _isSaving ? null : _save` + spinner replaces text while saving

### `main_page.dart` (space create dialog)
- `onPressed: ()` → `onPressed: () async`
- `context.read<SpaceCubit>().createSpace(...)` → `await context.read<SpaceCubit>().createSpace(...)`
- `Navigator.pop(ctx)` → `if (ctx.mounted) Navigator.pop(ctx)` (after await)
- No `_isSaving` needed — simple dialog without spinner slot; `createSpace` is fast

---

## 6. Old vs New Behavior

### Before (medicine/appointment)
```
User taps Save
  → _handleSave() called
  → healthCubit.addMedicine(med)  ← fire-and-forget, async error swallowed
  → navigator.pop()  ← immediate, sheet always closes
  → if addMedicine throws: error is unhandled silently
```

### After (medicine/appointment)
```
User taps Save
  → _handleSave() called
  → _isSaving = true (button disabled, spinner)
  → await healthCubit.addMedicine(med)
  → if HealthError: _isSaving = false; return  ← sheet stays open, error snackbar shown
  → navigator.pop()  ← only on success
```

### Before (module add)
```
User taps Save
  → _save() called
  → cubit.createModule(...)  ← fire-and-forget
  → Navigator.pop()  ← immediate, always closes
  → no loading guard, double-tap creates duplicates
```

### After (module add)
```
User taps Save
  → _save() called
  → _isSaving = true (button disabled, spinner)
  → await cubit.createModule(...)
  → if ModuleError: _isSaving = false; return
  → Navigator.pop()  ← only on success
```

### Before (space create)
```
User taps Create
  → createSpace(...)  ← fire-and-forget
  → Navigator.pop(ctx)  ← immediate, dialog closes before operation completes
```

### After (space create)
```
User taps Create
  → await createSpace(...)
  → if ctx.mounted: Navigator.pop(ctx)  ← closes after operation completes
```

---

## 7. Verification

```
flutter analyze → "No issues found!" ✅
```

---

## 8. Device Test Checklist

### Medicine add
- [ ] Open NavBar + → Medicine
- [ ] Fill form, tap Save — spinner shows, medicine saved, sheet closes
- [ ] Simulate error (disconnect) — sheet stays open, error shown

### Appointment add
- [ ] Open NavBar + → Appointment
- [ ] Fill form, tap Save — spinner shows, appointment saved, sheet closes

### Module add
- [ ] Open a space, tap add module
- [ ] Fill name, tap Save — spinner shows, module created, sheet closes
- [ ] Tap Save with no name — button stays disabled / validation fires
- [ ] Double-tap Save rapidly — only one module created (button disabled after first tap)

### Space create
- [ ] Open NavBar + → Space (or equivalent space create dialog)
- [ ] Enter name, tap Create — dialog closes after creation, not before

### Regression check
- [ ] Task add still works (Phase 1 not broken)
- [ ] Habit add still works (Phase 2 not broken)

---

## 9. Rollback Plan

```dart
// unified_add_sheet.dart — revert await + state checks:
healthCubit.addMedicine(med);
// and
healthCubit.addAppointment(appt);
// Remove health_state.dart import

// add_module_sheet.dart — revert _save():
void _save() { ... cubit.createModule(...); Navigator.pop(context); }
// Remove _isSaving field
// Revert _buildSaveButton to original onPressed/_save

// main_page.dart — revert to sync button:
onPressed: () { ... context.read<SpaceCubit>().createSpace(...); Navigator.pop(ctx); }
```

---

## 10. Remaining Phases

- Phase 4: Task/Habit iOS Widget localization
- Phase 5: Athkar in Habit iOS Widget
- Phase 6: Prayer notifications default OFF
- Phase 7: Final regression verification
