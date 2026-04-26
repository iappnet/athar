import 'package:athar/core/design_system/atoms/inputs/app_text_field.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إكمال الملف الشخصي")),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // عند النجاح، التوجيه يتم في app.dart أو يمكن عمل pop هنا
            // لكن الأفضل ترك app.dart يتعامل مع التغيير الجذري
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
          bool isLoading = state is AuthLoading;

          return Padding(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "مرحباً بك! يرجى إكمال بياناتك للمتابعة",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                  ),
                  AtharGap.xxxl,

                  AtharTextField(
                    label: "الاسم الكامل",
                    controller: _nameController,
                    icon: Icons.person,
                    validator: (v) => v!.isEmpty ? "مطلوب" : null,
                  ),
                  AtharGap.lg,

                  AtharTextField(
                    label: "اسم المستخدم",
                    controller: _usernameController,
                    icon: Icons.alternate_email,
                    validator: (v) => v!.isEmpty ? "مطلوب" : null,
                  ),
                  AtharGap.xxxl,

                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().completeProfileData(
                                fullName: _nameController.text,
                                username: _usernameController.text,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50.h),
                            backgroundColor: Colors.purple,
                          ),
                          child: const Text(
                            "حفظ ومتابعة",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
