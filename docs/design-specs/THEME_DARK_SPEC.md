# Theme — Dark Mode Spec

> Per Package C #1: every screen ships light + dark in v1. Tokens already
> live in `colors_and_type.css` (dark variants) and the Flutter codebase
> (`AtharColors.dark*`). This file locks the per-surface treatments.

---

## 1 · Theme switching

- `UserSettings.theme: 'system' | 'light' | 'dark'` (default `system`).
- Settings → Accessibility → Theme: 3-option segmented control.
- Switch is animated: `MaterialApp.themeMode` change with a 200ms cross-fade.

---

## 2 · Surface mapping (light → dark)

| Light token | Dark token | Notes |
|---|---|---|
| `surface` `#FFFFFF` | `surface` `#1A2520` | Primary card bg. |
| `background` `#F8F9FA` | `background` `#0E1714` | Scaffold. |
| `surface-variant` `#F5F5F5` | `surface-variant` `#22302B` | Subtle differentiation. |
| `surface-container` `#EEEEEE` | `surface-container` `#2A3833` | Elevated cards. |
| `text-primary` `#2D3436` | `text-primary` `#EDE6C8` | Cream-tinted body text. |
| `text-secondary` `#636E72` | `text-secondary` `#9BA8A2` | |
| `text-tertiary` `#95A5A6` | `text-tertiary` `#6B7771` | |
| `border-light` `#ECE6D3` | `border-light` `#2A3833` | |
| `primary` (forest) `#0F3D2E` | `primary` `#2E8B57` | Brighten primary in dark — pure forest reads as black. |

Cream stays cream in both modes (it's the warm anchor).

---

## 3 · Per-screen treatments

### Dashboard
- AppBar: transparent over scaffold (both modes).
- Prayer card: forest gradient unchanged. In dark, scaffold around it goes near-black, making the card glow.
- Stats rail: card bg = `surface-container`.

### Tasks / Habits
- List rows: `surface`. Selected row: `primary` 12% tint.
- Swipe actions: complete = `success`, delete = `error`. Same in both modes.

### Calendar
- Cell bg: transparent. Today: `primary` 12% tint (light) / `primary` 24% (dark).
- Selected: solid `primary` (both modes). White text.
- Hijri numerals: `primary-light` (light) / `cream` (dark) — brighten for legibility.
- Hijri-month boundary hairline: `primary-light` (light) / `cream-deep` (dark).

### Athkar (inside Habits)
- Reader: dhikr card uses `surface`, counter ring `primary` (both modes).
- Reader bg: cream gradient (light) / forest-deep gradient (dark).

### Focus
- Oil-fill animation tints to `forest-deep` in dark (vs `forest` in light).
- Dynamic Island drip color: `cream` (both modes).

### Settings
- Section bg: `surface`. Group separators: `border-light`.
- Toggle on: `primary` (both modes). Off: `surface-container-high`.

---

## 4 · Imagery + illustrations

- **Empty-state illustrations** ship in **two color palettes**:
  - Light: forest line on cream bg.
  - Dark: cream line on forest-deep bg.
- App icon (launcher): unchanged, single asset (the green-ground icon you
  shipped). iOS auto-darkens; Android adaptive icon respects system.
- Splash: forest-deep bg in both modes (icon already has its own ground).

---

## 5 · Status bar + system chrome

- Light mode: `SystemUiOverlayStyle.dark` (dark icons on light scaffold).
- Dark mode: `SystemUiOverlayStyle.light`.
- Prayer card scrim adjusts accordingly when card meets status bar edge.

---

## 6 · Color contrast guarantees

- Body text vs surface: ≥ 4.5:1 in both modes.
- AAA target for athkar reader (≥ 7:1) — that's why `cream` on `forest-deep`
  is the pairing there, not `text-secondary`.
- Disabled state: `text-tertiary` at 60% opacity. Must still pass 3:1.

---

## 7 · QA matrix

Every screen must be manually screenshot-tested in:
- iPhone 15 Pro · light + dark
- iPhone SE (small) · light + dark
- iPad portrait + landscape · light + dark
- Arabic locale · all 6 above

That's 24 screenshots per screen × ~12 screens = **~288 screenshot diffs**
to baseline. Use Golden Toolkit.

---

## 8 · Implementation order

1. `AppColors` already has dark variants — verify each is used.
2. Add `themeMode` to settings + persist.
3. Audit any hardcoded color literal (88 files per gap report) and replace
   with token reference.
4. Build dark variants of empty-state illustrations.
5. Run the QA matrix.
