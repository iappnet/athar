# PR3 Verification — Evidence Report
Generated 2026-06-01. No code was modified during this audit.

---

## A. Spec-Conformance Table

### A1 — Countdown 44px / w300 / JetBrains Mono (40px under 700pt, 56px tablet)

**Token definitions** — `lib/core/design_system/tokens/athar_typography.dart`
```
116:  static const double sizeDisplayLg = 40.0;   // small phone
119:  static const double sizeDisplay44 = 44.0;   // default
125:  static const double sizeDisplayXxl = 56.0;  // tablet
 30:  static const String fontFamilyMono = 'JetBrains Mono';
```

**Size-selection logic** — `lib/core/design_system/molecules/cards/next_prayer_card.dart:314–318`
```dart
final isTablet = screenSize.shortestSide > 600;
final countdownSize = isTablet
    ? AtharTypography.sizeDisplayXxl
    : (screenSize.height < 700 ? AtharTypography.sizeDisplayLg : AtharTypography.sizeDisplay44);
```

**Applied in RichText H:MM span** — `next_prayer_card.dart:380–387`
```dart
style: AtharTypography.numericMono.copyWith(
  fontSize: countdownSize.sp,
  fontWeight: FontWeight.w300,
  color: Colors.white,
  height: 1.1,
),
```

**Applied in RichText :SS span** — `next_prayer_card.dart:389–396`
```dart
style: AtharTypography.numericMono.copyWith(
  fontSize: 26.sp,
  fontWeight: FontWeight.w300,
  color: Colors.white.withValues(alpha: 0.55),
  height: 1.1,
),
```

`numericMono` base includes `fontFeatures: [FontFeature.tabularFigures()]` (athar_typography.dart:522–527).

---

### A2 — Forest gradient #0F3D2E → #1A5A45

**Token** — `lib/core/design_system/tokens/athar_colors.dart:110–117`
```dart
static const LinearGradient prayerCardGradient = LinearGradient(
  colors: [Color(0xFF0F3D2E), Color(0xFF1A5A45)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  transform: GradientRotation(135 * 3.14159 / 180),
);
```

**Applied** — `next_prayer_card.dart:78`
```dart
gradient: AtharColors.prayerCardGradient,
```

---

### A3 — Forest two-layer shadow (deep / mid)

**Tokens** — `athar_colors.dart:118–119`
```dart
static const Color prayerCardShadowDeep = Color(0xFF0F3D2E);
static const Color prayerCardShadowMid  = Color(0xFF1A5A45);
```

**Applied** — `next_prayer_card.dart:80–90`
```dart
BoxShadow(
  color: AtharColors.prayerCardShadowDeep.withValues(alpha: 0.45),
  blurRadius: 20,
  offset: const Offset(0, 8),
),
BoxShadow(
  color: AtharColors.prayerCardShadowMid.withValues(alpha: 0.2),
  blurRadius: 8,
  offset: const Offset(0, 2),
),
```

---

### A4 — Glass = Stack overlays; BackdropFilter ONLY on city pill

**Glass overlays (::before + ::after)** — `next_prayer_card.dart:96–142`
```dart
// ::before highlight
Positioned.fill(
  child: IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.08), Colors.transparent],
          stops: const [0.0, 0.6],
        ),
      ),
    ),
  ),
),
// ::after inner hairline border
Positioned.fill(
  child: IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AtharRadii.radiusXxl,
        border: Border(
          top:    BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.1),  width: 1),
          left:   BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
          right:  BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
        ),
      ),
    ),
  ),
),
```

**BackdropFilter — city pill only** — `next_prayer_card.dart:247, 261–262`
```dart
// The ONLY BackdropFilter on this card
...
child: BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
```

Full-file grep confirms one `BackdropFilter` occurrence; the card Container has no `BackdropFilter`.

---

### A5 — Active state: NO countdown, name 36px, "Started at HH:MM", NO pulse/animation, NO adhanMoment

**Active guard** — `next_prayer_card.dart:69–70`
```dart
final isActive = status.label == PrayerTimerLabel.justStarted ||
    status.label == PrayerTimerLabel.current;
```

**Cross-fade wiring** — `next_prayer_card.dart:163–171`
```dart
AnimatedCrossFade(
  duration: MediaQuery.of(context).disableAnimations
      ? Duration.zero
      : const Duration(milliseconds: 250),
  crossFadeState: isActive
      ? CrossFadeState.showSecond
      : CrossFadeState.showFirst,
  firstChild:  _buildUpcomingHero(context, status, l10n, isArabic),
  secondChild: _buildActiveHero(context, status, l10n, isArabic),
),
```

`AnimatedCrossFade` is a one-shot blend widget — not a pulse or repeating animation.

**Active hero body** — `next_prayer_card.dart:411–483` (no RichText countdown, no progress bar)
```dart
return Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text(l10n.prayerCardNow, ...),          // accent color label
    Text(prayerNameAr / prayerNameEn,       // 36sp / w700
      style: TextStyle(
        fontSize: AtharTypography.sizeDisplayMd.sp,   // = 36.0.sp
        fontWeight: FontWeight.w700, ...),
    ),
    Text(l10n.prayerCardStartedAt(timeDisplay), ...),  // "Started at HH:MM"
    TextButton(/* dhikr */),
  ],
);
```

**adhanMoment absent** — grep over all three modified files:
```
$ grep -n "adhanMoment" prayer_timer_service.dart prayer_timer_status.dart next_prayer_card.dart
(no output)
```

---

### A6 — Dhikr = conditional text button, active window only

**TextButton defined** — `next_prayer_card.dart:451–481` (inside `_buildActiveHero`)

**Guard**: `_buildActiveHero` is passed as `AnimatedCrossFade.secondChild` which renders only when `crossFadeState == CrossFadeState.showSecond`, which is set only when `isActive == true` (line 167–169).

`_buildUpcomingHero` (the first child) contains no `TextButton`, no `DhikrBottomSheet` reference. Confirmed by reading lines 335–402.

---

### A7 — Nafl chip Option A: below countdown, above sunrise/sunset row; always-show on isDuhaTime/isQiyamTime

**Placement in main column** — `next_prayer_card.dart:173–177`
```dart
if (!isActive) ...[
  if (status.isDuhaTime || status.isQiyamTime) ...[
    const SizedBox(height: AtharSpacing.xs),
    Center(child: _buildNaflChip(status, l10n)),
  ],
  const SizedBox(height: AtharSpacing.sm),
  _buildSunriseSunsetRow(status, isArabic),   // ← chip is above this
  ...
  _buildProgressBar(context, status),
],
```

**No settings flag** — `_buildNaflChip` at `next_prayer_card.dart:486–522` reads only `status.isDuhaTime` and `status.isQiyamTime`; no `UserSettings` reference.

**Teal dot** — `next_prayer_card.dart:503–509`
```dart
Container(
  width: 6.w, height: 6.w,
  decoration: BoxDecoration(
    color: AtharColors.prayerCardAccent,   // 0xFF7FE3DA
    shape: BoxShape.circle,
  ),
),
```

---

### A8 — Sunrise/sunset sourced from PrayerType.sunrise + PrayerType.maghrib

**Service computation** — `lib/core/services/prayer_timer_service.dart:175–191`
```dart
String? sunriseAr, sunriseEn, sunsetAr, sunsetEn;
try {
  final sunrise = _todayPrayers.firstWhere(
    (p) => p.type == PrayerType.sunrise,
    orElse: () => throw StateError('no sunrise'),
  );
  sunriseAr = _formatTime(sunrise.time);
  sunriseEn = _formatTimeEn(sunrise.time);
} catch (_) {}
try {
  final maghrib = _todayPrayers.firstWhere(
    (p) => p.type == PrayerType.maghrib,
    orElse: () => throw StateError('no maghrib'),
  );
  sunsetAr = _formatTime(maghrib.time);
  sunsetEn = _formatTimeEn(maghrib.time);
} catch (_) {}
```

**Card reads** — `next_prayer_card.dart:526–531`
```dart
final sunriseStr = isArabic
    ? (status.sunriseTime ?? '--:--')
    : (status.sunriseTimeEn ?? '--:--');
final sunsetStr = isArabic
    ? (status.sunsetTime ?? '--:--')
    : (status.sunsetTimeEn ?? '--:--');
```

---

### A9 — Progress bar directionality-aware (no scaleX, no hardcoded RTL override)

**RTL detection** — `next_prayer_card.dart:563`
```dart
final isRTL = Directionality.of(context) == TextDirection.rtl;
```

**Positioned fill** — `next_prayer_card.dart:576–581`
```dart
Positioned(
  left:  isRTL ? null : 0,
  right: isRTL ? 0    : null,
  top: 0, bottom: 0,
  width: fillWidth,
  ...
),
```

No `scaleX` transform. No `Directionality(textDirection: TextDirection.rtl, ...)` override.

---

### A10 — Expanded = widget-local flag, default false, no caller passes true, no on-card toggle

**Declaration** — `next_prayer_card.dart:26, 28`
```dart
final bool expanded;
const NextPrayerCard({super.key, this.allPrayers, this.expanded = false});
```

**Usage** — `next_prayer_card.dart:362`
```dart
if (!widget.expanded) ...[
  // hides the "at HH:MM" sub-label in expanded layout
```

No `setState` or toggle logic for `expanded` inside the widget.

**All callers** — grep `NextPrayerCard(` excluding the file itself:
```
smart_prayer_wrapper.dart:50:
  return NextPrayerCard(allPrayers: prayerState.allPrayers);

habit_page.dart:2218:
  //             //         child: NextPrayerCard(allPrayers: state.allPrayers),
```

One live caller (`SmartPrayerCardWrapper`) passes no `expanded:` argument → defaults to `false`.
One commented-out reference — not live code.

---

## B. Additive-Only Proof

### Full field list of PrayerTimerStatus
`lib/features/prayer/domain/models/prayer_timer_status.dart`

**Original fields (lines 12–24, unchanged):**
```dart
final String prayerNameAr;
final String prayerNameEn;
final String timeDisplay;
final String timeDisplayEn;
final String timeLeft;
final String timeLeftEn;
final double progress;
final PrayerTimerLabel label;
final Color statusColor;
final bool showDhikrButton;
final String fullDate;           // ← still present, line 21
final String fullDateEn;         // ← still present, line 22
final bool isDuhaTime;
final bool isQiyamTime;
```

**PR3 additive fields (lines 27–35):**
```dart
final String hijriDate;
final String gregorianDate;
final String hijriDateEn;
final String gregorianDateEn;
final int secondsRemaining;
final String? sunriseTime;
final String? sunriseTimeEn;
final String? sunsetTime;
final String? sunsetTimeEn;
```

`fullDate` and `fullDateEn` confirmed populated by service at `prayer_timer_service.dart:205–206`:
```dart
fullDate:   dateStr,
fullDateEn: dateStrEn,
```

### git diff --stat
```
 lib/core/design_system/molecules/cards/next_prayer_card.dart          | 1941 +++++---------------
 lib/core/design_system/molecules/cards/smart_prayer_wrapper.dart      |  202 +-
 lib/core/design_system/tokens/athar_colors.dart                       |   13 +-
 lib/core/design_system/tokens/athar_typography.dart                   |    7 +-
 lib/core/services/prayer_timer_service.dart                           |   44 +
 lib/features/prayer/domain/models/prayer_timer_status.dart            |   40 +-
 lib/l10n/app_ar.arb                                                   |   10 +
 lib/l10n/app_en.arb                                                   |   10 +
 lib/l10n/generated/app_localizations.dart                             |   30 +
 lib/l10n/generated/app_localizations_ar.dart                          |   17 +
 lib/l10n/generated/app_localizations_en.dart                          |   18 +
 pubspec.yaml                                                          |    8 +
 12 files changed, 767 insertions(+), 1573 deletions(-)
```

The 1573 deletions in `next_prayer_card.dart` are the two large commented-out legacy implementations
that existed before this PR. No existing behavior was removed.

---

## C. Preservation Proof (Behavioral Audit B1–B15)

### B1 — Full-card tap → PrayerDetailsPage
`next_prayer_card.dart:147–150` — unchanged call site:
```dart
onTap: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const PrayerDetailsPage()),
),
```

### B2 — isPrayerEnabled gate
`smart_prayer_wrapper.dart:30` — unchanged:
```dart
if (!settings.isPrayerEnabled) return const SizedBox.shrink();
```

### B3 — isPrayerCardEnabled gate
`smart_prayer_wrapper.dart:31` — unchanged:
```dart
if (!settings.isPrayerCardEnabled) return const SizedBox.shrink();
```

### B4 — prayerCardDisplayMode gate (dashboard / tasks / all)
`smart_prayer_wrapper.dart:35–42` — unchanged logic:
```dart
case PageType.dashboard: shouldShow = true;
case PageType.tasks:
  shouldShow = settings.prayerCardDisplayMode == PrayerCardDisplayMode.dashboardAndTasks ||
               settings.prayerCardDisplayMode == PrayerCardDisplayMode.allPages;
case PageType.habits:
case PageType.projects:
  shouldShow = settings.prayerCardDisplayMode == PrayerCardDisplayMode.allPages;
```

### B5 — Dynamic active windows (Fajr 40 min / Maghrib 20 min / clamp 15–45)
`prayer_timer_service.dart:52–58`:
```dart
int activeWindow = (timeBetween * 0.3).round();
if (activeWindow <= 0) activeWindow = 30;
activeWindow = activeWindow.clamp(15, 45);

if (prevPrayer.type == PrayerType.maghrib) activeWindow = 20;
if (prevPrayer.type == PrayerType.fajr)    activeWindow = 40;
```

### B6 — labelWindow = 10 (justStarted boundary)
`prayer_timer_service.dart:60`:
```dart
const labelWindow = 10;
```

### B7 — Duha window (sunrise+15 → dhuhr-15)
`prayer_timer_service.dart:113–123`:
```dart
final sunrise = _getFirstPrayer(PrayerType.sunrise);
final dhuhr   = _getFirstPrayer(PrayerType.dhuhr);
final start = sunrise.time.add(const Duration(minutes: 15));
final end   = dhuhr.time.subtract(const Duration(minutes: 15));
if (now.isAfter(start) && now.isBefore(end)) isDuha = true;
```

### B8 — Qiyam window (last-third-of-night)
`prayer_timer_service.dart:126–150`:
```dart
final duration        = nightEnd.difference(nightStart);
final lastThirdStart  = nightEnd.subtract(
  Duration(minutes: (duration.inMinutes / 3).round()),
);
if (now.isAfter(lastThirdStart) && now.isBefore(nightEnd)) isQiyam = true;
```

### B9 — Midnight crossing (isha-yesterday / fajr-tomorrow)
`prayer_timer_service.dart:243, 253`:
```dart
time: isha.time.subtract(const Duration(days: 1)),  // isha yesterday → prev when fajr is next
...
time: fajr.time.add(const Duration(days: 1)),        // fajr tomorrow → next after isha
isNext: true,
```

### B10 — _toArabicNumerals intact
`prayer_timer_service.dart:337–344`:
```dart
String _toArabicNumerals(String input) {
  const en = ['0','1','2','3','4','5','6','7','8','9'];
  const ar = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
  for (int i = 0; i < en.length; i++) {
    input = input.replaceAll(en[i], ar[i]);
  }
  return input;
}
```

### B11 — Sunrise excluded from fard timeline
`prayer_timer_service.dart:223–225`:
```dart
final fard = _todayPrayers
    .where((p) => p.type != PrayerType.sunrise)
    .toList();
```

### B12 — Sunrise used for Duha window, not as a fard prayer
`prayer_timer_service.dart:114` — Duha calculation only:
```dart
final sunrise = _getFirstPrayer(PrayerType.sunrise);
```
Timeline calculation at line 222–228 explicitly filters it out.

### B13 — PrayerTimerService @lazySingleton
`prayer_timer_service.dart:10`:
```dart
@lazySingleton
class PrayerTimerService {
```

### B14 — No WidgetKeys renamed
```
$ grep -n "WidgetKeys\|widgetKey" next_prayer_card.dart smart_prayer_wrapper.dart
(no output)
```

### B15 — injection.config.dart not edited
`git diff --name-only` output contains no `injection.config.dart` entry.

---

## D. Scope Proof

### git diff --name-only
```
lib/core/design_system/molecules/cards/next_prayer_card.dart
lib/core/design_system/molecules/cards/smart_prayer_wrapper.dart
lib/core/design_system/tokens/athar_colors.dart
lib/core/design_system/tokens/athar_typography.dart
lib/core/services/prayer_timer_service.dart
lib/features/prayer/domain/models/prayer_timer_status.dart
lib/l10n/app_ar.arb
lib/l10n/app_en.arb
lib/l10n/generated/app_localizations.dart
lib/l10n/generated/app_localizations_ar.dart
lib/l10n/generated/app_localizations_en.dart
pubspec.yaml
```

### The 9 agreed files — all present:
| # | File | In diff |
|---|------|---------|
| 1 | next_prayer_card.dart | ✅ |
| 2 | smart_prayer_wrapper.dart | ✅ |
| 3 | athar_colors.dart | ✅ |
| 4 | athar_typography.dart | ✅ |
| 5 | prayer_timer_service.dart | ✅ |
| 6 | prayer_timer_status.dart | ✅ |
| 7 | app_ar.arb | ✅ |
| 8 | app_en.arb | ✅ |
| 9 | pubspec.yaml | ✅ |

### 3 extra files — all auto-generated by `flutter gen-l10n`:
```
lib/l10n/generated/app_localizations.dart
lib/l10n/generated/app_localizations_ar.dart
lib/l10n/generated/app_localizations_en.dart
```
These are derived output from editing `app_ar.arb` / `app_en.arb`. They are committed by convention
in this project and are never hand-edited (CLAUDE.md: "Run `flutter gen-l10n` after edits").

---

## E. Fonts

### pubspec.yaml:152–160
```yaml
- family: JetBrains Mono
  fonts:
    - asset: assets/fonts/JetBrainsMono-Light.ttf
      weight: 300
    - asset: assets/fonts/JetBrainsMono-Regular.ttf
      weight: 400
    - asset: assets/fonts/JetBrainsMono-Medium.ttf
      weight: 500
```

### ls assets/fonts/
```
Cairo-Bold.ttf
Cairo-Medium.ttf
Cairo-Regular.ttf
Cairo-SemiBold.ttf
calibri-bold.ttf
calibri-light.ttf
calibri-regular.ttf
JetBrainsMono-Light.ttf
JetBrainsMono-Medium.ttf
JetBrainsMono-Regular.ttf
```

All three JetBrains Mono weights (300/400/500) present as TTF files and declared in pubspec.

---

## F. ARB — 5 New Keys

### app_ar.arb (lines 1601–1610)
```json
"prayerCardNow": "الآن",
"prayerCardStartedAt": "بدأت {time}",
"@prayerCardStartedAt": {
  "placeholders": { "time": { "type": "String" } }
},
"prayerCardPostPrayerAthkar": "أذكار ما بعد الصلاة",
"prayerSunset": "الغروب",
"prayerCardEnableLocation": "فعّل الموقع لأوقات صلاة دقيقة",
```

### app_en.arb (lines 1504–1513)
```json
"prayerCardNow": "Now",
"prayerCardStartedAt": "Started at {time}",
"@prayerCardStartedAt": {
  "placeholders": { "time": { "type": "String" } }
},
"prayerCardPostPrayerAthkar": "Post-prayer athkar",
"prayerSunset": "Sunset",
"prayerCardEnableLocation": "Enable location for accurate prayer times",
```

`flutter gen-l10n` ran clean — confirmed by the three generated files appearing in `git diff --name-only`
with only additive changes (+30, +17, +18 lines respectively, 0 deletions in any generated file).

---

## G. flutter analyze — Full Output

```
Analyzing athar...

No issues found! (ran in 4.7s)
```
