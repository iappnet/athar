import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/space/presentation/cubit/space_state.dart';
import 'package:athar/features/space/presentation/pages/space_page.dart';
import 'package:athar/features/space/presentation/pages/inbox_page.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/space_cubit.dart';
import '../../data/models/space_model.dart';

class SpaceListPage extends StatelessWidget {
  const SpaceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    // تحميل المساحات عند فتح الصفحة
    context.read<SpaceCubit>().loadSpaces();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.spaceListTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: colorScheme.onSurface,
        actions: [
          // ✅ إضافة زر صندوق الدعوات هنا
          IconButton(
            icon: const Icon(Icons.mark_email_unread_outlined),
            tooltip: l10n.spaceListInboxTooltip,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InboxPage()),
              );
            },
          ),
          AtharGap.hSm,
        ],
      ),
      body: BlocBuilder<SpaceCubit, SpaceState>(
        builder: (context, state) {
          if (state is SpaceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SpaceError) {
            return Center(child: Text(state.message));
          } else if (state is SpaceLoaded) {
            final spaces = state.spaces;

            if (spaces.isEmpty) {
              return _buildEmptyState(colorScheme, l10n);
            }

            return ListView.separated(
              padding: AtharSpacing.allLg,
              itemCount: spaces.length,
              separatorBuilder: (c, i) => AtharGap.md,
              itemBuilder: (context, index) {
                final space = spaces[index];
                final isSelected = state.selectedSpace?.uuid == space.uuid;

                return _buildSpaceCard(
                  context,
                  space,
                  isSelected,
                  colorScheme,
                  l10n,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSpaceDialog(context),
        label: Text(l10n.spaceListNewSpace),
        icon: const Icon(Icons.add_location_alt_rounded),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildSpaceCard(
    BuildContext context,
    SpaceModel space,
    bool isSelected,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final isPersonal = space.type == 'personal';

    return InkWell(
      onTap: () {
        context.read<SpaceCubit>().switchSpace(space);
        Navigator.push(
          context,
          MaterialPageRoute(
            // ✅ التوجيه للاسم الجديد SpacePage
            builder: (context) => SpacePage(space: space),
          ),
        );
      },
      onLongPress: () => _showDeleteDialog(context, space),
      borderRadius: AtharRadii.cardLarge,
      child: Container(
        padding: AtharSpacing.allLg,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AtharRadii.cardLarge,
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isPersonal
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPersonal ? Icons.person_rounded : Icons.groups_rounded,
                color: isPersonal ? Colors.blue : Colors.purple,
                size: 24.sp,
              ),
            ),
            AtharGap.hLg,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AtharGap.xxs,
                  Text(
                    isPersonal
                        ? l10n.spaceListPersonalSpace
                        : l10n.spaceListSharedSpace,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.error.withValues(alpha: 0.6),
                size: 22.sp,
              ),
              onPressed: () => _showDeleteDialog(context, space),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SpaceModel space) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.spaceListDeleteTitle),
        content: Text(l10n.spaceListDeleteMessage(space.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.spaceListCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SpaceCubit>().deleteSpace(space.uuid);
            },
            child: Text(l10n.spaceListDelete),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            size: 60.sp,
            color: colorScheme.outlineVariant,
          ),
          AtharGap.lg,
          Text(
            l10n.spaceListEmptyTitle,
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  void _showCreateSpaceDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    bool isShared = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.spaceListCreateTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: l10n.spaceListNameLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                AtharGap.lg,
                SwitchListTile(
                  title: Text(l10n.spaceListSharedQuestion),
                  subtitle: Text(
                    isShared
                        ? l10n.spaceListSharedSubtitle
                        : l10n.spaceListPrivateSubtitle,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  value: isShared,
                  onChanged: (val) => setState(() => isShared = val),
                  activeThumbColor: colorScheme.primary,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.spaceListCancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    context.read<SpaceCubit>().createSpace(
                      controller.text,
                      isShared: isShared,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text(l10n.spaceListCreate),
              ),
            ],
          );
        },
      ),
    );
  }
}
//----------------------------------------------------------------------
// import 'package:athar/features/space/presentation/cubit/space_state.dart';
// import 'package:athar/features/space/presentation/pages/space_page.dart';
// import 'package:athar/features/space/presentation/pages/inbox_page.dart'; // ✅ استيراد صفحة الدعوات
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import '../cubit/space_cubit.dart';
// import '../../data/models/space_model.dart';

// class SpaceListPage extends StatelessWidget {
//   const SpaceListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // تحميل المساحات عند فتح الصفحة
//     context.read<SpaceCubit>().loadSpaces();

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text(
//           "مساحاتي 🪐",
//           style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         foregroundColor: AppColors.textPrimary,
//         actions: [
//           // ✅ إضافة زر صندوق الدعوات هنا
//           IconButton(
//             icon: const Icon(Icons.mark_email_unread_outlined),
//             tooltip: "الدعوات",
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const InboxPage()),
//               );
//             },
//           ),
//           SizedBox(width: 8.w),
//         ],
//       ),
//       body: BlocBuilder<SpaceCubit, SpaceState>(
//         builder: (context, state) {
//           if (state is SpaceLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is SpaceError) {
//             return Center(child: Text(state.message));
//           } else if (state is SpaceLoaded) {
//             final spaces = state.spaces;

//             if (spaces.isEmpty) {
//               return _buildEmptyState();
//             }

//             return ListView.separated(
//               padding: EdgeInsets.all(16.w),
//               itemCount: spaces.length,
//               separatorBuilder: (c, i) => SizedBox(height: 12.h),
//               itemBuilder: (context, index) {
//                 final space = spaces[index];
//                 final isSelected = state.selectedSpace?.uuid == space.uuid;

//                 return _buildSpaceCard(context, space, isSelected);
//               },
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showCreateSpaceDialog(context),
//         label: const Text(
//           "مساحة جديدة",
//           style: TextStyle(fontFamily: 'Tajawal'),
//         ),
//         icon: const Icon(Icons.add_location_alt_rounded),
//         backgroundColor: AppColors.primary,
//       ),
//     );
//   }

//   Widget _buildSpaceCard(
//     BuildContext context,
//     SpaceModel space,
//     bool isSelected,
//   ) {
//     final isPersonal = space.type == 'personal';

//     return InkWell(
//       onTap: () {
//         context.read<SpaceCubit>().switchSpace(space);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             // ✅ التوجيه للاسم الجديد SpacePage
//             builder: (context) => SpacePage(space: space),
//           ),
//         );
//       },
//       onLongPress: () => _showDeleteDialog(context, space),
//       borderRadius: BorderRadius.circular(16.r),
//       child: Container(
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           border: isSelected
//               ? Border.all(color: AppColors.primary, width: 2)
//               : Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: isPersonal
//                     ? Colors.blue.withOpacity(0.1)
//                     : Colors.purple.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isPersonal ? Icons.person_rounded : Icons.groups_rounded,
//                 color: isPersonal ? Colors.blue : Colors.purple,
//                 size: 24.sp,
//               ),
//             ),
//             SizedBox(width: 16.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     space.name,
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Tajawal',
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     isPersonal ? "مساحة خاصة" : "مساحة مشتركة",
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.grey,
//                       fontFamily: 'Tajawal',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.delete_outline_rounded,
//                 color: Colors.red.withOpacity(0.6),
//                 size: 22.sp,
//               ),
//               onPressed: () => _showDeleteDialog(context, space),
//             ),
//             if (isSelected)
//               Icon(
//                 Icons.check_circle_rounded,
//                 color: AppColors.primary,
//                 size: 24.sp,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDeleteDialog(BuildContext context, SpaceModel space) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text(
//           "حذف المساحة",
//           style: TextStyle(fontFamily: 'Tajawal'),
//         ),
//         content: Text(
//           "هل أنت متأكد من حذف مساحة '${space.name}'؟\nسيؤدي هذا لحذف جميع المشاريع والمهام بداخلها.",
//           style: const TextStyle(fontFamily: 'Tajawal'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("إلغاء"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(ctx);
//               context.read<SpaceCubit>().deleteSpace(space.uuid);
//             },
//             child: const Text("حذف", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.rocket_launch_rounded,
//             size: 60.sp,
//             color: Colors.grey.shade300,
//           ),
//           SizedBox(height: 16.h),
//           const Text(
//             "لا توجد مساحات بعد",
//             style: TextStyle(fontFamily: 'Tajawal'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCreateSpaceDialog(BuildContext context) {
//     final controller = TextEditingController();
//     bool isShared = false;

//     showDialog(
//       context: context,
//       builder: (ctx) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: const Text(
//               "إنشاء مساحة جديدة",
//               style: TextStyle(fontFamily: 'Tajawal'),
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: controller,
//                   decoration: const InputDecoration(
//                     labelText: "اسم المساحة (البيت، العمل...)",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 SwitchListTile(
//                   title: const Text(
//                     "مساحة مشتركة؟",
//                     style: TextStyle(fontFamily: 'Tajawal'),
//                   ),
//                   subtitle: Text(
//                     isShared ? "سيتمكن الآخرون من الانضمام" : "خاصة بك فقط",
//                     style: TextStyle(fontSize: 12.sp),
//                   ),
//                   value: isShared,
//                   onChanged: (val) => setState(() => isShared = val),
//                   activeColor: AppColors.primary,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("إلغاء"),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (controller.text.isNotEmpty) {
//                     context.read<SpaceCubit>().createSpace(
//                       controller.text,
//                       isShared: isShared,
//                     );
//                     Navigator.pop(context);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                 ),
//                 child: const Text(
//                   "إنشاء",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
//----------------------------------------------------------------------
