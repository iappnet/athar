import 'package:injectable/injectable.dart';
import '../../features/settings/data/models/user_settings.dart';
import '../../features/prayer/domain/entities/prayer_time.dart'; // ✅ تغيير
import '../../features/task/domain/models/conflict_result.dart';

@lazySingleton
class PrayerConflictService {
  /// التحقق من التعارض بناءً على المناطق الذكية (Smart Zones)
  ConflictResult checkConflict({
    required DateTime taskStartTime,
    required Duration taskDuration, // ✅ مطلوب لحساب فترة التقاطع
    required List<PrayerTime> prayers,
    required UserSettings settings,
  }) {
    // 1. بوابة الإعدادات: إذا عطل المستخدم الصلاة، لا نفحص شيئاً
    if (!settings.isPrayerEnabled) {
      return ConflictResult.none();
    }

    final taskEndTime = taskStartTime.add(taskDuration);

    for (var prayer in prayers) {
      if (prayer.name.contains("الشروق")) continue; // الشروق ليس صلاة فرض

      final azanTime = prayer.time;

      // ✅ القاعدة الذهبية: إذا كانت المهمة تنتهي تماماً قبل الأذان، فلا يوجد تعارض
      if (taskEndTime.isBefore(azanTime) ||
          taskEndTime.isAtSameMomentAs(azanTime)) {
        continue;
      }

      // --- تعريف حدود المناطق الذكية (ديناميكي حسب الصلاة والوضع) ---

      int redZoneMinutes = 20; // المنطقة الحمراء (وقت الفريضة)
      int yellowZoneMinutes = 40; // المنطقة الصفراء (وقت السنن)

      // تخصيص الأوقات
      if (prayer.name.contains("المغرب")) {
        redZoneMinutes = 15;
        yellowZoneMinutes = 25; // وقت المغرب ضيق
      } else if (_isInWorkMode(taskStartTime, settings)) {
        redZoneMinutes = 15; // تقليص وقت الصلاة في العمل
        yellowZoneMinutes = 20; // تقليص وقت الراحة
      }

      final redZoneEnd = azanTime.add(Duration(minutes: redZoneMinutes));
      final yellowZoneEnd = azanTime.add(Duration(minutes: yellowZoneMinutes));

      // --- خوارزميات الفحص (سيناريوهات التعارض) ---

      // السيناريو 1: المهام الطويلة "العابرة" (Bridge Tasks)
      // مثال: مهمة من 11:00 إلى 13:00، والظهر 12:00
      // الشرط: تبدأ قبل الأذان بفترة معتبرة، وتنتهي بعد المنطقة الحمراء
      if (taskStartTime.isBefore(
            azanTime.subtract(const Duration(minutes: 15)),
          ) &&
          taskEndTime.isAfter(redZoneEnd)) {
        return ConflictResult.warning(
          "⚠️ هذه المهمة طويلة ويتخللها وقت صلاة ${prayer.name}.",
          suggestedTime: null, // لا نقترح تغييراً، فقط تذكير
        );
      }

      // السيناريو 2: المنطقة الحمراء (Red Zone - Critical) 🔴
      // أي تداخل مع وقت الفريضة (من الأذان إلى +20 دقيقة)
      // التحقق من التقاطع: (StartA < EndB) && (EndA > StartB)
      if (taskStartTime.isBefore(redZoneEnd) && taskEndTime.isAfter(azanTime)) {
        // وقت مقترح آمن (بعد المنطقة الحمراء + 5 دقائق راحة)
        final suggestedTime = redZoneEnd.add(const Duration(minutes: 5));

        return ConflictResult.alert(
          "⛔ هذا الوقت مخصص لصلاة ${prayer.name} (وقت الفريضة).",
          suggestedTime: suggestedTime,
        );
      }

      // السيناريو 3: المنطقة الصفراء (Yellow Zone - Warning) 🟡
      // التداخل مع وقت السنن أو ما بعد الصلاة مباشرة
      if (taskStartTime.isBefore(yellowZoneEnd) &&
          taskEndTime.isAfter(redZoneEnd)) {
        final remainingTime = yellowZoneEnd.difference(taskStartTime).inMinutes;
        final suggestedTime = yellowZoneEnd.add(const Duration(minutes: 5));

        return ConflictResult.warning(
          "⚠️ وقت ${prayer.name} (سنن/راحة). يفضل البدء بعد $remainingTime دقيقة.",
          suggestedTime: suggestedTime,
        );
      }
    }

    return ConflictResult.none();
  }

  /// التحقق مما إذا كان الوقت الحالي ضمن "وضع العمل" لتقليل فترات الانتظار
  bool _isInWorkMode(DateTime taskTime, UserSettings settings) {
    if (!settings.isAutoModeEnabled) return false;

    // هل اليوم يوم عمل؟
    if (!settings.workDaysSafe.contains(taskTime.weekday)) {
      return false;
    }

    // هل الساعة ضمن ساعات العمل؟
    if (settings.workPeriods != null) {
      for (var period in settings.workPeriodsSafe) {
        if (period.contains(taskTime)) {
          return true;
        }
      }
    }

    return false;
  }
}
