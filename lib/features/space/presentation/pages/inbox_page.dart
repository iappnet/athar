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
      child: BlocListener<InboxCubit, InboxState>(
        listener: (context, state) {
          if (state is InboxAcceptSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 انضممت إلى "${state.spaceName}" بنجاح'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is InboxRejectSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم رفض الدعوة'),
                backgroundColor: Colors.grey[700],
              ),
            );
          } else if (state is InboxError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
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
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => context.read<InboxCubit>().loadInvites(),
              ),
            ],
          ),
          body: BlocBuilder<InboxCubit, InboxState>(
            builder: (context, state) {
              if (state is InboxLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is InboxEmpty) {
                return _buildEmptyState(colorScheme, l10n);
              } else if (state is InboxError) {
                return _buildErrorState(colorScheme, state.message, context);
              } else if (state is InboxLoaded) {
                return ListView.builder(
                  padding: AtharSpacing.allXl,
                  itemCount: state.invitations.length,
                  itemBuilder: (context, index) {
                    final invite = state.invitations[index];
                    final spaceName = invite.spaceName?.isNotEmpty == true
                        ? invite.spaceName!
                        : 'مساحة غير معروفة';
                    final inviterName = invite.inviterName?.isNotEmpty == true
                        ? invite.inviterName!
                        : 'مستخدم';
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
                            // Header row: icon + space name + time
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: (invite.spaceColor != null
                                          ? Color(invite.spaceColor!)
                                          : colorScheme.primary)
                                      .withValues(alpha: 0.15),
                                  child: Icon(
                                    Icons.group_rounded,
                                    color: invite.spaceColor != null
                                        ? Color(invite.spaceColor!)
                                        : colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        spaceName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'دعوة من $inviterName',
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 13.sp,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
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
                            SizedBox(height: 12.h),
                            // Invite description
                            Text(
                              'دعاك $inviterName للانضمام إلى مساحة "$spaceName". انقر قبول للبدء بالتعاون.',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13.sp,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Reject button
                                OutlinedButton.icon(
                                  onPressed: () => context
                                      .read<InboxCubit>()
                                      .rejectInvite(invite.token),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: colorScheme.error,
                                  ),
                                  label: Text(
                                    'رفض',
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: colorScheme.error),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AtharRadii.radiusSm,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // Accept button
                                ElevatedButton.icon(
                                  onPressed: () => context
                                      .read<InboxCubit>()
                                      .acceptInvite(invite.token, spaceName),
                                  icon: const Icon(Icons.check_rounded, size: 16),
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
          SizedBox(height: 16.h),
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

  Widget _buildErrorState(
    ColorScheme colorScheme,
    String message,
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60.sp,
            color: colorScheme.error,
          ),
          SizedBox(height: 12.h),
          Text(message, style: TextStyle(color: colorScheme.error)),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: () => context.read<InboxCubit>().loadInvites(),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
