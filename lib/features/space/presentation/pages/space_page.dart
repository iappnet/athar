import 'package:athar/core/config/subscription_config.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/subscription/domain/entities/subscription_status.dart';
import 'package:athar/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:athar/features/subscription/presentation/widgets/pro_gate_widget.dart';
import 'package:athar/core/iam/permission_service.dart';
import 'package:athar/features/assets/presentation/cubit/assets_state.dart';
import 'package:athar/features/assets/presentation/pages/assets_page.dart';
import 'package:athar/features/health/presentation/pages/health_dashboard_page.dart';
import 'package:athar/features/space/presentation/cubit/list_cubit.dart';
import 'package:athar/features/space/presentation/cubit/space_cubit.dart';
import 'package:athar/features/space/presentation/cubit/space_state.dart';
import 'package:athar/features/space/presentation/pages/list_page.dart';
import 'package:athar/features/space/presentation/pages/project_details_page.dart';
import 'package:athar/features/space/presentation/pages/space_members_page.dart';
import 'package:athar/features/space/presentation/widgets/module_settings_dialog.dart';
import 'package:athar/features/space/presentation/widgets/space_settings_dialog.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/space_model.dart';
import '../../data/models/module_model.dart';
import '../cubit/module_cubit.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_display.dart';

class SpacePage extends StatefulWidget {
  final SpaceModel space;

  const SpacePage({super.key, required this.space});

  @override
  State<SpacePage> createState() => _SpaceDetailsPageState();
}

class _SpaceDetailsPageState extends State<SpacePage> {
  @override
  void initState() {
    super.initState();
    context.read<ModuleCubit>().loadModules(widget.space.uuid);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ الحل الجذري لمشكلة البيانات القديمة:
    // نستمع لتغيرات SpaceCubit لنحصل على أحدث نسخة من المساحة الحالية
    return BlocListener<SpaceCubit, SpaceState>(
      listenWhen: (_, curr) => curr is SpaceError,
      listener: (context, state) {
        if (state is SpaceError && state.message == 'spaces_pro_required') {
          context
              .read<SubscriptionCubit>()
              .presentSpacesPaywall(context);
        }
      },
      child: BlocBuilder<SpaceCubit, SpaceState>(
      builder: (context, spaceState) {
        // 1. محاولة العثور على النسخة المحدثة من المساحة الحالية
        SpaceModel currentSpace = widget.space;

        if (spaceState is SpaceLoaded) {
          try {
            currentSpace = spaceState.spaces.firstWhere(
              (s) => s.uuid == widget.space.uuid,
              orElse: () => widget.space,
            );
          } catch (_) {
            // في حال تم حذف المساحة ونحن بداخلها (نادر الحدوث)
            currentSpace = widget.space;
          }
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(
              currentSpace.name, // ✅ الاسم يتحدث تلقائياً لو تغير
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: colorScheme.onSurface,
            leading: BackButton(
              color: colorScheme.onSurface,
              onPressed: () => NavigationUtils.safeBack(context),
            ),
            actions: [
              if (currentSpace.type == 'shared')
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'members') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SpaceMembersPage(spaceId: currentSpace.uuid),
                        ),
                      );
                    } else if (value == 'settings') {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            SpaceSettingsDialog(space: currentSpace),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'members',
                      child: Row(
                        children: [
                          Icon(Icons.people_outline, color: context.colors.accentBlue),
                          AtharGap.hSm,
                          Text(l10n.spaceMembers),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings_suggest_outlined,
                            color: context.colors.accentOrange,
                          ),
                          AtharGap.hSm,
                          Text(l10n.spaceSettings),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // بقية الصفحة كما هي (تستخدم ModuleCubit وهو منفصل)
          body: BlocBuilder<ModuleCubit, ModuleState>(
            builder: (context, state) {
              if (state is ModuleLoading) {
                if (state is AssetsLoading) {
                  return GridView.builder(
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                    ),
                    itemCount: 4,
                    itemBuilder: (_, _) => AtharSkeleton(
                      width: double.infinity,
                      height: 200.h,
                      borderRadius: 16,
                    ),
                  );
                }
              } else if (state is ModuleLoaded) {
                final modules = state.modules;

                if (modules.isEmpty) {
                  return _buildEmptyState(l10n, colorScheme);
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    return _buildModuleCard(modules[index], l10n, colorScheme);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: null,
        );
      },
    ),   // closes BlocBuilder
    );   // closes BlocListener
  }

  // ✅ إصلاح الخلل: دالة التوجيه الموحدة
  void _navigateToModule(ModuleModel module) {
    if (module.type == 'project') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectDetailsPage(module: module),
        ),
      );
    } else if (module.type == 'assets') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProGateWidget(
            hasAccess: (SubscriptionStatus s) => s.hasAssetsPack,
            entitlementId: SubscriptionConfig.entitlementAssetsPack,
            featureName: 'وحدة الأصول',
            featureIcon: Icons.account_balance_wallet_rounded,
            featureDescription: 'اشترِ وحدة الأصول مرة واحدة وتتبع ممتلكاتك للأبد',
            child: const AssetsPage(),
          ),
        ),
      );
    } else if (module.type == 'list') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListPage(module: module)),
      );
    } else if (module.type == 'health') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProGateWidget(
            hasAccess: (SubscriptionStatus s) => s.hasHealthPack,
            entitlementId: SubscriptionConfig.entitlementHealthPack,
            featureName: 'وحدة الصحة',
            featureIcon: Icons.favorite_rounded,
            featureDescription: 'اشترِ وحدة الصحة مرة واحدة وتتبع صحتك للأبد',
            child: HealthDashboardPage(module: module),
          ),
        ),
      );
    }
  }

  /// يُرجع اسم النوع المترجم بناءً على نوع الموديول
  String _moduleTypeName(AppLocalizations l10n, String type) {
    switch (type) {
      case 'project':
        return l10n.moduleTypeProject;
      case 'list':
        return l10n.moduleTypeList;
      case 'health':
        return l10n.moduleTypeHealth;
      case 'assets':
        return l10n.moduleTypeAssets;
      default:
        return l10n.moduleTypeGeneral;
    }
  }

  Widget _buildModuleCard(
    ModuleModel module,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    // 🎨 تحديد الأيقونة واللون بناءً على النوع
    IconData icon;
    Color color;

    switch (module.type) {
      case 'project':
        icon = Icons.rocket_launch_rounded;
        color = context.colors.accentBlue;
        break;
      case 'list':
        icon = Icons.list_alt_rounded;
        color = context.colors.accentOrange;
        break;
      case 'health':
        icon = Icons.medical_services_rounded;
        color = context.colors.accentRed;
        break;
      case 'assets':
        icon = Icons.inventory_2_rounded;
        color = context.colors.accentTeal;
        break;
      default:
        icon = Icons.folder;
        color = context.colors.accentNeutral;
    }

    final typeName = _moduleTypeName(l10n, module.type);

    // ✅ دمج منطق الصلاحيات مع واجهة البطاقة
    return FutureBuilder<bool>(
      future: getIt<PermissionService>().canEdit(
        module.type == 'project' ? 'project' : 'module',
        spaceId: module.spaceId,
        module: module,
        resourceOwnerId: module.creatorId,
      ),
      builder: (context, snapshot) {
        final bool canEdit = snapshot.data ?? false;

        return Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: () => _navigateToModule(module),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: AtharRadii.radiusLg,
                    boxShadow: AtharShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 24.sp),
                          ),
                          // ✅ مؤشر الصلاحية البصري (القفل)
                          if (!canEdit)
                            Icon(
                              Icons.lock_outline,
                              size: 16.sp,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.name,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            typeName,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ حماية الأزرار: لا يظهر زر الخيارات إلا لمن يملك صلاحية التعديل
            if (canEdit)
              Positioned.directional(
                textDirection: Directionality.of(context),
                top: 8.h,
                start: 8.w,
                child: Material(
                  color: Colors.transparent,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDeleteModule(context, module, l10n);
                      } else if (value == 'settings') {
                        showDialog(
                          context: context,
                          builder: (_) => ModuleSettingsDialog(module: module),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            AtharGap.hSm,
                            Text(l10n.spacePermissionSettings),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            AtharGap.hSm,
                            Text(
                              l10n.spaceDeleteAction,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _confirmDeleteModule(
    BuildContext context,
    ModuleModel module,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.spaceDeleteModuleTitle),
        content: Text(l10n.spaceDeleteModuleContent(module.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.spaceCancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ModuleCubit>().deleteModule(module.uuid);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.spaceModuleDeletedSuccess)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.spaceDeleteAction),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ColorScheme colorScheme) {
    return AtharEmptyState(
      icon: Icons.folder_open_rounded,
      title: l10n.spaceEmptyTitle,
      message: l10n.spaceEmptySubtitle,
    );
  }

  // ignore: unused_element — keep for future use when context-aware FAB wires in
  void _showCreateModuleDialog(
    BuildContext context,
    List<ModuleModel> existingModules,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final controller = TextEditingController();
    String selectedType = 'project';
    String? selectedTemplateId;

    bool isPrivate = false;

    // تصفية القوائم فقط لاستخدامها كقوالب
    final listTemplates = existingModules
        .where((m) => m.type == 'list')
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              l10n.spaceAddNewTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: l10n.spaceModuleNameHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  AtharGap.lg,

                  SwitchListTile(
                    title: Text(l10n.spacePrivateModule),
                    subtitle: Text(l10n.spacePrivateModuleDesc),
                    value: isPrivate,
                    onChanged: (val) {
                      setState(() {
                        isPrivate = val;
                      });
                    },
                  ),

                  AtharGap.lg,

                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildTypeOption(
                        icon: Icons.rocket_launch,
                        label: l10n.moduleTypeProject,
                        type: 'project',
                        isSelected: selectedType == 'project',
                        colorScheme: colorScheme,
                        onTap: () => setState(() {
                          selectedType = 'project';
                          selectedTemplateId = null;
                        }),
                      ),
                      _buildTypeOption(
                        icon: Icons.inventory_2,
                        label: l10n.moduleTypeAssetsShort,
                        type: 'assets',
                        isSelected: selectedType == 'assets',
                        colorScheme: colorScheme,
                        onTap: () => setState(() {
                          selectedType = 'assets';
                          selectedTemplateId = null;
                        }),
                      ),
                      _buildTypeOption(
                        icon: Icons.list_alt,
                        label: l10n.moduleTypeList,
                        type: 'list',
                        isSelected: selectedType == 'list',
                        colorScheme: colorScheme,
                        onTap: () => setState(() => selectedType = 'list'),
                      ),
                      _buildTypeOption(
                        icon: Icons.favorite,
                        label: l10n.moduleTypeHealthShort,
                        type: 'health',
                        isSelected: selectedType == 'health',
                        colorScheme: colorScheme,
                        onTap: () => setState(() {
                          selectedType = 'health';
                          selectedTemplateId = null;
                        }),
                      ),
                    ],
                  ),

                  // ✅ خيار النسخ من قالب
                  if (selectedType == 'list' && listTemplates.isNotEmpty) ...[
                    AtharGap.lg,
                    const Divider(),
                    Row(
                      children: [
                        Icon(Icons.copy, size: 20, color: context.colors.accentOrange),
                        AtharGap.hSm,
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedTemplateId,
                            decoration: InputDecoration(
                              labelText: l10n.spaceCopyFromTemplate,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Text(l10n.spaceEmptyList),
                              ),
                              ...listTemplates.map(
                                (m) => DropdownMenuItem(
                                  value: m.uuid,
                                  child: Text(
                                    m.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) =>
                                setState(() => selectedTemplateId = val),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.spaceCancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    final newModuleId = const Uuid().v4();

                    context.read<ModuleCubit>().createModule(
                      widget.space.uuid,
                      controller.text,
                      selectedType,
                      uuid: newModuleId,
                      visibility: isPrivate ? 'private' : 'public',
                    );

                    if (selectedType == 'list' && selectedTemplateId != null) {
                      context.read<ListCubit>().copyList(
                        sourceModuleId: selectedTemplateId!,
                        targetModuleId: newModuleId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.spaceListCopiedSuccess)),
                      );
                    }

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                ),
                child: Text(
                  l10n.spaceCreateAction,
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeOption({
    required IconData icon,
    required String label,
    required String type,
    required bool isSelected,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 24.sp,
            ),
          ),
          AtharGap.xxs,
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
