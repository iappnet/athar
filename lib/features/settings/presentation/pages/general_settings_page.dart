import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/presentation/cubit/locale_cubit.dart';
import 'package:athar/core/utils/navigation_utils.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/auth/presentation/pages/login_page.dart';
import 'package:athar/features/auth/presentation/pages/profile_page.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:athar/features/settings/presentation/pages/location_settings_page.dart';
import 'package:athar/features/settings/presentation/pages/smart_zones_page.dart';
import 'package:athar/features/subscription/presentation/pages/subscription_page.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          onPressed: () => NavigationUtils.safeBack(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
        builder: (context, authState) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final settings =
                  settingsState is SettingsLoaded ? settingsState.settings : null;

              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                children: [
                  // ── Profile card ────────────────────────────────────────
                  _ProfileCard(authState: authState),
                  AtharGap.xl,

                  // ── Appearance ──────────────────────────────────────────
                  _SectionHeader(l10n.appearance),
                  _SettingsCard(children: [
                    _LanguageTile(),
                    _Divider(),
                    _SwitchTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: const Color(0xFF5C35C9),
                      title: l10n.darkMode,
                      value: settings?.isDarkMode ?? false,
                      onChanged: (_) {},
                    ),
                  ]),
                  AtharGap.lg,

                  // ── Prayer & Worship ────────────────────────────────────
                  _SectionHeader(l10n.prayerSettings),
                  _SettingsCard(children: [
                    _SwitchTile(
                      icon: Icons.mosque_outlined,
                      iconColor: const Color(0xFF1A6B3C),
                      title: l10n.prayerTimes,
                      value: settings?.isPrayerEnabled ?? true,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().togglePrayerEnabled(v),
                    ),
                    if (settings?.isPrayerEnabled ?? true) ...[
                      _Divider(),
                      _SwitchTile(
                        icon: Icons.notifications_outlined,
                        iconColor: const Color(0xFF1A6B3C),
                        title: l10n.prayerReminder,
                        value: settings?.enablePrayerReminders ?? true,
                        onChanged: (v) => context
                            .read<SettingsCubit>()
                            .togglePrayerReminders(v),
                      ),
                      _Divider(),
                      _NavTile(
                        icon: Icons.location_on_outlined,
                        iconColor: const Color(0xFF0288D1),
                        title: l10n.prayerTimesLocation,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LocationSettingsPage(),
                          ),
                        ),
                      ),
                    ],
                    _Divider(),
                    _SwitchTile(
                      icon: Icons.menu_book_outlined,
                      iconColor: const Color(0xFF00897B),
                      title: l10n.morningEveningAthkar,
                      value: settings?.isAthkarEnabled ?? true,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().toggleAthkarEnabled(v),
                    ),
                  ]),
                  AtharGap.lg,

                  // ── Productivity ────────────────────────────────────────
                  _SectionHeader(l10n.reminders),
                  _SettingsCard(children: [
                    _SwitchTile(
                      icon: Icons.task_alt_outlined,
                      iconColor: const Color(0xFF1565C0),
                      title: '${l10n.task} & ${l10n.habits}',
                      subtitle: l10n.reminders,
                      value: settings?.isTaskRemindersEnabled ?? true,
                      onChanged: (v) => context
                          .read<SettingsCubit>()
                          .toggleTaskRemindersEnabled(v),
                    ),
                    _Divider(),
                    _SwitchTile(
                      icon: Icons.calendar_today_outlined,
                      iconColor: const Color(0xFF6D4C41),
                      title: l10n.hijriCalendar,
                      subtitle: l10n.hijriCalendarDesc,
                      value: settings?.isHijriMode ?? false,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().toggleHijriMode(v),
                    ),
                    _Divider(),
                    _NavTile(
                      icon: Icons.schedule_outlined,
                      iconColor: const Color(0xFF7B1FA2),
                      title: l10n.smartZones,
                      subtitle: l10n.smartZonesDesc,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SmartZonesPage(),
                        ),
                      ),
                    ),
                  ]),
                  AtharGap.lg,

                  // ── Security ────────────────────────────────────────────
                  _SectionHeader(l10n.privacy),
                  _SettingsCard(children: [
                    _SwitchTile(
                      icon: Icons.fingerprint,
                      iconColor: const Color(0xFFC62828),
                      title: l10n.biometricLogin,
                      subtitle: l10n.biometricLoginDesc,
                      value: settings?.isBiometricEnabled ?? false,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().toggleBiometric(v),
                    ),
                  ]),
                  AtharGap.lg,

                  // ── Sync & Account ──────────────────────────────────────
                  if (authState is AuthAuthenticated) ...[
                    _SectionHeader(l10n.syncAndData),
                    _SettingsCard(children: [
                      _SwitchTile(
                        icon: Icons.cloud_sync_outlined,
                        iconColor: const Color(0xFF0288D1),
                        title: l10n.autoSync,
                        subtitle: l10n.autoSyncDesc,
                        value: settings?.isAutoSyncEnabled ?? false,
                        onChanged: (v) =>
                            context.read<SettingsCubit>().toggleAutoSync(v),
                      ),
                    ]),
                    AtharGap.lg,

                    _SectionHeader(l10n.accountSettings),
                    _SettingsCard(children: [
                      _NavTile(
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF1A6B3C),
                        title: l10n.editProfile,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfilePage()),
                        ),
                      ),
                      _Divider(),
                      _NavTile(
                        icon: Icons.workspace_premium_outlined,
                        iconColor: const Color(0xFFF57C00),
                        title: 'Athar Pro',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionPage(),
                          ),
                        ),
                      ),
                      _Divider(),
                      _NavTile(
                        icon: Icons.logout_rounded,
                        iconColor: Colors.red.shade600,
                        title: l10n.logout,
                        titleColor: Colors.red.shade600,
                        onTap: () => _confirmLogout(context, l10n),
                      ),
                    ]),
                    AtharGap.lg,
                  ],

                  // ── About ───────────────────────────────────────────────
                  _SectionHeader(l10n.aboutApp),
                  _SettingsCard(children: [
                    _NavTile(
                      icon: Icons.share_outlined,
                      iconColor: const Color(0xFF1A6B3C),
                      title: l10n.shareApp,
                      onTap: () => SharePlus.instance.share(
                        ShareParams(text: 'أثر — حياة متوازنة، أثر مستدام'),
                      ),
                    ),
                    _Divider(),
                    _InfoTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: const Color(0xFF546E7A),
                      title: l10n.version,
                      trailing: '1.0.0',
                    ),
                  ]),

                  SizedBox(height: 32.h),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusLg),
        title: Text(
          l10n.logout,
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.logout,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: const TextStyle(fontFamily: 'Cairo')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
            child: Text(
              l10n.logout,
              style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final AuthState authState;
  const _ProfileCard({required this.authState});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isAuth = authState is AuthAuthenticated;
    final String name;
    if (isAuth) {
      final a = authState as AuthAuthenticated;
      name = a.fullName ?? a.username;
    } else {
      name = l10n.login;
    }
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'أ';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF1A6B3C).withValues(alpha: 0.12),
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A6B3C),
              ),
            ),
          ),
          AtharGap.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  isAuth ? l10n.accountSettings : l10n.autoSyncDesc,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          if (!isAuth)
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A6B3C),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: AtharRadii.radiusMd),
              ),
              child: Text(
                l10n.login,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Language Tile ─────────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = context.watch<LocaleCubit>().state.locale;

    final String label;
    if (currentLocale == null) {
      label = l10n.systemMode;
    } else if (currentLocale.languageCode == 'ar') {
      label = l10n.arabic;
    } else {
      label = l10n.english;
    }

    return _NavTile(
      icon: Icons.language_outlined,
      iconColor: const Color(0xFF0288D1),
      title: l10n.language,
      trailing2: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          color: Color(0xFF636E72),
        ),
      ),
      onTap: () => _showPicker(context, l10n, currentLocale),
    );
  }

  void _showPicker(
    BuildContext context,
    AppLocalizations l10n,
    Locale? current,
  ) {
    final cubit = context.read<LocaleCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.language,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            _LangOption(
              label: l10n.systemMode,
              subtitle: 'System Default',
              isSelected: current == null,
              onTap: () {
                cubit.setLocale(null);
                Navigator.pop(sheetCtx);
              },
            ),
            _LangOption(
              label: 'العربية',
              subtitle: 'Arabic',
              isSelected: current?.languageCode == 'ar',
              onTap: () {
                cubit.setLocale(const Locale('ar', 'SA'));
                Navigator.pop(sheetCtx);
              },
            ),
            _LangOption(
              label: 'English',
              subtitle: 'الإنجليزية',
              isSelected: current?.languageCode == 'en',
              onTap: () {
                cubit.setLocale(const Locale('en', 'US'));
                Navigator.pop(sheetCtx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A6B3C).withValues(alpha: 0.1)
              : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked,
          color:
              isSelected ? const Color(0xFF1A6B3C) : Colors.grey.shade400,
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? const Color(0xFF1A6B3C) : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 8.h, start: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.outline,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Settings Card ─────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(children: children),
    );
  }
}

// ─── Divider ───────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56,
      color: Theme.of(context)
          .colorScheme
          .outlineVariant
          .withValues(alpha: 0.5),
    );
  }
}

// ─── Switch Tile ───────────────────────────────────────────────────────────────

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            )
          : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: const Color(0xFF1A6B3C),
      ),
    );
  }
}

// ─── Nav Tile ──────────────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing2;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            )
          : null,
      trailing: trailing2 ??
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.outline,
            size: 20,
          ),
    );
  }
}

// ─── Info Tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String trailing;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        trailing,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

// ─── Icon Box ──────────────────────────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusSm,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
