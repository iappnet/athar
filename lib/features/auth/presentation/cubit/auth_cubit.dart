import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authStateSubscription;

  // Suppresses the auth listener during OTP-based password reset so that
  // the temporary sign-in from verifyOTP does not navigate the user home.
  bool _passwordResetMode = false;

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
      if (_passwordResetMode) return;

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
        // Identify user in RevenueCat so entitlements sync per-account.
        try {
          await Purchases.logIn(user.id);
        } catch (_) {}
      } catch (e) {
        // ✅✅ دعم الأوفلاين (Offline Support)
        // إذا فشل الاتصال، لا نمنع المستخدم من الدخول!
        // نستخدم البيانات المخزنة محلياً في جلسة Supabase (MetaData)
        debugPrint("Offline mode or Error loading profile: $e");

        final metaData = user.userMetadata;
        final savedName = metaData?['full_name'] ?? 'مستخدم';
        final savedUsername = metaData?['username'] ?? 'user';

        emit(AuthAuthenticated(savedUsername, fullName: savedName));
        try {
          await Purchases.logIn(user.id);
        } catch (_) {}
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
      final raw = e.toString();
      String msg = "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً";
      if (raw.contains("User already registered") || raw.contains("23505")) {
        msg = "البريد الإلكتروني مسجل مسبقاً";
      } else if (raw.contains("username_key") || raw.contains("username")) {
        msg = "اسم المستخدم هذا محجوز، اختر اسماً آخر";
      } else if (raw.contains("weak_password")) {
        msg = "كلمة المرور ضعيفة، يجب أن تكون 8 أحرف على الأقل";
      }
      assert(() { debugPrint('[AuthCubit.signUp] $e'); return true; }());
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
      assert(() { debugPrint('[AuthCubit.updateProfile] $e'); return true; }());
      emit(AuthError("فشل تحديث البيانات، يرجى المحاولة لاحقاً"));
      await _loadUserProfile();
    }
  }

  Future<void> signIn(String emailOrUsername, String password) async {
    emit(AuthLoading());
    try {
      String email = emailOrUsername.trim();
      if (!email.contains('@')) {
        final resolved = await _authRepository.getEmailByUsername(email);
        if (resolved != null && resolved.isNotEmpty) {
          email = resolved;
        }
      }
      await _authRepository.signIn(email: email, password: password);
    } catch (e) {
      String msg = "فشل تسجيل الدخول، تأكد من البيانات";
      if (e.toString().contains("Invalid login credentials")) {
        msg = "اسم المستخدم أو البريد الإلكتروني أو كلمة المرور غير صحيحة";
      }
      emit(AuthError(msg));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      assert(() { debugPrint('[AuthCubit.sendPasswordResetEmail] $e'); return true; }());
      rethrow;
    }
  }

  String? get currentUserEmail => _authRepository.getCurrentUser()?.email;

  Future<void> sendOtpForPasswordReset(String email) async {
    await _authRepository.sendOtpForPasswordReset(email);
  }

  // Verifies OTP for an already-logged-in user (no mode flag needed since
  // the auth listener already guards against re-navigating AuthAuthenticated).
  Future<void> verifyOtpOnly({
    required String email,
    required String otp,
  }) async {
    await _authRepository.verifyOtpForPasswordReset(email: email, otp: otp);
  }

  Future<void> updatePasswordOnly(String newPassword) async {
    await _authRepository.updatePassword(newPassword);
  }

  Future<void> verifyOtpForPasswordReset({
    required String email,
    required String otp,
  }) async {
    _passwordResetMode = true;
    try {
      await _authRepository.verifyOtpForPasswordReset(email: email, otp: otp);
    } catch (e) {
      _passwordResetMode = false;
      rethrow;
    }
  }

  Future<void> updatePasswordAndFinishReset(String newPassword) async {
    try {
      await _authRepository.updatePassword(newPassword);
      await _authRepository.signOut();
    } finally {
      _passwordResetMode = false;
      emit(AuthUnauthenticated());
    }
  }

  // Called if the sheet is dismissed after OTP verification but before password update.
  Future<void> cancelPasswordReset() async {
    _passwordResetMode = false;
    try {
      await _authRepository.signOut();
    } catch (_) {}
    emit(AuthUnauthenticated());
  }

  Future<void> signInWithApple() async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithApple();
      // auth listener handles navigation via _loadUserProfile
    } catch (e) {
      final msg = e.toString().contains('canceled')
          ? 'تم إلغاء تسجيل الدخول'
          : 'فشل تسجيل الدخول عبر Apple، يرجى المحاولة لاحقاً';
      emit(AuthError(msg));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      try {
        await Purchases.logOut();
      } catch (_) {}
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
          assert(() { debugPrint('[AuthCubit.completeProfileData] $e'); return true; }());
          errorMsg = "فشل حفظ البيانات، يرجى المحاولة لاحقاً";
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
