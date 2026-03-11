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
    String? fullName, // جديد
    String? username, // جديد
  });

  Stream<AuthState> get authStateChanges;
}
