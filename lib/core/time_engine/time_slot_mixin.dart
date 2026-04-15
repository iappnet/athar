// lib/core/time_engine/time_slot_mixin.dart
// ✅ Mixin لإضافة دعم الأوقات الشرعية للـ Models

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'athar_time_periods.dart';
import 'athar_time_calculator.dart';
import 'relative_time_parser.dart';

// ═══════════════════════════════════════════════════════════════════
// نموذج إعدادات الوقت
// ═══════════════════════════════════════════════════════════════════

/// طريقة تحديد الوقت
enum TimeSpecificationType {
  /// وقت ثابت (مثل 05:00)
  fixed,
  
  /// نسبي للصلاة (مثل بعد الفجر بـ 15 دقيقة)
  relativeToprayer,
  
  /// فترة زمنية (مثل الصباح)
  period,
}

/// إعدادات الوقت الكاملة
class TimeSlotSettings {
  /// نوع التحديد
  final TimeSpecificationType type;
  
  /// الوقت الثابت (إذا كان type = fixed)
  final TimeOfDay? fixedTime;
  
  /// الصلاة المرجعية (إذا كان type = relativeToprayer)
  final ReferencePrayer? referencePrayer;
  
  /// العلاقة بالصلاة (قبل/بعد/إقامة)
  final PrayerRelativeTime? prayerRelation;
  
  /// الفارق بالدقائق
  final int offsetMinutes;
  
  /// الفترة الزمنية (إذا كان type = period)
  final AtharTimePeriod? period;
  
  /// موقع ضمن الفترة (بداية/منتصف/نهاية)
  final PeriodPosition? periodPosition;

  const TimeSlotSettings({
    required this.type,
    this.fixedTime,
    this.referencePrayer,
    this.prayerRelation,
    this.offsetMinutes = 0,
    this.period,
    this.periodPosition,
  });

  /// إنشاء من وقت ثابت
  factory TimeSlotSettings.fixed(TimeOfDay time) {
    return TimeSlotSettings(
      type: TimeSpecificationType.fixed,
      fixedTime: time,
    );
  }

  /// إنشاء من صلاة
  factory TimeSlotSettings.relativeToprayer({
    required ReferencePrayer prayer,
    PrayerRelativeTime relation = PrayerRelativeTime.after,
    int offsetMinutes = 0,
  }) {
    return TimeSlotSettings(
      type: TimeSpecificationType.relativeToprayer,
      referencePrayer: prayer,
      prayerRelation: relation,
      offsetMinutes: offsetMinutes,
    );
  }

  /// إنشاء من فترة
  factory TimeSlotSettings.period({
    required AtharTimePeriod period,
    PeriodPosition position = PeriodPosition.start,
  }) {
    return TimeSlotSettings(
      type: TimeSpecificationType.period,
      period: period,
      periodPosition: position,
    );
  }

  /// تحويل للـ JSON
  Map<String, dynamic> toJson() => {
    'type': type.index,
    'fixedHour': fixedTime?.hour,
    'fixedMinute': fixedTime?.minute,
    'referencePrayer': referencePrayer?.index,
    'prayerRelation': prayerRelation?.index,
    'offsetMinutes': offsetMinutes,
    'period': period?.index,
    'periodPosition': periodPosition?.index,
  };

  /// إنشاء من JSON
  factory TimeSlotSettings.fromJson(Map<String, dynamic> json) {
    final type = TimeSpecificationType.values[json['type'] ?? 0];
    
    return TimeSlotSettings(
      type: type,
      fixedTime: json['fixedHour'] != null
          ? TimeOfDay(hour: json['fixedHour'], minute: json['fixedMinute'] ?? 0)
          : null,
      referencePrayer: json['referencePrayer'] != null
          ? ReferencePrayer.values[json['referencePrayer']]
          : null,
      prayerRelation: json['prayerRelation'] != null
          ? PrayerRelativeTime.values[json['prayerRelation']]
          : null,
      offsetMinutes: json['offsetMinutes'] ?? 0,
      period: json['period'] != null
          ? AtharTimePeriod.values[json['period']]
          : null,
      periodPosition: json['periodPosition'] != null
          ? PeriodPosition.values[json['periodPosition']]
          : null,
    );
  }

  /// نسخة معدلة
  TimeSlotSettings copyWith({
    TimeSpecificationType? type,
    TimeOfDay? fixedTime,
    ReferencePrayer? referencePrayer,
    PrayerRelativeTime? prayerRelation,
    int? offsetMinutes,
    AtharTimePeriod? period,
    PeriodPosition? periodPosition,
  }) {
    return TimeSlotSettings(
      type: type ?? this.type,
      fixedTime: fixedTime ?? this.fixedTime,
      referencePrayer: referencePrayer ?? this.referencePrayer,
      prayerRelation: prayerRelation ?? this.prayerRelation,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      period: period ?? this.period,
      periodPosition: periodPosition ?? this.periodPosition,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlotSettings &&
          type == other.type &&
          fixedTime == other.fixedTime &&
          referencePrayer == other.referencePrayer &&
          prayerRelation == other.prayerRelation &&
          offsetMinutes == other.offsetMinutes &&
          period == other.period &&
          periodPosition == other.periodPosition;

  @override
  int get hashCode => Object.hash(
        type,
        fixedTime,
        referencePrayer,
        prayerRelation,
        offsetMinutes,
        period,
        periodPosition,
      );
}

/// موقع ضمن الفترة
enum PeriodPosition {
  start,  // بداية الفترة
  middle, // منتصف الفترة
  end,    // نهاية الفترة
}

// ═══════════════════════════════════════════════════════════════════
// Mixin للـ Models
// ═══════════════════════════════════════════════════════════════════

/// Mixin يضيف دعم الأوقات الشرعية لأي Model
mixin TimeSlotMixin {
  /// إعدادات الوقت
  TimeSlotSettings? get timeSlotSettings;

  /// حساب الوقت الفعلي
  DateTime? calculateActualTime({
    required PrayerTimes prayerTimes,
    required DateTime today,
    DateTime? nextFajr,
  }) {
    final settings = timeSlotSettings;
    if (settings == null) return null;

    switch (settings.type) {
      case TimeSpecificationType.fixed:
        if (settings.fixedTime == null) return null;
        return DateTime(
          today.year,
          today.month,
          today.day,
          settings.fixedTime!.hour,
          settings.fixedTime!.minute,
        );

      case TimeSpecificationType.relativeToprayer:
        if (settings.referencePrayer == null) return null;
        return RelativeTimeParser.calculateActualTime(
          prayer: settings.referencePrayer!,
          relation: settings.prayerRelation ?? PrayerRelativeTime.after,
          offsetMinutes: settings.offsetMinutes,
          prayerTimes: prayerTimes,
        );

      case TimeSpecificationType.period:
        if (settings.period == null) return null;
        return _calculatePeriodTime(
          period: settings.period!,
          position: settings.periodPosition ?? PeriodPosition.start,
          prayerTimes: prayerTimes,
          today: today,
          nextFajr: nextFajr,
        );
    }
  }

  /// حساب وقت الفترة
  DateTime? _calculatePeriodTime({
    required AtharTimePeriod period,
    required PeriodPosition position,
    required PrayerTimes prayerTimes,
    required DateTime today,
    DateTime? nextFajr,
  }) {
    // حساب بداية ونهاية كل فترة
    final bounds = _getPeriodBounds(
      period: period,
      prayerTimes: prayerTimes,
      today: today,
      nextFajr: nextFajr,
    );

    if (bounds == null) return null;

    final start = bounds.start;
    final end = bounds.end;
    final duration = end.difference(start);

    switch (position) {
      case PeriodPosition.start:
        return start;
      case PeriodPosition.middle:
        return start.add(Duration(seconds: duration.inSeconds ~/ 2));
      case PeriodPosition.end:
        return end.subtract(const Duration(minutes: 5)); // قبل النهاية بـ 5 دقائق
    }
  }

  /// الحصول على حدود الفترة
  _PeriodBounds? _getPeriodBounds({
    required AtharTimePeriod period,
    required PrayerTimes prayerTimes,
    required DateTime today,
    DateTime? nextFajr,
  }) {
    final sunrise = prayerTimes.sunrise;
    final dhuhr = prayerTimes.dhuhr;
    final asr = prayerTimes.asr;
    final maghrib = prayerTimes.maghrib;
    final isha = prayerTimes.isha;
    final fajr = prayerTimes.fajr;

    switch (period) {
      case AtharTimePeriod.dawn:
        return _PeriodBounds(fajr, sunrise);

      case AtharTimePeriod.bakur:
        final bakurEnd = DateTime(today.year, today.month, today.day, 8, 0);
        if (sunrise.isAfter(bakurEnd)) return null; // لا يوجد وقت بكور
        return _PeriodBounds(sunrise, bakurEnd);

      case AtharTimePeriod.morning:
        final morningStart = DateTime(today.year, today.month, today.day, 8, 0);
        final morningEnd = dhuhr.subtract(const Duration(minutes: 15));
        return _PeriodBounds(
          sunrise.isAfter(morningStart) ? sunrise : morningStart,
          morningEnd,
        );

      case AtharTimePeriod.noon:
        return _PeriodBounds(dhuhr, asr);

      case AtharTimePeriod.afternoon:
        return _PeriodBounds(asr, maghrib);

      case AtharTimePeriod.maghrib:
        return _PeriodBounds(maghrib, isha);

      case AtharTimePeriod.isha:
        final ishaEnd = isha.add(const Duration(minutes: 90));
        return _PeriodBounds(isha, ishaEnd);

      case AtharTimePeriod.night:
        if (nextFajr == null) return null;
        final nightStart = isha.add(const Duration(minutes: 90));
        final nightDuration = nextFajr.difference(maghrib);
        final lastThirdStart = nextFajr.subtract(
          Duration(seconds: (nightDuration.inSeconds / 3).round()),
        );
        return _PeriodBounds(nightStart, lastThirdStart);

      case AtharTimePeriod.lastThird:
        if (nextFajr == null) return null;
        final nightDuration = nextFajr.difference(maghrib);
        final lastThirdStart = nextFajr.subtract(
          Duration(seconds: (nightDuration.inSeconds / 3).round()),
        );
        return _PeriodBounds(lastThirdStart, nextFajr);

      case AtharTimePeriod.duha:
        // الضحى: من الشروق + 15د إلى قبل الظهر بـ 15د
        return _PeriodBounds(
          sunrise.add(const Duration(minutes: 15)),
          dhuhr.subtract(const Duration(minutes: 15)),
        );

      case AtharTimePeriod.undefined:
        return null;
    }
  }

  /// عرض الوقت كنص
  String getTimeDisplayString() {
    final settings = timeSlotSettings;
    if (settings == null) return 'غير محدد';

    switch (settings.type) {
      case TimeSpecificationType.fixed:
        if (settings.fixedTime == null) return 'غير محدد';
        return _formatTimeOfDay(settings.fixedTime!);

      case TimeSpecificationType.relativeToprayer:
        return _formatRelativeTime(settings);

      case TimeSpecificationType.period:
        return _formatPeriodTime(settings);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  String _formatRelativeTime(TimeSlotSettings settings) {
    final prayerName = _getPrayerName(settings.referencePrayer);
    
    if (settings.offsetMinutes == 0) {
      return prayerName;
    }

    final offset = settings.offsetMinutes;
    final relationText = settings.prayerRelation == PrayerRelativeTime.before
        ? 'قبل'
        : 'بعد';

    return '$relationText $prayerName بـ $offset د';
  }

  String _formatPeriodTime(TimeSlotSettings settings) {
    final periodName = _getPeriodName(settings.period);
    
    switch (settings.periodPosition) {
      case PeriodPosition.start:
        return 'بداية $periodName';
      case PeriodPosition.middle:
        return 'منتصف $periodName';
      case PeriodPosition.end:
        return 'نهاية $periodName';
      default:
        return periodName;
    }
  }

  String _getPrayerName(ReferencePrayer? prayer) {
    switch (prayer) {
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
      default:
        return 'غير محدد';
    }
  }

  String _getPeriodName(AtharTimePeriod? period) {
    switch (period) {
      case AtharTimePeriod.dawn:
        return 'الفجر';
      case AtharTimePeriod.bakur:
        return 'البكور';
      case AtharTimePeriod.duha:
        return 'الضحى';
      case AtharTimePeriod.morning:
        return 'الصباح';
      case AtharTimePeriod.noon:
        return 'الظهيرة';
      case AtharTimePeriod.afternoon:
        return 'العصر';
      case AtharTimePeriod.maghrib:
        return 'المغرب';
      case AtharTimePeriod.isha:
        return 'العشاء';
      case AtharTimePeriod.night:
        return 'الليل';
      case AtharTimePeriod.lastThird:
        return 'الثلث الأخير';
      default:
        return 'غير محدد';
    }
  }

  /// هل الوقت الحالي ضمن الفترة؟
  bool isWithinTimeSlot({
    required DateTime now,
    required PrayerTimes prayerTimes,
    DateTime? nextFajr,
  }) {
    final settings = timeSlotSettings;
    if (settings == null) return false;

    if (settings.type == TimeSpecificationType.period && settings.period != null) {
      final currentPeriod = AtharTimeCalculator.getCurrentPeriod(
        now: now,
        prayerTimes: prayerTimes,
        nextFajr: nextFajr ?? now.add(const Duration(hours: 6)),
      );
      return currentPeriod == settings.period;
    }

    // للوقت الثابت أو النسبي، نتحقق من أن الوقت الحالي قريب
    final actualTime = calculateActualTime(
      prayerTimes: prayerTimes,
      today: now,
      nextFajr: nextFajr,
    );

    if (actualTime == null) return false;

    final difference = now.difference(actualTime).inMinutes.abs();
    return difference <= 30; // ضمن 30 دقيقة من الوقت المحدد
  }
}

class _PeriodBounds {
  final DateTime start;
  final DateTime end;
  _PeriodBounds(this.start, this.end);
}

// ═══════════════════════════════════════════════════════════════════
// Extension للتحويل السريع
// ═══════════════════════════════════════════════════════════════════

extension TimeOfDayToSettings on TimeOfDay {
  TimeSlotSettings toTimeSlotSettings() => TimeSlotSettings.fixed(this);
}

extension ReferencePrayerToSettings on ReferencePrayer {
  TimeSlotSettings toTimeSlotSettings({
    PrayerRelativeTime relation = PrayerRelativeTime.after,
    int offsetMinutes = 0,
  }) => TimeSlotSettings.relativeToprayer(
    prayer: this,
    relation: relation,
    offsetMinutes: offsetMinutes,
  );
}

extension AtharTimePeriodToSettings on AtharTimePeriod {
  TimeSlotSettings toTimeSlotSettings({
    PeriodPosition position = PeriodPosition.start,
  }) => TimeSlotSettings.period(
    period: this,
    position: position,
  );
}
