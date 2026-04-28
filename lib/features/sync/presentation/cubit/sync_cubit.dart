import 'package:athar/core/di/injection.dart';
import 'package:athar/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import 'sync_state.dart';

@injectable
class SyncCubit extends Cubit<SyncState> {
  final SyncRepository _syncRepository;
  final SettingsRepository _settingsRepository; // ✅ حقن الإعدادات

  SyncCubit(this._syncRepository, this._settingsRepository)
    : super(SyncInitial());

  /// دالة المزامنة الذكية
  /// [isManual]: إذا كانت true تعني أن المستخدم ضغط الزر بيده، فنتجاهل إعدادات الإغلاق ونظهر أخطاء النت
  Future<void> triggerSync({bool isManual = false}) async {
    // 0. منع التكرار
    if (state is SyncLoading) return;

    // 🛑 1. الحارس الأول: التحقق من المستخدم (ضيف أم مسجل؟)
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // إذا كان ضيفاً، نقتل العملية بصمت فوراً
      return;
    }

    // 🛑 2. الحارس الثاني: التحقق من الاشتراك (المزامنة ميزة مدفوعة)
    final hasSyncAccess = getIt<SubscriptionCubit>().hasSyncAccess;
    if (!hasSyncAccess) return;

    // 🛑 3. الحارس الثالث: التحقق من الإعدادات (للمزامنة التلقائية فقط)
    // إذا كانت المزامنة "تلقائية" (ليست يدوية)، والزر مغلق في الإعدادات -> توقف
    if (!isManual) {
      final settings = await _settingsRepository.getSettings();
      if (!settings.isAutoSyncEnabled) {
        if (kDebugMode) print("Skipping Sync: Auto-sync is disabled by user.");
        return;
      }
    }

    // 🛑 4. الحارس الرابع: التحقق من الإنترنت (Real Connectivity Check)
    final bool hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      if (isManual) {
        // إذا كان المستخدم هو من ضغط الزر، يجب أن نخبره بالحقيقة
        emit(SyncError("لا يوجد اتصال بالإنترنت"));
        await Future.delayed(const Duration(seconds: 3));
        emit(SyncInitial());
      } else {
        // أما إذا كانت تلقائية، نفشل بصمت لكي لا نزعجه
        if (kDebugMode) print("Skipping Sync: No Internet.");
      }
      return;
    }

    // ✅✅ الضوء الأخضر: ابدأ المزامنة
    emit(SyncLoading());

    try {
      await _syncRepository.syncEverything();

      emit(SyncSuccess());

      await Future.delayed(const Duration(seconds: 2));
      emit(SyncInitial());
    } on SyncSkippedException catch (e) {
      // استثناءات التخطي من الـ Repository
      if (kDebugMode) {
        print("Sync Skipped Logic: ${e.reason}");
      }
      emit(SyncInitial());
    } catch (e) {
      // الأخطاء الحقيقية
      final msg = e.toString().replaceAll("Exception: ", "");

      // لا نظهر الخطأ للمستخدم إلا إذا كانت المزامنة يدوية أو الخطأ جسيم
      if (isManual) {
        emit(SyncError(msg));
        await Future.delayed(const Duration(seconds: 3));
      } else {
        if (kDebugMode) print("Auto-Sync Failed silently: $msg");
      }

      emit(SyncInitial());
    }
  }
}
