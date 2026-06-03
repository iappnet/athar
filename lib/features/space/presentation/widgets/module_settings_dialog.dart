import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/features/space/data/models/delegation_mode.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModuleSettingsDialog extends StatefulWidget {
  final ModuleModel module;

  const ModuleSettingsDialog({super.key, required this.module});

  @override
  State<ModuleSettingsDialog> createState() => _ModuleSettingsDialogState();
}

class _ModuleSettingsDialogState extends State<ModuleSettingsDialog> {
  late DelegationMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.module.delegationMode;
  }

  String _getContextMessage(AppLocalizations l10n) {
    switch (widget.module.type) {
      case 'health':
        return l10n.moduleSettingsContextHealth;
      case 'assets':
        return l10n.moduleSettingsContextAssets;
      case 'list':
        return l10n.moduleSettingsContextList;
      case 'project':
      default:
        return l10n.moduleSettingsContextProject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.settings, color: colorScheme.primary),
          AtharGap.hSm,
          Text(l10n.moduleSettingsTitle, style: TextStyle(fontSize: 18.sp)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.module.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            AtharGap.sm,
            Text(
              _getContextMessage(l10n),
              style: TextStyle(color: colorScheme.outline, fontSize: 12.sp),
            ),
            const Divider(),
            AtharGap.sm,
            Text(
              l10n.moduleSettingsDelegationLabel,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            AtharGap.sm,

            // ✅ الحل الصحيح للنسخة 3.38+:
            // 1. نغلف الخيارات بـ RadioGroup
            // 2. نستخدم groupValue هنا (وليس value)
            RadioGroup<DelegationMode>(
              groupValue: _selectedMode, // ✅ الاسم الصحيح للباراميتر
              onChanged: (DelegationMode? val) {
                if (val != null) {
                  setState(() => _selectedMode = val);
                }
              },
              child: Column(
                children: [
                  _buildRadioOption(
                    colorScheme: colorScheme,
                    value: DelegationMode.inherit,
                    title: l10n.moduleSettingsModeInherit,
                    subtitle: l10n.moduleSettingsModeInheritDesc,
                  ),
                  _buildRadioOption(
                    colorScheme: colorScheme,
                    value: DelegationMode.enabled,
                    title: l10n.moduleSettingsModeEnabled,
                    subtitle: l10n.moduleSettingsModeEnabledDesc,
                    icon: Icons.check_circle_outline,
                    iconColor: context.colors.success,
                  ),
                  _buildRadioOption(
                    colorScheme: colorScheme,
                    value: DelegationMode.disabled,
                    title: l10n.moduleSettingsModeDisabled,
                    subtitle: l10n.moduleSettingsModeDisabledDesc,
                    icon: Icons.lock_outline,
                    iconColor: colorScheme.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.moduleSettingsCancel),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<ModuleCubit>().updateModuleDelegation(
              widget.module,
              _selectedMode,
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.moduleSettingsSaveSuccess)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: Text(l10n.moduleSettingsSave),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required ColorScheme colorScheme,
    required DelegationMode value,
    required String title,
    required String subtitle,
    IconData? icon,
    Color? iconColor,
  }) {
    // ✅ نستخدم InkWell مع Radio للحفاظ على التخصيص
    // ✅ نزيل groupValue و onChanged من Radio (لأن RadioGroup تكفلت بها)
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMode = value;
        });
      },
      borderRadius: AtharRadii.radiusSm,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<DelegationMode>(
              value: value,
              // ❌ تم حذف groupValue (موروث من RadioGroup)
              // ❌ تم حذف onChanged (موروث من RadioGroup)
              activeColor: colorScheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: _selectedMode == value
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (icon != null) ...[
                        AtharGap.hSm,
                        Icon(icon, size: 16.sp, color: iconColor),
                      ],
                    ],
                  ),
                  AtharGap.xxxs,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
