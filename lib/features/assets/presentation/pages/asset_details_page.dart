import 'dart:io';
import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/iam/permission_service.dart';
import 'package:athar/features/assets/data/models/asset_model.dart';
import 'package:athar/features/assets/data/models/service_model.dart';
import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
import 'package:athar/features/assets/presentation/cubit/assets_state.dart';
import 'package:athar/features/assets/presentation/pages/service_logs_page.dart';
import 'package:athar/features/assets/presentation/widgets/add_service_log_sheet.dart';
import 'package:athar/features/assets/presentation/widgets/add_service_sheet.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
import 'package:athar/features/space/presentation/cubit/space_cubit.dart';
import 'package:athar/features/space/presentation/cubit/space_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

class AssetDetailsPage extends StatefulWidget {
  final AssetModel asset;

  const AssetDetailsPage({super.key, required this.asset});

  @override
  State<AssetDetailsPage> createState() => _AssetDetailsPageState();
}

class _AssetDetailsPageState extends State<AssetDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late Future<bool> _canEditFuture;
  late Future<bool> _canDeleteFuture;
  ModuleModel? _targetModule;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initPermissions();
  }

  void _initPermissions() {
    final permissionService = getIt<PermissionService>();

    bool allowSpaceDelegation = false;
    ModuleModel? targetModule;

    try {
      final spaceState = context.read<SpaceCubit>().state;
      if (spaceState is SpaceLoaded && spaceState.selectedSpace != null) {
        allowSpaceDelegation = spaceState.selectedSpace!.allowMemberDelegation;
      }

      if (widget.asset.moduleId != null) {
        final moduleState = context.read<ModuleCubit>().state;
        if (moduleState is ModuleLoaded) {
          targetModule = moduleState.modules.firstWhere(
            (m) => m.uuid == widget.asset.moduleId,
            orElse: () => ModuleModel()..uuid = 'dummy',
          );
          if (targetModule.uuid == 'dummy') targetModule = null;
        }
      }
    } catch (e) {
      assert(() {
        debugPrint('[AssetDetailsPage] _initPermissions: $e');
        return true;
      }());
    }

    _canEditFuture = permissionService.canEdit(
      'asset',
      spaceId: widget.asset.spaceId,
      module: targetModule,
      allowSpaceDelegation: allowSpaceDelegation,
    );

    _canDeleteFuture = permissionService.canDelete(
      'asset',
      spaceId: widget.asset.spaceId,
      module: targetModule,
      allowSpaceDelegation: allowSpaceDelegation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AssetsCubit, AssetsState>(
      builder: (context, state) {
        AssetModel currentAsset = widget.asset;
        if (state is AssetsLoaded) {
          try {
            currentAsset = state.assets.firstWhere(
              (a) => a.uuid == widget.asset.uuid,
            );
          } catch (_) {
            return Scaffold(
              body: Center(child: Text(l10n.assetDetailsNotFound)),
            );
          }
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(
              currentAsset.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: colorScheme.onSurface,
            actions: [
              FutureBuilder<bool>(
                future: _canEditFuture,
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.comingSoon)),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              FutureBuilder<bool>(
                future: _canDeleteFuture,
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      onPressed: () => _confirmDelete(
                        context,
                        l10n,
                        currentAsset,
                        _targetModule,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              tabs: [
                Tab(text: l10n.assetDetailsTabOverview),
                Tab(text: l10n.assetDetailsTabMaintenance),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, currentAsset),
              _buildMaintenanceTab(context, currentAsset),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(BuildContext context, AssetModel asset) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: AtharSpacing.allXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWarrantyCard(colorScheme, l10n, asset),
          AtharGap.lg,
          _buildAttachmentsSection(context, colorScheme, l10n, asset),
          AtharGap.lg,
          _buildInfoCard(colorScheme, l10n, asset),
          AtharGap.lg,
          if (asset.notes != null && asset.notes!.isNotEmpty)
            _buildSectionTitle(l10n.assetDetailsNotes),
          if (asset.notes != null && asset.notes!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: AtharRadii.card,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                asset.notes!,
                style: TextStyle(fontSize: 14.sp, height: 1.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWarrantyCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AssetModel asset,
  ) {
    final status = asset.status;
    Color color;
    String text;
    double progress = 0.0;
    final totalDays = asset.warrantyMonths * 30;
    final remaining = asset.daysRemaining;
    final usedDays = totalDays - remaining;

    if (totalDays > 0) {
      progress = (usedDays / totalDays).clamp(0.0, 1.0);
    }

    switch (status) {
      case AssetWarrantyStatus.active:
        color = Colors.green;
        text = l10n.assetWarrantyActive;
        break;
      case AssetWarrantyStatus.expiringSoon:
        color = Colors.orange;
        text = l10n.assetWarrantyExpiringSoon;
        break;
      case AssetWarrantyStatus.expired:
        color = Colors.red;
        text = l10n.assetWarrantyExpired;
        progress = 1.0;
        break;
    }

    return Container(
      padding: AtharSpacing.allXl,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                remaining > 0
                    ? l10n.assetDaysRemaining(remaining)
                    : l10n.assetDaysRemaining(0),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
            ],
          ),
          AtharGap.md,
          ClipRRect(
            borderRadius: AtharRadii.radiusXs,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: color,
              minHeight: 10.h,
            ),
          ),
          AtharGap.sm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(asset.purchaseDate),
                style: TextStyle(fontSize: 10.sp, color: colorScheme.outline),
              ),
              Text(
                DateFormat('yyyy-MM-dd').format(asset.warrantyExpiryDate),
                style: TextStyle(fontSize: 10.sp, color: colorScheme.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AssetModel asset,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(l10n.assetDetailsInvoicesPhotos),
            TextButton.icon(
              onPressed: () {
                final spaceType = asset.spaceId != null ? 'shared' : 'personal';
                context.read<AssetsCubit>().pickAndAddAssetImage(
                  asset,
                  spaceType: spaceType,
                );
              },
              icon: Icon(Icons.add_a_photo, size: 16.sp),
              label: Text(l10n.assetDetailsAddPhoto),
            ),
          ],
        ),
        AtharGap.sm,
        SizedBox(
          height: 100.h,
          child: asset.attachments.isEmpty
              ? _buildEmptyAttachments(colorScheme, l10n)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: asset.attachments.length,
                  separatorBuilder: (c, i) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final file = asset.attachments.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        if (file.localPath != null) {
                          OpenFilex.open(file.localPath!);
                        }
                      },
                      child: Container(
                        width: 100.w,
                        decoration: BoxDecoration(
                          borderRadius: AtharRadii.card,
                          border: Border.all(color: colorScheme.outlineVariant),
                          image:
                              file.localPath != null &&
                                  File(file.localPath!).existsSync()
                              ? DecorationImage(
                                  image: FileImage(File(file.localPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            file.localPath == null ||
                                !File(file.localPath!).existsSync()
                            ? Center(
                                child: Icon(
                                  Icons.insert_drive_file,
                                  color: colorScheme.outline,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyAttachments(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: AtharRadii.card,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: Text(
          l10n.assetDetailsNoAttachments,
          style: TextStyle(fontSize: 12.sp, color: colorScheme.outline),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AssetModel asset,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.assetDetailsInfo),
        AtharGap.sm,
        Container(
          padding: AtharSpacing.allXl,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AtharRadii.radiusLg,
            border: Border.all(color: colorScheme.surfaceContainerHighest),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                colorScheme,
                Icons.category,
                l10n.assetDetailsCategory,
                asset.category ?? "-",
              ),
              Divider(height: 24.h),
              _buildInfoRow(
                colorScheme,
                Icons.store,
                l10n.assetDetailsVendor,
                asset.vendor ?? "-",
              ),
              Divider(height: 24.h),
              _buildInfoRow(
                colorScheme,
                Icons.qr_code,
                "S/N",
                asset.serialNumber ?? "-",
              ),
              Divider(height: 24.h),
              _buildInfoRow(
                colorScheme,
                Icons.attach_money,
                l10n.assetDetailsPrice,
                asset.price != null ? l10n.serviceLogsCost(asset.price!) : "-",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    ColorScheme colorScheme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: colorScheme.outline),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
    );
  }

  Widget _buildMaintenanceTab(BuildContext context, AssetModel asset) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<ServiceModel>>(
      stream: context.read<AssetsCubit>().watchServices(asset.uuid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final services = snapshot.data ?? [];
        if (services.isEmpty) {
          return _buildEmptyServicesState(context, colorScheme, l10n, asset);
        }

        return ListView.builder(
          padding: AtharSpacing.allXl,
          itemCount: services.length + 1,
          itemBuilder: (context, index) {
            if (index == services.length) {
              return Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddServiceSheet(context, asset),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.assetDetailsDefineService),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurface,
                    elevation: 0,
                  ),
                ),
              );
            }
            return _buildServiceCard(
              context,
              colorScheme,
              l10n,
              services[index],
            );
          },
        );
      },
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    ServiceModel service,
  ) {
    String nextDueText = l10n.assetServiceStatusPending;
    Color statusColor = Colors.grey;
    if (service.nextDueDate != null) {
      final diff = service.nextDueDate!.difference(DateTime.now()).inDays;
      if (diff < 0) {
        nextDueText = l10n.assetServiceOverdue(diff.abs());
        statusColor = Colors.red;
      } else {
        nextDueText = l10n.assetDaysRemaining(diff);
        statusColor = diff < 7 ? Colors.orange : Colors.green;
      }
    }
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AtharRadii.card),
      child: Padding(
        padding: AtharSpacing.allXl,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    if (service.nextDueOdometer != null)
                      Text(
                        l10n.assetServiceAtOdometer(service.nextDueOdometer!),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: AtharRadii.radiusSm,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    nextDueText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<AssetsCubit>(),
                          child: ServiceLogsPage(
                            serviceId: service.uuid,
                            serviceName: service.name,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.history,
                    size: 16.sp,
                    color: colorScheme.outline,
                  ),
                  label: Text(
                    l10n.assetServiceLogButton,
                    style: TextStyle(
                      color: colorScheme.outline,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddServiceLogSheet(
                        serviceId: service.uuid,
                        serviceName: service.name,
                      ),
                    );
                  },
                  icon: Icon(Icons.check_circle_outline, size: 16.sp),
                  label: Text(l10n.assetServiceRecordButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyServicesState(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AssetModel asset,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings_suggest_outlined,
            size: 60.sp,
            color: colorScheme.outlineVariant,
          ),
          AtharGap.lg,
          Text(
            l10n.assetServicesEmpty,
            style: TextStyle(fontSize: 16.sp, color: colorScheme.outline),
          ),
          AtharGap.xl,
          ElevatedButton(
            onPressed: () => _showAddServiceSheet(context, asset),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(l10n.assetServicesDefineExample),
          ),
        ],
      ),
    );
  }

  void _showAddServiceSheet(BuildContext context, AssetModel asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddServiceSheet(assetId: asset.uuid),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
    AssetModel asset,
    ModuleModel? module,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.assetDeleteTitle),
        content: Text(l10n.assetDeleteConfirm),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: () {
              context.read<AssetsCubit>().deleteAsset(
                asset.id,
                spaceId: asset.spaceId,
                module: module,
              );
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.assetDeleteSuccess)));
            },
          ),
        ],
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'dart:io';
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/iam/permission_service.dart';
// import 'package:athar/features/assets/data/models/asset_model.dart';
// import 'package:athar/features/assets/data/models/service_model.dart';
// import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
// import 'package:athar/features/assets/presentation/cubit/assets_state.dart';
// import 'package:athar/features/assets/presentation/pages/service_logs_page.dart';
// import 'package:athar/features/assets/presentation/widgets/add_service_log_sheet.dart';
// import 'package:athar/features/assets/presentation/widgets/add_service_sheet.dart';
// import 'package:athar/features/space/data/models/module_model.dart'; // ✅
// import 'package:athar/features/space/presentation/cubit/module_cubit.dart'; // ✅
// import 'package:athar/features/space/presentation/cubit/space_cubit.dart';
// import 'package:athar/features/space/presentation/cubit/space_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:open_filex/open_filex.dart';

// class AssetDetailsPage extends StatefulWidget {
//   final AssetModel asset;

//   const AssetDetailsPage({super.key, required this.asset});

//   @override
//   State<AssetDetailsPage> createState() => _AssetDetailsPageState();
// }

// class _AssetDetailsPageState extends State<AssetDetailsPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   // ✅ كاش محلي للصلاحيات لمنع تكرار الطلبات في كل Build
//   late Future<bool> _canEditFuture;
//   late Future<bool> _canDeleteFuture;
//   ModuleModel? _targetModule;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _initPermissions();
//   }

//   void _initPermissions() {
//     final permissionService = getIt<PermissionService>();

//     // حساب إعدادات المساحة والموديول (نحسبها مرة واحدة عند البداية)
//     bool allowSpaceDelegation = false;
//     ModuleModel? targetModule;

//     try {
//       final spaceState = context.read<SpaceCubit>().state;
//       if (spaceState is SpaceLoaded && spaceState.selectedSpace != null) {
//         allowSpaceDelegation = spaceState.selectedSpace!.allowMemberDelegation;
//       }

//       if (widget.asset.moduleId != null) {
//         final moduleState = context.read<ModuleCubit>().state;
//         if (moduleState is ModuleLoaded) {
//           targetModule = moduleState.modules.firstWhere(
//             (m) => m.uuid == widget.asset.moduleId,
//             orElse: () => ModuleModel()..uuid = 'dummy',
//           );
//           if (targetModule.uuid == 'dummy') targetModule = null;
//         }
//       }
//     } catch (_) {}

//     // ✅ تهيئة المستقبلات (Futures)
//     _canEditFuture = permissionService.canEdit(
//       'asset',
//       spaceId: widget.asset.spaceId,
//       module: targetModule,
//       allowSpaceDelegation: allowSpaceDelegation,
//     );

//     _canDeleteFuture = permissionService.canDelete(
//       'asset',
//       spaceId: widget.asset.spaceId,
//       module: targetModule,
//       allowSpaceDelegation: allowSpaceDelegation,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AssetsCubit, AssetsState>(
//       builder: (context, state) {
//         // تحديث الأصل
//         AssetModel currentAsset = widget.asset;
//         if (state is AssetsLoaded) {
//           try {
//             currentAsset = state.assets.firstWhere(
//               (a) => a.uuid == widget.asset.uuid,
//             );
//           } catch (_) {
//             return const Scaffold(
//               body: Center(child: Text("لم يتم العثور على الأصل")),
//             );
//           }
//         }

//         return Scaffold(
//           backgroundColor: AppColors.background,
//           appBar: AppBar(
//             title: Text(
//               currentAsset.name,
//               style: const TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             centerTitle: true,
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             foregroundColor: AppColors.textPrimary,
//             actions: [
//               // ✅ 3. استخدام التوقيع الجديد للتحقق من الصلاحيات
//               // زر التعديل
//               // ✅ الإصلاح: استخدام FutureBuilder لزر التعديل
//               FutureBuilder<bool>(
//                 future: _canEditFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.data == true) {
//                     return IconButton(
//                       icon: const Icon(Icons.edit_outlined),
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("قريباً...")),
//                         );
//                       },
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),

//               // زر الحذف
//               // ✅ الإصلاح: استخدام FutureBuilder لزر الحذف
//               FutureBuilder<bool>(
//                 future: _canDeleteFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.data == true) {
//                     return IconButton(
//                       icon: const Icon(Icons.delete_outline, color: Colors.red),
//                       onPressed: () =>
//                           _confirmDelete(context, currentAsset, _targetModule),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ],
//             bottom: TabBar(
//               controller: _tabController,
//               labelColor: AppColors.primary,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: AppColors.primary,
//               labelStyle: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14.sp,
//               ),
//               tabs: const [
//                 Tab(text: "نظرة عامة"),
//                 Tab(text: "سجل الصيانة"),
//               ],
//             ),
//           ),
//           body: TabBarView(
//             controller: _tabController,
//             children: [
//               _buildOverviewTab(context, currentAsset),
//               _buildMaintenanceTab(context, currentAsset),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ===========================================================================
//   // دوال العرض المساعدة (نسخ كما هي من الكود السابق، لا تغيير جوهري)
//   // ===========================================================================
//   Widget _buildOverviewTab(BuildContext context, AssetModel asset) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildWarrantyCard(asset),
//           SizedBox(height: 16.h),
//           _buildAttachmentsSection(context, asset),
//           SizedBox(height: 16.h),
//           _buildInfoCard(asset),
//           SizedBox(height: 16.h),
//           if (asset.notes != null && asset.notes!.isNotEmpty)
//             _buildSectionTitle("ملاحظات"),
//           if (asset.notes != null && asset.notes!.isNotEmpty)
//             Container(
//               width: double.infinity,
//               margin: EdgeInsets.only(top: 8.h),
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12.r),
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: Text(
//                 asset.notes!,
//                 style: TextStyle(fontSize: 14.sp, height: 1.5),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWarrantyCard(AssetModel asset) {
//     final status = asset.status;
//     Color color;
//     String text;
//     double progress = 0.0;
//     final totalDays = asset.warrantyMonths * 30;
//     final remaining = asset.daysRemaining;
//     final usedDays = totalDays - remaining;

//     if (totalDays > 0) {
//       progress = (usedDays / totalDays).clamp(0.0, 1.0);
//     }

//     switch (status) {
//       case AssetWarrantyStatus.active:
//         color = Colors.green;
//         text = "الضمان ساري";
//         break;
//       case AssetWarrantyStatus.expiringSoon:
//         color = Colors.orange;
//         text = "ينتهي قريباً!";
//         break;
//       case AssetWarrantyStatus.expired:
//         color = Colors.red;
//         text = "الضمان منتهي";
//         progress = 1.0;
//         break;
//     }

//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 text,
//                 style: TextStyle(
//                   color: color,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16.sp,
//                 ),
//               ),
//               Text(
//                 remaining > 0 ? "باقي $remaining يوم" : "0 يوم",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(6),
//             child: LinearProgressIndicator(
//               value: progress,
//               backgroundColor: Colors.grey.shade100,
//               color: color,
//               minHeight: 10.h,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 DateFormat('yyyy-MM-dd').format(asset.purchaseDate),
//                 style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//               ),
//               Text(
//                 DateFormat('yyyy-MM-dd').format(asset.warrantyExpiryDate),
//                 style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttachmentsSection(BuildContext context, AssetModel asset) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _buildSectionTitle("الفواتير والصور"),
//             TextButton.icon(
//               onPressed: () {
//                 final spaceType = asset.spaceId != null ? 'shared' : 'personal';
//                 context.read<AssetsCubit>().pickAndAddAssetImage(
//                   asset,
//                   spaceType: spaceType,
//                 );
//               },
//               icon: Icon(Icons.add_a_photo, size: 16.sp),
//               label: const Text("إضافة"),
//             ),
//           ],
//         ),
//         SizedBox(height: 8.h),
//         SizedBox(
//           height: 100.h,
//           child: asset.attachments.isEmpty
//               ? _buildEmptyAttachments()
//               : ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: asset.attachments.length,
//                   separatorBuilder: (c, i) => SizedBox(width: 12.w),
//                   itemBuilder: (context, index) {
//                     final file = asset.attachments.elementAt(index);
//                     return GestureDetector(
//                       onTap: () {
//                         if (file.localPath != null) {
//                           OpenFilex.open(file.localPath!);
//                         }
//                       },
//                       child: Container(
//                         width: 100.w,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           border: Border.all(color: Colors.grey.shade300),
//                           image:
//                               file.localPath != null &&
//                                   File(file.localPath!).existsSync()
//                               ? DecorationImage(
//                                   image: FileImage(File(file.localPath!)),
//                                   fit: BoxFit.cover,
//                                 )
//                               : null,
//                         ),
//                         child:
//                             file.localPath == null ||
//                                 !File(file.localPath!).existsSync()
//                             ? const Center(
//                                 child: Icon(
//                                   Icons.insert_drive_file,
//                                   color: Colors.grey,
//                                 ),
//                               )
//                             : null,
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyAttachments() {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: Colors.grey.shade200,
//           style: BorderStyle.solid,
//         ),
//       ),
//       child: Center(
//         child: Text(
//           "لا توجد صور للفاتورة أو الجهاز",
//           style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(AssetModel asset) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionTitle("التفاصيل"),
//         SizedBox(height: 8.h),
//         Container(
//           padding: EdgeInsets.all(16.w),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             border: Border.all(color: Colors.grey.shade100),
//           ),
//           child: Column(
//             children: [
//               _buildInfoRow(Icons.category, "الفئة", asset.category ?? "-"),
//               Divider(height: 24.h),
//               _buildInfoRow(Icons.store, "المتجر/البائع", asset.vendor ?? "-"),
//               Divider(height: 24.h),
//               _buildInfoRow(Icons.qr_code, "S/N", asset.serialNumber ?? "-"),
//               Divider(height: 24.h),
//               _buildInfoRow(
//                 Icons.attach_money,
//                 "السعر",
//                 asset.price != null ? "${asset.price} ريال" : "-",
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, size: 18.sp, color: Colors.grey),
//         SizedBox(width: 8.w),
//         Text(
//           label,
//           style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
//         ),
//         const Spacer(),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontFamily: 'Tajawal',
//         fontWeight: FontWeight.bold,
//         fontSize: 16.sp,
//       ),
//     );
//   }

//   Widget _buildMaintenanceTab(BuildContext context, AssetModel asset) {
//     return StreamBuilder<List<ServiceModel>>(
//       stream: context.read<AssetsCubit>().watchServices(asset.uuid),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         final services = snapshot.data ?? [];
//         if (services.isEmpty) return _buildEmptyServicesState(context, asset);

//         return ListView.builder(
//           padding: EdgeInsets.all(16.w),
//           itemCount: services.length + 1,
//           itemBuilder: (context, index) {
//             if (index == services.length) {
//               return Padding(
//                 padding: EdgeInsets.only(top: 16.h),
//                 child: ElevatedButton.icon(
//                   onPressed: () => _showAddServiceSheet(context, asset),
//                   icon: const Icon(Icons.add),
//                   label: const Text("تعريف خدمة جديدة"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey.shade100,
//                     foregroundColor: Colors.black,
//                     elevation: 0,
//                   ),
//                 ),
//               );
//             }
//             return _buildServiceCard(context, services[index]);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildServiceCard(BuildContext context, ServiceModel service) {
//     String nextDueText = "غير محدد (بانتظار أول سجل)";
//     Color statusColor = Colors.grey;
//     if (service.nextDueDate != null) {
//       final diff = service.nextDueDate!.difference(DateTime.now()).inDays;
//       if (diff < 0) {
//         nextDueText = "متأخر بـ ${diff.abs()} يوم!";
//         statusColor = Colors.red;
//       } else {
//         nextDueText = "باقي $diff يوم";
//         statusColor = diff < 7 ? Colors.orange : Colors.green;
//       }
//     }
//     return Card(
//       margin: EdgeInsets.only(bottom: 12.h),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       child: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       service.name,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16.sp,
//                       ),
//                     ),
//                     if (service.nextDueOdometer != null)
//                       Text(
//                         "عند عداد: ${service.nextDueOdometer} كم",
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                   ],
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 10.w,
//                     vertical: 4.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: statusColor.withValues(alpha: 0.5),
//                     ),
//                   ),
//                   child: Text(
//                     nextDueText,
//                     style: TextStyle(
//                       color: statusColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Divider(height: 24.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton.icon(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => BlocProvider.value(
//                           value: context.read<AssetsCubit>(),
//                           child: ServiceLogsPage(
//                             serviceId: service.uuid,
//                             serviceName: service.name,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   icon: Icon(Icons.history, size: 16.sp, color: Colors.grey),
//                   label: Text(
//                     "السجل",
//                     style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       backgroundColor: Colors.transparent,
//                       builder: (context) => AddServiceLogSheet(
//                         serviceId: service.uuid,
//                         serviceName: service.name,
//                       ),
//                     );
//                   },
//                   icon: Icon(Icons.check_circle_outline, size: 16.sp),
//                   label: const Text("تسجيل صيانة"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 8.h,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyServicesState(BuildContext context, AssetModel asset) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.settings_suggest_outlined,
//             size: 60.sp,
//             color: Colors.grey.shade300,
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             "لم يتم تعريف أي خدمات صيانة",
//             style: TextStyle(fontSize: 16.sp, color: Colors.grey),
//           ),
//           SizedBox(height: 24.h),
//           ElevatedButton(
//             onPressed: () => _showAddServiceSheet(context, asset),
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//             child: const Text(
//               "تعريف خدمة (مثل: غيار زيت)",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddServiceSheet(BuildContext context, AssetModel asset) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => AddServiceSheet(assetId: asset.uuid),
//     );
//   }

//   // ✅ 4. تحديث دالة الحذف لتمرير الموديول
//   void _confirmDelete(
//     BuildContext context,
//     AssetModel asset,
//     ModuleModel? module,
//   ) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("حذف الأصل"),
//         content: const Text(
//           "هل أنت متأكد؟ سيتم حذف جميع الفواتير والسجلات المرتبطة.",
//         ),
//         actions: [
//           TextButton(
//             child: const Text("إلغاء"),
//             onPressed: () => Navigator.pop(ctx),
//           ),
//           TextButton(
//             child: const Text("حذف", style: TextStyle(color: Colors.red)),
//             onPressed: () {
//               context.read<AssetsCubit>().deleteAsset(
//                 asset.id,
//                 spaceId: asset.spaceId,
//                 module: module, // ✅ تمرير الموديول للكيوبت
//               );
//               Navigator.pop(ctx);
//               Navigator.pop(context);
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(const SnackBar(content: Text("تم الحذف")));
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
