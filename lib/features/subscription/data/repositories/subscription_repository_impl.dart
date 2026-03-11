import 'package:injectable/injectable.dart';
import '../../domain/repositories/subscription_repository.dart';

@LazySingleton(as: SubscriptionRepository)
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  @override
  Future<bool> isProUser() async {
    // ---------------------------------------------------------
    // 🛠️ وضع التطوير (Development Mode)
    // ---------------------------------------------------------
    // نرجح true دائماً لنتمكن من بناء واختبار ميزات المزامنة.
    // لاحقاً، سنغير هذا السطر ليتحقق من جدول 'subscriptions' في Supabase
    // أو من RevenueCat.

    await Future.delayed(const Duration(milliseconds: 100)); // محاكاة اتصال
    return true;
  }

  @override
  Future<String?> getPlanName() async {
    return "Premium (Dev)";
  }
}
