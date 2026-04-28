import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/widgets/athar_text_field.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final statusBarHeight = MediaQuery.of(context).padding.top;

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
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Column(
            children: [
              _buildHeader(colorScheme, statusBarHeight),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 24.h,
                    ),
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
                            validator: (v) =>
                                (v == null || v.isEmpty) ? "مطلوب" : null,
                          ),
                          AtharGap.lg,

                          AtharTextField(
                            label: "اسم المستخدم",
                            hint: "بدون مسافات أو رموز خاصة",
                            controller: _usernameController,
                            prefixIcon: Icons.alternate_email,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleSave(),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "مطلوب";
                              if (v.length < 3) return "3 أحرف على الأقل";
                              return null;
                            },
                          ),
                          AtharGap.xxxl,

                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : AtharButton(
                                  label: "حفظ ومتابعة",
                                  isFullWidth: true,
                                  onPressed: _handleSave,
                                ),
                        ],
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

  Widget _buildHeader(ColorScheme colorScheme, double statusBarHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 32.h + statusBarHeight,
        bottom: 28.h,
        left: 24.w,
        right: 24.w,
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
          const Icon(Icons.edit_note_rounded, color: Colors.white, size: 36),
          const SizedBox(height: 12),
          Text(
            "أكمل ملفك الشخصي",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "خطوة واحدة تفصلك عن بداية رحلتك مع أثر",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().completeProfileData(
        fullName: _nameController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
      );
    }
  }
}
