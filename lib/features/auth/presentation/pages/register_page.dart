import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_text_field.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/responsive_wrapper.dart';
import 'package:athar/core/utils/responsive_helper.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/deep_link_service.dart';
import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';

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
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state is AuthAuthenticated) {
            getIt<SyncCubit>().triggerSync();
            getIt<DeepLinkService>().checkPendingInvites();
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context, colorScheme, canPop, isTablet),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 48 : 24.w,
                      vertical: isTablet ? 32 : 24.h,
                    ),
                    child: ResponsiveWrapper.form(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AtharTextField(
                              label: "الاسم الكامل",
                              controller: _nameController,
                              prefixIcon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                              validator: (val) =>
                                  (val == null || val.isEmpty) ? "مطلوب" : null,
                            ),
                            AtharGap.lg,

                            AtharTextField(
                              label: "اسم المستخدم",
                              hint: "بدون مسافات أو رموز خاصة",
                              controller: _usernameController,
                              prefixIcon: Icons.alternate_email,
                              textInputAction: TextInputAction.next,
                              validator: (val) {
                                if (val == null || val.isEmpty) return "مطلوب";
                                if (val.length < 3) return "3 أحرف على الأقل";
                                return null;
                              },
                            ),
                            AtharGap.lg,

                            AtharTextField(
                              label: "البريد الإلكتروني",
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (val) {
                                if (val == null || val.isEmpty) return "مطلوب";
                                final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.\w{2,}$');
                                if (!emailRegex.hasMatch(val.trim())) {
                                  return "بريد إلكتروني غير صحيح";
                                }
                                return null;
                              },
                            ),
                            AtharGap.lg,

                            AtharTextField(
                              label: "كلمة المرور",
                              controller: _passwordController,
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleRegister(),
                              validator: (val) =>
                                  (val == null || val.length < 8) ? "8 خانات على الأقل" : null,
                            ),
                            AtharGap.xxxl,

                            state is AuthLoading
                                ? const Center(child: CircularProgressIndicator())
                                : AtharButton(
                                    label: "إنشاء الحساب",
                                    variant: AtharButtonVariant.primary,
                                    size: isTablet ? AtharButtonSize.large : AtharButtonSize.medium,
                                    isFullWidth: true,
                                    onPressed: _handleRegister,
                                  ),

                            AtharGap.lg,

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "لديك حساب بالفعل؟",
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: isTablet ? 15 : 13.sp,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (canPop) {
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.pushReplacementNamed(context, '/login');
                                    }
                                  },
                                  child: Text(
                                    "تسجيل الدخول",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 15 : 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    bool canPop,
    bool isTablet,
  ) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: (isTablet ? 40.0 : 32.h) + statusBarHeight,
        bottom: isTablet ? 32 : 28.h,
        left: isTablet ? 48 : 24.w,
        right: isTablet ? 48 : 24.w,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.75)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canPop)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          if (canPop) const SizedBox(height: 16),
          const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
          const SizedBox(height: 12),
          Text(
            "انضم لعائلة أثر",
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 28 : 26.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "أنشئ حسابك وابدأ رحلتك الإنتاجية",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: isTablet ? 14 : 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
      );
    }
  }
}
