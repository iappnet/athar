import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/space/presentation/cubit/inbox_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    timeago.setLocaleMessages('ar', timeago.ArMessages());

    return BlocProvider(
      create: (context) => getIt<InboxCubit>()..loadInvites(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            l10n.inboxTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
        ),
        body: BlocBuilder<InboxCubit, InboxState>(
          builder: (context, state) {
            if (state is InboxLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InboxEmpty) {
              return _buildEmptyState(colorScheme, l10n);
            } else if (state is InboxError) {
              return Center(child: Text(state.message));
            } else if (state is InboxLoaded) {
              return ListView.builder(
                padding: AtharSpacing.allXl,
                itemCount: state.invitations.length,
                itemBuilder: (context, index) {
                  final invite = state.invitations[index];

                  final timeAgo = timeago.format(
                    invite.createdAt ?? DateTime.now(),
                    locale: 'ar',
                  );

                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: AtharRadii.card,
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: AtharSpacing.allXl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.mail_outline,
                                color: colorScheme.primary,
                              ),
                              AtharGap.hSm,
                              Text(
                                l10n.inboxNewInvite,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: AtharRadii.card,
                                ),
                                child: Text(
                                  timeAgo,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AtharGap.sm,
                          Text(
                            l10n.inboxInviteMessage,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14.sp,
                              height: 1.5,
                            ),
                          ),
                          AtharGap.lg,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<InboxCubit>().acceptInvite(
                                    invite.token,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.inboxJoiningSpace),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check, size: 18),
                                label: Text(l10n.inboxAcceptInvite),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AtharRadii.radiusSm,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 80.sp,
            color: colorScheme.outlineVariant,
          ),
          AtharGap.lg,
          Text(
            l10n.inboxEmptyTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.outline,
            ),
          ),
          Text(
            l10n.inboxEmptySubtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}
//----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/space/presentation/cubit/inbox_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// // ✅ 1. استعادة مكتبة الوقت
// import 'package:timeago/timeago.dart' as timeago;

// class InboxPage extends StatelessWidget {
//   const InboxPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // ✅ 2. تهيئة اللغة العربية لمكتبة timeago
//     timeago.setLocaleMessages('ar', timeago.ArMessages());

//     return BlocProvider(
//       create: (context) => getIt<InboxCubit>()..loadInvites(),
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: const Text(
//             "صندوق الدعوات",
//             style: TextStyle(
//               fontFamily: 'Tajawal',
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           foregroundColor: AppColors.textPrimary,
//         ),
//         body: BlocBuilder<InboxCubit, InboxState>(
//           builder: (context, state) {
//             if (state is InboxLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is InboxEmpty) {
//               return _buildEmptyState();
//             } else if (state is InboxError) {
//               return Center(child: Text(state.message));
//             } else if (state is InboxLoaded) {
//               return ListView.builder(
//                 padding: EdgeInsets.all(16.w),
//                 itemCount: state.invitations.length,
//                 itemBuilder: (context, index) {
//                   final invite = state.invitations[index];

//                   // ✅ حساب الوقت المنقضي (تأكد أن created_at موجود في الموديل)
//                   // إذا لم يكن موجوداً، يمكنك استخدام invite.expiresAt وطرح 7 أيام
//                   final timeAgo = timeago.format(
//                     invite.createdAt ?? DateTime.now(),
//                     locale: 'ar',
//                   );

//                   return Card(
//                     margin: EdgeInsets.only(bottom: 12.h),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     elevation: 2,
//                     child: Padding(
//                       padding: EdgeInsets.all(16.w),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // الصف العلوي: الأيقونة + العنوان + الوقت
//                           Row(
//                             children: [
//                               const Icon(
//                                 Icons.mail_outline,
//                                 color: AppColors.primary,
//                               ),
//                               SizedBox(width: 8.w),
//                               Text(
//                                 "دعوة جديدة",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16.sp,
//                                   fontFamily: 'Tajawal',
//                                 ),
//                               ),
//                               const Spacer(), // يدفع الوقت لليسار
//                               // ✅ عرض الوقت هنا
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 8.w,
//                                   vertical: 2.h,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade100,
//                                   borderRadius: BorderRadius.circular(12.r),
//                                 ),
//                                 child: Text(
//                                   timeAgo,
//                                   style: TextStyle(
//                                     fontSize: 10.sp,
//                                     color: Colors.grey.shade600,
//                                     fontFamily: 'Tajawal',
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 8.h),
//                           Text(
//                             "لقد تمت دعوتك للانضمام إلى مساحة عمل جديدة.\nانقر قبول للبدء بالتعاون.",
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontSize: 14.sp,
//                               height: 1.5, // تحسين تباعد الأسطر
//                             ),
//                           ),
//                           SizedBox(height: 16.h),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               ElevatedButton.icon(
//                                 onPressed: () {
//                                   context.read<InboxCubit>().acceptInvite(
//                                     invite.token,
//                                   );
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text(
//                                         "جاري الانضمام للمساحة... 🚀",
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 icon: const Icon(Icons.check, size: 18),
//                                 label: const Text("قبول الدعوة"),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.green,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.mark_email_read_outlined,
//             size: 80.sp,
//             color: Colors.grey.shade300,
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             "لا توجد دعوات جديدة",
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//               fontFamily: 'Tajawal',
//             ),
//           ),
//           Text(
//             "أنت جاهز تماماً! استمتع بوقتك",
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
//           ),
//         ],
//       ),
//     );
//   }
// }
//----------------------------------------------------------------------
