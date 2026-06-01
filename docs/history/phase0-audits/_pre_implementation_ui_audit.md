# Pre-Implementation UI Audit — Athar App
**Date**: 2026-05-06  
**Branch**: main  
**Audit scope**: 10 UI areas against Package A + Package B design system specs  
**Status**: COMPLETE — ready for implementation  
**Auditor**: Claude Code + /office-hours (gstack)

> AUDIT ONLY — No Dart code was modified during this session.  
> All findings are evidence-based. Every claim cites the file it was read from.  
> Implementation begins only after designer sign-off on this document.

---

## Source of Truth Files Read

| File | Purpose |
|------|---------|
| `HANDOFF.md` | Contract: 11-step build order, architecture rules |
| `PACKAGE_A_DECISIONS.md` | 8 authoritative designer decisions |
| `COMPONENT_SPECS.md` | EmptyState, ErrorState, SyncStatusCard, RoleChip, ModuleFlags, Form primitives |
| `REDESIGN_AUDIT.md` | Screen-to-file mapping, NET-NEW callouts |
| `PRAYER_CARD_SPEC.md` | Compact + Expanded prayer card variants |
| `CALENDAR_CELL_SPEC.md` | DualDate, dual-numeral cells, isHijriMode |
| `ATHKAR_SPEC.md` | Athkar home, reader, counter, data model |
| `IOS_WIDGETS_SPEC.md` | Three widgets × three sizes, gating rules |
| `STATS_KPI_SPEC.md` | Tier-1 (6 KPIs) + Tier-2 (4 areas) |

---

## Classification Key

| Grade | Meaning |
|-------|---------|
| A | Fully matches spec — no action needed |
| B | Minor gaps — small additions or token fixes |
| C | Partial match — significant gaps, refactor required |
| D | Structural mismatch — rebuild required |
| F | Missing entirely — net-new implementation |

---

## Architectural Fork Decisions (Pre-locked)

Five architectural conflicts identified and resolved via /office-hours before implementation.
These decisions are locked and must be respected by all implementation work.

| Fork | Decision | Rationale |
|------|----------|-----------|
| D1: Onboarding location | New folder `lib/features/onboarding/` | Spec says NET-NEW; current file is cosmetic placeholder |
| D2: ModuleFlags architecture | Flat booleans in UserSettings | Consistent with existing pattern; structured object premature |
| D3: prayerCardVariant | Add `prayerCardVariant` alongside `prayerCardDisplayMode` | Different concepts (WHAT vs WHERE); additive = zero migration risk |
| D4: Profile page ownership | Move `profile_page.dart` → `settings/` | REDESIGN_AUDIT.md is explicit; post-login concern = Settings |
| D5: Accessibility settings | Inline section in `general_settings_page.dart` | PACKAGE_A #4 says "section" not "page"; 3 toggles ≠ full page |

---

## Cross-Cutting Issues (Apply to All 10 Areas)

These problems appear across multiple files and must be addressed globally, not per-screen.

### 1. ResponsiveHelper violation (Critical)
**Found in**: `login_page.dart`, `register_page.dart`, `profile_page.dart`  
**Evidence**: `ResponsiveHelper.isTablet()` calls observed in all three files  
**Spec requirement**: HANDOFF.md §2 — use `LayoutBuilder` for breakpoints  
**Action**: Replace every `ResponsiveHelper.isTablet()` with `LayoutBuilder` constraint checks

### 2. AdaptiveShell not at spec path (High)
**Found**: Only at `lib/core/layouts/adaptive_scaffold.dart`  
**Spec requires**: `lib/core/design_system/widgets/adaptive_shell.dart`  
**Action**: Move/rename to spec path, update all imports

### 3. Hardcoded colors (High — multiple files)
**Evidence**:
- `general_settings_page.dart`: `Color(0xFF1A6B3C)` (should be `AppColors.forest`)
- `splash_page.dart`: `Color(0xFF07111A)`, `Color(0xFF22A05B)`
- `register_page.dart`: gradient with hardcoded hex
- `space_members_page.dart`: `Colors.orange[50]` for owner badge
- `pending_invitations_widget.dart`: hardcoded role colors  
**Action**: Sweep all files in audit scope; replace with `AppColors.*` tokens

### 4. AtharEmptyState — wrong variant set (Medium)
**Found at**: `lib/core/design_system/widgets/athar_display.dart:321`  
**Current**: 4 generic variants — `noData`, `noResults`, `error`, `noConnection`  
**Spec requires** (COMPONENT_SPECS §2): 8 feature-specific variants:
- `EmptyState.tasks`, `.habits`, `.prayer`, `.stats`, `.calendar`, `.athkar`, `.spaces`, `.focus`
- Each with 96×96 feature glyph  
**Action**: Add 8 named constructors/factories matching spec; keep generic variants for backward compat

### 5. SyncStatusCard — missing entirely (Medium)
**Searched**: Entire codebase  
**Result**: No `SyncStatusCard` found anywhere  
**Spec requires** (COMPONENT_SPECS §3): 4-state card — `synced`, `syncing`, `offline`, `error`  
**Action**: Create `lib/core/design_system/widgets/sync_status_card.dart`

### 6. numericMono not in AtharTypography (Medium)
**Searched**: `AtharTypography` in design_system/  
**Result**: No `numericMono` text style  
**Spec requires**: JetBrains Mono, tabular figures, used on all counters/timers/stats  
**Action**: Add `numericMono` to `AtharTypography`; apply `FontFeature.tabularFigures()`

### 7. Hardcoded strings not in ARB (Medium)
**Evidence**: `pending_invitations_widget.dart` — hardcoded Arabic "دعوات معلقة"  
**Action**: Move all user-facing strings to `app_ar.arb` + `app_en.arb`; run `flutter gen-l10n`

### 8. RoleChip — not a reusable component (Low-Medium)
**Found**: `space_members_page.dart` — `_buildRoleBadge` is a private method  
**Spec requires** (COMPONENT_SPECS §5): Reusable `RoleChip` widget with 4 roles: owner/admin/member/viewer  
**Action**: Extract to `lib/core/design_system/widgets/role_chip.dart`

---

## Area-by-Area Audit

---

### 1. Settings Page

**File**: `lib/features/settings/presentation/pages/general_settings_page.dart`  
**Grade**: C

#### What's There ✅
- Prayer 4-level toggle hierarchy correctly implemented (isPrayerEnabled → isPrayerCardEnabled → isPrayerNotificationsEnabled → enablePrayerReminders)
- Section structure with dividers
- AtharButton, AtharTextField usage

#### Gaps ❌
| Gap | Severity | Action |
|-----|----------|--------|
| No Accessibility section (Reduce Motion, Disable Gyro, Eastern Numerals) | High | Add inline section (D5 decision) |
| No Modules section (visual grouping of feature toggles) | High | Add Modules section header + grouped toggles (D2 decision) |
| No SyncStatusCard | Medium | Add at top of page when sync state is relevant |
| Hardcoded `Color(0xFF1A6B3C)` | High | Replace with `AppColors.forest` |
| Missing `isSpacesEnabled`, `isHealthEnabled`, `isAssetsEnabled` in UserSettings | High | Add 3 flat bool fields (D2 decision) |

#### UserSettings Model Gaps (full list)

Missing fields — all confirmed by reading `lib/features/settings/data/models/user_settings.dart`:

| Field | Type | Default | Spec source |
|-------|------|---------|-------------|
| `prayerCardVariant` | `String` | `'compact'` | PACKAGE_A #8 |
| `isSpacesEnabled` | `bool` | `true` | COMPONENT_SPECS §6 |
| `isHealthEnabled` | `bool` | `false` | COMPONENT_SPECS §6 |
| `isAssetsEnabled` | `bool` | `false` | COMPONENT_SPECS §6 |
| `reduceMotion` | `bool` | `false` | PACKAGE_A #4 |
| `disableGyro` | `bool` | `false` | PACKAGE_A #4 |
| `easternNumerals` | `bool` | `false` | PACKAGE_A #6 |

> Note: `prayerCardDisplayMode` stays — it controls WHERE the card appears. `prayerCardVariant` controls WHAT it looks like. Different concepts; both needed.

---

### 2. Profile Page

**File**: `lib/features/auth/presentation/pages/profile_page.dart` (wrong location)  
**Spec location**: `lib/features/settings/presentation/pages/profile_page.dart`  
**Grade**: D

#### What's There ✅
- Form for name and username editing
- AtharTextField usage

#### Gaps ❌
| Gap | Severity | Action |
|-----|----------|--------|
| Wrong folder — in `auth/` not `settings/` | Critical | Move file (D4 decision) |
| `ResponsiveHelper.isTablet()` | High | Replace with LayoutBuilder |
| No avatar upload UI | Medium | Add avatar picker per spec |
| No loading skeleton | Medium | Add skeleton while profile loads |
| No error state | Medium | Add `ErrorState.inline` when load fails |

#### Migration steps for D4 (profile move)
1. `git mv lib/features/auth/presentation/pages/profile_page.dart lib/features/settings/presentation/pages/profile_page.dart`
2. Update import in `app.dart` (route key `/profile` stays the same)
3. Grep `auth/` for any `Navigator.push(ProfilePage)` — update imports

---

### 3. Login Page

**File**: `lib/features/auth/presentation/pages/login_page.dart`  
**Grade**: B

#### What's There ✅
- `AtharTextField` for email/password input
- Apple Sign-In integration
- Guest login path
- OTP-based forgot password flow

#### Gaps ❌
| Gap | Severity | Action |
|-----|----------|--------|
| `ResponsiveHelper.isTablet()` | High | Replace with LayoutBuilder |
| No password visibility toggle (eye icon) | Medium | Add to AtharTextField trailing |
| Inline errors via Snackbar (not field-level) | Medium | Move to field-level `ErrorState.inline` |
| Hardcoded hint text (not in ARB) | Medium | Move to `app_ar.arb` + `app_en.arb` |

---

### 4. Create Account / Sign-Up Page

**File**: `lib/features/auth/presentation/pages/register_page.dart`  
**Grade**: C

#### What's There ✅
- `AtharTextField` usage
- `AtharButton` usage

#### Gaps ❌
| Gap | Severity | Action |
|-----|----------|--------|
| Gradient header with hardcoded hex colors | High | Replace with `AppColors` tokens |
| `ResponsiveHelper.isTablet()` | High | Replace with LayoutBuilder |
| No confirm password field | Medium | Add per standard registration pattern |
| No password visibility toggle | Medium | Add to both password fields |
| No password strength indicator | Low | Optional — add if spec calls for it in implementation |

---

### 5. Onboarding

**File**: `lib/features/home/presentation/pages/onboarding_page.dart` (wrong location)  
**Spec location**: `lib/features/onboarding/` (NET-NEW)  
**Grade**: F

#### What's There ✅
- 4-slide carousel that marks itself "seen" in SharedPreferences

#### Gaps ❌
| Gap | Severity | Action |
|-----|----------|--------|
| Wrong folder — in `home/` not `lib/features/onboarding/` | Critical | New feature folder (D1 decision) |
| No module selection step | Critical | 5-step flow required |
| No location/permissions step | Critical | Required for prayer times |
| No notification permissions step | Critical | Required for adhan/reminder setup |
| No space creation/join step | High | Optional in onboarding but spec-required step |
| Hardcoded colors | High | Replace with AppColors tokens |
| SharedPreferences (not Isar/UserSettings) | Medium | Migrate "hasSeenOnboarding" to UserSettings |

#### New folder structure (D1 decision)
```
lib/features/onboarding/
  data/
  domain/
  presentation/
    cubit/
      onboarding_cubit.dart
      onboarding_state.dart
    pages/
      onboarding_page.dart     ← replaces old file
      step_modules_page.dart   ← module selection
      step_location_page.dart  ← location + prayer setup
      step_notifications_page.dart
      step_space_page.dart     ← optional space join/create
```

---

### 6. Splash Screen

**File**: `lib/features/home/presentation/pages/splash_page.dart`  
**Grade**: B

#### What's There ✅
- Islamic star animation (4 AnimationControllers)
- Correct routing logic:
  - `AuthAuthenticated` → biometric check → `/home` or `/login`
  - `AuthGuest` → `OnboardingPage.hasBeenSeen()` → `/login` or onboarding

#### Gaps ❌
| Gap | Severity | Action |
|-----|----------|--------|
| Hardcoded `Color(0xFF07111A)`, `Color(0xFF22A05B)` | High | Replace with `AppColors.background`, `AppColors.forest` |
| Always dark — no theme switching | Medium | Wire to theme setting when dark/light mode ships |
| Routing to onboarding uses old `home/` location | High | Update after D1 (onboarding move) completes |

---

### 7. Spaces Page

**File**: `lib/features/space/presentation/pages/` (directory)  
**Grade**: C

#### What's There ✅
- SpaceListPage exists
- Basic space creation flow

#### Gaps ❌
| Gap | Severity | Action |
|-----|----------|--------|
| `isSpacesEnabled` gate missing | High | Add gate once field added to UserSettings (D2) |
| `EmptyState.spaces` not spec-compliant | Medium | Update to feature-specific variant |
| Space card design not audited against COMPONENT_SPECS | Unclear | Requires dedicated space UI audit |

---

### 8. Invitations

**File**: `lib/features/space/presentation/widgets/pending_invitations_widget.dart`  
**Grade**: C

#### What's There ✅
- Accept/reject invitation UI
- InvitationCubit integration

#### Gaps ❌
| Gap | Severity | Action |
|-----|----------|--------|
| Hardcoded Arabic string "دعوات معلقة" — not in ARB | High | Move to `app_ar.arb` key `space.pendingInvitations` |
| Hardcoded invitation row colors | Medium | Replace with AppColors tokens |
| No `ErrorState.inline` on load failure | Medium | Add per COMPONENT_SPECS |
| No loading skeleton | Low | Add while invitations load |

---

### 9. Members Management

**File**: `lib/features/space/presentation/pages/space_members_page.dart`  
**Grade**: C

#### What's There ✅
- `SpaceMembersCubit` with `loadMembers`, `acceptInvite`, `rejectInvite`, `changeRole`
- 3 roles: owner / admin / member

#### Gaps ❌
| Gap | Severity | Action |
|-----|----------|--------|
| `_buildRoleBadge` is private — not reusable `RoleChip` | High | Extract to `lib/core/design_system/widgets/role_chip.dart` |
| `Colors.orange[50]` for owner badge — hardcoded | High | Use `AppColors.amber` or spec-defined owner color |
| Viewer role missing — only 3 of 4 roles | High | Add viewer to role enum + UI |
| No role-change confirmation dialog | Medium | Add confirmation per spec |
| `EmptyState.spaces` not spec-compliant | Medium | Update to feature-specific variant |

#### Spec RoleChip colors (COMPONENT_SPECS §5)
| Role | Background | Ink |
|------|-----------|-----|
| owner | `AppColors.amber` | `AppColors.text` |
| admin | `AppColors.primaryTint` | `AppColors.primary` |
| member | `AppColors.surface` | `AppColors.text2` |
| viewer | `AppColors.surface` | `AppColors.text3` |

---

### 10. Modules / Feature Toggles

**File**: `lib/features/settings/data/models/user_settings.dart` + `general_settings_page.dart`  
**Grade**: D

#### What's There ✅
- `isTasksEnabled`, `isHabitsEnabled`, `isPrayerEnabled`, `isFocusEnabled`, `isAthkarEnabled` — 5 of 8 modules

#### Gaps ❌
| Gap | Severity | Action |
|-----|----------|--------|
| `isSpacesEnabled` missing | High | Add bool field (D2 decision) |
| `isHealthEnabled` missing | High | Add bool field (D2 decision) |
| `isAssetsEnabled` missing | High | Add bool field (D2 decision) |
| No visual "Modules" grouping in Settings UI | High | Add section header + all 8 toggles grouped |
| No gating enforcement for spaces feature | High | Add `if (!isSpacesEnabled) return` guards in SpaceFeature entry points |

---

## Implementation Sequencing (Recommended)

### Phase 1 — Data Model (do first, single build_runner run)
1. Add 7 missing fields to `UserSettings`:
   - `prayerCardVariant`, `isSpacesEnabled`, `isHealthEnabled`, `isAssetsEnabled`
   - `reduceMotion`, `disableGyro`, `easternNumerals`
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`
3. Verify `flutter analyze` = 0 issues

### Phase 2 — Token + Global fixes (no new features, max blast radius)
1. Replace all `ResponsiveHelper.isTablet()` → `LayoutBuilder` in login, register, profile
2. Replace hardcoded colors in all audited files with `AppColors.*` tokens
3. Move hardcoded strings to ARB files; run `flutter gen-l10n`
4. Move `AdaptiveScaffold` → `AdaptiveShell` at spec path

### Phase 3 — Profile page move (isolated, low risk)
1. `git mv` profile_page.dart from `auth/` → `settings/`
2. Update app.dart import
3. Grep `auth/` for Navigator.push calls to ProfilePage

### Phase 4 — New components (spec-required, shared)
1. Extract `RoleChip` to design system
2. Add 8 feature-specific `EmptyState` variants
3. Create `SyncStatusCard`
4. Add `numericMono` to `AtharTypography`

### Phase 5 — Settings UI sections
1. Add Modules section in `general_settings_page.dart`
2. Add Accessibility section in `general_settings_page.dart`
3. Add prayer card variant selector (Compact / Expanded toggle)

### Phase 6 — Onboarding rebuild (new feature, highest effort)
1. Scaffold `lib/features/onboarding/` folder
2. Create `OnboardingCubit` + 5 step pages
3. Rewire `/onboarding` route in `app.dart`
4. Migrate `hasSeenOnboarding` from SharedPreferences to UserSettings

### Phase 7 — Auth pages (login, register)
1. Add password visibility toggle
2. Move to field-level error states
3. Add confirm password to register

### Phase 8 — Spaces / Members / Invitations
1. Add viewer role to members page
2. Wire `isSpacesEnabled` gate
3. Fix invitation widget hardcoded strings

---

## Do-Not-Touch Constraints (Carry Forward)

- Prayer toggle hierarchy (Phase 8.1): `isPrayerEnabled → isPrayerCardEnabled → isPrayerNotificationsEnabled → enablePrayerReminders` — do not simplify
- `WidgetKeys` constants — never rename
- App Group ID `group.com.iappsnet.athar` — never change
- `injection.config.dart` — never edit directly
- Central NavBar `+` FAB — only add entry point
- All prayer notifications via `PrayerNotificationScheduler` only
- `SubscriptionCubit` must remain `@lazySingleton`

---

## Open Questions for Designer

1. **Viewer role colors**: COMPONENT_SPECS §5 shows 4 roles but viewer color not specified precisely — confirm `AppColors.surface` + `text3` is correct.
2. **isSpacesEnabled default**: Should spaces be ON (true) or OFF (false) by default for new installs?
3. **Onboarding step 5 (space)**: Is space creation during onboarding mandatory or optional? If optional, what's the skip action?
4. **prayerCardDisplayMode + prayerCardVariant in Settings UI**: Should they appear as two separate rows, or should the variant selector only appear when `isPrayerCardEnabled = true`?
5. **Calibri font decision (PACKAGE_A #1)**: Unresolved. Current app uses Cairo. Implementation blocked on this until designer confirms Calibri vs Cairo for Arabic text.

---

## Audit Completeness

| Area | File Read | Evidence-Based | Grade |
|------|-----------|----------------|-------|
| Settings page | ✅ `general_settings_page.dart` (120 lines) | ✅ | C |
| UserSettings model | ✅ `user_settings.dart` (full) | ✅ | C |
| Profile page | ✅ `profile_page.dart` (80 lines) | ✅ | D |
| Login page | ✅ `login_page.dart` (full) | ✅ | B |
| Register page | ✅ `register_page.dart` (full) | ✅ | C |
| Onboarding | ✅ `onboarding_page.dart` (80 lines) | ✅ | F |
| Splash screen | ✅ `splash_page.dart` (full) | ✅ | B |
| Spaces page | Partial | Partial | C |
| Invitations | ✅ `pending_invitations_widget.dart` (60 lines) | ✅ | C |
| Members mgmt | ✅ `space_members_page.dart` (full review) | ✅ | C |
| Feature toggles | ✅ `user_settings.dart` | ✅ | D |
| AtharEmptyState | ✅ `athar_display.dart:321` | ✅ | C |
| AdaptiveScaffold | ✅ grep confirmed location | ✅ | D |
