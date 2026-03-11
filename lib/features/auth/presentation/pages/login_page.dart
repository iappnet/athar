import 'package:athar/core/di/injection.dart';
import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/atoms/inputs/app_text_field.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
import '../cubit/auth_cubit.dart';
import 'register_page.dart';
import 'package:athar/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:athar/core/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

enum ConflictResolution { cloud, local, merge }

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
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      appBar: AtharAppBar(
        title: "تسجيل الدخول",
        showActions: false,
        leading: canPop ? null : const SizedBox(),
        actions: null,
      ),

      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthProfileIncomplete) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
            );
          }
          // ✅ التعامل مع الضيف
          else if (state is AuthGuest) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
          }
          // ✅ التعامل مع المسجل
          else if (state is AuthAuthenticated) {
            if (ModalRoute.of(context)?.isCurrent != true) return;
            // ... (نفس منطق المزامنة السابق دون تغيير)
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (c) => const Center(child: CircularProgressIndicator()),
            );

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
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (c) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                      if (resolution == ConflictResolution.cloud) {
                        await syncService.resolveConflictKeepCloud(user.id);
                      } else if (resolution == ConflictResolution.local) {
                        await syncService.resolveConflictKeepLocal(user.id);
                      } else {
                        await syncService.resolveConflictMerge(user.id);
                      }
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  }
                } else {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (c) =>
                          const Center(child: CircularProgressIndicator()),
                    );
                    await syncService.executeAutomatedSync(status, user.id);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                }
                getIt<SyncCubit>().triggerSync();
              } else {
                if (context.mounted) Navigator.of(context).pop();
              }
            } catch (e) {
              print("Error in Sync Check: $e");
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
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "أهلاً بك في أثر",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "سجل دخولك لتزامن مساحاتك المشتركة",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 40.h),

                    AtharTextField(
                      label: "البريد الإلكتروني",
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      validator: (val) => val!.isEmpty ? "مطلوب" : null,
                    ),
                    SizedBox(height: 16.h),
                    AtharTextField(
                      label: "كلمة المرور",
                      controller: _passwordController,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (val) =>
                          val!.length < 6 ? "كلمة المرور قصيرة" : null,
                    ),
                    SizedBox(height: 32.h),

                    state is AuthLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().signIn(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "تسجيل الدخول",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),

                    SizedBox(height: 16.h),

                    // ✅ زر الدخول كضيف (جديد)
                    TextButton(
                      onPressed: () {
                        // استدعاء دالة الدخول كضيف
                        context.read<AuthCubit>().loginAsGuest();
                      },
                      child: Text(
                        "تخطي (المتابعة كضيف)",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        "ليس لديك حساب؟ أنشئ حساباً جديداً",
                        style: TextStyle(fontSize: 14.sp),
                      ),
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

  Future<ConflictResolution?> _showConflictDialog(
    BuildContext parentContext,
  ) async {
    return showDialog<ConflictResolution>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("تزامن البيانات"),
        content: const Text(
          "توجد بيانات محفوظة على جهازك وأخرى في السحابة.\nكيف تود المتابعة؟",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(ConflictResolution.cloud);
            },
            child: const Text(
              "استرجاع السحابة (مسح المحلي)",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(ConflictResolution.local);
            },
            child: const Text(
              "اعتماد المحلي (مسح السحابة)",
              style: TextStyle(color: Colors.orange),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(ConflictResolution.merge);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text(
              "دمج البيانات (الأفضل)",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

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
