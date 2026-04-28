import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> deleteAccount();

  User? getCurrentUser();

  Future<Map<String, dynamic>?> getUserProfile();

  Future<void> updateProfile({
    required String fullName,
    required String username,
  });

  // ✅ التعديل هنا: جعل الاسم واليوزرنيم اختياريين
  // إذا تم تمريرهما، نستخدمهما. وإلا، نستخدم القيم الافتراضية.
  Future<void> createDefaultProfile({
    required String userId,
    required String email,
    String? fullName,
    String? username,
  });

  /// Returns the email stored in profiles for the given username, or null.
  Future<String?> getEmailByUsername(String username);

  /// Sends a password-reset email to [email].
  Future<void> sendPasswordResetEmail(String email);

  /// Sends a 6-digit OTP to [email] for password reset.
  Future<void> sendOtpForPasswordReset(String email);

  /// Verifies [otp] for [email] and signs the user in temporarily.
  Future<void> verifyOtpForPasswordReset({
    required String email,
    required String otp,
  });

  /// Updates the current user's password (call after OTP verification).
  Future<void> updatePassword(String newPassword);

  /// Signs in natively with Apple (iOS only).
  Future<void> signInWithApple();

  Stream<AuthState> get authStateChanges;
}
