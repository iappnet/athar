import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/services/location_service.dart';
import 'package:athar/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Semantic colors (not in ColorScheme)
const _successColor = Color(0xFF00B894);

class LocationSettingsPage extends StatefulWidget {
  const LocationSettingsPage({super.key});

  @override
  State<LocationSettingsPage> createState() => _LocationSettingsPageState();
}

class _LocationSettingsPageState extends State<LocationSettingsPage> {
  final _cityController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = "";

  // استخدام GPS
  Future<void> _useGPS() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _statusMessage = l10n.detectingLocation;
    });
    try {
      final locationService = getIt<LocationService>();
      final position = await locationService.getCurrentLocation();

      if (position != null) {
        final cityName = await locationService.getCityName(
          position.latitude,
          position.longitude,
        );
        await _saveLocation(
          position.latitude,
          position.longitude,
          cityName ?? l10n.myCurrentLocation,
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = l10n.locationDetectionFailed(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // البحث اليدوي
  Future<void> _searchCity() async {
    if (_cityController.text.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _statusMessage = l10n.searching;
    });
    try {
      final locationService = getIt<LocationService>();
      final location = await locationService.getCoordinatesFromCity(
        _cityController.text,
      );

      if (location != null) {
        await _saveLocation(
          location.latitude,
          location.longitude,
          _cityController.text,
        );
      } else {
        setState(() {
          _statusMessage = l10n.cityNotFound;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = l10n.searchError;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // حفظ وتحديث
  Future<void> _saveLocation(double lat, double long, String city) async {
    final settingsRepo = getIt<SettingsRepository>();
    final settings = await settingsRepo.getSettings();

    settings.latitude = lat;
    settings.longitude = long;
    settings.cityName = city;

    await settingsRepo.updateSettings(settings);

    // تحديث مواقيت الصلاة فوراً
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      context.read<PrayerCubit>().loadPrayerTimes();

      setState(() {
        _statusMessage = l10n.locationUpdatedSuccess(city);
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          l10n.prayerTimesLocation,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // خيار GPS
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _useGPS,
              icon: const Icon(Icons.my_location),
              label: Text(l10n.useCurrentLocationGPS),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.surface,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: AtharRadii.radiusMd,
                ),
              ),
            ),

            SizedBox(height: 30.h),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(l10n.or),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            SizedBox(height: 30.h),

            // خيار البحث
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: l10n.cityNameHint,
                border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _isLoading ? null : _searchCity,
                ),
              ),
              onSubmitted: (_) => _searchCity(),
            ),

            if (_statusMessage.isNotEmpty) ...[
              SizedBox(height: 20.h),
              Text(
                _statusMessage,
                style: TextStyle(
                  color: _statusMessage.contains("✅")
                      ? _successColor
                      : colorScheme.error,
                ),
              ),
            ],

            if (_isLoading) ...[
              SizedBox(height: 20.h),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
//-----------------------------------------------------------------------------
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:athar/core/services/location_service.dart';
// import 'package:athar/features/prayer/presentation/cubit/prayer_cubit.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class LocationSettingsPage extends StatefulWidget {
//   const LocationSettingsPage({super.key});

//   @override
//   State<LocationSettingsPage> createState() => _LocationSettingsPageState();
// }

// class _LocationSettingsPageState extends State<LocationSettingsPage> {
//   final _cityController = TextEditingController();
//   bool _isLoading = false;
//   String _statusMessage = "";

//   // استخدام GPS
//   Future<void> _useGPS() async {
//     final l10n = AppLocalizations.of(context);
//     setState(() {
//       _isLoading = true;
//       _statusMessage = l10n.detectingLocation;
//     });
//     try {
//       final locationService = getIt<LocationService>();
//       final position = await locationService.getCurrentLocation();

//       if (position != null) {
//         final cityName = await locationService.getCityName(
//           position.latitude,
//           position.longitude,
//         );
//         await _saveLocation(
//           position.latitude,
//           position.longitude,
//           cityName ?? l10n.myCurrentLocation,
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = l10n.locationDetectionFailed(e.toString());
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // البحث اليدوي
//   Future<void> _searchCity() async {
//     if (_cityController.text.isEmpty) return;
//     final l10n = AppLocalizations.of(context);
//     setState(() {
//       _isLoading = true;
//       _statusMessage = l10n.searching;
//     });
//     try {
//       final locationService = getIt<LocationService>();
//       final location = await locationService.getCoordinatesFromCity(
//         _cityController.text,
//       );

//       if (location != null) {
//         await _saveLocation(
//           location.latitude,
//           location.longitude,
//           _cityController.text,
//         );
//       } else {
//         setState(() {
//           _statusMessage = l10n.cityNotFound;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = l10n.searchError;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // حفظ وتحديث
//   Future<void> _saveLocation(double lat, double long, String city) async {
//     final settingsRepo = getIt<SettingsRepository>();
//     final settings = await settingsRepo.getSettings();

//     settings.latitude = lat;
//     settings.longitude = long;
//     settings.cityName = city;

//     await settingsRepo.updateSettings(settings);

//     // تحديث مواقيت الصلاة فوراً
//     if (mounted) {
//       final l10n = AppLocalizations.of(context);
//       context.read<PrayerCubit>().loadPrayerTimes();

//       setState(() {
//         _statusMessage = l10n.locationUpdatedSuccess(city);
//       });
//       await Future.delayed(const Duration(seconds: 1));
//       if (mounted) Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor: colors.scaffoldBackground,
//       appBar: AppBar(
//         title: Text(
//           l10n.prayerTimesLocation,
//           style: TextStyle(color: colors.textPrimary),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: IconThemeData(color: colors.textPrimary),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.w),
//         child: Column(
//           children: [
//             // خيار GPS
//             ElevatedButton.icon(
//               onPressed: _isLoading ? null : _useGPS,
//               icon: const Icon(Icons.my_location),
//               label: Text(l10n.useCurrentLocationGPS),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: colors.primary,
//                 foregroundColor: colors.surface,
//                 minimumSize: Size(double.infinity, 50.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: AtharRadii.radiusMd,
//                 ),
//               ),
//             ),

//             SizedBox(height: 30.h),
//             Row(
//               children: [
//                 const Expanded(child: Divider()),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Text(l10n.or),
//                 ),
//                 const Expanded(child: Divider()),
//               ],
//             ),
//             SizedBox(height: 30.h),

//             // خيار البحث
//             TextField(
//               controller: _cityController,
//               decoration: InputDecoration(
//                 labelText: l10n.cityNameHint,
//                 border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: _isLoading ? null : _searchCity,
//                 ),
//               ),
//               onSubmitted: (_) => _searchCity(),
//             ),

//             if (_statusMessage.isNotEmpty) ...[
//               SizedBox(height: 20.h),
//               Text(
//                 _statusMessage,
//                 style: TextStyle(
//                   color: _statusMessage.contains("✅")
//                       ? colors.success
//                       : colors.error,
//                 ),
//               ),
//             ],

//             if (_isLoading) ...[
//               SizedBox(height: 20.h),
//               const CircularProgressIndicator(),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------------
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../../core/services/location_service.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_cubit.dart'; // لتحديث الصلاة فوراً
// import 'package:flutter_bloc/flutter_bloc.dart';

// class LocationSettingsPage extends StatefulWidget {
//   const LocationSettingsPage({super.key});

//   @override
//   State<LocationSettingsPage> createState() => _LocationSettingsPageState();
// }

// class _LocationSettingsPageState extends State<LocationSettingsPage> {
//   final _cityController = TextEditingController();
//   bool _isLoading = false;
//   String _statusMessage = "";

//   // استخدام GPS
//   Future<void> _useGPS() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = "جاري تحديد الموقع...";
//     });
//     try {
//       final locationService = getIt<LocationService>();
//       final position = await locationService.getCurrentLocation();

//       if (position != null) {
//         final cityName = await locationService.getCityName(
//           position.latitude,
//           position.longitude,
//         );
//         await _saveLocation(
//           position.latitude,
//           position.longitude,
//           cityName ?? "موقعي الحالي",
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = "فشل تحديد الموقع: $e";
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // البحث اليدوي
//   Future<void> _searchCity() async {
//     if (_cityController.text.isEmpty) return;
//     setState(() {
//       _isLoading = true;
//       _statusMessage = "جاري البحث...";
//     });
//     try {
//       final locationService = getIt<LocationService>();
//       final location = await locationService.getCoordinatesFromCity(
//         _cityController.text,
//       );

//       if (location != null) {
//         await _saveLocation(
//           location.latitude,
//           location.longitude,
//           _cityController.text,
//         );
//       } else {
//         setState(() {
//           _statusMessage = "لم يتم العثور على المدينة";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = "حدث خطأ أثناء البحث";
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // حفظ وتحديث
//   Future<void> _saveLocation(double lat, double long, String city) async {
//     final settingsRepo = getIt<SettingsRepository>();
//     final settings = await settingsRepo.getSettings();

//     settings.latitude = lat;
//     settings.longitude = long;
//     settings.cityName = city;

//     await settingsRepo.updateSettings(settings);

//     // تحديث مواقيت الصلاة فوراً
//     if (mounted) {
//       context
//           .read<PrayerCubit>()
//           .loadPrayerTimes(); // تأكد أن الصفحة مغلفة بـ BlocProvider أو التطبيق ككل

//       setState(() {
//         _statusMessage = "تم تحديث الموقع بنجاح: $city ✅";
//       });
//       await Future.delayed(const Duration(seconds: 1));
//       if (mounted) Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text(
//           "موقع المواقيت",
//           style: TextStyle(color: Colors.black),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.w),
//         child: Column(
//           children: [
//             // خيار GPS
//             ElevatedButton.icon(
//               onPressed: _isLoading ? null : _useGPS,
//               icon: const Icon(Icons.my_location),
//               label: const Text("استخدام الموقع الحالي (GPS)"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: Colors.white,
//                 minimumSize: Size(double.infinity, 50.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//               ),
//             ),

//             SizedBox(height: 30.h),
//             Row(
//               children: [
//                 Expanded(child: Divider()),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   child: Text("أو"),
//                 ),
//                 Expanded(child: Divider()),
//               ],
//             ),
//             SizedBox(height: 30.h),

//             // خيار البحث
//             TextField(
//               controller: _cityController,
//               decoration: InputDecoration(
//                 labelText: "اسم المدينة (مثلاً: الرياض، القاهرة)",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: _isLoading ? null : _searchCity,
//                 ),
//               ),
//               onSubmitted: (_) => _searchCity(),
//             ),

//             if (_statusMessage.isNotEmpty) ...[
//               SizedBox(height: 20.h),
//               Text(
//                 _statusMessage,
//                 style: TextStyle(
//                   color: _statusMessage.contains("نجاح")
//                       ? Colors.green
//                       : Colors.red,
//                 ),
//               ),
//             ],

//             if (_isLoading) ...[
//               SizedBox(height: 20.h),
//               const CircularProgressIndicator(),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
