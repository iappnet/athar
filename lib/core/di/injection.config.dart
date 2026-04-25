// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i7;
import 'package:supabase_flutter/supabase_flutter.dart' as _i29;

import '../../features/assets/data/repositories/assets_repository_impl.dart'
    as _i36;
import '../../features/assets/domain/repositories/assets_repository.dart'
    as _i35;
import '../../features/assets/presentation/cubit/assets_cubit.dart' as _i81;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i38;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i37;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i67;
import '../../features/dhikr/data/repositories/dhikr_repository.dart' as _i42;
import '../../features/dhikr/presentation/cubit/dhikr_cubit.dart' as _i69;
import '../../features/focus/data/repositories/focus_repository.dart' as _i45;
import '../../features/focus/presentation/cubit/focus_cubit.dart' as _i70;
import '../../features/habits/data/repositories/habit_repository_impl.dart'
    as _i47;
import '../../features/habits/domain/repositories/habit_repository.dart'
    as _i46;
import '../../features/habits/presentation/cubit/habit_cubit.dart' as _i71;
import '../../features/health/data/repositories/health_repository_impl.dart'
    as _i49;
import '../../features/health/domain/repositories/health_repository.dart'
    as _i48;
import '../../features/health/presentation/cubit/health_cubit.dart' as _i82;
import '../../features/home/presentation/cubit/timeline_cubit.dart' as _i64;
import '../../features/notifications/data/repositories/notifications_repository_impl.dart'
    as _i17;
import '../../features/notifications/domain/repositories/notifications_repository.dart'
    as _i16;
import '../../features/notifications/presentation/cubit/notifications_cubit.dart'
    as _i51;
import '../../features/prayer/data/repositories/prayer_repository_impl.dart'
    as _i53;
import '../../features/prayer/domain/repositories/prayer_repository.dart'
    as _i52;
import '../../features/prayer/presentation/cubit/prayer_cubit.dart' as _i77;
import '../../features/settings/data/repositories/category_repository.dart'
    as _i41;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i23;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i22;
import '../../features/settings/presentation/cubit/category_cubit.dart' as _i68;
import '../../features/settings/presentation/cubit/settings_cubit.dart' as _i57;
import '../../features/space/data/repositories/invitation_repository_impl.dart'
    as _i74;
import '../../features/space/data/repositories/list_repository_impl.dart'
    as _i9;
import '../../features/space/data/repositories/module_repository_impl.dart'
    as _i13;
import '../../features/space/data/repositories/space_member_repository_impl.dart'
    as _i24;
import '../../features/space/data/repositories/space_repository_impl.dart'
    as _i26;
import '../../features/space/domain/repositories/invitation_repository.dart'
    as _i73;
import '../../features/space/domain/repositories/list_repository.dart' as _i8;
import '../../features/space/domain/repositories/module_repository.dart'
    as _i12;
import '../../features/space/domain/repositories/space_repository.dart' as _i25;
import '../../features/space/presentation/cubit/inbox_cubit.dart' as _i83;
import '../../features/space/presentation/cubit/join_space_cubit.dart' as _i75;
import '../../features/space/presentation/cubit/list_cubit.dart' as _i84;
import '../../features/space/presentation/cubit/module_cubit.dart' as _i85;
import '../../features/space/presentation/cubit/space_cubit.dart' as _i58;
import '../../features/space/presentation/cubit/space_members_cubit.dart'
    as _i79;
import '../../features/stats/presentation/cubit/stats_cubit.dart' as _i59;
import '../../features/subscription/data/repositories/subscription_repository_impl.dart'
    as _i28;
import '../../features/subscription/domain/repositories/subscription_repository.dart'
    as _i27;
import '../../features/subscription/presentation/cubit/subscription_cubit.dart'
    as _i60;
import '../../features/sync/data/repositories/sync_repository_impl.dart'
    as _i31;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i30;
import '../../features/sync/presentation/cubit/sync_cubit.dart' as _i61;
import '../../features/task/data/repositories/task_repository_impl.dart'
    as _i33;
import '../../features/task/domain/repositories/task_repository.dart' as _i32;
import '../../features/task/presentation/cubit/task_cubit.dart' as _i80;
import '../iam/permission_cache.dart' as _i18;
import '../iam/permission_service.dart' as _i76;
import '../iam/role_service.dart' as _i56;
import '../presentation/cubit/celebration_cubit.dart' as _i4;
import '../services/appointment_notification_scheduler.dart' as _i65;
import '../services/asset_notification_scheduler.dart' as _i66;
import '../services/automation_service.dart' as _i39;
import '../services/biometric_service.dart' as _i3;
import '../services/category_migration_service.dart' as _i40;
import '../services/deep_link_service.dart' as _i5;
import '../services/fcm_service.dart' as _i43;
import '../services/file_service.dart' as _i44;
import '../services/habit_notification_scheduler.dart' as _i72;
import '../services/hijri_service.dart' as _i6;
import '../services/local_notification_service.dart' as _i10;
import '../services/location_service.dart' as _i11;
import '../services/medication_notification_scheduler.dart' as _i50;
import '../services/notification_id_manager.dart' as _i14;
import '../services/notification_service.dart' as _i15;
import '../services/prayer_conflict_service.dart' as _i19;
import '../services/prayer_notification_scheduler.dart' as _i78;
import '../services/prayer_service.dart' as _i20;
import '../services/prayer_timer_service.dart' as _i21;
import '../services/project_notification_scheduler.dart' as _i54;
import '../services/push_notification_service.dart' as _i55;
import '../services/sync_service.dart' as _i62;
import '../services/task_notification_scheduler.dart' as _i63;
import '../services/time_conflict_service.dart' as _i34;
import 'register_module.dart' as _i86;

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
    gh.lazySingleton<_i3.BiometricService>(() => _i3.BiometricService());
    gh.lazySingleton<_i4.CelebrationCubit>(() => _i4.CelebrationCubit());
    gh.lazySingleton<_i5.DeepLinkService>(() => _i5.DeepLinkService());
    gh.lazySingleton<_i6.HijriService>(() => _i6.HijriService());
    await gh.factoryAsync<_i7.Isar>(
      () => registerModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i8.ListRepository>(
        () => _i9.ListRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i10.LocalNotificationService>(
        () => _i10.LocalNotificationService());
    gh.lazySingleton<_i11.LocationService>(() => _i11.LocationService());
    gh.lazySingleton<_i12.ModuleRepository>(
        () => _i13.ModuleRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i14.NotificationIdManager>(
        () => _i14.NotificationIdManager());
    gh.lazySingleton<_i15.NotificationService>(
        () => _i15.NotificationService());
    gh.lazySingleton<_i16.NotificationsRepository>(
        () => _i17.NotificationsRepositoryImpl(gh<_i7.Isar>()));
    gh.singleton<_i18.PermissionCache>(() => _i18.PermissionCache());
    gh.lazySingleton<_i19.PrayerConflictService>(
        () => _i19.PrayerConflictService());
    gh.lazySingleton<_i20.PrayerService>(() => _i20.PrayerService());
    gh.lazySingleton<_i21.PrayerTimerService>(() => _i21.PrayerTimerService());
    gh.lazySingleton<_i22.SettingsRepository>(
        () => _i23.SettingsRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i24.SpaceMemberRepository>(
        () => _i24.SpaceMemberRepository(gh<_i7.Isar>()));
    gh.lazySingleton<_i25.SpaceRepository>(
        () => _i26.SpaceRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i27.SubscriptionRepository>(
        () => _i28.SubscriptionRepositoryImpl());
    gh.lazySingleton<_i29.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i30.SyncRepository>(() => _i31.SyncRepositoryImpl(
          gh<_i7.Isar>(),
          gh<_i29.SupabaseClient>(),
        ));
    gh.lazySingleton<_i32.TaskRepository>(
        () => _i33.TaskRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i34.TimeConflictService>(
        () => _i34.TimeConflictService(gh<_i32.TaskRepository>()));
    gh.lazySingleton<_i35.AssetsRepository>(
        () => _i36.AssetsRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i37.AuthRepository>(
        () => _i38.AuthRepositoryImpl(gh<_i29.SupabaseClient>()));
    gh.lazySingleton<_i39.AutomationService>(() => _i39.AutomationService(
          gh<_i32.TaskRepository>(),
          gh<_i8.ListRepository>(),
          gh<_i7.Isar>(),
        ));
    gh.lazySingleton<_i40.CategoryMigrationService>(
        () => _i40.CategoryMigrationService(gh<_i7.Isar>()));
    gh.lazySingleton<_i41.CategoryRepository>(
        () => _i41.CategoryRepository(gh<_i7.Isar>()));
    gh.lazySingleton<_i42.DhikrRepository>(
        () => _i42.DhikrRepository(gh<_i7.Isar>()));
    gh.lazySingleton<_i43.FCMService>(
        () => _i43.FCMService(gh<_i10.LocalNotificationService>()));
    gh.lazySingleton<_i44.FileService>(() => _i44.FileService(gh<_i7.Isar>()));
    gh.lazySingleton<_i45.FocusRepository>(
        () => _i45.FocusRepository(gh<_i7.Isar>()));
    gh.lazySingleton<_i46.HabitRepository>(
        () => _i47.HabitRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i48.HealthRepository>(
        () => _i49.HealthRepositoryImpl(gh<_i7.Isar>()));
    gh.singleton<_i50.MedicationNotificationScheduler>(
        () => _i50.MedicationNotificationScheduler(
              gh<_i48.HealthRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.factory<_i51.NotificationsCubit>(
        () => _i51.NotificationsCubit(gh<_i16.NotificationsRepository>()));
    gh.lazySingleton<_i52.PrayerRepository>(
        () => _i53.PrayerRepositoryImpl(gh<_i22.SettingsRepository>()));
    gh.singleton<_i54.ProjectNotificationScheduler>(
        () => _i54.ProjectNotificationScheduler(
              gh<_i7.Isar>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.singleton<_i55.PushNotificationService>(
        () => _i55.PushNotificationService(gh<_i29.SupabaseClient>()));
    gh.lazySingleton<_i56.RoleService>(
        () => _i56.RoleService(gh<_i24.SpaceMemberRepository>()));
    gh.factory<_i57.SettingsCubit>(() => _i57.SettingsCubit(
          gh<_i22.SettingsRepository>(),
          gh<_i3.BiometricService>(),
        ));
    gh.factory<_i58.SpaceCubit>(
        () => _i58.SpaceCubit(gh<_i25.SpaceRepository>()));
    gh.factory<_i59.StatsCubit>(
        () => _i59.StatsCubit(gh<_i45.FocusRepository>()));
    gh.factory<_i60.SubscriptionCubit>(
        () => _i60.SubscriptionCubit(gh<_i27.SubscriptionRepository>()));
    gh.factory<_i61.SyncCubit>(() => _i61.SyncCubit(
          gh<_i30.SyncRepository>(),
          gh<_i22.SettingsRepository>(),
        ));
    gh.lazySingleton<_i62.SyncService>(() => _i62.SyncService(
          gh<_i7.Isar>(),
          gh<_i46.HabitRepository>(),
        ));
    gh.singleton<_i63.TaskNotificationScheduler>(
        () => _i63.TaskNotificationScheduler(
              gh<_i32.TaskRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.factory<_i64.TimelineCubit>(() => _i64.TimelineCubit(
          gh<_i32.TaskRepository>(),
          gh<_i48.HealthRepository>(),
          gh<_i22.SettingsRepository>(),
          gh<_i7.Isar>(),
        ));
    gh.singleton<_i65.AppointmentNotificationScheduler>(
        () => _i65.AppointmentNotificationScheduler(
              gh<_i48.HealthRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.singleton<_i66.AssetNotificationScheduler>(
        () => _i66.AssetNotificationScheduler(
              gh<_i35.AssetsRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.factory<_i67.AuthCubit>(() => _i67.AuthCubit(gh<_i37.AuthRepository>()));
    gh.factory<_i68.CategoryCubit>(
        () => _i68.CategoryCubit(gh<_i41.CategoryRepository>()));
    gh.factory<_i69.DhikrCubit>(
        () => _i69.DhikrCubit(gh<_i42.DhikrRepository>()));
    gh.factory<_i70.FocusCubit>(
        () => _i70.FocusCubit(gh<_i45.FocusRepository>()));
    gh.factory<_i71.HabitCubit>(() => _i71.HabitCubit(
          gh<_i46.HabitRepository>(),
          gh<_i52.PrayerRepository>(),
          gh<_i22.SettingsRepository>(),
        ));
    gh.singleton<_i72.HabitNotificationScheduler>(
        () => _i72.HabitNotificationScheduler(
              gh<_i46.HabitRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.lazySingleton<_i73.InvitationRepository>(
        () => _i74.InvitationRepositoryImpl(gh<_i62.SyncService>()));
    gh.factory<_i75.JoinSpaceCubit>(
        () => _i75.JoinSpaceCubit(gh<_i73.InvitationRepository>()));
    gh.lazySingleton<_i76.PermissionService>(() => _i76.PermissionService(
          gh<_i56.RoleService>(),
          gh<_i18.PermissionCache>(),
        ));
    gh.factory<_i77.PrayerCubit>(() => _i77.PrayerCubit(
          prayerRepository: gh<_i52.PrayerRepository>(),
          settingsRepository: gh<_i22.SettingsRepository>(),
        ));
    gh.singleton<_i78.PrayerNotificationScheduler>(
        () => _i78.PrayerNotificationScheduler(
              gh<_i52.PrayerRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.factory<_i79.SpaceMembersCubit>(() => _i79.SpaceMembersCubit(
          gh<_i24.SpaceMemberRepository>(),
          gh<_i73.InvitationRepository>(),
          gh<_i76.PermissionService>(),
        ));
    gh.factory<_i80.TaskCubit>(() => _i80.TaskCubit(
          gh<_i32.TaskRepository>(),
          gh<_i22.SettingsRepository>(),
          gh<_i41.CategoryRepository>(),
          gh<_i25.SpaceRepository>(),
          gh<_i76.PermissionService>(),
          gh<_i63.TaskNotificationScheduler>(),
        ));
    gh.factory<_i81.AssetsCubit>(() => _i81.AssetsCubit(
          gh<_i35.AssetsRepository>(),
          gh<_i76.PermissionService>(),
        ));
    gh.factory<_i82.HealthCubit>(() => _i82.HealthCubit(
          gh<_i48.HealthRepository>(),
          gh<_i76.PermissionService>(),
          gh<_i39.AutomationService>(),
          gh<_i50.MedicationNotificationScheduler>(),
          gh<_i65.AppointmentNotificationScheduler>(),
        ));
    gh.factory<_i83.InboxCubit>(
        () => _i83.InboxCubit(gh<_i73.InvitationRepository>()));
    gh.factory<_i84.ListCubit>(() => _i84.ListCubit(
          gh<_i8.ListRepository>(),
          gh<_i76.PermissionService>(),
          gh<_i39.AutomationService>(),
        ));
    gh.factory<_i85.ModuleCubit>(() => _i85.ModuleCubit(
          gh<_i12.ModuleRepository>(),
          gh<_i54.ProjectNotificationScheduler>(),
          gh<_i76.PermissionService>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i86.RegisterModule {}
