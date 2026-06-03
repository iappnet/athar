import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/athar_feedback.dart';
import 'package:athar/core/design_system/widgets/athar_text_field.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/features/task/data/models/task_note_model.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;


class TaskBoardWidget extends StatefulWidget {
  final String taskId;

  const TaskBoardWidget({super.key, required this.taskId});

  @override
  State<TaskBoardWidget> createState() => _TaskBoardWidgetState();
}

class _TaskBoardWidgetState extends State<TaskBoardWidget> {
  final TextEditingController _noteController = TextEditingController();
  // ✅ التعامل مع الزائر
  final String _myUserId =
      Supabase.instance.client.auth.currentUser?.id ?? 'guest';
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<TaskNoteModel>>(
      stream: context.read<TaskCubit>().watchTaskNotes(widget.taskId),
      builder: (context, snapshot) {
        final notes = snapshot.data ?? [];

        // ✅ التصحيح 1: البحث الآمن
        // بدلاً من orElse التي تعيد موديلاً فارغاً يسبب المشكلة، نستخدم try/catch أو نتركها null
        final myNoteMatches = notes.where((n) => n.userId == _myUserId);
        final TaskNoteModel? myNote =
            myNoteMatches.isEmpty ? null : myNoteMatches.first;

        final otherNotes = notes.where((n) => n.userId != _myUserId).toList();

        // تعبئة النص عند الفتح لأول مرة فقط
        if (_isInit && myNote?.content != null) {
          _noteController.text = myNote!.content!;
          _isInit = false;
        }

        return ListView(
          padding: AtharSpacing.allLg,
          children: [
            // 1. سبورتي (My Whiteboard)
            // ✅ نمرر المتغير حتى لو كان null
            _buildMyBoardSection(myNote),

            AtharGap.xxl,
            Divider(thickness: 1, color: colorScheme.outline),
            AtharGap.lg,

            // 2. سبورات الفريق (Team Boards)
            Text(
              l10n.teamBoardsCount(otherNotes.length),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: colorScheme.onSurfaceVariant,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
            AtharGap.md,

            if (otherNotes.isEmpty)
              _buildEmptyTeamState()
            else
              ...otherNotes.map((note) => _buildTeamNoteCard(note)),
          ],
        );
      },
    );
  }

  // ✅ التصحيح 2: استقبال Null
  Widget _buildMyBoardSection(TaskNoteModel? myNote) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.myBoard,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, fontFamily: AtharTypography.fontFamily, fontFamilyFallback: AtharTypography.fontFallback),
            ),
            // ✅ التصحيح 3: لا نعرض التاريخ إذا كانت الملاحظة null
            if (myNote != null)
              Text(
                l10n.lastUpdate(timeago.format(myNote.updatedAt, locale: 'ar')),
                style: TextStyle(fontSize: 12.sp, color: colorScheme.outline, fontFamily: AtharTypography.fontFamily, fontFamilyFallback: AtharTypography.fontFallback),
              ),
          ],
        ),
        AtharGap.md,
        Container(
          decoration: BoxDecoration(
            color: colors.warning.withValues(alpha: 0.15), // لون أصفر فاتح
            borderRadius: AtharRadii.radiusMd,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            children: [
              AtharTextField(
                controller: _noteController,
                variant: AtharTextFieldVariant.borderless,
                maxLength: 1400,
                maxLines: 6,
                hint: l10n.boardNoteHint,
                customStyle: AtharTextFieldStyle(
                  textStyle: TextStyle(fontSize: 14.sp, height: 1.5, fontFamily: AtharTypography.fontFamily, fontFamilyFallback: AtharTypography.fontFallback),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AtharButton(
                  label: l10n.update,
                  icon: Icons.check,
                  size: AtharButtonSize.small,
                  onPressed: () {
                    if (_noteController.text.trim().isNotEmpty) {
                      context.read<TaskCubit>().saveMyNote(
                        widget.taskId,
                        _noteController.text,
                      );
                      AtharSnackbar.success(
                        context: context,
                        message: l10n.boardUpdated,
                      );
                      // إخفاء الكيبورد
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamNoteCard(TaskNoteModel note) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: colors.info.withValues(alpha: 0.15),
                child: Icon(Icons.person, size: 14.sp, color: colors.info),
              ),
              AtharGap.hSm,
              Text(
                l10n.teamMember,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, fontFamily: AtharTypography.fontFamily, fontFamilyFallback: AtharTypography.fontFallback),
              ),
              const Spacer(),
              // هنا updatedAt مضمونة الوجود لأننا جلبنا only valid notes في الـ Cubit
              Text(
                timeago.format(note.updatedAt, locale: 'ar'),
                style: TextStyle(fontSize: 10.sp, color: colorScheme.outline, fontFamily: AtharTypography.fontFamily, fontFamilyFallback: AtharTypography.fontFallback),
              ),
            ],
          ),
          AtharGap.sm,
          Text(
            note.content ?? "",
            style: TextStyle(
              fontSize: 13.sp,
              color: colorScheme.onSurface,
              height: 1.5,
              fontFamily: AtharTypography.fontFamily,
              fontFamilyFallback: AtharTypography.fontFallback,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTeamState() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Text(
          l10n.noTeamNotesYet,
          style: TextStyle(fontSize: 12.sp, color: colorScheme.outline),
        ),
      ),
    );
  }
}
