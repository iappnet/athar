import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/health/presentation/widgets/add_vital_sheet.dart';
import 'package:athar/features/health/data/models/vital_sign_model.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class VitalsPage extends StatefulWidget {
  final String moduleId;
  final String moduleName;

  const VitalsPage({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  State<VitalsPage> createState() => _VitalsPageState();
}

class _VitalsPageState extends State<VitalsPage> {
  late HealthCubit _cubit;
  String _selectedFilter =
      'all'; // all, weight, temp, pressure, sugar, document

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HealthCubit>();
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
            l10n.vitalsPageTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: colors.surface,
          elevation: 0,
          foregroundColor: colors.onSurface,
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: StreamBuilder<List<VitalSignModel>>(
                stream: _cubit.watchVitals(widget.moduleId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allRecords = snapshot.data ?? [];
                  final records = allRecords.where((r) {
                    if (_selectedFilter == 'all') return true;
                    if (_selectedFilter == 'document') {
                      return r.category == 'document';
                    }
                    return r.vitalType == _selectedFilter;
                  }).toList();

                  if (records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monitor_heart_outlined,
                            size: 60.sp,
                            color: colors.outlineVariant,
                          ),
                          AtharGap.md,
                          Text(
                            l10n.vitalsEmptyState,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: AtharSpacing.allLg,
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      return _buildRecordCard(records[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) =>
                  AddVitalSheet(moduleId: widget.moduleId, cubit: _cubit),
            );
          },
          backgroundColor: colors.primary,
          icon: const Icon(Icons.add_chart),
          label: Text(
            l10n.vitalsNewButton,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 60.h,
      color: colors.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        children: [
          _buildFilterChip('all', l10n.vitalsFilterAll),
          _buildFilterChip('weight', l10n.vitalsFilterWeight),
          _buildFilterChip('temp', l10n.vitalsFilterTemp),
          _buildFilterChip('pressure', l10n.vitalsFilterPressure),
          _buildFilterChip('sugar', l10n.vitalsFilterSugar),
          _buildFilterChip('document', l10n.vitalsFilterDocuments),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _selectedFilter == key;

    return Padding(
      padding: EdgeInsetsDirectional.only(start: 8.w),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: colors.primary.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: isSelected ? colors.primary : colors.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? colors.primary : colors.outlineVariant,
        ),
        onSelected: (val) => setState(() => _selectedFilter = key),
      ),
    );
  }

  Widget _buildRecordCard(VitalSignModel record) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final isVital = record.category == 'vital';

    IconData icon;
    Color color;
    String title;
    String valueText = "";

    if (isVital) {
      switch (record.vitalType) {
        case 'weight':
          icon = Icons.monitor_weight_outlined;
          color = context.colors.accentBlue;
          title = l10n.vitalsFilterWeight;
          break;
        case 'temp':
          icon = Icons.thermostat;
          color = context.colors.accentRed;
          title = l10n.vitalsFilterTemp;
          break;
        case 'pressure':
          icon = Icons.speed;
          color = context.colors.accentPurple;
          title = l10n.vitalsFilterPressure;
          break;
        case 'sugar':
          icon = Icons.bloodtype;
          color = context.colors.accentPink;
          title = l10n.vitalsFilterSugar;
          break;
        default:
          icon = Icons.favorite_border;
          color = context.colors.accentNeutral;
          title = l10n.vitalsIndicatorGeneric;
      }
      valueText = "${record.vitalValue} ${record.vitalUnit ?? ''}";
    } else {
      icon = Icons.description_outlined;
      color = context.colors.accentOrange;
      title = l10n.vitalsNoteDocument;
      valueText = record.title ?? l10n.vitalsNoTitle;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: AtharSpacing.allLg,
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
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('MMM d, hh:mm a').format(record.recordDate),
            style: TextStyle(
              fontSize: 12.sp,
              color: colors.outlineVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

