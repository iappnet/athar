import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import 'location_settings_page.dart';
import 'smart_zones_page.dart';
import '../../data/models/user_settings.dart';

// تأكد من استيراد المسارات الصحيحة
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoaded) {
            final settings = state.settings;
            final cubit = context.read<SettingsCubit>();

            return ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                // 1. قسم الحساب
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthAuthenticated) {
                      return Column(
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12.w),
                              leading: CircleAvatar(
                                radius: 25.r,
                                backgroundColor: Colors.purple.shade100,
                                child: Text(
                                  authState.username.isNotEmpty
                                      ? authState.username[0].toUpperCase()
                                      : "?",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ),
                              title: Text(
                                authState.fullName ?? authState.username,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              subtitle: Text(
                                "@${authState.username}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.sp,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.edit,
                                color: Colors.purple,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfilePage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // ✅✅ زر تفعيل البصمة (يظهر فقط للمسجلين)
                          _buildSettingsContainer([
                            _buildSwitchTile(
                              context,
                              icon: Icons.fingerprint_rounded,
                              color: Colors.pink,
                              title: l10n.biometricLogin,
                              subtitle: l10n.biometricLoginDesc,
                              value: settings.isBiometricEnabled,
                              onChanged: (val) async {
                                // نستدعي دالة التبديل في الكيوبت
                                final success = await cubit.toggleBiometric(
                                  val,
                                );

                                if (!success &&
                                    val == true &&
                                    context.mounted) {
                                  // إذا فشل التفعيل (لم يتعرف على البصمة)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.biometricVerificationFailed,
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ]),
                        ],
                      );
                    } else {
                      return Card(
                        color: Colors.purple.withValues(alpha: 0.05),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: Colors.purple.withValues(alpha: 0.2),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.login_rounded,
                            color: Colors.purple,
                            size: 28.sp,
                          ),
                          title: Text(
                            l10n.loginOrCreateAccount,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: Colors.purple,
                            ),
                          ),
                          subtitle: Text(l10n.forSyncAndFamilySharing),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.purple,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),

                SizedBox(height: 24.h),

                // ✅ 1.5. قسم المزامنة (جديد)
                _buildSectionHeader(context, l10n.syncAndData),
                _buildSettingsContainer([
                  // ✅✅ الخيار الذكي للمزامنة التلقائية
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      // نحدد هل هو ضيف أم لا
                      final isGuest =
                          authState is AuthGuest ||
                          authState is AuthUnauthenticated;
                      return _buildSwitchTile(
                        context,
                        icon: Icons.cloud_sync_outlined,
                        color: Colors.teal,
                        title: l10n.autoSync,
                        subtitle: l10n.autoSyncDesc,
                        // إذا كان ضيفاً -> اجبر القيمة على false (مغلق)
                        // إذا كان مسجلاً -> خذ القيمة الحقيقية من الإعدادات
                        value: isGuest ? false : settings.isAutoSyncEnabled,
                        onChanged: (val) {
                          // 🛑 التحقق الذكي قبل التغيير
                          if (authState is AuthGuest ||
                              authState is AuthUnauthenticated) {
                            // إذا كان ضيفاً، نرفض التغيير ونعرض حوار التسجيل
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(l10n.loginRequired),
                                content: Text(l10n.syncRequiresAccount),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(l10n.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginPage(),
                                        ),
                                      );
                                    },
                                    child: Text(l10n.login),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // إذا كان مسجلاً، نسمح بالتغيير
                            cubit.toggleAutoSync(val);
                          }
                        },
                      );
                    },
                  ),
                ]),

                SizedBox(height: 24.h),

                // 2. قسم الميزات والذكاء
                _buildSectionHeader(context, l10n.smartFeatures),
                _buildSettingsContainer([
                  _buildTile(
                    icon: Icons.auto_awesome_rounded,
                    color: Colors.purple,
                    title: l10n.smartZones,
                    subtitle: l10n.smartZonesDesc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SmartZonesPage()),
                    ),
                  ),
                ]),

                SizedBox(height: 24.h),

                // 3. قسم إعدادات الصلاة
                _buildSectionHeader(context, l10n.prayerSettings),
                _buildSettingsContainer([
                  _buildSwitchTile(
                    context,
                    icon: Icons.access_time_filled_rounded,
                    color: colorScheme.primary,
                    title: l10n.enablePrayerTimes,
                    subtitle: l10n.enablePrayerTimesDesc,
                    value: settings.isPrayerEnabled,
                    onChanged: (val) {
                      final newSettings = settings..isPrayerEnabled = val;
                      cubit.updateSettings(newSettings);
                    },
                  ),
                  if (settings.isPrayerEnabled) ...[
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.location_on_outlined,
                      color: Colors.red,
                      title: l10n.prayerTimesLocation,
                      subtitle: settings.cityName ?? l10n.notSet,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LocationSettingsPage(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                      child: Text(
                        l10n.prayerCardLocations,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // ✅ إصلاح: استخدام RadioGroup بدل groupValue/onChanged المهملة
                    RadioGroup<PrayerCardDisplayMode>(
                      groupValue: settings.prayerCardDisplayMode,
                      onChanged: (val) {
                        final newSettings = settings
                          ..prayerCardDisplayMode = val!;
                        cubit.updateSettings(newSettings);
                      },
                      child: Column(
                        children: [
                          _buildRadioOption(
                            context,
                            title: l10n.dashboardOnly,
                            value: PrayerCardDisplayMode.dashboardOnly,
                          ),
                          _buildRadioOption(
                            context,
                            title: l10n.dashboardAndTasks,
                            value: PrayerCardDisplayMode.dashboardAndTasks,
                          ),
                          _buildRadioOption(
                            context,
                            title: l10n.allPages,
                            value: PrayerCardDisplayMode.allPages,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ]),

                SizedBox(height: 24.h),

                // 4. قسم التفضيلات
                _buildSectionHeader(context, l10n.preferences),
                _buildSettingsContainer([
                  _buildSwitchTile(
                    context,
                    icon: Icons.calendar_month_outlined,
                    color: Colors.blue,
                    title: l10n.hijriCalendar,
                    subtitle: l10n.hijriCalendarDesc,
                    value: settings.isHijriMode,
                    onChanged: (val) {
                      cubit.toggleHijriMode(val);
                    },
                  ),
                  _buildDivider(),
                  Column(
                    children: [
                      _buildSwitchTile(
                        context,
                        icon: Icons.wb_sunny_outlined,
                        color: Colors.orange,
                        title: l10n.morningEveningAthkar,
                        subtitle: l10n.morningEveningAthkarDesc,
                        value: settings.isAthkarEnabled,
                        onChanged: (val) {
                          cubit.toggleAthkarFeature(val);
                        },
                      ),
                      if (settings.isAthkarEnabled)
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                height: 20.h,
                                color: Colors.grey.shade100,
                              ),
                              Text(
                                l10n.displayMode,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              SegmentedButton<AthkarDisplayMode>(
                                segments: [
                                  ButtonSegment(
                                    value: AthkarDisplayMode.independent,
                                    label: Text(l10n.cards),
                                    icon: Icon(Icons.view_agenda_outlined),
                                  ),
                                  ButtonSegment(
                                    value: AthkarDisplayMode.embedded,
                                    label: Text(l10n.compact),
                                    icon: Icon(Icons.list_alt_rounded),
                                  ),
                                ],
                                selected: {settings.athkarDisplayMode},
                                onSelectionChanged:
                                    (Set<AthkarDisplayMode> newSelection) {
                                      cubit.updateAthkarDisplayMode(
                                        newSelection.first,
                                      );
                                    },
                                style: _segmentedButtonStyle(context),
                              ),
                              Text(
                                l10n.sessionDisplayMode,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              SegmentedButton<AthkarSessionViewMode>(
                                segments: [
                                  ButtonSegment(
                                    value: AthkarSessionViewMode.list,
                                    label: Text(l10n.listMode),
                                    icon: Icon(Icons.format_list_bulleted),
                                  ),
                                  ButtonSegment(
                                    value: AthkarSessionViewMode.focus,
                                    label: Text(l10n.focusMode),
                                    icon: Icon(Icons.fullscreen),
                                  ),
                                ],
                                selected: {settings.athkarSessionViewMode},
                                onSelectionChanged: (newSelection) =>
                                    cubit.updateAthkarSessionViewMode(
                                      newSelection.first,
                                    ),
                                style: _segmentedButtonStyle(context),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ]),

                SizedBox(height: 24.h),

                // 5. قسم حول التطبيق
                _buildSectionHeader(context, l10n.aboutApp),
                _buildSettingsContainer([
                  _buildTile(
                    icon: Icons.info_outline_rounded,
                    color: Colors.grey,
                    title: l10n.aboutAthar,
                    trailing: Text(
                      "v1.0.0",
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildTile(
                    icon: Icons.share_outlined,
                    color: Colors.green,
                    title: l10n.shareApp,
                    onTap: () {},
                  ),
                ]),

                SizedBox(height: 40.h),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // --- Widgets مساعدة ---

  ButtonStyle _segmentedButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ButtonStyle(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary.withValues(alpha: 0.2);
        }
        return Colors.transparent;
      }),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  // ✅ إصلاح: بدون groupValue/onChanged — يتم التحكم عبر RadioGroup الأب
  Widget _buildRadioOption(
    BuildContext context, {
    required String title,
    required PrayerCardDisplayMode value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return RadioListTile<PrayerCardDisplayMode>(
      title: Text(title, style: TextStyle(fontSize: 14.sp)),
      value: value,
      activeColor: colorScheme.primary,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.sp,
            color: Colors.grey,
          ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: colorScheme.onSurfaceVariant),
      ),
      trailing: Switch(
        value: value,
        activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
        activeThumbColor: colorScheme.primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60.w,
      endIndent: 20.w,
      color: Colors.grey.shade100,
    );
  }
}
//-----------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import '../cubit/settings_cubit.dart';
// import '../cubit/settings_state.dart';
// import 'location_settings_page.dart';
// import 'smart_zones_page.dart';
// import '../../data/models/user_settings.dart';

// // تأكد من استيراد المسارات الصحيحة
// import '../../../auth/presentation/cubit/auth_cubit.dart';
// import '../../../auth/presentation/cubit/auth_state.dart';
// import '../../../auth/presentation/pages/login_page.dart';
// import '../../../auth/presentation/pages/profile_page.dart';

// class GeneralSettingsPage extends StatelessWidget {
//   const GeneralSettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor: colors.scaffoldBackground,
//       appBar: AppBar(
//         title: Text(
//           l10n.settings,
//           style: TextStyle(
//             color: colors.textPrimary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: BackButton(color: colors.textPrimary),
//       ),
//       body: BlocBuilder<SettingsCubit, SettingsState>(
//         builder: (context, state) {
//           if (state is SettingsLoaded) {
//             final settings = state.settings;
//             final cubit = context.read<SettingsCubit>();

//             return ListView(
//               padding: EdgeInsets.all(20.w),
//               children: [
//                 // 1. قسم الحساب
//                 BlocBuilder<AuthCubit, AuthState>(
//                   builder: (context, authState) {
//                     if (authState is AuthAuthenticated) {
//                       return Column(
//                         children: [
//                           Card(
//                             elevation: 2,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                             child: ListTile(
//                               contentPadding: EdgeInsets.all(12.w),
//                               leading: CircleAvatar(
//                                 radius: 25.r,
//                                 backgroundColor: Colors.purple.shade100,
//                                 child: Text(
//                                   authState.username.isNotEmpty
//                                       ? authState.username[0].toUpperCase()
//                                       : "?",
//                                   style: TextStyle(
//                                     fontSize: 20.sp,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.purple,
//                                   ),
//                                 ),
//                               ),
//                               title: Text(
//                                 authState.fullName ?? authState.username,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16.sp,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 "@${authState.username}",
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 12.sp,
//                                 ),
//                               ),
//                               trailing: const Icon(
//                                 Icons.edit,
//                                 color: Colors.purple,
//                               ),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => const ProfilePage(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           SizedBox(height: 16.h),

//                           // ✅✅ زر تفعيل البصمة (يظهر فقط للمسجلين)
//                           _buildSettingsContainer([
//                             _buildSwitchTile(
//                               context,
//                               icon: Icons.fingerprint_rounded,
//                               color: Colors.pink,
//                               title: l10n.biometricLogin,
//                               subtitle: l10n.biometricLoginDesc,
//                               value: settings.isBiometricEnabled,
//                               onChanged: (val) async {
//                                 // نستدعي دالة التبديل في الكيوبت
//                                 final success = await cubit.toggleBiometric(
//                                   val,
//                                 );

//                                 if (!success &&
//                                     val == true &&
//                                     context.mounted) {
//                                   // إذا فشل التفعيل (لم يتعرف على البصمة)
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                         l10n.biometricVerificationFailed,
//                                       ),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                 }
//                               },
//                             ),
//                           ]),
//                         ],
//                       );
//                     } else {
//                       return Card(
//                         color: Colors.purple.withValues(alpha: 0.05),
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           side: BorderSide(
//                             color: Colors.purple.withValues(alpha: 0.2),
//                           ),
//                         ),
//                         child: ListTile(
//                           leading: Icon(
//                             Icons.login_rounded,
//                             color: Colors.purple,
//                             size: 28.sp,
//                           ),
//                           title: Text(
//                             l10n.loginOrCreateAccount,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14.sp,
//                               color: Colors.purple,
//                             ),
//                           ),
//                           subtitle: Text(l10n.forSyncAndFamilySharing),
//                           trailing: Icon(
//                             Icons.arrow_forward_ios,
//                             size: 16,
//                             color: Colors.purple,
//                           ),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const LoginPage(),
//                                 fullscreenDialog: true,
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     }
//                   },
//                 ),

//                 SizedBox(height: 24.h),

//                 // ✅ 1.5. قسم المزامنة (جديد)
//                 _buildSectionHeader(context, l10n.syncAndData),
//                 _buildSettingsContainer([
//                   // ✅✅ الخيار الذكي للمزامنة التلقائية
//                   BlocBuilder<AuthCubit, AuthState>(
//                     builder: (context, authState) {
//                       // نحدد هل هو ضيف أم لا
//                       final isGuest =
//                           authState is AuthGuest ||
//                           authState is AuthUnauthenticated;
//                       return _buildSwitchTile(
//                         context,
//                         icon: Icons.cloud_sync_outlined,
//                         color: Colors.teal,
//                         title: l10n.autoSync,
//                         subtitle: l10n.autoSyncDesc,
//                         // إذا كان ضيفاً -> اجبر القيمة على false (مغلق)
//                         // إذا كان مسجلاً -> خذ القيمة الحقيقية من الإعدادات
//                         value: isGuest ? false : settings.isAutoSyncEnabled,
//                         onChanged: (val) {
//                           // 🛑 التحقق الذكي قبل التغيير
//                           if (authState is AuthGuest ||
//                               authState is AuthUnauthenticated) {
//                             // إذا كان ضيفاً، نرفض التغيير ونعرض حوار التسجيل
//                             showDialog(
//                               context: context,
//                               builder: (ctx) => AlertDialog(
//                                 title: Text(l10n.loginRequired),
//                                 content: Text(l10n.syncRequiresAccount),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(ctx),
//                                     child: Text(l10n.cancel),
//                                   ),
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       Navigator.pop(ctx);
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => const LoginPage(),
//                                         ),
//                                       );
//                                     },
//                                     child: Text(l10n.login),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           } else {
//                             // إذا كان مسجلاً، نسمح بالتغيير
//                             cubit.toggleAutoSync(val);
//                           }
//                         },
//                       );
//                     },
//                   ),
//                 ]),

//                 SizedBox(height: 24.h),

//                 // 2. قسم الميزات والذكاء
//                 _buildSectionHeader(context, l10n.smartFeatures),
//                 _buildSettingsContainer([
//                   _buildTile(
//                     icon: Icons.auto_awesome_rounded,
//                     color: Colors.purple,
//                     title: l10n.smartZones,
//                     subtitle: l10n.smartZonesDesc,
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SmartZonesPage()),
//                     ),
//                   ),
//                 ]),

//                 SizedBox(height: 24.h),

//                 // 3. قسم إعدادات الصلاة
//                 _buildSectionHeader(context, l10n.prayerSettings),
//                 _buildSettingsContainer([
//                   _buildSwitchTile(
//                     context,
//                     icon: Icons.access_time_filled_rounded,
//                     color: colors.primary,
//                     title: l10n.enablePrayerTimes,
//                     subtitle: l10n.enablePrayerTimesDesc,
//                     value: settings.isPrayerEnabled,
//                     onChanged: (val) {
//                       final newSettings = settings..isPrayerEnabled = val;
//                       cubit.updateSettings(newSettings);
//                     },
//                   ),
//                   if (settings.isPrayerEnabled) ...[
//                     _buildDivider(),
//                     _buildTile(
//                       icon: Icons.location_on_outlined,
//                       color: Colors.red,
//                       title: l10n.prayerTimesLocation,
//                       subtitle: settings.cityName ?? l10n.notSet,
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const LocationSettingsPage(),
//                         ),
//                       ),
//                     ),
//                     _buildDivider(),
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
//                       child: Text(
//                         l10n.prayerCardLocations,
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey.shade600,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     // ✅ إصلاح: استخدام RadioGroup بدل groupValue/onChanged المهملة
//                     RadioGroup<PrayerCardDisplayMode>(
//                       groupValue: settings.prayerCardDisplayMode,
//                       onChanged: (val) {
//                         final newSettings = settings
//                           ..prayerCardDisplayMode = val!;
//                         cubit.updateSettings(newSettings);
//                       },
//                       child: Column(
//                         children: [
//                           _buildRadioOption(
//                             context,
//                             title: l10n.dashboardOnly,
//                             value: PrayerCardDisplayMode.dashboardOnly,
//                           ),
//                           _buildRadioOption(
//                             context,
//                             title: l10n.dashboardAndTasks,
//                             value: PrayerCardDisplayMode.dashboardAndTasks,
//                           ),
//                           _buildRadioOption(
//                             context,
//                             title: l10n.allPages,
//                             value: PrayerCardDisplayMode.allPages,
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                   ],
//                 ]),

//                 SizedBox(height: 24.h),

//                 // 4. قسم التفضيلات
//                 _buildSectionHeader(context, l10n.preferences),
//                 _buildSettingsContainer([
//                   _buildSwitchTile(
//                     context,
//                     icon: Icons.calendar_month_outlined,
//                     color: Colors.blue,
//                     title: l10n.hijriCalendar,
//                     subtitle: l10n.hijriCalendarDesc,
//                     value: settings.isHijriMode,
//                     onChanged: (val) {
//                       cubit.toggleHijriMode(val);
//                     },
//                   ),
//                   _buildDivider(),
//                   Column(
//                     children: [
//                       _buildSwitchTile(
//                         context,
//                         icon: Icons.wb_sunny_outlined,
//                         color: Colors.orange,
//                         title: l10n.morningEveningAthkar,
//                         subtitle: l10n.morningEveningAthkarDesc,
//                         value: settings.isAthkarEnabled,
//                         onChanged: (val) {
//                           cubit.toggleAthkarFeature(val);
//                         },
//                       ),
//                       if (settings.isAthkarEnabled)
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Divider(
//                                 height: 20.h,
//                                 color: Colors.grey.shade100,
//                               ),
//                               Text(
//                                 l10n.displayMode,
//                                 style: TextStyle(
//                                   fontSize: 12.sp,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                               SizedBox(height: 8.h),
//                               SegmentedButton<AthkarDisplayMode>(
//                                 segments: [
//                                   ButtonSegment(
//                                     value: AthkarDisplayMode.independent,
//                                     label: Text(l10n.cards),
//                                     icon: Icon(Icons.view_agenda_outlined),
//                                   ),
//                                   ButtonSegment(
//                                     value: AthkarDisplayMode.embedded,
//                                     label: Text(l10n.compact),
//                                     icon: Icon(Icons.list_alt_rounded),
//                                   ),
//                                 ],
//                                 selected: {settings.athkarDisplayMode},
//                                 onSelectionChanged:
//                                     (Set<AthkarDisplayMode> newSelection) {
//                                       cubit.updateAthkarDisplayMode(
//                                         newSelection.first,
//                                       );
//                                     },
//                                 style: _segmentedButtonStyle(context),
//                               ),
//                               Text(
//                                 l10n.sessionDisplayMode,
//                                 style: TextStyle(
//                                   fontSize: 12.sp,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                               SizedBox(height: 8.h),
//                               SegmentedButton<AthkarSessionViewMode>(
//                                 segments: [
//                                   ButtonSegment(
//                                     value: AthkarSessionViewMode.list,
//                                     label: Text(l10n.listMode),
//                                     icon: Icon(Icons.format_list_bulleted),
//                                   ),
//                                   ButtonSegment(
//                                     value: AthkarSessionViewMode.focus,
//                                     label: Text(l10n.focusMode),
//                                     icon: Icon(Icons.fullscreen),
//                                   ),
//                                 ],
//                                 selected: {settings.athkarSessionViewMode},
//                                 onSelectionChanged: (newSelection) =>
//                                     cubit.updateAthkarSessionViewMode(
//                                       newSelection.first,
//                                     ),
//                                 style: _segmentedButtonStyle(context),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ]),

//                 SizedBox(height: 24.h),

//                 // 5. قسم حول التطبيق
//                 _buildSectionHeader(context, l10n.aboutApp),
//                 _buildSettingsContainer([
//                   _buildTile(
//                     icon: Icons.info_outline_rounded,
//                     color: Colors.grey,
//                     title: l10n.aboutAthar,
//                     trailing: Text(
//                       "v1.0.0",
//                       style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//                     ),
//                     onTap: () {},
//                   ),
//                   _buildDivider(),
//                   _buildTile(
//                     icon: Icons.share_outlined,
//                     color: Colors.green,
//                     title: l10n.shareApp,
//                     onTap: () {},
//                   ),
//                 ]),

//                 SizedBox(height: 40.h),
//               ],
//             );
//           }
//           return const Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }

//   // --- Widgets مساعدة ---

//   ButtonStyle _segmentedButtonStyle(BuildContext context) {
//     final colors = context.colors;

//     return ButtonStyle(
//       visualDensity: VisualDensity.compact,
//       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
//         if (states.contains(WidgetState.selected)) {
//           return colors.primary.withValues(alpha: 0.2);
//         }
//         return Colors.transparent;
//       }),
//     );
//   }

//   Widget _buildSectionHeader(BuildContext context, String title) {
//     final colors = context.colors;

//     return Padding(
//       padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 14.sp,
//           fontWeight: FontWeight.bold,
//           color: colors.textSecondary,
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingsContainer(List<Widget> children) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.02),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: children,
//       ),
//     );
//   }

//   // ✅ إصلاح: بدون groupValue/onChanged — يتم التحكم عبر RadioGroup الأب
//   Widget _buildRadioOption(
//     BuildContext context, {
//     required String title,
//     required PrayerCardDisplayMode value,
//   }) {
//     final colors = context.colors;

//     return RadioListTile<PrayerCardDisplayMode>(
//       title: Text(title, style: TextStyle(fontSize: 14.sp)),
//       value: value,
//       activeColor: colors.primary,
//       contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
//       dense: true,
//       visualDensity: VisualDensity.compact,
//     );
//   }

//   Widget _buildTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     String? subtitle,
//     Widget? trailing,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       onTap: onTap,
//       contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//       leading: Container(
//         padding: EdgeInsets.all(8.w),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: color, size: 20.sp),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
//       ),
//       subtitle: subtitle != null
//           ? Text(
//               subtitle,
//               style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//             )
//           : null,
//       trailing:
//           trailing ??
//           Icon(
//             Icons.arrow_forward_ios_rounded,
//             size: 14.sp,
//             color: Colors.grey,
//           ),
//     );
//   }

//   Widget _buildSwitchTile(
//     BuildContext context, {
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     required bool value,
//     required Function(bool) onChanged,
//   }) {
//     final colors = context.colors;

//     return ListTile(
//       contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//       leading: Container(
//         padding: EdgeInsets.all(8.w),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: color, size: 20.sp),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(fontSize: 12.sp, color: colors.textSecondary),
//       ),
//       trailing: Switch(
//         value: value,
//         activeTrackColor: colors.primary.withValues(alpha: 0.5),
//         activeThumbColor: colors.primary,
//         onChanged: onChanged,
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Divider(
//       height: 1,
//       indent: 60.w,
//       endIndent: 20.w,
//       color: Colors.grey.shade100,
//     );
//   }
// }
//--------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../cubit/settings_cubit.dart';
// import '../cubit/settings_state.dart';
// import 'location_settings_page.dart';
// import 'smart_zones_page.dart';
// import '../../data/models/user_settings.dart';

// // تأكد من استيراد المسارات الصحيحة
// import '../../../auth/presentation/cubit/auth_cubit.dart';
// import '../../../auth/presentation/cubit/auth_state.dart';
// import '../../../auth/presentation/pages/login_page.dart';
// import '../../../auth/presentation/pages/profile_page.dart';

// class GeneralSettingsPage extends StatelessWidget {
//   const GeneralSettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text(
//           "الإعدادات",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//       ),
//       body: BlocBuilder<SettingsCubit, SettingsState>(
//         builder: (context, state) {
//           if (state is SettingsLoaded) {
//             final settings = state.settings;
//             final cubit = context.read<SettingsCubit>();

//             return ListView(
//               padding: EdgeInsets.all(20.w),
//               children: [
//                 // 1. قسم الحساب
//                 BlocBuilder<AuthCubit, AuthState>(
//                   builder: (context, authState) {
//                     if (authState is AuthAuthenticated) {
//                       return Column(
//                         children: [
//                           Card(
//                             elevation: 2,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                             child: ListTile(
//                               contentPadding: EdgeInsets.all(12.w),
//                               leading: CircleAvatar(
//                                 radius: 25.r,
//                                 backgroundColor: Colors.purple.shade100,
//                                 child: Text(
//                                   authState.username.isNotEmpty
//                                       ? authState.username[0].toUpperCase()
//                                       : "?",
//                                   style: TextStyle(
//                                     fontSize: 20.sp,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.purple,
//                                   ),
//                                 ),
//                               ),
//                               title: Text(
//                                 authState.fullName ?? authState.username,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16.sp,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 "@${authState.username}",
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 12.sp,
//                                 ),
//                               ),
//                               trailing: const Icon(
//                                 Icons.edit,
//                                 color: Colors.purple,
//                               ),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => const ProfilePage(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           SizedBox(height: 16.h),

//                           // ✅✅ زر تفعيل البصمة (يظهر فقط للمسجلين)
//                           _buildSettingsContainer([
//                             _buildSwitchTile(
//                               icon: Icons.fingerprint_rounded,
//                               color: Colors.pink,
//                               title: "الدخول بالبصمة",
//                               subtitle: "حماية التطبيق ببصمة الوجه أو الأصبع",
//                               value: settings.isBiometricEnabled,
//                               onChanged: (val) async {
//                                 // نستدعي دالة التبديل في الكيوبت
//                                 final success = await cubit.toggleBiometric(
//                                   val,
//                                 );

//                                 if (!success &&
//                                     val == true &&
//                                     context.mounted) {
//                                   // إذا فشل التفعيل (لم يتعرف على البصمة)
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text("فشل التحقق من البصمة"),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                 }
//                               },
//                             ),
//                           ]),
//                         ],
//                       );
//                     } else {
//                       return Card(
//                         color: Colors.purple.withOpacity(0.05),
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           side: BorderSide(
//                             color: Colors.purple.withOpacity(0.2),
//                           ),
//                         ),
//                         child: ListTile(
//                           leading: Icon(
//                             Icons.login_rounded,
//                             color: Colors.purple,
//                             size: 28.sp,
//                           ),
//                           title: Text(
//                             "تسجيل الدخول / إنشاء حساب",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14.sp,
//                               color: Colors.purple,
//                             ),
//                           ),
//                           subtitle: const Text("للمزامنة والمشاركة العائلية"),
//                           trailing: const Icon(
//                             Icons.arrow_forward_ios,
//                             size: 16,
//                             color: Colors.purple,
//                           ),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const LoginPage(),
//                                 fullscreenDialog: true,
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     }
//                   },
//                 ),

//                 SizedBox(height: 24.h),

//                 // ✅ 1.5. قسم المزامنة (جديد)
//                 _buildSectionHeader("المزامنة والبيانات"),
//                 _buildSettingsContainer([
//                   // ✅✅ الخيار الذكي للمزامنة التلقائية
//                   BlocBuilder<AuthCubit, AuthState>(
//                     builder: (context, authState) {
//                       // نحدد هل هو ضيف أم لا
//                       final isGuest =
//                           authState is AuthGuest ||
//                           authState is AuthUnauthenticated;
//                       return _buildSwitchTile(
//                         icon: Icons.cloud_sync_outlined,
//                         color: Colors.teal,
//                         title: "المزامنة التلقائية",
//                         subtitle: "حفظ بياناتك في السحابة تلقائياً",
//                         // إذا كان ضيفاً -> اجبر القيمة على false (مغلق)
//                         // إذا كان مسجلاً -> خذ القيمة الحقيقية من الإعدادات
//                         value: isGuest ? false : settings.isAutoSyncEnabled,
//                         onChanged: (val) {
//                           // 🛑 التحقق الذكي قبل التغيير
//                           if (authState is AuthGuest ||
//                               authState is AuthUnauthenticated) {
//                             // إذا كان ضيفاً، نرفض التغيير ونعرض حوار التسجيل
//                             showDialog(
//                               context: context,
//                               builder: (ctx) => AlertDialog(
//                                 title: const Text("مطلوب تسجيل الدخول"),
//                                 content: const Text(
//                                   "المزامنة السحابية تتطلب حساباً.\nهل تود تسجيل الدخول الآن؟",
//                                 ),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(ctx),
//                                     child: const Text("إلغاء"),
//                                   ),
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       Navigator.pop(ctx);
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => const LoginPage(),
//                                         ),
//                                       );
//                                     },
//                                     child: const Text("تسجيل الدخول"),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           } else {
//                             // إذا كان مسجلاً، نسمح بالتغيير
//                             cubit.toggleAutoSync(val);
//                           }
//                         },
//                       );
//                     },
//                   ),
//                 ]),

//                 SizedBox(height: 24.h),

//                 // 2. قسم الميزات والذكاء
//                 _buildSectionHeader("الذكاء والميزات"),
//                 _buildSettingsContainer([
//                   _buildTile(
//                     icon: Icons.auto_awesome_rounded,
//                     color: Colors.purple,
//                     title: "المناطق الذكية",
//                     subtitle: "تخصيص أوقات العمل والمنزل",
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SmartZonesPage()),
//                     ),
//                   ),
//                 ]),

//                 SizedBox(height: 24.h),

//                 // 3. قسم إعدادات الصلاة
//                 _buildSectionHeader("إعدادات الصلاة"),
//                 _buildSettingsContainer([
//                   _buildSwitchTile(
//                     icon: Icons.access_time_filled_rounded,
//                     color: AppColors.primary,
//                     title: "تفعيل مواقيت الصلاة",
//                     subtitle: "البطاقات، التنبيهات، والتعارضات",
//                     value: settings.isPrayerEnabled,
//                     onChanged: (val) {
//                       final newSettings = settings..isPrayerEnabled = val;
//                       cubit.updateSettings(newSettings);
//                     },
//                   ),
//                   if (settings.isPrayerEnabled) ...[
//                     _buildDivider(),
//                     _buildTile(
//                       icon: Icons.location_on_outlined,
//                       color: Colors.red,
//                       title: "موقع المواقيت",
//                       subtitle: settings.cityName ?? "غير محدد",
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const LocationSettingsPage(),
//                         ),
//                       ),
//                     ),
//                     _buildDivider(),
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
//                       child: Text(
//                         "أماكن ظهور بطاقة الصلاة:",
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey.shade600,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     _buildRadioOption(
//                       title: "الداشبورد فقط",
//                       value: PrayerCardDisplayMode.dashboardOnly,
//                       groupValue: settings.prayerCardDisplayMode,
//                       onChanged: (val) {
//                         final newSettings = settings
//                           ..prayerCardDisplayMode = val!;
//                         cubit.updateSettings(newSettings);
//                       },
//                     ),
//                     _buildRadioOption(
//                       title: "الداشبورد وصفحة المهام",
//                       value: PrayerCardDisplayMode.dashboardAndTasks,
//                       groupValue: settings.prayerCardDisplayMode,
//                       onChanged: (val) {
//                         final newSettings = settings
//                           ..prayerCardDisplayMode = val!;
//                         cubit.updateSettings(newSettings);
//                       },
//                     ),
//                     _buildRadioOption(
//                       title: "جميع الصفحات",
//                       value: PrayerCardDisplayMode.allPages,
//                       groupValue: settings.prayerCardDisplayMode,
//                       onChanged: (val) {
//                         final newSettings = settings
//                           ..prayerCardDisplayMode = val!;
//                         cubit.updateSettings(newSettings);
//                       },
//                     ),
//                     SizedBox(height: 8.h),
//                   ],
//                 ]),

//                 SizedBox(height: 24.h),

//                 // 4. قسم التفضيلات
//                 _buildSectionHeader("التفضيلات"),
//                 _buildSettingsContainer([
//                   _buildSwitchTile(
//                     icon: Icons.calendar_month_outlined,
//                     color: Colors.blue,
//                     title: "التقويم الهجري",
//                     subtitle: "استخدام التاريخ الهجري كافتراضي",
//                     value: settings.isHijriMode,
//                     onChanged: (val) {
//                       cubit.toggleHijriMode(val);
//                     },
//                   ),
//                   _buildDivider(),
//                   Column(
//                     children: [
//                       _buildSwitchTile(
//                         icon: Icons.wb_sunny_outlined,
//                         color: Colors.orange,
//                         title: "أذكار الصباح والمساء",
//                         subtitle: "تفعيل نظام الأذكار اليومي",
//                         value: settings.isAthkarEnabled,
//                         onChanged: (val) {
//                           cubit.toggleAthkarFeature(val);
//                         },
//                       ),
//                       if (settings.isAthkarEnabled)
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Divider(
//                                 height: 20.h,
//                                 color: Colors.grey.shade100,
//                               ),
//                               Text(
//                                 "طريقة العرض:",
//                                 style: TextStyle(
//                                   fontSize: 12.sp,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                               SizedBox(height: 8.h),
//                               SegmentedButton<AthkarDisplayMode>(
//                                 segments: const [
//                                   ButtonSegment(
//                                     value: AthkarDisplayMode.independent,
//                                     label: Text("بطاقات"),
//                                     icon: Icon(Icons.view_agenda_outlined),
//                                   ),
//                                   ButtonSegment(
//                                     value: AthkarDisplayMode.embedded,
//                                     label: Text("مدمجة"),
//                                     icon: Icon(Icons.list_alt_rounded),
//                                   ),
//                                 ],
//                                 selected: {settings.athkarDisplayMode},
//                                 onSelectionChanged:
//                                     (Set<AthkarDisplayMode> newSelection) {
//                                       cubit.updateAthkarDisplayMode(
//                                         newSelection.first,
//                                       );
//                                     },
//                                 style: _segmentedButtonStyle(),
//                               ),
//                               Text(
//                                 "طريقة عرض الجلسة:",
//                                 style: TextStyle(
//                                   fontSize: 12.sp,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                               SizedBox(height: 8.h),
//                               SegmentedButton<AthkarSessionViewMode>(
//                                 segments: const [
//                                   ButtonSegment(
//                                     value: AthkarSessionViewMode.list,
//                                     label: Text("قائمة"),
//                                     icon: Icon(Icons.format_list_bulleted),
//                                   ),
//                                   ButtonSegment(
//                                     value: AthkarSessionViewMode.focus,
//                                     label: Text("تركيز"),
//                                     icon: Icon(Icons.fullscreen),
//                                   ),
//                                 ],
//                                 selected: {settings.athkarSessionViewMode},
//                                 onSelectionChanged: (newSelection) =>
//                                     cubit.updateAthkarSessionViewMode(
//                                       newSelection.first,
//                                     ),
//                                 style: _segmentedButtonStyle(),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ]),

//                 SizedBox(height: 24.h),

//                 // 5. قسم حول التطبيق
//                 _buildSectionHeader("عن التطبيق"),
//                 _buildSettingsContainer([
//                   _buildTile(
//                     icon: Icons.info_outline_rounded,
//                     color: Colors.grey,
//                     title: "عن أثر",
//                     trailing: Text(
//                       "v1.0.0",
//                       style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//                     ),
//                     onTap: () {},
//                   ),
//                   _buildDivider(),
//                   _buildTile(
//                     icon: Icons.share_outlined,
//                     color: Colors.green,
//                     title: "شارك التطبيق",
//                     onTap: () {},
//                   ),
//                 ]),

//                 SizedBox(height: 40.h),
//               ],
//             );
//           }
//           return const Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }

//   // --- Widgets مساعدة ---

//   ButtonStyle _segmentedButtonStyle() {
//     return ButtonStyle(
//       visualDensity: VisualDensity.compact,
//       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
//         if (states.contains(WidgetState.selected)) {
//           return AppColors.primary.withValues(alpha: 0.2);
//         }
//         return Colors.transparent;
//       }),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 14.sp,
//           fontWeight: FontWeight.bold,
//           color: Colors.grey.shade600,
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingsContainer(List<Widget> children) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.02),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: children,
//       ),
//     );
//   }

//   Widget _buildRadioOption({
//     required String title,
//     required PrayerCardDisplayMode value,
//     required PrayerCardDisplayMode groupValue,
//     required ValueChanged<PrayerCardDisplayMode?> onChanged,
//   }) {
//     return RadioListTile<PrayerCardDisplayMode>(
//       title: Text(title, style: TextStyle(fontSize: 14.sp)),
//       value: value,
//       groupValue: groupValue,
//       onChanged: onChanged,
//       activeColor: AppColors.primary,
//       contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
//       dense: true,
//       visualDensity: VisualDensity.compact,
//     );
//   }

//   Widget _buildTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     String? subtitle,
//     Widget? trailing,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       onTap: onTap,
//       contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//       leading: Container(
//         padding: EdgeInsets.all(8.w),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: color, size: 20.sp),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
//       ),
//       subtitle: subtitle != null
//           ? Text(
//               subtitle,
//               style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//             )
//           : null,
//       trailing:
//           trailing ??
//           Icon(
//             Icons.arrow_forward_ios_rounded,
//             size: 14.sp,
//             color: Colors.grey,
//           ),
//     );
//   }

//   Widget _buildSwitchTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     required bool value,
//     required Function(bool) onChanged,
//   }) {
//     return ListTile(
//       contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//       leading: Container(
//         padding: EdgeInsets.all(8.w),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: color, size: 20.sp),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//       ),
//       trailing: Switch(
//         value: value,
//         activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
//         activeColor: AppColors.primary,
//         onChanged: onChanged,
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Divider(
//       height: 1,
//       indent: 60.w,
//       endIndent: 20.w,
//       color: Colors.grey.shade100,
//     );
//   }
// }
