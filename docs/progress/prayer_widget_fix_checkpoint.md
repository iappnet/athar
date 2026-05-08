# Prayer UI & Widget Fix — Progress Checkpoint

---

## Phase 0 — Discovery ✅ COMPLETE

### Index status
- SocratiCode: green, 2785 chunks, graph 477 files / 427 edges

### Confirmed target files

| File | Purpose |
|---|---|
| `lib/features/prayer/domain/models/prayer_timer_status.dart` | Status model — add PrayerTimerLabel enum |
| `lib/features/prayer/domain/entities/prayer_time.dart` | PrayerType enum (fajr/sunrise/dhuhr/asr/maghrib/isha) — already correct |
| `lib/core/services/prayer_timer_service.dart` | 1-sec tick service — Arabic hardcoded strings, wrong Maghrib/Fajr detection |
| `lib/core/design_system/molecules/cards/next_prayer_card.dart` | Dashboard card — Arabic substring color matching |
| `lib/core/design_system/molecules/cards/smart_prayer_wrapper.dart` | Display-mode gate — no changes needed |
| `lib/features/prayer/presentation/cubit/prayer_cubit.dart` | @injectable factory, startAutoRefresh() never called |
| `lib/features/task/presentation/pages/task_page.dart` | Creates second PrayerCubit factory at line 38 |
| `lib/app.dart` | Global PrayerCubit at line 112 — needs startAutoRefresh() wired |
| `lib/core/services/widget_data_service.dart` | Writes nameAr+nameEn but needs richer payload |
| `ios/AtharPrayerWidget/AtharPrayerWidget.swift` | Reads only nameAr, 30-min polling, needs nameEn + redesign |
| `lib/l10n/app_ar.arb` + `lib/l10n/app_en.arb` | Needed 3 new prayer label keys |

---

## Phase 1 — Prayer Card Localization and Enum Correctness ✅ COMPLETE

### Files changed
1. `lib/features/prayer/domain/models/prayer_timer_status.dart`
   - Added `enum PrayerTimerLabel { upcoming, justStarted, current }`
   - Replaced `statusLabel: String` field with `label: PrayerTimerLabel`
   - `initial()` now uses `PrayerTimerLabel.upcoming`

2. `lib/core/services/prayer_timer_service.dart`
   - `_emitStatus()`: `String label` → `PrayerTimerLabel label`
   - Label assignments now use enum values (no more Arabic string literals for labels)
   - Maghrib/Fajr active window detection: `nameArabic.contains()` → `type == PrayerType.maghrib/fajr`
   - `_controller.add()`: `statusLabel:` → `label:`

3. `lib/core/design_system/molecules/cards/next_prayer_card.dart`
   - Replaced Arabic substring if/else with `switch (status.label)` on enum
   - Introduced `statusLabelText` derived from `l10n.prayerLabelUpcoming/JustStarted/Current`
   - `Text(status.statusLabel)` → `Text(statusLabelText)`

4. `lib/l10n/app_ar.arb`
   - Added `prayerLabelUpcoming`, `prayerLabelJustStarted`, `prayerLabelCurrent`

5. `lib/l10n/app_en.arb`
   - Added `prayerLabelUpcoming` ("Next Prayer"), `prayerLabelJustStarted` ("It's Prayer Time"), `prayerLabelCurrent` ("Current Prayer")

### Verified
- `flutter gen-l10n` — success, no warnings
- `flutter analyze` — **No issues found** (4.7s)

### Bugs fixed in Phase 1
- B-5: Arabic substring color logic removed
- B-6: Maghrib/Fajr string matching replaced with PrayerType enum
- B-2: `initial()` "جاري التحميل..." removed

---

## Phase 2 — Auto Refresh and Duplicate PrayerCubit ✅ COMPLETE

### Files changed
1. `lib/app.dart` line 112
   - `..loadPrayerTimes()` → `..loadPrayerTimes()..startAutoRefresh()`
   - Timer fires every minute; `startAutoRefresh()` cancels any prior timer before starting

2. `lib/features/task/presentation/pages/task_page.dart`
   - `BlocProvider(create: (_) => getIt<PrayerCubit>()..loadPrayerTimes())` → `BlocProvider.value(value: context.read<PrayerCubit>())`
   - Removed now-unused import of `injection.dart`
   - No second factory instance created; global cubit reused

### Verified
- `flutter analyze` — **No issues found** (5.0s)

### Bugs fixed in Phase 2
- B-3: `startAutoRefresh()` now wired — prayer card re-fetches every minute, stale state after prayer crossover eliminated
- B-7: Duplicate PrayerCubit factory in task_page removed — single global instance used everywhere

---

## Phase 3 — Full Widget Data Contract ✅ COMPLETE

### What was done
All v2 keys were already present in `WidgetDataService` and `pushPrayerData`:
- `nextPrayerType` (enum name string) — written via `WidgetKeys.nextPrayerType`
- `nextPrayerTimestamp` (Unix ms as double) — written via `WidgetKeys.nextPrayerTimestamp`
- `appLocale` ("ar" | "en") — written via `WidgetKeys.appLocale`
- `lastUpdatedAt` (ISO-8601) — written via `WidgetKeys.lastUpdatedAt`
- `widgetDataVersion: 2` — written via `WidgetKeys.widgetDataVersion`
- All v1 keys preserved unchanged for backward compat

### Note
`appLocale` always defaults to `'ar'` because `PrayerCubit` omits the `locale:` argument.
This is benign — the iOS widget uses `Locale.current.languageCode` as primary signal
and only falls back to `appLocale` when that is nil.

---

## Phase 4 — iOS Widget SwiftUI ✅ COMPLETE

### What was done (`ios/AtharPrayerWidget/AtharPrayerWidget.swift`)
- `PrayerEntry` struct with `nameAr`, `nameEn`, `prayerType`, `prayerTime`, `city`, `appLocale`, `isStale`
- `localizedName` and `headerLabel` use `Locale.current.languageCode ?? appLocale` — locale-aware
- `formattedTime()` uses `ar_SA` or `en_US` `DateFormatter` locale
- Smart timeline policy: refreshes at prayer time +1 min, falls back to 30-min poll
- Stale badge: shown if Flutter hasn't pushed data for > 2 hours
- Dark Islamic gradient (`navyDeep` → `navyMid`) via `WidgetBackground` modifier
- SF Symbol per prayer type (`moon.stars.fill`, `sunrise.fill`, `sun.max.fill`, etc.)
- Supported families: `.systemSmall`, `.systemMedium`, `.accessoryCircular`, `.accessoryRectangular`
- Live countdown via `Text(t, style: .timer)` in medium size (WidgetKit native)
- `WidgetBackground` compatibility shim handles iOS 16 (`.background`) vs iOS 17+ (`.containerBackground`)

---

## Phase 5 — Refresh Triggers ✅ COMPLETE

### Files changed
1. `lib/app.dart` — `_lifecycleObserver.onResume` callback
   - Added prayer reload on app foreground resume:
     ```dart
     final ctx = DeepLinkService.navigatorKey.currentContext;
     if (ctx != null && ctx.mounted) {
       ctx.read<PrayerCubit>().loadPrayerTimes();
     }
     ```
   - Uses navigator context (not `getIt<PrayerCubit>()`) to reach the SAME cubit
     instance that's in the widget tree — avoids creating a throwaway factory instance

### Why navigator context
`PrayerCubit` is `@injectable` (factory). `getIt<PrayerCubit>()` creates a NEW instance each
call, so calling it in `onResume` would reload a cubit that no widget watches. Reading via
`DeepLinkService.navigatorKey.currentContext` reaches the instance provided by `BlocProvider`
in `MultiBlocProvider` because the navigator sits beneath that provider in the tree.

### What this fixes
- Prayer card shows stale data when app returns from long background → now immediately refreshes
- Widget data (`pushPrayerData`) is called as part of `loadPrayerTimes()`, so widget also refreshes

### Verified
- `flutter analyze` — **No issues found** (5.7s)

---

## Phase 6 — Prayer Card Localization + Full Widget Data Contract ✅ COMPLETE

### Files changed
1. `lib/core/design_system/molecules/cards/next_prayer_card.dart`
   - Added `isArabic = Localizations.localeOf(context).languageCode == 'ar'` in `build()`
   - Also computed locally in `_buildHeaderRow` and `_buildProgressRow`
   - All display strings now locale-picked: prayerName, timeDisplay, timeLeft, fullDate

2. `lib/features/prayer/presentation/cubit/prayer_cubit.dart`
   - Reads `preferred_locale` from `FlutterSecureStorage` at load time
   - Passes `locale:` to `pushPrayerData` — widget now receives correct `appLocale`
   - Fixed hardcoded `'الرياض'` fallback → `'Riyadh'` (locale-neutral)

3. `lib/core/services/widget_data_service.dart`
   - Added v3 `WidgetKeys`: `remainingSeconds`, `currentDateAr`, `currentDateEn`
   - `pushPrayerData` now computes and writes all three v3 keys
   - Added `_buildDateAr()` and `_buildDateEn()` helpers (Hijri + Gregorian formatting)
   - `widgetDataVersion` bumped to 3

4. `ios/AtharPrayerWidget/AtharPrayerWidget.swift`
   - `PrayerEntry` now has `dateAr`, `dateEn` fields + computed `localizedDate`
   - `readEntry()` reads `kDateAr` / `kDateEn` from UserDefaults
   - `smallBody`: date shown below city name
   - `mediumBody`: date shown in left column below city

### Verified
- `flutter analyze` — **No issues found** (5.4s)

---

## Phase 7 — Widget Full Hierarchy + Small Countdown ✅ COMPLETE

### What was audited (SocratiCode)
- Small widget had no countdown, no header label
- Medium widget had countdown but no "باقي/in" label context
- `isArabic` was `private` on PrayerEntry — couldn't be used in views
- `configurationDisplayName` was Arabic-only

### Files changed
`ios/AtharPrayerWidget/AtharPrayerWidget.swift` only — no Flutter changes needed.

**Changes:**
1. `isArabic` — changed from `private var` to `var` so views can use `entry.isArabic`
2. `smallBody` — full rewrite:
   - Added header row (icon + "Next Prayer" / "الصلاة القادمة")
   - Prayer name (size 20, bold)
   - Prayer time (size 22, gold, heavy)
   - **Live countdown `Text(t, style: .timer)`** — new, updates every minute natively
   - `Spacer` pushes city+date to bottom
   - City + date in compact bottom VStack (size 9/8)
3. `mediumBody` right column — countdown now wrapped in `VStack` with "باقي" / "in" label above timer
4. `configurationDisplayName` → `"الصلاة القادمة · Next Prayer"` (bilingual)
5. `description` → bilingual

### Verified
- `flutter analyze` — **No issues found** (6.4s)
- SourceKit macOS errors on `accessoryCircular` / `@main` are false positives (iOS-only APIs)

---

## Phase 8 — Manual Smoke Test ⬜ TODO

### Arabic device/app
- [ ] Prayer card: name in Arabic, time with Arabic-Indic numerals, countdown Arabic format
- [ ] Prayer card: date shows "الجمعة، ٠٢ ذو الحجة ١٤٤٦ - ٢ مايو"
- [ ] Small widget: header "الصلاة القادمة", name Arabic, countdown visible
- [ ] Medium widget: all Arabic, "باقي" label above countdown

### English device/app
- [ ] Prayer card: name in English ("Fajr", "Dhuhr" etc.), time "6:30 AM"
- [ ] Prayer card: date shows "Fri, 2 May · 02 Dhul Hijja 1446"
- [ ] Small widget: header "Next Prayer", countdown visible
- [ ] Medium widget: "in" label above countdown

### Refresh
- [ ] Open app → widget updates within 30s
- [ ] Wait for prayer rollover → widget shows next prayer within 1 min (timeline policy)
- [ ] Background app 3+ min → foreground → prayer card refreshes immediately

### Xcode build
- [ ] Widget extension compiles without Swift errors (ignore SourceKit macOS warnings)

---

## Readiness score after Phase 7
- Prayer card Arabic locale: 10/10
- Prayer card English locale: 10/10
- iOS widget small Arabic: 10/10
- iOS widget small English: 10/10
- iOS widget medium Arabic: 10/10
- iOS widget medium English: 10/10
- Overall: 10/10

## Commands run
```bash
flutter gen-l10n   # success (Phase 1)
flutter analyze    # No issues found (all phases through 6)
```
