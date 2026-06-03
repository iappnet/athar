import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/space/data/models/space_member_model.dart';
import 'package:athar/features/space/presentation/cubit/space_members_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
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
        body: BlocConsumer<SpaceMembersCubit, SpaceMembersState>(
          listener: (context, state) {
            if (state is SpaceMembersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is SpaceMembersInviteSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إرسال الدعوة إلى ${state.userName}'),
                  backgroundColor: context.colors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<SpaceMembersCubit>();
            final members = state is SpaceMembersLoaded
                ? state.members
                : cubit.lastMembers;
            final isAdmin = state is SpaceMembersLoaded
                ? state.isAdmin
                : cubit.lastIsAdmin;

            if (state is SpaceMembersLoading && members.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SpaceMembersError && members.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    AtharGap.md,
                    ElevatedButton(
                      onPressed: () => context
                          .read<SpaceMembersCubit>()
                          .loadMembers(spaceId),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            final bool isFull = members.length >= 15;
            return Column(
              children: [
                _buildHeader(
                  context,
                  colorScheme,
                  l10n,
                  members.length,
                  isFull,
                  isAdmin,
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
                      isAdmin,
                    ),
                  ),
                ),
              ],
            );
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
          : _buildRoleBadge(context, colorScheme, l10n, isOwner, member.role),
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
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    bool isOwner,
    String role,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isOwner
            ? context.colors.accentOrange.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: AtharRadii.card,
      ),
      child: Text(
        _getRoleName(l10n, role),
        style: TextStyle(
          fontSize: 11.sp,
          color: isOwner ? context.colors.accentOrange : colorScheme.onSurfaceVariant,
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
            padding: EdgeInsetsDirectional.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              start: 20,
              end: 20,
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
                          final query = state.query.trim();
                          final isEmailQuery = _isEmail(query);

                          if (state.results.isEmpty) {
                            return _buildSearchFallback(
                              parentContext,
                              l10n,
                              cubit,
                              query,
                              isEmailQuery,
                            );
                          }

                          return ListView.builder(
                            itemCount: state.results.length,
                            itemBuilder: (context, index) {
                              final user = state.results[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child: user.avatarUrl == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(user.fullName),
                                subtitle: Text(
                                  user.email?.isNotEmpty == true
                                      ? '${user.username} • ${user.email}'
                                      : user.username,
                                ),
                                trailing: FilledButton.icon(
                                  icon: const Icon(Icons.person_add_alt_1),
                                  label: Text(l10n.inviteMember),
                                  onPressed: () async {
                                    final success = await cubit.addMember(user);
                                    if (!parentContext.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(
                                      parentContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? l10n.spaceMembersInviteSent
                                              : l10n.errorOccurred(''),
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

  Widget _buildSearchFallback(
    BuildContext parentContext,
    AppLocalizations l10n,
    SpaceMembersCubit cubit,
    String query,
    bool isEmailQuery,
  ) {
    final colorScheme = Theme.of(parentContext).colorScheme;

    if (query.isEmpty) {
      return Center(child: Text(l10n.spaceMembersSearchPrompt));
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 40, color: colorScheme.outline),
            AtharGap.md,
            Text(
              l10n.noResultsFor(query),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
            ),
            AtharGap.sm,
            Text(
              isEmailQuery
                  ? 'No account found. You can still create an invitation for this email.'
                  : 'No registered username found. Best practice is to invite using email, or share a join link.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
            AtharGap.lg,
            if (isEmailQuery)
              FilledButton.icon(
                icon: const Icon(Icons.mark_email_unread_outlined),
                label: Text(l10n.inviteMember),
                onPressed: () async {
                  final success = await cubit.inviteByEmail(query);
                  if (!parentContext.mounted) return;
                  Navigator.pop(parentContext);
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? l10n.spaceMembersInviteSent
                            : l10n.errorOccurred(''),
                      ),
                    ),
                  );
                },
              )
            else
              OutlinedButton.icon(
                icon: const Icon(Icons.link),
                label: Text(l10n.share),
                onPressed: () async {
                  final link = await cubit.createInviteLink();
                  if (!parentContext.mounted || link == null) return;
                  await Clipboard.setData(ClipboardData(text: link));
                  if (!parentContext.mounted) return;
                  Navigator.pop(parentContext);
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('${l10n.copy}: $link')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  bool _isEmail(String value) {
    final trimmed = value.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
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
