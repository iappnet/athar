import 'package:equatable/equatable.dart';
import '../../data/models/user_settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserSettings settings;
  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [
    settings.id,
    settings.isDarkMode,
    settings.isAutoModeEnabled,
    settings.workPeriodsSafe,
    settings.sleepPeriodsSafe,
    settings.quietPeriodsSafe,
    settings.isAthkarEnabled,
    settings.athkarDisplayMode,
    settings.athkarSessionViewMode,
    settings.hideNavOnScroll,
    settings.isPrayerEnabled,
    settings.isPrayerCardEnabled,
    settings.isPrayerNotificationsEnabled,
    settings.enablePrayerReminders,
    settings.isTaskRemindersEnabled,
    settings.isHijriMode,
    settings.isBiometricEnabled,
    settings.isAutoSyncEnabled,
    settings.isHabitRemindersEnabled,
    settings.isMedicationNotificationsEnabled,
    settings.lastSyncAt,
    settings.lastSyncError,
  ];
}
