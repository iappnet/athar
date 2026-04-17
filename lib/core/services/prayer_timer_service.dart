import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:injectable/injectable.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../features/prayer/domain/entities/prayer_time.dart';
import '../../features/prayer/domain/models/prayer_timer_status.dart';

@lazySingleton
class PrayerTimerService {
  final _controller = StreamController<PrayerTimerStatus>.broadcast();
  Stream<PrayerTimerStatus> get timerStream => _controller.stream;

  Timer? _ticker;
  List<PrayerTime> _todayPrayers = [];

  PrayerTimerService();

  void startTimer(List<PrayerTime> prayers) {
    prayers.sort((a, b) => a.time.compareTo(b.time));
    _todayPrayers = prayers;

    _ticker?.cancel();
    _emitStatus();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _emitStatus());
  }

  void stopTimer() {
    _ticker?.cancel();
  }

  void dispose() {
    _controller.close();
    _ticker?.cancel();
  }

  void _emitStatus() {
    if (_todayPrayers.isEmpty) return;

    final now = DateTime.now();

    final timeline = _calculateTimeline(now);
    final prevPrayer = timeline['prev']!;
    final nextPrayer = timeline['next']!;

    final minutesSincePrev = now.difference(prevPrayer.time).inMinutes;

    // ✅ activeWindow ديناميكي
    final timeBetween = nextPrayer.time.difference(prevPrayer.time).inMinutes;

    int activeWindow = (timeBetween * 0.3).round();

    if (activeWindow <= 0) activeWindow = 30;
    activeWindow = activeWindow.clamp(15, 45);

    // حالات خاصة (باستخدام النص لأن المصدر عربي)
    if (prevPrayer.nameArabic.contains("المغرب")) {
      activeWindow = 20;
    }
    if (prevPrayer.nameArabic.contains("الفجر")) {
      activeWindow = 40;
    }

    const labelWindow = 10;

    PrayerTime displayPrayer;
    String label;
    Color color;
    bool showBtn = false;
    String timeLeftStr;
    double progress;

    if (minutesSincePrev >= 0 && minutesSincePrev < activeWindow) {
      displayPrayer = prevPrayer;
      showBtn = true;

      if (minutesSincePrev < labelWindow) {
        label = "حان الآن موعد";
        color = const Color(0xFF4CAF50);
        timeLeftStr = "الآن";
      } else {
        label = "الصلاة الحالية";
        color = const Color(0xFF29B6F6);
        timeLeftStr = "منذ ${_toArabicNumerals(minutesSincePrev.toString())} د";
      }

      progress = (minutesSincePrev / activeWindow).clamp(0.0, 1.0);
    } else {
      displayPrayer = nextPrayer;
      label = "الصلاة القادمة";
      color = Colors.amber;
      showBtn = false;

      final diff = nextPrayer.time.difference(now);
      if (diff.isNegative) {
        timeLeftStr = "الآن";
      } else {
        final h = diff.inHours;
        final m = diff.inMinutes.remainder(60);
        final s = diff.inSeconds.remainder(60);
        timeLeftStr = _formatDuration(h, m, s);
      }

      final totalSeconds = nextPrayer.time
          .difference(prevPrayer.time)
          .inSeconds;

      final elapsedSeconds = now.difference(prevPrayer.time).inSeconds;

      progress = totalSeconds > 0
          ? (elapsedSeconds / totalSeconds).clamp(0.0, 1.0)
          : 0.0;
    }

    // ✅ الضحى
    bool isDuha = false;
    try {
      final sunrise = _getFirstPrayer(PrayerType.sunrise);
      final dhuhr = _getFirstPrayer(PrayerType.dhuhr);

      final start = sunrise.time.add(const Duration(minutes: 15));
      final end = dhuhr.time.subtract(const Duration(minutes: 15));

      if (now.isAfter(start) && now.isBefore(end)) {
        isDuha = true;
      }
    } catch (_) {}

    // ✅ قيام الليل (ثلث الليل)
    bool isQiyam = false;
    try {
      final isha = _getLastPrayer(PrayerType.isha);
      final fajr = _getFirstPrayer(PrayerType.fajr);

      DateTime nightStart;
      DateTime nightEnd;

      if (now.hour >= 12) {
        nightStart = isha.time;
        nightEnd = fajr.time.add(const Duration(days: 1));
      } else {
        nightStart = isha.time.subtract(const Duration(days: 1));
        nightEnd = fajr.time;
      }

      final duration = nightEnd.difference(nightStart);
      final lastThirdStart = nightEnd.subtract(
        Duration(minutes: (duration.inMinutes / 3).round()),
      );

      if (now.isAfter(lastThirdStart) && now.isBefore(nightEnd)) {
        isQiyam = true;
      }
    } catch (_) {}

    final dateStr = _getFormattedDate(now);
    final timeDisplay = _formatTime(displayPrayer.time);

    _controller.add(
      PrayerTimerStatus(
        prayerName: displayPrayer.nameArabic,
        timeDisplay: timeDisplay,
        timeLeft: _toArabicNumerals(timeLeftStr),
        progress: progress,
        statusLabel: label,
        statusColor: color,
        showDhikrButton: showBtn,
        fullDate: dateStr,
        isDuhaTime: isDuha,
        isQiyamTime: isQiyam,
      ),
    );
  }

  Map<String, PrayerTime> _calculateTimeline(DateTime now) {
    final fard = _todayPrayers
        .where((p) => p.type != PrayerType.sunrise)
        .toList();

    if (fard.isEmpty) {
      return {'prev': _todayPrayers.first, 'next': _todayPrayers.last};
    }

    final upcoming = fard.where((p) => p.time.isAfter(now)).toList();

    if (upcoming.isNotEmpty) {
      final next = upcoming.first;
      final index = fard.indexOf(next);

      if (index > 0) {
        return {'prev': fard[index - 1], 'next': next};
      } else {
        final isha = _getLastPrayer(PrayerType.isha);
        return {
          'prev': isha.copyWith(
            time: isha.time.subtract(const Duration(days: 1)),
          ),
          'next': next,
        };
      }
    } else {
      final fajr = _getFirstPrayer(PrayerType.fajr);
      return {
        'prev': fard.last,
        'next': fajr.copyWith(
          time: fajr.time.add(const Duration(days: 1)),
          isNext: true,
        ),
      };
    }
  }

  PrayerTime _getFirstPrayer(PrayerType type) {
    return _todayPrayers.firstWhere(
      (p) => p.type == type,
      orElse: () => _todayPrayers.first,
    );
  }

  PrayerTime _getLastPrayer(PrayerType type) {
    return _todayPrayers.lastWhere(
      (p) => p.type == type,
      orElse: () => _todayPrayers.last,
    );
  }

  String _getFormattedDate(DateTime now) {
    final dayName = DateFormat('EEEE', 'ar').format(now);
    final gregorian = DateFormat('d MMMM yyyy', 'ar').format(now);
    final hijri = HijriCalendar.fromDate(now);
    HijriCalendar.setLocal('ar');
    final hijriStr = hijri.toFormat("dd MMMM yyyy");
    return _toArabicNumerals("$dayName، $hijriStr - $gregorian");
  }

  String _formatDuration(int h, int m, int s) {
    if (h > 0) return "$hس $mد $sث";
    if (m > 0) return "$mد $sث";
    return "$sث";
  }

  String _formatTime(DateTime time) {
    final timeStr = DateFormat('h:mm', 'ar').format(time);
    final amPmStr = DateFormat('a', 'ar').format(time);
    return _toArabicNumerals("$timeStr $amPmStr");
  }

  String _toArabicNumerals(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < en.length; i++) {
      input = input.replaceAll(en[i], ar[i]);
    }
    return input;
  }
}
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:injectable/injectable.dart';
// import 'package:hijri/hijri_calendar.dart';
// import '../../features/prayer/domain/entities/prayer_time.dart';
// import '../../features/prayer/domain/models/prayer_timer_status.dart';

// @lazySingleton
// class PrayerTimerService {
//   final _controller = StreamController<PrayerTimerStatus>.broadcast();
//   Stream<PrayerTimerStatus> get timerStream => _controller.stream;

//   Timer? _ticker;
//   List<PrayerTime> _todayPrayers =
//       []; // ✅ استخدام PrayerTime بدلاً من PrayerItem

//   PrayerTimerService();

//   /// ✅ startTimer يستقبل List<PrayerTime>
//   void startTimer(List<PrayerTime> prayers) {
//     // ترتيب الصلوات للتأكد
//     prayers.sort((a, b) => a.time.compareTo(b.time));
//     _todayPrayers = prayers;

//     _ticker?.cancel();
//     _emitStatus();
//     _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _emitStatus());
//   }

//   void stopTimer() {
//     _ticker?.cancel();
//   }

//   void dispose() {
//     _controller.close();
//     _ticker?.cancel();
//   }

//   void _emitStatus() {
//     if (_todayPrayers.isEmpty) return;

//     final now = DateTime.now();

//     // 1. تحديد الخط الزمني (السابقة والقادمة)
//     final timeline = _calculateTimeline(now);
//     final prevPrayer = timeline['prev']!;
//     final nextPrayer = timeline['next']!;

//     // 2. حساب الوقت المنقضي منذ الصلاة السابقة
//     final minutesSincePrev = now.difference(prevPrayer.time).inMinutes;
//     final isMaghribPrev = prevPrayer.nameArabic.contains("المغرب");

//     final labelWindow = 10; // مدة "حان الآن"
//     final activeWindow = isMaghribPrev ? 15 : 45; // مدة "الصلاة الحالية"

//     // 3. تحديد "الصلاة المعروضة" والحالة
//     PrayerTime displayPrayer;
//     String label;
//     Color color;
//     bool showBtn = false;
//     String timeLeftStr;
//     double progress;

//     // هل نحن في النطاق النشط للصلاة السابقة؟
//     if (minutesSincePrev >= 0 && minutesSincePrev < activeWindow) {
//       // ✅ الحالة 1 و 2: نعرض الصلاة السابقة (الحالية)
//       displayPrayer = prevPrayer;
//       showBtn = true;

//       if (minutesSincePrev < labelWindow) {
//         label = "حان الآن موعد";
//         color = const Color(0xFF4CAF50);
//         timeLeftStr = "الآن";
//       } else {
//         label = "الصلاة الحالية";
//         color = const Color(0xFF29B6F6);
//         timeLeftStr = "منذ ${_toArabicNumerals(minutesSincePrev.toString())} د";
//       }
//       progress = 1.0;
//     } else {
//       // ✅ الحالة 3: تجاوزنا الوقت، نعرض الصلاة القادمة
//       displayPrayer = nextPrayer;
//       label = "الصلاة القادمة";
//       color = Colors.amber;
//       showBtn = false;

//       // حساب العداد التنازلي للصلاة القادمة
//       final diff = nextPrayer.time.difference(now);
//       if (diff.isNegative) {
//         timeLeftStr = "الآن";
//       } else {
//         final h = diff.inHours;
//         final m = diff.inMinutes.remainder(60);
//         final s = diff.inSeconds.remainder(60);
//         timeLeftStr = _formatDuration(h, m, s);
//       }

//       // حساب شريط التقدم
//       final totalSeconds = nextPrayer.time
//           .difference(prevPrayer.time)
//           .inSeconds;
//       final elapsedSeconds = now.difference(prevPrayer.time).inSeconds;
//       if (totalSeconds > 0) {
//         progress = (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
//       } else {
//         progress = 0.0;
//       }
//     }

//     // 4. ✅ منطق النوافذ الذكية (الضحى والقيام)
//     bool isDuha = false;
//     bool isQiyam = false;

//     // أ. حساب الضحى
//     try {
//       final sunrise = _getFirstPrayer(PrayerType.sunrise);
//       final dhuhr = _getFirstPrayer(PrayerType.dhuhr);

//       final duhaStart = sunrise.time.add(const Duration(minutes: 15));
//       final duhaEnd = dhuhr.time.subtract(const Duration(minutes: 15));

//       if (now.isAfter(duhaStart) && now.isBefore(duhaEnd)) {
//         isDuha = true;
//       }
//     } catch (_) {}

//     // ب. حساب قيام الليل
//     try {
//       final isha = _getLastPrayer(PrayerType.isha);
//       final fajr = _getFirstPrayer(PrayerType.fajr);

//       final qiyamStart = isha.time.add(const Duration(minutes: 30));

//       if (now.isAfter(qiyamStart)) {
//         final nextFajr = fajr.time.add(const Duration(days: 1));
//         if (now.isBefore(nextFajr.subtract(const Duration(minutes: 5)))) {
//           isQiyam = true;
//         }
//       } else if (now.hour < 12) {
//         if (now.isBefore(fajr.time.subtract(const Duration(minutes: 5)))) {
//           isQiyam = true;
//         }
//       }
//     } catch (_) {}

//     // 5. تجهيز النصوص النهائية
//     final dateStr = _getFormattedDate(now);
//     final timeDisplay = _formatTime(displayPrayer.time);

//     // 6. إرسال البيانات
//     _controller.add(
//       PrayerTimerStatus(
//         prayerName: displayPrayer.nameArabic,
//         timeDisplay: timeDisplay,
//         timeLeft: _toArabicNumerals(timeLeftStr),
//         progress: progress,
//         statusLabel: label,
//         statusColor: color,
//         showDhikrButton: showBtn,
//         fullDate: dateStr,
//         isDuhaTime: isDuha,
//         isQiyamTime: isQiyam,
//       ),
//     );
//   }

//   /// ✅ الخوارزمية الجوهرية للخط الزمني (مُحدثة)
//   Map<String, PrayerTime> _calculateTimeline(DateTime now) {
//     // ✅ نفلتر القائمة لنحصل على الفروض فقط (بدون الشروق)
//     final fardPrayers = _todayPrayers
//         .where((p) => p.type != PrayerType.sunrise)
//         .toList();

//     // البحث في قائمة الفروض فقط
//     final upcoming = fardPrayers.where((p) => p.time.isAfter(now)).toList();

//     PrayerTime nextP;
//     PrayerTime prevP;

//     if (upcoming.isNotEmpty) {
//       nextP = upcoming.first;
//       final index = fardPrayers.indexOf(nextP);
//       if (index > 0) {
//         prevP = fardPrayers[index - 1];
//       } else {
//         // القادمة فجر اليوم، السابقة عشاء أمس
//         final isha = _getLastPrayer(PrayerType.isha);
//         prevP = isha.copyWith(
//           time: isha.time.subtract(const Duration(days: 1)),
//         );
//       }
//     } else {
//       // انتهت صلوات اليوم، القادمة فجر الغد
//       final fajr = _getFirstPrayer(PrayerType.fajr);
//       nextP = fajr.copyWith(
//         time: fajr.time.add(const Duration(days: 1)),
//         isNext: true,
//       );

//       // السابقة عشاء اليوم
//       prevP = fardPrayers.last;
//     }

//     return {'prev': prevP, 'next': nextP};
//   }

//   /// ✅ الحصول على أول صلاة بنوع محدد
//   PrayerTime _getFirstPrayer(PrayerType type) {
//     return _todayPrayers.firstWhere(
//       (p) => p.type == type,
//       orElse: () => _todayPrayers.first,
//     );
//   }

//   /// ✅ الحصول على آخر صلاة بنوع محدد
//   PrayerTime _getLastPrayer(PrayerType type) {
//     return _todayPrayers.lastWhere(
//       (p) => p.type == type,
//       orElse: () => _todayPrayers.last,
//     );
//   }

//   // --- أدوات التنسيق (كما هي) ---
//   String _getFormattedDate(DateTime now) {
//     final dayName = DateFormat('EEEE', 'ar').format(now);
//     final gregorian = DateFormat('d MMMM yyyy', 'ar').format(now);
//     final hijri = HijriCalendar.fromDate(now);
//     HijriCalendar.setLocal('ar');
//     final hijriStr = hijri.toFormat("dd MMMM yyyy");
//     return _toArabicNumerals("$dayName، $hijriStr - $gregorian");
//   }

//   String _formatDuration(int h, int m, int s) {
//     if (h > 0) {
//       return "$hس $mد $sث";
//     } else if (m > 0) {
//       return "$mد $sث";
//     } else {
//       return "$sث";
//     }
//   }

//   String _formatTime(DateTime time) {
//     final timeStr = DateFormat('h:mm', 'ar').format(time);
//     final amPmStr = DateFormat('a', 'ar').format(time);
//     return _toArabicNumerals("$timeStr $amPmStr");
//   }

//   String _toArabicNumerals(String input) {
//     const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
//     const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
//     for (int i = 0; i < english.length; i++) {
//       input = input.replaceAll(english[i], arabic[i]);
//     }
//     return input;
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:injectable/injectable.dart';
// import 'package:hijri/hijri_calendar.dart';
// import '../../features/task/data/models/prayer_item.dart';
// import '../../features/prayer/domain/models/prayer_timer_status.dart';

// @lazySingleton
// class PrayerTimerService {
//   final _controller = StreamController<PrayerTimerStatus>.broadcast();
//   Stream<PrayerTimerStatus> get timerStream => _controller.stream;

//   Timer? _ticker;
//   List<PrayerItem> _todayPrayers = []; // القائمة الكاملة (شروق + فروض)

//   PrayerTimerService();

//   void startTimer(List<PrayerItem> prayers) {
//     // ترتيب الصلوات للتأكد
//     prayers.sort((a, b) => a.time.compareTo(b.time));
//     _todayPrayers = prayers;
//     _ticker?.cancel();
//     _emitStatus();
//     _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _emitStatus());
//   }

//   void stopTimer() {
//     _ticker?.cancel();
//   }

//   void dispose() {
//     _controller.close();
//     _ticker?.cancel();
//   }

//   void _emitStatus() {
//     if (_todayPrayers.isEmpty) return;

//     final now = DateTime.now();

//     // 1. تحديد الخط الزمني (السابقة والقادمة)
//     // ✅ التعديل: نستخدم منطقاً يستبعد الشروق من العرض الرئيسي
//     final timeline = _calculateTimeline(now);
//     final prevPrayer = timeline['prev']!;
//     final nextPrayer = timeline['next']!;

//     // 2. حساب الوقت المنقضي منذ الصلاة السابقة
//     final minutesSincePrev = now.difference(prevPrayer.time).inMinutes;

//     final isMaghribPrev = prevPrayer.name.contains("المغرب");

//     // السيناريو المطلوب (كما هو في كودك):
//     final labelWindow = 10; // مدة "حان الآن"
//     final activeWindow = isMaghribPrev ? 420 : 420; // مدة "الصلاة الحالية"

//     // 3. تحديد "الصلاة المعروضة" والحالة
//     PrayerItem displayPrayer;
//     String label;
//     Color color;
//     bool showBtn = false;
//     String timeLeftStr;
//     double progress;

//     // هل نحن في النطاق النشط للصلاة السابقة؟
//     if (minutesSincePrev >= 0 && minutesSincePrev < activeWindow) {
//       // ✅ الحالة 1 و 2: نعرض الصلاة السابقة (الحالية)
//       displayPrayer = prevPrayer;
//       showBtn = true;

//       if (minutesSincePrev < labelWindow) {
//         label = "حان الآن موعد";
//         color = const Color(0xFF4CAF50); // لون أخضر حيوي
//         timeLeftStr = "الآن";
//       } else {
//         label = "الصلاة الحالية";
//         color = const Color(0xFF29B6F6); // لون أزرق سماوي
//         timeLeftStr = "منذ ${_toArabicNumerals(minutesSincePrev.toString())} د";
//       }
//       progress = 1.0;
//     } else {
//       // ✅ الحالة 3: تجاوزنا الوقت، نعرض الصلاة القادمة (الفرض القادم)
//       displayPrayer = nextPrayer;
//       label = "الصلاة القادمة";
//       color = Colors.amber; // أو اللون البرتقالي المعتاد
//       showBtn = false;

//       // حساب العداد التنازلي للصلاة القادمة
//       final diff = nextPrayer.time.difference(now);
//       if (diff.isNegative) {
//         timeLeftStr = "الآن";
//       } else {
//         final h = diff.inHours;
//         final m = diff.inMinutes.remainder(60);
//         final s = diff.inSeconds.remainder(60);
//         timeLeftStr = _formatDuration(h, m, s);
//       }

//       // حساب شريط التقدم للصلاة القادمة
//       final totalSeconds = nextPrayer.time
//           .difference(prevPrayer.time)
//           .inSeconds;
//       final elapsedSeconds = now.difference(prevPrayer.time).inSeconds;
//       if (totalSeconds > 0) {
//         progress = (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
//       } else {
//         progress = 0.0;
//       }
//     }

//     // 4. ✅ منطق النوافذ الذكية (الضحى والقيام) - الميزة الجديدة
//     bool isDuha = false;
//     bool isQiyam = false;

//     // أ. حساب الضحى (نحتاج الشروق والظهر من القائمة الكاملة)
//     try {
//       final sunrise = _getFirstPrayer("الشروق"); // قد تكون موجودة أو لا
//       final dhuhr = _getFirstPrayer("الظهر");

//       // الضحى يبدأ بعد الشروق بـ 15 دقيقة وينتهي قبل الظهر بـ 15 دقيقة
//       final duhaStart = sunrise.time.add(const Duration(minutes: 15));
//       final duhaEnd = dhuhr.time.subtract(const Duration(minutes: 15));

//       if (now.isAfter(duhaStart) && now.isBefore(duhaEnd)) {
//         isDuha = true;
//       }
//     } catch (_) {
//       // تجاهل الخطأ في حال عدم وجود الشروق في البيانات
//     }

//     // ب. حساب قيام الليل (بعد العشاء بـ 30 دقيقة وحتى قبل الفجر بـ 5 دقائق)
//     try {
//       final isha = _getLastPrayer("العشاء"); // عشاء اليوم
//       final fajr = _getFirstPrayer("الفجر"); // فجر اليوم

//       // بداية القيام (بعد عشاء اليوم)
//       final qiyamStart = isha.time.add(const Duration(minutes: 30));

//       // نهاية القيام (فجر الغد إذا كنا في الليل، أو فجر اليوم إذا كنا بعد منتصف الليل)
//       // للتبسيط: إذا كنا بعد العشاء وقبل الفجر القادم

//       if (now.isAfter(qiyamStart)) {
//         // نحن بعد العشاء، هل تجاوزنا الفجر التالي؟
//         // الفجر التالي سيكون غداً
//         final nextFajr = fajr.time.add(const Duration(days: 1));
//         if (now.isBefore(nextFajr.subtract(const Duration(minutes: 5)))) {
//           isQiyam = true;
//         }
//       } else if (now.hour < 12) {
//         // نحن بعد منتصف الليل وقبل الظهر
//         // يجب أن نكون قبل فجر اليوم بـ 5 دقائق
//         if (now.isBefore(fajr.time.subtract(const Duration(minutes: 5)))) {
//           isQiyam = true;
//         }
//       }
//     } catch (_) {}

//     // 5. تجهيز النصوص النهائية
//     final dateStr = _getFormattedDate(now);
//     final timeDisplay = _formatTime(displayPrayer.time);

//     // 6. إرسال البيانات
//     _controller.add(
//       PrayerTimerStatus(
//         prayerName: displayPrayer.name,
//         timeDisplay: timeDisplay,
//         timeLeft: _toArabicNumerals(timeLeftStr),
//         progress: progress,
//         statusLabel: label,
//         statusColor: color,
//         showDhikrButton: showBtn,
//         fullDate: dateStr,
//         // ✅ تمرير الحالات الجديدة (تأكد من وجودها في الموديل PrayerTimerStatus)
//         isDuhaTime: isDuha,
//         isQiyamTime: isQiyam,
//       ),
//     );
//   }

//   // --- الخوارزمية الجوهرية للخط الزمني (المعدلة) ---
//   Map<String, PrayerItem> _calculateTimeline(DateTime now) {
//     // ✅ التعديل: نفلتر القائمة لنحصل على الفروض فقط (بدون الشروق)
//     // هذا يضمن أن "الصلاة القادمة" لن تكون أبداً الشروق
//     final fardPrayers = _todayPrayers
//         .where((p) => !p.name.contains("الشروق"))
//         .toList();

//     // البحث في قائمة الفروض فقط
//     final upcoming = fardPrayers.where((p) => p.time.isAfter(now)).toList();

//     PrayerItem nextP;
//     PrayerItem prevP;

//     if (upcoming.isNotEmpty) {
//       nextP = upcoming.first;
//       final index = fardPrayers.indexOf(nextP);
//       if (index > 0) {
//         prevP = fardPrayers[index - 1];
//       } else {
//         // القادمة فجر اليوم، السابقة عشاء أمس
//         // نعود للقائمة الكاملة لجلب العشاء بأمان
//         final isha = _getLastPrayer("العشاء");
//         prevP = PrayerItem(
//           name: isha.name,
//           time: isha.time.subtract(const Duration(days: 1)),
//         );
//       }
//     } else {
//       // انتهت صلوات اليوم، القادمة فجر الغد
//       final fajr = _getFirstPrayer("الفجر");
//       nextP = PrayerItem(
//         name: fajr.name,
//         time: fajr.time.add(const Duration(days: 1)),
//         isNext: true,
//       );

//       // السابقة عشاء اليوم
//       // نأخذ آخر صلاة في قائمة الفروض (العشاء عادة)
//       prevP = fardPrayers.last;
//     }

//     return {'prev': prevP, 'next': nextP};
//   }

//   PrayerItem _getFirstPrayer(String namePart) {
//     return _todayPrayers.firstWhere(
//       (p) => p.name.contains(namePart),
//       orElse: () => _todayPrayers.first,
//     );
//   }

//   PrayerItem _getLastPrayer(String namePart) {
//     return _todayPrayers.lastWhere(
//       (p) => p.name.contains(namePart),
//       orElse: () => _todayPrayers.last,
//     );
//   }

//   // --- أدوات التنسيق (كما هي في كودك) ---
//   String _getFormattedDate(DateTime now) {
//     final dayName = DateFormat('EEEE', 'ar').format(now);
//     final gregorian = DateFormat('d MMMM yyyy', 'ar').format(now);
//     final hijri = HijriCalendar.fromDate(now);
//     HijriCalendar.setLocal('ar');
//     final hijriStr = hijri.toFormat("dd MMMM yyyy");

//     return _toArabicNumerals("$dayName، $hijriStr - $gregorian");
//   }

//   String _formatDuration(int h, int m, int s) {
//     if (h > 0) {
//       return "$hس $mد $sث";
//     } else if (m > 0) {
//       return "$mد $sث";
//     } else {
//       return "$sث";
//     }
//   }

//   String _formatTime(DateTime time) {
//     final timeStr = DateFormat('h:mm', 'ar').format(time);
//     final amPmStr = DateFormat('a', 'ar').format(time);
//     return _toArabicNumerals("$timeStr $amPmStr");
//   }

//   String _toArabicNumerals(String input) {
//     const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
//     const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
//     for (int i = 0; i < english.length; i++) {
//       input = input.replaceAll(english[i], arabic[i]);
//     }
//     return input;
//   }
// }
