import '../../features/settings/data/models/user_settings.dart';
import '../../features/settings/data/models/time_range.dart';

class SmartZoneHelper {
  /// ترجع مفتاح المنطقة الحالية (work, home, free, quiet, sleep)
  /// يتم استخدامه لاحقاً لمطابقته مع اسم أو ID التصنيف
  static String getCurrentZoneKey(UserSettings settings) {
    // 1. إذا كان الوضع التلقائي معطلاً، نعود للوضع الحر (أو الافتراضي)
    if (!settings.isAutoModeEnabled) return 'free';

    final now = DateTime.now();

    // 2. التحقق من وقت العمل (يتطلب تحقق من الأيام + الساعات)
    if (_isWorkTime(now, settings)) {
      return 'work';
    }

    // 3. التحقق من وقت الأهل/المنزل
    if (_isInPeriod(now, settings.familyPeriodsSafe)) {
      return 'home';
    }

    // 4. التحقق من وقت الهدوء/الشخصي
    if (_isInPeriod(now, settings.quietPeriodsSafe)) {
      return 'quiet'; // يمكن ربطه بتصنيف "شخصي" أو "هدوء"
    }

    // 5. التحقق من الوقت الحر (إذا كان معرفاً بفترات محددة)
    if (_isInPeriod(now, settings.freePeriodsSafe)) {
      return 'free';
    }

    // 6. إذا لم ينطبق أي شيء، نعتبره وقتاً حراً افتراضياً
    return 'personal';
  }

  // --- الدوال المساعدة (Helpers) ---

  /// تتحقق هل الوقت الحالي يقع ضمن ساعات وأيام العمل
  static bool _isWorkTime(DateTime now, UserSettings settings) {
    // أ) التحقق من أيام العمل (Work Days)
    // DateTime.weekday: 1 = Monday, ..., 7 = Sunday
    // تأكد أن settings.workDaysSafe تحتوي على أرقام مطابقة
    if (settings.workDaysSafe.isNotEmpty) {
      if (!settings.workDaysSafe.contains(now.weekday)) {
        return false; // اليوم ليس يوم عمل
      }
    }

    // ب) التحقق من ساعات العمل (Work Periods)
    return _isInPeriod(now, settings.workPeriodsSafe);
  }

  /// دالة عامة تتحقق هل الوقت الحالي يقع داخل أي فترة من قائمة الفترات
  static bool _isInPeriod(DateTime now, List<TimeRange> periods) {
    if (periods.isEmpty) return false;

    for (var period in periods) {
      // TimeRange يحتوي بالفعل على دالة contains(DateTime) كما عرفناها سابقاً
      if (period.contains(now)) {
        return true;
      }
    }
    return false;
  }
}
