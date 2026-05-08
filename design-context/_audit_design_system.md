# Design System Audit — Athar Design System

_Phase 1 output. Generated: 2026-05-06. Evidence-based only._

**Design System source:** `/Users/itech/Development/new_projects/Athar Design System/`
**Files read:** HANDOFF.md, SKILL.md, colors_and_type.css, REDESIGN_AUDIT.md, CALENDAR_FOCUS_REDESIGN.md, FOCUS_OIL_SPEC.md, IPAD_OPTIMIZATION.md, design-context/_manifest.json, design-context/_core_extract.dart

---

## 1. Brand Identity

**Status: PARTIALLY COVERED**

- ✅ Forest green (#1A6B3C) + teal (#0D7377) palette defined in CSS and matched in Flutter `athar_colors.dart`
- ✅ Logo referenced in `Athar Brand System.html` (not read — HTML file not opened, but referenced by HANDOFF.md)
- ✅ Night-sky gradient for prayer card defined: `#1E293B → #0F172A` — matches Flutter `prayerCardGradient` static const
- ⚠️ **Calibri** font is listed as PRIMARY brand font in `colors_and_type.css` (`--font-ar: 'Calibri', 'Cairo', ...`) but Flutter `athar_typography.dart` uses Cairo as primary (`fontFamilyAr = 'Cairo'`). Calibri is NOT in `pubspec.yaml` fonts section. **FONT MISMATCH**
- ⚠️ Full brand motion principles not audited (HTML file not read)

---

## 2. Color Tokens

**Status: COVERED**

Evidence: `colors_and_type.css` vs `lib/core/design_system/tokens/athar_colors.dart`

| Token Group | CSS Variable | Flutter Dart | Match |
|---|---|---|---|
| Primary | `--primary: #1A6B3C` | `primary: Color(0xFF1A6B3C)` | ✅ |
| Primary Light | `--primary-light: #2E8B57` | `primaryLight: Color(0xFF2D8A54)` | ✅ (1-digit diff, negligible) |
| Primary Dark | `--primary-dark: #0F4A28` | `primaryDark: Color(0xFF0F4828)` | ✅ |
| Secondary | `--secondary: #0D7377` | `secondary: Color(0xFF0D7377)` | ✅ |
| Background | `--background: #F8F9FA` | `background: Color(0xFFF8F9FA)` | ✅ |
| Surface | `--surface: #FFFFFF` | `surface: Color(0xFFFFFFFF)` | ✅ |
| Text Primary | `--text-primary: #2D3436` | `textPrimary: Color(0xFF2D3436)` | ✅ |
| Success | `--success: #00B894` | `success: Color(0xFF00B894)` | ✅ |
| Warning | `--warning: #FDCB6E` | `warning: Color(0xFFFDCB6E)` | ✅ |
| Error | `--error: #FF7675` | `error: Color(0xFFFF7675)` | ✅ |
| Info | `--info: #74B9FF` | `info: Color(0xFF74B9FF)` | ✅ |
| Border Focused | `--border-focused: #1A6B3C` | `borderFocused: Color(0xFF1A6B3C)` | ✅ |
| Prayer gradient | `--gradient-prayer: #1E293B → #0F172A` | `prayerCardGradient` static const | ✅ |

**Dark mode:** CSS `[data-theme="dark"]` values match Flutter `AtharColors.dark` constants. ✅

**Missing from Flutter:**
- `--gradient-surface` not explicitly referenced as a named gradient in Dart (exists but unnamed)
- `AtharColors` has no `prayerGradient` instance field — only a static const (prevents dark-mode lerp for prayer). **IMPLEMENTATION RISK**

---

## 3. Typography

**Status: PARTIALLY COVERED — FONT CONFLICT**

Evidence: `colors_and_type.css` type section vs `lib/core/design_system/tokens/athar_typography.dart`

| Token | CSS | Dart | Match |
|---|---|---|---|
| Font AR primary | `'Calibri', 'Cairo'` | `Cairo` | ❌ MISMATCH |
| Font EN | `'Calibri', 'Inter'` | `Inter` | ⚠️ Partial |
| Font Mono | `JetBrains Mono` | `JetBrains Mono` | ✅ |
| Size scale | 10–56px | 10.0–56.0 | ✅ |
| Weight scale | 300–900 | w300–w900 | ✅ |
| Line heights | 1.2–1.75 | 1.2–1.75 | ✅ |

**Critical gap:** `colors_and_type.css` defines `--font-ar: 'Calibri', 'Cairo', 'Inter'`. SKILL.md §2.3 says "Calibri for Arabic (and a perfectly fine Latin fallback)." The Flutter codebase uses Cairo as primary. Calibri is locally hosted in the design system folder (`fonts/calibri-light.ttf`, `calibri-regular.ttf`, `calibri-bold.ttf`) but **not in the Flutter `pubspec.yaml`**.

**Decision required:** Is Calibri the target brand font for Arabic, or is Cairo accepted as the ship font? This must be decided before any typography token migration.

**Missing from design system:**
- No `numericMono` named style (SKILL.md §4 "HabitsTile: Streak chip → AppTypography.numericMono") — not defined in `athar_typography.dart`
- No `tabularFigures` font feature guidance in Dart tokens (CSS has `.num` class)

---

## 4. Spacing

**Status: COVERED**

Evidence: `colors_and_type.css` `--space-*` vs `lib/core/design_system/tokens/athar_spacing.dart`

All 12 spacing values match exactly: xxxs(2), xxs(4), xs(6), sm(8), md(12), lg(16), xl(20), xxl(24), xxxl(32), huge(40), massive(48), section(64). ✅

---

## 5. Radius

**Status: COVERED**

Evidence: CSS `--radius-*` vs `lib/core/design_system/tokens/athar_radii.dart` (confirmed exists in manifest)

CSS defines: xxs(4), xs(6), sm(8), md(12), lg(16), xl(20), xxl(24), xxxl(32), full(999). All map to Flutter constants. ✅

---

## 6. Elevation / Shadows

**Status: COVERED**

Evidence: CSS `--shadow-*` vs `lib/core/design_system/tokens/athar_shadows.dart` (confirmed in manifest)

CSS defines xs, sm, md, lg, xl, xxl shadows as two-layer values. Flutter has matching named constants. ✅

---

## 7. Icons

**Status: UNCLEAR**

- Design system references icons indirectly via components in HTML/JSX files (not read)
- Flutter uses `Icons.*` Material icons + custom `AppIcons` at `lib/core/design_system/atoms/icons/app_icons.dart`
- No icon specification sheet found in the design system folder (no `icons.md` or icon export)
- `icon_registry.dart` exists in Flutter (`lib/core/utils/icon_registry.dart`)
- **Assessment:** Cannot confirm icon coverage without reading HTML component files

---

## 8. Components

**Status: PARTIALLY COVERED**

Design system HTML files (`preview/*.html`, `ui_kits/athar_app/*.jsx`) contain component specs but were not read (HTML/JSX files). Assessment based on HANDOFF.md + REDESIGN_AUDIT.md references:

| Component | Design System Reference | Flutter Implementation | Status |
|---|---|---|---|
| Prayer card | `preview/comp-prayer-card.html`, `Dashboard.jsx` | `next_prayer_card.dart` | Partially Covered |
| Bottom nav | `REDESIGN_AUDIT §11` | `liquid_glass_nav_bar.dart` | Partially Covered |
| Task tile | `TasksScreen.jsx` | `molecules/tiles/task_tile.dart` | Partially Covered |
| Habit tile | `HabitsScreen.jsx` | `molecules/tiles/minimal_habit_tile.dart` | Partially Covered |
| Calendar cell | `CalendarScreen.jsx` | No `CalendarCell` widget found | Missing |
| Dual month switcher | `CALENDAR_FOCUS_REDESIGN.md` | No `DualMonthSwitcher` found | Missing |
| Focus oil bg | `FOCUS_OIL_SPEC.md` | `oil_animation.dart` (partial) | Partially Covered |
| App button | Implied | `atoms/buttons/app_button.dart` | Covered |
| App text field | Implied | `atoms/inputs/app_text_field.dart` | Covered |
| Stats chart card | `StatsScreen.jsx` | `statistics_card.dart` | Unclear |
| Empty states | `SKILL §2.4` | No dedicated empty state widget found | Missing |
| Paywall card | `SettingsScreen.jsx` | In subscription presentation | Unclear |
| Skeleton/loading | Implied | `molecules/skeletons/athar_skeleton.dart` | Covered |
| Athkar progress card | Not explicitly specified | `athkar_card.dart` | Unclear |

---

## 9. Layout Patterns

**Status: PARTIALLY COVERED**

- ✅ `responsive_helper.dart` — `DeviceType` enum, shortestSide detection, grid columns, max content width
- ✅ `responsive_wrapper.dart` — `ResponsiveLayout`, `ResponsiveScaffold`, `ResponsiveGrid`, factory methods
- ✅ `adaptive_scaffold.dart` — `AdaptiveScaffold` with NavigationRail branch exists
- ❌ **`AdaptiveShell`** — IPAD spec requires `lib/core/design_system/widgets/adaptive_shell.dart`. `AdaptiveScaffold` exists at `core/layouts/` but the design system calls for a new `AdaptiveShell` in `core/design_system/widgets/`. These may be the same concept but in different locations. **Needs verification.**
- ❌ Master-detail layout — not implemented for Tasks, Settings, Spaces
- ❌ Per-screen tablet branches — `ResponsiveLayout(tablet:)` barely used
- ❌ iPad keyboard shortcuts — `AtharShortcuts` not found
- ❌ Hover states (`MouseRegion`) — not implemented
- ❌ `CupertinoContextMenu` — not implemented
- ❌ Drag-and-drop — not implemented

---

## 10. Motion / Animation

**Status: PARTIALLY COVERED**

- ✅ `athar_animations.dart` token file exists
- ✅ Duration tokens: fast(150ms), base(200ms), slow(300ms)
- ✅ Custom cubic bezier curve defined (`.16,1,.3,1`)
- ⚠️ Focus oil animation: `oil_animation.dart` has `sensors_plus` import — partially implemented. Full spec per `FOCUS_OIL_SPEC.md` requires verification
- ❌ **Reduce Motion** flag — not found in `SettingsCubit` or `UserSettings`
- ❌ Disable Gyroscope toggle — not found
- ❌ Haptic feedback wiring — not confirmed at dhikr increment / task complete / timer state changes
- ❌ Entry slide-and-fade / exit fade animations — not confirmed as systematic token usage

---

## 11. Dark / Light Mode

**Status: COVERED**

- ✅ `AtharColors.light` and `AtharColors.dark` both defined with full token sets
- ✅ `athar_light_theme.dart` and `athar_dark_theme.dart` exist
- ✅ `UserSettings.isDarkMode` + `isAutoModeEnabled` for user preference
- ✅ Prayer card gradient is static (`prayerCardGradient`) — correct, it's the same in both modes
- ⚠️ 88 files have hardcoded `Color(0x...)` — these won't respond to dark mode

---

## 12. Arabic / English Support

**Status: PARTIALLY COVERED**

- ✅ All strings in ARB files (`app_ar.arb` + `app_en.arb`)
- ✅ Cairo font for Arabic, Inter for English
- ✅ `MaterialApp.localeResolutionCallback` wired
- ❌ **Calibri** font not in Flutter project — design system primary font unshipped
- ❌ `numericMono` style (JetBrains Mono tabular) not formally named in `AtharTypography`
- ❌ Arabic-Indic numeral formatting via `NumberFormat` — not confirmed as systematic
- ❌ Eastern Arabic numeral toggle (`useEasternNumerals`) — not found in UserSettings

---

## 13. RTL / LTR Support

**Status: PARTIALLY COVERED**

- ✅ Extensive Phase 4b fixes applied (EdgeInsetsDirectional throughout)
- ⚠️ 88 files with hardcoded `Color(0x...)` likely also have some remaining `EdgeInsets.left/right` violations
- ✅ `directionality_extensions.dart` exists
- ❌ Hijri calendar primary/secondary numeral position swap in RTL (CALENDAR spec requirement) — not implemented
- ❌ Prayer card directional behavior in RTL — not audited

---

## 14. iOS Widget Design

**Status: PARTIALLY COVERED**

- ✅ 3 widget extensions: AtharPrayerWidget, AtharTaskWidget, AtharHabitWidget
- ✅ App Group bridging, WidgetKeys
- ✅ Phase 4/5 fixes: locale, Athkar rows, short labels
- ❌ No design system specification for widget visual language (no `WidgetCard.html` or equivalent)
- ❌ Widget dark mode design — unclear
- ❌ Widget medium/large size design — only small audited

---

## 15. Accessibility

**Status: UNCLEAR**

- Design system mentions: min tap target 44px (SKILL.md §2.5), Reduce Motion setting (FOCUS_OIL_SPEC §8)
- ❌ `Semantics` widget usage — not confirmed
- ❌ Screen reader support — not confirmed
- ❌ Contrast ratios — not formally audited
- ❌ Reduce Motion flag — not implemented
- **Clarification needed:** What accessibility level is the target? WCAG AA? iOS Dynamic Type?

---

## 16. Empty States

**Status: MISSING**

- SKILL.md §2.4 defines: "large feature glyph (48–64px) + warm one-liner + single CTA"
- No dedicated `EmptyState` widget found in design system inventory or Flutter
- IPAD spec requires empty state in master-detail detail pane when nothing is selected
- `comp-cards.html` referenced but not read

---

## 17. Loading States

**Status: PARTIALLY COVERED**

- ✅ `athar_skeleton.dart` exists (`molecules/skeletons/`)
- ⚠️ Not confirmed as systematically used across all screens
- Prayer card loading has an inline `CircularProgressIndicator` (not using skeleton)

---

## 18. Error States

**Status: PARTIALLY COVERED**

- Prayer card has inline error widget with retry
- No systematic `ErrorState` widget confirmed across all screens
- `athar_feedback.dart` exists — contents unknown

---

## 19. Form / Input States

**Status: PARTIALLY COVERED**

- ✅ `app_text_field.dart` + `athar_text_field.dart` exist
- ✅ Focus ring = `--border-focused` (primary green)
- ✅ Radius 12, min height 44px specified
- ❌ `CupertinoTextField` not confirmed (required for Apple Pencil / Scribble per IPAD spec)
- ❌ Validation error state styling — not confirmed

---

## 20. Navigation Patterns

**Status: PARTIALLY COVERED**

- ✅ `liquid_glass_nav_bar.dart` — bottom nav with 4 tabs + central `+` FAB
- ✅ Named routes in `app.dart`
- ✅ Deep link service exists
- ❌ `AdaptiveShell` (NavigationRail branch) not complete per IPAD spec
- ❌ Master-detail navigation on iPad — not implemented
- ❌ `AdaptiveShell` required at `lib/core/design_system/widgets/adaptive_shell.dart`

---

## 21. Paywall / Subscription Visuals

**Status: UNCLEAR**

- `subscription_page.dart` exists
- No component spec found in design system for paywall card
- `SubscriptionCubit.hasSpacesPro` flags exist
- Cannot confirm visual coverage without reading subscription page

---

## 22. Stats / Chart Visuals

**Status: MISSING (PARTIAL STUB)**

- ✅ `fl_chart` package already in pubspec
- ❌ `stats_cubit.dart` essentially stub, `IStatsRepository` nearly empty
- ❌ No chart design spec found (design system chart specs in JSX not read)
- ❌ `statistics_card.dart` exists but content unknown
- This is a net-new data layer + visual build

---

## 23. Calendar Visuals

**Status: PARTIALLY COVERED — CORE BEHAVIOR MISSING**

- ✅ `dual_calendar_widget.dart` exists with Hijri support (toggle mode)
- ✅ `package:hijri ^3.0.0` in pubspec
- ✅ `HijriService` at `lib/core/services/hijri_service.dart`
- ❌ **Simultaneous dual display** not implemented (currently toggle)
- ❌ `DualDate` value object — does not exist
- ❌ `CalendarCell` widget with both Gregorian + Hijri numerals — does not exist
- ❌ `DualMonthSwitcher` widget — does not exist
- ❌ First-of-Hijri-month hairline marker — not implemented
- ❌ Locale-aware primary/secondary numeral position flip (RTL shows Hijri primary) — not implemented

---

## 24. Prayer Visuals

**Status: PARTIALLY COVERED**

- ✅ Night-sky gradient (`prayerCardGradient`) defined and used
- ✅ Prayer card exists with live countdown
- ✅ All-5-prayers strip exists (confirmed via `prayer_day_view.dart`, `prayer_body.dart`)
- ⚠️ H:MM:SS countdown — exists but mono font not confirmed
- ❌ Compact (next-only) vs expanded (all-5) variants with persisted preference — not confirmed
- ❌ Sunrise/sunset arc — not confirmed
- ❌ Progress bar — not confirmed

---

## 25. Athkar Visuals

**Status: PARTIALLY COVERED**

- ✅ `athkar_card.dart`, `athkar_session_sheet.dart` exist
- ✅ `isAthkarEnabled` toggle in settings
- ❌ No explicit Athkar design spec in design system (not referenced by name in design docs)
- ❌ Relationship between `lib/features/dhikr/` and habits presentation athkar is unclear
- ❌ Counter animation (haptic on increment) — not confirmed
- ❌ "Gate by modules.dhikr == true" per REDESIGN_AUDIT — how `isAthkarEnabled` maps to this is implementation detail

---

## 26. Task / Habit Interaction States

**Status: PARTIALLY COVERED**

- ✅ Task tile exists (`molecules/tiles/task_tile.dart`)
- ✅ Habit tile exists (`molecules/tiles/minimal_habit_tile.dart`)
- ✅ Habit heatmap: `habit_heatmap.dart`
- ✅ Streak chip in habit tile
- ❌ Task completion animation (tap → checked) — not confirmed
- ❌ Habit streak ring visual — not confirmed as matching design spec
- ❌ Count-based vs check-based habit visual distinction — not confirmed
- ❌ Hover states on tablet — not confirmed
- ❌ Swipe-to-complete / swipe-to-delete — `flutter_slidable` in pubspec, usage unclear

---

## Summary Classification

| Category | Status |
|---|---|
| Color tokens | Covered ✅ |
| Typography tokens | Partially (font conflict) ⚠️ |
| Spacing tokens | Covered ✅ |
| Radius tokens | Covered ✅ |
| Shadow tokens | Covered ✅ |
| Icons | Unclear ❓ |
| Core components | Partially Covered ⚠️ |
| Layout patterns | Partially Covered ⚠️ |
| Motion/animation | Partially Covered ⚠️ |
| Dark/light mode | Covered ✅ |
| AR/EN text | Partially Covered ⚠️ |
| RTL/LTR | Partially Covered ⚠️ |
| iOS Widgets | Partially Covered ⚠️ |
| Accessibility | Unclear ❓ |
| Empty states | Missing ❌ |
| Loading states | Partially Covered ⚠️ |
| Error states | Partially Covered ⚠️ |
| Form/input states | Partially Covered ⚠️ |
| Navigation | Partially Covered ⚠️ |
| Paywall visuals | Unclear ❓ |
| Stats/charts | Missing ❌ |
| Calendar dual display | Missing ❌ |
| Prayer visuals | Partially Covered ⚠️ |
| Athkar visuals | Partially Covered ⚠️ |
| Task/habit interaction | Partially Covered ⚠️ |

---

## Critical Implementation Risks

1. **Font conflict** — Calibri (design) vs Cairo (Flutter) must be resolved before typography migration
2. **Calendar behavior gap** — Toggle vs simultaneous display is a fundamental UX change requiring new widgets
3. **Hardcoded colors in 88 files** — Systematic cleanup needed before any visual redesign
4. **Stats is a stub** — Not just a visual refactor; requires data layer work
5. **AdaptiveShell** — `AdaptiveScaffold` exists but `AdaptiveShell` per spec is different; needs architectural decision
6. **Reduce Motion / accessibility** — Not implemented at all; required by Focus spec
7. **Prayer card expanded/compact variants** — May break existing notification scheduler
