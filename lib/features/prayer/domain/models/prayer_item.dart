/// ❌ DEPRECATED: Use PrayerTime from prayer feature instead
///
/// هذا الكلاس كان خطأ معماري - الصلاة لا تنتمي لـ Task feature!
/// استخدم PrayerTime بدلاً منه.
@Deprecated(
  'Use PrayerTime from features/prayer/domain/entities/prayer_time.dart instead. '
  'This class will be removed in a future version.',
)
class PrayerItem {
  final String name;
  final DateTime time;
  final bool isNext;

  PrayerItem({required this.name, required this.time, this.isNext = false});
}
