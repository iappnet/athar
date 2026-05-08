# Design Gap Analysis — Athar

_Phase 3 output. Generated: 2026-05-06. Evidence-based only._

**Comparing:** Current Flutter UI (Phase 2 audit) vs New Design System (Phase 1 audit)

---

## Classification Key

- **A** — Fully covered by design system
- **B** — Partially covered
- **C** — Not covered by design system
- **D** — Covered visually but missing behavior/state spec
- **E** — Needs new design component
- **F** — Dangerous to redesign without extra rules

---

## Feature / Screen / Component Gap Table

| Item | Class | Gap Description |
|---|---|---|
| Color tokens | A | Fully matched CSS ↔ Dart. No gap. |
| Spacing tokens | A | Fully matched. No gap. |
| Radius tokens | A | Fully matched. No gap. |
| Shadow tokens | A | Fully matched. No gap. |
| Motion/animation tokens | A | Durations and curves matched. |
| Dark/light mode token system | A | Both themes defined. |
| App typography scale | B | Scale matches; font conflict (Calibri vs Cairo) unresolved |
| Hardcoded colors in 88 files | F | Redesign risk — must clean before token migration |
| App shell / LiquidGlassNavBar | B | Backdrop filter, 5 destinations, new brand colors needed |
| AdaptiveShell / NavigationRail | E | `AdaptiveShell` in `core/design_system/widgets/` not built |
| Dashboard layout (phone) | B | 3 duplicate pages need merging; visual refresh needed |
| Dashboard layout (iPad 2-col) | E | Tablet branch not implemented |
| Dashboard layout (iPad 3-col) | E | 3-col layout not implemented |
| Prayer card — compact/expanded | E | Not implemented; needs design spec for both variants |
| Prayer card — countdown mono font | B | JetBrains Mono not confirmed in current card |
| Prayer card — H:MM:SS format | B | Format exists; mono tabular not confirmed |
| Prayer card — sunrise/sunset arc | E | Not implemented; no Dart spec |
| Prayer card — progress bar | E | Not implemented; no Dart spec |
| Prayer card — Hijri-prominent date | E | Not confirmed; no Dart spec |
| Prayer card — all-5 strip | B | Strip exists; past/next visual states not confirmed |
| Prayer toggles architecture | F | Phase 8.1 recently completed — DO NOT TOUCH without full context |
| Prayer reminders | F | Notification scheduler architecture must survive redesign |
| Prayer screens (day/week/month) | B | Exist; visual refresh needed |
| Prayer compact vs full preference | E | User preference persistence not implemented |
| Tasks — phone list view | B | Exists; visual refresh (tokens, spacing) needed |
| Tasks — quick-add row | E | Not implemented |
| Tasks — smart-time chips | E | SmartTimeParser exists; widget chips not implemented |
| Tasks — iPad master-detail | E | Not implemented |
| Tasks — task detail (iPad right rail) | E | Not implemented |
| Tasks — hover states | E | Not implemented |
| Habits — phone list view | B | Exists; visual refresh needed |
| Habits — grid view | E | Currently list; grid not implemented |
| Habits — streak ring visual | D | Exists; ring visual not confirmed to spec |
| Habits — streak chip (numericMono) | D | Chip exists; mono font not confirmed |
| Habits — iPad 2-col/3-col layout | E | Not implemented |
| Habits — heatmap (token colors) | B | Exists; token color compliance not confirmed |
| Athkar UI | F | Exists; spec is weak. Do not merge with habits or redesign without explicit Athkar UX spec |
| Athkar progress model | D | Counter exists; animation/haptic not confirmed |
| Calendar — dual simultaneous display | F | Currently toggle; simultaneous is fundamental behavior change. REQUIRES DEDICATED SPEC |
| Calendar — DualDate value object | E | Does not exist; must be created |
| Calendar — CalendarCell widget | E | Does not exist; must be created |
| Calendar — DualMonthSwitcher | E | Does not exist; must be created |
| Calendar — first-of-Hijri hairline | E | Not implemented |
| Calendar — RTL numeral position swap | E | Not implemented (Hijri primary in RTL) |
| Calendar — iPad month+timeline | E | Not implemented |
| Calendar — timeline fan-in from tasks/habits/prayer | E | `CalendarCubit` does not fan-in; `TimelineItem` entity missing |
| Focus — oil fill animation | B | Partial implementation; full spec audit needed |
| Focus — gyroscope coupling | B | `sensors_plus` imported; full spec audit needed |
| Focus — 4 time-pressure tiers | D | Unknown if implemented |
| Focus — Dynamic Island halo | E | Not confirmed; iPhone SE fallback needed |
| Focus — Reduce Motion setting | E | Not implemented in SettingsCubit |
| Focus — Disable Gyroscope setting | E | Not implemented in SettingsCubit |
| Focus — iPad cap + session history | E | Not implemented |
| Stats — visual charts | C | Stats is a stub; no design data spec either |
| Stats — StatsRepository | E | Needs net-new data layer build |
| Stats — KPI aggregation | E | Cross-domain fan-in not implemented |
| Stats — iPad responsive grid | E | Not implemented |
| Settings — phone list | B | Exists; visual refresh needed |
| Settings — Modules block | E | Individual flags exist; unified `ModuleFlags` object not implemented |
| Settings — iPad two-pane | E | Not implemented |
| Settings — Reduce Motion toggle | E | Not implemented |
| Settings — Eastern numerals toggle | E | `useEasternNumerals` not in UserSettings |
| Spaces — phone list | B | Exists; visual refresh needed |
| Spaces — iPad 3-col permission matrix | E | Not implemented |
| Spaces — role chips (Owner/Admin/Member/Viewer) | E | Not confirmed in current UI |
| Onboarding | B | Exists in home/; not dedicated feature folder per spec |
| Onboarding — Modules step | E | Module-flag wiring not confirmed |
| Onboarding — Location step | E | Not confirmed as standalone step |
| Onboarding — iPad centered card | E | Not implemented |
| iOS widgets — visual design spec | C | No design system spec for widget visual language |
| iOS widgets — widget dark mode | C | Not audited |
| iOS widgets — medium/large variants | B | Exist; design spec missing |
| Add task bottom sheet | B | Exists with Phase 1/3 fixes; visual refresh |
| Add habit bottom sheet | B | Exists with Phase 2 fix; visual refresh |
| Add medicine / appointment sheet | B | Phase 3 fixes; visual refresh |
| Modal/sheet headers | D | Exist; not confirmed to spec style |
| Empty states | E | No systematic empty state widget |
| Error states | E | No systematic error state widget |
| Loading states (skeleton) | B | Skeleton exists; not confirmed systematic |
| Paywall card | D | Subscription page exists; visual unknown |
| Sync status card | C | No sync status widget found |
| Hover states (tablet) | E | Not implemented anywhere |
| Keyboard shortcuts | E | `AtharShortcuts` not found |
| Context menus (CupertinoContextMenu) | E | Not implemented |
| Drag-and-drop | E | Not implemented |
| Apple Pencil / CupertinoTextField | E | Not confirmed; TextField used in forms |
| Haptic feedback | D | `vibration` package exists; systematic use not confirmed |
| `numericMono` text style | E | Not defined in `AtharTypography` |
| Tabular figure font feature | E | Not applied to counters/timers |
| Eastern Arabic numerals | E | `useEasternNumerals` preference not implemented |
| Calibri font | E | Design spec primary font; not in Flutter project |
| Badge / chip components | B | `athar_selection.dart` exists; spec compliance unknown |
| Section headers | B | Used in settings; not systematic design component |
| Primary / secondary buttons | B | `app_button.dart` exists; gradient fill not confirmed |
| Central NavBar add workflow | F | Phase 1/2/3 critical fixes — do not break |

---

## Detailed Analysis of Critical Gaps

### Athkar UI

**Classification: F (Dangerous)**

Evidence: `athkar_card.dart`, `athkar_session_sheet.dart` in habits presentation. `lib/features/dhikr/` exists separately. Design system REDESIGN_AUDIT calls it "Dhikr ribbon / sheet" but provides no spec.

Gap: No explicit Athkar design spec in design system. Relationship between `dhikr/` feature and habits-presentation Athkar unclear. Counter animation, haptic on increment, session progress not confirmed. **Must not be redesigned or merged with habits without explicit Athkar UX spec from designer.**

---

### Prayer Master Toggle

**Classification: F (Dangerous)**

Evidence: Phase 6/8/8.1 series of fixes in BUGFIX_PHASE_STATUS.md. Four-level hierarchy: master → card → notifications → 15-min reminder. One-time migration. Save-ordering constraints (scheduler reads Isar, must save before calling scheduler).

Gap: Design system REDESIGN_AUDIT §2 references `SettingsState.modules.prayer` as a simple boolean. The real implementation is far more granular. **Any redesign of prayer settings must honor Phase 8.1 architecture.**

---

### Prayer Card Toggle

**Classification: F (Dangerous)**

Evidence: `isPrayerCardEnabled` sub-toggle (Phase 8.1), `SmartPrayerCardWrapper` checks both master and card flags.

Gap: Design system compact/expanded card variants with user preference not implemented. Implementing this touches the wrapper; must not break toggle guard.

---

### Prayer Notification Toggle

**Classification: F (Dangerous)**

Evidence: `isPrayerNotificationsEnabled` controls scheduler. Scheduler guard: `!isPrayerEnabled || !isPrayerNotificationsEnabled`.

Gap: Design system spec doesn't detail this multi-level guard. **Never simplify to single toggle without full Phase 8 regression testing.**

---

### Prayer Reminders

**Classification: F (Dangerous)**

Evidence: `enablePrayerReminders` sub-sub-toggle, `scheduleSevenDays()` only called when both `isPrayerEnabled && isPrayerNotificationsEnabled`.

Gap: Notification ID ranges must not be changed. Auto-renewal mechanism must survive redesign.

---

### iOS Widgets

**Classification: B/C**

Evidence: Phase 4/5 fixes in Swift files. No widget design spec in design system.

Gaps: No visual language spec for widgets. Dark mode widget design missing. Medium/large widget designs missing. Widget locale bug (P1 in KNOWN_PROBLEMS) — `athar_app_locale` in UserDefaults not updated on language change.

---

### Add Bottom Sheets

**Classification: B**

Evidence: Phase 1/2/3 fixes applied. `_isSaving` guards, async saves, state-check before pop.

Gaps: Visual design refresh needed. Smart-time chip parsing via `SmartTimeParser` not in sheets. `CupertinoTextField` for Pencil support not confirmed.

---

### Interactive Task States

**Classification: D/E**

Evidence: `task_tile.dart` exists. Swipe gestures via `flutter_slidable` in pubspec.

Gaps: Completion animation not confirmed. Hover state not implemented. Smart-time chip input not implemented.

---

### Interactive Habit States

**Classification: D/E**

Evidence: `minimal_habit_tile.dart`, `habit_heatmap.dart` exist.

Gaps: Grid view not implemented (currently list). Streak ring visual spec compliance unknown. Count-based vs check-based distinction not confirmed in widget.

---

### Stats Metric Cards

**Classification: E**

Evidence: `statistics_card.dart` exists but cubit is stub.

Gaps: No live data. KPI definitions not specified. Chart card design unknown.

---

### Stats Charts

**Classification: E**

Evidence: `fl_chart` in pubspec, `stats_weekly_focus_chart.dart` exists.

Gaps: Data sources not connected. Chart design spec from `StatsScreen.jsx` not read. Repository needs building from scratch.

---

### Calendar Dual Hijri/Gregorian

**Classification: F (Dangerous)**

Evidence: `dual_calendar_widget.dart` has TOGGLE. Design spec requires SIMULTANEOUS display.

Gaps: Fundamental behavior change. `DualDate` entity missing. `CalendarCell` widget missing. `DualMonthSwitcher` missing. Hairline marker for first-of-Hijri-month missing. RTL numeral swap missing. Calendar fan-in from tasks/habits/prayer missing (`TimelineItem` entity missing). `CalendarCubit` doesn't aggregate cross-domain data.

**This is one of the largest single gaps in the entire codebase.**

---

### Sync Status / Settings

**Classification: C**

Evidence: `SyncCubit` exists, `lastSyncAt`/`lastSyncError` in UserSettings.

Gaps: No sync status widget found. No visual design spec.

---

### Subscription Gates / Free Limits

**Classification: D**

Evidence: `SubscriptionCubit` (`@lazySingleton` — Phase 1 fix), `TaskFreeLimitReached`, `HabitFreeLimitReached` states.

Gaps: Paywall page visual unknown. Pre-emptive gate UI (show paywall before attempting add over-limit) not confirmed.

---

### Empty States

**Classification: E**

Evidence: None found.

Gaps: SKILL.md §2.4 defines spec: "large feature glyph (48-64px) + warm one-liner + single CTA." Not implemented as a reusable widget. Required by IPAD spec for master-detail detail pane.

---

### Error States

**Classification: E**

Evidence: Inline error widgets in prayer card. Cubit error states exist.

Gaps: No systematic, reusable `ErrorState` widget.

---

### Loading States

**Classification: B**

Evidence: `athar_skeleton.dart` exists.

Gaps: Not confirmed as systematically used. Prayer card uses `CircularProgressIndicator` inline.

---

### Arabic Typography

**Classification: B**

Evidence: Cairo is current primary. Type scale matches.

Gaps: Calibri (design primary) not in project. `numericMono` not defined. Tabular figures not applied to counters. Eastern Arabic numerals not implemented. Calibri decision needed before migration.

---

### English Typography

**Classification: B**

Evidence: Inter in token file.

Gaps: Whether widgets actually use Inter for English strings (vs Cairo for everything) not confirmed without screen-level audit.

---

### RTL/LTR Spacing and Alignment

**Classification: B**

Evidence: Phase 4b fixes applied. Directional extensions exist.

Gaps: 88 files still with hardcoded values. Calendar dual-display RTL swap not implemented. Some directional violations may remain.

---

### Accessibility

**Classification: C (Not audited)**

Evidence: 44px tap targets mentioned in SKILL.md.

Gaps: Semantics not confirmed. Screen reader not confirmed. Contrast ratios not audited. Dynamic Type not confirmed. Reduce Motion not implemented.

---

### Dark / Light Mode

**Classification: B**

Evidence: Both themes defined. 88 hardcoded-color files bypass dark mode.

Gaps: Systematic cleanup of 88 files required before dark mode is reliable.

---

### App Navigation

**Classification: B**

Evidence: `liquid_glass_nav_bar.dart` exists. Named routes in `app.dart`.

Gaps: NavigationRail iPad branch (`AdaptiveShell`) not built per spec. Master-detail not implemented.

---

### Central NavBar Add Workflow

**Classification: F (Dangerous)**

Evidence: Phase 1/2/3 critical fixes — `SubscriptionCubit` singleton, `_isSaving` guards, async saves.

Gaps: Any visual refactor of NavBar must not break `+` FAB dispatch logic and must not introduce page-level FABs.
