// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i8;
import 'package:supabase_flutter/supabase_flutter.dart' as _i30;

import '../../features/assets/data/repositories/assets_repository_impl.dart'
    as _i38;
import '../../features/assets/domain/repositories/assets_repository.dart'
    as _i37;
import '../../features/assets/presentation/cubit/assets_cubit.dart' as _i86;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i40;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i39;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i71;
import '../../features/calendar/presentation/cubit/calendar_cubit.dart' as _i72;
import '../../features/dhikr/data/repositories/dhikr_repository.dart' as _i44;
import '../../features/dhikr/presentation/cubit/dhikr_cubit.dart' as _i74;
import '../../features/focus/data/repositories/focus_repository.dart' as _i47;
import '../../features/focus/presentation/cubit/focus_cubit.dart' as _i75;
import '../../features/habits/data/repositories/habit_repository_impl.dart'
    as _i49;
import '../../features/habits/domain/repositories/habit_repository.dart'
    as _i48;
import '../../features/habits/presentation/cubit/habit_cubit.dart' as _i76;
import '../../features/health/data/repositories/health_repository_impl.dart'
    as _i51;
import '../../features/health/domain/repositories/health_repository.dart'
    as _i50;
import '../../features/health/presentation/cubit/health_cubit.dart' as _i87;
import '../../features/home/presentation/cubit/timeline_cubit.dart' as _i68;
import '../../features/notifications/data/repositories/notifications_repository_impl.dart'
    as _i18;
import '../../features/notifications/domain/repositories/notifications_repository.dart'
    as _i17;
import '../../features/notifications/presentation/cubit/notifications_cubit.dart'
    as _i55;
import '../../features/prayer/data/repositories/prayer_repository_impl.dart'
    as _i57;
import '../../features/prayer/domain/repositories/prayer_repository.dart'
    as _i56;
import '../../features/prayer/presentation/cubit/prayer_cubit.dart' as _i82;
import '../../features/settings/data/repositories/category_repository.dart'
    as _i43;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i24;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i23;
import '../../features/settings/presentation/cubit/category_cubit.dart' as _i73;
import '../../features/settings/presentation/cubit/settings_cubit.dart' as _i61;
import '../../features/space/data/repositories/invitation_repository_impl.dart'
    as _i79;
import '../../features/space/data/repositories/list_repository_impl.dart'
    as _i10;
import '../../features/space/data/repositories/module_repository_impl.dart'
    as _i14;
import '../../features/space/data/repositories/space_member_repository_impl.dart'
    as _i25;
import '../../features/space/data/repositories/space_repository_impl.dart'
    as _i27;
import '../../features/space/domain/repositories/invitation_repository.dart'
    as _i78;
import '../../features/space/domain/repositories/list_repository.dart' as _i9;
import '../../features/space/domain/repositories/module_repository.dart'
    as _i13;
import '../../features/space/domain/repositories/space_repository.dart' as _i26;
import '../../features/space/presentation/cubit/inbox_cubit.dart' as _i88;
import '../../features/space/presentation/cubit/join_space_cubit.dart' as _i80;
import '../../features/space/presentation/cubit/list_cubit.dart' as _i89;
import '../../features/space/presentation/cubit/module_cubit.dart' as _i90;
import '../../features/space/presentation/cubit/space_cubit.dart' as _i62;
import '../../features/space/presentation/cubit/space_members_cubit.dart'
    as _i84;
import '../../features/stats/data/repositories/stats_repository_impl.dart'
    as _i53;
import '../../features/stats/domain/repositories/i_stats_repository.dart'
    as _i52;
import '../../features/stats/presentation/cubit/stats_cubit.dart' as _i63;
import '../../features/subscription/data/repositories/subscription_repository_impl.dart'
    as _i29;
import '../../features/subscription/domain/repositories/subscription_repository.dart'
    as _i28;
import '../../features/subscription/presentation/cubit/subscription_cubit.dart'
    as _i64;
import '../../features/sync/data/repositories/sync_repository_impl.dart'
    as _i32;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i31;
import '../../features/sync/presentation/cubit/sync_cubit.dart' as _i65;
import '../../features/task/data/repositories/task_repository_impl.dart'
    as _i34;
import '../../features/task/domain/repositories/task_repository.dart' as _i33;
import '../../features/task/presentation/cubit/task_cubit.dart' as _i85;
import '../iam/permission_cache.dart' as _i19;
import '../iam/permission_service.dart' as _i81;
import '../iam/role_service.dart' as _i60;
import '../presentation/cubit/celebration_cubit.dart' as _i5;
import '../services/appointment_notification_scheduler.dart' as _i69;
import '../services/appointment_notifier.dart' as _i3;
import '../services/asset_notification_scheduler.dart' as _i70;
import '../services/automation_service.dart' as _i41;
import '../services/biometric_service.dart' as _i4;
import '../services/category_migration_service.dart' as _i42;
import '../services/deep_link_service.dart' as _i6;
import '../services/fcm_service.dart' as _i45;
import '../services/file_service.dart' as _i46;
import '../services/habit_notification_scheduler.dart' as _i77;
import '../services/hijri_service.dart' as _i7;
import '../services/local_notification_service.dart' as _i11;
import '../services/location_service.dart' as _i12;
import '../services/medication_notification_scheduler.dart' as _i54;
import '../services/notification_id_manager.dart' as _i15;
import '../services/notification_service.dart' as _i16;
import '../services/prayer_conflict_service.dart' as _i20;
import '../services/prayer_notification_scheduler.dart' as _i83;
import '../services/prayer_service.dart' as _i21;
import '../services/prayer_timer_service.dart' as _i22;
import '../services/project_notification_scheduler.dart' as _i58;
import '../services/push_notification_service.dart' as _i59;
import '../services/sync_service.dart' as _i66;
import '../services/task_notification_scheduler.dart' as _i67;
import '../services/time_conflict_service.dart' as _i35;
import '../services/widget_data_service.dart' as _i36;
import 'register_module.dart' as _i91;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i3.AppointmentNotifier>(() => _i3.AppointmentNotifier());
    gh.lazySingleton<_i4.BiometricService>(() => _i4.BiometricService());
    gh.lazySingleton<_i5.CelebrationCubit>(() => _i5.CelebrationCubit());
    gh.lazySingleton<_i6.DeepLinkService>(() => _i6.DeepLinkService());
    gh.lazySingleton<_i7.HijriService>(() => _i7.HijriService());
    await gh.factoryAsync<_i8.Isar>(
      () => registerModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i9.ListRepository>(
        () => _i10.ListRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i11.LocalNotificationService>(
        () => _i11.LocalNotificationService());
    gh.lazySingleton<_i12.LocationService>(() => _i12.LocationService());
    gh.lazySingleton<_i13.ModuleRepository>(
        () => _i14.ModuleRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i15.NotificationIdManager>(
        () => _i15.NotificationIdManager());
    gh.lazySingleton<_i16.NotificationService>(
        () => _i16.NotificationService());
    gh.lazySingleton<_i17.NotificationsRepository>(
        () => _i18.NotificationsRepositoryImpl(gh<_i8.Isar>()));
    gh.singleton<_i19.PermissionCache>(() => _i19.PermissionCache());
    gh.lazySingleton<_i20.PrayerConflictService>(
        () => _i20.PrayerConflictService());
    gh.lazySingleton<_i21.PrayerService>(() => _i21.PrayerService());
    gh.lazySingleton<_i22.PrayerTimerService>(() => _i22.PrayerTimerService());
    gh.lazySingleton<_i23.SettingsRepository>(
        () => _i24.SettingsRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i25.SpaceMemberRepository>(
        () => _i25.SpaceMemberRepository(gh<_i8.Isar>()));
    gh.lazySingleton<_i26.SpaceRepository>(
        () => _i27.SpaceRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i28.SubscriptionRepository>(
        () => _i29.SubscriptionRepositoryImpl());
    gh.lazySingleton<_i30.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i31.SyncRepository>(() => _i32.SyncRepositoryImpl(
          gh<_i8.Isar>(),
          gh<_i30.SupabaseClient>(),
        ));
    gh.lazySingleton<_i33.TaskRepository>(
        () => _i34.TaskRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i35.TimeConflictService>(
        () => _i35.TimeConflictService(gh<_i33.TaskRepository>()));
    gh.lazySingleton<_i36.WidgetDataService>(() => _i36.WidgetDataService());
    gh.lazySingleton<_i37.AssetsRepository>(
        () => _i38.AssetsRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i39.AuthRepository>(
        () => _i40.AuthRepositoryImpl(gh<_i30.SupabaseClient>()));
    gh.lazySingleton<_i41.AutomationService>(() => _i41.AutomationService(
          gh<_i33.TaskRepository>(),
          gh<_i9.ListRepository>(),
          gh<_i8.Isar>(),
        ));
    gh.lazySingleton<_i42.CategoryMigrationService>(
        () => _i42.CategoryMigrationService(gh<_i8.Isar>()));
    gh.lazySingleton<_i43.CategoryRepository>(
        () => _i43.CategoryRepository(gh<_i8.Isar>()));
    gh.lazySingleton<_i44.DhikrRepository>(
        () => _i44.DhikrRepository(gh<_i8.Isar>()));
    gh.lazySingleton<_i45.FCMService>(
        () => _i45.FCMService(gh<_i11.LocalNotificationService>()));
    gh.lazySingleton<_i46.FileService>(() => _i46.FileService(gh<_i8.Isar>()));
    gh.lazySingleton<_i47.FocusRepository>(
        () => _i47.FocusRepository(gh<_i8.Isar>()));
    gh.lazySingleton<_i48.HabitRepository>(
        () => _i49.HabitRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i50.HealthRepository>(
        () => _i51.HealthRepositoryImpl(gh<_i8.Isar>()));
    gh.lazySingleton<_i52.IStatsRepository>(
        () => _i53.StatsRepositoryImpl(gh<_i8.Isar>()));
    gh.singleton<_i54.MedicationNotificationScheduler>(
        () => _i54.MedicationNotificationScheduler(
              gh<_i50.HealthRepository>(),
              gh<_i23.SettingsRepository>(),
              gh<_i11.LocalNotificationService>(),
              gh<_i15.NotificationIdManager>(),
            ));
    gh.factory<_i55.NotificationsCubit>(
        () => _i55.NotificationsCubit(gh<_i17.NotificationsRepository>()));
    gh.lazySingleton<_i56.PrayerRepository>(
        () => _i57.PrayerRepositoryImpl(gh<_i23.SettingsRepository>()));
    gh.singleton<_i58.ProjectNotificationScheduler>(
        () => _i58.ProjectNotificationScheduler(
              gh<_i8.Isar>(),
              gh<_i23.SettingsRepository>(),
              gh<_i11.LocalNotificationService>(),
              gh<_i15.NotificationIdManager>(),
            ));
    gh.singleton<_i59.PushNotificationService>(
        () => _i59.PushNotificationService(gh<_i30.SupabaseClient>()));
    gh.lazySingleton<_i60.RoleService>(
        () => _i60.RoleService(gh<_i25.SpaceMemberRepository>()));
    gh.factory<_i61.SettingsCubit>(() => _i61.SettingsCubit(
          gh<_i23.SettingsRepository>(),
          gh<_i4.BiometricService>(),
        ));
    gh.factory<_i62.SpaceCubit>(
        () => _i62.SpaceCubit(gh<_i26.SpaceRepository>()));
    gh.factory<_i63.StatsCubit>(
        () => _i63.StatsCubit(gh<_i52.IStatsRepository>()));
    gh.factory<_i64.SubscriptionCubit>(
        () => _i64.SubscriptionCubit(gh<_i28.SubscriptionRepository>()));
    gh.factory<_i65.SyncCubit>(() => _i65.SyncCubit(
          gh<_i31.SyncRepository>(),
          gh<_i23.SettingsRepository>(),
        ));
    gh.lazySingleton<_i66.SyncService>(() => _i66.SyncService(
          gh<_i8.Isar>(),
          gh<_i48.HabitRepository>(),
        ));
    gh.singleton<_i67.TaskNotificationScheduler>(
        () => _i67.TaskNotificationScheduler(
              gh<_i33.TaskRepository>(),
              gh<_i23.SettingsRepository>(),
              gh<_i11.LocalNotificationService>(),
              gh<_i15.NotificationIdManager>(),
            ));
    gh.factory<_i68.TimelineCubit>(() => _i68.TimelineCubit(
          gh<_i33.TaskRepository>(),
          gh<_i50.HealthRepository>(),
          gh<_i23.SettingsRepository>(),
          gh<_i8.Isar>(),
        ));
    gh.singleton<_i69.AppointmentNotificationScheduler>(
        () => _i69.AppointmentNotificationScheduler(
              gh<_i50.HealthRepository>(),
              gh<_i23.SettingsRepository>(),
              gh<_i11.LocalNotificationService>(),
              gh<_i15.NotificationIdManager>(),
            ));
    gh.singleton<_i70.AssetNotificationScheduler>(
        () => _i70.AssetNotificationScheduler(
              gh<_i37.AssetsRepository>(),
              gh<_i23.SettingsRepository>(),
              gh<_i11.LocalNotificationService>(),
              gh<_i15.NotificationIdManager>(),
            ));
    gh.factory<_i71.AuthCubit>(() => _i71.AuthCubit(gh<_i39.AuthRepository>()));
    gh.factory<_i72.CalendarCubit>(() => _i72.CalendarCubit(
          gh<_i33.TaskRepository>(),
          gh<_i50.HealthRepository>(),
          gh<_i3.AppointmentNotifier>(),
        ));
    gh.factory<_i73.CategoryCubit>(
        () => _i73.CategoryCubit(gh<_i43.CategoryRepository>()));
    gh.factory<_i74.DhikrCubit>(
        () => _i74.DhikrCubit(gh<_i44.DhikrRepository>()));
    gh.factory<_i75.FocusCubit>(
        () => _i75.FocusCubit(gh<_i47.FocusRepository>()));
    gh.factory<_i76.HabitCubit>(() => _i76.HabitCubit(
          gh<_i48.HabitRepository>(),
          gh<_i56.PrayerRepository>(),
          gh<_i23.SettingsRepository>(),
          gh<_i36.WidgetDataService>(),
        ));
    gh.singleton<_i77.HabitNotificationScheduler>(
        () => _i77.HabitNotificationScheduler(
              gh<_i48.HabitRepository>(),
              gh<_i23.SettingsRepository>(),
              gh<_i11.LocalNotificationService>(),
              gh<_i15.NotificationIdManager>(),
            ));
    gh.lazySingleton<_i78.InvitationRepository>(
        () => _i79.InvitationRepositoryImpl(gh<_i66.SyncService>()));
    gh.factory<_i80.JoinSpaceCubit>(
        () => _i80.JoinSpaceCubit(gh<_i78.InvitationRepository>()));
    gh.lazySingleton<_i81.PermissionService>(() => _i81.PermissionService(
          gh<_i60.RoleService>(),
          gh<_i19.PermissionCache>(),
        ));
    gh.factory<_i82.PrayerCubit>(() => _i82.PrayerCubit(
          prayerRepository: gh<_i56.PrayerRepository>(),
          settingsRepository: gh<_i23.SettingsRepository>(),
          widgetDataService: gh<_i36.WidgetDataService>(),
        ));
    gh.singleton<_i83.PrayerNotificationScheduler>(
        () => _i83.PrayerNotificationScheduler(
              gh<_i56.PrayerRepository>(),
              gh<_i23.SettingsRepository>(),
              gh<_i11.LocalNotificationService>(),
              gh<_i15.NotificationIdManager>(),
            ));
    gh.factory<_i84.SpaceMembersCubit>(() => _i84.SpaceMembersCubit(
          gh<_i25.SpaceMemberRepository>(),
          gh<_i78.InvitationRepository>(),
          gh<_i81.PermissionService>(),
        ));
    gh.factory<_i85.TaskCubit>(() => _i85.TaskCubit(
          gh<_i33.TaskRepository>(),
          gh<_i23.SettingsRepository>(),
          gh<_i43.CategoryRepository>(),
          gh<_i26.SpaceRepository>(),
          gh<_i81.PermissionService>(),
          gh<_i67.TaskNotificationScheduler>(),
          gh<_i66.SyncService>(),
          gh<_i36.WidgetDataService>(),
        ));
    gh.factory<_i86.AssetsCubit>(() => _i86.AssetsCubit(
          gh<_i37.AssetsRepository>(),
          gh<_i81.PermissionService>(),
        ));
    gh.factory<_i87.HealthCubit>(() => _i87.HealthCubit(
          gh<_i50.HealthRepository>(),
          gh<_i81.PermissionService>(),
          gh<_i41.AutomationService>(),
          gh<_i54.MedicationNotificationScheduler>(),
          gh<_i69.AppointmentNotificationScheduler>(),
          gh<_i3.AppointmentNotifier>(),
        ));
    gh.factory<_i88.InboxCubit>(
        () => _i88.InboxCubit(gh<_i78.InvitationRepository>()));
    gh.factory<_i89.ListCubit>(() => _i89.ListCubit(
          gh<_i9.ListRepository>(),
          gh<_i81.PermissionService>(),
          gh<_i41.AutomationService>(),
        ));
    gh.factory<_i90.ModuleCubit>(() => _i90.ModuleCubit(
          gh<_i13.ModuleRepository>(),
          gh<_i58.ProjectNotificationScheduler>(),
          gh<_i81.PermissionService>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i91.RegisterModule {}
