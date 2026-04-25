// lib/features/auth/presentation/pages/login_page.dart
// ✅ النسخة المُصلَّحة مع دعم iPad

import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
import 'package:athar/core/design_system/widgets/athar_text_field.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/responsive_wrapper.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/sync_service.dart';
import 'package:athar/core/utils/responsive_helper.dart'; // ✅ إضافة
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:athar/features/auth/presentation/pages/register_page.dart';
import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ التحقق من نوع الجهاز
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AtharAppBar(
        title: l10n.login,
        showActions: false,
        leading: canPop ? null : const SizedBox(),
        actions: null,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: _handleAuthState,
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                // ✅ تعديل الـ padding حسب الجهاز
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 48 : 24.w,
                  vertical: isTablet ? 32 : 24.h,
                ),
                child: ResponsiveWrapper.form(
                  // ✅ تغليف الفورم
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ✅ العنوان
                        _buildHeader(colorScheme, l10n, isTablet),

                        SizedBox(height: isTablet ? 48 : 40.h),

                        // ✅ حقول الإدخال
                        _buildEmailField(l10n),
                        SizedBox(height: isTablet ? 20 : 16.h),
                        _buildPasswordField(l10n),

                        SizedBox(height: isTablet ? 40 : 32.h),

                        // ✅ أزرار الإجراءات
                        _buildActions(context, state, l10n, isTablet),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // بناء العناصر
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildHeader(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return Column(
      children: [
        Text(
          l10n.welcomeToAthar,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTablet ? 32 : 28.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8.h),
        Text(
          l10n.loginSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14.sp,
            color: colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return AtharTextField(
      label: l10n.email,
      controller: _emailController,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        if (val == null || val.isEmpty) return l10n.required;
        final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.\w{2,}$');
        if (!emailRegex.hasMatch(val.trim())) return 'بريد إلكتروني غير صحيح';
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return AtharTextField(
      label: l10n.password,
      controller: _passwordController,
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      validator: (val) {
        if (val == null || val.isEmpty) return l10n.required;
        if (val.length < 8) return l10n.passwordTooShort;
        return null;
      },
    );
  }

  Widget _buildActions(
    BuildContext context,
    AuthState state,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    if (state is AuthLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // زر تسجيل الدخول
        AtharButton(
          label: l10n.login,
          onPressed: _handleLogin,
          // ✅ ارتفاع مناسب للتابلت
          size: isTablet ? AtharButtonSize.large : AtharButtonSize.medium,
        ),

        SizedBox(height: isTablet ? 20 : 16.h),

        // زر تخطي (الدخول كضيف)
        TextButton(
          onPressed: _handleGuestLogin,
          child: Text(
            l10n.skipAsGuest,
            style: TextStyle(fontSize: isTablet ? 16 : 14.sp),
          ),
        ),

        SizedBox(height: isTablet ? 16 : 12.h),

        // رابط إنشاء حساب
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.noAccount,
              style: TextStyle(fontSize: isTablet ? 15 : 13.sp),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
              child: Text(
                l10n.createAccount,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // الأحداث
  // ═══════════════════════════════════════════════════════════════════

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _handleGuestLogin() {
    context.read<AuthCubit>().loginAsGuest();
  }

  Future<void> _handleAuthState(BuildContext context, AuthState state) async {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    } else if (state is AuthProfileIncomplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
      );
    } else if (state is AuthGuest) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('/home', (route) => false);
    } else if (state is AuthAuthenticated) {
      await _handleAuthenticated(context);
    }
  }

  Future<void> _handleAuthenticated(BuildContext context) async {
    if (ModalRoute.of(context)?.isCurrent != true) return;

    _showLoadingDialog(context);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final syncService = getIt<SyncService>();
        final status = await syncService.checkSyncStatus(user.id);

        if (context.mounted) Navigator.of(context).pop();

        if (status == SyncStatus.conflict) {
          if (context.mounted) {
            final resolution = await _showConflictDialog(context);
            if (resolution != null && context.mounted) {
              _showLoadingDialog(context);

              switch (resolution) {
                case ConflictResolution.cloud:
                  await syncService.resolveConflictKeepCloud(user.id);
                  break;
                case ConflictResolution.local:
                  await syncService.resolveConflictKeepLocal(user.id);
                  break;
                case ConflictResolution.merge:
                  await syncService.resolveConflictMerge(user.id);
                  break;
              }

              if (context.mounted) Navigator.of(context).pop();
            }
          }
        } else {
          if (context.mounted) {
            _showLoadingDialog(context);
            await syncService.executeAutomatedSync(status, user.id);
            if (context.mounted) Navigator.of(context).pop();
          }
        }

        getIt<SyncCubit>().triggerSync();
      } else {
        if (context.mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error in Sync Check: $e");
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }

    if (context.mounted) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<ConflictResolution?> _showConflictDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    return showDialog<ConflictResolution>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.syncConflict),
        content: Text(l10n.syncConflictMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ConflictResolution.local),
            child: Text(l10n.keepLocal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ConflictResolution.cloud),
            child: Text(l10n.keepCloud),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ConflictResolution.merge),
            child: Text(l10n.mergeBoth),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Enums
// ═══════════════════════════════════════════════════════════════════

enum ConflictResolution { local, cloud, merge }

// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/atoms/inputs/app_text_field.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
// import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
// import '../cubit/auth_cubit.dart';
// import 'register_page.dart';
// import 'package:athar/features/auth/presentation/pages/complete_profile_page.dart';
// import 'package:athar/core/services/sync_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// enum ConflictResolution { cloud, local, merge }

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     final canPop = Navigator.canPop(context);

//     return Scaffold(
//       appBar: AtharAppBar(
//         title: "تسجيل الدخول",
//         showActions: false,
//         leading: canPop ? null : const SizedBox(),
//         actions: null,
//       ),

//       body: BlocConsumer<AuthCubit, AuthState>(
//         listener: (context, state) async {
//           if (state is AuthError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           } else if (state is AuthProfileIncomplete) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
//             );
//           }
//           // ✅ التعامل مع الضيف
//           else if (state is AuthGuest) {
//             Navigator.of(
//               context,
//               rootNavigator: true,
//             ).pushNamedAndRemoveUntil('/home', (route) => false);
//           }
//           // ✅ التعامل مع المسجل
//           else if (state is AuthAuthenticated) {
//             if (ModalRoute.of(context)?.isCurrent != true) return;
//             // ... (نفس منطق المزامنة السابق دون تغيير)
//             showDialog(
//               context: context,
//               barrierDismissible: false,
//               builder: (c) => const Center(child: CircularProgressIndicator()),
//             );

//             try {
//               final user = Supabase.instance.client.auth.currentUser;
//               if (user != null) {
//                 final syncService = getIt<SyncService>();
//                 final status = await syncService.checkSyncStatus(user.id);
//                 if (context.mounted) Navigator.of(context).pop();

//                 if (status == SyncStatus.conflict) {
//                   if (context.mounted) {
//                     final resolution = await _showConflictDialog(context);
//                     if (resolution != null && context.mounted) {
//                       showDialog(
//                         context: context,
//                         barrierDismissible: false,
//                         builder: (c) =>
//                             const Center(child: CircularProgressIndicator()),
//                       );
//                       if (resolution == ConflictResolution.cloud) {
//                         await syncService.resolveConflictKeepCloud(user.id);
//                       } else if (resolution == ConflictResolution.local) {
//                         await syncService.resolveConflictKeepLocal(user.id);
//                       } else {
//                         await syncService.resolveConflictMerge(user.id);
//                       }
//                       if (context.mounted) Navigator.of(context).pop();
//                     }
//                   }
//                 } else {
//                   if (context.mounted) {
//                     showDialog(
//                       context: context,
//                       barrierDismissible: false,
//                       builder: (c) =>
//                           const Center(child: CircularProgressIndicator()),
//                     );
//                     await syncService.executeAutomatedSync(status, user.id);
//                     if (context.mounted) Navigator.of(context).pop();
//                   }
//                 }
//                 getIt<SyncCubit>().triggerSync();
//               } else {
//                 if (context.mounted) Navigator.of(context).pop();
//               }
//             } catch (e) {
//               print("Error in Sync Check: $e");
//               if (context.mounted && Navigator.canPop(context)) {
//                 Navigator.of(context).pop();
//               }
//             }

//             if (context.mounted) {
//               Navigator.of(
//                 context,
//                 rootNavigator: true,
//               ).pushNamedAndRemoveUntil('/home', (route) => false);
//             }
//           }
//         },
//         builder: (context, state) {
//           return Center(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(24.w),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       "أهلاً بك في أثر",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 28.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.purple,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Text(
//                       "سجل دخولك لتزامن مساحاتك المشتركة",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//                     ),
//                     SizedBox(height: 40.h),

//                     AtharTextField(
//                       label: "البريد الإلكتروني",
//                       controller: _emailController,
//                       icon: Icons.email_outlined,
//                       validator: (val) => val!.isEmpty ? "مطلوب" : null,
//                     ),
//                     SizedBox(height: 16.h),
//                     AtharTextField(
//                       label: "كلمة المرور",
//                       controller: _passwordController,
//                       icon: Icons.lock_outline,
//                       isPassword: true,
//                       validator: (val) =>
//                           val!.length < 6 ? "كلمة المرور قصيرة" : null,
//                     ),
//                     SizedBox(height: 32.h),

//                     state is AuthLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : ElevatedButton(
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 context.read<AuthCubit>().signIn(
//                                   _emailController.text.trim(),
//                                   _passwordController.text.trim(),
//                                 );
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.purple,
//                               padding: EdgeInsets.symmetric(vertical: 16.h),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12.r),
//                               ),
//                             ),
//                             child: Text(
//                               "تسجيل الدخول",
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),

//                     SizedBox(height: 16.h),

//                     // ✅ زر الدخول كضيف (جديد)
//                     TextButton(
//                       onPressed: () {
//                         // استدعاء دالة الدخول كضيف
//                         context.read<AuthCubit>().loginAsGuest();
//                       },
//                       child: Text(
//                         "تخطي (المتابعة كضيف)",
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           color: Colors.grey[700],
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: 8.h),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const RegisterPage(),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         "ليس لديك حساب؟ أنشئ حساباً جديداً",
//                         style: TextStyle(fontSize: 14.sp),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<ConflictResolution?> _showConflictDialog(
//     BuildContext parentContext,
//   ) async {
//     return showDialog<ConflictResolution>(
//       context: parentContext,
//       barrierDismissible: false,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text("تزامن البيانات"),
//         content: const Text(
//           "توجد بيانات محفوظة على جهازك وأخرى في السحابة.\nكيف تود المتابعة؟",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop(ConflictResolution.cloud);
//             },
//             child: const Text(
//               "استرجاع السحابة (مسح المحلي)",
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop(ConflictResolution.local);
//             },
//             child: const Text(
//               "اعتماد المحلي (مسح السحابة)",
//               style: TextStyle(color: Colors.orange),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop(ConflictResolution.merge);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
//             child: const Text(
//               "دمج البيانات (الأفضل)",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//---------------------------------------------------------------------------
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/atoms/inputs/app_text_field.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
// import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
// import '../cubit/auth_cubit.dart';
// import 'register_page.dart';

// // ✅ استيراد صفحة إكمال البيانات (ضروري لعمل التعديل الجديد)
// import 'package:athar/features/auth/presentation/pages/complete_profile_page.dart';

// // ✅ استيرادات المزامنة
// import 'package:athar/core/services/sync_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// // ✅ تعريف خيارات الحل (تم إضافة خيار الدمج)
// enum ConflictResolution { cloud, local, merge }

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     final canPop = Navigator.canPop(context);

//     return Scaffold(
//       appBar: AtharAppBar(
//         title: "تسجيل الدخول",
//         showActions: false,
//         leading: canPop ? null : const SizedBox(),
//       ),

//       body: BlocConsumer<AuthCubit, AuthState>(
//         listener: (context, state) async {
//           if (state is AuthError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//           // ✅✅ التعديل الجديد: التعامل مع حالة البيانات الناقصة
//           else if (state is AuthProfileIncomplete) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
//             );
//           }
//           // ✅ منطق المزامنة الأصلي (بقي كما هو تماماً)
//           else if (state is AuthAuthenticated) {
//             // 1. منع التداخل
//             if (ModalRoute.of(context)?.isCurrent != true) return;

//             // 2. إظهار دائرة التحميل المبدئية للفحص
//             showDialog(
//               context: context,
//               barrierDismissible: false,
//               builder: (c) => const Center(child: CircularProgressIndicator()),
//             );

//             try {
//               final user = Supabase.instance.client.auth.currentUser;
//               if (user != null) {
//                 final syncService = getIt<SyncService>();

//                 // ✅✅ 1. مرحلة التحقق الذكي (Investigation)
//                 // نفحص الحالة أولاً قبل اتخاذ أي إجراء
//                 final status = await syncService.checkSyncStatus(user.id);

//                 // إغلاق دائرة التحميل المبدئية
//                 if (context.mounted) Navigator.of(context).pop();

//                 if (status == SyncStatus.conflict) {
//                   // 🛑 حالة التعارض: نسأل المستخدم
//                   if (context.mounted) {
//                     final resolution = await _showConflictDialog(context);

//                     if (resolution != null && context.mounted) {
//                       // إظهار التحميل للتنفيذ
//                       showDialog(
//                         context: context,
//                         barrierDismissible: false,
//                         builder: (c) =>
//                             const Center(child: CircularProgressIndicator()),
//                       );

//                       // تنفيذ القرار
//                       if (resolution == ConflictResolution.cloud) {
//                         await syncService.resolveConflictKeepCloud(user.id);
//                       } else if (resolution == ConflictResolution.local) {
//                         await syncService.resolveConflictKeepLocal(user.id);
//                       } else {
//                         // ✅ خيار الدمج الجديد
//                         await syncService.resolveConflictMerge(user.id);
//                       }

//                       // إغلاق التحميل
//                       if (context.mounted) Navigator.of(context).pop();
//                     }
//                   }
//                 } else {
//                   // ✅✅ الحالة التلقائية (نظيف، استرجاع، رفع)
//                   // نقوم بالتنفيذ فوراً مع إظهار تحميل سريع
//                   if (context.mounted) {
//                     showDialog(
//                       context: context,
//                       barrierDismissible: false,
//                       builder: (c) =>
//                           const Center(child: CircularProgressIndicator()),
//                     );

//                     await syncService.executeAutomatedSync(status, user.id);

//                     if (context.mounted) Navigator.of(context).pop();
//                   }
//                 }

//                 // تشغيل المزامنة الخلفية لباقي البيانات (المهام وغيرها)
//                 getIt<SyncCubit>().triggerSync();
//               } else {
//                 if (context.mounted) Navigator.of(context).pop();
//               }
//             } catch (e) {
//               print("Error in Sync Check: $e");
//               if (context.mounted && Navigator.canPop(context)) {
//                 Navigator.of(context).pop();
//               }
//             }

//             // 3. الانتقال النهائي للصفحة الرئيسية
//             if (context.mounted) {
//               Navigator.of(
//                 context,
//                 rootNavigator: true,
//               ).pushNamedAndRemoveUntil('/home', (route) => false);
//             }
//           }
//         },
//         builder: (context, state) {
//           return Center(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(24.w),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       "أهلاً بك في أثر",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 28.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.purple,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Text(
//                       "سجل دخولك لتزامن مساحاتك المشتركة",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//                     ),
//                     SizedBox(height: 40.h),

//                     AtharTextField(
//                       label: "البريد الإلكتروني",
//                       controller: _emailController,
//                       icon: Icons.email_outlined,
//                       validator: (val) => val!.isEmpty ? "مطلوب" : null,
//                     ),
//                     SizedBox(height: 16.h),
//                     AtharTextField(
//                       label: "كلمة المرور",
//                       controller: _passwordController,
//                       icon: Icons.lock_outline,
//                       isPassword: true,
//                       validator: (val) =>
//                           val!.length < 6 ? "كلمة المرور قصيرة" : null,
//                     ),
//                     SizedBox(height: 32.h),

//                     state is AuthLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : ElevatedButton(
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 context.read<AuthCubit>().signIn(
//                                   _emailController.text.trim(),
//                                   _passwordController.text.trim(),
//                                 );
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.purple,
//                               padding: EdgeInsets.symmetric(vertical: 16.h),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12.r),
//                               ),
//                             ),
//                             child: Text(
//                               "تسجيل الدخول",
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),

//                     SizedBox(height: 16.h),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const RegisterPage(),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         "ليس لديك حساب؟ أنشئ حساباً جديداً",
//                         style: TextStyle(fontSize: 14.sp),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // ✅ نافذة حل التعارض المحدثة (مع خيار الدمج)
//   // ---------------------------------------------------------------------------
//   Future<ConflictResolution?> _showConflictDialog(
//     BuildContext parentContext,
//   ) async {
//     return showDialog<ConflictResolution>(
//       context: parentContext,
//       barrierDismissible: false,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text("تزامن البيانات"),
//         content: const Text(
//           "توجد بيانات محفوظة على جهازك وأخرى في السحابة.\nكيف تود المتابعة؟",
//         ),
//         actions: [
//           // الخيار 1: استرجاع السحابة
//           TextButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop(ConflictResolution.cloud);
//             },
//             child: const Text(
//               "استرجاع السحابة (مسح المحلي)",
//               style: TextStyle(color: Colors.red),
//             ),
//           ),

//           // الخيار 2: اعتماد المحلي
//           TextButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop(ConflictResolution.local);
//             },
//             child: const Text(
//               "اعتماد المحلي (مسح السحابة)",
//               style: TextStyle(color: Colors.orange), // لون تحذيري
//             ),
//           ),

//           // ✅ الخيار 3: الدمج (المفضل)
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop(ConflictResolution.merge);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
//             child: const Text(
//               "دمج البيانات (الأفضل)",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/atoms/inputs/app_text_field.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
// import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
// import '../cubit/auth_cubit.dart';
// import 'register_page.dart';

// // ✅ استيرادات المزامنة
// import 'package:athar/core/services/sync_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// // ✅ تعريف خيارات الحل (تم إضافة خيار الدمج)
// enum ConflictResolution { cloud, local, merge }

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     final canPop = Navigator.canPop(context);

//     return Scaffold(
//       appBar: AtharAppBar(
//         title: "تسجيل الدخول",
//         showActions: false,
//         leading: canPop ? null : const SizedBox(),
//       ),

//       body: BlocConsumer<AuthCubit, AuthState>(
//         listener: (context, state) async {
//           if (state is AuthError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           } else if (state is AuthAuthenticated) {
//             // 1. منع التداخل
//             if (ModalRoute.of(context)?.isCurrent != true) return;

//             // 2. إظهار دائرة التحميل المبدئية للفحص
//             showDialog(
//               context: context,
//               barrierDismissible: false,
//               builder: (c) => const Center(child: CircularProgressIndicator()),
//             );

//             try {
//               final user = Supabase.instance.client.auth.currentUser;
//               if (user != null) {
//                 final syncService = getIt<SyncService>();

//                 // ✅✅ 1. مرحلة التحقق الذكي (Investigation)
//                 // نفحص الحالة أولاً قبل اتخاذ أي إجراء
//                 final status = await syncService.checkSyncStatus(user.id);

//                 // إغلاق دائرة التحميل المبدئية
//                 if (context.mounted) Navigator.of(context).pop();

//                 if (status == SyncStatus.conflict) {
//                   // 🛑 حالة التعارض: نسأل المستخدم
//                   if (context.mounted) {
//                     final resolution = await _showConflictDialog(context);

//                     if (resolution != null && context.mounted) {
//                       // إظهار التحميل للتنفيذ
//                       showDialog(
//                         context: context,
//                         barrierDismissible: false,
//                         builder: (c) =>
//                             const Center(child: CircularProgressIndicator()),
//                       );

//                       // تنفيذ القرار
//                       if (resolution == ConflictResolution.cloud) {
//                         await syncService.resolveConflictKeepCloud(user.id);
//                       } else if (resolution == ConflictResolution.local) {
//                         await syncService.resolveConflictKeepLocal(user.id);
//                       } else {
//                         // ✅ خيار الدمج الجديد
//                         await syncService.resolveConflictMerge(user.id);
//                       }

//                       // إغلاق التحميل
//                       if (context.mounted) Navigator.of(context).pop();
//                     }
//                   }
//                 } else {
//                   // ✅✅ الحالة التلقائية (نظيف، استرجاع، رفع)
//                   // نقوم بالتنفيذ فوراً مع إظهار تحميل سريع
//                   if (context.mounted) {
//                     showDialog(
//                       context: context,
//                       barrierDismissible: false,
//                       builder: (c) =>
//                           const Center(child: CircularProgressIndicator()),
//                     );

//                     await syncService.executeAutomatedSync(status, user.id);

//                     if (context.mounted) Navigator.of(context).pop();
//                   }
//                 }

//                 // تشغيل المزامنة الخلفية لباقي البيانات (المهام وغيرها)
//                 getIt<SyncCubit>().triggerSync();
//               } else {
//                 if (context.mounted) Navigator.of(context).pop();
//               }
//             } catch (e) {
//               print("Error in Sync Check: $e");
//               if (context.mounted && Navigator.canPop(context)) {
//                 Navigator.of(context).pop();
//               }
//             }

//             // 3. الانتقال النهائي للصفحة الرئيسية
//             if (context.mounted) {
//               Navigator.of(
//                 context,
//                 rootNavigator: true,
//               ).pushNamedAndRemoveUntil('/home', (route) => false);
//             }
//           }
//         },
//         builder: (context, state) {
//           return Center(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(24.w),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       "أهلاً بك في أثر",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 28.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.purple,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Text(
//                       "سجل دخولك لتزامن مساحاتك المشتركة",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//                     ),
//                     SizedBox(height: 40.h),

//                     AtharTextField(
//                       label: "البريد الإلكتروني",
//                       controller: _emailController,
//                       icon: Icons.email_outlined,
//                       validator: (val) => val!.isEmpty ? "مطلوب" : null,
//                     ),
//                     SizedBox(height: 16.h),
//                     AtharTextField(
//                       label: "كلمة المرور",
//                       controller: _passwordController,
//                       icon: Icons.lock_outline,
//                       isPassword: true,
//                       validator: (val) =>
//                           val!.length < 6 ? "كلمة المرور قصيرة" : null,
//                     ),
//                     SizedBox(height: 32.h),

//                     state is AuthLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : ElevatedButton(
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 context.read<AuthCubit>().signIn(
//                                   _emailController.text.trim(),
//                                   _passwordController.text.trim(),
//                                 );
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.purple,
//                               padding: EdgeInsets.symmetric(vertical: 16.h),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12.r),
//                               ),
//                             ),
//                             child: Text(
//                               "تسجيل الدخول",
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),

//                     SizedBox(height: 16.h),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const RegisterPage(),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         "ليس لديك حساب؟ أنشئ حساباً جديداً",
//                         style: TextStyle(fontSize: 14.sp),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // ✅ نافذة حل التعارض المحدثة (مع خيار الدمج)
//   // ---------------------------------------------------------------------------
//   Future<ConflictResolution?> _showConflictDialog(
//     BuildContext parentContext,
//   ) async {
//     return showDialog<ConflictResolution>(
//       context: parentContext,
//       barrierDismissible: false,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text("تزامن البيانات"),
//         content: const Text(
//           "توجد بيانات محفوظة على جهازك وأخرى في السحابة.\nكيف تود المتابعة؟",
//         ),
//         actions: [
//           // الخيار 1: استرجاع السحابة
//           TextButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop(ConflictResolution.cloud);
//             },
//             child: const Text(
//               "استرجاع السحابة (مسح المحلي)",
//               style: TextStyle(color: Colors.red),
//             ),
//           ),

//           // الخيار 2: اعتماد المحلي
//           TextButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop(ConflictResolution.local);
//             },
//             child: const Text(
//               "اعتماد المحلي (مسح السحابة)",
//               style: TextStyle(color: Colors.orange), // لون تحذيري
//             ),
//           ),

//           // ✅ الخيار 3: الدمج (المفضل)
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop(ConflictResolution.merge);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
//             child: const Text(
//               "دمج البيانات (الأفضل)",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
