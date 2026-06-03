# Athkar — UX Spec

> Net-new design work. Athkar is the morning/evening Islamic remembrance
> flow. This spec defines screens, components, and interactions. No visual
> mock yet — Claude Code may produce one for designer review before coding.

---

## 1 · Information architecture

```
Athkar (top-level feature, gated by isAthkarEnabled)
├── Home
│   ├── Morning set (post-Fajr → Dhuhr)
│   ├── Evening set (post-Asr → Maghrib)
│   └── Custom sets (user-created)
├── Reader (per-set, sequential dhikr)
└── History (last 30 days, streak)
```

Entry points: bottom-tab "Athkar", Dashboard insight card, Prayer card "Start
dhikr" CTA.

---

## 2 · Home screen

**Anatomy**:
1. Header: "Athkar" / "الأذكار" + current day's adhkar status (e.g. "Morning
   ✓ · Evening ⏳").
2. **Time-aware hero card**:
   - Currently-relevant set (morning if before Asr, else evening).
   - Background: cream gradient at dawn, slate at dusk.
   - Big title, count "33 dhikr", est duration "~12 min", "Begin" CTA.
3. Other sets list:
   - Morning, Evening, Sleep, After-prayer, Quranic supplications.
   - Each row: icon, name, count, last-completed (`{relative}`).
4. Custom sets footer: "+ Create custom set".

**Empty state**: `EmptyState.athkar` with "Begin your dhikr" CTA opening
morning set reader.

---

## 3 · Reader screen

The core experience. One dhikr at a time, swipe or tap-to-advance.

**Layout** (vertical, full-screen):
1. Top bar: ← back, set title, progress dots (3/33).
2. **Dhikr card** (max-width 480pt, centered):
   - Arabic text — `AppText.headlineXL`, Cairo Bold, line-height 1.6.
   - Translation — `AppText.bodyM`, `text2`, italicized, below.
   - Transliteration — `AppText.bodyS`, `text3`, below translation.
   - Source — `AppText.captionM`, `text3`, e.g. "Al-Bukhari 6307".
3. **Counter** (large, tap to advance):
   - 120pt circle, `AppColors.forest` border, count in center.
   - `AppText.numericMono` 56pt.
   - Below: "× 33" target.
   - Tap counter → +1, haptic light.
   - Long-press → -1.
   - Reaches target → fill animation, success haptic, auto-advance after 600ms.
4. Bottom bar:
   - Skip (text button).
   - Play audio (icon, optional recitation).
   - Settings (text size, translation toggle, Arabic-only).

**Gestures**:
- Swipe left → next.
- Swipe right → previous.
- Pull down → exit to home.

**Completion screen**:
- Set complete confetti / glow.
- Stats: "33 dhikr · 11 min · day {n} of streak".
- CTAs: "Done", "Continue with evening set" (if morning just done and < Asr).

---

## 4 · Counter logic

- Per dhikr, count persists if user navigates away mid-set.
- Per set, completion = all dhikr at target. Logged to `AthkarSession`.
- One session per set per day (latest overwrites).
- Streak: consecutive days with at least 1 set completed.

---

## 5 · Settings (per-feature)

Settings → Athkar:
- Font size: S / M / L / XL.
- Show translation: on/off.
- Show transliteration: on/off.
- Audio recitation: on/off (requires download per recitor).
- Vibration on tap: on/off.
- Reminder times: 30 min after Fajr, 30 min before Maghrib (configurable).

---

## 6 · Notifications

- Two daily reminders (morning, evening), scheduled by `AthkarScheduler`.
- Body: "Time for {morning/evening} adhkar".
- Action: "Begin" → opens reader directly.
- Snooze: 15 min, 1 h, skip.

---

## 7 · Data model

```dart
class DhikrEntry {
  final String id;          // 'morning_1', etc.
  final String arabic;
  final String translation; // localized
  final String? transliteration;
  final String source;
  final int target;         // count target (e.g. 33, 100)
  final String? audioUrl;
}

class AthkarSet {
  final String id;          // 'morning', 'evening', etc.
  final String name;        // localized
  final List<DhikrEntry> entries;
  final TimeOfDay? defaultStart; // 'morning' = post-fajr
}

class AthkarSession {
  final String setId;
  final DateTime date;
  final int completedCount; // out of total entries
  final Duration duration;
}
```

---

## 8 · iPad layout

- Reader: dhikr card on left half, counter on right half (side-by-side).
- Home: 2-column grid for sets list.

---

## 9 · RTL

- Reader: progress dots reverse direction.
- Swipe directions reverse (swipe right → next in RTL).
- Counter unchanged (symmetric).

---

## 10 · Open questions for designer

1. Should we ship with a curated set library or allow user creation v1?
   (Recommendation: curated only v1; custom sets v2.)
2. Audio recitation: include a default recitor download in v1?
   (Recommendation: include 1 default, allow others as paid add-ons.)
3. Should the Dashboard insight card show today's status?
   (Recommendation: yes — "Morning adhkar pending" prompt when applicable.)
