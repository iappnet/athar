// lib/features/space/presentation/widgets/pending_invitations_widget.dart

import 'package:athar/features/space/presentation/cubit/space_members_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingInvitationsWidget extends StatelessWidget {
  const PendingInvitationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpaceMembersCubit, SpaceMembersState>(
      builder: (context, state) {
        if (state is SpacePendingInvitationsLoaded &&
            state.invitations.isNotEmpty) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.mail, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'دعوات معلقة (${state.invitations.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                ...state.invitations.map(
                  (invite) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(invite.spaceColor ?? 0xFF6200EE),
                      child: const Icon(Icons.group, color: Colors.white),
                    ),
                    title: Text(invite.spaceName ?? 'مساحة'),
                    subtitle: Text('من: ${invite.inviterName ?? 'مستخدم'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => context
                              .read<SpaceMembersCubit>()
                              .acceptInvite(invite.token),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => context
                              .read<SpaceMembersCubit>()
                              .rejectInvite(invite.token),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
