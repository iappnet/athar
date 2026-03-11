import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/focus/presentation/cubit/focus_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../cubit/focus_cubit.dart';
import '../widgets/liquid_background.dart';

class FocusPage extends StatelessWidget {
  final String? focusTarget;

  const FocusPage({super.key, this.focusTarget});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => getIt<FocusCubit>(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: SharpLiquidBackground()),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (focusTarget != null) ...[
                    Text(
                      l10n.focusNowOn,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.outline,
                      ),
                    ),
                    AtharGap.sm,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        focusTarget!,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],

                  const _FocusTimerDisplay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusTimerDisplay extends StatelessWidget {
  const _FocusTimerDisplay();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<FocusCubit, FocusState>(
      builder: (context, state) {
        int minutes = state.duration ~/ 60;
        int seconds = state.duration % 60;
        String formattedTime =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        return Column(
          children: [
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 90.sp,
                fontWeight: FontWeight.w100,
                color: colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: -2,
              ),
            ),

            Text(
              state is FocusRunning
                  ? l10n.focusStatusRunning
                  : state is FocusPaused
                  ? l10n.focusStatusPaused
                  : l10n.focusStatusReady,
              style: TextStyle(
                fontSize: 16.sp,
                color: colorScheme.outline,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 60.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state is FocusRunning) ...[
                  _buildModernButton(
                    icon: Icons.pause_rounded,
                    label: l10n.focusPause,
                    color: Colors.amber.shade700,
                    bgColor: Colors.amber.shade50,
                    onTap: () => context.read<FocusCubit>().pauseTimer(),
                  ),
                  SizedBox(width: 30.w),
                  _buildModernButton(
                    icon: Icons.stop_rounded,
                    label: l10n.focusStop,
                    color: Colors.redAccent,
                    bgColor: Colors.red.shade50,
                    onTap: () => context.read<FocusCubit>().resetTimer(),
                  ),
                ] else if (state is FocusPaused) ...[
                  _buildModernButton(
                    icon: Icons.play_arrow_rounded,
                    label: l10n.focusResume,
                    color: colorScheme.primary,
                    bgColor: colorScheme.primary.withValues(alpha: 0.1),
                    onTap: () => context.read<FocusCubit>().resumeTimer(),
                    isLarge: true,
                  ),
                  SizedBox(width: 30.w),
                  _buildModernButton(
                    icon: Icons.refresh_rounded,
                    label: l10n.focusReset,
                    color: Colors.grey,
                    bgColor: colorScheme.surfaceContainerHighest,
                    onTap: () => context.read<FocusCubit>().resetTimer(),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: () => context.read<FocusCubit>().startTimer(),
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: colorScheme.onPrimary,
                        size: 40.sp,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: isLarge ? 70.w : 60.w,
            height: isLarge ? 70.w : 60.w,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: isLarge ? 32.sp : 28.sp),
          ),
        ),
        AtharGap.sm,
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
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
//                     bgColor: AppColors.primary.withOpacity(0.1),
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
//                             color: AppColors.primary.withOpacity(0.4),
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
//             color: Colors.white.withOpacity(0.9), // خلفية بيضاء لضمان القراءة
//             borderRadius: BorderRadius.circular(40.r),
//             border: Border.all(color: Colors.grey.shade300),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
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
//               color: Colors.black.withOpacity(0.1),
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
