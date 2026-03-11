import 'dart:async';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/user_settings.dart'; // تأكد أن الـ Enum موجود هنا
import 'package:athar/features/settings/data/models/time_range.dart';
import '../../../../core/services/biometric_service.dart'; // ✅ استيراد خدمة البصمة

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;
  final BiometricService _biometricService; // ✅ 1. حقن خدمة البصمة
  // final AuthRepository _authRepository; // ✅ 1. إضافة AuthRepository

  StreamSubscription? _settingsSubscription;

  SettingsCubit(
    this._repository,
    // this._authRepository
    this._biometricService, // ✅ إضافتها للبناء
  ) : super(SettingsInitial());
  // تحميل الإعدادات وبدء المراقبة
  // استبدل دالة loadSettings بهذا الكود النظيف
  Future<void> loadSettings() async {
    // لا نضع emit(Loading) هنا إذا كانت البيانات موجودة لمنع وميض الشاشة
    if (state is! SettingsLoaded) emit(SettingsLoading());

    await _settingsSubscription?.cancel();

    // 🛑 تم نقل ensureAthkarSeeding إلى AuthCubit عند تسجيل الدخول
    // لكي تعمل مرة واحدة فقط ولا تسبب تعليق المزامنة.

    _settingsSubscription = _repository.watchSettings().listen((settings) {
      emit(SettingsLoaded(settings));
    });
  }

  // ✅ دالة تبديل البصمة الذكية
  // تعيد true إذا نجحت العملية، و false إذا فشلت المصادقة
  Future<bool> toggleBiometric(bool enable) async {
    if (enable) {
      // 1. إذا أراد التفعيل، نطلب البصمة أولاً للتأكد من هوية المالك
      final success = await _biometricService.authenticate();
      if (success) {
        final currentSettings = await _repository.getSettings();
        currentSettings.isBiometricEnabled = true;
        await _repository.updateSettings(currentSettings);
        return true;
      } else {
        return false; // فشل التحقق، لا نفعل الخيار
      }
    } else {
      // 2. عند التعطيل، نعطل فوراً
      final currentSettings = await _repository.getSettings();
      currentSettings.isBiometricEnabled = false;
      await _repository.updateSettings(currentSettings);
      return true;
    }
  }

  // --- دوال الأذكار الجديدة ---

  // تفعيل أو تعطيل الأذكار
  Future<void> toggleAthkarFeature(bool isEnabled) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      currentSettings.isAthkarEnabled = isEnabled;
      await updateSettings(currentSettings);
    }
  }

  // تغيير نمط العرض (منفصل / مدمج)
  Future<void> updateAthkarDisplayMode(AthkarDisplayMode mode) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      currentSettings.athkarDisplayMode = mode;
      await updateSettings(currentSettings);
    }
  }

  // ✅ تحديث فترات الأهل
  Future<void> updateFamilyPeriods(List<TimeRange> newPeriods) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.familyPeriods = newPeriods;
    await _repository.updateSettings(currentSettings);
  }

  // ✅ تحديث الفترات الحرة
  Future<void> updateFreePeriods(List<TimeRange> newPeriods) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.freePeriods = newPeriods;
    await _repository.updateSettings(currentSettings);
  }

  // ✅ دالة لربط منطقة بتصنيف معين (مثلاً: ربط وقت العمل بتصنيف "دراسة")
  Future<void> mapZoneToCategory({
    required String zoneType, // 'work', 'family', 'free', 'quiet'
    required int categoryId,
  }) async {
    final currentSettings = await _repository.getSettings();

    switch (zoneType) {
      case 'work':
        currentSettings.workCategoryId = categoryId;
        break;
      case 'family':
        currentSettings.familyCategoryId = categoryId;
        break;
      case 'free':
        currentSettings.freeCategoryId = categoryId;
        break;
      case 'quiet':
        currentSettings.quietCategoryId = categoryId;
        break;
    }

    await _repository.updateSettings(currentSettings);
  }

  // ✅✅ هذه هي الدالة المفقودة التي يجب إضافتها لإصلاح الخطأ ✅✅
  Future<void> updateSettings(UserSettings settings) async {
    try {
      await _repository.updateSettings(settings);
    } catch (e) {
      // emit(SettingsError("فشل تحديث الإعدادات: $e"));
    }
  }

  // ✅ دالة تحديث أيام العمل
  Future<void> updateWorkDays(List<int> days) async {
    final currentSettings = await _repository.getSettings();
    // نقوم بنسخ القائمة وتحديثها
    currentSettings.workDays = List.from(days);
    await _repository.updateSettings(currentSettings);
  }

  // ✅ دالة تبديل التقويم (هجري / ميلادي)
  Future<void> toggleHijriMode(bool value) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.isHijriMode = value;
    await _repository.updateSettings(currentSettings);
    // الستريم سيحدث الواجهات تلقائياً
  }

  // ✅✅ دالة جديدة لتبديل المزامنة التلقائية
  Future<void> toggleAutoSync(bool isEnabled) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.isAutoSyncEnabled = isEnabled;
    await _repository.updateSettings(currentSettings);
  }

  // ✅ دالة جديدة لتغيير نمط جلسة الأذكار
  Future<void> updateAthkarSessionViewMode(AthkarSessionViewMode mode) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      currentSettings.athkarSessionViewMode = mode;
      await updateSettings(currentSettings);
    }
  }

  // --- دوال التحديث (تقوم بالحفظ في الـ DB فقط، والستريم سيحدث الواجهة) ---

  Future<void> updateWorkPeriods(List<TimeRange> newPeriods) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.workPeriods = newPeriods;
    await _repository.updateSettings(currentSettings);
  }

  Future<void> updateQuietPeriods(List<TimeRange> newPeriods) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.quietPeriods = newPeriods;
    await _repository.updateSettings(currentSettings);
  }

  Future<void> updateSleepPeriods(List<TimeRange> newPeriods) async {
    final currentSettings = await _repository.getSettings();
    currentSettings.sleepPeriods = newPeriods;
    await _repository.updateSettings(currentSettings);
  }

  Future<void> toggleAutoMode(bool value) async {
    await _repository.toggleAutoMode(value);
    // لا نحتاج لاستدعاء loadSettings() يدوياً لأن watchSettings سيعمل
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel(); // 4. تنظيف الاشتراك عند الإغلاق
    return super.close();
  }
}
