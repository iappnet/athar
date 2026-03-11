import 'dart:ui'; // للألوان

class PrayerTimerStatus {
  final String prayerName;
  final String timeDisplay; // مثلا "3:45 م"
  final String timeLeft; // العداد التنازلي
  final double progress; // من 0.0 إلى 1.0
  final String statusLabel; // "الصلاة القادمة" أو "حان الآن"
  final Color statusColor;
  final bool showDhikrButton;
  final String fullDate; // التاريخ الهجري والميلادي

  // ✅ حقول جديدة للنوافذ الزمنية
  final bool isDuhaTime; // هل نحن في وقت الضحى؟
  final bool isQiyamTime; // هل نحن في وقت قيام الليل؟

  PrayerTimerStatus({
    required this.prayerName,
    required this.timeDisplay,
    required this.timeLeft,
    required this.progress,
    required this.statusLabel,
    required this.statusColor,
    required this.showDhikrButton,
    required this.fullDate,
    this.isDuhaTime = false,
    this.isQiyamTime = false,
  });

  // حالة فارغة أولية
  factory PrayerTimerStatus.initial() {
    return PrayerTimerStatus(
      prayerName: "...",
      timeDisplay: "--:--",
      timeLeft: "--:--:--",
      progress: 0,
      statusLabel: "جاري التحميل...",
      statusColor: const Color(0xFFFFC107), // Amber
      showDhikrButton: false,
      fullDate: "",
      isDuhaTime: false,
      isQiyamTime: false,
    );
  }
}
