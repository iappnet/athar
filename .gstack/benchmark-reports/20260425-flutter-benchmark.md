# Flutter Performance Benchmark — Athar (أثر)
**Date:** 2026-04-25  
**Branch:** main  
**Files:** 426 Dart files | 212,102 lines | 68 direct deps | 1,140 transitive deps  
**Analyze:** 5.1s, 0 issues

---

## Overall Score: C+

| Category | Grade | Finding |
|---|---|---|
| Widget const-ness | D | 3,337 non-const widget callsites |
| BlocBuilder discipline | C | 115 BlocBuilders missing `buildWhen` |
| List rendering | B | 23 non-lazy `ListView()` usages |
| GPU / overdraw | A | 5 BackdropFilters — expected for glass UI |
| Font loading | B | 4 `GoogleFonts.*` calls — should use bundled fonts |
| File size hygiene | D | `add_task_sheet.dart` = 5,262 lines |
| Asset footprint | A | 572KB total assets, 1 PNG |
| Static analysis | A | Clean, 5.1s |

---

## PERF-001 — Missing `const` on 3,337 Widget Callsites [HIGH]

Flutter's const widgets are allocated once and skipped on every subsequent rebuild. Non-const widgets are re-instantiated on every `build()` call, even when nothing changed. With 3,337 non-const widget callsites, the app rebuilds thousands of objects on every state change.

```
Text()       1,587 non-const usages   (in features/)
SizedBox()   1,018 non-const usages
Icon()         559 non-const usages
Padding()      173 non-const usages
```

**Impact:** Every time any cubit emits a new state, the widget tree rebuilds. Without `const`, that means 1,587 new Text objects, 1,018 new SizedBoxes, etc. On a 60Hz screen that means 60 allocations per second during animations.

**Fix pattern:**
```dart
// Before
Text('مرحباً', style: TextStyle(fontSize: 16))
SizedBox(height: 8)
Icon(Icons.home)

// After
const Text('مرحباً', style: TextStyle(fontSize: 16))
const SizedBox(height: 8)
const Icon(Icons.home)
```

Run `dart fix --apply` — it auto-adds `const` where possible. Then review manually.

---

## PERF-002 — 115 BlocBuilders Without `buildWhen` [HIGH]

Every `BlocBuilder` without `buildWhen` rebuilds its subtree on EVERY state emission from its cubit — including Loading → Loaded → Error → Loaded cycles where the UI didn't visually change. With 14 cubits all emitting on the same screen (dashboard shows tasks, habits, prayer, settings, auth all at once), this stacks up.

```dart
// Rebuilds on every TaskState change:
BlocBuilder<TaskCubit, TaskState>(
  builder: (context, state) => TaskList(state),
)

// Only rebuilds when loaded tasks actually change:
BlocBuilder<TaskCubit, TaskState>(
  buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType
      || (curr is TaskLoaded && prev is TaskLoaded && curr.tasks != prev.tasks),
  builder: (context, state) => TaskList(state),
)
```

**Priority files to fix first** (dashboard composites with many BlocBuilders):
- `lib/features/home/presentation/pages/dashboard_page.dart`
- `lib/features/task/presentation/pages/task_page.dart`
- `lib/features/habits/presentation/pages/habit_page.dart`

---

## PERF-003 — 23 Non-Lazy `ListView()` [MEDIUM]

`ListView()` renders ALL children immediately, even those off-screen. With dynamic data from Isar streams, this means every item in a task list, habit list, or notification list is built at once.

```dart
// Builds all items at once:
ListView(children: tasks.map((t) => TaskTile(t)).toList())

// Only builds visible items:
ListView.builder(
  itemCount: tasks.length,
  itemBuilder: (ctx, i) => TaskTile(tasks[i]),
)
```

23 is manageable but any list over ~20 items is a jank risk on older devices.

---

## PERF-004 — 4 `GoogleFonts.*` Calls [MEDIUM]

`GoogleFonts` makes an HTTP request to fonts.googleapis.com on first use and caches to disk. The problem: if the user is offline on first launch, fonts fall back to system default and Cairo never loads. Worse, it adds network latency to first paint.

The repo already has Cairo bundled at `assets/fonts/` (per CLAUDE.md). Use it.

```dart
// Current (network-dependent):
GoogleFonts.cairo(fontSize: 16)

// Better (bundled, offline-safe):
TextStyle(fontFamily: 'Cairo', fontSize: 16)
// or use the token:
AtharTypography.bodyLarge
```

Grep to find the 4 usages:
```bash
grep -rn "GoogleFonts\." lib/ --include="*.dart"
```

---

## PERF-005 — `add_task_sheet.dart` = 5,262 Lines [HIGH]

A single file at 5,262 lines is the single biggest hot-reload killer in the codebase. Flutter hot reload has to re-parse and re-compile the entire file on every change. At 5,262 lines that's slow — engineers will feel it.

It also signals that this widget is doing too much. A bottom sheet that needs 5,262 lines is either a god widget (handling all task types, all validation, all state) or it has large generated sections mixed in.

**Recommended split:**
```
add_task_sheet.dart (coordinator, ~200 lines)
├── task_form_basic.dart (title, date, priority)
├── task_form_reminders.dart (notification scheduling)
├── task_form_recurrence.dart (repeat logic)
├── task_form_space.dart (space/assignment fields)
└── task_form_health.dart (health-specific fields)
```

Similarly, `unified_add_sheet.dart` at 3,967 lines.

---

## PERF-006 — `setState` Called 435 Times Across 134 StatefulWidgets [MEDIUM]

435 `setState` calls is ~3.2 per StatefulWidget on average. That's not alarming by itself, but `setState` rebuilds the entire subtree of that widget. In screens with deep widget trees (task_page, space_page), a single `setState` in a parent rebuilds hundreds of child widgets.

Pattern to watch: `setState` inside stream listeners or timers that fire frequently (e.g., the focus timer, prayer countdown).

**Best practice:** Keep StatefulWidgets as leaves. If a StatefulWidget contains BlocBuilders, those BlocBuilders will rebuild on both state changes AND setState calls.

---

## Performance Budget

```
FLUTTER PERFORMANCE BUDGET
═══════════════════════════
Metric                  Budget    Actual      Status
──────                  ──────    ──────      ──────
Dart files              < 500     426         PASS
Total lines             < 200K    212K        WARNING (106%)
Direct dependencies     < 50      68          FAIL
Const widget coverage   > 80%     ~55%        FAIL
BlocBuilders w/buildWhen> 70%     50%         FAIL
Largest single file     < 1,000   5,262 ln    FAIL
Asset total size        < 5MB     572KB       PASS
Analyze time            < 10s     5.1s        PASS
Analyze issues          0         0           PASS

Score: D+ → C+ (asset hygiene and analysis are excellent; code discipline needs work)
```

---

## Quick Wins (fix order by impact / effort)

1. **Run `dart fix --apply`** — auto-adds missing `const`, costs 2 minutes, gains the most. Estimated ~1,500+ const additions.
2. **Fix GoogleFonts 4 calls** — swap to bundled Cairo. 10 minutes, eliminates network dependency on first paint.
3. **Add `buildWhen` to dashboard BlocBuilders** — 30 minutes, eliminates redundant rebuilds on the most-viewed screen.
4. **Split `add_task_sheet.dart`** — 2 hours, dramatically improves hot reload speed during task feature development.
5. **Convert 23 ListView() to ListView.builder** — 1 hour, eliminates off-screen rendering on list screens.

---

## Baseline (save for next run)

```json
{
  "date": "2026-04-25",
  "branch": "main",
  "dart_files": 426,
  "total_lines": 212102,
  "direct_deps": 68,
  "transitive_deps": 1140,
  "stateful_widgets": 134,
  "stateless_widgets": 225,
  "set_state_calls": 435,
  "non_const_text": 1587,
  "non_const_sizedbox": 1018,
  "non_const_icon": 559,
  "non_const_padding": 173,
  "bloc_builder_no_build_when": 115,
  "non_lazy_listview": 23,
  "backdrop_filters": 5,
  "google_fonts_calls": 4,
  "largest_file_lines": 5262,
  "largest_file": "add_task_sheet.dart",
  "asset_size_kb": 572,
  "analyze_time_s": 5.1,
  "analyze_issues": 0,
  "overall_grade": "C+"
}
```
