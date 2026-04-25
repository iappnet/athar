import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AddAssetSheet extends StatefulWidget {
  final String? spaceId;
  final String? moduleId;

  const AddAssetSheet({super.key, this.spaceId, this.moduleId});

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _warrantyController = TextEditingController(text: '24');

  final _vendorController = TextEditingController();
  final _serialController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  DateTime? _nextMaintenanceDate;
  DateTime? _insuranceExpiryDate;
  DateTime? _licenseExpiryDate;
  bool _reminderEnabled = true;
  int _reminderDaysBefore = 7;
  bool _showAdvanced = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _warrantyController.dispose();
    _vendorController.dispose();
    _serialController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        24.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AtharGap.xl,
              Text(
                l10n.addAssetTitle,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              AtharGap.xl,

              // 1. Name (required)
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  colorScheme,
                  l10n.addAssetNameLabel,
                  Icons.local_offer_outlined,
                ),
                validator: (value) =>
                    value!.isEmpty ? l10n.addAssetNameRequired : null,
              ),
              AtharGap.md,

              // 2. Category & Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: _inputDecoration(
                        colorScheme,
                        l10n.addAssetCategoryLabel,
                        Icons.category_outlined,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        colorScheme,
                        l10n.addAssetPriceLabel,
                        Icons.attach_money,
                      ),
                    ),
                  ),
                ],
              ),
              AtharGap.md,

              // 3. Purchase date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _purchaseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _purchaseDate = picked);
                },
                borderRadius: AtharRadii.card,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: AtharRadii.card,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: colorScheme.outline,
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        l10n.addAssetPurchaseDate(
                          DateFormat('yyyy-MM-dd').format(_purchaseDate),
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AtharGap.md,

              // 4. Warranty duration
              TextFormField(
                controller: _warrantyController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  colorScheme,
                  l10n.addAssetWarrantyLabel,
                  Icons.security,
                ).copyWith(helperText: l10n.addAssetWarrantyHint),
              ),

              AtharGap.lg,

              // 5. Advanced details toggle
              TextButton.icon(
                onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
                icon: Icon(
                  _showAdvanced
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                label: Text(
                  _showAdvanced
                      ? l10n.addAssetHideAdvanced
                      : l10n.addAssetShowAdvanced,
                ),
              ),

              if (_showAdvanced) ...[
                AtharGap.sm,
                TextFormField(
                  controller: _vendorController,
                  decoration: _inputDecoration(
                    colorScheme,
                    l10n.addAssetVendorLabel,
                    Icons.store_outlined,
                  ),
                ),
                AtharGap.md,
                TextFormField(
                  controller: _serialController,
                  decoration: _inputDecoration(
                    colorScheme,
                    l10n.addAssetSerialLabel,
                    Icons.qr_code,
                  ),
                ),
                AtharGap.md,
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    colorScheme,
                    l10n.addAssetNotesLabel,
                    Icons.note_outlined,
                  ),
                ),
                AtharGap.lg,
                _buildDatePickerRow(
                  colorScheme,
                  label: 'تاريخ الصيانة القادمة',
                  icon: Icons.build_outlined,
                  date: _nextMaintenanceDate,
                  onPicked: (d) =>
                      setState(() => _nextMaintenanceDate = d),
                ),
                AtharGap.md,
                _buildDatePickerRow(
                  colorScheme,
                  label: 'تاريخ انتهاء التأمين',
                  icon: Icons.health_and_safety_outlined,
                  date: _insuranceExpiryDate,
                  onPicked: (d) =>
                      setState(() => _insuranceExpiryDate = d),
                ),
                AtharGap.md,
                _buildDatePickerRow(
                  colorScheme,
                  label: 'تاريخ انتهاء الترخيص',
                  icon: Icons.badge_outlined,
                  date: _licenseExpiryDate,
                  onPicked: (d) =>
                      setState(() => _licenseExpiryDate = d),
                ),
                AtharGap.lg,
                SwitchListTile(
                  title: const Text('تفعيل التذكير'),
                  subtitle:
                      const Text('تذكيرني قبل انتهاء التواريخ'),
                  value: _reminderEnabled,
                  onChanged: (v) =>
                      setState(() => _reminderEnabled = v),
                ),
                if (_reminderEnabled) ...[
                  AtharGap.sm,
                  Row(
                    children: [
                      const Text('التذكير قبل:'),
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 70.w,
                        child: DropdownButtonFormField<int>(
                          initialValue: _reminderDaysBefore,
                          items: [1, 3, 7, 14, 30]
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text('$d يوم'),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(
                              () => _reminderDaysBefore = v!),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: AtharRadii.card),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.w),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              AtharGap.xxl,

              // Save button
              ElevatedButton(
                onPressed: _saveAsset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(borderRadius: AtharRadii.card),
                ),
                child: Text(
                  l10n.addAssetSaveButton,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerRow(
    ColorScheme colorScheme, {
    required String label,
    required IconData icon,
    required DateTime? date,
    required ValueChanged<DateTime> onPicked,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: AtharRadii.card,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: AtharRadii.card,
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.outline, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                date != null
                    ? '$label: ${DateFormat('yyyy-MM-dd').format(date)}'
                    : label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: date != null ? null : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    ColorScheme colorScheme,
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20.sp, color: colorScheme.outline),
      border: OutlineInputBorder(borderRadius: AtharRadii.card),
      enabledBorder: OutlineInputBorder(
        borderRadius: AtharRadii.card,
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }

  void _saveAsset() {
    final l10n = AppLocalizations.of(context);

    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text);
      final warranty = int.tryParse(_warrantyController.text) ?? 24;

      context.read<AssetsCubit>().addAsset(
        name: _nameController.text,
        purchaseDate: _purchaseDate,
        warrantyMonths: warranty,
        category: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : null,
        price: price,
        vendor: _vendorController.text.isNotEmpty
            ? _vendorController.text
            : null,
        serialNumber: _serialController.text.isNotEmpty
            ? _serialController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        spaceId: widget.spaceId,
        moduleId: widget.moduleId,
        nextMaintenanceDate: _nextMaintenanceDate,
        insuranceExpiryDate: _insuranceExpiryDate,
        licenseExpiryDate: _licenseExpiryDate,
        reminderEnabled: _reminderEnabled,
        reminderDaysBefore: _reminderDaysBefore,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addAssetSuccess)));
    }
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class AddAssetSheet extends StatefulWidget {
//   final String? spaceId; // في حال كنا داخل مساحة مشتركة
//   final String? moduleId; // ✅ الإضافة الجديدة: معرف الموديول

//   const AddAssetSheet({super.key, this.spaceId, this.moduleId});

//   @override
//   State<AddAssetSheet> createState() => _AddAssetSheetState();
// }

// class _AddAssetSheetState extends State<AddAssetSheet> {
//   // المفاتيح والتحكم
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _categoryController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _warrantyController = TextEditingController(
//     text: '24',
//   ); // الافتراضي سنتين

//   // حقول إضافية
//   final _vendorController = TextEditingController();
//   final _serialController = TextEditingController();
//   final _notesController = TextEditingController();

//   DateTime _purchaseDate = DateTime.now();
//   bool _showAdvanced = false; // لإخفاء/إظهار التفاصيل الثانوية

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         24.w,
//         24.h,
//         24.w,
//         MediaQuery.of(context).viewInsets.bottom + 24.h, // لتجنب الكيبورد
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // العنوان
//               Center(
//                 child: Container(
//                   width: 40.w,
//                   height: 4.h,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.h),
//               Text(
//                 "إضافة أصل جديد 💎",
//                 style: TextStyle(
//                   fontFamily: 'Tajawal',
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20.h),

//               // 1. الاسم (إجباري)
//               TextFormField(
//                 controller: _nameController,
//                 decoration: _inputDecoration(
//                   "اسم الجهاز/الأصل",
//                   Icons.local_offer_outlined,
//                 ),
//                 validator: (value) => value!.isEmpty ? "الاسم مطلوب" : null,
//               ),
//               SizedBox(height: 12.h),

//               // 2. الفئة والسعر
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _categoryController,
//                       decoration: _inputDecoration(
//                         "الفئة (مثلاً: جوال)",
//                         Icons.category_outlined,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _priceController,
//                       keyboardType: TextInputType.number,
//                       decoration: _inputDecoration("السعر", Icons.attach_money),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12.h),

//               // 3. تاريخ الشراء
//               InkWell(
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: _purchaseDate,
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime.now(),
//                   );
//                   if (picked != null) setState(() => _purchaseDate = picked);
//                 },
//                 borderRadius: BorderRadius.circular(12.r),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 12.w,
//                     vertical: 16.h,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.calendar_today,
//                         color: Colors.grey,
//                         size: 20.sp,
//                       ),
//                       SizedBox(width: 10.w),
//                       Text(
//                         "تاريخ الشراء: ${DateFormat('yyyy-MM-dd').format(_purchaseDate)}",
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12.h),

//               // 4. مدة الضمان
//               TextFormField(
//                 controller: _warrantyController,
//                 keyboardType: TextInputType.number,
//                 decoration: _inputDecoration(
//                   "مدة الضمان (بالأشهر)",
//                   Icons.security,
//                 ).copyWith(helperText: "مثال: 12 لسنة واحدة، 24 لسنتين"),
//               ),

//               SizedBox(height: 16.h),

//               // 5. زر إظهار التفاصيل المتقدمة
//               TextButton.icon(
//                 onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
//                 icon: Icon(
//                   _showAdvanced
//                       ? Icons.keyboard_arrow_up
//                       : Icons.keyboard_arrow_down,
//                 ),
//                 label: Text(
//                   _showAdvanced
//                       ? "إخفاء التفاصيل الإضافية"
//                       : "إضافة تفاصيل (البائع، السيريال، ملاحظات)",
//                 ),
//               ),

//               if (_showAdvanced) ...[
//                 SizedBox(height: 8.h),
//                 TextFormField(
//                   controller: _vendorController,
//                   decoration: _inputDecoration(
//                     "المتجر / البائع",
//                     Icons.store_outlined,
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 TextFormField(
//                   controller: _serialController,
//                   decoration: _inputDecoration(
//                     "الرقم التسلسلي (S/N)",
//                     Icons.qr_code,
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 TextFormField(
//                   controller: _notesController,
//                   maxLines: 3,
//                   decoration: _inputDecoration(
//                     "ملاحظات إضافية",
//                     Icons.note_outlined,
//                   ),
//                 ),
//               ],

//               SizedBox(height: 24.h),

//               // زر الحفظ
//               ElevatedButton(
//                 onPressed: _saveAsset,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   minimumSize: Size(double.infinity, 50.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 child: const Text(
//                   "حفظ الأصل",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon, size: 20.sp, color: Colors.grey),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//     );
//   }

//   void _saveAsset() {
//     if (_formKey.currentState!.validate()) {
//       final price = double.tryParse(_priceController.text);
//       final warranty = int.tryParse(_warrantyController.text) ?? 24;

//       context.read<AssetsCubit>().addAsset(
//         name: _nameController.text,
//         purchaseDate: _purchaseDate,
//         warrantyMonths: warranty,
//         category: _categoryController.text.isNotEmpty
//             ? _categoryController.text
//             : null,
//         price: price,
//         vendor: _vendorController.text.isNotEmpty
//             ? _vendorController.text
//             : null,
//         serialNumber: _serialController.text.isNotEmpty
//             ? _serialController.text
//             : null,
//         notes: _notesController.text.isNotEmpty ? _notesController.text : null,
//         spaceId: widget.spaceId,
//         moduleId: widget.moduleId, // ✅ تمرير معرف الموديول للكيوبت
//       );

//       Navigator.pop(context);

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("تمت إضافة الأصل بنجاح ✅")));
//     }
//   }
// }
//-----------------------------------------------------------------------
