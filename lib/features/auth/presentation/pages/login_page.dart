import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
import 'package:athar/core/design_system/widgets/athar_text_field.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/responsive_wrapper.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/deep_link_service.dart';
import 'package:athar/core/services/sync_service.dart';
import 'package:athar/core/utils/responsive_helper.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:athar/features/auth/presentation/pages/register_page.dart';
import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 48 : 24.w,
                  vertical: isTablet ? 32 : 24.h,
                ),
                child: ResponsiveWrapper.form(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(Theme.of(context).colorScheme, l10n, isTablet),

                        SizedBox(height: isTablet ? 48 : 40.h),

                        _buildEmailField(l10n),
                        SizedBox(height: isTablet ? 20 : 16.h),
                        _buildPasswordField(context, l10n),

                        SizedBox(height: isTablet ? 40 : 32.h),

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

  Widget _buildHeader(ColorScheme colorScheme, AppLocalizations l10n, bool isTablet) {
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
      label: l10n.emailOrUsername,
      hint: "example@email.com أو username",
      controller: _emailController,
      prefixIcon: Icons.person_outline,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: (val) {
        if (val == null || val.isEmpty) return l10n.required;
        return null;
      },
    );
  }

  Widget _buildPasswordField(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AtharTextField(
          label: l10n.password,
          controller: _passwordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
          validator: (val) {
            if (val == null || val.isEmpty) return l10n.required;
            if (val.length < 8) return l10n.passwordTooShort;
            return null;
          },
        ),
        TextButton(
          onPressed: () => _showForgotPasswordSheet(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.forgotPassword,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _showForgotPasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ForgotPasswordSheet(cubit: context.read<AuthCubit>()),
    );
  }

  Widget _buildActions(BuildContext context, AuthState state, AppLocalizations l10n, bool isTablet) {
    if (state is AuthLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtharButton(
          label: l10n.login,
          onPressed: _handleLogin,
          isFullWidth: true,
          size: isTablet ? AtharButtonSize.large : AtharButtonSize.medium,
        ),

        SizedBox(height: isTablet ? 20 : 16.h),

        SizedBox(height: isTablet ? 16 : 12.h),

        SignInWithAppleButton(
          onPressed: () => context.read<AuthCubit>().signInWithApple(),
          style: SignInWithAppleButtonStyle.black,
          borderRadius: BorderRadius.circular(12),
          height: isTablet ? 52 : 44.h,
        ),

        SizedBox(height: isTablet ? 16 : 12.h),

        TextButton(
          onPressed: _handleGuestLogin,
          child: Text(
            l10n.skipAsGuest,
            style: TextStyle(fontSize: isTablet ? 16 : 14.sp),
          ),
        ),

        SizedBox(height: isTablet ? 16 : 12.h),

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
        SnackBar(
          content: Text(state.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else if (state is AuthProfileIncomplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
      );
    } else if (state is AuthGuest) {
      getIt<DeepLinkService>().checkPendingInvites();
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil('/home', (route) => false);
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
      getIt<DeepLinkService>().checkPendingInvites();
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil('/home', (route) => false);
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

enum ConflictResolution { local, cloud, merge }

enum _ResetStep { email, otp, newPassword, done }

class _ForgotPasswordSheet extends StatefulWidget {
  final AuthCubit cubit;
  const _ForgotPasswordSheet({required this.cubit});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  _ResetStep _step = _ResetStep.email;
  String _submittedEmail = '';
  bool _otpVerified = false;
  bool _resetCompleted = false;
  bool _loading = false;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _pwFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    if (_otpVerified && !_resetCompleted) {
      widget.cubit.cancelPasswordReset();
    }
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _pwCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await widget.cubit.sendOtpForPasswordReset(_emailCtrl.text.trim());
      if (mounted) {
        setState(() {
          _submittedEmail = _emailCtrl.text.trim();
          _step = _ResetStep.otp;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'تعذّر إرسال الرمز. تأكد من البريد الإلكتروني وحاول مجدداً.';
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await widget.cubit.verifyOtpForPasswordReset(
        email: _submittedEmail,
        otp: _otpCtrl.text.trim(),
      );
      if (mounted) {
        setState(() {
          _otpVerified = true;
          _step = _ResetStep.newPassword;
          _loading = false;
        });
      }
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
      await widget.cubit.updatePasswordAndFinishReset(_pwCtrl.text);
      if (mounted) {
        setState(() {
          _resetCompleted = true;
          _step = _ResetStep.done;
          _loading = false;
        });
      }
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
    _ResetStep.email => 0,
    _ResetStep.otp => 1,
    _ResetStep.newPassword => 2,
    _ResetStep.done => 2,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = _step == _ResetStep.done;

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
            _ResetStepIndicator(currentStep: _stepIndex, colorScheme: colorScheme),
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
      _ResetStep.email => (
          'إعادة تعيين كلمة المرور',
          'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق',
        ),
      _ResetStep.otp => (
          'أدخل رمز التحقق',
          'تم إرسال رمز مكوّن من 6 أرقام إلى $_submittedEmail',
        ),
      _ResetStep.newPassword => (
          'كلمة مرور جديدة',
          'أدخل كلمة المرور الجديدة لحسابك',
        ),
      _ResetStep.done => (
          '✓  تم بنجاح',
          'تم تغيير كلمة مرورك. يمكنك الآن تسجيل الدخول.',
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
                color: _step == _ResetStep.done
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
      _ResetStep.email => _buildEmailStep(colorScheme),
      _ResetStep.otp => _buildOtpStep(colorScheme),
      _ResetStep.newPassword => _buildPasswordStep(colorScheme),
      _ResetStep.done => _buildDoneStep(),
    };
  }

  Widget _buildEmailStep(ColorScheme colorScheme) {
    return Form(
      key: _emailFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtharTextField(
            label: 'البريد الإلكتروني',
            controller: _emailCtrl,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _sendOtp(),
            validator: (val) {
              if (val == null || val.isEmpty) return 'مطلوب';
              final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.\w{2,}$');
              if (!emailRegex.hasMatch(val.trim())) return 'بريد إلكتروني غير صحيح';
              return null;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: colorScheme.error, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          AtharButton(
            label: 'إرسال رمز التحقق',
            isFullWidth: true,
            isLoading: _loading,
            onPressed: _loading ? null : _sendOtp,
          ),
        ],
      ),
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
                        _step = _ResetStep.email;
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
          label: 'تسجيل الدخول',
          isFullWidth: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _ResetStepIndicator extends StatelessWidget {
  final int currentStep;
  final ColorScheme colorScheme;

  const _ResetStepIndicator({
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
