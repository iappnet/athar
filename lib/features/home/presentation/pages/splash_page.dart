// lib/features/home/presentation/pages/splash_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.3
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/biometric_service.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isTimerDone = false;
  AuthState? _lastState;

  @override
  void initState() {
    super.initState();

    _lastState = context.read<AuthCubit>().state;

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTimerDone = true;
        });
        _tryNavigate();
      }
    });
  }

  Future<void> _tryNavigate() async {
    if (!_isTimerDone || _lastState == null) return;

    if (_lastState is AuthAuthenticated) {
      final settingsCubit = context.read<SettingsCubit>();
      UserSettings? settings;

      if (settingsCubit.state is SettingsLoaded) {
        settings = (settingsCubit.state as SettingsLoaded).settings;
      } else {
        settings = await getIt<SettingsRepository>().getSettings();
      }

      if (settings.isBiometricEnabled) {
        final bioService = getIt<BiometricService>();
        final authenticated = await bioService.authenticate();

        if (authenticated) {
          if (mounted) Navigator.of(context).pushReplacementNamed('/home');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).biometricLoginFailed,
                ),
              ),
            );
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      } else {
        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      }
    } else if (_lastState is AuthGuest) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (_lastState is AuthProfileIncomplete) {
      Navigator.of(context).pushReplacementNamed('/complete_profile');
    } else if (_lastState is AuthUnauthenticated) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else if (_lastState is AuthError) {
      debugPrint("Auth Error in Splash: ${(_lastState as AuthError).message}");
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors from context
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        _lastState = state;
        _tryNavigate();
      },
      child: Scaffold(
        // ✅ AppColors.primary → colors.primary
        backgroundColor: colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.track_changes_outlined,
                size: 80.sp,
                // ✅ Colors.white → colors.onPrimary
                color: colorScheme.onPrimary,
              ),
              // ✅ SizedBox(height: 20.h) → AtharGap.xl
              AtharGap.xl,
              Text(
                l10n.athar,
                // ✅ AtharTypography
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.5,
                ).copyWith(color: colorScheme.onPrimary),
              ),
              // ✅ SizedBox(height: 10.h) → AtharGap.sm
              AtharGap.sm,
              Text(
                l10n.leaveYourMark,
                // ✅ AtharTypography
                style:
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ).copyWith(
                      // ✅ Colors.white70 → colors.onPrimary.withValues(alpha: 0.7)
                      color: colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
              ),
              SizedBox(height: 50.h),
              if (_isTimerDone)
                CircularProgressIndicator(
                  // ✅ Colors.white → colors.onPrimary
                  color: colorScheme.onPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
//------------------------------------------------------------------------

// // lib/features/home/presentation/pages/splash_page.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 2 | File 2.3
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';

// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/services/biometric_service.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
// import 'package:athar/features/settings/data/models/user_settings.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_state.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   bool _isTimerDone = false;
//   AuthState? _lastState;

//   @override
//   void initState() {
//     super.initState();

//     _lastState = context.read<AuthCubit>().state;

//     Timer(const Duration(seconds: 2), () {
//       if (mounted) {
//         setState(() {
//           _isTimerDone = true;
//         });
//         _tryNavigate();
//       }
//     });
//   }

//   Future<void> _tryNavigate() async {
//     if (!_isTimerDone || _lastState == null) return;

//     if (_lastState is AuthAuthenticated) {
//       final settingsCubit = context.read<SettingsCubit>();
//       UserSettings? settings;

//       if (settingsCubit.state is SettingsLoaded) {
//         settings = (settingsCubit.state as SettingsLoaded).settings;
//       } else {
//         settings = await getIt<SettingsRepository>().getSettings();
//       }

//       if (settings.isBiometricEnabled) {
//         final bioService = getIt<BiometricService>();
//         final authenticated = await bioService.authenticate();

//         if (authenticated) {
//           if (mounted) Navigator.of(context).pushReplacementNamed('/home');
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   AppLocalizations.of(context).biometricLoginFailed,
//                 ),
//               ),
//             );
//             Navigator.of(context).pushReplacementNamed('/login');
//           }
//         }
//       } else {
//         if (mounted) Navigator.of(context).pushReplacementNamed('/home');
//       }
//     } else if (_lastState is AuthGuest) {
//       Navigator.of(context).pushReplacementNamed('/home');
//     } else if (_lastState is AuthProfileIncomplete) {
//       Navigator.of(context).pushReplacementNamed('/complete_profile');
//     } else if (_lastState is AuthUnauthenticated) {
//       Navigator.of(context).pushReplacementNamed('/login');
//     } else if (_lastState is AuthError) {
//       debugPrint("Auth Error in Splash: ${(_lastState as AuthError).message}");
//       Navigator.of(context).pushReplacementNamed('/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return BlocListener<AuthCubit, AuthState>(
//       listener: (context, state) {
//         _lastState = state;
//         _tryNavigate();
//       },
//       child: Scaffold(
//         // ✅ AppColors.primary → colors.primary
//         backgroundColor: colors.primary,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.track_changes_outlined,
//                 size: 80.sp,
//                 // ✅ Colors.white → colors.onPrimary
//                 color: colors.onPrimary,
//               ),
//               // ✅ SizedBox(height: 20.h) → AtharGap.xl
//               AtharGap.xl,
//               Text(
//                 l10n.athar,
//                 // ✅ AtharTypography
//                 style: AtharTypography.displayLarge.copyWith(
//                   color: colors.onPrimary,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//               // ✅ SizedBox(height: 10.h) → AtharGap.sm
//               AtharGap.sm,
//               Text(
//                 l10n.leaveYourMark,
//                 // ✅ AtharTypography
//                 style: AtharTypography.bodyMedium.copyWith(
//                   // ✅ Colors.white70 → colors.onPrimary.withValues(alpha: 0.7)
//                   color: colors.onPrimary.withValues(alpha: 0.7),
//                 ),
//               ),
//               SizedBox(height: 50.h),
//               if (_isTimerDone)
//                 CircularProgressIndicator(
//                   // ✅ Colors.white → colors.onPrimary
//                   color: colors.onPrimary,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//------------------------------------------------------------------------




//     // ✅ 1. قراءة الحالة الحالية فوراً عند البناء لتجنب ضياعها

//     // 2. بدء المؤقت


//     // 🛑 1. إذا كان المستخدم مسجلاً، نتحقق من البصمة
//       // نحصل على الإعدادات الحالية

//         // إذا لم تكن الإعدادات محملة بعد، نقرأها مباشرة من الـ Repo

//       // إذا كانت البصمة مفعلة، نطلب المصادقة
//         // نستخدم خدمة البصمة عبر GetIt

//           // ✅ بصمة صحيحة -> دخول
//           // ❌ فشل البصمة أو إلغاؤها -> توجيه لصفحة الدخول كإجراء أمني
//             ScaffoldMessenger.of(context).showSnackBar(
//                 content: Text("فشل الدخول البيومتري، يرجى تسجيل الدخول"),
//               ),
//         // البصمة غير مفعلة -> دخول مباشر
//     // 2. بقية الحالات (ضيف، غير مسجل..)

//       },
//       child: Scaffold(
//         backgroundColor: AppColors.primary,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.track_changes_outlined,
//                 size: 80.sp,
//                 color: Colors.white,
//               ),
//               SizedBox(height: 20.h),
//               Text(
//                 "أثر",
//                 style: TextStyle(
//                   fontSize: 32.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//               SizedBox(height: 10.h),
//               Text(
//                 "اترك أثراً في يومك",
//                 style: TextStyle(fontSize: 14.sp, color: Colors.white70),
//               ),
//               SizedBox(height: 50.h),
//               // يظهر التحميل فقط إذا انتهى الوقت ولم يتم اتخاذ قرار بعد
//           ),
//         ),
//       ),




//     // مؤقت لمدة 3 ثواني ثم الانتقال
//       // نستخدم pushReplacement لمنع العودة لشاشة البداية عند الضغط على "رجوع"
//       Navigator.of(context).pushReplacement(

//   /// دالة للتحقق من المصادقة وبدء المزامنة
//   /// دالة للتحقق من حالة الدخول وتوجيه المستخدم
//     // 1. انتظار بسيط لعرض الشعار (UX)


//     // 2. التحقق من وجود جلسة حالية في Supabase

//       // ✅ الحالة أ: المستخدم مسجل دخول

//       // 1. بدء المزامنة في الخلفية فوراً
//       // نستخدم getIt مباشرة لأننا لا نحتاج لعرض حالة الـ Cubit هنا، فقط تشغيل الدالة

//       // 2. التوجيه للداشبورد
//       Navigator.of(context).pushReplacement(
//       // ❌ الحالة ب: المستخدم غير مسجل (جديد أو سجل خروجه)

//       // التوجيه لصفحة تسجيل الدخول
//       Navigator.of(context).pushReplacement(

//       backgroundColor: AppColors.primary, // أو AppColors.background حسب رغبتك
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // أيقونة التطبيق أو الشعار (مؤقتاً أيقونة)
//             Icon(
//               Icons.track_changes_outlined,
//               size: 80.sp,
//               color: Colors.white,
//             ),
//             SizedBox(height: 20.h),
//             // اسم التطبيق
//             Text(
//               "أثر",
//               style: TextStyle(
//                 fontSize: 32.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 fontFamily: 'Tajawal', // إذا كنت تستخدم خطاً معيناً
//               ),
//             ),
//             SizedBox(height: 10.h),
//             Text(
//               "اترك أثراً في يومك",
//               style: TextStyle(fontSize: 14.sp, color: Colors.white70),
//             ),
//             SizedBox(height: 50.h),
//             // مؤشر تحميل صغير
//         ),
//       ),
//------------------------------------------------------------------------
// lib/features/home/presentation/pages/splash_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.3
// ═══════════════════════════════════════════════════════════════════════════════

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ❌ REMOVED: import '../../../../core/design_system/themes/app_colors.dart';

// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/services/biometric_service.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
// import 'package:athar/features/settings/data/models/user_settings.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_state.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   bool _isTimerDone = false;
//   AuthState? _lastState;

//   @override
//   void initState() {
//     super.initState();

//     _lastState = context.read<AuthCubit>().state;

//     Timer(const Duration(seconds: 2), () {
//       if (mounted) {
//         setState(() {
//           _isTimerDone = true;
//         });
//         _tryNavigate();
//       }
//     });
//   }

//   Future<void> _tryNavigate() async {
//     if (!_isTimerDone || _lastState == null) return;

//     if (_lastState is AuthAuthenticated) {
//       final settingsCubit = context.read<SettingsCubit>();
//       UserSettings? settings;

//       if (settingsCubit.state is SettingsLoaded) {
//         settings = (settingsCubit.state as SettingsLoaded).settings;
//       } else {
//         settings = await getIt<SettingsRepository>().getSettings();
//       }

//       if (settings.isBiometricEnabled) {
//         final bioService = getIt<BiometricService>();
//         final authenticated = await bioService.authenticate();

//         if (authenticated) {
//           if (mounted) Navigator.of(context).pushReplacementNamed('/home');
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("فشل الدخول البيومتري، يرجى تسجيل الدخول"),
//               ),
//             );
//             Navigator.of(context).pushReplacementNamed('/login');
//           }
//         }
//       } else {
//         if (mounted) Navigator.of(context).pushReplacementNamed('/home');
//       }
//     } else if (_lastState is AuthGuest) {
//       Navigator.of(context).pushReplacementNamed('/home');
//     } else if (_lastState is AuthProfileIncomplete) {
//       Navigator.of(context).pushReplacementNamed('/complete_profile');
//     } else if (_lastState is AuthUnauthenticated) {
//       Navigator.of(context).pushReplacementNamed('/login');
//     } else if (_lastState is AuthError) {
//       debugPrint("Auth Error in Splash: ${(_lastState as AuthError).message}");
//       Navigator.of(context).pushReplacementNamed('/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;

//     return BlocListener<AuthCubit, AuthState>(
//       listener: (context, state) {
//         _lastState = state;
//         _tryNavigate();
//       },
//       child: Scaffold(
//         // ✅ AppColors.primary → colors.primary
//         backgroundColor: colors.primary,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.track_changes_outlined,
//                 size: 80.sp,
//                 // ✅ Colors.white → colors.onPrimary
//                 color: colors.onPrimary,
//               ),
//               // ✅ SizedBox(height: 20.h) → AtharGap.xl
//               AtharGap.xl,
//               Text(
//                 "أثر",
//                 // ✅ AtharTypography
//                 style: AtharTypography.displayLarge.copyWith(
//                   color: colors.onPrimary,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//               // ✅ SizedBox(height: 10.h) → AtharGap.sm
//               AtharGap.sm,
//               Text(
//                 "اترك أثراً في يومك",
//                 // ✅ AtharTypography
//                 style: AtharTypography.bodyMedium.copyWith(
//                   // ✅ Colors.white70 → colors.onPrimary.withValues(alpha: 0.7)
//                   color: colors.onPrimary.withValues(alpha: 0.7),
//                 ),
//               ),
//               SizedBox(height: 50.h),
//               if (_isTimerDone)
//                 CircularProgressIndicator(
//                   // ✅ Colors.white → colors.onPrimary
//                   color: colors.onPrimary,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//------------------------------------------------------------------------
// import 'dart:async';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/services/biometric_service.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
// import 'package:athar/features/settings/data/models/user_settings.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   bool _isTimerDone = false;
//   AuthState? _lastState;

//   @override
//   void initState() {
//     super.initState();

//     // ✅ 1. قراءة الحالة الحالية فوراً عند البناء لتجنب ضياعها
//     _lastState = context.read<AuthCubit>().state;

//     // 2. بدء المؤقت
//     Timer(const Duration(seconds: 2), () {
//       if (mounted) {
//         setState(() {
//           _isTimerDone = true;
//         });
//         _tryNavigate();
//       }
//     });
//   }

//   Future<void> _tryNavigate() async {
//     if (!_isTimerDone || _lastState == null) return;

//     // 🛑 1. إذا كان المستخدم مسجلاً، نتحقق من البصمة
//     if (_lastState is AuthAuthenticated) {
//       // نحصل على الإعدادات الحالية
//       final settingsCubit = context.read<SettingsCubit>();
//       UserSettings? settings;

//       if (settingsCubit.state is SettingsLoaded) {
//         settings = (settingsCubit.state as SettingsLoaded).settings;
//       } else {
//         // إذا لم تكن الإعدادات محملة بعد، نقرأها مباشرة من الـ Repo
//         settings = await getIt<SettingsRepository>().getSettings();
//       }

//       // إذا كانت البصمة مفعلة، نطلب المصادقة
//       if (settings.isBiometricEnabled) {
//         // نستخدم خدمة البصمة عبر GetIt
//         final bioService = getIt<BiometricService>();
//         final authenticated = await bioService.authenticate();

//         if (authenticated) {
//           // ✅ بصمة صحيحة -> دخول
//           if (mounted) Navigator.of(context).pushReplacementNamed('/home');
//         } else {
//           // ❌ فشل البصمة أو إلغاؤها -> توجيه لصفحة الدخول كإجراء أمني
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("فشل الدخول البيومتري، يرجى تسجيل الدخول"),
//               ),
//             );
//             Navigator.of(context).pushReplacementNamed('/login');
//           }
//         }
//       } else {
//         // البصمة غير مفعلة -> دخول مباشر
//         if (mounted) Navigator.of(context).pushReplacementNamed('/home');
//       }
//     }
//     // 2. بقية الحالات (ضيف، غير مسجل..)
//     else if (_lastState is AuthGuest) {
//       Navigator.of(context).pushReplacementNamed('/home');
//     } else if (_lastState is AuthProfileIncomplete) {
//       Navigator.of(context).pushReplacementNamed('/complete_profile');
//     } else if (_lastState is AuthUnauthenticated) {
//       Navigator.of(context).pushReplacementNamed('/login');
//     } else if (_lastState is AuthError) {
//       debugPrint("Auth Error in Splash: ${(_lastState as AuthError).message}");
//       Navigator.of(context).pushReplacementNamed('/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthCubit, AuthState>(
//       listener: (context, state) {
//         _lastState = state;
//         _tryNavigate();
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.primary,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.track_changes_outlined,
//                 size: 80.sp,
//                 color: Colors.white,
//               ),
//               SizedBox(height: 20.h),
//               Text(
//                 "أثر",
//                 style: TextStyle(
//                   fontSize: 32.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//               SizedBox(height: 10.h),
//               Text(
//                 "اترك أثراً في يومك",
//                 style: TextStyle(fontSize: 14.sp, color: Colors.white70),
//               ),
//               SizedBox(height: 50.h),
//               // يظهر التحميل فقط إذا انتهى الوقت ولم يتم اتخاذ قرار بعد
//               if (_isTimerDone)
//                 const CircularProgressIndicator(color: Colors.white),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/auth/presentation/pages/login_page.dart';
// import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../../core/design_system/theme/app_colors.dart';
// import 'main_page.dart'; // استيراد الصفحة الرئيسية الجديدة

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthAndNavigate();
//     // مؤقت لمدة 3 ثواني ثم الانتقال
//     Timer(const Duration(milliseconds: 750), () {
//       // نستخدم pushReplacement لمنع العودة لشاشة البداية عند الضغط على "رجوع"
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const MainPage()),
//       );
//     });
//   }

//   /// دالة للتحقق من المصادقة وبدء المزامنة
//   /// دالة للتحقق من حالة الدخول وتوجيه المستخدم
//   Future<void> _checkAuthAndNavigate() async {
//     // 1. انتظار بسيط لعرض الشعار (UX)
//     await Future.delayed(const Duration(seconds: 2));

//     if (!mounted) return;

//     // 2. التحقق من وجود جلسة حالية في Supabase
//     final session = Supabase.instance.client.auth.currentSession;

//     if (session != null) {
//       // ✅ الحالة أ: المستخدم مسجل دخول

//       // 1. بدء المزامنة في الخلفية فوراً
//       // نستخدم getIt مباشرة لأننا لا نحتاج لعرض حالة الـ Cubit هنا، فقط تشغيل الدالة
//       getIt<SyncCubit>().triggerSync();

//       // 2. التوجيه للداشبورد
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const MainPage()),
//       );
//     } else {
//       // ❌ الحالة ب: المستخدم غير مسجل (جديد أو سجل خروجه)

//       // التوجيه لصفحة تسجيل الدخول
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary, // أو AppColors.background حسب رغبتك
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // أيقونة التطبيق أو الشعار (مؤقتاً أيقونة)
//             Icon(
//               Icons.track_changes_outlined,
//               size: 80.sp,
//               color: Colors.white,
//             ),
//             SizedBox(height: 20.h),
//             // اسم التطبيق
//             Text(
//               "أثر",
//               style: TextStyle(
//                 fontSize: 32.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 fontFamily: 'Tajawal', // إذا كنت تستخدم خطاً معيناً
//               ),
//             ),
//             SizedBox(height: 10.h),
//             Text(
//               "اترك أثراً في يومك",
//               style: TextStyle(fontSize: 14.sp, color: Colors.white70),
//             ),
//             SizedBox(height: 50.h),
//             // مؤشر تحميل صغير
//             const CircularProgressIndicator(color: Colors.white),
//           ],
//         ),
//       ),
//     );
//   }
// }
