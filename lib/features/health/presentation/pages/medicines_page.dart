import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/health/presentation/cubit/health_state.dart';
import 'package:athar/features/health/presentation/widgets/add_medicine_sheet.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/di/injection.dart';

class MedicinesPage extends StatefulWidget {
  final String moduleId;
  final String moduleName;

  const MedicinesPage({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  State<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HealthCubit _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cubit = getIt<HealthCubit>();
    _cubit.subscribeToMedicines(widget.moduleId);
  }

  @override
  void dispose() {
    _cubit.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Text(
            l10n.medicinesPageTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: colors.surface,
          elevation: 0,
          foregroundColor: colors.onSurface,
          bottom: TabBar(
            controller: _tabController,
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            indicatorColor: colors.primary,
            tabs: [
              Tab(text: l10n.medicinesTabActive),
              Tab(text: l10n.medicinesTabArchive),
            ],
          ),
        ),
        body: BlocListener<HealthCubit, HealthState>(
          listener: (context, state) {
            if (state is HealthOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colors.primary,
                ),
              );
            } else if (state is HealthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colors.error,
                ),
              );
            }
          },
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMedicinesList(isActive: true),
              _buildMedicinesList(isActive: false),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) =>
                  AddMedicineSheet(moduleId: widget.moduleId, cubit: _cubit),
            );
          },
          backgroundColor: colors.primary,
          icon: const Icon(Icons.add),
          label: Text(
            l10n.medicinesNewButton,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicinesList({required bool isActive}) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<HealthCubit, HealthState>(
      buildWhen: (previous, current) =>
          current is HealthMedicinesLoaded || current is HealthLoading,
      builder: (context, state) {
        if (state is HealthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<MedicineModel> medicines = [];
        if (state is HealthMedicinesLoaded) {
          medicines = state.medicines;
        }

        final filteredMedicines = medicines
            .where((m) => m.isActive == isActive)
            .toList();

        if (filteredMedicines.isEmpty) {
          if (state is! HealthLoading && state is! HealthMedicinesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive
                      ? Icons.medication_liquid_outlined
                      : Icons.archive_outlined,
                  size: 60.sp,
                  color: colors.outlineVariant,
                ),
                AtharGap.md,
                Text(
                  isActive
                      ? l10n.medicinesEmptyActive
                      : l10n.medicinesEmptyArchive,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: AtharSpacing.allLg,
          itemCount: filteredMedicines.length,
          separatorBuilder: (c, i) => AtharGap.md,
          itemBuilder: (context, index) {
            return _buildMedicineCard(filteredMedicines[index]);
          },
        );
      },
    );
  }

  Widget _buildMedicineCard(MedicineModel medicine) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    IconData icon;
    Color color;
    switch (medicine.type) {
      case 'syrup':
        icon = Icons.local_drink_rounded;
        color = context.colors.accentOrange;
        break;
      case 'injection':
        icon = Icons.vaccines_rounded;
        color = context.colors.accentRed;
        break;
      default:
        icon = Icons.medication_rounded;
        color = context.colors.accentBlue;
    }

    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: AtharShadows.card,
      ),
      child: Row(
        children: [
          Container(
            padding: AtharSpacing.allMd,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          AtharGap.hLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AtharGap.xs,
                if (medicine.schedulingType == 'fixed')
                  Wrap(
                    spacing: 4.w,
                    children:
                        medicine.fixedTimeSlots
                            ?.map((time) => _buildTag(time))
                            .toList() ??
                        [],
                  )
                else
                  _buildTag(
                    l10n.medicinesEveryHours(medicine.intervalHours ?? 0),
                    isInterval: true,
                  ),
              ],
            ),
          ),
          if (medicine.isActive) ...[
            IconButton(
              tooltip: 'تسجيل الجرعة',
              icon: Icon(Icons.check_circle_outline_rounded,
                  color: context.colors.success),
              onPressed: () =>
                  _cubit.takeDose(widget.moduleId, medicine),
            ),
            IconButton(
              tooltip: 'تخطي الجرعة',
              icon: Icon(Icons.cancel_outlined,
                  color: colors.outline),
              onPressed: () =>
                  _cubit.skipDose(widget.moduleId, medicine),
            ),
          ],
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _cubit.deleteMedicine(medicine);
              } else if (value == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddMedicineSheet(
                    moduleId: widget.moduleId,
                    cubit: _cubit,
                    medicineToEdit: medicine,
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text(l10n.medicinesMenuEdit)),
              PopupMenuItem(
                value: 'archive',
                child: Text(
                  medicine.isActive
                      ? l10n.medicinesMenuArchive
                      : l10n.medicinesMenuReactivate,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  l10n.medicinesMenuDelete,
                  style: TextStyle(color: colors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {bool isInterval = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isInterval
            ? context.colors.accentOrange.withValues(alpha: 0.1)
            : context.colors.accentBlue.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusSm,
        border: Border.all(
          color: isInterval
              ? context.colors.accentOrange.withValues(alpha: 0.3)
              : context.colors.accentBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: isInterval ? context.colors.accentOrange : context.colors.accentBlue,
        ),
      ),
    );
  }
}

