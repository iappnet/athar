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
import '../../features/assets/presentation/cubit/assets_cubit.dart' as _i79;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i38;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i37;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i65;
import '../../features/dhikr/data/repositories/dhikr_repository.dart' as _i41;
import '../../features/dhikr/presentation/cubit/dhikr_cubit.dart' as _i67;
import '../../features/focus/data/repositories/focus_repository.dart' as _i44;
import '../../features/focus/presentation/cubit/focus_cubit.dart' as _i68;
import '../../features/habits/data/repositories/habit_repository_impl.dart'
    as _i46;
import '../../features/habits/domain/repositories/habit_repository.dart'
    as _i45;
import '../../features/habits/presentation/cubit/habit_cubit.dart' as _i69;
import '../../features/health/data/repositories/health_repository_impl.dart'
    as _i48;
import '../../features/health/domain/repositories/health_repository.dart'
    as _i47;
import '../../features/health/presentation/cubit/health_cubit.dart' as _i80;
import '../../features/home/presentation/cubit/timeline_cubit.dart' as _i62;
import '../../features/notifications/data/repositories/notifications_repository_impl.dart'
    as _i17;
import '../../features/notifications/domain/repositories/notifications_repository.dart'
    as _i16;
import '../../features/notifications/presentation/cubit/notifications_cubit.dart'
    as _i50;
import '../../features/prayer/data/repositories/prayer_repository_impl.dart'
    as _i52;
import '../../features/prayer/domain/repositories/prayer_repository.dart'
    as _i51;
import '../../features/prayer/presentation/cubit/prayer_cubit.dart' as _i75;
import '../../features/settings/data/repositories/category_repository.dart'
    as _i40;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i23;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i22;
import '../../features/settings/presentation/cubit/category_cubit.dart' as _i66;
import '../../features/settings/presentation/cubit/settings_cubit.dart' as _i56;
import '../../features/space/data/repositories/invitation_repository_impl.dart'
    as _i72;
import '../../features/space/data/repositories/list_repository_impl.dart'
    as _i9;
import '../../features/space/data/repositories/module_repository_impl.dart'
    as _i13;
import '../../features/space/data/repositories/space_member_repository_impl.dart'
    as _i24;
import '../../features/space/data/repositories/space_repository_impl.dart'
    as _i26;
import '../../features/space/domain/repositories/invitation_repository.dart'
    as _i71;
import '../../features/space/domain/repositories/list_repository.dart' as _i8;
import '../../features/space/domain/repositories/module_repository.dart'
    as _i12;
import '../../features/space/domain/repositories/space_repository.dart' as _i25;
import '../../features/space/presentation/cubit/inbox_cubit.dart' as _i81;
import '../../features/space/presentation/cubit/join_space_cubit.dart' as _i73;
import '../../features/space/presentation/cubit/list_cubit.dart' as _i82;
import '../../features/space/presentation/cubit/module_cubit.dart' as _i83;
import '../../features/space/presentation/cubit/space_cubit.dart' as _i57;
import '../../features/space/presentation/cubit/space_members_cubit.dart'
    as _i77;
import '../../features/stats/presentation/cubit/stats_cubit.dart' as _i58;
import '../../features/subscription/data/repositories/subscription_repository_impl.dart'
    as _i28;
import '../../features/subscription/domain/repositories/subscription_repository.dart'
    as _i27;
import '../../features/sync/data/repositories/sync_repository_impl.dart'
    as _i31;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i30;
import '../../features/sync/presentation/cubit/sync_cubit.dart' as _i59;
import '../../features/task/data/repositories/task_repository_impl.dart'
    as _i33;
import '../../features/task/domain/repositories/task_repository.dart' as _i32;
import '../../features/task/presentation/cubit/task_cubit.dart' as _i78;
import '../iam/permission_cache.dart' as _i18;
import '../iam/permission_service.dart' as _i74;
import '../iam/role_service.dart' as _i55;
import '../presentation/cubit/celebration_cubit.dart' as _i4;
import '../services/appointment_notification_scheduler.dart' as _i63;
import '../services/asset_notification_scheduler.dart' as _i64;
import '../services/automation_service.dart' as _i39;
import '../services/biometric_service.dart' as _i3;
import '../services/deep_link_service.dart' as _i5;
import '../services/fcm_service.dart' as _i42;
import '../services/file_service.dart' as _i43;
import '../services/habit_notification_scheduler.dart' as _i70;
import '../services/hijri_service.dart' as _i6;
import '../services/local_notification_service.dart' as _i10;
import '../services/location_service.dart' as _i11;
import '../services/medication_notification_scheduler.dart' as _i49;
import '../services/notification_id_manager.dart' as _i14;
import '../services/notification_service.dart' as _i15;
import '../services/prayer_conflict_service.dart' as _i19;
import '../services/prayer_notification_scheduler.dart' as _i76;
import '../services/prayer_service.dart' as _i20;
import '../services/prayer_timer_service.dart' as _i21;
import '../services/project_notification_scheduler.dart' as _i53;
import '../services/push_notification_service.dart' as _i54;
import '../services/sync_service.dart' as _i60;
import '../services/task_notification_scheduler.dart' as _i61;
import '../services/time_conflict_service.dart' as _i34;
import 'register_module.dart' as _i84;

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
    gh.lazySingleton<_i40.CategoryRepository>(
        () => _i40.CategoryRepository(gh<_i7.Isar>()));
    gh.lazySingleton<_i41.DhikrRepository>(
        () => _i41.DhikrRepository(gh<_i7.Isar>()));
    gh.lazySingleton<_i42.FCMService>(
        () => _i42.FCMService(gh<_i10.LocalNotificationService>()));
    gh.lazySingleton<_i43.FileService>(() => _i43.FileService(gh<_i7.Isar>()));
    gh.lazySingleton<_i44.FocusRepository>(
        () => _i44.FocusRepository(gh<_i7.Isar>()));
    gh.lazySingleton<_i45.HabitRepository>(
        () => _i46.HabitRepositoryImpl(gh<_i7.Isar>()));
    gh.lazySingleton<_i47.HealthRepository>(
        () => _i48.HealthRepositoryImpl(gh<_i7.Isar>()));
    gh.singleton<_i49.MedicationNotificationScheduler>(
        () => _i49.MedicationNotificationScheduler(
              gh<_i47.HealthRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.factory<_i50.NotificationsCubit>(
        () => _i50.NotificationsCubit(gh<_i16.NotificationsRepository>()));
    gh.lazySingleton<_i51.PrayerRepository>(
        () => _i52.PrayerRepositoryImpl(gh<_i22.SettingsRepository>()));
    gh.singleton<_i53.ProjectNotificationScheduler>(
        () => _i53.ProjectNotificationScheduler(
              gh<_i7.Isar>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.singleton<_i54.PushNotificationService>(
        () => _i54.PushNotificationService(gh<_i29.SupabaseClient>()));
    gh.lazySingleton<_i55.RoleService>(
        () => _i55.RoleService(gh<_i24.SpaceMemberRepository>()));
    gh.factory<_i56.SettingsCubit>(() => _i56.SettingsCubit(
          gh<_i22.SettingsRepository>(),
          gh<_i3.BiometricService>(),
        ));
    gh.factory<_i57.SpaceCubit>(
        () => _i57.SpaceCubit(gh<_i25.SpaceRepository>()));
    gh.factory<_i58.StatsCubit>(
        () => _i58.StatsCubit(gh<_i44.FocusRepository>()));
    gh.factory<_i59.SyncCubit>(() => _i59.SyncCubit(
          gh<_i30.SyncRepository>(),
          gh<_i22.SettingsRepository>(),
        ));
    gh.lazySingleton<_i60.SyncService>(() => _i60.SyncService(
          gh<_i7.Isar>(),
          gh<_i45.HabitRepository>(),
        ));
    gh.singleton<_i61.TaskNotificationScheduler>(
        () => _i61.TaskNotificationScheduler(
              gh<_i32.TaskRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.factory<_i62.TimelineCubit>(() => _i62.TimelineCubit(
          gh<_i32.TaskRepository>(),
          gh<_i47.HealthRepository>(),
          gh<_i22.SettingsRepository>(),
          gh<_i7.Isar>(),
        ));
    gh.singleton<_i63.AppointmentNotificationScheduler>(
        () => _i63.AppointmentNotificationScheduler(
              gh<_i47.HealthRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.singleton<_i64.AssetNotificationScheduler>(
        () => _i64.AssetNotificationScheduler(
              gh<_i35.AssetsRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.factory<_i65.AuthCubit>(() => _i65.AuthCubit(gh<_i37.AuthRepository>()));
    gh.factory<_i66.CategoryCubit>(
        () => _i66.CategoryCubit(gh<_i40.CategoryRepository>()));
    gh.factory<_i67.DhikrCubit>(
        () => _i67.DhikrCubit(gh<_i41.DhikrRepository>()));
    gh.factory<_i68.FocusCubit>(
        () => _i68.FocusCubit(gh<_i44.FocusRepository>()));
    gh.factory<_i69.HabitCubit>(() => _i69.HabitCubit(
          gh<_i45.HabitRepository>(),
          gh<_i51.PrayerRepository>(),
          gh<_i22.SettingsRepository>(),
        ));
    gh.singleton<_i70.HabitNotificationScheduler>(
        () => _i70.HabitNotificationScheduler(
              gh<_i45.HabitRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.lazySingleton<_i71.InvitationRepository>(
        () => _i72.InvitationRepositoryImpl(gh<_i60.SyncService>()));
    gh.factory<_i73.JoinSpaceCubit>(
        () => _i73.JoinSpaceCubit(gh<_i71.InvitationRepository>()));
    gh.lazySingleton<_i74.PermissionService>(() => _i74.PermissionService(
          gh<_i55.RoleService>(),
          gh<_i18.PermissionCache>(),
        ));
    gh.factory<_i75.PrayerCubit>(() => _i75.PrayerCubit(
          prayerRepository: gh<_i51.PrayerRepository>(),
          settingsRepository: gh<_i22.SettingsRepository>(),
        ));
    gh.singleton<_i76.PrayerNotificationScheduler>(
        () => _i76.PrayerNotificationScheduler(
              gh<_i51.PrayerRepository>(),
              gh<_i22.SettingsRepository>(),
              gh<_i10.LocalNotificationService>(),
              gh<_i14.NotificationIdManager>(),
            ));
    gh.factory<_i77.SpaceMembersCubit>(() => _i77.SpaceMembersCubit(
          gh<_i24.SpaceMemberRepository>(),
          gh<_i71.InvitationRepository>(),
          gh<_i74.PermissionService>(),
        ));
    gh.factory<_i78.TaskCubit>(() => _i78.TaskCubit(
          gh<_i32.TaskRepository>(),
          gh<_i22.SettingsRepository>(),
          gh<_i40.CategoryRepository>(),
          gh<_i25.SpaceRepository>(),
          gh<_i74.PermissionService>(),
          gh<_i61.TaskNotificationScheduler>(),
        ));
    gh.factory<_i79.AssetsCubit>(() => _i79.AssetsCubit(
          gh<_i35.AssetsRepository>(),
          gh<_i74.PermissionService>(),
        ));
    gh.factory<_i80.HealthCubit>(() => _i80.HealthCubit(
          gh<_i47.HealthRepository>(),
          gh<_i74.PermissionService>(),
          gh<_i39.AutomationService>(),
          gh<_i49.MedicationNotificationScheduler>(),
          gh<_i63.AppointmentNotificationScheduler>(),
        ));
    gh.factory<_i81.InboxCubit>(
        () => _i81.InboxCubit(gh<_i71.InvitationRepository>()));
    gh.factory<_i82.ListCubit>(() => _i82.ListCubit(
          gh<_i8.ListRepository>(),
          gh<_i74.PermissionService>(),
          gh<_i39.AutomationService>(),
        ));
    gh.factory<_i83.ModuleCubit>(() => _i83.ModuleCubit(
          gh<_i12.ModuleRepository>(),
          gh<_i53.ProjectNotificationScheduler>(),
          gh<_i74.PermissionService>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i84.RegisterModule {}
