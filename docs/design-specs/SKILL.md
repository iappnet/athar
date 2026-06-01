---
name: athar-design
description: Build Flutter UI (widgets, screens, themes) for Athar (أثر) — a bilingual Arabic/English personal-productivity app. This skill teaches Claude Code the real architecture (BLoC + Isar + Supabase + IAM + Time Engine), the visual language (indigo/teal, Cairo + Inter, soft cards, liquid-glass nav), and the rules for adding screens without breaking the existing patterns. Use whenever generating new screens, widgets, cubits, or theme work in `iappnet/athar`.
user-invocable: true
---

# Athar — Flutter Build Skill (for Claude Code)

You are extending **`iappnet/athar`** — a Flutter app shipping on iOS/Android. You have read access to a design-system workspace (`/projects/<this-project-id>/`) that contains tokens, mockups, and component previews. **The mockups are HTML/JSX — they are reference, not source.** Your job is to translate those visuals into Flutter that fits the app's existing architecture.

Before you write code, **read these files in this order**:

1. `README.md` (this workspace) — voice, palette conflicts, asset gaps.
2. `REDESIGN_AUDIT.md` — per-screen ticket list mapping each JSX mockup to the live Dart files (target paths, cubit assertions, refactor deltas).
3. `IPAD_OPTIMIZATION.md` — per-screen iPad layouts (master-detail, NavigationRail shell, keyboard shortcuts, drag-and-drop, Pencil). Apply *after* the matching phone screen in the audit lands.
4. `colors_and_type.css` — every design token already mapped from `lib/core/design_system/tokens/`.
5. `design-context/_manifest.json` — list of every Dart file in the codebase, grouped by feature.
6. `design-context/_core_extract.dart` — the architectural backbone (time engine, IAM, DI, top-level cubits) in one file.
7. The relevant feature folder under `lib/features/<feature>/` for whatever you're building.

If the user attaches the codebase directly, prefer reading from `lib/...` over the workspace extracts.

---

## 1. Architectural laws (do not break)

### 1.1 Layer model — Clean Architecture per feature

Every feature under `lib/features/<name>/` follows:

```
data/
  models/         Isar @collection classes (mirrored to Supabase)
  repositories/   *_repository_impl.dart — Isar + Supabase
domain/
  entities/       Plain Dart classes (Equatable) — what the UI consumes
  repositories/   abstract <Name>Repository — contract
presentation/
  cubit/          <name>_cubit.dart + <name>_state.dart  (flutter_bloc)
  pages/          full screens
  widgets/        feature-scoped widgets
```

**Rule**: a widget never imports a `data/` model. It consumes the entity or the cubit's state. The repository is the only thing that crosses the data ↔ domain line. If you find yourself importing `task_model.dart` from a widget, stop and add a getter to the entity instead.

### 1.2 State management — BLoC (cubits, not blocs)

Every feature's UI is driven by a `Cubit` registered in `lib/app.dart` via `MultiBlocProvider` and resolved through GetIt (`getIt<XCubit>()`). New cubits **must** be:

- Annotated `@injectable` (added to `injection.config.dart` by `build_runner`).
- Named `<Feature>Cubit` with a sibling `<Feature>State` sealed class hierarchy: `<Feature>Initial`, `<Feature>Loading`, `<Feature>Loaded`, `<Feature>Error`.
- Listening to repositories via `Stream` → `StreamSubscription`, cancelled in `close()`.

Don't introduce Riverpod, Provider, or `setState` for cross-screen data. Local-only ephemeral state (a toggle inside one widget) is fine in `StatefulWidget`.

### 1.3 Persistence — Isar first, Supabase second

- **Local**: every model is an Isar `@collection` with a stable `uuid` (string) and integer `id` (Isar's auto-id, ignored by sync).
- **Remote**: Supabase Postgres. The `SyncService` + per-feature `*_repository_impl.dart` reconcile on app resume + on push.
- **Reads** in the UI are **Isar streams** (`watchSomething(...)`). Never `.read()` Supabase from a widget — go through the repo, which prefers Isar.
- **Writes** go to Isar immediately (optimistic UI), then queue a Supabase write. The repo handles conflict.

### 1.4 DI — `getIt` + `injectable`

Use `@injectable` (or `@lazySingleton` for services) and let `build_runner` regenerate `injection.config.dart`. Never instantiate a repository or service directly in a widget tree. Always `getIt<X>()` or, better, `context.read<XCubit>()`.

### 1.5 IAM — every action that touches a Space goes through `PermissionService`

`lib/core/iam/permission_service.dart` is the single source of truth for "can the current user do X in this space?" It:

- Caches roles in `PermissionCache` per `spaceId`.
- Resolves `SpaceRole` (`owner`, `admin`, `member`).
- For members, applies module-level `DelegationMode` (`enabled` / `disabled` / `inherit`).
- Has typed helpers: `canCreate`, `canEdit`, `canDelete`, plus task-specific `canViewTask`, `canEditTask`, `canDeleteTask`, `canAssignTask`.

**Rule**: any cubit method that creates/updates/deletes a space-scoped resource starts with a `permissionService.canX(...)` check and emits an error state if it fails. See `module_cubit.dart` for the canonical pattern. Personal resources (`spaceId == null`) skip the check.

### 1.6 Time Engine — never hardcode "morning" / "evening"

`lib/core/time_engine/` defines **11 named periods** keyed off prayer times:

`dawn · bakur · morning · noon · afternoon · maghrib · isha · night · lastThird · undefined · duha`

Use `AtharTimeCalculator.getCurrentPeriod(...)` to derive the current period and `SmartTimeParser` to interpret user-entered relative times ("بعد العصر بساعة", "after asr +1h"). Greetings, scheduling defaults, and the home zone-detector all read from this — match that pattern instead of computing your own buckets.

### 1.7 Subscription gates — check before unlocking

Free-tier limits live in `lib/core/config/subscription_config.dart`:

- `freeTasksLimit = 20`, `freeHabitsLimit = 5`
- Entitlements: `spaces_pro`, `sync_pro`, `health_pack`, `assets_pack`

Before exposing a paid feature, query `getIt<SubscriptionCubit>().hasSpacesPro` (or the relevant flag) and route to the paywall if false. **Don't** silently let users create over-limit items and fail at save time.

### 1.8 Notifications — schedulers, never raw

There are dedicated schedulers per domain: `prayer_notification_scheduler`, `habit_notification_scheduler`, `medication_notification_scheduler`, `appointment_notification_scheduler`, `asset_notification_scheduler`, `project_notification_scheduler`. They allocate IDs through `notification_id_manager.dart` to avoid collisions. Never call `LocalNotificationService.schedule(...)` directly from a feature — go through (or add) a scheduler.

---

## 2. Visual language

### 2.1 Tokens

All tokens live as Dart constants in `lib/core/design_system/tokens/` and are mirrored 1-to-1 in `colors_and_type.css`. **Use the Dart tokens — never hardcode hex / dp.**

| Concern | Source |
|---|---|
| Colors | `tokens/colors.dart` (light) + `tokens/colors_dark.dart` |
| Type | `tokens/typography.dart` — `AppTypography.headline*`, `body*`, `caption*` |
| Spacing | `tokens/spacing.dart` — `AppSpacing.xs/sm/md/lg/xl/xxl` (4-pt grid) |
| Radii | `tokens/radii.dart` — `AppRadii.sm` (8) … `xxxl` (32) … `full` (999) |
| Shadows | `tokens/shadows.dart` — `AppShadows.sm/md/lg/xl` (two-layer) |
| Motion | `tokens/animations.dart` — durations + curves |

The `Theme.of(context)` `ColorScheme` is wired in `themes/app_theme.dart` from the same tokens. Prefer `Theme.of(context).colorScheme.primary` over `AppColors.primary` inside widgets — it makes dark mode free.

### 2.2 Color rules

- **Primary** is indigo `#1A6B3C` (yes, the hex looks green — it renders as a deep teal-leaning indigo in context). **Secondary** is teal `#0D7377`. Don't introduce a third brand hue.
- **Backgrounds** are flat `#F8F9FA` (light) and `#121212` (dark). No gradients on page backgrounds.
- **Gradients** are reserved for: primary CTA fills, the Prayer card (`gradient-prayer` — fixed night sky in both themes), and the Focus session fluid background.
- **Status colors** are `#00B894` / `#FDCB6E` / `#FF7675` / `#74B9FF`. Each has a `*-light` tint for backgrounds.

### 2.3 Type rules

- **Calibri** is the **sole canonical brand font** for the entire Athar experience — Arabic AND English, UI, headings, body, onboarding, widgets, showcase, and specs alike. Weights: Light 300 / Regular 400 / Bold 700. Use it everywhere; do not introduce a second face. **JetBrains Mono** for numerals when alignment matters (timer, counters, stats). Cairo and Inter are NOT design-authority fonts — they may appear only as emergency technical fallbacks in font stacks (last-resort glyph rendering), never as the named primary in any design surface.
- Set `MaterialApp.locale` based on settings. Arabic forces `Directionality.rtl` — every custom widget must respect `Directionality.of(context)`.
- Tabular numerals: pass `fontFeatures: [FontFeature.tabularFigures()]` on any text that displays a counter, time, or stat.

### 2.4 Component conventions

- **Cards**: white, `radius: AppRadii.lg` (16) or `xl` (20), `AppShadows.sm` at rest → `md` on hover/press. **No border** on cards. Use a 1px `border` only on inputs.
- **Buttons**: primary = filled `--gradient-primary`, secondary = filled secondary, tertiary = text. All have radius 12, min height 44 (`AppSpacing.touchTarget`), scale to 0.98 on press.
- **Bottom nav**: `lib/core/design_system/widgets/liquid_glass_nav_bar.dart`. 4 tabs + a centered elevated FAB ("+"). Don't replace it; extend it. iPad / wide widths swap to a `NavigationRail` — the layout switch lives in `lib/core/layouts/`.
- **Inputs**: 1px border, 12px radius, 44px min height, focus ring is `--border-focused` (= primary).
- **Empty states**: large feature glyph (48-64px) + warm one-liner + single CTA. See `comp-cards.html` and the existing screens for tone.

### 2.5 Density

- Page padding: 16-20px.
- Card inner padding: 16-20px.
- Section gaps: 24-32px.
- Min tap target: 44px. Always.
- Page content max-width: 640px on phone, 960px on tablet — handled by the layout shell, not by individual screens.

### 2.6 Motion

150-300ms with `Curves.easeOutCubic` (or the custom `cubic-bezier(.16,1,.3,1)`). Entries slide-and-fade, exits fade. Haptic light tick on dhikr increment, task complete, and timer state changes — use `HapticFeedback.lightImpact()`.

### 2.7 Adaptive layout — phone vs. iPad

Athar ships on iPhone **and** iPad. The codebase already has the responsive primitives — use them, don't reinvent:

- `lib/core/utils/responsive_helper.dart` — `ResponsiveHelper.isMobile/isTablet/isDesktop(context)`, `getDeviceType`, `getGridColumns(mobile, tablet, desktop)`, `getSpacing`, `getMaxContentWidth` (640pt phone / 960pt tablet). Detection is `shortestSide`-based so it works in both orientations and through Split View / Slide Over.
- `lib/core/design_system/widgets/responsive_wrapper.dart` — `ResponsiveLayout(mobile, tablet)`, `ResponsiveScaffold`, `ResponsiveGrid`, plus factories `ResponsiveWrapper.form()` (450), `.content()` (600), `.card()` (500).

**Rule**: every page that has a meaningfully different iPad composition wraps its body in `ResponsiveLayout(mobile: PhoneVariant, tablet: TabletVariant)`. Pages without a different composition still cap content with `ResponsiveWrapper.content()` so they don't stretch to 1366pt.

**Adaptive shell** — phone uses `LiquidGlassNavBar`; iPad uses a `NavigationRail` (compact in portrait, expanded with labels in landscape). The shell switch belongs in `lib/core/design_system/widgets/adaptive_shell.dart` (build it if missing) and uses `LayoutBuilder` constraints — never `MediaQuery.size.width`, which lies under Split View. The bottom-nav FAB ("+") moves into the rail's `leading:` slot on tablet+.

**Master-detail screens** (Tasks, Settings, Spaces): tapping a master row updates `selectedId` in the page's local state — it does **not** push a route — and the detail pane rebuilds. On phone, the same widget falls back to push navigation. The detail pane needs an empty state when nothing is selected (large feature glyph + warm one-liner, per §2.4).

**Don't stretch**. The prayer card, focus fluid background, and any centered single-column form must be capped at their natural width and centered in negative space. A 1366pt-wide single-column page is worse than the phone layout.

**iPad affordances** when `ResponsiveHelper.isTablet(context)` is true:
- Hover via `MouseRegion` on every interactive card / row.
- Keyboard shortcuts via `Shortcuts` + `Actions` at the shell level (⌘N new task, ⌘F focus, ⌘1–5 tabs, J/K next/prev, Space toggle complete, Esc clear selection). Shortcuts dispatch `Intent`s; cubits handle them — never wire shortcuts to widget callbacks.
- `CupertinoContextMenu` on long-press / right-click for tile-shaped widgets.
- `Draggable` + `DragTarget` for task → calendar / task → space / habit reorder.
- `CupertinoTextField` (not `TextField`) on text inputs — Pencil Scribble works natively on iOS.

The full per-screen iPad spec is in `IPAD_OPTIMIZATION.md`. Read it before adding a tablet branch.

---

## 3. Voice & content

- **Bilingual-first**: every user-visible string belongs in `lib/l10n/` (`app_ar.arb` + `app_en.arb`). Generated keys land in `lib/l10n/generated/`. Never hardcode a string in a widget — even for prototypes.
- **Tone**: warm, calm, practical. Arabic is human ("مرحباً بعودتك"); English is crisp ("Welcome back"). Sentence case, never ALL CAPS.
- **Brevity**: kill half the words. "+ مهمة" not "اضغط لإضافة مهمة جديدة".
- **Universal by default**: prayer / dhikr features are **opt-in**. Don't show religious copy or imagery to a user who hasn't enabled them. The default greeting is time-based, not Islamic.
- **Emoji**: rare — time-of-day (🌅 🌙) and feature category hints only. Never in titles, never as buttons.

---

## 4. RTL

The app's primary locale is `ar-SA`. **Every screen must work mirrored.** Practical rules:

- Use `EdgeInsetsDirectional` and `start`/`end` instead of `left`/`right`.
- Use `Row`'s default `MainAxisAlignment` semantics (start = leading edge in current direction).
- Icons that imply direction (back arrow, "next" chevron) — wrap in `Directionality.of(context) == TextDirection.rtl ? Transform.flip : ...` or use the `*Outlined` Cupertino variants which auto-mirror.
- Prayer card, Hijri date, dhikr counter — Arabic-numerals optional via settings (`useEasternNumerals`). Format with `intl`'s `NumberFormat` keyed off the current locale.

---

## 5. When you add a new screen — checklist

1. **Read** the matching cubit and entity if one exists. If not, design entity + repo contract first.
2. **Define** the cubit's state hierarchy (Initial / Loading / Loaded / Error).
3. **Permission-gate** every mutation through `PermissionService` if the resource has a `spaceId`.
4. **Wire** the cubit into `app.dart` `MultiBlocProvider` (or scope it with `BlocProvider.value` if it's screen-local).
5. **Build** the widget tree using `Theme.of(context)` and `AppSpacing` / `AppRadii` / `AppShadows` — never hex / hardcoded dp.
6. **Adaptive layout** — wrap the page body in `AdaptiveShell` (not a bare `Scaffold` with `LiquidGlassNavBar`). If the iPad composition differs, branch via `ResponsiveLayout(mobile: ..., tablet: ...)`. Use `LayoutBuilder` constraints, never `MediaQuery.size.width`. Cap content with `ResponsiveWrapper.content()` if there's no genuine multi-column variant. Master-detail screens need an empty state in the detail pane.
7. **Localize** every string into `app_ar.arb` + `app_en.arb`.
8. **Test** in RTL (`Directionality(textDirection: TextDirection.rtl, child: ...)`), dark theme, **and** at iPad portrait, iPad landscape, and Split View 1/2.
9. **iPad affordances** if the page is interactive: hover (`MouseRegion`) on every card/row, `CupertinoContextMenu` on long-press, keyboard shortcuts dispatched as `Intent`s at the shell, `CupertinoTextField` on text inputs (Pencil Scribble).
10. **Schedule** notifications, if any, via the relevant `*_notification_scheduler.dart` — never directly.
11. Run `flutter pub run build_runner build --delete-conflicting-outputs` if you added `@injectable`, an Isar collection, or a `freezed` class.

---

## 6. Files you'll touch most

| Need | File |
|---|---|
| Add a route | `lib/app.dart` (`routes:` map) |
| Register a cubit | `lib/app.dart` (`MultiBlocProvider`) + `@injectable` annotation |
| New design token | `lib/core/design_system/tokens/<concern>.dart` + mirror in `colors_and_type.css` |
| Theme tweak | `lib/core/design_system/themes/app_theme.dart` |
| Bottom nav item | `lib/core/design_system/widgets/liquid_glass_nav_bar.dart` + `lib/features/home/presentation/pages/main_page.dart` |
| New permission rule | `lib/core/iam/permission_service.dart` (extend, don't fork) |
| New time period interpretation | `lib/core/time_engine/smart_time_parser.dart` |
| Localization | `lib/l10n/app_ar.arb` + `app_en.arb` (regen with `flutter gen-l10n`) |

---

## 7. Things to never do

- ❌ Hardcode colors / fonts / spacing — always tokens.
- ❌ Skip permission checks on space-scoped writes.
- ❌ Compute time-of-day with raw `DateTime.hour < 12`. Use the time engine.
- ❌ Schedule notifications outside the schedulers.
- ❌ Show prayer/dhikr UI to a user who hasn't enabled the module.
- ❌ Introduce a non-`Cubit` state pattern for shared state.
- ❌ Bypass Isar by reading Supabase from a widget.
- ❌ Add English-only or Arabic-only strings — both, every time.
- ❌ Pure black `#000000` for dark surfaces — use `#121212` / `#1E1E1E`.
- ❌ Fork `liquid_glass_nav_bar.dart` for a new screen — extend the existing one.
- ❌ Stretch a single-column phone layout to 1366pt on iPad. Cap with `ResponsiveWrapper.content()` or build a real `tablet:` variant.
- ❌ Read `MediaQuery.size.width` to drive adaptive layout. Use `LayoutBuilder` constraints — Split View / Slide Over / Stage Manager break otherwise.
- ❌ Push a detail page on iPad master-detail screens. Update local `selectedId` and rebuild the detail pane.
- ❌ Use `EdgeInsets.only(left: ...)` — always `EdgeInsetsDirectional.only(start: ...)`. RTL + iPad master-detail amplifies every directional bug.

---

## 8. When the spec and the code disagree

The user brief once described a green primary. **The shipping codebase is indigo `#1A6B3C` + teal `#0D7377`.** Follow the code unless the user explicitly tells you to re-skin. Same rule for every other conflict: code wins, flag the discrepancy in your PR description.
