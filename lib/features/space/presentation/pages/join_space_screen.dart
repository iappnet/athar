import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/space/presentation/cubit/join_space_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JoinSpaceScreen extends StatelessWidget {
  final String token;

  const JoinSpaceScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => getIt<JoinSpaceCubit>()..joinSpace(token),
      child: Scaffold(
        body: BlocConsumer<JoinSpaceCubit, JoinSpaceState>(
          listener: (context, state) {
            if (state is JoinSpaceSuccess) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.joinSpaceSuccess)));
            }
          },
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: AtharSpacing.allXxxl,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state is JoinSpaceLoading ||
                        state is JoinSpaceInitial) ...[
                      const CircularProgressIndicator(),
                      AtharGap.xl,
                      Text(
                        l10n.joinSpaceLoading,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ] else if (state is JoinSpaceError) ...[
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.error,
                        size: 60.sp,
                      ),
                      AtharGap.xl,
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AtharGap.xxl,
                      ElevatedButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/home', (route) => false),
                        child: Text(l10n.joinSpaceBackHome),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
//----------------------------------------------------------------------
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/space/presentation/cubit/join_space_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class JoinSpaceScreen extends StatelessWidget {
//   final String token; // التوكن القادم من الرابط

//   const JoinSpaceScreen({super.key, required this.token});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<JoinSpaceCubit>()..joinSpace(token),
//       child: Scaffold(
//         body: BlocConsumer<JoinSpaceCubit, JoinSpaceState>(
//           listener: (context, state) {
//             if (state is JoinSpaceSuccess) {
//               // توجيه للرئيسية مع رسالة نجاح
//               Navigator.of(
//                 context,
//               ).pushNamedAndRemoveUntil('/home', (route) => false);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('تم الانضمام للمساحة بنجاح! 🎉')),
//               );
//             }
//           },
//           builder: (context, state) {
//             return Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20.w),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (state is JoinSpaceLoading ||
//                         state is JoinSpaceInitial) ...[
//                       const CircularProgressIndicator(),
//                       SizedBox(height: 20.h),
//                       Text(
//                         "جاري الانضمام للمساحة...",
//                         style: TextStyle(fontSize: 16.sp),
//                       ),
//                     ] else if (state is JoinSpaceError) ...[
//                       Icon(Icons.error_outline, color: Colors.red, size: 60.sp),
//                       SizedBox(height: 20.h),
//                       Text(
//                         state.message,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       SizedBox(height: 30.h),
//                       ElevatedButton(
//                         onPressed: () => Navigator.of(
//                           context,
//                         ).pushNamedAndRemoveUntil('/home', (route) => false),
//                         child: const Text("العودة للرئيسية"),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//----------------------------------------------------------------------
