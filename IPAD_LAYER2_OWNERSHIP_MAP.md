# iPad Layer 2 — Ownership Map

**Date:** 2026-06-01  
**Source spec:** `IPAD_OPTIMIZATION.md §1–§9`  
**Decision:** PR-IPAD-LAYER2 is an **umbrella tracker only** — not a mega-PR.  
Each screen's tablet layout ships inside that screen's feature PR.

---

## Architecture Decision

`PR-IPAD-LAYER2` is a tracking label, not a standalone implementation PR.

**Rationale:**
- Each screen's tablet layout depends on the same PR that redesigns that screen's phone layout
- Shipping tablet + phone together avoids two passes through the same file
- Layer 2 work is additive to each feature PR: add `tablet:` branch to `ResponsiveLayout` — no cross-file coordination required
- A batch mega-PR after all features land would touch 9+ files with no logical cohesion and high regression risk

**Governance:** The rows in this table replace the `PR-IPAD-LAYER2` placeholder in the roadmap. When a feature PR ships its tablet branch, mark the row ✅.

---

## Screen Ownership

### Dashboard

| Field | Value |
|-------|-------|
| **Spec** | `IPAD_OPTIMIZATION.md §1` |
| **Target file** | `lib/features/home/presentation/pages/dashboard_page.dart` |
| **Owning PR** | **PR-DASHBOARD-TABLET** (new standalone PR — no phone redesign yet planned) |
| **Tablet requirement** | 2-col portrait (40%/60%): greeting+prayer / tasks+habits. 3-col landscape (28%/42%/30%): greeting+prayer / tasks+habits / timeline+stats peek. Prayer card capped at 480pt. |
| **Implementation pattern** | `LayoutBuilder` → `ShellBreakpoint.fromWidth` → `Row(Expanded(flex:...))` branches |
| **Currently implemented** | `ConstrainedBox(maxWidth: context.isTablet ? 900 : infinity)` — width cap only |
| **Future work required** | Multi-column layout |
| **Ships with feature PR** | Yes — when Dashboard redesign PR ships |

---

### Prayer (Calendar + Prayer Card)

| Field | Value |
|-------|-------|
| **Spec** | `IPAD_OPTIMIZATION.md §1` (prayer card appears in Dashboard column) |
| **Target file** | `lib/core/design_system/molecules/cards/next_prayer_card.dart` |
| **Owning PR** | PR3 complete for phone. Tablet sizing (cap at 480pt) → PR-DASHBOARD-TABLET |
| **Tablet requirement** | Cap at 480pt, centered in its dashboard column. No stretch. |
| **Currently implemented** | PR3 forest gradient complete. No width cap on card itself. |
| **Future work required** | Width cap — 2 lines of change. Deferred to Dashboard PR. |
| **Ships with feature PR** | Yes — PR-DASHBOARD-TABLET |

---

### Tasks

| Field | Value |
|-------|-------|
| **Spec** | `IPAD_OPTIMIZATION.md §2` |
| **Target file** | `lib/features/task/presentation/pages/unified_tasks_page.dart` (display) + `task_page.dart` |
| **Owning PR** | Future task redesign PR (no current PR planned for tasks visual refresh) |
| **Tablet requirement** | Master-detail: task list (360pt) + task detail pane. No push on iPad. Hero title transition. Right-rail (3rd column) at ≥1200dp. |
| **Implementation pattern** | `LayoutBuilder` or `ResponsiveLayout(tablet: TaskMasterDetailPage())` |
| **Currently implemented** | `ConstrainedBox(maxWidth: context.isTablet ? 900 : infinity)` — width cap only |
| **Future work required** | `TaskMasterDetailPage` widget, selected-task side pane, empty state, Hero |
| **Ships with feature PR** | Yes — when task redesign ships |

---

### Habits

| Field | Value |
|-------|-------|
| **Spec** | `IPAD_OPTIMIZATION.md §3` |
| **Target file** | `lib/features/habits/presentation/pages/habit_page.dart` + `habit_details_page.dart` |
| **Owning PR** | Future habits redesign PR |
| **Tablet requirement** | 2-col portrait / 3-col landscape `ResponsiveGrid`. Permanent right pane (`HabitDetailsBody` scaffold-less). |
| **Implementation pattern** | `ResponsiveGrid(mobileColumns: 1, tabletColumns: 2)` + `LayoutBuilder` for pane |
| **Currently implemented** | `ConstrainedBox(maxWidth: context.isTablet ? 900 : infinity)` — width cap only |
| **Future work required** | `HabitDetailsBody` scaffold-less widget extraction, grid layout, right pane |
| **Ships with feature PR** | Yes — when habits redesign ships |

---

### Calendar

| Field | Value |
|-------|-------|
| **Spec** | `IPAD_OPTIMIZATION.md §4` |
| **Target files** | `lib/features/calendar/presentation/pages/calendar_page.dart`, `dual_calendar_widget.dart` |
| **Owning PR** | **PR4a** (visual refresh) + **PR4b** (full rebuild incl. iPad layout) |
| **Tablet requirement** | Week view default portrait. Full month grid + side timeline of selected day in landscape. Multi-source activity dots. |
| **Implementation pattern** | `LayoutBuilder` or `ResponsiveLayout` in `CalendarPage` body |
| **Currently implemented** | `ConstrainedBox(maxWidth: context.isTablet ? 900 : infinity)` — width cap only |
| **Future work required** | Week view, month grid, side timeline — all PR4b architecture (requires `TimelineItem` cubit unification) |
| **Ships with feature PR** | PR4b — Calendar dual-display rebuild |

---

### Athkar / Dhikr

| Field | Value |
|-------|-------|
| **Spec** | No explicit tablet spec in `IPAD_OPTIMIZATION.md` |
| **Target file** | `lib/features/dhikr/` |
| **Owning PR** | PR7 (Athkar net-new feature) |
| **Tablet requirement** | Not specified — defer to PR7 audit |
| **Currently implemented** | Unknown — no explicit tablet handling found |
| **Future work required** | Determine in PR7 pre-implementation audit |
| **Ships with feature PR** | Yes — PR7 |

---

### Stats

| Field | Value |
|-------|-------|
| **Spec** | `IPAD_OPTIMIZATION.md §6` |
| **Target file** | `lib/features/stats/presentation/pages/stats_page.dart` |
| **Owning PR** | **PR6** (Stats redesign — already planned; spec explicitly includes tablet layout) |
| **Tablet requirement** | 2-col chart grid portrait. 3-col dashboard landscape + sparkline rail (280pt). |
| **Implementation pattern** | `ResponsiveGrid` wrapping each chart card |
| **Currently implemented** | NO tablet handling at all |
| **Future work required** | `ResponsiveGrid` wrapper + sparkline rail |
| **Ships with feature PR** | Yes — PR6 |

---

### Settings

| Field | Value |
|-------|-------|
| **Spec** | `IPAD_OPTIMIZATION.md §7` |
| **Target file** | `lib/features/settings/presentation/pages/settings_page.dart` + sub-pages |
| **Owning PR** | **PR5** (Accessibility Settings — already planned; touches same file) |
| **Tablet requirement** | Two-pane: category list 280pt (leading) + content (trailing). Phone retains push navigation. `selectedCategory` local state. Deep-link pre-selection. |
| **Implementation pattern** | `ResponsiveLayout(mobile: pushNavLayout, tablet: twoPaneLayout)` |
| **Currently implemented** | NO tablet handling — phone-only push navigation |
| **Future work required** | Two-pane layout, `selectedCategory` state, scaffold-less sub-page bodies |
| **Ships with feature PR** | Yes — PR5 |

---

### Focus

| Field | Value |
|-------|-------|
| **Spec** | `IPAD_OPTIMIZATION.md §5` |
| **Target file** | `lib/features/focus/presentation/pages/focus_page.dart` |
| **Owning PR** | **PR8** (Focus oil-fill — already planned; touches same file) |
| **Tablet requirement** | Cap timer composition at 720pt, centered. Session history rail 280pt on landscape. |
| **Implementation pattern** | `Center(child: ConstrainedBox(maxWidth: 720))` + `LayoutBuilder` for rail |
| **Currently implemented** | NO tablet handling |
| **Future work required** | Width cap + history rail |
| **Ships with feature PR** | Yes — PR8 (cap is minimal; history rail is additive) |

---

### Spaces

| Field | Value |
|-------|-------|
| **Spec** | `IPAD_OPTIMIZATION.md §8` |
| **Target files** | `lib/features/space/presentation/` |
| **Owning PR** | Future spaces redesign PR (not currently scheduled) |
| **Tablet requirement** | Master/detail portrait (320pt list + detail). 3-col landscape: spaces list / members list / permission matrix (`Table` with sticky column+header). |
| **Implementation pattern** | `ResponsiveLayout` + permission matrix widget |
| **Currently implemented** | Basic maxWidth + some `isTablet` checks — no master-detail |
| **Future work required** | Permission matrix widget (Table + DropdownMenu), master-detail layout |
| **Ships with feature PR** | Yes — spaces redesign |

---

### Onboarding

| Field | Value |
|-------|-------|
| **Spec** | `IPAD_OPTIMIZATION.md §9` |
| **Target file** | `lib/features/home/presentation/pages/onboarding_page.dart` |
| **Owning PR** | **PR-ONBOARD-AB** |
| **Tablet requirement** | Centered card 560pt portrait. 2-col 960pt landscape: illustration (480pt) + content (480pt). No orientation lock on iPad. |
| **Implementation pattern** | `ResponsiveWrapper.content()` + `ResponsiveLayout` |
| **Currently implemented** | Variant A phone-only. No tablet layout. |
| **Future work required** | Centered card + 2-col layout. |
| **Ships with feature PR** | Yes — PR-ONBOARD-AB |

---

## Summary — Umbrella Tracker Status

| Screen | Owning PR | Tablet work status | Layer 2 ETA |
|--------|-----------|-------------------|-------------|
| Dashboard | PR-DASHBOARD-TABLET | Not Started | After Dashboard phone design |
| Prayer card | PR-DASHBOARD-TABLET | Not Started | With Dashboard |
| Tasks | Future task PR | Not Started | Not scheduled |
| Habits | Future habits PR | Not Started | Not scheduled |
| Calendar | PR4b | Not Started | PR4b |
| Athkar | PR7 | Not Started | PR7 |
| Stats | PR6 | Not Started | PR6 |
| Settings | PR5 | Not Started | PR5 |
| Focus | PR8 | Not Started | PR8 |
| Spaces | Future spaces PR | Not Started | Not scheduled |
| Onboarding | PR-ONBOARD-AB | Not Started | PR-ONBOARD-AB |

**Immediate actions for PR4a:** None. Calendar tablet layout is PR4b scope. PR4a can proceed without any Layer 2 work.
