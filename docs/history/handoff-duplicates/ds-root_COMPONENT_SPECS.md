# Component Specs — Athar Design System

> Net-new components called out in Phase 6 audit. All measurements in Flutter
> logical pixels. All colors via tokens (`AppColors.*`). All copy via `.arb`.

---

## 1 · `EmptyState`

Used when a list/grid has zero items by design (not by error).

**Anatomy** (vertical stack, centered):
1. Illustration / glyph — 96×96, `AppColors.primaryMuted` tint.
2. Title — `AppText.titleM`, `AppColors.text`.
3. Body — `AppText.bodyS`, `AppColors.text2`, max 2 lines, `text-wrap: pretty`.
4. Primary CTA — optional `AppButton.primary`.
5. Secondary link — optional `AppButton.text`.

**Spacing**: 16 between glyph→title, 8 title→body, 24 body→CTA, 8 CTA→link.

**Variants** (props: `feature`):
- `tasks` — glyph: clipboard. "No tasks today". CTA: "Add task".
- `habits` — glyph: target. "Start your first habit". CTA: "New habit".
- `calendar` — glyph: calendar. "Nothing scheduled". CTA: "Add event".
- `focus` — glyph: hourglass. "Set up your first session". CTA: "Start focus".
- `stats` — glyph: chart. "Not enough data yet". CTA: none, link: "How stats work".
- `spaces` — glyph: people. "Create a shared space". CTA: "New space".
- `athkar` — glyph: prayer beads. "Begin your dhikr". CTA: "Start athkar".
- `search` — glyph: search. "No matches". CTA: none.

**Dark mode**: glyph tint switches to `AppColors.primaryMutedDark`.

---

## 2 · `ErrorState`

Three sub-variants for different fail surfaces.

### 2a · `ErrorState.full` — full-page failure
Same anatomy as EmptyState, but:
- Glyph: warning triangle, `AppColors.error` tint.
- Title: short ("Something went wrong").
- Body: error message + 1-line context.
- CTA: "Retry" (primary).
- Secondary link: "Report issue".

### 2b · `ErrorState.inline` — within a card
- Single row: 16×16 error glyph + body text (`AppText.bodyS`, `AppColors.error`).
- Trailing text button "Retry" if action available.
- Background: `AppColors.errorBg` (8% error tint).

### 2c · `ErrorState.compact` — toast / snackbar
- 32×32 left, body + retry inline right.
- Auto-dismiss after 5s unless action available.
- Stack at bottom-end with 8pt gap, max 3 visible.

---

## 3 · `SyncStatusCard`

Surface in Settings → Account showing Supabase sync state.

**States** (icon · ink color · title):
- `synced` — checkmark · `AppColors.success` · "Up to date" · subtitle: "Last synced {relative}".
- `syncing` — spinner · `AppColors.info` · "Syncing…" · subtitle: "{n} changes pending".
- `offline` — cloud-off · `AppColors.text3` · "Offline" · subtitle: "Will sync when connected".
- `error` — warning · `AppColors.error` · "Sync failed" · subtitle: error message · CTA: "Retry now".

**Layout**: 56pt min-height, 16pt padding, `AppColors.surface` bg, 14pt radius.

---

## 4 · Role Chips

Used in Spaces member lists.

| Role | Bg | Ink | Label key |
|---|---|---|---|
| owner | `AppColors.forest15` | `AppColors.forest` | `role.owner` |
| admin | `AppColors.amber15` | `AppColors.amber` | `role.admin` |
| member | `AppColors.surfaceAlt` | `AppColors.text2` | `role.member` |
| viewer | `AppColors.borderLt` | `AppColors.text3` | `role.viewer` |

**Shape**: pill, 4pt vertical / 10pt horizontal padding, `AppText.captionM`.

---

## 5 · `numericMono` text style

Add to `AppText`:

```dart
static const numericMono = TextStyle(
  fontFamily: 'JetBrainsMono',
  fontFeatures: [FontFeature.tabularFigures()],
  fontVariations: [FontVariation('wght', 500)],
);
```

Applied wherever digits must align column-wise: countdowns, timers, stat
values, streak counters, progress percentages.

**Size variants**: `numericMono.copyWith(fontSize: 12 / 14 / 18 / 24 / 36 / 56 / 72 / 84)`.

---

## 6 · `ModuleFlags` block

Settings → Features section. Already exists in mockup
(`SettingsScreen.jsx` → `featureList`). Spec lock-in:

- Each row: 36×36 tinted icon, name, description, `Toggle` switch.
- "CORE" badge appears next to name when `f.core` is true (cannot be toggled
  off — switch is disabled and visually muted).
- Toggle on/off persists immediately to `UserSettings.featureFlags`.
- Spaces, Health, Dhikr, Prayer, Notes are optional → can be toggled.
- Tasks, Habits, Calendar, Focus are core → always on.

**`isPrayerEnabled`** is the master toggle controlling: in-app prayer card,
prayer notifications, prayer-tied habits, and the iOS widget.

---

## 7 · `PrayerToggleTile`

Inside Settings → Prayer (visible only when `isPrayerEnabled` is on).

**Per-prayer row** (Fajr, Dhuhr, Asr, Maghrib, Isha):
- 32×32 icon (mosque glyph) on `AppColors.primary8` tint.
- Prayer name (`AppText.bodyM`).
- Time (`AppText.numericMono.copyWith(fontSize:14)`, `AppColors.text3`).
- Trailing: `Toggle` for adhan notification.
- Tap row → opens "Notification mode" sheet (silent / chime / full adhan).

**Hierarchy** (Phase 8.1, do not regress):
1. Master `isPrayerEnabled` (off → entire section hidden).
2. Per-prayer notification toggles.
3. Per-prayer notification mode.
4. Pre-prayer reminder offset (0 / 5 / 10 / 15 min).

---

## 8 · Form primitives (lock-in only — already in mockup)

For reference; no new spec needed beyond what `comp-inputs.html` shows:
- `AppTextField`: 48pt height, 12pt radius, `AppColors.surface`, 1pt border `AppColors.borderLt`. Focus → `AppColors.primary`, 2pt.
- `AppSelect`: same as TextField + chevron-down trailing.
- `AppDatePicker`: opens cupertino-style sheet on iOS, material on Android.
