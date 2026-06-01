# AdaptiveShell Foundation Audit

**Date:** 2026-06-01  
**Trigger:** Pre-PR4a readiness gate — ADAPTIVESHELL_IPAD_PR4A_READINESS_AUDIT  
**Scope:** Layer 1 only — shell infrastructure verification  
**No Dart code modified.**

---

## Files Inspected

| File | Lines | Purpose |
|------|-------|---------|
| `lib/core/design_system/widgets/adaptive_shell.dart` | 79 | ShellBreakpoint enum + AdaptiveShell LayoutBuilder |
| `lib/features/home/presentation/pages/main_page.dart` | 500+ | Shell integration, NavigationRail, RTL |
| `lib/core/utils/responsive_helper.dart` | 706 (incl. legacy comments) | Device detection, content widths, breakpoints |
| `lib/core/design_system/widgets/responsive_wrapper.dart` | 215 | Content-area wrappers (ResponsiveWrapper, ResponsiveLayout, ResponsiveGrid) |
| `lib/core/design_system/widgets/liquid_glass_nav_bar.dart` | — | FAB pill, phone dock chrome |
| `lib/core/design_system/widgets/context_aware_fab.dart` | — | FAB routing |

---

## Part 1 — Layer 1 Checklist

### Breakpoints

| Breakpoint | Width | Behavior | Status |
|------------|-------|----------|--------|
| `phone` | < 600dp | Bottom `LiquidGlassNavBar` + FAB | ✅ Implemented |
| `tabletCompact` | 600–839dp | `NavigationRail` 72pt, icons only | ✅ Implemented |
| `tabletExpanded` | 840–1199dp | `NavigationRail` 200pt, user-togglable | ✅ Implemented |
| `desktop` | ≥ 1200dp | Expanded rail (full sidebar deferred, not a blocker) | ✅ Implemented |

Code: `adaptive_shell.dart:21–26` (`ShellBreakpoint.fromWidth`) + `adaptive_shell.dart:29–43` (getters).

### Phone Bottom Dock

- `LiquidGlassNavBar` rendered only when `breakpoint.isPhone` → `main_page.dart:151`
- `extendBody: breakpoint.isPhone` → content scrolls behind glass → `main_page.dart:140`
- `IndexedStack` preserves page state on phone → `main_page.dart:232`

**Status: ✅ Complete**

### Compact Rail (600–839dp)

- `effectivelyExpanded = !breakpoint.usesCompactRail && _isRailExpanded` → icons only, no expand toggle
- `_buildRailLeading` returns `SizedBox.shrink()` on compact rail → no expand button
- `didChangeDependencies` forces `_isRailExpanded = false` when width drops to 600–839

**Status: ✅ Complete**

### Expanded Rail (840dp+)

- User-togglable width: 72pt (collapsed) → 200pt (expanded)
- Auto-expands in landscape, auto-collapses in portrait via `didChangeDependencies`
- Animated container width transition via `AtharAnimations.normal`

**Status: ✅ Complete**

### RTL Rail Placement

- `Row(children: isRTL ? [content, rail] : [rail, content])` → `main_page.dart:327`
- Rail on trailing edge (right in RTL, left in LTR) — correct
- Chevron icon flips: `Icons.chevron_right_rounded` in RTL + `AnimatedRotation`
- `SafeArea(left: !isRTL, right: isRTL)` on content area

**Status: ✅ Complete**

### FAB Behavior

- Phone: FAB pill inside `LiquidGlassNavBar` — 22px radius, forest gradient `#2F7A5E→#0F3D2E`, 64×64
- Tablet: `FloatingActionButton.large` — separate from rail, correct position
- `FabContextProvider` wraps `AdaptiveShell` so same FAB routing works on both form factors

**Status: ✅ Complete**

### LayoutBuilder Usage (Split View / Stage Manager Safety)

- `AdaptiveShell` uses `LayoutBuilder` at `adaptive_shell.dart:72–74` — reads `constraints.maxWidth`
- Does NOT use `MediaQuery.size.width` at the shell level
- Width changes from Split View / Stage Manager / Slide Over trigger immediate rebuilds

**Status: ✅ Complete**

### Safe-Area Handling

- `SafeArea(child: NavigationRail(...))` on the rail — notch-safe
- `SafeArea(left: !isRTL, right: isRTL)` on content — directional-safe
- Phone keyboard inset handled by `Scaffold.extendBody: true` + native inset

**Status: ✅ Complete**

### Content Width on Wide Screens

- `AdaptiveShell` itself does NOT cap content width — it only handles chrome (navigation)
- Feature pages are responsible for their own content width capping
- Current pattern: `ConstrainedBox(maxWidth: context.isTablet ? ResponsiveHelper.maxContentWidth : double.infinity)` — **already in `calendar_page.dart`**
- `ResponsiveHelper.maxContentWidth = 900` — content capped at 900dp on tablet

**Status: ✅ Content capping available via ResponsiveHelper; shell delegates this correctly to pages**

---

## Part 2 — Known Limitation (Not a Layer 1 Blocker)

### ResponsiveHelper / AdaptiveShell Breakpoint Mismatch

| Decision point | Method used | Split View behavior |
|----------------|-------------|---------------------|
| `AdaptiveShell` chrome (rail vs dock) | `LayoutBuilder constraints.maxWidth` | ✅ Correct — reacts to window width |
| `ResponsiveHelper.isTablet()` | `MediaQuery.shortestSide >= 600` | ⚠️ Device-based — returns `true` even in narrow Split View window |
| `ResponsiveLayout` / `ResponsiveWrapper` | Delegates to `ResponsiveHelper` | ⚠️ Same split view mismatch |
| `context.isTablet` extension | Delegates to `ResponsiveHelper` | ⚠️ Same |

**Impact:** In a narrow iPad Split View window (<600dp width):
- `AdaptiveShell` correctly shows phone chrome (bottom dock)
- But `context.isTablet` returns `true` → feature pages apply tablet content styles in a phone-width area
- Result: content may be width-capped at 900dp in a window narrower than 900dp (effectively no-op, so no visual break)
- Result: content may use tablet padding/typography in a phone-sized window

**Severity:** Low — does not break functionality; minor cosmetic mismatch in Split View. Accepted risk for current PRs.

**Fix (deferred, not urgent):** Feature pages should use `LayoutBuilder` within their bodies and pass `constraints.maxWidth` to `ShellBreakpoint.fromWidth()` for self-consistent behavior. This can be batched into PR-IPAD-LAYER2 per screen.

---

## Part 3 — Content-Area Contract (Decisive Test)

### AdaptiveShell API

```dart
// adaptive_shell.dart:62–68
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({super.key, required this.builder});

  final Widget Function(BuildContext context, ShellBreakpoint breakpoint) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ShellBreakpoint.fromWidth(constraints.maxWidth);
        return builder(context, breakpoint);
      },
    );
  }
}
```

### How Feature Pages Are Served

`AdaptiveShell` is used in `main_page.dart` **only**. Feature pages (`CalendarPage`, `HabitsPage`, etc.) are NOT wrapped in their own `AdaptiveShell`. They are served as passive bodies:

```dart
// main_page.dart: tablet branch
body: _pages[_currentIndex]  // Line 321 inside SafeArea

// main_page.dart: phone branch  
child: IndexedStack(index: _currentIndex, children: _pages)  // Line 232
```

Feature pages receive whatever content area they are given. They do NOT interact with `AdaptiveShell` directly.

### Can Feature Pages Add Tablet Layouts WITHOUT Modifying adaptive_shell.dart?

**YES — definitively.** Three proven patterns, all usable today:

**Pattern A: `ResponsiveLayout` (simplest — coarse device-based)**
```dart
// Inside CalendarPage body — no adaptive_shell.dart change needed
class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildPhoneLayout(),
        tablet: _buildTabletLayout(),
      ),
    );
  }
}
```

**Pattern B: `LayoutBuilder` + `ShellBreakpoint` (recommended — Split View safe)**
```dart
// Reuse ShellBreakpoint in feature body — no adaptive_shell.dart change needed
class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bp = ShellBreakpoint.fromWidth(constraints.maxWidth);
          return bp.isTablet ? _buildTabletLayout() : _buildPhoneLayout();
        },
      ),
    );
  }
}
```

**Pattern C: `ResponsiveGrid` (for grid layouts)**
```dart
// HabitsPage tablet grid — no adaptive_shell.dart change needed
ResponsiveGrid(
  mobileColumns: 1,
  tabletColumns: 2,
  children: habits.map((h) => HabitTile(h)).toList(),
)
```

**Three-column layouts (e.g., 28%/42%/30% dashboard):**
```dart
// Dashboard tablet landscape — no adaptive_shell.dart change needed
Row(children: [
  Expanded(flex: 28, child: _greetingColumn()),
  Expanded(flex: 42, child: _tasksColumn()),
  Expanded(flex: 30, child: _timelineColumn()),
])
```

**Verdict: AdaptiveShell foundation is complete. No PR2.1 required. Feature pages add tablet layouts independently.**

---

## Part 4 — Whether Any Layer 1 Shell Blocker Remains

| Check | Result |
|-------|--------|
| `adaptive_shell.dart` needs modification for any PR4a+ screen | ❌ No — feature pages are independent |
| Any chrome behavior missing for tablets | ❌ No — compact/expanded rail both work |
| Any RTL gap | ❌ No — rail side, chevron, SafeArea all correct |
| Any Split View / Stage Manager gap | ❌ No — `LayoutBuilder` at shell level |
| Any FAB gap | ❌ No — phone pill + tablet FAB.large both present |
| Any blocker for PR4a start | ❌ No — calendar fits in existing shell |

**Layer 1 is ready. No PR2.1 is required. AdaptiveShell is ready for PR4a and all subsequent feature PRs.**

---

## Validation Checklist

| Item | Status |
|------|--------|
| `adaptive_shell.dart` exists (79 lines) | ✅ |
| `ShellBreakpoint.fromWidth()` covers all 4 bands | ✅ |
| `AdaptiveShell` uses `LayoutBuilder` (not `MediaQuery.size`) | ✅ |
| Phone: `LiquidGlassNavBar` shown, `extendBody: true` | ✅ |
| Tablet compact (600–839): icon-only rail, no expand toggle | ✅ |
| Tablet expanded (840+): togglable, auto-expands in landscape | ✅ |
| RTL rail placement: trailing edge | ✅ |
| RTL chevron flip + animation | ✅ |
| `SafeArea` directional on tablet content | ✅ |
| FAB: pill on phone, `FloatingActionButton.large` on tablet | ✅ |
| Stage Manager / Split View safe at shell level | ✅ |
| Feature pages CAN add tablet layouts without modifying shell | ✅ |
| PR2.1 needed | ❌ Not needed |
