import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/assets/data/models/asset_model.dart';
import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
import 'package:athar/features/assets/presentation/cubit/assets_state.dart';
import 'package:athar/features/assets/presentation/pages/asset_details_page.dart';
import 'package:athar/features/assets/presentation/widgets/add_asset_sheet.dart';
import 'package:athar/features/assets/presentation/widgets/asset_card.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssetsPage extends StatefulWidget {
  final ModuleModel? module;

  const AssetsPage({super.key, this.module});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AssetsCubit>().watchAssets(moduleId: widget.module?.uuid);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final title = widget.module != null
        ? widget.module!.name
        : l10n.assetsPageTitle;

    return BlocListener<AssetsCubit, AssetsState>(
      listener: (context, state) {
        if (state is AssetOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context
              .read<AssetsCubit>()
              .watchAssets(moduleId: widget.module?.uuid);
        } else if (state is AssetsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final state = context.read<AssetsCubit>().state;
              if (state is AssetsLoaded && state.assets.isNotEmpty) {
                showSearch(
                  context: context,
                  delegate: AssetsSearchDelegate(state.assets, l10n),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.assetsNoSearchResults)),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<AssetsCubit, AssetsState>(
        builder: (context, state) {
          if (state is AssetsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AssetsLoaded) {
            final assets = state.assets;

            if (assets.isEmpty) {
              return _buildEmptyState(colorScheme, l10n);
            }

            return GridView.builder(
              padding: AtharSpacing.allXl,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                return AssetCard(
                  asset: assets[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AssetDetailsPage(asset: assets[index]),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is AssetsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAssetSheet(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(
          l10n.assetsAddButton,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80.sp,
            color: colorScheme.outlineVariant,
          ),
          AtharGap.lg,
          Text(
            l10n.assetsEmptyTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.outline,
            ),
          ),
          AtharGap.sm,
          Text(
            l10n.assetsEmptySubtitle,
            style: TextStyle(fontSize: 14.sp, color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  void _showAddAssetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAssetSheet(
        spaceId: widget.module?.spaceId,
        moduleId: widget.module?.uuid,
      ),
    );
  }
}

class AssetsSearchDelegate extends SearchDelegate {
  final List<AssetModel> assets;
  final AppLocalizations l10n;

  AssetsSearchDelegate(this.assets, this.l10n);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final results = assets.where((asset) {
      final q = query.toLowerCase();
      return asset.name.toLowerCase().contains(q) ||
          (asset.category?.toLowerCase().contains(q) ?? false) ||
          (asset.vendor?.toLowerCase().contains(q) ?? false);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          l10n.assetsSearchNoMatch,
          style: TextStyle(fontSize: 16.sp, color: colorScheme.outline),
        ),
      );
    }

    return GridView.builder(
      padding: AtharSpacing.allXl,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return AssetCard(
          asset: results[index],
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssetDetailsPage(asset: results[index]),
              ),
            );
          },
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/assets/data/models/asset_model.dart';
// import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
// import 'package:athar/features/assets/presentation/cubit/assets_state.dart';
// import 'package:athar/features/assets/presentation/pages/asset_details_page.dart';
// import 'package:athar/features/assets/presentation/widgets/add_asset_sheet.dart';
// import 'package:athar/features/assets/presentation/widgets/asset_card.dart';
// import 'package:athar/features/space/data/models/module_model.dart'; // ✅ استيراد
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class AssetsPage extends StatefulWidget {
//   // ✅ التعديل: نستقبل الموديول كاملاً (اختياري)
//   final ModuleModel? module;

//   const AssetsPage({super.key, this.module});

//   @override
//   State<AssetsPage> createState() => _AssetsPageState();
// }

// class _AssetsPageState extends State<AssetsPage> {
//   @override
//   void initState() {
//     super.initState();
//     // ✅ مراقبة الأصول بناءً على معرف الموديول
//     context.read<AssetsCubit>().watchAssets(moduleId: widget.module?.uuid);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // تحديد العنوان بناءً على السياق
//     final title = widget.module != null ? widget.module!.name : "خزينة الأصول";

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text(
//           title,
//           style: const TextStyle(
//             fontFamily: 'Tajawal',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: AppColors.textPrimary,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               final state = context.read<AssetsCubit>().state;
//               if (state is AssetsLoaded && state.assets.isNotEmpty) {
//                 showSearch(
//                   context: context,
//                   delegate: AssetsSearchDelegate(state.assets),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("لا توجد أصول للبحث عنها")),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: BlocBuilder<AssetsCubit, AssetsState>(
//         builder: (context, state) {
//           if (state is AssetsLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is AssetsLoaded) {
//             final assets = state.assets;

//             if (assets.isEmpty) {
//               return _buildEmptyState();
//             }

//             return GridView.builder(
//               padding: EdgeInsets.all(16.w),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 0.75,
//                 crossAxisSpacing: 16.w,
//                 mainAxisSpacing: 16.h,
//               ),
//               itemCount: assets.length,
//               itemBuilder: (context, index) {
//                 return AssetCard(
//                   asset: assets[index],
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             AssetDetailsPage(asset: assets[index]),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           } else if (state is AssetsError) {
//             return Center(child: Text(state.message));
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showAddAssetSheet(context),
//         backgroundColor: AppColors.primary,
//         icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
//         label: const Text(
//           "إضافة أصل",
//           style: TextStyle(color: Colors.white, fontFamily: 'Tajawal'),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inventory_2_outlined,
//             size: 80.sp,
//             color: Colors.grey.shade300,
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             "خزينتك فارغة",
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade600,
//               fontFamily: 'Tajawal',
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             "أضف فواتيرك وضماناتك لترتاح بالك",
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddAssetSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       // ✅ تمرير الموديول والمساحة للشيت لضمان الحفظ الصحيح
//       builder: (context) => AddAssetSheet(
//         spaceId: widget.module?.spaceId,
//         moduleId: widget.module?.uuid,
//       ),
//     );
//   }
// }

// class AssetsSearchDelegate extends SearchDelegate {
//   final List<AssetModel> assets;

//   AssetsSearchDelegate(this.assets);

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () => close(context, null),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return _buildSearchResults(context);
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return _buildSearchResults(context);
//   }

//   Widget _buildSearchResults(BuildContext context) {
//     final results = assets.where((asset) {
//       final q = query.toLowerCase();
//       return asset.name.toLowerCase().contains(q) ||
//           (asset.category?.toLowerCase().contains(q) ?? false) ||
//           (asset.vendor?.toLowerCase().contains(q) ?? false);
//     }).toList();

//     if (results.isEmpty) {
//       return Center(
//         child: Text(
//           "لا توجد نتائج مطابقة",
//           style: TextStyle(fontSize: 16.sp, color: Colors.grey),
//         ),
//       );
//     }

//     return GridView.builder(
//       padding: EdgeInsets.all(16.w),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.75,
//         crossAxisSpacing: 16.w,
//         mainAxisSpacing: 16.h,
//       ),
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         return AssetCard(
//           asset: results[index],
//           onTap: () {
//             close(context, null);
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AssetDetailsPage(asset: results[index]),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   ThemeData appBarTheme(BuildContext context) {
//     return Theme.of(context).copyWith(
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       inputDecorationTheme: const InputDecorationTheme(
//         border: InputBorder.none,
//         hintStyle: TextStyle(fontFamily: 'Tajawal'),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
