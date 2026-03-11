import '../../data/models/habit_model.dart';

abstract class HabitRepository {
  /// مراقبة تدفق العادات (Stream) لتحديث الواجهة تلقائياً
  Stream<List<HabitModel>> watchHabits();

  /// إضافة عادة جديدة
  Future<void> addHabit(HabitModel habit);

  /// تحديث بيانات عادة موجودة
  Future<void> updateHabit(HabitModel habit);

  /// حذف عادة
  Future<void> deleteHabit(int id);

  /// تسجيل الإنجاز أو إلغاؤه (Toggle)
  Future<void> toggleHabit(int id);

  /// التأكد من وجود عادات النظام (أذكار الصباح والمساء)
  Future<void> ensureSystemHabits();

  /// إعادة تعيين الأذكار للافتراضي
  Future<void> resetAthkarToDefault(int habitId);

  // ---------------------------------------------------------------------------
  // ✅ دوال جديدة لدعم المزامنة الذكية (Smart Sync)
  // ---------------------------------------------------------------------------

  /// التحقق مما إذا كان المستخدم قد تفاعل مع العادات محلياً (هل البيانات "معدلة"؟)
  /// يعيد true إذا كان هناك أي تقدم أو إنجاز سابق
  Future<bool> hasUserInteractedWithHabits();

  /// حذف جميع العادات المحلية
  /// (يستخدم عند قرار استبدال البيانات المحلية بنسخة السحابة)
  Future<void> clearAllHabits();

  // ✅✅ أضف هذا السطر لتعريف الدالة
  Future<void> fixMissingUserIds(String userId);

  // ✅ الدوال الجديدة
  Future<void> migrateDataForGuest(String oldUserId);
  // clearAllHabits موجودة سابقاً، سنستخدمها
  // ═══════════════════════════════════════════════════════════
  // ✅ دوال جديدة للإشعارات
  // ═══════════════════════════════════════════════════════════
  /// جلب جميع العادات ذات التذكيرات المُفعّلة
  Future<List<HabitModel>> getHabitsWithReminders();

  /// جلب عادة واحدة بالـ UUID
  Future<HabitModel?> getHabitByUuid(String uuid);
}
