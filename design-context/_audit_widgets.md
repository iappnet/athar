# PR9 Audit — iOS Widget Visual Refresh
**Date:** 2026-06-02  
**Status:** AUDIT COMPLETE — awaiting designer sign-off before any code  
**Files read:** `docs/design-specs/IOS_WIDGETS_SPEC.md`, `docs/ai/WIDGET_INDEX.md`, `ios/AtharPrayerWidget/AtharPrayerWidget.swift`, `ios/AtharTaskWidget/AtharTaskWidget.swift`, `ios/AtharHabitWidget/AtharHabitWidget.swift`, `ios/AtharPrayerWidgetExtension.entitlements`, `ios/AtharTaskWidgetExtension.entitlements`, `ios/AtharHabitWidgetExtensionProfile.entitlements`, `ios/Runner/Runner.entitlements`, `lib/core/services/widget_data_service.dart`, `pubspec.yaml`, `ios/Runner.xcodeproj/project.pbxproj` (grepped)

---

## SECTION 1 — Native Scaffolding Verdict

**Verdict: NOT greenfield. All three WidgetKit extension targets exist and are fully wired.**

### 1.1 Xcode Extension Targets

Three targets confirmed in `ios/Runner.xcodeproj/project.pbxproj`:

| Target | appex file | Embedded in Runner | Status |
|--------|-----------|-------------------|--------|
| `AtharPrayerWidgetExtension` | `AtharPrayerWidgetExtension.appex` | ✅ `Embed Foundation Extensions` | Exists |
| `AtharTaskWidgetExtension` | `AtharTaskWidgetExtension.appex` | ✅ | Exists |
| `AtharHabitWidgetExtension` | `AtharHabitWidgetExtension.appex` | ✅ | Exists |

**PR9 does NOT need to create new Xcode targets.** The extension targets, bundle references, and build phase embeddings are already in the project file.

### 1.2 Swift Source Files (project-owned, excluding Pods/vendor)

```
ios/AtharPrayerWidget/AtharPrayerWidget.swift   — 611 lines
ios/AtharTaskWidget/AtharTaskWidget.swift        — 421 lines
ios/AtharHabitWidget/AtharHabitWidget.swift      — 580 lines
```

**Focus widget: NO Swift file exists.** There is no `ios/AtharFocusWidget/` directory. A Focus widget would require a new extension target + new Swift file + Xcode manual setup (see §1.5 and Conflict B below).

### 1.3 AtharPrayerWidget — Dart push ↔ Swift consumer: ✅ BOTH SIDES WIRED

- Dart: `WidgetDataService.pushPrayerData()` writes 16 UserDefaults keys (v1–v6) via `home_widget`, then calls `HomeWidget.updateWidget(iOSName: 'AtharPrayerWidget')`.
- Swift: `AtharPrayerWidget.swift` reads all 16 keys from `UserDefaults(suiteName: "group.com.iappsnet.athar")` in `readEntry(configuration:)`. Provider schedules `WidgetCenter.shared.reloadTimelines(ofKind: "AtharPrayerWidget")` correctly.
- **Not just a Dart stub** — the Swift consumer fully exists with small, medium, accessoryCircular, and accessoryRectangular layouts implemented.

### 1.4 App Group — ✅ CONFIGURED (all 4 entitlements)

| File | App Group value | Status |
|------|----------------|--------|
| `ios/AtharPrayerWidgetExtension.entitlements` | `group.com.iappsnet.athar` | ✅ |
| `ios/AtharTaskWidgetExtension.entitlements` | `group.com.iappsnet.athar` | ✅ |
| `ios/AtharHabitWidgetExtensionProfile.entitlements` | `group.com.iappsnet.athar` | ✅ |
| `ios/Runner/Runner.entitlements` | `group.com.iappsnet.athar` | ✅ |
| `WidgetDataService._iosGroupId` | `group.com.iappsnet.athar` | ✅ |
| All three Swift files (`kGroupId`) | `group.com.iappsnet.athar` | ✅ |

**Spec discrepancy:** `IOS_WIDGETS_SPEC.md §4` says `group.app.athar.widgets` — this is a typo in the spec. The actual App Group ID across all code, entitlements, and `WIDGET_INDEX.md` is `group.com.iappsnet.athar`. No new App Group setup is needed. The spec §4 mention should be ignored.

### 1.5 home_widget package

- ✅ `home_widget: ^0.6.0` in `pubspec.yaml`
- ✅ `sensors_plus: ^4.0.2` also present (used by PR8 focus gyro — unrelated to PR9)
- `HomeWidget.setAppGroupId()` called in `WidgetDataService.init()` which is invoked from `main.dart` before `runApp()`

### 1.6 Current App Group Payload Inventory

**Prayer keys (16 — v1 through v6):**

| Key | Type | Content |
|-----|------|---------|
| `athar_next_prayer_name_ar` | String | Arabic prayer name |
| `athar_next_prayer_name_en` | String | English prayer name |
| `athar_next_prayer_time` | String (ISO-8601) | Next prayer datetime |
| `athar_city_name` | String | City |
| `athar_next_prayer_type` | String | fajr/dhuhr/maghrib/etc |
| `athar_next_prayer_timestamp` | Double | epoch ms |
| `athar_app_locale` | String | ar/en/system |
| `athar_last_updated_at` | String (ISO-8601) | Push timestamp |
| `athar_widget_data_version` | Int | 6 |
| `athar_remaining_seconds` | Int | Seconds until next prayer |
| `athar_current_date_ar` | String | Full Arabic Hijri+Gregorian date |
| `athar_current_date_en` | String | Full English Gregorian+Hijri date |
| `athar_prev_prayer_timestamp` | Double | epoch ms of previous prayer |
| `athar_is_duha_time` | Int (0/1) | Duha nafl window |
| `athar_is_qiyam_time` | Int (0/1) | Qiyam window |
| `athar_prev_prayer_name_ar` | String | Arabic name of last started prayer |
| `athar_prev_prayer_name_en` | String | English name of last started prayer |

**Habit keys (4):** `athar_habits` (JSON array: t/d/s/u/cp/tg/tp), `athar_habits_total`, `athar_habits_done`, `athar_app_locale`

**Task keys (5):** `athar_tasks` (JSON array: t/d/p/u), `athar_tasks_total`, `athar_tasks_done`, `athar_current_period`, `athar_app_locale`

**Focus keys:** ❌ **NONE.** No focus data exists in the payload. No `pushFocusData()` method. No focus-related `WidgetKeys` constants.

### 1.7 WidgetTokens.swift Pipeline

**Does NOT exist.** No `WidgetTokens.swift` file anywhere in `ios/`. No build phase script to generate it.

Instead, all three Swift files duplicate inline color constants in a `private extension Color { }` block:

```swift
// Current (identical in all 3 widgets — navy/gold pre-v2 palette):
static let navyDeep = Color(red: 0.07, green: 0.09, blue: 0.15)  // ~#111827
static let navyMid  = Color(red: 0.12, green: 0.16, blue: 0.24)  // ~#1E293B
static let gold     = Color(red: 0.83, green: 0.68, blue: 0.21)  // ~#D4AE35
```

**Spec §5 target:**
```swift
static let athaForest    = Color(hex: 0x0F3D2E)   // forest green — v2 brand primary
static let athaForestMid = Color(hex: 0x1A5A45)
static let athaCream     = Color(hex: 0xEDE6C8)
```

This is the central visual delta for PR9. The pipeline (build-phase code-gen) is an infrastructure concern separate from the visual refresh itself. See OQ7 below.

---

## SECTION 2 — Current Visual State vs PR9 Spec

### 2.1 Prayer Widget

| Spec requirement | Current state | Gap |
|-----------------|--------------|-----|
| Background: forest gradient + glass (`#0F3D2E → #1A5A45`) | Navy gradient (`#1E293B → #111827`) | ❌ Color token refresh needed |
| Small: 32pt countdown | 11pt `.timer` style, no explicit 32pt | ❌ Font size |
| Large (systemLarge): expanded layout | `.systemLarge` not in `supportedFamilies` — only small/medium/accessory | ❌ New layout + new family |
| Calibri font throughout | `.system(size:weight:design:)` everywhere | ❌ Font bundle + Info.plist change per extension |
| Post-prayer window: 40 min | `isCurrentPrayerWindow`: `< 1800s` (30 min) | ❌ Window mismatch — see OQ2 |
| Whole-widget tap → PrayerDetailsPage | Standard WidgetKit `.widgetURL()` — not wired | ❌ `widgetURL` missing |
| accessoryCircular / accessoryRectangular | ✅ Both implemented | ✅ Exists (visual refresh still needed) |
| RTL wiring | ✅ `.environment(\.layoutDirection, ...)` | ✅ |
| Locale resolution | ✅ `resolvedLocale` intent+device+fallback | ✅ |
| Stale indicator | ✅ `exclamationmark.circle` when > 2h | ✅ |
| Nafl badge (Duha/Qiyam) | ✅ `NaflBadge` view | ✅ |
| Progress bar (medium/detailed) | ✅ `intervalProgress` computed from prev/next timestamps | ✅ |

**Net prayer widget gaps:** background gradient, countdown sizes, systemLarge layout, Calibri font, post-prayer window duration, `widgetURL` deep link.

### 2.2 Habits Widget

| Spec requirement | Current state | Gap |
|-----------------|--------------|-----|
| Background: forest gradient | Navy gradient | ❌ Color token refresh |
| Small §2a: ring (28pt diameter) + n/total + "Habits today" | Header row (done/total badge) + row list | ❌ Complete small layout redesign |
| Medium §2b: ring + 7-day streak grid + top 3 mini check-pills | Header + row list (4 rows) | ❌ Complete medium layout redesign |
| Medium §2b: 7-day streak grid | No 7-day data in payload | ❌ Data payload gap (see Section 3) |
| Large §2c: ring + n/total · streak + list max 6 | Header + list (max 6) + no ring | ❌ Ring missing; otherwise close |
| Top 5 habit cap (Dart) | ✅ Pushes top 5 | ❌ Spec says max 6 for large → raise cap |
| Interactive check-pills (large §2c) | ✅ `CompleteHabitIntent` / `IncrementHabitIntent` wired | ✅ |
| Athkar rows: read-only | ✅ `athkarRow()` — no intent wired | ✅ |
| Streak badge | ✅ `streakBadge()` on boolean rows | ✅ |
| RTL wiring | ✅ `.environment(\.layoutDirection, ...)` | ✅ |
| Count-based progress bar | ✅ `countBasedRow()` with Capsule bar | ✅ |

**Net habit widget gaps:** all three layouts need ring-based restructure; background gradient; 7-day payload missing (medium); cap raised to 6 (Dart).

### 2.3 Task Widget

**Note:** The task widget is not described in `IOS_WIDGETS_SPEC.md` at all (spec covers Prayer §1, Habits §2, Focus §3 only). The task widget is an existing interactive widget not being redesigned in this spec. PR9 should **not** change the task widget layout. Only the background gradient and font token refresh applies if visual parity is the goal — but this is a scope question (see OQ8).

Current task widget: small/medium/large layouts with interactive `ToggleTaskIntent`, priority dots, done/total badge. Functionally complete.

### 2.4 Focus Widget

**Does not exist.** Entire widget is net-new:
- No `ios/AtharFocusWidget/` directory
- No `AtharFocusWidgetExtension` Xcode target
- No `WidgetKeys` focus constants
- No `pushFocusData()` in `WidgetDataService`
- No `FocusWidget.swift` file

Spec §3 requires: today's focus minutes (large numeric), daily goal ring, 7-day bar chart, "Start session" CTA deep link. All of these need new infrastructure end-to-end (Dart + Xcode + Swift).

---

## SECTION 3 — Data Push Gaps (Conflict C)

| Widget | Data needed | Currently in payload | Gap |
|--------|------------|---------------------|-----|
| Prayer | All spec fields | ✅ 16 keys cover all §1 needs | None |
| Habits §2a | done + total | ✅ `habitsDone`, `habitsTotal` | None |
| Habits §2b | 7-day streak grid (per-habit or aggregate) | ❌ Missing | **New key needed**: `athar_habits_history_7d` — 7-element bool or daily done/total counts |
| Habits §2c | ring + streak + list max 6 | `streak` in payload (✅); cap is 5 not 6 (❌) | Raise Dart cap: `take(5)` → `take(6)` |
| Focus §3a | Today's focus minutes, daily goal | ❌ Not in payload | `athar_focus_minutes_today`, `athar_focus_goal_minutes` |
| Focus §3b | 7-day focus bar chart | ❌ Not in payload | `athar_focus_minutes_7d` (7-element int array) |
| Focus §3c | "Start session" deep-link | No link needed in data; WidgetKit `widgetURL` or AppIntent handles this | Architecture question — see OQ9 |

**Summary:** Prayer data is complete. Habits needs one new key for the 7-day grid (§2b only). Focus needs all keys from scratch.

---

## SECTION 4 — Design Conflicts

### Conflict A — Gating: spec header is wrong

**Spec header:** "All gated on the `isPrayerEnabled` master feature toggle."

This is a spec error. Three separate widgets with different domains should not share a single prayer feature gate.

**Proposed correct gating per widget:**

| Widget | Gate | Rationale |
|--------|------|-----------|
| Prayer widget | `isPrayerEnabled` | Prayer is the feature being displayed; correct to gate |
| Habits widget | Ungated (or `isHabitsEnabled` if such a flag exists) | Habit tracking is independent of prayer; prayer being off should not hide habit completions |
| Focus widget | Ungated | Focus session tracking is independent of prayer; the focus screen itself has no prayer gate |

**Implementation:** The "Master toggle off → show Enable prompt" state (spec §6) should be widget-specific:
- Prayer widget: when `isPrayerEnabled = false` → show "Enable Prayer in Athar" prompt
- Habits/Focus: no prayer gate applies; show their data or empty state per their own logic

**isPrayerEnabled in payload:** Currently, `isPrayerEnabled` is NOT in the App Group payload — `WidgetDataService` never pushes it to UserDefaults. The Prayer Swift widget shows data when the name fields are empty (stale state), not when a boolean is false. **If the "enable prompt" state is in scope for PR9, a new key `athar_is_prayer_enabled` (Int 0/1) must be added to the Dart push and read in Swift.** This is a new requirement vs. current behavior.

**Recommendation:** Flag the spec error to designer. Keep gating scoped to the Prayer widget only. Habits and Focus show their own data without a prayer gate.

### Conflict B — Scope: prayer + habits in PR9 v1; Focus → PR9b

**Evidence:**

- Prayer widget: 3 layouts fully implemented in Swift; data push complete (16 keys). Visual refresh only (gradient + font + countdown sizes + systemLarge layout). Lower risk.
- Habits widget: 3 layouts implemented; data push complete for §2a and §2c. Medium layout (§2b) needs new 7-day payload key. Ring-based layout restructure required for small and medium. Manageable with audit.
- Focus widget: Zero infrastructure — new Xcode target, new Swift file, new WidgetKeys constants, new `pushFocusData()` method, FocusCubit integration to track daily minutes (unclear if that data is even stored today). **This is a net-new widget, not a visual refresh.**

**Proposed scope split:**

**PR9 (this PR) = Prayer widget visual refresh + Habits widget visual refresh:**
- Prayer: gradient swap, countdown sizes, systemLarge layout, Calibri font bundle, `widgetURL`, post-prayer window fix
- Habits: gradient swap, ring-based small/medium layouts, Calibri font bundle, 7-day payload key

**PR9b (follow-on) = Focus widget (net-new):**
- New Xcode target + Swift file
- New `WidgetKeys` constants (focus_minutes_today, focus_goal_minutes, focus_minutes_7d)
- New `pushFocusData()` in `WidgetDataService`
- FocusCubit integration (does Isar store session history with timestamps? Unclear — requires FocusCubit audit)
- Device QA required for any new Xcode target

**Recommendation:** Approve PR9 = prayer + habits refresh; defer Focus widget to PR9b. The focus widget has a data-dependency question (see OQ6) that blocks implementation regardless.

---

## SECTION 5 — Open Questions

| ID | Question | Blocks |
|----|----------|--------|
| OQ1 | **Prayer systemLarge:** spec §1c defines a large (expanded) layout. Is `.systemLarge` in PR9 scope? Current code only supports small/medium/accessory. Adding large requires new SwiftUI view code. | PR9 prayer scope |
| OQ2 | **Post-prayer window duration:** spec says 40-min window for `isCurrentPrayerWindow`; Swift code uses 30 min (`< 1800s`). Which is authoritative? The prayer card spec (PR3) may have the canonical number. | Prayer widget `isCurrentPrayerWindow` |
| OQ3 | **Calibri in widget targets:** widget extensions do not inherit Runner's font bundle. Each extension's `Info.plist` must declare `UIFonts` with the `.ttf` files added to that extension target's bundle. This is a manual Xcode step (file membership must be set per target). Confirm this is in scope and flag it as a device-only test item. | Font rendering |
| OQ4 | **7-day habit history data:** spec §2b needs a 7-day streak grid. Does Isar store per-day habit completion history accessible from Dart? If yes, which table/field? If no per-day history exists, §2b (medium habits widget) is unimplementable without a schema change (new Isar entity or field). This is the single biggest data-dependency question for the Habits widget. | Habits §2b layout |
| OQ5 | **Habit ring diameter and color:** spec §2 says "28pt diameter, `AppColors.success`". What is `AppColors.success` in the v2 token set? Is it `AtharColors.success` (`#27AE60`) or the forest green `#0F3D2E`? Needs color authority clarification. | Ring color token |
| OQ6 | **Focus data in Isar:** does `FocusCubit` store completed session duration + timestamp in Isar? If not, there is no source for "today's focus minutes" or "7-day history" — the Focus widget has no data source at all, not just a payload gap. | PR9b scope |
| OQ7 | **WidgetTokens.swift pipeline:** spec §5 describes a build-time code-gen script (Dart → Swift token export). This is non-trivial infrastructure (build phase, script, output file path). Can PR9 ship using the current inline-const pattern (matching existing code) with the tokens manually kept in sync, and defer the pipeline to PR-CLEANUP or an infra PR? Recommendation: yes, defer — inline consts are auditable and the pipeline is a separate engineering task. | §5 infra |
| OQ8 | **Task widget visual refresh:** spec §2 only covers Habits; the task widget is not in spec. Should the task widget also get the forest gradient / Calibri refresh in PR9? Or stay as-is (navy/gold) until explicitly specced? | Task widget scope |
| OQ9 | **Focus "Start session" CTA:** spec §3c shows a "Start session" button that opens Focus with default duration. In WidgetKit this requires an `AppIntent` (interactive widget) OR a `widgetURL` tap. An AppIntent would need a new `StartFocusSessionIntent` struct. Is this in PR9b scope? | PR9b focus interaction |

---

## SECTION 6 — Xcode Change Risk Register

All Swift changes in PR9 are device/simulator-only — no CLI render possible. Each item below is a separate risk:

| Change | Risk | Notes |
|--------|------|-------|
| Gradient token swap (all 3 widgets) | Low | Inline color constant change; no Xcode project file edit |
| Calibri font bundle per extension | Medium | Requires `Add Files to Target` in Xcode for each extension; `UIFonts` key in each extension `Info.plist`. Wrong target membership → font silently falls back to system. Device validation required. |
| Prayer systemLarge layout | Medium | New `case .systemLarge:` branch + new SwiftUI view; add `.systemLarge` to `supportedFamilies` |
| `widgetURL` deep link | Low | `.widgetURL(URL(string: "athar://prayer")!)` modifier — no Xcode project change |
| Habit ring layout (small + medium) | Medium | Complete layout restructure; `Circle()` + progress ring in SwiftUI |
| 7-day habit history key | Low-Medium | New Dart `WidgetKeys` constant + `pushHabitData` addition + Swift `HabitEntry` field |
| Focus widget extension (PR9b) | High | New Xcode target — requires manual Xcode setup; entitlements; build phase; App Group membership; provisioning profile update; device test required |

---

## SECTION 7 — No-Code Constraints (per CLAUDE.md)

- ✅ No Dart code modified in this audit session
- ✅ No Swift code modified in this audit session
- ✅ No Xcode project edits made
- ✅ All findings are read-only observations

---

## SECTION 9 — Designer Sign-Off (2026-06-02)

**SIGNED OFF — proceed to implementation.**

OQ rulings applied:
- **OQ1 APPROVED:** `.systemLarge` in PR9 scope — new SwiftUI view (dual date, 40pt countdown, 5-prayer strip, progress bar). Sunrise/sunset omitted — not in 16-key payload; logged as P-item in self-report.
- **OQ2 RESOLVED:** Post-prayer window = 2400s (40 min). Swift `< 1800` → `< 2400`. In-app PrayerCubit window not touched in PR9; logged as P-item if discrepancy confirmed.
- **OQ3 CONFIRMED:** Calibri bundle per extension — written in Swift code; Xcode file-target-membership + UIFonts Info.plist steps listed in self-report as manual gates; device-only QA deferred.
- **OQ4 CONFIRMED YES:** `HabitModel.completedDays: List<DateTime>` exists in Isar. Push `athar_habits_history_7d` as JSON array of 7 ints (done count per day, index 0 = 6 days ago, 6 = today). Habits MEDIUM ships with 7-day grid.
- **OQ5 RESOLVED:** Habit ring color = `#27AE60` (AtharColors.success).
- **OQ7 DEFERRED:** WidgetTokens.swift pipeline deferred to PR-CLEANUP. Inline color consts updated to v2 forest palette.
- **OQ8 RESOLVED (Conflict B approved):** Task widget = gradient + Calibri token refresh only; no layout change.

Conflict A gating approved: Prayer gated by `athar_is_prayer_enabled` (Int 0/1); Habits + Task ungated.
Conflict B scope approved: PR9 = Prayer + Habits + Task(token-only). Focus widget → PR9b.

**Implementation constraints:**
- No Isar schema changes.
- No Xcode project file edits from CLI (target membership steps = manual — listed in self-report).
- All widget changes are code-conformance only; device QA deferred to PR9 sweep bucket.

---

## SECTION 8 — Summary Verdict

| Question | Answer |
|---------|--------|
| Is scaffolding greenfield? | **No — all three existing widget targets fully built.** Prayer, Task, Habit widgets have Swift files, Xcode targets, and data push. |
| Does AtharPrayerWidget exist as SwiftUI? | **Yes** — 611 lines, small/medium/accessory layouts, data-read from App Group. |
| App Group configured? | **Yes** — `group.com.iappsnet.athar` in all 4 entitlements files, all 3 Swift files, and Dart service. Spec §4's `group.app.athar.widgets` is a typo. |
| home_widget in pubspec? | **Yes** — `^0.6.0` |
| Focus data in payload? | **No** — zero focus keys anywhere |
| WidgetTokens.swift pipeline? | **Does not exist** — inline color consts per-file |
| "Low risk" rating for PR9 accurate? | **Conditional.** Prayer + Habits visual refresh are low-medium risk (infra exists). Focus widget is high risk / separate PR (net-new target). |

**Recommended PR9 scope:** Prayer widget visual refresh (3→4 sizes) + Habits widget visual refresh (ring-based restructure). Task widget: no change. Focus widget: PR9b.

**Entry blocker:** OQ4 (7-day habit history in Isar) must be answered before Habits medium layout can be specced. OQ2 (post-prayer window) is a minor spec discrepancy to confirm before prayer widget edit.
