/// هذا العقد يحدد كيفية التحقق من حالة الاشتراك
/// سواء كان من Supabase أو من Apple/Google Store مستقبلاً
abstract class SubscriptionRepository {
  /// هل المستخدم لديه اشتراك فعال؟
  Future<bool> isProUser();

  /// (اختياري مستقبلاً) جلب تفاصيل الخطة
  Future<String?> getPlanName();
}
