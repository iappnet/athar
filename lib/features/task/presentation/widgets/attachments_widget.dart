import 'dart:io';
import 'package:athar/features/task/data/models/attachment_model.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:flutter/material.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_filex/open_filex.dart';

class AttachmentsWidget extends StatelessWidget {
  final String taskId;
  final String spaceType; // 'personal' or 'shared'

  const AttachmentsWidget({
    super.key,
    required this.taskId,
    required this.spaceType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان وزر الإضافة
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.attachments,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.blue,
                size: 24.sp,
              ),
              onSelected: (value) {
                context.read<TaskCubit>().pickAndAddAttachment(
                  taskId: taskId,
                  spaceType: spaceType,
                  isImage: value == 'image',
                );
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'image',
                  child: Row(
                    children: [
                      Icon(Icons.image),
                      SizedBox(width: 8),
                      Text(l10n.attachmentImage),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'file',
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file),
                      SizedBox(width: 8),
                      Text(l10n.attachmentFile),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // قائمة الملفات
        StreamBuilder<List<AttachmentModel>>(
          stream: context.read<TaskCubit>().watchAttachments(taskId),
          builder: (context, snapshot) {
            final files = snapshot.data ?? [];

            if (files.isEmpty) {
              return _buildEmptyState(context);
            }

            return SizedBox(
              height: 120.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: files.length,
                separatorBuilder: (c, i) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  return _buildFileCard(context, files[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFileCard(BuildContext context, AttachmentModel file) {
    final l10n = AppLocalizations.of(context);
    final bool isImage = file.fileType == 'image';
    final bool isExpired =
        file.expiresAt != null && DateTime.now().isAfter(file.expiresAt!);
    // التحقق من وجود الملف محلياً
    final bool hasLocal =
        file.localPath != null && File(file.localPath!).existsSync();

    return GestureDetector(
      onTap: () {
        if (hasLocal) {
          // ✅ فتح الملف المحلي
          OpenFilex.open(file.localPath!);
        } else if (isExpired) {
          // ✅✅ التعديل الجديد: إظهار ديالوج طلب الإحياء
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.fileExpiredTitle),
              content: Text(l10n.fileArchivedMessage),
              actions: [
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  child: Text(l10n.requestReupload),
                  onPressed: () {
                    context.read<TaskCubit>().requestResurrection(file.uuid);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.requestSentToOwner)),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          // منطق التحميل المستقبلي (عندما يكون في السحابة ولم ينتهِ)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.downloadingFromCloud)));
        }
      },
      child: Container(
        width: 100.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    child: isImage && hasLocal
                        ? Image.file(File(file.localPath!), fit: BoxFit.cover)
                        : Icon(
                            isImage ? Icons.image : Icons.picture_as_pdf,
                            size: 40.sp,
                            color: Colors.grey.shade400,
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Text(
                    file.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.sp),
                  ),
                ),
              ],
            ),

            // زر الحذف
            Positioned(
              top: 4,
              left: 4,
              child: GestureDetector(
                onTap: () =>
                    context.read<TaskCubit>().deleteAttachment(file.uuid),
                child: CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  child: Icon(Icons.close, size: 14.sp, color: Colors.red),
                ),
              ),
            ),

            // أيقونة انتهاء الصلاحية
            if (isExpired && !hasLocal)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.timer_off,
                      color: Colors.red,
                      size: 30.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.shade200,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          l10n.noAttachments,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ),
    );
  }
}
