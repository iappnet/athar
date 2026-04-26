import 'package:flutter/material.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/utils/navigation_utils.dart';
import '../../../../core/design_system/atoms/inputs/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

// ✅ 1. استيراد SettingsCubit و DeleteAccountDialog
import '../../../settings/presentation/widgets/delete_account_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated) {
      _nameController.text = state.fullName ?? "";
      _usernameController.text = state.username;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile), centerTitle: true),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.logoutSuccess)),
            );
            NavigationUtils.resetToUnauthenticated(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.purple.shade100,
                    child: Icon(
                      Icons.person,
                      size: 50.sp,
                      color: Colors.purple,
                    ),
                  ),
                  AtharGap.xxxl,

                  AtharTextField(
                    label: l10n.fullName,
                    controller: _nameController,
                    icon: Icons.person_outline,
                    validator: (val) =>
                        val!.isEmpty ? l10n.errorRequired : null,
                  ),
                  AtharGap.lg,

                  AtharTextField(
                    label: l10n.usernameLabel,
                    controller: _usernameController,
                    icon: Icons.alternate_email,
                  ),

                  AtharGap.xxxl,

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthCubit>().updateProfile(
                          _nameController.text,
                          _usernameController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.profileUpdatedSuccess)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: AtharRadii.radiusMd,
                      ),
                    ),
                    child: Text(
                      l10n.saveChanges,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  AtharGap.xxl,
                  Divider(color: Colors.grey.shade300),
                  AtharGap.lg, // تقليل المسافة قليلاً
                  // زر تسجيل الخروج
                  TextButton.icon(
                    onPressed: () {
                      context.read<AuthCubit>().signOut();
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.orange,
                    ), // غيرت اللون لتمييزه عن الحذف
                    label: Text(
                      l10n.logout,
                      style: TextStyle(color: Colors.orange, fontSize: 16.sp),
                    ),
                  ),

                  AtharGap.sm,

                  // ✅ 2. زر حذف الحساب (تم دمجه هنا)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: AtharRadii.radiusMd,
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                          size: 20.sp,
                        ),
                      ),
                      title: Text(
                        l10n.deleteAccount,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.sp,
                        color: Colors.red.shade300,
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => DeleteAccountDialog(
                            onConfirm: (bool deleteAll) {
                              // ✅ التعديل هنا: استخدام AuthCubit بدلاً من SettingsCubit
                              // deleteAll == true  => يعني حذف كل شيء (keepLocal = false)
                              // deleteAll == false => يعني الاحتفاظ بالمحلي (keepLocal = true)

                              final keepLocal = !deleteAll;

                              context.read<AuthCubit>().deleteAccount(
                                keepLocalData: keepLocal,
                              );

                              // إغلاق الدايلوج فقط، الـ Listener سيتكفل بإغلاق الصفحة عند نجاح الحذف
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 30.h), // مسافة في الأسفل لضمان العرض الجيد
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// -----------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/atoms/inputs/app_text_field.dart';
// import '../cubit/auth_cubit.dart';
// import '../cubit/auth_state.dart';

// // ✅ 1. استيراد SettingsCubit و DeleteAccountDialog
// import '../../../settings/presentation/widgets/delete_account_dialog.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final _nameController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   void _loadUserData() {
//     final state = context.read<AuthCubit>().state;
//     if (state is AuthAuthenticated) {
//       _nameController.text = state.fullName ?? "";
//       _usernameController.text = state.username;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("الملف الشخصي"), centerTitle: true),
//       body: BlocConsumer<AuthCubit, AuthState>(
//         listener: (context, state) {
//           if (state is AuthUnauthenticated) {
//             Navigator.pop(context);
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("تم تسجيل الخروج بنجاح")),
//             );
//           } else if (state is AuthError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is AuthLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return SingleChildScrollView(
//             padding: EdgeInsets.all(24.w),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50.r,
//                     backgroundColor: Colors.purple.shade100,
//                     child: Icon(
//                       Icons.person,
//                       size: 50.sp,
//                       color: Colors.purple,
//                     ),
//                   ),
//                   SizedBox(height: 32.h),

//                   AtharTextField(
//                     label: "الاسم الكامل",
//                     controller: _nameController,
//                     icon: Icons.person_outline,
//                     validator: (val) => val!.isEmpty ? "مطلوب" : null,
//                   ),
//                   SizedBox(height: 16.h),

//                   AtharTextField(
//                     label: "اسم المستخدم (Username)",
//                     controller: _usernameController,
//                     icon: Icons.alternate_email,
//                   ),

//                   SizedBox(height: 32.h),

//                   ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         context.read<AuthCubit>().updateProfile(
//                           _nameController.text,
//                           _usernameController.text,
//                         );
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("تم تحديث البيانات بنجاح"),
//                           ),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple,
//                       minimumSize: Size(double.infinity, 50.h),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                     ),
//                     child: const Text(
//                       "حفظ التغييرات",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),

//                   SizedBox(height: 24.h),
//                   Divider(color: Colors.grey.shade300),
//                   SizedBox(height: 16.h), // تقليل المسافة قليلاً
//                   // زر تسجيل الخروج
//                   TextButton.icon(
//                     onPressed: () {
//                       context.read<AuthCubit>().signOut();
//                     },
//                     icon: const Icon(
//                       Icons.logout,
//                       color: Colors.orange,
//                     ), // غيرت اللون لتمييزه عن الحذف
//                     label: Text(
//                       "تسجيل الخروج",
//                       style: TextStyle(color: Colors.orange, fontSize: 16.sp),
//                     ),
//                   ),

//                   SizedBox(height: 8.h),

//                   // ✅ 2. زر حذف الحساب (تم دمجه هنا)
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(12.r),
//                       border: Border.all(color: Colors.red.shade100),
//                     ),
//                     child: ListTile(
//                       leading: Container(
//                         padding: EdgeInsets.all(8.w),
//                         decoration: BoxDecoration(
//                           color: Colors.red.withValues(alpha: 0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.delete_outline_rounded,
//                           color: Colors.red,
//                           size: 20.sp,
//                         ),
//                       ),
//                       title: Text(
//                         "حذف الحساب",
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.red,
//                         ),
//                       ),
//                       trailing: Icon(
//                         Icons.arrow_forward_ios_rounded,
//                         size: 14.sp,
//                         color: Colors.red.shade300,
//                       ),
//                       onTap: () {
//                         showDialog(
//                           context: context,
//                           builder: (context) => DeleteAccountDialog(
//                             onConfirm: (bool deleteAll) {
//                               // ✅ التعديل هنا: استخدام AuthCubit بدلاً من SettingsCubit
//                               // deleteAll == true  => يعني حذف كل شيء (keepLocal = false)
//                               // deleteAll == false => يعني الاحتفاظ بالمحلي (keepLocal = true)

//                               final keepLocal = !deleteAll;

//                               context.read<AuthCubit>().deleteAccount(
//                                 keepLocalData: keepLocal,
//                               );

//                               // إغلاق الدايلوج فقط، الـ Listener سيتكفل بإغلاق الصفحة عند نجاح الحذف
//                               Navigator.pop(context);
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   SizedBox(height: 30.h), // مسافة في الأسفل لضمان العرض الجيد
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
