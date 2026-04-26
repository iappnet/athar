// lib/features/space/presentation/pages/space_list_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 📦 صفحة قائمة المساحات - مع SampleDataBanner و Adaptive UI
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/core/design_system/widgets/sample_data_banner.dart';
import 'package:athar/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/utils/responsive_helper.dart';
import 'package:athar/features/notifications/presentation/widgets/notification_center_button.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

import '../cubit/space_cubit.dart';
import '../cubit/space_state.dart';
import '../../data/models/space_model.dart';
import 'space_page.dart';
import 'inbox_page.dart';

class SpaceListPage extends StatefulWidget {
  const SpaceListPage({super.key});

  @override
  State<SpaceListPage> createState() => _SpaceListPageState();
}

class _SpaceListPageState extends State<SpaceListPage> {
  bool _showSampleBanner = true;

  @override
  void initState() {
    super.initState();
    // تحميل المساحات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpaceCubit>().loadSpaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.spaceListTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        centerTitle: true,
        foregroundColor: colorScheme.onSurface,
        actions: [
          const NotificationCenterButton(),
          // ✅ زر صندوق الدعوات
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSpaceDialog(context, l10n, colorScheme),
        label: Text(l10n.spaceListNewSpace),
        icon: const Icon(Icons.add_location_alt_rounded),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          // ✅ Adaptive UI - تحديد العرض الأقصى للتابلت
          constraints: BoxConstraints(
            maxWidth: isTablet
                ? ResponsiveHelper.maxContentWidth
                : double.infinity,
          ),
          child: BlocConsumer<SpaceCubit, SpaceState>(
            listenWhen: (_, curr) => curr is SpaceError,
            listener: (context, state) {
              if (state is SpaceError &&
                  state.message == 'spaces_pro_required') {
                context
                    .read<SubscriptionCubit>()
                    .presentSpacesPaywall(context);
              }
            },
            builder: (context, state) {
              if (state is SpaceLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SpaceError &&
                  state.message != 'spaces_pro_required') {
                return Center(child: Text(state.message));
              } else if (state is SpaceLoaded) {
                final spaces = state.spaces;

                return CustomScrollView(
                  slivers: [
                    // ✅ بانر البيانات التجريبية
                    if (_showSampleBanner)
                      SliverToBoxAdapter(
                        child: SampleDataBannerChecker(
                          onDismissed: () {
                            setState(() => _showSampleBanner = false);
                          },
                          onKept: () {
                            setState(() => _showSampleBanner = false);
                          },
                        ),
                      ),

                    // المحتوى
                    if (spaces.isEmpty)
                      SliverFillRemaining(
                        child: _buildEmptyState(colorScheme, l10n),
                      )
                    else
                      SliverPadding(
                        padding: AtharSpacing.allLg,
                        sliver: isTablet
                            ? _buildGridView(spaces, state, colorScheme, l10n)
                            : _buildListView(spaces, state, colorScheme, l10n),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Grid View للتابلت
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildGridView(
    List<SpaceModel> spaces,
    SpaceLoaded state,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 3.0, // ✅ نسبة أكبر = بطاقات أوسع
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final space = spaces[index];
        final isSelected = state.selectedSpace?.uuid == space.uuid;
        return _buildSpaceCard(context, space, isSelected, colorScheme, l10n);
      }, childCount: spaces.length),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // List View للهاتف
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildListView(
    List<SpaceModel> spaces,
    SpaceLoaded state,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return SliverList.separated(
      itemCount: spaces.length,
      separatorBuilder: (context, index) => AtharGap.md,
      itemBuilder: (context, index) {
        final space = spaces[index];
        final isSelected = state.selectedSpace?.uuid == space.uuid;
        return _buildSpaceCard(context, space, isSelected, colorScheme, l10n);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // بطاقة المساحة
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSpaceCard(
    BuildContext context,
    SpaceModel space,
    bool isSelected,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final isPersonal = space.type == 'personal';
    // ✅ استخدام isSampleData بدلاً من التحقق من ownerId
    final isSampleData = space.isSampleData || space.ownerId == 'guest';

    return InkWell(
      onTap: () {
        context.read<SpaceCubit>().switchSpace(space);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SpacePage(space: space)),
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
            // ✅ أيقونة المساحة (نفس الكود القديم)
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isPersonal
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPersonal ? Icons.person_rounded : Icons.groups_rounded,
                color: isPersonal ? Colors.blue : Colors.purple,
                size: 22.sp,
              ),
            ),
            AtharGap.hMd,

            // معلومات المساحة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          space.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // ✅ علامة البيانات التجريبية
                      if (isSampleData)
                        Container(
                          margin: EdgeInsets.only(right: 6.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: AtharRadii.radiusXxs,
                          ),
                          child: Text(
                            'تجريبي',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // زر الحذف
            // IconButton(
            //   icon: Icon(
            //     Icons.delete_outline_rounded,
            //     color: colorScheme.error.withValues(alpha: 0.6),
            //     size: 22.sp,
            //   ),
            //   onPressed: () => _showDeleteDialog(context, space),
            // ),
            // ✅ زر الحذف (بحجم أصغر)
            SizedBox(
              width: 36.w, // ✅ حجم ثابت
              height: 36.w,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.error.withValues(alpha: 0.6),
                  size: 20.sp, // ✅ أصغر
                ),
                onPressed: () => _showDeleteDialog(context, space),
              ),
            ),

            // علامة الاختيار
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // حالة الفراغ
  // ═══════════════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════════════
  // حوار إنشاء مساحة جديدة
  // ═══════════════════════════════════════════════════════════════════════════

  void _showCreateSpaceDialog(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final controller = TextEditingController();
    bool isShared = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(
            l10n.spaceListCreateTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
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
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.spaceListCancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<SpaceCubit>().createSpace(
                    controller.text,
                    isShared: isShared,
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(l10n.spaceListCreate),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // حوار الحذف
  // ═══════════════════════════════════════════════════════════════════════════

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

}

//----------------------------------------------------------------------
// import 'package:athar/core/design_system/tokens/athar_radii.dart';
// import 'package:athar/core/design_system/tokens/athar_spacing.dart';
// import 'package:athar/features/space/presentation/cubit/space_state.dart';
// import 'package:athar/features/space/presentation/pages/space_page.dart';
// import 'package:athar/features/space/presentation/pages/inbox_page.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../cubit/space_cubit.dart';
// import '../../data/models/space_model.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
// import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
// import 'package:athar/features/auth/presentation/pages/auth_page.dart';

// class SpaceListPage extends StatelessWidget {
//   const SpaceListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final l10n = AppLocalizations.of(context);

//     // تحميل المساحات عند فتح الصفحة
//     context.read<SpaceCubit>().loadSpaces();

//     return Scaffold(
//       backgroundColor: colorScheme.surface,
//       appBar: AppBar(
//         title: Text(
//           l10n.spaceListTitle,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         foregroundColor: colorScheme.onSurface,
//         actions: [
//           // ✅ إضافة زر صندوق الدعوات هنا
//           IconButton(
//             icon: const Icon(Icons.mark_email_unread_outlined),
//             tooltip: l10n.spaceListInboxTooltip,
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const InboxPage()),
//               );
//             },
//           ),
//           AtharGap.hSm,
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
//               return _buildEmptyState(colorScheme, l10n);
//             }

//             return ListView.separated(
//               padding: AtharSpacing.allLg,
//               itemCount: spaces.length,
//               separatorBuilder: (c, i) => AtharGap.md,
//               itemBuilder: (context, index) {
//                 final space = spaces[index];
//                 final isSelected = state.selectedSpace?.uuid == space.uuid;

//                 return _buildSpaceCard(
//                   context,
//                   space,
//                   isSelected,
//                   colorScheme,
//                   l10n,
//                 );
//               },
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showCreateSpaceDialog(context),
//         label: Text(l10n.spaceListNewSpace),
//         icon: const Icon(Icons.add_location_alt_rounded),
//         backgroundColor: colorScheme.primary,
//         foregroundColor: colorScheme.onPrimary,
//       ),
//     );
//   }

//   Widget _buildSpaceCard(
//     BuildContext context,
//     SpaceModel space,
//     bool isSelected,
//     ColorScheme colorScheme,
//     AppLocalizations l10n,
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
//       borderRadius: AtharRadii.cardLarge,
//       child: Container(
//         padding: AtharSpacing.allLg,
//         decoration: BoxDecoration(
//           color: colorScheme.surface,
//           borderRadius: AtharRadii.cardLarge,
//           border: isSelected
//               ? Border.all(color: colorScheme.primary, width: 2)
//               : Border.all(color: colorScheme.outlineVariant),
//           boxShadow: [
//             BoxShadow(
//               color: colorScheme.shadow.withValues(alpha: 0.03),
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
//                     ? Colors.blue.withValues(alpha: 0.1)
//                     : Colors.purple.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isPersonal ? Icons.person_rounded : Icons.groups_rounded,
//                 color: isPersonal ? Colors.blue : Colors.purple,
//                 size: 24.sp,
//               ),
//             ),
//             AtharGap.hLg,
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     space.name,
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   AtharGap.xxs,
//                   Text(
//                     isPersonal
//                         ? l10n.spaceListPersonalSpace
//                         : l10n.spaceListSharedSpace,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: colorScheme.outline,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.delete_outline_rounded,
//                 color: colorScheme.error.withValues(alpha: 0.6),
//                 size: 22.sp,
//               ),
//               onPressed: () => _showDeleteDialog(context, space),
//             ),
//             if (isSelected)
//               Icon(
//                 Icons.check_circle_rounded,
//                 color: colorScheme.primary,
//                 size: 24.sp,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDeleteDialog(BuildContext context, SpaceModel space) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final l10n = AppLocalizations.of(context);

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(l10n.spaceListDeleteTitle),
//         content: Text(l10n.spaceListDeleteMessage(space.name)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text(l10n.spaceListCancel),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: colorScheme.error,
//               foregroundColor: colorScheme.onError,
//             ),
//             onPressed: () {
//               Navigator.pop(ctx);
//               context.read<SpaceCubit>().deleteSpace(space.uuid);
//             },
//             child: Text(l10n.spaceListDelete),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.rocket_launch_rounded,
//             size: 60.sp,
//             color: colorScheme.outlineVariant,
//           ),
//           AtharGap.lg,
//           Text(
//             l10n.spaceListEmptyTitle,
//             style: TextStyle(color: colorScheme.outline),
//           ),
//         ],
//       ),
//     );
//   }

//   // void _showCreateSpaceDialog(BuildContext context) {
//   //   final colorScheme = Theme.of(context).colorScheme;
//   //   final l10n = AppLocalizations.of(context);
//   //   final controller = TextEditingController();
//   //   bool isShared = false;

//   //   showDialog(
//   //     context: context,
//   //     builder: (ctx) => StatefulBuilder(
//   //       builder: (context, setState) {
//   //         return AlertDialog(
//   //           title: Text(l10n.spaceListCreateTitle),
//   //           content: Column(
//   //             mainAxisSize: MainAxisSize.min,
//   //             children: [
//   //               TextField(
//   //                 controller: controller,
//   //                 decoration: InputDecoration(
//   //                   labelText: l10n.spaceListNameLabel,
//   //                   border: const OutlineInputBorder(),
//   //                 ),
//   //               ),
//   //               AtharGap.lg,
//   //               SwitchListTile(
//   //                 title: Text(l10n.spaceListSharedQuestion),
//   //                 subtitle: Text(
//   //                   isShared
//   //                       ? l10n.spaceListSharedSubtitle
//   //                       : l10n.spaceListPrivateSubtitle,
//   //                   style: TextStyle(fontSize: 12.sp),
//   //                 ),
//   //                 value: isShared,
//   //                 onChanged: (val) => setState(() => isShared = val),
//   //                 activeThumbColor: colorScheme.primary,
//   //               ),
//   //             ],
//   //           ),
//   //           actions: [
//   //             TextButton(
//   //               onPressed: () => Navigator.pop(context),
//   //               child: Text(l10n.spaceListCancel),
//   //             ),
//   //             ElevatedButton(
//   //               onPressed: () {
//   //                 if (controller.text.isNotEmpty) {
//   //                   context.read<SpaceCubit>().createSpace(
//   //                     controller.text,
//   //                     isShared: isShared,
//   //                   );
//   //                   Navigator.pop(context);
//   //                 }
//   //               },
//   //               style: ElevatedButton.styleFrom(
//   //                 backgroundColor: colorScheme.primary,
//   //                 foregroundColor: colorScheme.onPrimary,
//   //               ),
//   //               child: Text(l10n.spaceListCreate),
//   //             ),
//   //           ],
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }

//   /// ✅ الدالة المصححة مع التحقق من تسجيل الدخول
//   void _showCreateSpaceDialog(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final l10n = AppLocalizations.of(context);
//     final controller = TextEditingController();
//     bool isShared = false;

//     // ✅ التحقق من حالة المستخدم
//     final authState = context.read<AuthCubit>().state;
//     final bool isAuthenticated = authState is AuthAuthenticated;

//     showDialog(
//       context: context,
//       builder: (ctx) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Text(l10n.spaceListCreateTitle),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: controller,
//                   decoration: InputDecoration(
//                     labelText: l10n.spaceListNameLabel,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 AtharGap.lg,

//                 // ═══════════════════════════════════════════════════════════════
//                 // ✅ Switch مع التحقق من تسجيل الدخول
//                 // ═══════════════════════════════════════════════════════════════
//                 if (isAuthenticated)
//                   // ✅ المستخدم مسجل → إظهار switch عادي
//                   SwitchListTile(
//                     title: Text(l10n.spaceListSharedQuestion),
//                     subtitle: Text(
//                       isShared
//                           ? l10n.spaceListSharedSubtitle
//                           : l10n.spaceListPrivateSubtitle,
//                       style: TextStyle(fontSize: 12.sp),
//                     ),
//                     value: isShared,
//                     onChanged: (val) => setState(() => isShared = val),
//                     activeThumbColor: colorScheme.primary,
//                   )
//                 else
//                   // ✅ المستخدم guest → إظهار switch معطل مع رسالة
//                   InkWell(
//                     onTap: () {
//                       // إغلاق الـ dialog
//                       Navigator.pop(context);
//                       // فتح صفحة تسجيل الدخول
//                       _showLoginRequiredDialog(context, l10n);
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(12.w),
//                       decoration: BoxDecoration(
//                         color: colorScheme.surfaceContainerHighest.withValues(alpha: 
//                           0.5,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: colorScheme.outlineVariant),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.group_off, color: colorScheme.outline),
//                           SizedBox(width: 12.w),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   l10n.spaceListSharedQuestion,
//                                   style: TextStyle(
//                                     color: colorScheme.outline,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 Text(
//                                   'سجل دخولك لإنشاء مساحات مشتركة',
//                                   style: TextStyle(
//                                     fontSize: 12.sp,
//                                     color: colorScheme.outline.withValues(alpha: 0.7),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             size: 16,
//                             color: colorScheme.outline,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(l10n.spaceListCancel),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (controller.text.isNotEmpty) {
//                     // ✅ التحقق مرة أخرى قبل الإنشاء
//                     if (isShared && !isAuthenticated) {
//                       Navigator.pop(context);
//                       _showLoginRequiredDialog(context, l10n);
//                       return;
//                     }

//                     context.read<SpaceCubit>().createSpace(
//                       controller.text,
//                       isShared: isShared,
//                     );
//                     Navigator.pop(context);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: colorScheme.primary,
//                   foregroundColor: colorScheme.onPrimary,
//                 ),
//                 child: Text(l10n.spaceListCreate),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   /// ✅ Dialog طلب تسجيل الدخول
//   void _showLoginRequiredDialog(BuildContext context, AppLocalizations l10n) {
//     final colorScheme = Theme.of(context).colorScheme;

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         icon: Icon(Icons.lock_outline, size: 48, color: colorScheme.primary),
//         title: const Text('تسجيل الدخول مطلوب'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'لإنشاء مساحات مشتركة ودعوة الآخرين، تحتاج لتسجيل الدخول أولاً.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: colorScheme.onSurfaceVariant),
//             ),
//             SizedBox(height: 16.h),
//             // ✅ مزايا تسجيل الدخول
//             _buildFeatureItem(
//               colorScheme,
//               Icons.group_add,
//               'إنشاء مساحات مشتركة',
//             ),
//             _buildFeatureItem(
//               colorScheme,
//               Icons.person_add,
//               'دعوة أفراد العائلة والفريق',
//             ),
//             _buildFeatureItem(
//               colorScheme,
//               Icons.cloud_sync,
//               'مزامنة بياناتك عبر الأجهزة',
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('لاحقاً'),
//           ),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pop(ctx);
//               // التنقل لصفحة تسجيل الدخول
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AuthPage()),
//               );
//             },
//             icon: const Icon(Icons.login),
//             label: const Text('تسجيل الدخول'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: colorScheme.primary,
//               foregroundColor: colorScheme.onPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeatureItem(
//     ColorScheme colorScheme,
//     IconData icon,
//     String text,
//   ) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: colorScheme.primary),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 13.sp, color: colorScheme.onSurface),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
//               color: Colors.black.withValues(alpha: 0.03),
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
//                     ? Colors.blue.withValues(alpha: 0.1)
//                     : Colors.purple.withValues(alpha: 0.1),
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
//                 color: Colors.red.withValues(alpha: 0.6),
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
