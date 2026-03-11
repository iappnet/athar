import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/space/data/models/space_member_model.dart';
import 'package:athar/features/space/presentation/cubit/space_members_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/iam/permission_service.dart';

class SpaceMembersPage extends StatelessWidget {
  final String spaceId;
  const SpaceMembersPage({super.key, required this.spaceId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => getIt<SpaceMembersCubit>()..loadMembers(spaceId),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            l10n.spaceMembersTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
        ),
        body: BlocBuilder<SpaceMembersCubit, SpaceMembersState>(
          builder: (context, state) {
            if (state is SpaceMembersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SpaceMembersLoaded) {
              final members = state.members;
              final bool isFull = members.length >= 15;

              return Column(
                children: [
                  _buildHeader(
                    context,
                    colorScheme,
                    l10n,
                    members.length,
                    isFull,
                    state.isAdmin,
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      itemCount: members.length,
                      separatorBuilder: (_, _) => const Divider(indent: 70),
                      itemBuilder: (context, index) => _buildMemberTile(
                        context,
                        colorScheme,
                        l10n,
                        members[index],
                        state.isAdmin,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    int count,
    bool isFull,
    bool isAdmin,
  ) {
    return Container(
      padding: AtharSpacing.allXxl,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.spaceMembersTotalLabel,
                style: TextStyle(color: colorScheme.outline, fontSize: 12.sp),
              ),
              Text(
                "$count / 15",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
            ],
          ),
          if (isAdmin)
            ElevatedButton.icon(
              onPressed: isFull ? null : () => _showSearchSheet(context, l10n),
              icon: const Icon(Icons.person_add_alt_1, size: 20),
              label: Text(l10n.spaceMembersAddButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFull
                    ? colorScheme.outline
                    : colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: AtharRadii.card),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    SpaceMemberModel member,
    bool isAdmin,
  ) {
    final isOwner = member.role == 'owner';
    final currentUserId = getIt<PermissionService>().currentUserId;
    final isMe = member.userId == currentUserId;

    return ListTile(
      leading: CircleAvatar(
        radius: 25.r,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: member.tempAvatarUrl != null
            ? NetworkImage(member.tempAvatarUrl!)
            : null,
        child: member.tempAvatarUrl == null
            ? Icon(Icons.person, color: colorScheme.primary)
            : null,
      ),
      title: Text(
        member.tempDisplayName ?? l10n.spaceMembersDefaultName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(_getRoleName(l10n, member.role)),
      trailing: (isAdmin && !isOwner && !isMe)
          ? _buildRoleDropdown(context, colorScheme, l10n, member)
          : _buildRoleBadge(colorScheme, l10n, isOwner, member.role),
      onTap: isAdmin && !isOwner && !isMe
          ? () => _showManagementOptions(context, colorScheme, l10n, member)
          : null,
    );
  }

  Widget _buildRoleDropdown(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    SpaceMemberModel member,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: AtharRadii.radiusSm,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: member.role,
          items: [
            DropdownMenuItem(
              value: 'member',
              child: Text(
                l10n.spaceMembersRoleMember,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            DropdownMenuItem(
              value: 'admin',
              child: Text(
                l10n.spaceMembersRoleAdmin,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
          onChanged: (newRole) {
            if (newRole != null && newRole != member.role) {
              context.read<SpaceMembersCubit>().changeRole(
                member.userId,
                newRole,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildRoleBadge(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    bool isOwner,
    String role,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isOwner
            ? Colors.orange[50]
            : colorScheme.surfaceContainerHighest,
        borderRadius: AtharRadii.card,
      ),
      child: Text(
        _getRoleName(l10n, role),
        style: TextStyle(
          fontSize: 11.sp,
          color: isOwner ? Colors.orange[800] : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _getRoleName(AppLocalizations l10n, String role) {
    if (role == 'owner') return l10n.spaceMembersRoleOwner;
    if (role == 'admin') return l10n.spaceMembersRoleAdmin;
    return l10n.spaceMembersRoleMember;
  }

  void _showSearchSheet(BuildContext parentContext, AppLocalizations l10n) {
    final cubit = parentContext.read<SpaceMembersCubit>();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SizedBox(
              height: 500.h,
              child: Column(
                children: [
                  Text(
                    l10n.spaceMembersSearchTitle,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AtharGap.sm,
                  TextField(
                    decoration: InputDecoration(
                      hintText: l10n.spaceMembersSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      if (val.length >= 3) {
                        cubit.searchUser(val);
                      }
                    },
                  ),
                  AtharGap.sm,
                  Expanded(
                    child: BlocBuilder<SpaceMembersCubit, SpaceMembersState>(
                      builder: (context, state) {
                        if (state is SpaceMembersSearching) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is SpaceMembersSearchResults) {
                          if (state.results.isEmpty) {
                            return Center(child: Text(l10n.noResults));
                          }

                          return ListView.builder(
                            itemCount: state.results.length,
                            itemBuilder: (context, index) {
                              final user = state.results[index];
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person_add),
                                ),
                                title: Text(user.fullName),
                                subtitle: Text(user.username),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    cubit.inviteUser(user);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(
                                      parentContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.spaceMembersInviteSent,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }
                        return Center(
                          child: Text(l10n.spaceMembersSearchPrompt),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      cubit.cancelSearch();
    });
  }

  void _showManagementOptions(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    SpaceMemberModel member,
  ) {
    final userId = member.userId;
    final currentRole = member.role;
    final cubit = context.read<SpaceMembersCubit>();

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentRole == 'member')
            ListTile(
              leading: Icon(Icons.security, color: colorScheme.primary),
              title: Text(l10n.spaceMembersPromoteAdmin),
              onTap: () {
                Navigator.pop(context);
                _confirmAction(
                  context,
                  l10n,
                  l10n.spaceMembersPromoteAdmin,
                  () {
                    cubit.changeRole(userId, 'admin');
                  },
                );
              },
            )
          else if (currentRole == 'admin')
            ListTile(
              leading: Icon(Icons.person_outline, color: colorScheme.outline),
              title: Text(l10n.spaceMembersDemoteMember),
              onTap: () {
                Navigator.pop(context);
                _confirmAction(
                  context,
                  l10n,
                  l10n.spaceMembersDemoteMember,
                  () {
                    cubit.changeRole(userId, 'member');
                  },
                );
              },
            ),
          ListTile(
            leading: Icon(Icons.delete, color: colorScheme.error),
            title: Text(l10n.spaceMembersKick),
            textColor: colorScheme.error,
            onTap: () {
              Navigator.pop(context);
              _confirmAction(context, l10n, l10n.spaceMembersKick, () {
                cubit.removeMember(userId);
              });
            },
          ),
        ],
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    AppLocalizations l10n,
    String title,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(l10n.spaceMembersConfirmPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }
}
//----------------------------------------------------------------------
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/space/data/models/space_member_model.dart';
// import 'package:athar/features/space/presentation/cubit/space_members_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/iam/permission_service.dart';

// class SpaceMembersPage extends StatelessWidget {
//   final String spaceId;
//   const SpaceMembersPage({super.key, required this.spaceId});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<SpaceMembersCubit>()..loadMembers(spaceId),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text(
//             "أعضاء المساحة",
//             style: TextStyle(
//               fontFamily: 'Tajawal',
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           elevation: 0,
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//         ),
//         body: BlocBuilder<SpaceMembersCubit, SpaceMembersState>(
//           builder: (context, state) {
//             if (state is SpaceMembersLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (state is SpaceMembersLoaded) {
//               final members = state.members;
//               final bool isFull = members.length >= 15;

//               return Column(
//                 children: [
//                   _buildHeader(context, members.length, isFull, state.isAdmin),
//                   Expanded(
//                     child: ListView.separated(
//                       padding: EdgeInsets.symmetric(vertical: 10.h),
//                       itemCount: members.length,
//                       separatorBuilder: (_, _) => const Divider(indent: 70),
//                       itemBuilder: (context, index) => _buildMemberTile(
//                         context,
//                         members[index],
//                         state.isAdmin,
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(
//     BuildContext context,
//     int count,
//     bool isFull,
//     bool isAdmin,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "إجمالي الأعضاء",
//                 style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
//               ),
//               Text(
//                 "$count / 15",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
//               ),
//             ],
//           ),
//           if (isAdmin)
//             ElevatedButton.icon(
//               onPressed: isFull ? null : () => _showSearchSheet(context),
//               icon: const Icon(Icons.person_add_alt_1, size: 20),
//               label: const Text("إضافة عضو"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isFull ? Colors.grey : Colors.blue[700],
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMemberTile(
//     BuildContext context,
//     SpaceMemberModel member,
//     bool isAdmin,
//   ) {
//     final isOwner = member.role == 'owner';

//     // ✅ إصلاح الخطأ: تعريف isMe
//     // نجلب معرف المستخدم الحالي من PermissionService
//     final currentUserId = getIt<PermissionService>().currentUserId;
//     final isMe = member.userId == currentUserId;

//     return ListTile(
//       leading: CircleAvatar(
//         radius: 25.r,
//         backgroundColor: Colors.blue[50],
//         backgroundImage: member.tempAvatarUrl != null
//             ? NetworkImage(member.tempAvatarUrl!)
//             : null,
//         child: member.tempAvatarUrl == null
//             ? const Icon(Icons.person, color: Colors.blue)
//             : null,
//       ),
//       title: Text(
//         member.tempDisplayName ?? 'مستخدم أثر',
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(
//         member.role == 'owner'
//             ? 'مؤسس المساحة'
//             : member.role == 'admin'
//             ? 'مدير'
//             : 'عضو',
//       ),
//       // ✅ تم تحديث trailing لاستخدام isMe المصلح
//       trailing: (isAdmin && !isOwner && !isMe)
//           ? _buildRoleDropdown(context, member)
//           : _buildRoleBadge(isOwner, member.role),
//       onTap: isAdmin && !isOwner && !isMe
//           ? () => _showManagementOptions(context, member)
//           : null,
//     );
//   }

//   // مكوّن الـ Dropdown الجديد
//   Widget _buildRoleDropdown(BuildContext context, SpaceMemberModel member) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8.w),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: member.role,
//           items: const [
//             DropdownMenuItem(
//               value: 'member',
//               child: Text("عضو", style: TextStyle(fontSize: 12)),
//             ),
//             DropdownMenuItem(
//               value: 'admin',
//               child: Text("مدير", style: TextStyle(fontSize: 12)),
//             ),
//           ],
//           onChanged: (newRole) {
//             if (newRole != null && newRole != member.role) {
//               context.read<SpaceMembersCubit>().changeRole(
//                 member.userId,
//                 newRole,
//               );
//               // تنبيه: الكاش سيتم تحديثه تلقائياً في الخطوة القادمة
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildRoleBadge(bool isOwner, String role) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: isOwner ? Colors.orange[50] : Colors.grey[100],
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Text(
//         _getRoleName(role),
//         style: TextStyle(
//           fontSize: 11.sp,
//           color: isOwner ? Colors.orange[800] : Colors.grey[800],
//         ),
//       ),
//     );
//   }

//   String _getRoleName(String role) {
//     if (role == 'owner') return 'المالك';
//     if (role == 'admin') return 'مدير';
//     return 'عضو';
//   }

//   void _showSearchSheet(BuildContext parentContext) {
//     // ✅ حفظ الكيوبت قبل الدخول في async gap
//     final cubit = parentContext.read<SpaceMembersCubit>();

//     showModalBottomSheet(
//       context: parentContext,
//       isScrollControlled: true,
//       builder: (context) {
//         return BlocProvider.value(
//           value: cubit,
//           child: Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//               left: 20,
//               right: 20,
//               top: 20,
//             ),
//             child: SizedBox(
//               height: 500.h,
//               child: Column(
//                 children: [
//                   Text(
//                     "بحث عن أعضاء",
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 10.h),
//                   TextField(
//                     decoration: const InputDecoration(
//                       hintText: "البريد الإلكتروني أو اسم المستخدم",
//                       prefixIcon: Icon(Icons.search),
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (val) {
//                       if (val.length >= 3) {
//                         cubit.searchUser(val);
//                       }
//                     },
//                   ),
//                   SizedBox(height: 10.h),
//                   Expanded(
//                     child: BlocBuilder<SpaceMembersCubit, SpaceMembersState>(
//                       builder: (context, state) {
//                         if (state is SpaceMembersSearching) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         if (state is SpaceMembersSearchResults) {
//                           if (state.results.isEmpty) {
//                             return const Center(child: Text("لا توجد نتائج"));
//                           }

//                           return ListView.builder(
//                             itemCount: state.results.length,
//                             itemBuilder: (context, index) {
//                               final user = state.results[index];
//                               return ListTile(
//                                 leading: const CircleAvatar(
//                                   child: Icon(Icons.person_add),
//                                 ),
//                                 title: Text(user.fullName),
//                                 subtitle: Text(user.username),
//                                 trailing: IconButton(
//                                   icon: const Icon(
//                                     Icons.send,
//                                     color: Colors.blue,
//                                   ),
//                                   onPressed: () {
//                                     cubit.inviteUser(user);
//                                     Navigator.pop(context);
//                                     ScaffoldMessenger.of(
//                                       parentContext,
//                                     ).showSnackBar(
//                                       const SnackBar(
//                                         content: Text("تم إرسال الدعوة"),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               );
//                             },
//                           );
//                         }
//                         return const Center(child: Text("ابحث لإضافة أعضاء"));
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     ).whenComplete(() {
//       // ✅ استخدام المرجع المحفوظ cubit بدلاً من parentContext
//       cubit.cancelSearch();
//     });
//   }

//   void _showManagementOptions(
//     BuildContext context,
//     SpaceMemberModel member, // ✅ التغيير من Map إلى Model
//   ) {
//     final userId = member.userId;
//     final currentRole = member.role;
//     final cubit = context.read<SpaceMembersCubit>();

//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (currentRole == 'member')
//             ListTile(
//               leading: const Icon(Icons.security, color: Colors.blue),
//               title: const Text("ترقية إلى مدير"),
//               onTap: () {
//                 Navigator.pop(context);
//                 _confirmAction(context, "ترقية العضو", () {
//                   cubit.changeRole(userId, 'admin');
//                 });
//               },
//             )
//           else if (currentRole == 'admin')
//             ListTile(
//               leading: const Icon(Icons.person_outline, color: Colors.grey),
//               title: const Text("إلغاء الصلاحية (تخفيض لعضو)"),
//               onTap: () {
//                 Navigator.pop(context);
//                 _confirmAction(context, "إلغاء صلاحية المدير", () {
//                   cubit.changeRole(userId, 'member');
//                 });
//               },
//             ),
//           ListTile(
//             leading: const Icon(Icons.delete, color: Colors.red),
//             title: const Text("طرد من المساحة"),
//             textColor: Colors.red,
//             onTap: () {
//               Navigator.pop(context);
//               _confirmAction(context, "طرد العضو نهائياً", () {
//                 cubit.removeMember(userId);
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _confirmAction(
//     BuildContext context,
//     String title,
//     VoidCallback onConfirm,
//   ) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(title),
//         content: const Text("هل أنت متأكد؟"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("إلغاء"),
//           ),
//           TextButton(
//             onPressed: () {
//               onConfirm();
//               Navigator.pop(ctx);
//             },
//             child: const Text("نعم"),
//           ),
//         ],
//       ),
//     );
//   }
// }
//----------------------------------------------------------------------
