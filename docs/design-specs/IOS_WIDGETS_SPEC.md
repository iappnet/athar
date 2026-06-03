# iOS Widgets — Spec

> Three widgets × three sizes. All gated on the `isPrayerEnabled` master
> feature toggle (Package A decision #6). Visual language matches in-app
> components 1:1 — render through shared SwiftUI views generated from the
> Flutter `AppColors` / `AppText` token export.

---

## Common rules

- **Background**: respects iOS widget tint (system bg in light, dark in dark mode).
- **Radius**: 22pt (iOS widget standard, system-clipped).
- **Tap target**: whole widget → deep-link into the relevant feature.
- **Refresh**: `WidgetKit.reloadTimelines` on data change + scheduled boundary
  (next prayer time, midnight, etc.).
- **Locale**: respects app language (Arabic / English) independently of system locale.

---

## 1 · Prayer Widget (gated by `isPrayerEnabled`)

Mirrors the in-app prayer card's compact/expanded selection (widget-local state in the Flutter app, synced to the App Group's shared `UserDefaults` for the iOS widget to read). `UserSettings.prayerCardDisplayMode` is a separate concern — it controls *where* the card surfaces in-app, not which variant.

### 1a · Small (compact only)
- Top: Hijri date (primary) + city.
- Middle: next prayer name + time (`HH:MM`, mono).
- Bottom: countdown (`H:MM`).
- Background: forest gradient + glass.

### 1b · Medium (compact only)
- Left half: same as small.
- Right half: 4-pt vertical bar progress + "in 1h 23m" pill.

### 1c · Large (expanded)
- Top section: Hijri + Gregorian dual date, city.
- Middle: next prayer name + big time (`HH:MM`).
- Strip: 5 prayers (Fajr → Isha) with past/now/next/future states.
- Bottom: progress bar + sunrise/sunset markers.

### 1e · Post-prayer window
The prayer widget's "After {prayer}" state uses the **dynamic post-prayer window** —
not a fixed value. Formula (canonical source: `prayer_timer_service.dart:50–58`):
`round(0.3 × minutesBetween(prevPrayer, nextPrayer))`, clamp(15, 45) min,
with overrides applied **after** the clamp: Fajr = 40 min, Maghrib = 20 min.

Inputs already in the payload — no new keys required:
- `athar_prev_prayer_timestamp` (Unix epoch ms) → `prevPrayer.time`
- `athar_next_prayer_timestamp` (Unix epoch ms) → `nextPrayer.time`
- `athar_prev_prayer_name_en` (e.g. `"Fajr"`, `"Maghrib"`) → prayer type lookup

The widget must replicate the formula exactly so the "After Fajr" / "After Maghrib"
label and the in-app card flip at the same moment. (P9-C resolved 2026-06-02.)

---

## 2 · Habits Widget

### 2a · Small
- Today's completion ring (28pt diameter, `AppColors.success`).
- "{n}/{total}" inside.
- Below: "Habits today".

### 2b · Medium
- Left: ring + count.
- Right: 7-day streak grid (small dots, filled green = done).
- Bottom strip: top 3 habits with mini check-pills.

### 2c · Large
- Top: ring + "{n}/{total} · {streak} day streak".
- Below: full habits list (max 6) with check-pills, tappable per row.

---

## 3 · Focus Widget

### 3a · Small
- Today's focus minutes (large numeric mono).
- "minutes today" caption.
- Subtle progress ring around perimeter (vs daily goal).

### 3b · Medium
- Left: today's minutes + ring.
- Right: 7-day bar chart (`AppColors.amber`).

### 3c · Large
- Top: today's minutes + goal progress.
- Mid: 7-day chart with weekday labels.
- Bottom: "Start session" CTA → opens Focus screen with default duration.

---

## 4 · Configuration

User taps "Edit Widget" → choose:
- Variant (compact / expanded for Prayer).
- Theme (auto / light / dark).
- For Habits: which habits to show (max 6).

Stored in widget's own `UserDefaults` group (`group.app.athar.widgets`),
synced from main app via App Groups.

---

## 5 · Design tokens

iOS widgets cannot import Flutter directly. Generate a `WidgetTokens.swift`
file from `app_colors.dart` at build time:

```swift
extension Color {
  static let athaForest    = Color(hex: 0x0F3D2E)
  static let athaForestMid = Color(hex: 0x1A5A45)
  static let athaCream     = Color(hex: 0xEDE6C8)
  // …
}
```

Same for typography. Ensures perfect visual parity.

---

## 6 · States

- **Master toggle off** (`isPrayerEnabled = false`): widget renders an
  outline "Enable Prayer in Athar" prompt. Tap → opens app at Settings.
- **No data**: render skeleton.
- **Sync error**: render last-known data with small warning glyph in corner.
