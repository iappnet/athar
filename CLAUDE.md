# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Athar (أثر)** is an Islamic productivity Flutter app targeting iOS and Android. Core features: prayer times, dhikr, habits, tasks, calendar, focus mode, health tracking, assets management, spaces (collaborative workspaces), and subscription management. The app is Arabic-first (locale `ar-SA`), uses Supabase as the remote backend, Isar for local persistence, and Firebase for push notifications (FCM).

## Setup

A `.env` file must exist at the project root before the app will launch — it is loaded before Firebase/Supabase init:

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

## Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Static analysis / lint
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Code generation (injectable DI + Isar schemas) — run after adding @injectable annotations or Isar collections
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode during development (re-runs codegen on save)
dart run build_runner watch --delete-conflicting-outputs

# Regenerate localizations (after editing lib/l10n/app_ar.arb or app_en.arb)
flutter gen-l10n

# iOS deployment via Fastlane (run from ios/ directory)
cd ios && fastlane beta       # Build + upload to TestFlight
cd ios && fastlane release    # Build + upload to App Store
cd ios && fastlane metadata   # Upload metadata only
cd ios && fastlane screenshots # Upload screenshots only
```

## Architecture

The app follows **Clean Architecture** with a feature-based module structure:

```
lib/
  main.dart          # Bootstraps Firebase, Supabase, RevenueCat, GetIt, schedulers
  app.dart           # AtharApp widget — MultiBlocProvider + MaterialApp + routing
  core/              # Shared infrastructure
  features/          # Feature modules
  l10n/              # ARB files + generated AppLocalizations
  firebase_options.dart
```

### Feature Module Structure

Every feature follows this identical layered layout:

```
features/<name>/
  data/
    datasources/     # Remote (Supabase) and/or local (Isar) data sources
    models/          # Data models with fromJson/toJson + Isar @collection/@embedded annotations
    repositories/    # Concrete implementations of domain repository interfaces
  domain/
    entities/        # Pure Dart entities (Equatable)
    repositories/    # Abstract repository contracts
    usecases/        # Single-responsibility use cases returning Either<Failure, T>
  presentation/
    cubit/           # Cubit + State classes (flutter_bloc)
    pages/           # Full-screen route pages
    widgets/         # Feature-specific widgets
```

**Features**: `auth`, `home`, `prayer`, `dhikr`, `habits`, `task`, `calendar`, `focus`, `health`, `assets`, `space`, `notifications`, `stats`, `subscription`, `sync`, `settings`

Note: the `task` feature has only a remote datasource (`task_remote_source.dart`) — no local Isar collection. Most other features have both local and remote datasources.

### Core Module

```
core/
  di/            # GetIt setup (injection.dart + generated injection.config.dart)
  config/        # App constants, subscription config; routes.dart is an unused GoRouter stub
  error/         # failures.dart (stub — Failure types are defined inline in features)
  services/      # All app-wide services (25+ files, see Services section)
  design_system/ # Atomic design: tokens → atoms → molecules → organisms → templates
    tokens/      # athar_colors, athar_typography, athar_spacing, athar_radii, athar_shadows, athar_animations
    tokens.dart  # Barrel export for all tokens
  iam/           # RBAC for space permissions: permission_service, role_service, permission_cache, models/
  time_engine/   # Prayer time logic: AtharTimeCalculator, AtharTimePeriods, SmartTimeParser, RelativeTimeParser
  models/        # Shared data models (e.g. upload queue)
  layouts/       # Responsive layout wrappers
  utils/         # Shared utilities
  presentation/cubit/  # CelebrationCubit (global confetti), LocaleCubit (language switching)
  constants/     # athkar_data.dart — static Islamic dhikr content database
```

### Dependency Injection

DI uses **GetIt** + **Injectable**. All injectable classes use `@injectable`, `@singleton`, or `@lazySingleton` annotations. After modifying DI annotations, regenerate with `build_runner`. The entry point is `configureDependencies()` in `core/di/injection.dart`, which calls the generated `injection.config.dart`. Access the service locator via the global `getIt` instance.

### State Management

All state is managed via **Cubit** (from `flutter_bloc`). Cubits are registered in GetIt and provided globally in `app.dart` via `MultiBlocProvider` (18+ cubits at app root). Feature-scoped cubits may be provided locally at the page/widget level.

### Data Layer

- **Local**: Isar database. Models use `@collection` / `@embedded` annotations. Schema files (`*.g.dart`) are generated by `isar_generator` via `build_runner`. Never edit `.g.dart` files manually.
- **Remote**: Supabase (PostgreSQL). Credentials loaded from `.env` via `flutter_dotenv`.
- **Sync**: `SyncService` handles Isar → Supabase synchronization, triggered at startup via `SyncCubit` and manually. Background sync uses `workmanager`.

### Navigation

Routing is defined in `app.dart` using `MaterialApp.routes` with named routes:

- `/home` → `MainPage`
- `/login` → `LoginPage`
- `/complete_profile` → `CompleteProfilePage`
- `/join-space` → `JoinSpaceScreen` (receives an invitation token via `settings.arguments`)

`DeepLinkService.navigatorKey` is the global navigator key (passed to `MaterialApp`), used by deep links and notification taps to push routes after the app is running. Cold-start notification payloads are consumed in `AtharApp.initState` via `LocalNotificationService.consumeColdStartPayload()`.

> `core/config/routes.dart` contains a GoRouter stub but is **not used** — routing is handled entirely in `app.dart`.

### Startup Sequence

`main()` splits initialization into two phases:

1. **Critical (before `runApp`)**: dotenv load → Firebase → Supabase → RevenueCat → `configureDependencies()`
2. **Deferred (`_initBackground`, fires after first frame)**: WidgetDataService → SpaceRepository.initDefaultData → SyncService → HabitRepository.ensureSystemHabits → intl → DeepLinkService → LocalNotificationService → FCMService → notification schedulers

This keeps the splash screen appearing immediately while background services warm up concurrently.

### Notifications

`LocalNotificationService` is the central hub. Feature-specific schedulers handle scheduling:

- `PrayerNotificationScheduler`, `MedicationNotificationScheduler`, `TaskNotificationScheduler`, `HabitNotificationScheduler`, `AppointmentNotificationScheduler`, `AssetNotificationScheduler`, `ProjectNotificationScheduler`

Auto-renewal payloads (e.g. `auto_reschedule_prayers`) fire from a scheduled notification and are routed back to the appropriate scheduler via `_handleAutoRenewal` in `main.dart`. `FCMService` handles remote push via Firebase.

### IAM & Space Permissions

`core/iam/` implements RBAC scoped to the `space` feature:

- `RoleService` — resolves the current user's role within a space
- `PermissionService` — checks capabilities (create/edit/delete/invite) based on role
- `PermissionCache` — caches role lookups to avoid redundant Supabase queries
- `core/iam/models/` — role enums and permission definitions

### Native Home Widgets

Three iOS widget extensions and four Android widget types bridge to Flutter via the `home_widget` package. `WidgetDataService` (`core/services/widget_data_service.dart`) is the Flutter-side bridge — it serializes data and writes it to the shared app group/intent so native widgets can read it. Call `WidgetDataService.init()` at startup (already done in `_initBackground`).

### Subscriptions

RevenueCat (`purchases_flutter`) manages in-app subscriptions. `SubscriptionCubit` loads status at app start. `SubscriptionConfig` in `core/config/subscription_config.dart` holds the RevenueCat API key. Use `SubscriptionCubit` state to gate pro features.

### Localization

- Arabic (`app_ar.arb`) is the template/primary locale; English (`app_en.arb`) is secondary.
- `l10n.yaml` configures code generation into `lib/l10n/generated/app_localizations.dart`.
- Run `flutter gen-l10n` after editing ARB files.
- `missing_translations.txt` is auto-generated and tracks untranslated keys.
- `LocaleCubit` (provided globally) handles runtime language switching; locale is persisted via `FlutterSecureStorage`.

### Design System

Design tokens live in `core/design_system/tokens/` and are re-exported via `tokens.dart`. The `ScreenUtilInit` design size is `375×812`. The app uses the **Cairo** font family for Arabic text. Import the barrel with `import 'package:athar/core/design_system/tokens/tokens.dart'`.

### Error Handling

Domain use cases return `dartz` `Either<Failure, T>`. `failures.dart` is currently a stub — Failure subclasses are defined inline within individual features.


## gstack
Use /browse from gstack for all web browsing.
Available skills: /office-hours, /plan-ceo-review, /plan-eng-review, /plan-design-review, /review, /ship, /qa, /cso, /autoplan, /investigate, /retro.
## Skill routing

When the user's request matches an available skill, ALWAYS invoke it using the Skill
tool as your FIRST action. Do NOT answer directly, do NOT use other tools first.
The skill has specialized workflows that produce better results than ad-hoc answers.

Key routing rules:
- Product ideas, "is this worth building", brainstorming → invoke office-hours
- Bugs, errors, "why is this broken", 500 errors → invoke investigate
- Ship, deploy, push, create PR → invoke ship
- QA, test the site, find bugs → invoke qa
- Code review, check my diff → invoke review
- Update docs after shipping → invoke document-release
- Weekly retro → invoke retro
- Design system, brand → invoke design-consultation
- Visual audit, design polish → invoke design-review
- Architecture review → invoke plan-eng-review
- Save progress, checkpoint, resume → invoke checkpoint
- Code quality, health check → invoke health
