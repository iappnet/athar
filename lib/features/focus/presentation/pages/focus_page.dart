// lib/features/focus/presentation/pages/focus_page_enhanced.dart
// ✅ صفحة التركيز المحسنة - متوافقة مع FocusCubit المعدل

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ❌ لا نستورد wakelock_plus هنا - FocusCubit يديره
import '../../../../core/di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/focus_cubit.dart' hide Ticker;
import '../cubit/focus_state.dart';
import '../widgets/fluid_engine.dart';

/// أنواع خلفية التركيز
enum FocusBackgroundType {
  advanced, // FluidEngine المتقدم
  simple, // الخلفية البسيطة الأصلية
}

class FocusPage extends StatefulWidget {
  final String? focusTarget;
  final FocusBackgroundType backgroundType;

  const FocusPage({
    super.key,
    this.focusTarget,
    this.backgroundType = FocusBackgroundType.advanced,
  });

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage>
    with SingleTickerProviderStateMixin {
  late final FluidEngine _fluidEngine;
  late final Ticker _ticker;
  bool _isEngineRunning = false;

  // ألوان قابلة للتخصيص
  final List<FocusColorTheme> _colorThemes = [
    FocusColorTheme(
      name: 'بنفسجي هادئ',
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF4F46E5),
      highlight: const Color(0xFFA5B4FC),
    ),
    FocusColorTheme(
      name: 'أزرق محيط',
      primary: const Color(0xFF0EA5E9),
      secondary: const Color(0xFF0284C7),
      highlight: const Color(0xFF7DD3FC),
    ),
    FocusColorTheme(
      name: 'أخضر طبيعة',
      primary: const Color(0xFF10B981),
      secondary: const Color(0xFF059669),
      highlight: const Color(0xFF6EE7B7),
    ),
    FocusColorTheme(
      name: 'برتقالي دافئ',
      primary: const Color(0xFFF59E0B),
      secondary: const Color(0xFFD97706),
      highlight: const Color(0xFFFCD34D),
    ),
    FocusColorTheme(
      name: 'وردي ناعم',
      primary: const Color(0xFFEC4899),
      secondary: const Color(0xFFDB2777),
      highlight: const Color(0xFFF9A8D4),
    ),
  ];
  int _selectedThemeIndex = 0;

  @override
  void initState() {
    super.initState();
    _fluidEngine = FluidEngine();
    _ticker = createTicker(_onTick);

    // ✅ WakeLock يُدار من FocusCubit - لا نفعله هنا

    // إخفاء شريط النظام للتجربة الغامرة
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _onTick(Duration elapsed) {
    if (_isEngineRunning) {
      setState(() {
        _fluidEngine.update(0.016); // ~60 FPS
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    // ✅ WakeLock يُدار من FocusCubit - لا نعطله هنا
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _applyTheme(int index) {
    setState(() {
      _selectedThemeIndex = index;
      final theme = _colorThemes[index];
      _fluidEngine.setColors(theme.primary, theme.secondary, theme.highlight);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    _fluidEngine.updateScreenSize(size.width, size.height);
    final currentTheme = _colorThemes[_selectedThemeIndex];

    return BlocProvider(
      create: (context) {
        final cubit = getIt<FocusCubit>();
        // ✅ تعيين المهمة إذا كانت موجودة
        if (widget.focusTarget != null) {
          cubit.setTask(widget.focusTarget);
        }
        return cubit;
      },
      child: BlocListener<FocusCubit, FocusState>(
        listener: (context, state) {
          if (state is FocusRunning && !_isEngineRunning) {
            _isEngineRunning = true;
            _ticker.start();
          } else if (state is! FocusRunning && _isEngineRunning) {
            _isEngineRunning = false;
            _ticker.stop();
          }

          if (state is FocusInitial || state is FocusCompleted) {
            _fluidEngine.reset();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // الخلفية
              if (widget.backgroundType == FocusBackgroundType.advanced)
                _buildAdvancedBackground(size)
              else
                _buildSimpleBackground(currentTheme),

              // المحتوى
              SafeArea(
                child: Column(
                  children: [
                    // شريط علوي
                    _buildTopBar(context, l10n),

                    const Spacer(),

                    // هدف التركيز
                    if (widget.focusTarget != null)
                      _buildFocusTarget(l10n, currentTheme),

                    // ✅ اختيار المدة (جديد)
                    _buildDurationSelector(context, currentTheme),

                    SizedBox(height: 20.h),

                    // العداد
                    _buildTimerDisplay(context, l10n, currentTheme),

                    const Spacer(),

                    // أزرار التحكم
                    _buildControls(context, l10n, currentTheme),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ✅ اختيار المدة (جديد)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildDurationSelector(BuildContext context, FocusColorTheme theme) {
    return BlocBuilder<FocusCubit, FocusState>(
      builder: (context, state) {
        // فقط نعرض في حالة Initial
        if (state is! FocusInitial) return const SizedBox.shrink();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDurationChip('15', 'short', context, theme),
            SizedBox(width: 12.w),
            _buildDurationChip('25', 'pomodoro', context, theme),
            SizedBox(width: 12.w),
            _buildDurationChip('45', 'long', context, theme),
            SizedBox(width: 12.w),
            _buildDurationChip('60', 'hour', context, theme),
          ],
        );
      },
    );
  }

  Widget _buildDurationChip(
    String label,
    String preset,
    BuildContext context,
    FocusColorTheme theme,
  ) {
    final cubit = context.read<FocusCubit>();
    final isSelected = cubit.currentDurationMinutes == int.parse(label);

    return GestureDetector(
      onTap: () => cubit.setDuration(preset),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: AtharRadii.radiusXl,
          border: Border.all(
            color: isSelected ? theme.primary : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          '$label د',
          style: TextStyle(
            color: isSelected ? theme.primary : Colors.white70,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // الخلفيات
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildAdvancedBackground(Size size) {
    return Positioned.fill(
      child: CustomPaint(
        painter: FluidPainter(
          engine: _fluidEngine,
          fillPercentage: _fluidEngine.fillPercentage,
        ),
      ),
    );
  }

  Widget _buildSimpleBackground(FocusColorTheme theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [theme.primary.withValues(alpha: 0.15), Colors.black],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // الشريط العلوي
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => _handleBack(context),
          ),
          _buildGlassButton(
            icon: Icons.palette_outlined,
            onTap: () => _showColorPicker(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: AtharRadii.radiusLg,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 22.sp),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // هدف التركيز
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildFocusTarget(AppLocalizations l10n, FocusColorTheme theme) {
    return Column(
      children: [
        Text(
          l10n.focusNowOn,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.2),
            borderRadius: AtharRadii.radiusXxl,
            border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            widget.focusTarget!,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // عرض العداد
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTimerDisplay(
    BuildContext context,
    AppLocalizations l10n,
    FocusColorTheme theme,
  ) {
    return BlocBuilder<FocusCubit, FocusState>(
      builder: (context, state) {
        final minutes = state.duration ~/ 60;
        final seconds = state.duration % 60;
        final formattedTime =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: AtharRadii.radiusXxxl,
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 72.sp,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -2,
                  shadows: [
                    Shadow(
                      color: theme.primary.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _getStatusText(state, l10n),
              style: TextStyle(
                fontSize: 16.sp,
                color: _getStatusColor(state, theme),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getStatusText(FocusState state, AppLocalizations l10n) {
    if (state is FocusRunning) return l10n.focusStatusRunning;
    if (state is FocusPaused) return l10n.focusStatusPaused;
    if (state is FocusCompleted) return l10n.sessionCompleted;
    return l10n.focusStatusReady;
  }

  Color _getStatusColor(FocusState state, FocusColorTheme theme) {
    if (state is FocusRunning) return theme.primary;
    if (state is FocusPaused) return Colors.amber;
    if (state is FocusCompleted) return Colors.green;
    return Colors.white.withValues(alpha: 0.6);
  }

  // ═══════════════════════════════════════════════════════════════════
  // أزرار التحكم
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildControls(
    BuildContext context,
    AppLocalizations l10n,
    FocusColorTheme theme,
  ) {
    return BlocBuilder<FocusCubit, FocusState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state is FocusRunning) ...[
              _buildControlButton(
                icon: Icons.pause_rounded,
                label: l10n.focusPause,
                color: Colors.amber,
                onTap: () => context.read<FocusCubit>().pauseTimer(),
              ),
              SizedBox(width: 24.w),
              _buildControlButton(
                icon: Icons.stop_rounded,
                label: l10n.focusStop,
                color: Colors.redAccent,
                onTap: () => context.read<FocusCubit>().resetTimer(),
              ),
            ] else if (state is FocusPaused) ...[
              _buildControlButton(
                icon: Icons.play_arrow_rounded,
                label: l10n.focusResume,
                color: theme.primary,
                isLarge: true,
                onTap: () => context.read<FocusCubit>().resumeTimer(),
              ),
              SizedBox(width: 24.w),
              _buildControlButton(
                icon: Icons.refresh_rounded,
                label: l10n.focusReset,
                color: Colors.grey,
                onTap: () => context.read<FocusCubit>().resetTimer(),
              ),
            ] else if (state is FocusCompleted) ...[
              _buildControlButton(
                icon: Icons.replay_rounded,
                label: 'جلسة جديدة',
                color: theme.primary,
                isLarge: true,
                onTap: () => context.read<FocusCubit>().resetTimer(),
              ),
            ] else ...[
              _buildMainPlayButton(context, theme),
            ],
          ],
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    final size = isLarge ? 70.w : 60.w;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: isLarge ? 32.sp : 28.sp),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: color.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMainPlayButton(BuildContext context, FocusColorTheme theme) {
    return GestureDetector(
      onTap: () => context.read<FocusCubit>().startTimer(),
      child: Container(
        width: 90.w,
        height: 90.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.primary, theme.secondary],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.primary.withValues(alpha: 0.5),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 45.sp),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // الدوال المساعدة
  // ═══════════════════════════════════════════════════════════════════

  void _handleBack(BuildContext context) {
    final state = context.read<FocusCubit>().state;
    if (state is FocusRunning || state is FocusPaused) {
      _showExitConfirmation(context);
    } else {
      Navigator.pop(context);
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'إنهاء الجلسة؟',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'سيتم فقدان تقدم هذه الجلسة',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('متابعة'),
          ),
          TextButton(
            onPressed: () {
              context.read<FocusCubit>().resetTimer();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'إنهاء',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر لون التركيز',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: List.generate(_colorThemes.length, (index) {
                final theme = _colorThemes[index];
                final isSelected = index == _selectedThemeIndex;

                return GestureDetector(
                  onTap: () {
                    _applyTheme(index);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primary, theme.secondary],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// نموذج سمة الألوان
// ═══════════════════════════════════════════════════════════════════

class FocusColorTheme {
  final String name;
  final Color primary;
  final Color secondary;
  final Color highlight;

  const FocusColorTheme({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.highlight,
  });
}

//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/tokens/athar_spacing.dart';
// import 'package:athar/features/focus/presentation/cubit/focus_state.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/di/injection.dart';
// import '../cubit/focus_cubit.dart';
// import '../widgets/liquid_background.dart';

// class FocusPage extends StatelessWidget {
//   final String? focusTarget;

//   const FocusPage({super.key, this.focusTarget});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final l10n = AppLocalizations.of(context);

//     return BlocProvider(
//       create: (context) => getIt<FocusCubit>(),
//       child: Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: Stack(
//           children: [
//             const Positioned.fill(child: SharpLiquidBackground()),

//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (focusTarget != null) ...[
//                     Text(
//                       l10n.focusNowOn,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: colorScheme.outline,
//                       ),
//                     ),
//                     AtharGap.sm,
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 16.w,
//                         vertical: 8.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: colorScheme.surfaceContainerHighest,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         focusTarget!,
//                         style: TextStyle(
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.bold,
//                           color: colorScheme.onSurface,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 40.h),
//                   ],

//                   const _FocusTimerDisplay(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _FocusTimerDisplay extends StatelessWidget {
//   const _FocusTimerDisplay();

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final l10n = AppLocalizations.of(context);

//     return BlocBuilder<FocusCubit, FocusState>(
//       builder: (context, state) {
//         int minutes = state.duration ~/ 60;
//         int seconds = state.duration % 60;
//         String formattedTime =
//             '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

//         return Column(
//           children: [
//             Text(
//               formattedTime,
//               style: TextStyle(
//                 fontSize: 90.sp,
//                 fontWeight: FontWeight.w100,
//                 color: colorScheme.onSurface,
//                 fontFeatures: const [FontFeature.tabularFigures()],
//                 letterSpacing: -2,
//               ),
//             ),

//             Text(
//               state is FocusRunning
//                   ? l10n.focusStatusRunning
//                   : state is FocusPaused
//                   ? l10n.focusStatusPaused
//                   : l10n.focusStatusReady,
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 color: colorScheme.outline,
//                 letterSpacing: 1.2,
//               ),
//             ),

//             SizedBox(height: 60.h),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (state is FocusRunning) ...[
//                   _buildModernButton(
//                     icon: Icons.pause_rounded,
//                     label: l10n.focusPause,
//                     color: Colors.amber.shade700,
//                     bgColor: Colors.amber.shade50,
//                     onTap: () => context.read<FocusCubit>().pauseTimer(),
//                   ),
//                   SizedBox(width: 30.w),
//                   _buildModernButton(
//                     icon: Icons.stop_rounded,
//                     label: l10n.focusStop,
//                     color: Colors.redAccent,
//                     bgColor: Colors.red.shade50,
//                     onTap: () => context.read<FocusCubit>().resetTimer(),
//                   ),
//                 ] else if (state is FocusPaused) ...[
//                   _buildModernButton(
//                     icon: Icons.play_arrow_rounded,
//                     label: l10n.focusResume,
//                     color: colorScheme.primary,
//                     bgColor: colorScheme.primary.withValues(alpha: 0.1),
//                     onTap: () => context.read<FocusCubit>().resumeTimer(),
//                     isLarge: true,
//                   ),
//                   SizedBox(width: 30.w),
//                   _buildModernButton(
//                     icon: Icons.refresh_rounded,
//                     label: l10n.focusReset,
//                     color: Colors.grey,
//                     bgColor: colorScheme.surfaceContainerHighest,
//                     onTap: () => context.read<FocusCubit>().resetTimer(),
//                   ),
//                 ] else ...[
//                   GestureDetector(
//                     onTap: () => context.read<FocusCubit>().startTimer(),
//                     child: Container(
//                       width: 80.w,
//                       height: 80.w,
//                       decoration: BoxDecoration(
//                         color: colorScheme.primary,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: colorScheme.primary.withValues(alpha: 0.4),
//                             blurRadius: 20,
//                             offset: const Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.play_arrow_rounded,
//                         color: colorScheme.onPrimary,
//                         size: 40.sp,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildModernButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required Color bgColor,
//     required VoidCallback onTap,
//     bool isLarge = false,
//   }) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             width: isLarge ? 70.w : 60.w,
//             height: isLarge ? 70.w : 60.w,
//             decoration: BoxDecoration(
//               color: bgColor,
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: color.withValues(alpha: 0.2),
//                 width: 1.5,
//               ),
//             ),
//             child: Icon(icon, color: color, size: isLarge ? 32.sp : 28.sp),
//           ),
//         ),
//         AtharGap.sm,
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w600,
//             color: color.withValues(alpha: 0.8),
//           ),
//         ),
//       ],
//     );
//   }
// }
//-----------------------------------------------------------------------
// import 'package:athar/features/focus/presentation/cubit/focus_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../cubit/focus_cubit.dart';
// import '../widgets/liquid_background.dart'; // أو sharp_liquid_background حسب ما اعتمدت

// class FocusPage extends StatelessWidget {
//   // 1. إضافة متغير لاستقبال اسم المهمة
//   final String? focusTarget;

//   const FocusPage({super.key, this.focusTarget});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<FocusCubit>(),
//       child: Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: Stack(
//           children: [
//             // الخلفية السائلة
//             const Positioned.fill(
//               child: SharpLiquidBackground(), // تأكد من اسم الملف المعتمد لديك
//             ),

//             // المحتوى
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // 2. عرض اسم المهمة إن وجد
//                   if (focusTarget != null) ...[
//                     Text(
//                       "أنت تركز الآن على:",
//                       style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//                     ),
//                     SizedBox(height: 8.h),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 16.w,
//                         vertical: 8.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         focusTarget!,
//                         style: TextStyle(
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 40.h),
//                   ],

//                   // العداد (Timer Widget)
//                   const _FocusTimerDisplay(), // (هذا الودجت الفرعي الذي بنيناه سابقاً)
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ... (الجزء العلوي من الملف كما هو)

// class _FocusTimerDisplay extends StatelessWidget {
//   const _FocusTimerDisplay();

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<FocusCubit, FocusState>(
//       builder: (context, state) {
//         int minutes = state.duration ~/ 60;
//         int seconds = state.duration % 60;
//         String formattedTime =
//             '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

//         return Column(
//           children: [
//             // عرض الوقت بخط أنيق وكبير
//             Text(
//               formattedTime,
//               style: TextStyle(
//                 fontSize: 90.sp, // أكبر قليلاً
//                 fontWeight: FontWeight.w100, // نحيف جداً (Ultra Light)
//                 color: AppColors.textPrimary,
//                 fontFeatures: const [FontFeature.tabularFigures()],
//                 letterSpacing: -2, // تباعد حروف أقل للمظهر العصري
//               ),
//             ),

//             // حالة العداد (نص صغير يوضح الحالة)
//             Text(
//               state is FocusRunning
//                   ? "ركز الآن..."
//                   : state is FocusPaused
//                   ? "مؤقت مؤقتاً"
//                   : "جاهز للبدء",
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 color: Colors.grey.shade500,
//                 letterSpacing: 1.2,
//               ),
//             ),

//             SizedBox(height: 60.h),

//             // --- أزرار التحكم العصرية ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (state is FocusRunning) ...[
//                   // زر الإيقاف المؤقت
//                   _buildModernButton(
//                     icon: Icons.pause_rounded,
//                     label: "إيقاف",
//                     color: Colors.amber.shade700,
//                     bgColor: Colors.amber.shade50,
//                     onTap: () => context.read<FocusCubit>().pauseTimer(),
//                   ),
//                   SizedBox(width: 30.w),
//                   // زر الإنهاء
//                   _buildModernButton(
//                     icon: Icons.stop_rounded,
//                     label: "إنهاء",
//                     color: Colors.redAccent,
//                     bgColor: Colors.red.shade50,
//                     onTap: () => context.read<FocusCubit>().resetTimer(),
//                   ),
//                 ] else if (state is FocusPaused) ...[
//                   // زر الاستئناف
//                   _buildModernButton(
//                     icon: Icons.play_arrow_rounded,
//                     label: "استئناف",
//                     color: AppColors.primary,
//                     bgColor: AppColors.primary.withValues(alpha: 0.1),
//                     onTap: () => context.read<FocusCubit>().resumeTimer(),
//                     isLarge: true, // زر أكبر للاستئناف
//                   ),
//                   SizedBox(width: 30.w),
//                   // زر إعادة الضبط
//                   _buildModernButton(
//                     icon: Icons.refresh_rounded,
//                     label: "إعادة",
//                     color: Colors.grey,
//                     bgColor: Colors.grey.shade100,
//                     onTap: () => context.read<FocusCubit>().resetTimer(),
//                   ),
//                 ] else ...[
//                   // زر البدء الكبير (الرئيسي)
//                   GestureDetector(
//                     onTap: () => context.read<FocusCubit>().startTimer(),
//                     child: Container(
//                       width: 80.w,
//                       height: 80.w,
//                       decoration: BoxDecoration(
//                         color: AppColors.primary,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.primary.withValues(alpha: 0.4),
//                             blurRadius: 20,
//                             offset: const Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.play_arrow_rounded,
//                         color: Colors.white,
//                         size: 40.sp,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ودجت الزر المطور
//   Widget _buildModernButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required Color bgColor,
//     required VoidCallback onTap,
//     bool isLarge = false,
//   }) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             width: isLarge ? 70.w : 60.w,
//             height: isLarge ? 70.w : 60.w,
//             decoration: BoxDecoration(
//               color: bgColor,
//               shape: BoxShape.circle,
//               // حدود ناعمة بلون الأيقونة
//               border: Border.all(
//                 color: color.withValues(alpha: 0.2),
//                 width: 1.5,
//               ),
//             ),
//             child: Icon(icon, color: color, size: isLarge ? 32.sp : 28.sp),
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w600,
//             color: color.withValues(alpha: 0.8),
//           ),
//         ),
//       ],
//     );
//   }
// }
//-----------------------------------------------------------------------
// import 'dart:ui';
// import 'package:athar/features/focus/presentation/cubit/focus_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/di/injection.dart';
// import '../cubit/focus_cubit.dart';
// import '../widgets/liquid_background.dart';

// class FocusPage extends StatelessWidget {
//   const FocusPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<FocusCubit>(),
//       child: Scaffold(
//         backgroundColor: Colors.white, // 1. خلفية بيضاء
//         extendBodyBehindAppBar: true,
//         appBar: AppBar(
//           leading: const BackButton(color: Colors.black), // 2. زر عودة أسود
//           title: const Text(
//             "مؤقت التركيز",
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//         ),
//         body: const _FocusView(),
//       ),
//     );
//   }
// }

// class _FocusView extends StatelessWidget {
//   const _FocusView();

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         const Positioned.fill(
//           child: SharpLiquidBackground(), // الخلفية السائلة
//         ),
//         Positioned.fill(
//           child: SafeArea(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: 120.h), // مساحة للجزيرة والكتلة السوداء

//                 const _TimerText(),

//                 SizedBox(height: 40.h),

//                 Text(
//                   "Focus Cycle",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
//                 ),

//                 const Spacer(),
//                 const _ActionButtons(),
//                 SizedBox(height: 80.h),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _TimerText extends StatelessWidget {
//   const _TimerText();

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<FocusCubit, FocusState>(
//       builder: (context, state) {
//         final minutes = ((state.duration / 60) % 60).floor().toString().padLeft(
//           2,
//           '0',
//         );
//         final seconds = (state.duration % 60).floor().toString().padLeft(
//           2,
//           '0',
//         );

//         // 3. تصميم العداد: نص أسود داخل حاوية بيضاء شبه شفافة (لتبقى ظاهرة عندما يملأ السائل الأسود الشاشة)
//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: 0.9), // خلفية بيضاء لضمان القراءة
//             borderRadius: BorderRadius.circular(40.r),
//             border: Border.all(color: Colors.grey.shade300),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.1),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Text(
//             "$minutes:$seconds",
//             style: TextStyle(
//               fontSize: 60.sp,
//               fontWeight: FontWeight.bold,
//               color: Colors.black, // نص أسود
//               fontFeatures: const [FontFeature.tabularFigures()],
//               height: 1,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _ActionButtons extends StatelessWidget {
//   const _ActionButtons();

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<FocusCubit, FocusState>(
//       builder: (context, state) {
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             if (state is FocusRunning) ...[
//               _buildCircleButton(
//                 icon: Icons.pause,
//                 color: Colors.white,
//                 iconColor: Colors.black,
//                 onTap: () => context.read<FocusCubit>().pauseTimer(),
//               ),
//               _buildCircleButton(
//                 icon: Icons.close,
//                 color: Colors.red.shade50,
//                 iconColor: Colors.red,
//                 onTap: () => context.read<FocusCubit>().resetTimer(),
//               ),
//             ] else if (state is FocusPaused) ...[
//               _buildCircleButton(
//                 icon: Icons.play_arrow,
//                 color: Colors.black,
//                 iconColor: Colors.white,
//                 onTap: () => context.read<FocusCubit>().resumeTimer(),
//               ),
//               _buildCircleButton(
//                 icon: Icons.refresh,
//                 color: Colors.grey.shade200,
//                 iconColor: Colors.black,
//                 onTap: () => context.read<FocusCubit>().resetTimer(),
//               ),
//             ] else ...[
//               // زر البدء الرئيسي
//               _buildCircleButton(
//                 icon: Icons.play_arrow,
//                 color: Colors.black, // زر أسود
//                 iconColor: Colors.white,
//                 size: 80.w,
//                 iconSize: 40.sp,
//                 onTap: () => context.read<FocusCubit>().startTimer(),
//               ),
//             ],
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildCircleButton({
//     required IconData icon,
//     required Color color,
//     required Color iconColor,
//     required VoidCallback onTap,
//     double? size,
//     double? iconSize,
//   }) {
//     final buttonSize = size ?? 65.w;
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(buttonSize / 2),
//       child: Container(
//         width: buttonSize,
//         height: buttonSize,
//         decoration: BoxDecoration(
//           color: color,
//           shape: BoxShape.circle,
//           // ظل خفيف للأزرار
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Icon(icon, color: iconColor, size: iconSize ?? 30.sp),
//       ),
//     );
//   }
// }
