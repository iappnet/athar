import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/design_system/atoms/inputs/app_text_field.dart';
import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

// ✅ 1. إضافة استيرادات الحقن والمزامنة
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      appBar: const AtharAppBar(
        title: "إنشاء حساب جديد",
        showActions: false,
        actions: null,
      ),

      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthAuthenticated) {
            // ✅✅ التعديل الجوهري هنا ✅✅
            // بما أن هذا حساب جديد، السحابة فارغة بالتأكيد.
            // نقوم بتشغيل المزامنة فوراً لرفع البيانات المحلية (Push) إلى الحساب الجديد.
            getIt<SyncCubit>().triggerSync();

            // ثم ننتقل للصفحة الرئيسية
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "انضم لعائلة أثر",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // الاسم الكامل
                    AtharTextField(
                      label: "الاسم الكامل",
                      controller: _nameController,
                      icon: Icons.person_outline,
                      validator: (val) => val!.isEmpty ? "مطلوب" : null,
                    ),
                    SizedBox(height: 16.h),

                    // اسم المستخدم
                    AtharTextField(
                      label: "اسم المستخدم (Username)",
                      controller: _usernameController,
                      icon: Icons.alternate_email,
                      validator: (val) {
                        if (val!.isEmpty) return "مطلوب";
                        if (val.length < 3) return "3 أحرف على الأقل";
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // البريد
                    AtharTextField(
                      label: "البريد الإلكتروني",
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      validator: (val) =>
                          !val!.contains('@') ? "بريد غير صحيح" : null,
                    ),
                    SizedBox(height: 16.h),

                    // كلمة المرور
                    AtharTextField(
                      label: "كلمة المرور",
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (val) =>
                          val!.length < 6 ? "6 خانات على الأقل" : null,
                    ),
                    SizedBox(height: 32.h),

                    state is AuthLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().signUp(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  fullName: _nameController.text.trim(),
                                  username: _usernameController.text.trim(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              minimumSize: Size(double.infinity, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "إنشاء الحساب",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),

                    SizedBox(height: 24.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "لديك حساب بالفعل؟",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            if (canPop) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          child: const Text(
                            "تسجيل الدخول",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
