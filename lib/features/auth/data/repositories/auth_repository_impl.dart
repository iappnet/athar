import 'package:injectable/injectable.dart';
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
        'user_id': userId, // ✅ تصحيح: استخدام الاسم الجديد user_id بدلاً من id
        'full_name': fullName, // تأكد أن هذه الأعمدة موجودة في جدول profiles
        'username': username,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // نستخدم upsert لضمان النجاح في الحالتين
      await _supabase
          .from('profiles')
          .upsert(
            profileData,
            onConflict: 'user_id', // ✅ مهم جداً: تحديد عمود التعارض
          );
    } on AuthException catch (e) {
      // معالجة خاصة لأخطاء المصادقة
      throw e.message;
    } catch (e) {
      // طباعة الخطأ الحقيقي للمطور
      print("SignUp Error Details: $e");
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
