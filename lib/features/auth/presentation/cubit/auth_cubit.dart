import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authStateSubscription;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _startAuthListener();
  }

  void _startAuthListener() {
    final currentUser = _authRepository.getCurrentUser();
    if (currentUser != null) {
      _loadUserProfile();
    } else {
      // لا نرسل Unauthenticated فوراً إذا أردنا حفظ حالة الضيف سابقاً
      // ولكن للتبسيط، سنرسلها والواجهة ستخيره
      emit(AuthUnauthenticated());
    }

    _authStateSubscription = _authRepository.authStateChanges.listen((data) {
      final event = data.event;
      final session = data.session;

      if ((event == AuthChangeEvent.signedIn ||
              event == AuthChangeEvent.tokenRefreshed ||
              event == AuthChangeEvent.initialSession) &&
          session != null) {
        if (state is! AuthAuthenticated) {
          _loadUserProfile();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        emit(AuthUnauthenticated());
      }
    });
  }

  // ✅ دالة الدخول كضيف
  void loginAsGuest() {
    // يمكن هنا حفظ flag في SharedPreferences أن المستخدم اختار "ضيف"
    // لتجاوز شاشة الدخول مستقبلاً (اختياري)
    emit(AuthGuest());
  }

  Future<void> _loadUserProfile() async {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      try {
        await getIt<SpaceRepository>().claimLocalSpaces(user.id);
        await getIt<HabitRepository>().fixMissingUserIds(user.id);
        await getIt<SettingsRepository>().ensureAthkarSeeding(user.id);
      } catch (e) {
        // Log error
      }

      try {
        // محاولة جلب البيانات من السحابة
        final profile = await _authRepository.getUserProfile();

        if (profile == null) {
          emit(AuthProfileIncomplete(userId: user.id, email: user.email ?? ''));
          return;
        }

        emit(
          AuthAuthenticated(
            profile['username'] ?? 'user',
            fullName: profile['full_name'],
          ),
        );
      } catch (e) {
        // ✅✅ دعم الأوفلاين (Offline Support)
        // إذا فشل الاتصال، لا نمنع المستخدم من الدخول!
        // نستخدم البيانات المخزنة محلياً في جلسة Supabase (MetaData)
        print("Offline mode or Error loading profile: $e");

        final metaData = user.userMetadata;
        final savedName = metaData?['full_name'] ?? 'مستخدم';
        final savedUsername = metaData?['username'] ?? 'user';

        emit(AuthAuthenticated(savedUsername, fullName: savedName));
      }
    }
  }

  // ... (بقية الدوال: signUp, updateProfile, signIn كما هي تماماً)
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
      );
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        await getIt<SettingsRepository>().ensureAthkarSeeding(user.id);
        await _loadUserProfile();
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      String msg = "حدث خطأ غير متوقع: ${e.toString()}";
      if (e.toString().contains("User already registered") ||
          e.toString().contains("23505")) {
        msg = "البريد الإلكتروني مسجل مسبقاً";
      }
      if (e.toString().contains("username_key") ||
          e.toString().contains("username")) {
        msg = "اسم المستخدم هذا محجوز، اختر اسماً آخر";
      }
      if (e.toString().contains("weak_password")) {
        msg = "كلمة المرور ضعيفة، يجب أن تكون 6 أحرف على الأقل";
      }
      emit(AuthError(msg));
    }
  }

  Future<void> updateProfile(String fullName, String username) async {
    emit(AuthLoading());
    try {
      await _authRepository.updateProfile(
        fullName: fullName,
        username: username,
      );
      await _loadUserProfile();
    } catch (e) {
      emit(AuthError("فشل تحديث البيانات: ${e.toString()}"));
      await _loadUserProfile();
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(email: email, password: password);
    } catch (e) {
      String msg = "فشل تسجيل الدخول، تأكد من البيانات";
      if (e.toString().contains("Invalid login credentials")) {
        msg = "البريد الإلكتروني أو كلمة المرور غير صحيحة";
      }
      emit(AuthError(msg));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      emit(AuthError("فشل تسجيل الخروج"));
    }
  }

  Future<void> completeProfileData({
    required String fullName,
    required String username,
  }) async {
    emit(AuthLoading());
    final user = _authRepository.getCurrentUser();

    if (user != null) {
      try {
        await _authRepository.createDefaultProfile(
          userId: user.id,
          email: user.email ?? '',
          fullName: fullName,
          username: username,
        );
        await _loadUserProfile();
      } catch (e) {
        String errorMsg = "فشل حفظ البيانات";
        if (e.toString().contains("username_key") ||
            e.toString().contains("duplicate")) {
          errorMsg = "اسم المستخدم هذا محجوز، يرجى اختيار اسم آخر";
        } else {
          errorMsg = "حدث خطأ: $e";
        }
        emit(AuthError(errorMsg));
        emit(AuthProfileIncomplete(userId: user.id, email: user.email ?? ''));
      }
    }
  }

  Future<void> deleteAccount({required bool keepLocalData}) async {
    emit(AuthLoading());

    final currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) return;

    try {
      if (keepLocalData) {
        await getIt<SpaceRepository>().migrateDataForGuest(currentUser.id);
        await getIt<HabitRepository>().migrateDataForGuest(currentUser.id);
      } else {
        await getIt<SpaceRepository>().clearAllLocalData();
        await getIt<HabitRepository>().clearAllHabits();
        await getIt<SettingsRepository>().updateSettings(UserSettings());
      }

      await _authRepository.deleteAccount();
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError("حدث خطأ أثناء الحذف: $e"));
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
