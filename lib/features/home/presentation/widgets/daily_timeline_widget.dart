// lib/features/home/presentation/widgets/daily_timeline_widget.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 4 | Part 1 | File 2 (l10n added to existing DS)
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// ✅ Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import 'package:athar/core/di/injection.dart';
import 'package:athar/features/home/domain/entities/daily_item.dart';
import 'package:athar/features/home/presentation/cubit/timeline_cubit.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';

/// Semantic colors (not in ColorScheme)
const _successColor = Color(0xFF00B894);
const _infoColor = Color(0xFF74B9FF);

class DailyTimelineWidget extends StatelessWidget {
  final String? moduleId;

  const DailyTimelineWidget({super.key, this.moduleId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // ✅ NEW: l10n
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) {
        final cubit = getIt<TimelineCubit>();
        if (moduleId != null) {
          cubit.loadDailyTimeline(moduleId!);
        } else {
          cubit.loadGlobalTimeline();
        }
        return cubit;
      },
      child: BlocBuilder<TimelineCubit, TimelineState>(
        builder: (context, state) {
          if (state is TimelineLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          } else if (state is TimelineLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyState(colorScheme, l10n);
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.items.length,
              separatorBuilder: (c, i) => AtharGap.md,
              itemBuilder: (context, index) {
                return _buildItemCard(
                  context,
                  colorScheme,
                  l10n,
                  state.items[index],
                );
              },
            );
          } else if (state is TimelineError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ).copyWith(color: colorScheme.error),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l,
    DailyItem item,
  ) {
    Color color;

    switch (item.type) {
      case DailyItemType.task:
        color = _infoColor;
        break;
      case DailyItemType.medicine:
        color = colorScheme.error;
        break;
      case DailyItemType.appointment:
        color = colorScheme.secondary;
        break;
    }

    String timeText = DateFormat('hh:mm a').format(item.time);

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        border: Border(
          right: BorderSide(color: color, width: 4.w),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // الوقت
          Column(
            children: [
              Text(
                timeText.split(' ')[0],
                style:
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: 0.25,
                    ).copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              Text(
                timeText.split(' ')[1],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  letterSpacing: 0.5,
                ).copyWith(color: colorScheme.outline),
              ),
            ],
          ),
          AtharGap.hMd,
          Container(
            width: 1.w,
            height: 30.h,
            color: colorScheme.outlineVariant,
          ),
          AtharGap.hMd,

          // المحتوى
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ).copyWith(color: colorScheme.onSurface),
                ),
                if (item.subtitle != null && item.subtitle!.isNotEmpty)
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ).copyWith(color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),

          // زر الإجراء
          IconButton(
            icon: Icon(
              item.type == DailyItemType.task
                  ? Icons.circle_outlined
                  : Icons.check_circle_outline,
              color: color,
            ),
            onPressed: () => _handleAction(context, item, l),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, DailyItem item, AppLocalizations l) {
    if (item.type == DailyItemType.medicine) {
      final medicine = item.originalData as MedicineModel;
      getIt<HealthCubit>().takeDose(medicine.moduleId, medicine);
      ScaffoldMessenger.of(context).showSnackBar(
        // ✅ l10n: "تم تسجيل الجرعة ✅"
        SnackBar(content: Text(l.timelineDoseTakenSuccess)),
      );
    } else if (item.type == DailyItemType.task) {
      final task = item.originalData as TaskModel;
      getIt<TaskCubit>().toggleTaskCompletion(task);
      ScaffoldMessenger.of(context).showSnackBar(
        // ✅ l10n: "تم إنجاز المهمة 💪"
        SnackBar(content: Text(l.timelineTaskCompletedSuccess)),
      );
    }
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l) {
    return Container(
      padding: EdgeInsets.all(AtharSpacing.xl),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.spa,
            size: 40.sp,
            color: _successColor.withValues(alpha: 0.5),
          ),
          AtharGap.sm,
          Text(
            // ✅ l10n: "يومك صافٍ! لا توجد مهام أو أدوية حالياً 🌿"
            l.timelineEmptyMessage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ).copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
//------------------------------------------------------------------------
// // lib/features/home/presentation/widgets/daily_timeline_widget.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 4 | Part 1 | File 2 (l10n added to existing DS)
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// // ✅ Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/home/domain/entities/daily_item.dart';
// import 'package:athar/features/home/presentation/cubit/timeline_cubit.dart';
// import 'package:athar/features/health/data/models/medicine_model.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';

// class DailyTimelineWidget extends StatelessWidget {
//   final String? moduleId;

//   const DailyTimelineWidget({super.key, this.moduleId});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     // ✅ NEW: l10n
//     final l10n = AppLocalizations.of(context);

//     return BlocProvider(
//       create: (context) {
//         final cubit = getIt<TimelineCubit>();
//         if (moduleId != null) {
//           cubit.loadDailyTimeline(moduleId!);
//         } else {
//           cubit.loadGlobalTimeline();
//         }
//         return cubit;
//       },
//       child: BlocBuilder<TimelineCubit, TimelineState>(
//         builder: (context, state) {
//           if (state is TimelineLoading) {
//             return Center(
//               child: CircularProgressIndicator(color: colors.primary),
//             );
//           } else if (state is TimelineLoaded) {
//             if (state.items.isEmpty) {
//               return _buildEmptyState(colors, l10n);
//             }
//             return ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: state.items.length,
//               separatorBuilder: (c, i) => AtharGap.md,
//               itemBuilder: (context, index) {
//                 return _buildItemCard(
//                   context,
//                   colors,
//                   l10n,
//                   state.items[index],
//                 );
//               },
//             );
//           } else if (state is TimelineError) {
//             return Center(
//               child: Text(
//                 state.message,
//                 style: AtharTypography.bodyMedium.copyWith(color: colors.error),
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   Widget _buildItemCard(
//     BuildContext context,
//     AtharColors colors,
//     AppLocalizations l,
//     DailyItem item,
//   ) {
//     Color color;

//     switch (item.type) {
//       case DailyItemType.task:
//         color = colors.info;
//         break;
//       case DailyItemType.medicine:
//         color = colors.error;
//         break;
//       case DailyItemType.appointment:
//         color = colors.secondary;
//         break;
//     }

//     String timeText = DateFormat('hh:mm a').format(item.time);

//     return Container(
//       padding: AtharSpacing.allMd,
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: AtharRadii.radiusLg,
//         border: Border(
//           right: BorderSide(color: color, width: 4.w),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: colors.shadow.withValues(alpha: 0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // الوقت
//           Column(
//             children: [
//               Text(
//                 timeText.split(' ')[0],
//                 style: AtharTypography.labelLarge.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colors.textPrimary,
//                 ),
//               ),
//               Text(
//                 timeText.split(' ')[1],
//                 style: AtharTypography.labelSmall.copyWith(
//                   color: colors.textTertiary,
//                 ),
//               ),
//             ],
//           ),
//           AtharGap.hMd,
//           Container(width: 1.w, height: 30.h, color: colors.borderLight),
//           AtharGap.hMd,

//           // المحتوى
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.title,
//                   style: AtharTypography.titleSmall.copyWith(
//                     color: colors.textPrimary,
//                   ),
//                 ),
//                 if (item.subtitle != null && item.subtitle!.isNotEmpty)
//                   Text(
//                     item.subtitle!,
//                     style: AtharTypography.bodySmall.copyWith(
//                       color: colors.textSecondary,
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // زر الإجراء
//           IconButton(
//             icon: Icon(
//               item.type == DailyItemType.task
//                   ? Icons.circle_outlined
//                   : Icons.check_circle_outline,
//               color: color,
//             ),
//             onPressed: () => _handleAction(context, item, l),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleAction(BuildContext context, DailyItem item, AppLocalizations l) {
//     if (item.type == DailyItemType.medicine) {
//       final medicine = item.originalData as MedicineModel;
//       getIt<HealthCubit>().takeDose(medicine.moduleId, medicine);
//       ScaffoldMessenger.of(context).showSnackBar(
//         // ✅ l10n: "تم تسجيل الجرعة ✅"
//         SnackBar(content: Text(l.timelineDoseTakenSuccess)),
//       );
//     } else if (item.type == DailyItemType.task) {
//       final task = item.originalData as TaskModel;
//       getIt<TaskCubit>().toggleTaskCompletion(task);
//       ScaffoldMessenger.of(context).showSnackBar(
//         // ✅ l10n: "تم إنجاز المهمة 💪"
//         SnackBar(content: Text(l.timelineTaskCompletedSuccess)),
//       );
//     }
//   }

//   Widget _buildEmptyState(AtharColors colors, AppLocalizations l) {
//     return Container(
//       padding: EdgeInsets.all(AtharSpacing.xl),
//       alignment: Alignment.center,
//       child: Column(
//         children: [
//           Icon(
//             Icons.spa,
//             size: 40.sp,
//             color: colors.success.withValues(alpha: 0.5),
//           ),
//           AtharGap.sm,
//           Text(
//             // ✅ l10n: "يومك صافٍ! لا توجد مهام أو أدوية حالياً 🌿"
//             l.timelineEmptyMessage,
//             style: AtharTypography.bodyMedium.copyWith(
//               color: colors.textTertiary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//------------------------------------------------------------------------

// lib/features/home/presentation/widgets/daily_timeline_widget.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.7
// ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/home/domain/entities/daily_item.dart';
// import 'package:athar/features/home/presentation/cubit/timeline_cubit.dart';
// import 'package:athar/features/health/data/models/medicine_model.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';

// class DailyTimelineWidget extends StatelessWidget {
//   final String? moduleId;

//   const DailyTimelineWidget({super.key, this.moduleId});

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;

//     return BlocProvider(
//       create: (context) {
//         final cubit = getIt<TimelineCubit>();
//         if (moduleId != null) {
//           cubit.loadDailyTimeline(moduleId!);
//         } else {
//           cubit.loadGlobalTimeline();
//         }
//         return cubit;
//       },
//       child: BlocBuilder<TimelineCubit, TimelineState>(
//         builder: (context, state) {
//           if (state is TimelineLoading) {
//             return Center(
//               child: CircularProgressIndicator(color: colors.primary),
//             );
//           } else if (state is TimelineLoaded) {
//             if (state.items.isEmpty) {
//               return _buildEmptyState(colors);
//             }
//             return ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: state.items.length,
//               // ✅ SizedBox(height: 12.h) → AtharGap.md
//               separatorBuilder: (c, i) => AtharGap.md,
//               itemBuilder: (context, index) {
//                 return _buildItemCard(context, colors, state.items[index]);
//               },
//             );
//           } else if (state is TimelineError) {
//             return Center(
//               child: Text(
//                 state.message,
//                 // ✅ Colors.red → colors.error
//                 style: AtharTypography.bodyMedium.copyWith(color: colors.error),
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   Widget _buildItemCard(
//     BuildContext context,
//     AtharColors colors,
//     DailyItem item,
//   ) {
//     Color color;

//     // ✅ تحديد اللون من الثيم
//     switch (item.type) {
//       case DailyItemType.task:
//         // ✅ Colors.blue → colors.info
//         color = colors.info;
//         break;
//       case DailyItemType.medicine:
//         // ✅ Colors.red → colors.error
//         color = colors.error;
//         break;
//       case DailyItemType.appointment:
//         // ✅ Colors.purple → colors.secondary
//         color = colors.secondary;
//         break;
//     }

//     String timeText = DateFormat('hh:mm a').format(item.time);

//     return Container(
//       // ✅ EdgeInsets.all(12.w) → AtharSpacing.allMd
//       padding: AtharSpacing.allMd,
//       decoration: BoxDecoration(
//         // ✅ Colors.white → colors.surface
//         color: colors.surface,
//         // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
//         borderRadius: AtharRadii.radiusLg,
//         border: Border(
//           right: BorderSide(color: color, width: 4.w),
//         ),
//         boxShadow: [
//           BoxShadow(
//             // ✅ Colors.black.withOpacity(0.03) → colors.shadow
//             color: colors.shadow.withValues(alpha: 0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // الوقت
//           Column(
//             children: [
//               Text(
//                 timeText.split(' ')[0],
//                 // ✅ AtharTypography
//                 style: AtharTypography.labelLarge.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: colors.textPrimary,
//                 ),
//               ),
//               Text(
//                 timeText.split(' ')[1],
//                 // ✅ AtharTypography
//                 style: AtharTypography.labelSmall.copyWith(
//                   // ✅ Colors.grey → colors.textTertiary
//                   color: colors.textTertiary,
//                 ),
//               ),
//             ],
//           ),
//           // ✅ SizedBox(width: 12.w) → AtharGap.hMd
//           AtharGap.hMd,
//           Container(
//             width: 1.w,
//             height: 30.h,
//             // ✅ Colors.grey.shade200 → colors.borderLight
//             color: colors.borderLight,
//           ),
//           AtharGap.hMd,

//           // المحتوى
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.title,
//                   // ✅ AtharTypography
//                   style: AtharTypography.titleSmall.copyWith(
//                     color: colors.textPrimary,
//                   ),
//                 ),
//                 if (item.subtitle != null && item.subtitle!.isNotEmpty)
//                   Text(
//                     item.subtitle!,
//                     // ✅ AtharTypography
//                     style: AtharTypography.bodySmall.copyWith(
//                       // ✅ Colors.grey.shade600 → colors.textSecondary
//                       color: colors.textSecondary,
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // زر الإجراء
//           IconButton(
//             icon: Icon(
//               item.type == DailyItemType.task
//                   ? Icons.circle_outlined
//                   : Icons.check_circle_outline,
//               color: color,
//             ),
//             onPressed: () => _handleAction(context, item),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleAction(BuildContext context, DailyItem item) {
//     if (item.type == DailyItemType.medicine) {
//       final medicine = item.originalData as MedicineModel;
//       getIt<HealthCubit>().takeDose(medicine.moduleId, medicine);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("تم تسجيل الجرعة ✅")));
//     } else if (item.type == DailyItemType.task) {
//       final task = item.originalData as TaskModel;
//       getIt<TaskCubit>().toggleTaskCompletion(task);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("تم إنجاز المهمة 💪")));
//     }
//   }

//   Widget _buildEmptyState(AtharColors colors) {
//     return Container(
//       padding: EdgeInsets.all(AtharSpacing.xl),
//       alignment: Alignment.center,
//       child: Column(
//         children: [
//           Icon(
//             Icons.spa,
//             size: 40.sp,
//             // ✅ Colors.green.shade200 → colors.success
//             color: colors.success.withValues(alpha: 0.5),
//           ),
//           // ✅ SizedBox(height: 8.h) → AtharGap.sm
//           AtharGap.sm,
//           Text(
//             "يومك صافٍ! لا توجد مهام أو أدوية حالياً 🌿",
//             // ✅ AtharTypography
//             style: AtharTypography.bodyMedium.copyWith(
//               // ✅ Colors.grey → colors.textTertiary
//               color: colors.textTertiary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//------------------------------------------------------------------------

// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/home/domain/entities/daily_item.dart';
// import 'package:athar/features/home/presentation/cubit/timeline_cubit.dart';
// import 'package:athar/features/health/data/models/medicine_model.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class DailyTimelineWidget extends StatelessWidget {
//   final String? moduleId; // ✅ أصبح اختيارياً

//   const DailyTimelineWidget({super.key, this.moduleId});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) {
//         final cubit = getIt<TimelineCubit>();
//         // ✅ تحديد وضع التشغيل (عام أو خاص)
//         if (moduleId != null) {
//           cubit.loadDailyTimeline(moduleId!);
//         } else {
//           cubit.loadGlobalTimeline();
//         }
//         return cubit;
//       },
//       child: BlocBuilder<TimelineCubit, TimelineState>(
//         builder: (context, state) {
//           if (state is TimelineLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is TimelineLoaded) {
//             if (state.items.isEmpty) {
//               return _buildEmptyState();
//             }
//             return ListView.separated(
//               shrinkWrap: true, // مهم داخل SingleChildScrollView
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: state.items.length,
//               separatorBuilder: (c, i) => SizedBox(height: 12.h),
//               itemBuilder: (context, index) {
//                 return _buildItemCard(context, state.items[index]);
//               },
//             );
//           } else if (state is TimelineError) {
//             return Center(
//               child: Text(
//                 state.message,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   Widget _buildItemCard(BuildContext context, DailyItem item) {
//     Color color;

//     // ✅ تحديد اللون مباشرة هنا
//     switch (item.type) {
//       case DailyItemType.task:
//         color = Colors.blue;
//         break;
//       case DailyItemType.medicine:
//         color = Colors.red;
//         break;
//       case DailyItemType.appointment:
//         color = Colors.purple;
//         break;
//     }

//     String timeText = DateFormat('hh:mm a').format(item.time);

//     return Container(
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border(
//           right: BorderSide(color: color, width: 4.w),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // الوقت
//           Column(
//             children: [
//               Text(
//                 timeText.split(' ')[0],
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//               ),
//               Text(
//                 timeText.split(' ')[1],
//                 style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//               ),
//             ],
//           ),
//           SizedBox(width: 12.w),
//           Container(width: 1.w, height: 30.h, color: Colors.grey.shade200),
//           SizedBox(width: 12.w),

//           // المحتوى
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14.sp,
//                     fontFamily: 'Tajawal',
//                   ),
//                 ),
//                 if (item.subtitle != null && item.subtitle!.isNotEmpty)
//                   Text(
//                     item.subtitle!,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.grey.shade600,
//                       fontFamily: 'Tajawal',
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           // زر الإجراء
//           IconButton(
//             icon: Icon(
//               item.type == DailyItemType.task
//                   ? Icons.circle_outlined
//                   : Icons.check_circle_outline,
//               color: color,
//             ),
//             onPressed: () {
//               _handleAction(context, item);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleAction(BuildContext context, DailyItem item) {
//     if (item.type == DailyItemType.medicine) {
//       // نحتاج moduleId هنا، إذا كان null (وضع عام) قد لا نستطيع التسجيل
//       // أو نمرر moduleId محفوظ في MedicineModel نفسه (وهو موجود)
//       final medicine = item.originalData as MedicineModel;

//       getIt<HealthCubit>().takeDose(
//         medicine.moduleId, // ✅ نستخدم الـ moduleId من الدواء نفسه
//         medicine,
//       );
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("تم تسجيل الجرعة ✅")));
//     } else if (item.type == DailyItemType.task) {
//       final task = item.originalData as TaskModel;
//       getIt<TaskCubit>().toggleTaskCompletion(task);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("تم إنجاز المهمة 💪")));
//     }
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       padding: EdgeInsets.all(20.h),
//       alignment: Alignment.center,
//       child: Column(
//         children: [
//           Icon(Icons.spa, size: 40.sp, color: Colors.green.shade200),
//           SizedBox(height: 8.h),
//           Text(
//             "يومك صافٍ! لا توجد مهام أو أدوية حالياً 🌿",
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 14.sp,
//               fontFamily: 'Tajawal',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
