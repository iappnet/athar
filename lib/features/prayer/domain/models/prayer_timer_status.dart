import 'dart:ui';

/// Semantic label for the current prayer window.
enum PrayerTimerLabel {
  upcoming,     // Counting down to the next obligatory prayer
  justStarted,  // Within the first ~10 min after prayer time
  current,      // Active prayer window, past the just-started window
}

class PrayerTimerStatus {
  final String prayerNameAr;
  final String prayerNameEn;
  final String timeDisplay;       // Prayer time — Arabic-Indic numerals (ar)
  final String timeDisplayEn;     // Prayer time — Latin numerals (en)
  final String timeLeft;          // Countdown/elapsed — Arabic text + numerals
  final String timeLeftEn;        // Countdown/elapsed — English text + numerals
  final double progress;
  final PrayerTimerLabel label;
  final Color statusColor;
  final bool showDhikrButton;
  final String fullDate;          // Full combined date — Arabic
  final String fullDateEn;        // Full combined date — English
  final bool isDuhaTime;
  final bool isQiyamTime;

  // PR3 additive fields — never remove the fields above
  final String hijriDate;         // Hijri date only — Arabic e.g. "١٥ رجب ١٤٤٦"
  final String gregorianDate;     // Gregorian date only — Arabic e.g. "الأربعاء، 15 يناير"
  final String hijriDateEn;       // Hijri date only — English e.g. "15 Rajab 1446"
  final String gregorianDateEn;   // Gregorian date only — English e.g. "Wed, 15 Jan"
  final int secondsRemaining;     // Raw seconds until next prayer (clamped ≥ 0); 0 in active state
  final String? sunriseTime;      // Formatted sunrise time (ar locale) or null if unavailable
  final String? sunriseTimeEn;    // Formatted sunrise time (en locale) or null
  final String? sunsetTime;       // Formatted sunset/Maghrib time (ar locale) or null
  final String? sunsetTimeEn;     // Formatted sunset/Maghrib time (en locale) or null

  PrayerTimerStatus({
    required this.prayerNameAr,
    required this.prayerNameEn,
    required this.timeDisplay,
    required this.timeDisplayEn,
    required this.timeLeft,
    required this.timeLeftEn,
    required this.progress,
    required this.label,
    required this.statusColor,
    required this.showDhikrButton,
    required this.fullDate,
    required this.fullDateEn,
    this.isDuhaTime = false,
    this.isQiyamTime = false,
    this.hijriDate = '',
    this.gregorianDate = '',
    this.hijriDateEn = '',
    this.gregorianDateEn = '',
    this.secondsRemaining = 0,
    this.sunriseTime,
    this.sunriseTimeEn,
    this.sunsetTime,
    this.sunsetTimeEn,
  });

  factory PrayerTimerStatus.initial() {
    return PrayerTimerStatus(
      prayerNameAr: '...',
      prayerNameEn: '...',
      timeDisplay: '--:--',
      timeDisplayEn: '--:--',
      timeLeft: '--:--:--',
      timeLeftEn: '--:--:--',
      progress: 0,
      label: PrayerTimerLabel.upcoming,
      statusColor: const Color(0xFFFFC107),
      showDhikrButton: false,
      fullDate: '',
      fullDateEn: '',
      isDuhaTime: false,
      isQiyamTime: false,
    );
  }
}
