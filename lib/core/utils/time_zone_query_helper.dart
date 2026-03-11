import 'package:athar/features/settings/data/models/time_range.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:isar/isar.dart';

/// ✅ مساعد لاستعلامات الوقت في حالة الورديات الليلية
///
/// نسخة مُصلحة - متوافقة مع TaskModel
class TimeZoneQueryHelper {
  // ═══════════════════════════════════════════════════════════
  // 🌙 TIME RANGE CHECKS
  // ═══════════════════════════════════════════════════════════

  /// ✅ التحقق مما إذا كان الوقت الحالي ضمن فترة (مع دعم الورديات الليلية)
  static bool isTimeInRange({
    required DateTime currentTime,
    required TimeRange range,
  }) {
    return range.contains(currentTime);
  }

  // ═══════════════════════════════════════════════════════════
  // 🏷️ CATEGORY FILTERING
  // ═══════════════════════════════════════════════════════════

  /// ✅ فلترة المهام حسب Smart Zone (مع معالجة الورديات الليلية)
  static List<TaskModel> filterTasksByZone({
    required List<TaskModel> tasks,
    required String currentZone,
    required UserSettings settings,
  }) {
    // الحصول على categoryId للمنطقة الحالية
    final categoryId = _getCategoryForZone(currentZone, settings);

    if (categoryId == null) {
      return tasks; // لا فلترة
    }

    // فلترة المهام
    return tasks.where((task) => task.categoryId == categoryId).toList();
  }

  /// ✅ الحصول على categoryId من المنطقة
  static int? _getCategoryForZone(String zone, UserSettings settings) {
    final now = DateTime.now();
    List<TimeRange> periods;

    switch (zone) {
      case 'work':
        periods = settings.workPeriodsSafe;
        break;
      case 'home':
        periods = settings.familyPeriodsSafe;
        break;
      case 'quiet':
        periods = settings.quietPeriodsSafe;
        break;
      case 'free':
        periods = settings.freePeriodsSafe;
        break;
      default:
        return null;
    }

    // البحث عن الفترة الحالية
    for (final period in periods) {
      if (period.contains(now) && period.categoryId != null) {
        return period.categoryId;
      }
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // 🗄️ ISAR QUERIES (مع معالجة الورديات الليلية)
  // ═══════════════════════════════════════════════════════════

  /// ✅ استعلام Isar للمهام في فترة زمنية محددة
  ///
  /// يدعم الورديات الليلية (مثل 22:00 - 04:00)
  static Future<List<TaskModel>> queryTasksForTimeRange({
    required Isar isar,
    required TimeRange range,
  }) async {
    // نستعلم عن جميع المهام في اليوم
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final allTasks = await isar.taskModels
        .filter()
        .dateGreaterThan(startOfDay)
        .and()
        .dateLessThan(endOfDay)
        .findAll();

    // فلترة يدوية حسب الوقت
    return allTasks.where((task) {
      final taskTime = task.time;
      if (taskTime == null) return false;

      // استخدام TimeRange.contains()
      return range.contains(taskTime);
    }).toList();
  }

  /// ✅ استعلام Isar للمهام في منطقة محددة (Smart Zone)
  static Future<List<TaskModel>> queryTasksForZone({
    required Isar isar,
    required String zone,
    required UserSettings settings,
  }) async {
    // الحصول على categoryId للمنطقة
    final categoryId = _getCategoryForZone(zone, settings);

    if (categoryId == null) {
      return [];
    }

    // استعلام Isar
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await isar.taskModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .and()
        .dateGreaterThan(startOfDay)
        .and()
        .dateLessThan(endOfDay)
        .findAll();
  }

  // ═══════════════════════════════════════════════════════════
  // 🕐 TIME UTILITIES
  // ═══════════════════════════════════════════════════════════

  /// ✅ التحقق: هل الوقت الحالي في فترة عمل؟
  static bool isInWorkPeriod(UserSettings settings) {
    final now = DateTime.now();
    for (final period in settings.workPeriodsSafe) {
      if (period.contains(now)) return true;
    }
    return false;
  }

  /// ✅ التحقق: هل الوقت الحالي في فترة هادئة؟
  static bool isInQuietPeriod(UserSettings settings) {
    final now = DateTime.now();
    for (final period in settings.quietPeriodsSafe) {
      if (period.contains(now)) return true;
    }
    return false;
  }

  /// ✅ الحصول على المنطقة الحالية
  static String? getCurrentZone(UserSettings settings) {
    final now = DateTime.now();

    // ترتيب الأولويات: quiet > work > home > free
    for (final period in settings.quietPeriodsSafe) {
      if (period.contains(now)) return 'quiet';
    }

    for (final period in settings.workPeriodsSafe) {
      if (period.contains(now)) return 'work';
    }

    for (final period in settings.familyPeriodsSafe) {
      if (period.contains(now)) return 'home';
    }

    for (final period in settings.freePeriodsSafe) {
      if (period.contains(now)) return 'free';
    }

    return null; // لا توجد منطقة نشطة
  }
}
