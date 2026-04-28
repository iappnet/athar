import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
import 'package:athar/core/presentation/cubit/locale_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
import 'package:athar/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:athar/features/habits/presentation/cubit/habit_cubit.dart';
import 'package:athar/features/space/presentation/cubit/list_cubit.dart'; // ✅ استيراد القائمة
import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
import 'package:athar/features/space/presentation/pages/join_space_screen.dart';
import 'package:athar/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/design_system/themes/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/home/presentation/pages/onboarding_page.dart';
import 'features/home/presentation/pages/splash_page.dart';
import 'features/settings/presentation/cubit/settings_state.dart';
import 'core/di/injection.dart';
import 'dart:math';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/space/presentation/cubit/space_cubit.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:athar/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:athar/core/services/local_notification_service.dart';
import 'features/home/presentation/pages/main_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
// ✅ استيراد خدمة الروابط للوصول للمفتاح
import 'package:athar/core/services/deep_link_service.dart';
import 'package:athar/features/calendar/presentation/cubit/calendar_cubit.dart';

class AtharApp extends StatefulWidget {
  const AtharApp({super.key, required this.hasSeenOnboarding});
  final bool hasSeenOnboarding;

  @override
  State<AtharApp> createState() => _AtharAppState();
}

class _AtharAppState extends State<AtharApp> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _clearNotificationBadges();
    // Navigate for cold-start after the first frame so the navigator is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = getIt<LocalNotificationService>();
      final payload = notificationService.consumeColdStartPayload();
      if (payload != null) {
        notificationService.navigateFromNotificationPayload(payload);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _confettiController.dispose();
    super.dispose();
  }

  late final WidgetsBindingObserver _lifecycleObserver = _AppLifecycleObserver(
    onResume: () async {
      await _clearNotificationBadges();
      getIt<SubscriptionCubit>().loadStatus();
    },
  );

  Future<void> _clearNotificationBadges() async {
    final repository = getIt<NotificationsRepository>();
    final notificationService = getIt<LocalNotificationService>();

    try {
      // Log any notifications still sitting in the system tray so they
      // appear in the in-app notification center (covers prayer & local ones).
      await notificationService.logActiveNotifications();
      await repository.syncNotifications();
      await repository.markAllAsRead();
      await notificationService.setAppBadge(0);
    } catch (_) {
      await notificationService.setAppBadge(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1. الأساسيات والأنظمة العامة
        BlocProvider(create: (_) => getIt<CelebrationCubit>()),
        BlocProvider(create: (_) => getIt<SettingsCubit>()..loadSettings()),
        BlocProvider(create: (_) => getIt<SyncCubit>()..triggerSync()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),
        BlocProvider(
          create: (_) => getIt<NotificationsCubit>()..watchNotifications(),
        ),

        // 2. الميزات الرئيسية (إسلاميات، عادات)
        BlocProvider(create: (_) => getIt<PrayerCubit>()..loadPrayerTimes()),
        BlocProvider(create: (_) => getIt<HabitCubit>()..loadHabits()),
        BlocProvider(create: (_) => getIt<CategoryCubit>()),

        // 3. إدارة المساحات والمشاريع
        BlocProvider(create: (_) => getIt<SpaceCubit>()),
        BlocProvider(create: (_) => getIt<ModuleCubit>()),

        // 4. المهام (تحميل مهام اليوم افتراضياً)
        BlocProvider(
          create: (_) => getIt<TaskCubit>()..watchTasks(DateTime.now()),
        ),

        // 5. الميزات الجديدة (الأصول والقوائم)
        BlocProvider(
          create: (_) => getIt<CalendarCubit>()..selectDate(DateTime.now()),
        ),
        BlocProvider(create: (context) => getIt<AssetsCubit>()), // ✅ الأصول
        BlocProvider(
          create: (context) => getIt<ListCubit>(),
        ), // ✅ القوائم (المقاضي)

        // 6. الاشتراك
        BlocProvider(
          create: (_) => getIt<SubscriptionCubit>()..loadStatus(),
        ),

        // 7. اللغة
        BlocProvider(
          create: (_) =>
              LocaleCubit(const FlutterSecureStorage())..loadLocale(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final locale = context.watch<LocaleCubit>().state.locale;
          final settingsState = context.watch<SettingsCubit>().state;
          final isDark = settingsState is SettingsLoaded
              ? settingsState.settings.isDarkMode
              : false;
          return MaterialApp(
            navigatorKey: DeepLinkService.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Athar | أثر',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            locale: locale,
            supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
            localizationsDelegates: [
              AppLocalizations.delegate, // ← هذا كان مفقوداً!
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: widget.hasSeenOnboarding
                ? const SplashPage()
                : const OnboardingPage(),
            routes: {
              '/join-space': (context) {
                final token =
                    ModalRoute.of(context)!.settings.arguments as String;
                return JoinSpaceScreen(token: token);
              },
              '/home': (context) => const MainPage(),
              '/login': (context) => const LoginPage(),
              '/complete_profile': (context) => const CompleteProfilePage(),
            },
            builder: (context, widget) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (widget != null) widget,
                  BlocListener<CelebrationCubit, CelebrationState>(
                    listener: (context, state) {
                      if (state is CelebrationTriggered) {
                        _confettiController.play();
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  BlocListener<SubscriptionCubit, SubscriptionState>(
                    listenWhen: (_, curr) => curr is SubscriptionError,
                    listener: (context, state) {
                      if (state is SubscriptionError) {
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  Positioned(
                    top: -20,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple,
                      ],
                      createParticlePath: drawStar,
                      numberOfParticles: 20,
                      gravity: 0.2,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (3.141592653589793 / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final Future<void> Function() onResume;

  _AppLifecycleObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}
