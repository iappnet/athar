import 'package:adhan/adhan.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/core/utils/smart_zone_helper.dart'; // لتحديد هل نحن في وقت عمل

enum ConflictType { none, warning, blocked }

class PrayerConflictHelper {
  // دالة الفحص الرئيسية
  static ConflictResult checkConflict(
    DateTime taskTime,
    Coordinates coordinates,
    UserSettings settings,
  ) {
    // 1. حساب مواقيت الصلاة لليوم المحدد
    final params = CalculationMethod.umm_al_qura.getParameters();
    final dateComponents = DateComponents(
      taskTime.year,
      taskTime.month,
      taskTime.day,
    );
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    // 2. تحديد مدة الحظر بناءً على المنطقة الذكية (تم التعديل هنا)
    // نستخدم getCurrentZoneKey التي ترجع String ('work', 'home', etc)
    final currentZone = SmartZoneHelper.getCurrentZoneKey(settings);
    final isWorkTime = currentZone == 'work';

    // القواعد:
    // - المغرب: دائماً 20 دقيقة.
    // - أوقات العمل: 15 دقيقة لباقي الصلوات.
    // - خارج العمل: 40 دقيقة لباقي الصلوات.

    int getBufferMinutes(Prayer prayer) {
      if (prayer == Prayer.maghrib) return 20;
      return isWorkTime ? 15 : 40;
    }

    // 3. فحص كل صلاة
    Map<Prayer, DateTime> times = {
      Prayer.fajr: prayerTimes.fajr,
      Prayer.dhuhr: prayerTimes.dhuhr,
      Prayer.asr: prayerTimes.asr,
      Prayer.maghrib: prayerTimes.maghrib,
      Prayer.isha: prayerTimes.isha,
    };

    for (var entry in times.entries) {
      final prayer = entry.key;
      final prayerTime = entry.value;
      final buffer = getBufferMinutes(prayer);

      // وقت انتهاء الحظر لهذه الصلاة
      final bufferEndTime = prayerTime.add(Duration(minutes: buffer));

      // هل وقت المهمة يقع داخل فترة الحظر؟
      // (من وقت الأذان إلى وقت انتهاء الحظر)
      if (taskTime.isAfter(prayerTime) && taskTime.isBefore(bufferEndTime)) {
        return ConflictResult(
          type: ConflictType.warning, // نجعلها تحذير وليس منع كما طلبت
          prayerName: _getPrayerName(prayer),
          suggestedTime: bufferEndTime.add(
            const Duration(minutes: 5),
          ), // اقتراح وقت بعد الحظر
        );
      }
    }

    return ConflictResult(type: ConflictType.none);
  }

  static String _getPrayerName(Prayer p) {
    switch (p) {
      case Prayer.fajr:
        return "الفجر";
      case Prayer.dhuhr:
        return "الظهر";
      case Prayer.asr:
        return "العصر";
      case Prayer.maghrib:
        return "المغرب";
      case Prayer.isha:
        return "العشاء";
      default:
        return "";
    }
  }
}

class ConflictResult {
  final ConflictType type;
  final String? prayerName;
  final DateTime? suggestedTime;

  ConflictResult({required this.type, this.prayerName, this.suggestedTime});
}
