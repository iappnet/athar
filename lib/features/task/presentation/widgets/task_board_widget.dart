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

/// Semantic colors (not in ColorScheme)
const _warningColor = Color(0xFFFDCB6E);
const _infoColor = Color(0xFF74B9FF);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.myBoard,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
            // ✅ التصحيح 3: لا نعرض التاريخ إذا كانت الملاحظة null
            if (myNote != null)
              Text(
                l10n.lastUpdate(timeago.format(myNote.updatedAt, locale: 'ar')),
                style: TextStyle(fontSize: 12.sp, color: colorScheme.outline),
              ),
          ],
        ),
        AtharGap.md,
        Container(
          decoration: BoxDecoration(
            color: _warningColor.withValues(alpha: 0.15), // لون أصفر فاتح
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
                  textStyle: TextStyle(fontSize: 14.sp, height: 1.5),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
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
                backgroundColor: _infoColor.withValues(alpha: 0.15),
                child: Icon(Icons.person, size: 14.sp, color: _infoColor),
              ),
              AtharGap.hSm,
              Text(
                l10n.teamMember,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              const Spacer(),
              // هنا updatedAt مضمونة الوجود لأننا جلبنا only valid notes في الـ Cubit
              Text(
                timeago.format(note.updatedAt, locale: 'ar'),
                style: TextStyle(fontSize: 10.sp, color: colorScheme.outline),
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
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/features/task/data/models/task_note_model.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class TaskBoardWidget extends StatefulWidget {
//   final String taskId;

//   const TaskBoardWidget({super.key, required this.taskId});

//   @override
//   State<TaskBoardWidget> createState() => _TaskBoardWidgetState();
// }

// class _TaskBoardWidgetState extends State<TaskBoardWidget> {
//   final TextEditingController _noteController = TextEditingController();
//   // ✅ التعامل مع الزائر
//   final String _myUserId =
//       Supabase.instance.client.auth.currentUser?.id ?? 'guest';
//   bool _isInit = true;

//   @override
//   void initState() {
//     super.initState();
//     // إعداد اللغة العربية للمكتبة
//     timeago.setLocaleMessages('ar', timeago.ArMessages());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return StreamBuilder<List<TaskNoteModel>>(
//       stream: context.read<TaskCubit>().watchTaskNotes(widget.taskId),
//       builder: (context, snapshot) {
//         final notes = snapshot.data ?? [];

//         // ✅ التصحيح 1: البحث الآمن
//         // بدلاً من orElse التي تعيد موديلاً فارغاً يسبب المشكلة، نستخدم try/catch أو نتركها null
//         TaskNoteModel? myNote;
//         try {
//           myNote = notes.firstWhere((n) => n.userId == _myUserId);
//         } catch (_) {
//           myNote = null; // لا توجد ملاحظة لي بعد
//         }

//         final otherNotes = notes.where((n) => n.userId != _myUserId).toList();

//         // تعبئة النص عند الفتح لأول مرة فقط
//         if (_isInit && myNote?.content != null) {
//           _noteController.text = myNote!.content!;
//           _isInit = false;
//         }

//         return ListView(
//           padding: AtharSpacing.allLg,
//           children: [
//             // 1. سبورتي (My Whiteboard)
//             // ✅ نمرر المتغير حتى لو كان null
//             _buildMyBoardSection(myNote),

//             AtharGap.xxl,
//             Divider(thickness: 1, color: colors.border),
//             AtharGap.lg,

//             // 2. سبورات الفريق (Team Boards)
//             Text(
//               "سبورات الفريق (${otherNotes.length})",
//               style: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16.sp,
//                 color: colors.textSecondary,
//               ),
//             ),
//             AtharGap.md,

//             if (otherNotes.isEmpty)
//               _buildEmptyTeamState()
//             else
//               ...otherNotes.map((note) => _buildTeamNoteCard(note)),
//           ],
//         );
//       },
//     );
//   }

//   // ✅ التصحيح 2: استقبال Null
//   Widget _buildMyBoardSection(TaskNoteModel? myNote) {
//     final colors = context.colors;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "سبورتي 📝",
//               style: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18.sp,
//               ),
//             ),
//             // ✅ التصحيح 3: لا نعرض التاريخ إذا كانت الملاحظة null
//             if (myNote != null)
//               Text(
//                 "آخر تحديث: ${timeago.format(myNote.updatedAt, locale: 'ar')}",
//                 style: TextStyle(fontSize: 12.sp, color: colors.textTertiary),
//               ),
//           ],
//         ),
//         AtharGap.md,
//         Container(
//           decoration: BoxDecoration(
//             color: colors.warning.withValues(alpha: 0.15), // لون أصفر فاتح
//             borderRadius: AtharRadii.radiusMd,
//             boxShadow: [
//               BoxShadow(
//                 color: colors.shadow.withValues(alpha: 0.05),
//                 blurRadius: 5,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//           child: Column(
//             children: [
//               AtharTextField(
//                 controller: _noteController,
//                 variant: AtharTextFieldVariant.borderless,
//                 maxLength: 1400,
//                 maxLines: 6,
//                 hint: "اكتب ملاحظاتك، شرح المشكلة، أو التحديثات هنا...",
//                 customStyle: AtharTextFieldStyle(
//                   textStyle: TextStyle(fontSize: 14.sp, height: 1.5),
//                   contentPadding: EdgeInsets.zero,
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: AtharButton(
//                   label: "تحديث",
//                   icon: Icons.check,
//                   size: AtharButtonSize.small,
//                   onPressed: () {
//                     if (_noteController.text.trim().isNotEmpty) {
//                       context.read<TaskCubit>().saveMyNote(
//                         widget.taskId,
//                         _noteController.text,
//                       );
//                       AtharSnackbar.success(
//                         context: context,
//                         message: "تم تحديث السبورة ✅",
//                       );
//                       // إخفاء الكيبورد
//                       FocusScope.of(context).unfocus();
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTeamNoteCard(TaskNoteModel note) {
//     final colors = context.colors;

//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: AtharSpacing.allLg,
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: AtharRadii.radiusMd,
//         border: Border.all(color: colors.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 12.r,
//                 backgroundColor: colors.info.withValues(alpha: 0.15),
//                 child: Icon(Icons.person, size: 14.sp, color: colors.info),
//               ),
//               AtharGap.hSm,
//               Text(
//                 "عضو فريق",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14.sp,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//               const Spacer(),
//               // هنا updatedAt مضمونة الوجود لأننا جلبنا only valid notes في الـ Cubit
//               Text(
//                 timeago.format(note.updatedAt, locale: 'ar'),
//                 style: TextStyle(fontSize: 10.sp, color: colors.textTertiary),
//               ),
//             ],
//           ),
//           AtharGap.sm,
//           Text(
//             note.content ?? "",
//             style: TextStyle(
//               fontSize: 13.sp,
//               color: colors.textPrimary,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyTeamState() {
//     final colors = context.colors;

//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 20.h),
//         child: Text(
//           "لا توجد ملاحظات من الفريق بعد",
//           style: TextStyle(fontSize: 12.sp, color: colors.textTertiary),
//         ),
//       ),
//     );
//   }
// }
// import 'package:athar/features/task/data/models/task_note_model.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class TaskBoardWidget extends StatefulWidget {
//   final String taskId;

//   const TaskBoardWidget({super.key, required this.taskId});

//   @override
//   State<TaskBoardWidget> createState() => _TaskBoardWidgetState();
// }

// class _TaskBoardWidgetState extends State<TaskBoardWidget> {
//   final TextEditingController _noteController = TextEditingController();
//   // ✅ التعامل مع الزائر
//   final String _myUserId =
//       Supabase.instance.client.auth.currentUser?.id ?? 'guest';
//   bool _isInit = true;

//   @override
//   void initState() {
//     super.initState();
//     // إعداد اللغة العربية للمكتبة
//     timeago.setLocaleMessages('ar', timeago.ArMessages());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<TaskNoteModel>>(
//       stream: context.read<TaskCubit>().watchTaskNotes(widget.taskId),
//       builder: (context, snapshot) {
//         final notes = snapshot.data ?? [];

//         // ✅ التصحيح 1: البحث الآمن
//         // بدلاً من orElse التي تعيد موديلاً فارغاً يسبب المشكلة، نستخدم try/catch أو نتركها null
//         TaskNoteModel? myNote;
//         try {
//           myNote = notes.firstWhere((n) => n.userId == _myUserId);
//         } catch (_) {
//           myNote = null; // لا توجد ملاحظة لي بعد
//         }

//         final otherNotes = notes.where((n) => n.userId != _myUserId).toList();

//         // تعبئة النص عند الفتح لأول مرة فقط
//         if (_isInit && myNote?.content != null) {
//           _noteController.text = myNote!.content!;
//           _isInit = false;
//         }

//         return ListView(
//           padding: EdgeInsets.all(16.w),
//           children: [
//             // 1. سبورتي (My Whiteboard)
//             // ✅ نمرر المتغير حتى لو كان null
//             _buildMyBoardSection(myNote),

//             SizedBox(height: 24.h),
//             Divider(thickness: 1, color: Colors.grey.shade200),
//             SizedBox(height: 16.h),

//             // 2. سبورات الفريق (Team Boards)
//             Text(
//               "سبورات الفريق (${otherNotes.length})",
//               style: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16.sp,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//             SizedBox(height: 12.h),

//             if (otherNotes.isEmpty)
//               _buildEmptyTeamState()
//             else
//               ...otherNotes.map((note) => _buildTeamNoteCard(note)),
//           ],
//         );
//       },
//     );
//   }

//   // ✅ التصحيح 2: استقبال Null
//   Widget _buildMyBoardSection(TaskNoteModel? myNote) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "سبورتي 📝",
//               style: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18.sp,
//               ),
//             ),
//             // ✅ التصحيح 3: لا نعرض التاريخ إذا كانت الملاحظة null
//             if (myNote != null)
//               Text(
//                 "آخر تحديث: ${timeago.format(myNote.updatedAt, locale: 'ar')}",
//                 style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//               ),
//           ],
//         ),
//         SizedBox(height: 12.h),
//         Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFFFFF9C4), // لون أصفر فاتح
//             borderRadius: BorderRadius.circular(12.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.05),
//                 blurRadius: 5,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//           child: Column(
//             children: [
//               TextField(
//                 controller: _noteController,
//                 maxLength: 1400,
//                 maxLines: 6,
//                 style: TextStyle(fontSize: 14.sp, height: 1.5),
//                 decoration: const InputDecoration(
//                   hintText: "اكتب ملاحظاتك، شرح المشكلة، أو التحديثات هنا...",
//                   border: InputBorder.none,
//                   counterText: "", // إخفاء العداد الافتراضي
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     if (_noteController.text.trim().isNotEmpty) {
//                       context.read<TaskCubit>().saveMyNote(
//                         widget.taskId,
//                         _noteController.text,
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("تم تحديث السبورة ✅")),
//                       );
//                       // إخفاء الكيبورد
//                       FocusScope.of(context).unfocus();
//                     }
//                   },
//                   icon: const Icon(Icons.check, size: 18),
//                   label: const Text("تحديث"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange.shade300,
//                     foregroundColor: Colors.black87,
//                     elevation: 0,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTeamNoteCard(TaskNoteModel note) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 12.r,
//                 backgroundColor: Colors.blue.shade100,
//                 child: Icon(Icons.person, size: 14.sp, color: Colors.blue),
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 "عضو فريق",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14.sp,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//               const Spacer(),
//               // هنا updatedAt مضمونة الوجود لأننا جلبنا only valid notes في الـ Cubit
//               Text(
//                 timeago.format(note.updatedAt, locale: 'ar'),
//                 style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//               ),
//             ],
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             note.content ?? "",
//             style: TextStyle(
//               fontSize: 13.sp,
//               color: Colors.black87,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyTeamState() {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 20.h),
//         child: Text(
//           "لا توجد ملاحظات من الفريق بعد",
//           style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//         ),
//       ),
//     );
//   }
// }
