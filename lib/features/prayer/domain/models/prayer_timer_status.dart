import 'dart:ui';

/// Semantic label for the current prayer window.
/// The UI layer maps this to the appropriate localized string via AppLocalizations.
enum PrayerTimerLabel {
  upcoming,     // Counting down to the next obligatory prayer
  justStarted,  // Within the first ~10 min after prayer time
  current,      // Active prayer window, past the just-started window
}

/// All string fields are stored in both Arabic and English variants so that
/// the UI layer can pick the correct one based on the current app locale
/// without requiring BuildContext inside the service.
class PrayerTimerStatus {
  final String prayerNameAr;      // e.g. "الفجر"
  final String prayerNameEn;      // e.g. "Fajr"
  final String timeDisplay;       // Prayer time — Arabic-Indic numerals (for ar locale)
  final String timeDisplayEn;     // Prayer time — Latin numerals (for en locale)
  final String timeLeft;          // Countdown/elapsed — Arabic text + Arabic-Indic numerals
  final String timeLeftEn;        // Countdown/elapsed — English text + Latin numerals
  final double progress;
  final PrayerTimerLabel label;
  final Color statusColor;
  final bool showDhikrButton;
  final String fullDate;          // Full date — Arabic (Hijri + Gregorian)
  final String fullDateEn;        // Full date — English (Hijri + Gregorian)
  final bool isDuhaTime;
  final bool isQiyamTime;

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
