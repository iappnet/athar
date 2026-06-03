# Athar Design System (أثر) — Workspace

> A handoff workspace for **Claude Code** (and any future contributor) building Flutter UI in [`iappnet/athar`](https://github.com/iappnet/athar). Everything here is reference: design tokens, screen mockups, component previews, and the architectural map of the codebase.

## What is Athar?

Athar is a cross-platform Flutter app (iOS + Android, Web/Desktop possible) that consolidates **tasks, habits, calendar, focus (Pomodoro), stats, shared spaces, health (medicines / appointments / vitals), assets (cars / homes), prayer times, and dhikr** — every module independently toggleable. The product philosophy:

- **Bilingual**: Arabic (RTL, primary) + English (LTR, parallel).
- **Universal by default**: religious features are opt-in, never imposed.
- **Don't make me think**: every action obvious in < 1 second; max 3 primary actions per screen.

The user's mantra is *athar* — leave a positive trace in your day.

---

## How Claude Code should use this workspace

You're being asked to write Dart/Flutter code, not HTML. The workflow:

1. **Read `SKILL.md` first.** It contains the architectural laws (BLoC + Isar + Supabase + IAM + Time Engine), the visual rules, and the "things to never do" list. It's the contract.
2. **Read `REDESIGN_AUDIT.md`** for the per-screen ticket list — which Dart files to edit for each JSX mockup, which features are net-new, and the recommended implementation order.
3. **Read `IPAD_OPTIMIZATION.md`** for iPad layouts (master-detail, NavigationRail shell, keyboard shortcuts, drag-and-drop, Pencil) — apply after the matching phone screen in the audit lands.
4. **Read `colors_and_type.css`** to see every design token already mapped — these are mirrored 1-to-1 in `lib/core/design_system/tokens/`.
5. **Skim `design-context/_manifest.json`** for the file inventory of the whole codebase (398 Dart files, grouped by feature).
6. **Read `design-context/_core_extract.dart`** for the architectural backbone: `app.dart`, DI, IAM, Time Engine, top-level cubits — all in one file.
7. **Open the relevant feature folder** in the actual codebase (`lib/features/<name>/`) before generating code.
8. **Use the HTML mockups under `ui_kits/athar_app/`** as the visual target. They are JSX/React, *not* a source for copying logic — translate the visuals into Flutter, drive the data through the existing cubits.

---

## Workspace map

| Path | What it is | Use it for |
|---|---|---|
| `SKILL.md` | The build rules — architecture, voice, RTL, checklist | **Read first.** Every Flutter task. |
| `README.md` | This file | Orientation |
| `REDESIGN_AUDIT.md` | Per-screen ticket list mapping each JSX mockup to the live Dart files. | When implementing the redesign — pick a screen, follow its ticket. |
| `IPAD_OPTIMIZATION.md` | Per-screen iPad layouts, master-detail, NavigationRail shell, keyboard shortcuts, Pencil & drag-and-drop. | After a screen's phone redesign lands — port it to iPad. |
| `colors_and_type.css` | Every token (colors, type, spacing, radii, shadows, motion) — light + dark | Verify token names; mirror into Dart if you add one |
| `design-context/_manifest.json` | List of all 398 Dart files + per-feature counts | Find which file a feature lives in |
| `design-context/_core_extract.dart` | `app.dart` + DI + IAM + Time Engine + top-level cubits, concatenated | Understand the architecture in one read |
| `design-context/...` | Other extracted Dart snippets, organized by concern | Drill into a specific subsystem |
| `preview/*.html` | Token + component preview cards (palette, type, spacing, buttons, cards, chips, inputs, nav, prayer card, habits, tasks) | Pixel-level reference for a single component |
| `ui_kits/athar_app/` | Full mobile-app mockup as a clickable JSX prototype (Dashboard · Focus · Tasks · Habits · Calendar · Stats · Settings · Spaces · Onboarding) | Visual target when generating a Flutter screen |
| `ui_kits/athar_app/index.html` | Side-by-side iOS-frame view of every screen | Open this to see the whole app |
| `uploads/` | Source-of-truth dumps the user provided (full codebase as text, brief, etc.) | Reference only — don't modify |

---

## The codebase at a glance

Live shape from the latest dump (`design-context/_manifest.json`):

| Folder | Files | What lives there |
|---|---:|---|
| `lib/core/design_system/` | 53 | Tokens, themes, shared widgets (incl. `liquid_glass_nav_bar.dart`) |
| `lib/core/services/` | 25 | Notification schedulers, sync, deep links, hijri, location, prayer engine |
| `lib/core/iam/` | 4 | `permission_service`, `permission_cache`, `role_service`, role enums |
| `lib/core/time_engine/` | 5 | `AtharTimeCalculator`, `SmartTimeParser`, period definitions |
| `lib/features/space/` | 45 | Spaces, modules, members, invitations, lists |
| `lib/features/task/` | 32 | Tasks (the central productivity object) |
| `lib/features/home/` | 21 | Splash, main shell, timeline, dashboard |
| `lib/features/settings/` | 19 | User settings, categories |
| `lib/features/habits/` | 19 | Habits + tracking |
| `lib/features/prayer/` | 17 | Prayer times, conflict resolution |
| `lib/features/health/` | 17 | Medicines, appointments, vitals |
| `lib/features/assets/` | 17 | Cars, homes, scheduled maintenance |
| `lib/features/focus/` | 15 | Pomodoro / focus sessions |
| `lib/features/auth/` | 14 | Login, profile completion |
| `lib/features/dhikr/` | 12 | Dhikr counter |
| `lib/features/subscription/` | 12 | RevenueCat, paywalls, entitlements |
| `lib/features/calendar/` | 11 | Month / week / day views |
| `lib/features/notifications/` | 11 | In-app notification center |
| `lib/features/stats/` | 11 | Charts and summaries |
| `lib/features/sync/` | 10 | Sync orchestration |

---

## Design system at a glance

- **Palette**: indigo primary `#1A6B3C` + teal secondary `#0D7377`. Status: green `#00B894` / amber `#FDCB6E` / red `#FF7675` / blue `#74B9FF`.
- **Surfaces**: warm off-white `#F8F9FA` (light) · `#121212` / `#1E1E1E` (dark). Never pure black.
- **Type**: **Calibri** is the sole canonical brand font for both Arabic and English (Light 300 / Regular 400 / Bold 700). **JetBrains Mono** for numerals.
- **Spacing**: 4-pt grid (`xxxs`=2 … `xxl`=48).
- **Radii**: 4 → 32 → 999. Buttons 12, cards 16-20, pills full.
- **Shadows**: two-layer (close + diffuse), low-opacity. `sm` at rest, `md` on hover.
- **Motion**: 150-300ms `easeOutCubic`. Slide-and-fade entries, fade exits. Light haptics on commit actions.
- **Signature moments**: prayer card uses a fixed night-sky gradient in both themes; focus session uses a fluid animated background; bottom nav uses real `liquid-glass` blur (the only place transparency is allowed).

Everything above is already in `lib/core/design_system/tokens/*` — don't redefine, reuse.

---

## iPad — first-class, not stretched

The codebase already ships responsive primitives (`lib/core/utils/responsive_helper.dart`, `lib/core/design_system/widgets/responsive_wrapper.dart` — `ResponsiveLayout`, `ResponsiveScaffold`, `ResponsiveGrid`) and `main.dart` already unlocks all four orientations on iPad. What's missing is **using them**: most pages render the phone layout stretched to 1366pt.

The fix lands in three layers, fully specified in `IPAD_OPTIMIZATION.md`:

1. **Adaptive shell** (`AdaptiveShell` widget) — `LiquidGlassNavBar` on phone, compact `NavigationRail` on iPad portrait, expanded rail + master-detail on iPad landscape, 3-column on 12.9" iPad Pro / external display. Detection via `LayoutBuilder` constraints (not `MediaQuery.size`) so Split View / Slide Over / Stage Manager work without changes.
2. **Per-screen layouts** — each redesigned screen gets a `tablet:` branch in `ResponsiveLayout`. Tasks → master-detail. Settings → two-pane (iOS Settings.app pattern). Calendar → month grid + side timeline. Spaces → permission matrix. Etc.
3. **iPad affordances** — hover states (`MouseRegion`), keyboard shortcuts (`⌘N`, `⌘F`, `⌘1-5`, J/K, Space), `CupertinoContextMenu` on long-press / right-click, drag-and-drop (task → calendar, task → space), Apple Pencil scribble via `CupertinoTextField`.

Hard rule: **don't stretch**. Cap content widths with `ResponsiveWrapper.content()` (600pt) when there's no genuine multi-column composition. The prayer card and focus fluid background look worse at 1366pt wide than at 390pt — center them in negative space.

---

## Architecture in one paragraph

Every feature follows Clean Architecture: `data/` (Isar models + repository impls) ↔ `domain/` (entities + abstract repos) ↔ `presentation/` (cubits + pages + widgets). State is **flutter_bloc cubits**, registered with **GetIt + injectable**, persisted to **Isar locally** and synced to **Supabase**. Permissions for any space-scoped resource go through `PermissionService` (`canCreate` / `canEdit` / `canDelete` / task-specific helpers); roles cache per-space in `PermissionCache`. Time logic — greetings, scheduling, smart zones — flows through the `time_engine/` (11 named periods keyed off prayer times). Notifications are routed through per-domain schedulers that allocate IDs via `notification_id_manager.dart`. Free-tier limits and entitlements live in `subscription_config.dart`. **All UI is bilingual (`lib/l10n/`) and must work mirrored in RTL.**

The full version of the rules — including the non-negotiables and the per-screen checklist — is in `SKILL.md`.

---

## Known gaps & caveats

- **Brand assets**: `assets/icon/` in the repo is binary-only and was not imported here. Logos and per-feature SVGs need to be supplied separately if pixel parity matters.
- **Fonts**: Calibri (Light/Regular/Bold) ships locally in `fonts/` — it is the sole canonical brand font. The bundled TTFs may have limited Arabic glyph coverage; this is an **asset-supply gap** to resolve by sourcing a Calibri build with full Arabic coverage, not a typography-authority decision. Production code should keep using the bundled fonts.
- **Color naming**: the hex `#1A6B3C` reads as "green" but the brand calls it indigo and renders deep teal-leaning in context. Don't rename it.
- **Mockups vs. code**: the JSX mockups under `ui_kits/athar_app/` are illustrative. They use mock data and React state. The real screens read from cubits — port the visuals, not the wiring.
- **Iconography**: previews use Lucide as a stand-in. Production uses `cupertino_icons` + `flutter_svg` with custom SVGs under `assets/icon/`.

---

## Asks for the human

If anything below is missing when you start, ask:

1. Confirm the **indigo `#1A6B3C` + teal `#0D7377`** palette (or instruct a re-skin).
2. Drop the **logo** + brand mark SVGs into the repo's `assets/` if they aren't there.
3. Point out the **screen to start with** if multiple are in scope — recommend Dashboard or Tasks; they exercise most of the system.
4. Confirm whether new strings should be added to **`app_ar.arb` + `app_en.arb`** in this PR or a follow-up.
