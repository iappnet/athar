# Stats — KPI Spec (Tier-1 + Tier-2)

> Per Package A decision #5: full dashboard from day one. All KPIs ship in
> v1. Tier ordering controls visual prominence on the screen, not delivery.

---

## Visual hierarchy

```
Stats screen
├── Header: "Stats" + period selector (Today / Week / Month / Custom)
├── Tier-1 KPIs (hero grid: 6 cards, 2 columns on phone, 3 on iPad)
├── Tier-2 KPIs (secondary section, scroll below)
└── Insights (auto-generated copy: "You've focused 40% more this week")
```

---

## Tier-1 KPIs (always visible)

| # | KPI | Source | Metric type | Format |
|---|---|---|---|---|
| 1 | Tasks completed | `TaskCubit.completedCount` | today + 7d sparkline | "{n}" / chart |
| 2 | Longest current habit streak | `HabitCubit.maxStreak` | live integer | "{n} days" |
| 3 | Habits completion rate (7d) | `HabitCubit.completionRate7d` | percentage | "{pct}%" + trend arrow |
| 4 | Focus minutes | `FocusCubit.minutesToday/7d` | sum | "{n} min" / weekly bar |
| 5 | Prayer adherence (7d) | `PrayerCubit.adherence7d` | percentage | "{pct}%" |
| 6 | Athkar sessions (7d) | `AthkarCubit.sessions7d` | sum | "{n} sessions" |

**Card layout**: `StatsMetricCard` — title, big value (numericMono), trend
delta vs prior period, optional sparkline footer.

---

## Tier-2 KPIs (secondary section)

| # | KPI | Surface |
|---|---|---|
| 7 | Per-space breakdown | Spaces section: stacked bar, top 5 spaces by activity |
| 8 | Mood log (7d avg) | Optional — only shown if `isMoodEnabled` |
| 9 | Sleep (7d avg) | Optional — only shown if `isSleepEnabled` |
| 10 | Custom date ranges | Period selector includes "Custom…" → date-pair sheet |

---

## Components

### `StatsMetricCard`
- 1×1 (square) on phone, 2×1 (wide) on iPad large variant.
- Padding 16, radius 18, `AppColors.surface`, 1pt border `borderLt`.
- Title `AppText.captionM` (text3), value `numericMono` 28pt (text), trend
  pill bottom-right (green up / red down / gray flat with delta).

### `ChartCard`
- Wraps any chart (sparkline / bar / heatmap).
- Header: title + period chip.
- Body: chart, max-height 180pt phone / 240pt iPad.
- Tap → opens detail screen with full history.

### `InsightCard`
- Algorithmic copy generated nightly.
- E.g. "Your habit streak grew by 3 days this week."
- `AppText.bodyM`, `forest` accent on numbers.
- Dismiss (×) hides for 7d.

---

## Period selector

Pills row (horizontal scroll on phone):
- Today
- This week (default)
- This month
- Last 7 days
- Last 30 days
- Custom… → opens date-pair sheet

Selection persists in `StatsCubit.state.period`.

---

## Per-space breakdown (Tier-2 detail)

When user has 2+ spaces:
- Horizontal stacked bar, segmented per space.
- Below: legend with space color dot + name + count.
- Tap a segment → filters whole stats screen to that space.

---

## Empty / loading

- `EmptyState.stats` shown when no data exists in selected period.
- Skeleton grid while computing (6 placeholder cards).

---

## Export

Bottom CTA: "Export…" → choose CSV (raw) or PDF (formatted report). Sent via
share sheet or email.

---

## Accessibility

- All numbers announced with units ("7 days", "82 percent").
- Charts have alt-text summary ("Focus minutes increased steadily").
- Color is never the sole indicator: trend shown as arrow + sign (+/-).

---

## RTL

- Period selector flips direction.
- Charts: x-axis reads right-to-left (Sat at right, Fri at left).
- Trend arrows mirror.

---

## Implementation notes

- Aggregations computed in cubit, cached per period in Isar.
- Recompute on data mutation (debounced 500ms).
- Heavy queries (per-space, custom range) move to isolate.
