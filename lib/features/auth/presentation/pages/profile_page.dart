import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/utils/navigation_utils.dart';
import 'package:athar/core/utils/responsive_helper.dart';
import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
import 'package:athar/core/design_system/widgets/athar_text_field.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/tokens.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
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
      _nameController.text = state.fullName ?? '';
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
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AtharAppBar(title: l10n.profile, showActions: false),
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
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 48 : 24.w,
              vertical: isTablet ? 32 : 24.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: isTablet ? 60 : 50.r,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: isTablet ? 60 : 50.sp,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  AtharGap.xxxl,

                  AtharTextField(
                    label: l10n.fullName,
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? l10n.errorRequired : null,
                  ),
                  AtharGap.lg,

                  AtharTextField(
                    label: l10n.usernameLabel,
                    controller: _usernameController,
                    prefixIcon: Icons.alternate_email,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleSave(),
                  ),

                  AtharGap.xxxl,

                  AtharButton(
                    label: l10n.saveChanges,
                    isFullWidth: true,
                    size: isTablet ? AtharButtonSize.large : AtharButtonSize.medium,
                    onPressed: _handleSave,
                  ),

                  AtharGap.md,

                  TextButton.icon(
                    onPressed: () => _showChangePasswordSheet(context),
                    icon: Icon(
                      Icons.lock_reset_outlined,
                      color: colorScheme.primary,
                      size: isTablet ? 22 : 20.sp,
                    ),
                    label: Text(
                      l10n.changePassword,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: isTablet ? 16 : 14.sp,
                      ),
                    ),
                  ),

                  AtharGap.sm,
                  Divider(color: colorScheme.outlineVariant),
                  AtharGap.lg,

                  TextButton.icon(
                    onPressed: () => context.read<AuthCubit>().signOut(),
                    icon: Icon(Icons.logout, color: colorScheme.error),
                    label: Text(
                      l10n.logout,
                      style: TextStyle(
                        color: colorScheme.error,
                        fontSize: isTablet ? 16 : 14.sp,
                      ),
                    ),
                  ),

                  AtharGap.sm,

                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: AtharRadii.radiusMd,
                      border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: colorScheme.error,
                          size: isTablet ? 22 : 20.sp,
                        ),
                      ),
                      title: Text(
                        l10n.deleteAccount,
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 14.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.error,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: isTablet ? 15 : 14.sp,
                        color: colorScheme.error.withValues(alpha: 0.5),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => DeleteAccountDialog(
                            onConfirm: (bool deleteAll) {
                              context.read<AuthCubit>().deleteAccount(
                                keepLocalData: !deleteAll,
                              );
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().updateProfile(
        _nameController.text,
        _usernameController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).profileUpdatedSuccess)),
      );
    }
  }

  void _showChangePasswordSheet(BuildContext context) {
    final email = context.read<AuthCubit>().currentUserEmail;
    if (email == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ChangePasswordSheet(
        cubit: context.read<AuthCubit>(),
        email: email,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

enum _ChangeStep { confirm, otp, newPassword, done }

class _ChangePasswordSheet extends StatefulWidget {
  final AuthCubit cubit;
  final String email;
  const _ChangePasswordSheet({required this.cubit, required this.email});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  _ChangeStep _step = _ChangeStep.confirm;
  bool _loading = false;
  String? _error;

  final _otpCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _otpFormKey = GlobalKey<FormState>();
  final _pwFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpCtrl.dispose();
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() { _loading = true; _error = null; });
    try {
      await widget.cubit.sendOtpForPasswordReset(widget.email);
      if (mounted) setState(() { _step = _ChangeStep.otp; _loading = false; });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'تعذّر إرسال الرمز. حاول مجدداً.';
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await widget.cubit.verifyOtpOnly(
        email: widget.email,
        otp: _otpCtrl.text.trim(),
      );
      if (mounted) setState(() { _step = _ChangeStep.newPassword; _loading = false; });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'الرمز غير صحيح أو منتهي الصلاحية. حاول مجدداً.';
        });
      }
    }
  }

  Future<void> _updatePassword() async {
    if (!_pwFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await widget.cubit.updatePasswordOnly(_pwCtrl.text);
      if (mounted) setState(() { _step = _ChangeStep.done; _loading = false; });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'فشل تحديث كلمة المرور. حاول مجدداً.';
        });
      }
    }
  }

  int get _stepIndex => switch (_step) {
    _ChangeStep.confirm => 0,
    _ChangeStep.otp => 1,
    _ChangeStep.newPassword => 2,
    _ChangeStep.done => 2,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = _step == _ChangeStep.done;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!isDone) ...[
            _ChangeStepIndicator(currentStep: _stepIndex, colorScheme: colorScheme),
            const SizedBox(height: 20),
          ],
          _buildHeader(colorScheme),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: _buildStepContent(colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    final (title, subtitle) = switch (_step) {
      _ChangeStep.confirm => (
          'تغيير كلمة المرور',
          'سنرسل رمز التحقق إلى ${widget.email}',
        ),
      _ChangeStep.otp => (
          'أدخل رمز التحقق',
          'تم إرسال رمز مكوّن من 6 أرقام إلى ${widget.email}',
        ),
      _ChangeStep.newPassword => (
          'كلمة مرور جديدة',
          'أدخل كلمة المرور الجديدة لحسابك',
        ),
      _ChangeStep.done => (
          '✓  تم بنجاح',
          'تم تغيير كلمة مرورك بنجاح.',
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(
        key: ValueKey(_step),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _step == _ChangeStep.done
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(ColorScheme colorScheme) {
    return switch (_step) {
      _ChangeStep.confirm => _buildConfirmStep(colorScheme),
      _ChangeStep.otp => _buildOtpStep(colorScheme),
      _ChangeStep.newPassword => _buildPasswordStep(colorScheme),
      _ChangeStep.done => _buildDoneStep(),
    };
  }

  Widget _buildConfirmStep(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          Text(_error!, style: TextStyle(color: colorScheme.error, fontSize: 13)),
          const SizedBox(height: 12),
        ],
        AtharButton(
          label: 'إرسال رمز التحقق',
          isFullWidth: true,
          isLoading: _loading,
          onPressed: _loading ? null : _sendOtp,
        ),
      ],
    );
  }

  Widget _buildOtpStep(ColorScheme colorScheme) {
    return Form(
      key: _otpFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtharTextField(
            label: 'رمز التحقق',
            hint: '000000',
            controller: _otpCtrl,
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _verifyOtp(),
            validator: (val) {
              if (val == null || val.isEmpty) return 'مطلوب';
              if (val.trim().length != 6) return 'الرمز يجب أن يكون 6 أرقام';
              return null;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: colorScheme.error, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          AtharButton(
            label: 'تحقق من الرمز',
            isFullWidth: true,
            isLoading: _loading,
            onPressed: _loading ? null : _verifyOtp,
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () => setState(() {
                        _step = _ChangeStep.confirm;
                        _error = null;
                        _otpCtrl.clear();
                      }),
              child: Text(
                'إعادة إرسال الرمز',
                style: TextStyle(color: colorScheme.primary, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep(ColorScheme colorScheme) {
    return Form(
      key: _pwFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtharTextField(
            label: 'كلمة المرور الجديدة',
            controller: _pwCtrl,
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: (val) {
              if (val == null || val.isEmpty) return 'مطلوب';
              if (val.length < 8) return '8 خانات على الأقل';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AtharTextField(
            label: 'تأكيد كلمة المرور',
            controller: _confirmCtrl,
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _updatePassword(),
            validator: (val) {
              if (val == null || val.isEmpty) return 'مطلوب';
              if (val != _pwCtrl.text) return 'كلمتا المرور غير متطابقتين';
              return null;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: colorScheme.error, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          AtharButton(
            label: 'تحديث كلمة المرور',
            isFullWidth: true,
            isLoading: _loading,
            onPressed: _loading ? null : _updatePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildDoneStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtharButton(
          label: 'تم',
          isFullWidth: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _ChangeStepIndicator extends StatelessWidget {
  final int currentStep;
  final ColorScheme colorScheme;

  const _ChangeStepIndicator({
    required this.currentStep,
    required this.colorScheme,
  });

  static const _labels = ['البريد', 'التحقق', 'كلمة المرور'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final isPast = stepIndex < currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              color: isPast ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isActive = stepIndex == currentStep;
        final isPast = stepIndex < currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 28 : 22,
          height: isActive ? 28 : 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPast || isActive
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isPast
                ? Icon(Icons.check, size: 13, color: colorScheme.onPrimary)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
