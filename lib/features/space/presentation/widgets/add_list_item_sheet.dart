import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/features/space/data/models/list_item_model.dart';
import 'package:athar/features/space/presentation/cubit/list_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddListItemSheet extends StatefulWidget {
  final String moduleId;
  final ListItemModel? itemToEdit; // ✅ عنصر اختياري للتعديل

  const AddListItemSheet({
    super.key,
    required this.moduleId,
    this.itemToEdit, // ✅
  });

  @override
  State<AddListItemSheet> createState() => _AddListItemSheetState();
}

class _AddListItemSheetState extends State<AddListItemSheet> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController();
  final _repeatDaysController = TextEditingController();

  bool _autoUncheck = false;

  // ✅ معرفة هل نحن في وضع التعديل أم الإضافة
  bool get isEditing => widget.itemToEdit != null;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _repeatDaysController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final item = widget.itemToEdit!;
      _nameController.text = item.name;
      _quantityController.text = item.quantity.toString().replaceAll(
        RegExp(r'\.0$'),
        '',
      ); // إزالة .0
      _unitController.text = item.unit ?? '';
      _repeatDaysController.text = item.repeatEveryDays?.toString() ?? '';
      _autoUncheck = item.autoUncheck;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        AtharSpacing.xxl,
        AtharSpacing.xxl,
        AtharSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + AtharSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.bottomSheet,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: AtharRadii.radiusFull,
                ),
              ),
            ),
            AtharGap.xl,

            // ✅ تغيير العنوان حسب الحالة
            Text(
              isEditing ? l10n.addListItemEditTitle : l10n.addListItemAddTitle,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            AtharGap.xl,

            // 1. الاسم
            TextField(
              controller: _nameController,
              autofocus:
                  !isEditing, // لا نفتح الكيبورد تلقائياً في التعديل لتجنب الإزعاج
              decoration: InputDecoration(
                labelText: l10n.addListItemNameLabel,
                border: OutlineInputBorder(borderRadius: AtharRadii.card),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            AtharGap.lg,

            // 2. الكمية والوحدة
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.addListItemQuantityLabel,
                      border: OutlineInputBorder(borderRadius: AtharRadii.card),
                    ),
                  ),
                ),
                AtharGap.hMd,
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    decoration: InputDecoration(
                      labelText: l10n.addListItemUnitLabel,
                      border: OutlineInputBorder(borderRadius: AtharRadii.card),
                    ),
                  ),
                ),
              ],
            ),
            AtharGap.lg,

            // 3. خيارات التكرار
            ExpansionTile(
              title: Text(
                l10n.addListItemRepeatTitle,
                style: TextStyle(fontSize: 14.sp),
              ),
              leading: Icon(Icons.repeat, color: context.colors.accentOrange),
              tilePadding: EdgeInsets.zero,
              initiallyExpanded:
                  isEditing &&
                  widget.itemToEdit!.repeatEveryDays !=
                      null, // ✅ فتح القائمة إذا كان هناك تكرار مسبق
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _repeatDaysController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.addListItemRepeatDaysLabel,
                          helperText: l10n.addListItemRepeatDaysHelper,
                          border: OutlineInputBorder(
                            borderRadius: AtharRadii.card,
                          ),
                        ),
                      ),
                    ),
                    AtharGap.hMd,
                    Expanded(
                      child: CheckboxListTile(
                        title: Text(
                          l10n.addListItemAutoUncheck,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        subtitle: Text(
                          l10n.addListItemAutoUncheckDesc,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: colorScheme.outline,
                          ),
                        ),
                        value: _autoUncheck,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) =>
                            setState(() => _autoUncheck = val ?? false),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            AtharGap.xxl,

            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: AtharRadii.card),
              ),
              child: Text(
                isEditing
                    ? l10n.addListItemSaveEdits
                    : l10n.addListItemAddToList,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveItem() {
    if (_nameController.text.isNotEmpty) {
      final qty = double.tryParse(_quantityController.text) ?? 1.0;
      final repeat = int.tryParse(_repeatDaysController.text);

      if (isEditing) {
        // ✅ منطق التعديل
        context.read<ListCubit>().updateItemDetails(
          item: widget.itemToEdit!,
          name: _nameController.text,
          quantity: qty,
          unit: _unitController.text.isNotEmpty ? _unitController.text : null,
          repeatDays: repeat,
          autoUncheck: _autoUncheck,
        );
      } else {
        // ✅ منطق الإضافة
        context.read<ListCubit>().addItem(
          moduleId: widget.moduleId,
          name: _nameController.text,
          quantity: qty,
          unit: _unitController.text.isNotEmpty ? _unitController.text : null,
          repeatDays: repeat,
          autoUncheck: _autoUncheck,
        );
      }
      Navigator.pop(context);
    }
  }
}
