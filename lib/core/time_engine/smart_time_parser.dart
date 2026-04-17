// lib/core/time_engine/smart_time_parser.dart
// ✅ محلل ذكي للأوقات - يتكامل مع نظام الأوقات الموجود

import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter/material.dart';
import 'athar_time_periods.dart';
import 'relative_time_parser.dart';

/// محلل ذكي للأوقات
/// يدعم:
/// - أسماء الصلوات (الفجر، الظهر، العصر، المغرب، العشاء)
/// - الأوقات النسبية (بعد الفجر، قبل المغرب)
/// - أوقات خاصة (الضحى، منتصف الليل، الثلث الأخير)
/// - صيغة الساعة العادية (3:30، ٣:٣٠)
class SmartTimeParser {
  // ═══════════════════════════════════════════════════════════════════
  // الأسماء المدعومة - ربط مع ReferencePrayer من athar_time_periods.dart
  // ═══════════════════════════════════════════════════════════════════

  static const Map<String, ReferencePrayer> prayerMappings = {
    // الفجر
    'الفجر': ReferencePrayer.fajr,
    'فجر': ReferencePrayer.fajr,
    'الصبح': ReferencePrayer.fajr,
    'صبح': ReferencePrayer.fajr,
    'صلاة الفجر': ReferencePrayer.fajr,
    'صلاة الصبح': ReferencePrayer.fajr,

    // الشروق
    'الشروق': ReferencePrayer.sunrise,
    'شروق': ReferencePrayer.sunrise,
    'طلوع الشمس': ReferencePrayer.sunrise,

    // الظهر
    'الظهر': ReferencePrayer.dhuhr,
    'ظهر': ReferencePrayer.dhuhr,
    'صلاة الظهر': ReferencePrayer.dhuhr,

    // العصر
    'العصر': ReferencePrayer.asr,
    'عصر': ReferencePrayer.asr,
    'صلاة العصر': ReferencePrayer.asr,

    // المغرب
    'المغرب': ReferencePrayer.maghrib,
    'مغرب': ReferencePrayer.maghrib,
    'صلاة المغرب': ReferencePrayer.maghrib,
    'غروب': ReferencePrayer.maghrib,
    'الغروب': ReferencePrayer.maghrib,

    // العشاء
    'العشاء': ReferencePrayer.isha,
    'عشاء': ReferencePrayer.isha,
    'صلاة العشاء': ReferencePrayer.isha,
  };

  // ═══════════════════════════════════════════════════════════════════
  // ربط مع AtharTimePeriod من athar_time_periods.dart
  // ═══════════════════════════════════════════════════════════════════

  static const Map<String, AtharTimePeriod> periodMappings = {
    'الفجر': AtharTimePeriod.dawn,
    'فجر': AtharTimePeriod.dawn,
    'البكور': AtharTimePeriod.bakur,
    'بكور': AtharTimePeriod.bakur,
    'الصباح': AtharTimePeriod.morning,
    'صباح': AtharTimePeriod.morning,
    'الظهيرة': AtharTimePeriod.noon,
    'ظهيرة': AtharTimePeriod.noon,
    'العصر': AtharTimePeriod.afternoon,
    'عصر': AtharTimePeriod.afternoon,
    'المغرب': AtharTimePeriod.maghrib,
    'مغرب': AtharTimePeriod.maghrib,
    'العشاء': AtharTimePeriod.isha,
    'عشاء': AtharTimePeriod.isha,
    'الليل': AtharTimePeriod.night,
    'ليل': AtharTimePeriod.night,
    'الثلث الأخير': AtharTimePeriod.lastThird,
    'ثلث الليل': AtharTimePeriod.lastThird,
    'السحر': AtharTimePeriod.lastThird,
    'سحر': AtharTimePeriod.lastThird,
  };

  // ═══════════════════════════════════════════════════════════════════
  // التحليل الرئيسي
  // ═══════════════════════════════════════════════════════════════════

  /// تحويل النص إلى وقت فعلي
  ///
  /// أمثلة مدعومة:
  /// - "الفجر" → وقت صلاة الفجر
  /// - "بعد الظهر" → 15 دقيقة بعد الظهر
  /// - "قبل المغرب" → 15 دقيقة قبل المغرب
  /// - "الضحى" → 20 دقيقة بعد الشروق
  /// - "3:30" أو "٣:٣٠" → الساعة 3:30
  /// - "منتصف الليل" → 12:00 ص
  static SmartParseResult parse(
    String input,
    DateTime date,
    adhan.PrayerTimes prayerTimes,
  ) {
    final normalized = input.trim();

    if (normalized.isEmpty) {
      return SmartParseResult.invalid('الرجاء إدخال وقت');
    }

    // 1. الصلوات المباشرة
    final directPrayer = _parseDirectPrayer(normalized, prayerTimes);
    if (directPrayer.isValid) return directPrayer;

    // 2. "بعد X"
    final afterPrayer = _parseAfterPrayer(normalized, prayerTimes);
    if (afterPrayer.isValid) return afterPrayer;

    // 3. "قبل X"
    final beforePrayer = _parseBeforePrayer(normalized, prayerTimes);
    if (beforePrayer.isValid) return beforePrayer;

    // 4. أوقات خاصة (الضحى، منتصف الليل، إلخ)
    final specialTime = _parseSpecialTime(normalized, date, prayerTimes);
    if (specialTime.isValid) return specialTime;

    // 5. صيغة الساعة العادية
    final standardTime = _parseStandardTime(normalized, date);
    if (standardTime.isValid) return standardTime;

    return SmartParseResult.invalid('لم أفهم الوقت المطلوب');
  }

  // ═══════════════════════════════════════════════════════════════════
  // التحليل التفصيلي
  // ═══════════════════════════════════════════════════════════════════

  static SmartParseResult _parseDirectPrayer(
    String input,
    adhan.PrayerTimes prayerTimes,
  ) {
    for (final entry in prayerMappings.entries) {
      if (input == entry.key) {
        final time = _getPrayerTimeFromAdhan(entry.value, prayerTimes);
        if (time != null) {
          return SmartParseResult.valid(
            time: time,
            displayText: 'عند ${entry.key}',
            referencePrayer: entry.value,
            relation: PrayerRelativeTime.after,
            offsetMinutes: 0,
          );
        }
      }
    }
    return SmartParseResult.notMatched();
  }

  static SmartParseResult _parseAfterPrayer(
    String input,
    adhan.PrayerTimes prayerTimes,
  ) {
    // أنماط: "بعد الفجر"، "بعد صلاة الظهر"، "بعد الفجر بـ 30 دقيقة"
    final patterns = [
      RegExp(r'^بعد\s+(.+?)\s+بـ?\s*(\d+)\s*(?:دقيقة|د|دقائق)?$'),
      RegExp(r'^بعد\s+(.+)$'),
      RegExp(r'^عقب\s+(.+)$'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null) {
        final prayerName = match.group(1)!.trim();
        final offsetMinutes =
            match.groupCount >= 2 ? int.tryParse(match.group(2) ?? '') ?? 15 : 15;

        final prayerType = _findPrayerType(prayerName);

        if (prayerType != null) {
          final prayerTime = _getPrayerTimeFromAdhan(prayerType, prayerTimes);
          if (prayerTime != null) {
            final time = prayerTime.add(Duration(minutes: offsetMinutes));
            return SmartParseResult.valid(
              time: time,
              displayText: 'بعد ${_getPrayerDisplayName(prayerType)} بـ $offsetMinutes د',
              referencePrayer: prayerType,
              relation: PrayerRelativeTime.after,
              offsetMinutes: offsetMinutes,
            );
          }
        }
      }
    }
    return SmartParseResult.notMatched();
  }

  static SmartParseResult _parseBeforePrayer(
    String input,
    adhan.PrayerTimes prayerTimes,
  ) {
    // أنماط: "قبل المغرب"، "قبل صلاة العشاء"، "قبل الفجر بـ 30 دقيقة"
    final patterns = [
      RegExp(r'^قبل\s+(.+?)\s+بـ?\s*(\d+)\s*(?:دقيقة|د|دقائق)?$'),
      RegExp(r'^قبل\s+(.+)$'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null) {
        final prayerName = match.group(1)!.trim();
        final offsetMinutes =
            match.groupCount >= 2 ? int.tryParse(match.group(2) ?? '') ?? 15 : 15;

        final prayerType = _findPrayerType(prayerName);

        if (prayerType != null) {
          final prayerTime = _getPrayerTimeFromAdhan(prayerType, prayerTimes);
          if (prayerTime != null) {
            final time = prayerTime.subtract(Duration(minutes: offsetMinutes));
            return SmartParseResult.valid(
              time: time,
              displayText: 'قبل ${_getPrayerDisplayName(prayerType)} بـ $offsetMinutes د',
              referencePrayer: prayerType,
              relation: PrayerRelativeTime.before,
              offsetMinutes: offsetMinutes,
            );
          }
        }
      }
    }
    return SmartParseResult.notMatched();
  }

  static SmartParseResult _parseSpecialTime(
    String input,
    DateTime date,
    adhan.PrayerTimes prayerTimes,
  ) {
    // الضحى
    if (input.contains('الضحى') || input.contains('ضحى')) {
      final sunrise = prayerTimes.sunrise;
      final time = sunrise.add(const Duration(minutes: 20));
      return SmartParseResult.valid(
        time: time,
        displayText: 'وقت الضحى',
        period: AtharTimePeriod.bakur,
      );
    }

    // منتصف الليل
    if (input.contains('منتصف الليل') || input == 'نصف الليل') {
      return SmartParseResult.valid(
        time: DateTime(date.year, date.month, date.day, 0, 0),
        displayText: 'منتصف الليل',
        period: AtharTimePeriod.night,
      );
    }

    // الثلث الأخير
    if (input.contains('الثلث الأخير') || input.contains('قيام الليل')) {
      final isha = prayerTimes.isha;
      // نحتاج فجر اليوم التالي
      final nextDayFajr = prayerTimes.fajr.add(const Duration(days: 1));

      final nightDuration = nextDayFajr.difference(isha);
      final thirdStart = nextDayFajr.subtract(Duration(
        minutes: (nightDuration.inMinutes / 3).round(),
      ));
      return SmartParseResult.valid(
        time: thirdStart,
        displayText: 'الثلث الأخير من الليل',
        period: AtharTimePeriod.lastThird,
      );
    }

    // السحور
    if (input.contains('السحور') || input.contains('سحور')) {
      final fajr = prayerTimes.fajr;
      final time = fajr.subtract(const Duration(minutes: 30));
      return SmartParseResult.valid(
        time: time,
        displayText: 'وقت السحور',
        referencePrayer: ReferencePrayer.fajr,
        relation: PrayerRelativeTime.before,
        offsetMinutes: 30,
      );
    }

    return SmartParseResult.notMatched();
  }

  static SmartParseResult _parseStandardTime(String input, DateTime date) {
    // تحويل الأرقام العربية للإنجليزية
    final englishNumbers = _convertArabicToEnglish(input);

    // أنماط الوقت
    final patterns = [
      // 3:30 ص / 3:30 م
      RegExp(r'(\d{1,2}):(\d{2})\s*(ص|م|صباحا|مساء|صباحاً|مساءً)?'),
      // 3 ص / 3 م
      RegExp(r'(\d{1,2})\s*(ص|م|صباحا|مساء|صباحاً|مساءً)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(englishNumbers);
      if (match != null) {
        var hour = int.parse(match.group(1)!);
        final minute = match.groupCount >= 2 && match.group(2) != null
            ? int.tryParse(match.group(2)!) ?? 0
            : 0;
        final amPm = match.groupCount >= 3 ? match.group(3) : null;

        // تحويل 12 ساعة إلى 24 ساعة
        if (amPm != null) {
          if ((amPm == 'م' || amPm.contains('مساء')) && hour < 12) {
            hour += 12;
          } else if ((amPm == 'ص' || amPm.contains('صباح')) && hour == 12) {
            hour = 0;
          }
        }

        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          final time = DateTime(date.year, date.month, date.day, hour, minute);
          return SmartParseResult.valid(
            time: time,
            displayText: _formatTime(time),
            isFixedTime: true,
            fixedTimeOfDay: TimeOfDay(hour: hour, minute: minute),
          );
        }
      }
    }

    return SmartParseResult.notMatched();
  }

  // ═══════════════════════════════════════════════════════════════════
  // الدوال المساعدة
  // ═══════════════════════════════════════════════════════════════════

  static ReferencePrayer? _findPrayerType(String name) {
    for (final entry in prayerMappings.entries) {
      if (name == entry.key || name.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  static DateTime? _getPrayerTimeFromAdhan(
    ReferencePrayer prayer,
    adhan.PrayerTimes prayerTimes,
  ) {
    switch (prayer) {
      case ReferencePrayer.fajr:
        return prayerTimes.fajr;
      case ReferencePrayer.sunrise:
        return prayerTimes.sunrise;
      case ReferencePrayer.dhuhr:
        return prayerTimes.dhuhr;
      case ReferencePrayer.asr:
        return prayerTimes.asr;
      case ReferencePrayer.maghrib:
        return prayerTimes.maghrib;
      case ReferencePrayer.isha:
        return prayerTimes.isha;
    }
  }

  static String _getPrayerDisplayName(ReferencePrayer type) {
    switch (type) {
      case ReferencePrayer.fajr:
        return 'الفجر';
      case ReferencePrayer.sunrise:
        return 'الشروق';
      case ReferencePrayer.dhuhr:
        return 'الظهر';
      case ReferencePrayer.asr:
        return 'العصر';
      case ReferencePrayer.maghrib:
        return 'المغرب';
      case ReferencePrayer.isha:
        return 'العشاء';
    }
  }

  static String _convertArabicToEnglish(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    var result = input;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }

  static String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $amPm';
  }

  // ═══════════════════════════════════════════════════════════════════
  // تحويل النتيجة لاستخدام مع RelativeTimeParser الموجود
  // ═══════════════════════════════════════════════════════════════════

  /// تحويل النتيجة لـ RelativeTimeParser الموجود
  static DateTime? calculateActualTime(
    SmartParseResult result,
    adhan.PrayerTimes prayerTimes,
  ) {
    if (!result.isValid) return null;

    // إذا كان وقت ثابت، أرجعه مباشرة
    if (result.isFixedTime) {
      return result.time;
    }

    // إذا كان نسبي للصلاة، استخدم RelativeTimeParser
    if (result.referencePrayer != null) {
      return RelativeTimeParser.calculateActualTime(
        prayer: result.referencePrayer!,
        relation: result.relation ?? PrayerRelativeTime.after,
        offsetMinutes: result.offsetMinutes ?? 0,
        prayerTimes: prayerTimes,
      );
    }

    return result.time;
  }
}

// ═══════════════════════════════════════════════════════════════════
// نتيجة التحليل - متوافقة مع time_slot_mixin.dart
// ═══════════════════════════════════════════════════════════════════

class SmartParseResult {
  final bool isValid;
  final DateTime? time;
  final String? displayText;
  final String? errorMessage;
  final bool _notMatched;

  // للتكامل مع نظام الأوقات الموجود
  final ReferencePrayer? referencePrayer;
  final PrayerRelativeTime? relation;
  final int? offsetMinutes;
  final AtharTimePeriod? period;

  // للوقت الثابت
  final bool isFixedTime;
  final TimeOfDay? fixedTimeOfDay;

  SmartParseResult._({
    required this.isValid,
    this.time,
    this.displayText,
    this.errorMessage,
    this.referencePrayer,
    this.relation,
    this.offsetMinutes,
    this.period,
    this.isFixedTime = false,
    this.fixedTimeOfDay,
    bool notMatched = false,
  }) : _notMatched = notMatched;

  factory SmartParseResult.valid({
    required DateTime time,
    required String displayText,
    ReferencePrayer? referencePrayer,
    PrayerRelativeTime? relation,
    int? offsetMinutes,
    AtharTimePeriod? period,
    bool isFixedTime = false,
    TimeOfDay? fixedTimeOfDay,
  }) {
    return SmartParseResult._(
      isValid: true,
      time: time,
      displayText: displayText,
      referencePrayer: referencePrayer,
      relation: relation,
      offsetMinutes: offsetMinutes,
      period: period,
      isFixedTime: isFixedTime,
      fixedTimeOfDay: fixedTimeOfDay,
    );
  }

  factory SmartParseResult.invalid(String message) {
    return SmartParseResult._(
      isValid: false,
      errorMessage: message,
    );
  }

  factory SmartParseResult.notMatched() {
    return SmartParseResult._(
      isValid: false,
      notMatched: true,
    );
  }

  bool get wasNotMatched => _notMatched;
}
