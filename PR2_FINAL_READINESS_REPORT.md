# PR2 Final Readiness Report — AdaptiveShell

**Date:** 2026-05-09  
**PR:** PR2 — AdaptiveShell + responsive breakpoints + 4-tab nav + standalone FAB  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Status:** ✅ READY — all 4 spec files read; zero blockers; implementation plan complete  
**Supersedes:** `PR2_READINESS_PREVIEW.md` (was NOT READY — 4 files unread)

---

## Spec File Reading Summary

All 4 required files are now fully read and analyzed.

| File | Status | Key Deliverable |
|------|--------|----------------|
| `handoff_v2-2/IPAD_OPTIMIZATION.md` | ✅ Read | AdaptiveShell breakpoints, NavigationRail spec, FAB rail slot |
| `handoff_v2-2/INVESTIGATION_REPORT.md` | ✅ Read | Current file locations, `AdaptiveShell` identifier absent from codebase |
| `handoff_v2-2/REDESIGN_AUDIT.md` | ✅ Read | Bottom nav shape (§11), cross-cutting checklist, per-screen ticket list |
| `handoff_v2-2/preview/comp-nav.html` | ✅ Read | Exact CSS measurements: dock flex, 10px gap, nav 64px h / 24px radius, FAB 64×64 / 22px radius |

---

## PR2 Scope — Locked

PR2 is **shell-only**. It adds responsive breakpoint behavior at the outermost scaffold layer.
No screen content changes. No Isar model changes. No new cubits.

### Files to CREATE

| File | Description |
|------|-------------|
| `lib/core/design_system/widgets/adaptive_shell.dart` | New AdaptiveShell widget; LayoutBuilder branches for phone/rail; RTL-aware |

### Files to MODIFY

| File | Specific Change |
|------|----------------|
| `lib/features/home/presentation/pages/main_page.dart` | Wrap scaffold in AdaptiveShell; restructure bottom dock to `Row(nav + FAB)` |
| `lib/core/design_system/widgets/liquid_glass_nav_bar.dart` | 4 tabs only (Dashboard/Tasks/Habits/Spaces); no FAB inside; exact glass treatment from §11 |
| `lib/core/design_system/widgets/context_aware_fab.dart` | 64×64, borderRadius 22, primary gradient (#2F7A5E→#0F3D2E), cream foreground |

### Files NOT touched in PR2

| File | Reason |
|------|--------|
| `lib/core/layouts/adaptive_scaffold.dart` | Superseded but keep; delete only in PR-CLEANUP |
| All screen/page/feature files | PR2 is shell-only |
| All Isar models | No data layer changes |
| `lib/l10n/*.arb` | Nav labels already exist in ARBs |

---

## Codebase Facts (Confirmed from INVESTIGATION_REPORT.md)

| Item | Location |
|------|----------|
| Current shell | `lib/core/layouts/adaptive_scaffold.dart` |
| `AdaptiveShell` identifier | Not found anywhere — clean slate |
| LiquidGlassNavBar | `lib/core/design_system/widgets/liquid_glass_nav_bar.dart` |
| ContextAwareFab | `lib/core/design_system/widgets/context_aware_fab.dart` |
| Main page | `lib/features/home/presentation/pages/main_page.dart` |
| ResponsiveHelper | `lib/core/utils/responsive_helper.dart` (DeviceType, breakpoints 600/1200) |
| ResponsiveWrapper | `lib/core/design_system/widgets/responsive_wrapper.dart` |

---

## AdaptiveShell Breakpoint Spec (IPAD_OPTIMIZATION.md)

| Breakpoint | Width | Nav Chrome | FAB Position |
|------------|-------|-----------|-------------|
| Phone | < 600dp | LiquidGlassNavBar bottom dock | Standalone pill beside bar (10px gap) |
| Tablet compact | 600–839dp | NavigationRail, 72pt wide, icons only | Rail leading slot |
| Tablet expanded | 840–1199dp | NavigationRail, 240pt wide, labels visible | Rail leading slot |
| Desktop | ≥ 1200dp | Rail + sidebar panel | Deferred — use expanded rail as fallback |

**Critical:** Use `LayoutBuilder` (not `MediaQuery.size.width`) — required for Split View / Stage Manager compatibility.

---

## Bottom Nav Spec (REDESIGN_AUDIT.md §11 + comp-nav.html)

### Dock Layout (phone)

```
Row(textDirection: inherited from Directionality)   ← RTL auto-reverses
  ├── Expanded(child: LiquidGlassNavBar)
  ├── SizedBox(width: 10)
  └── ContextAwareFab (64×64)
```

### LiquidGlassNavBar

| Property | Value |
|----------|-------|
| Height | 64px |
| Border radius | 24px |
| Blur | BackdropFilter sigmaX 28, sigmaY 28 |
| Saturation | 180% |
| Fill gradient | rgba(255,255,255,.42) → rgba(255,255,255,.22), top→bottom |
| Specular highlight | Radial gradient top |
| Border | Inner 1px rgba(255,255,255,.22) |
| Tabs | 4: Dashboard / Tasks / Habits / Spaces (ARB strings) |
| Active color | AppColors.primary (forest green #0F3D2E) |
| Active chip | rgba(255,255,255,.32) fill + 1px inner ring |

### Standalone FAB

| Property | Value |
|----------|-------|
| Size | 64×64 |
| Border radius | 22px |
| Gradient | 135°: #2F7A5E → #0F3D2E |
| Foreground | #FAF7EC (cream) |
| Gap from bar | 10px |
| Shadow | Ambient 10px + brand-tinted 3px + specular inset |
| RTL | Appears left of bar automatically via inherited Directionality |

---

## RTL Rules (Non-Negotiable for PR2)

- `Row` children auto-reverse via inherited `TextDirection` — never hardcode left/right positions
- `NavigationRail` side driven by `Directionality.of(context)` — never `Alignment.centerLeft`
- `EdgeInsetsDirectional` everywhere — never `EdgeInsets.only(left:)` or `only(right:)`
- `AlignmentDirectional` everywhere — never `Alignment.centerLeft/centerRight`

---

## Blockers

None. PR2 has zero blockers:

| Blocker | Affects PR2? |
|---------|-------------|
| B1 — Calibri App Store licence | No |
| B2 — Dark secondary gradient | No |
| B3 — Calendar dual-display spec | No |

---

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| `main_page.dart` has complex BlocProvider tree | Medium | Read file before editing; preserve provider tree exactly; restructure scaffold only |
| `LiquidGlassNavBar` may currently manage FAB internally | Low | Read before editing; strip FAB logic from bar |
| NavigationRail RTL placement | Low | Use `Directionality.of(context)` inline; test both orientations |
| `adaptive_scaffold.dart` has live consumers | Low | Do not delete in PR2; AdaptiveShell wraps independently |

---

## Approval Phrase

Use **"Implement PR2"** to begin implementation.

**Required reads at implementation time (Dart source files — not spec files):**
1. `lib/features/home/presentation/pages/main_page.dart`
2. `lib/core/design_system/widgets/liquid_glass_nav_bar.dart`
3. `lib/core/design_system/widgets/context_aware_fab.dart`

Full step-by-step plan: `PR2_IMPLEMENTATION_PLAN.md`
