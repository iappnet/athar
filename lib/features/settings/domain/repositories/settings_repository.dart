import '../../data/models/user_settings.dart';

/// واجهة المستودع (العقد)
abstract class SettingsRepository {
  /// جلب الإعدادات الحالية
  Future<UserSettings> getSettings();

  /// تحديث الإعدادات بالكامل
  Future<void> updateSettings(UserSettings settings);

  /// مراقبة تغييرات الإعدادات (Stream)
  Stream<UserSettings> watchSettings();

  /// تفعيل أو تعطيل الوضع التلقائي
  Future<void> toggleAutoMode(bool isEnabled);

  Future<void> ensureAthkarSeeding(String userId);
}
