import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MemberSelectorSheet extends StatelessWidget {
  final String spaceId;
  final String? currentAssigneeId;

  const MemberSelectorSheet({
    super.key,
    required this.spaceId,
    this.currentAssigneeId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: 400.h,
      padding: AtharSpacing.allXl,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.bottomSheet,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.memberSelectorTitle,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          AtharGap.lg,
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getIt<SpaceRepository>().getSpaceMembers(spaceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(l10n.memberSelectorEmpty));
                }

                final members = snapshot.data!;

                return ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final profile = member['profiles'] ?? {};
                    final userId = member['user_id'];
                    final isSelected = userId == currentAssigneeId;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profile['avatar_url'] != null
                            ? NetworkImage(profile['avatar_url'])
                            : null,
                        child: profile['avatar_url'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        profile['full_name'] ?? l10n.memberSelectorDefaultName,
                      ),
                      subtitle: Text(_getRoleName(l10n, member['role'])),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: context.colors.success)
                          : null,
                      onTap: () {
                        Navigator.pop(context, userId);
                      },
                    );
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.people_outline, color: context.colors.warning),
            title: Text(l10n.memberSelectorUnassign),
            onTap: () => Navigator.pop(context, 'unassign'),
          ),
        ],
      ),
    );
  }

  String _getRoleName(AppLocalizations l10n, String role) {
    switch (role) {
      case 'owner':
        return l10n.spaceMembersRoleOwner;
      case 'admin':
        return l10n.spaceMembersRoleAdmin;
      default:
        return l10n.spaceMembersRoleMember;
    }
  }
}
