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
    settings.isAutoModeEnabled,
    settings.workPeriodsSafe,
    settings.sleepPeriodsSafe,
    settings.quietPeriodsSafe,
    // ✅ نراقب الحقول الجديدة
    settings.isAthkarEnabled,
    settings.athkarDisplayMode,
    settings.athkarSessionViewMode, // ✅ إضافة الجديد
    // ✅✅✅ الحقل الجديد - إخفاء شريط التنقل ✅✅✅
    settings.hideNavOnScroll,
  ];
}
