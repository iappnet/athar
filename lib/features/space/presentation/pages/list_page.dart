import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/features/space/data/models/list_item_model.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/presentation/cubit/list_cubit.dart';
import 'package:athar/features/space/presentation/cubit/list_state.dart';
import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
import 'package:athar/features/space/presentation/pages/list_history_page.dart';
import 'package:athar/features/space/presentation/widgets/add_list_item_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class ListPage extends StatefulWidget {
  final ModuleModel module;

  const ListPage({super.key, required this.module});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ListCubit>().setContext(widget.module);
    context.read<ListCubit>().watchListItems(widget.module.uuid);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.module.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        actions: [
          // زر الأرشيف
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.listPageHistoryTooltip,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListHistoryPage(
                    moduleId: widget.module.uuid,
                    moduleName: widget.module.name,
                  ),
                ),
              );
            },
          ),

          // زر الخيارات
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _confirmReset(context);
              } else if (value == 'duplicate') {
                // ✅ خيار التكرار
                _showDuplicateDialog(context);
              }
            },
            itemBuilder: (context) => [
              // خيار التكرار (حفظ كقالب)
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: colorScheme.primary),
                    AtharGap.hSm,
                    Text(l10n.listPageDuplicateOption),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: context.colors.accentOrange),
                    AtharGap.hSm,
                    Text(l10n.listPageResetOption),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<ListCubit, ListState>(
        // ✅ استماع للأخطاء
        listener: (context, state) {
          if (state is ListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ListCubit, ListState>(
                builder: (context, state) {
                  if (state is ListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ListLoaded) {
                    final items = state.items;
                    if (items.isEmpty) {
                      return _buildEmptyState(colorScheme, l10n);
                    }

                    return ListView.builder(
                      padding: EdgeInsetsDirectional.only(
                        bottom: 80.h,
                        top: 10.h,
                        start: AtharSpacing.md,
                        end: AtharSpacing.md,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildListItem(items[index], colorScheme, l10n);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildQuickInputArea(colorScheme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    ListItemModel item,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final isChecked = item.isChecked;

    return Dismissible(
      key: Key(item.uuid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsetsDirectional.only(start: 20.w),
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      onDismissed: (direction) {
        // ✅ 2. التصحيح: تمرير الكائن كاملاً للحذف
        context.read<ListCubit>().deleteItem(item);
      },
      child: Card(
        elevation: isChecked ? 0 : 2,
        color: isChecked
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.card),
        margin: EdgeInsets.only(bottom: 8.h),
        child: ListTile(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddListItemSheet(
                moduleId: widget.module.uuid,
                itemToEdit: item,
              ),
            );
          },
          leading: Checkbox(
            value: isChecked,
            activeColor: colorScheme.outline,
            shape: RoundedRectangleBorder(
              borderRadius: AtharRadii.radiusXxs,
            ),
            onChanged: (val) {
              context.read<ListCubit>().toggleItem(item);
            },
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16.sp,
              decoration: isChecked ? TextDecoration.lineThrough : null,
              color: isChecked ? colorScheme.outline : colorScheme.onSurface,
            ),
          ),
          subtitle:
              (item.quantity > 1 ||
                  item.unit != null ||
                  item.repeatEveryDays != null)
              ? Row(
                  children: [
                    if (item.quantity > 1 || item.unit != null)
                      Text(
                        "${item.quantity} ${item.unit ?? ''}",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    if (item.repeatEveryDays != null) ...[
                      AtharGap.hSm,
                      Icon(Icons.repeat, size: 12.sp, color: context.colors.accentOrange),
                      Text(
                        l10n.listPageRepeatEvery(
                          item.repeatEveryDays.toString(),
                        ),
                        style: TextStyle(fontSize: 10.sp, color: context.colors.accentOrange),
                      ),
                    ],
                  ],
                )
              : null,
          trailing: !isChecked
              ? Icon(
                  Icons.edit_outlined,
                  size: 16.sp,
                  color: colorScheme.outline,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildQuickInputArea(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AtharSpacing.md,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      AddListItemSheet(moduleId: widget.module.uuid),
                );
              },
              icon: Icon(Icons.tune, color: colorScheme.primary),
              tooltip: l10n.listPageAdvancedTooltip,
            ),
            AtharGap.hSm,
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.listPageQuickAddHint,
                  hintStyle: TextStyle(color: colorScheme.outline),
                  border: OutlineInputBorder(
                    borderRadius: AtharRadii.radiusXxxl,
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addItem(),
              ),
            ),
            AtharGap.hSm,
            FloatingActionButton.small(
              onPressed: _addItem,
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.arrow_upward, color: colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() {
    if (_controller.text.trim().isNotEmpty) {
      context.read<ListCubit>().addItem(
        moduleId: widget.module.uuid,
        name: _controller.text,
      );
      _controller.clear();
    }
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 60.sp,
            color: colorScheme.outlineVariant,
          ),
          AtharGap.lg,
          Text(
            l10n.listPageEmptyTitle,
            style: TextStyle(color: colorScheme.outline, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.listPageResetTitle),
        content: Text(l10n.listPageResetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.listPageCancel),
          ),
          TextButton(
            onPressed: () {
              final state = context.read<ListCubit>().state;
              if (state is ListLoaded) {
                context.read<ListCubit>().resetList(state.items);
              }
              Navigator.pop(ctx);
            },
            child: Text(
              l10n.listPageResetAction,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDuplicateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final nameController = TextEditingController(
      text: l10n.listPageDuplicateDefaultName(widget.module.name),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.listPageDuplicateTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.listPageDuplicateDescription,
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
            AtharGap.lg,
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.listPageNewListNameLabel,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.listPageCancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newModuleId = const Uuid().v4();
                context.read<ModuleCubit>().createModule(
                  widget.module.spaceId,
                  nameController.text,
                  'list',
                  uuid: newModuleId,
                );
                context.read<ListCubit>().copyList(
                  sourceModuleId: widget.module.uuid,
                  targetModuleId: newModuleId,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.listPageDuplicateSuccess)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
            ),
            child: Text(
              l10n.listPageDuplicateAction,
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
