import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    try {
      // 1. إنشاء المستخدم في نظام المصادقة
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        // نرسل البيانات الوصفية (Metadata) أيضاً لضمان وجودها في التوكن
        data: {'full_name': fullName, 'username': username},
      );

      if (response.user == null) {
        throw AuthException("فشل إنشاء الحساب");
      }

      final userId = response.user!.id;

      // 2. تحديث بيانات البروفايل (الحل الجذري للمشكلة)
      // نستخدم upsert بدلاً من insert لسببين:
      // أ. لتفادي التعارض مع التريجر (إذا أنشأ التريجر الصف، نقوم نحن بتحديثه).
      // ب. إذا تأخر التريجر، نقوم نحن بإنشاء الصف.

      final profileData = {
        'user_id': userId,
        'full_name': fullName,
        'username': username,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Try saving with email (requires an `email` column in profiles).
      // Fall back gracefully if the column doesn't exist yet.
      try {
        await _supabase.from('profiles').upsert(
          {...profileData, 'email': email.trim().toLowerCase()},
          onConflict: 'user_id',
        );
      } catch (_) {
        await _supabase.from('profiles').upsert(
          profileData,
          onConflict: 'user_id',
        );
      }
    } on AuthException catch (e) {
      // معالجة خاصة لأخطاء المصادقة
      throw e.message;
    } catch (e) {
      // طباعة الخطأ الحقيقي للمطور
      debugPrint("SignUp Error Details: $e");
      throw "حدث خطأ غير متوقع أثناء إنشاء الحساب";
    }
  }

  // @override
  // Future<void> signUp({
  //   required String email,
  //   required String password,
  //   required String fullName,
  //   required String username,
  // }) async {
  //   // نرسل البيانات الإضافية (الاسم واليوزرنيم) كـ MetaData
  //   // ليقوم التريغر في قاعدة البيانات بإنشاء البروفايل تلقائياً
  //   await _supabase.auth.signUp(
  //     email: email,
  //     password: password,
  //     data: {
  //       'full_name': fullName,
  //       'username': username, // هذا المفتاح مهم جداً
  //     },
  //   );
  // }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ✅ 2. تنفيذ دالة حذف الحساب
  @override
  Future<void> deleteAccount() async {
    try {
      // استدعاء الدالة الآمنة من قاعدة البيانات
      await _supabase.rpc('delete_user_account');

      // // تسجيل الخروج محلياً لتنظيف الجلسة
      // await _supabase.auth.signOut();
    } catch (e) {
      throw "فشل حذف الحساب: $e";
    }
  }

  @override
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle(); // ✅ استخدمنا maybeSingle بدلاً من single لمنع الانهيار
    return response;
  }

  // ✅ تنفيذ دالة الإنشاء الذاتي
  // ✅✅ التعديل الجذري هنا
  @override
  Future<void> createDefaultProfile({
    required String userId,
    required String email,
    String? fullName,
    String? username,
  }) async {
    // 1. تحديد القيم النهائية: إما القيمة الممررة أو القيمة الافتراضية
    final finalUsername = username ?? email.split('@')[0];
    final finalFullName = fullName ?? 'مستخدم جديد';

    final profileData = {
      'user_id': userId,
      'full_name': finalFullName,
      'username': finalUsername,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // 2. عملية واحدة (Atomic Operation) لضمان الحفظ
    await _supabase.from('profiles').upsert(profileData, onConflict: 'user_id');
  }

  @override
  Future<String?> getEmailByUsername(String username) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('email')
          .eq('username', username.trim().toLowerCase())
          .maybeSingle();
      return response?['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email.trim().toLowerCase());
  }

  @override
  Future<void> sendOtpForPasswordReset(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email.trim().toLowerCase(),
      shouldCreateUser: false,
    );
  }

  @override
  Future<void> verifyOtpForPasswordReset({
    required String email,
    required String otp,
  }) async {
    await _supabase.auth.verifyOTP(
      email: email.trim().toLowerCase(),
      token: otp.trim(),
      type: OtpType.email,
    );
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: credential.identityToken!,
      nonce: rawNonce,
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    required String username,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("لا يوجد مستخدم مسجل");

    await _supabase
        .from('profiles')
        .update({
          'full_name': fullName,
          'username': username,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', user.id);
  }

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
