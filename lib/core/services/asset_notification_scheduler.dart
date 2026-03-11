// lib/core/services/asset_notification_scheduler.dart

import 'package:athar/features/assets/data/models/asset_model.dart';
import 'package:athar/features/assets/data/models/service_model.dart';
import 'package:athar/features/assets/domain/repositories/assets_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'local_notification_service.dart';
import 'notification_id_manager.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

/// ✅ جدولة إشعارات الأصول (صيانة، تأمين، رخصة)
@singleton
class AssetNotificationScheduler {
  final AssetsRepository _assetRepository;
  final SettingsRepository _settingsRepository;
  final LocalNotificationService _notificationService;
  final NotificationIdManager _idManager;

  AssetNotificationScheduler(
    this._assetRepository,
    this._settingsRepository,
    this._notificationService,
    this._idManager,
  );

  // ═══════════════════════════════════════════════════════════
  // 🎬 INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  Future<void> initializeScheduling() async {
    try {
      if (kDebugMode) {
        print('📦 Initializing asset notification scheduler...');
      }

      final settings = await _settingsRepository.getSettings();

      if (!settings.isAssetRemindersEnabled) {
        if (kDebugMode) {
          print('⏸️ Asset reminders disabled in settings');
        }
        return;
      }

      await scheduleAllAssets();
      await _scheduleAutoRenewal();

      if (kDebugMode) {
        print('✅ Asset notification scheduler initialized successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error initializing asset notification scheduler: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📅 ASSET SCHEDULING
  // ═══════════════════════════════════════════════════════════

  Future<void> scheduleAllAssets() async {
    try {
      if (kDebugMode) {
        print('📅 Scheduling all assets with reminders...');
      }

      final assets = await _assetRepository.getAssetsWithReminders();

      if (assets.isEmpty) {
        if (kDebugMode) {
          print('ℹ️ No assets with reminders to schedule');
        }
        return;
      }

      int successCount = 0;
      int failedCount = 0;

      for (final asset in assets) {
        try {
          await scheduleAsset(asset);
          successCount++;
        } catch (e) {
          failedCount++;
          if (kDebugMode) {
            print('⚠️ Failed to schedule asset "${asset.name}": $e');
          }
        }
      }

      if (kDebugMode) {
        print('✅ Asset scheduler initialized:');
        print('   • Scheduled: $successCount assets');
        print('   • Failed: $failedCount assets');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error scheduling all assets: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  Future<void> scheduleAsset(AssetModel asset) async {
    try {
      if (!asset.reminderEnabled) {
        if (kDebugMode) {
          print('⏸️ Reminders disabled for asset: ${asset.name}');
        }
        return;
      }

      if (asset.isArchived) {
        if (kDebugMode) {
          print('⏸️ Skipping archived asset: ${asset.name}');
        }
        return;
      }

      final settings = await _settingsRepository.getSettings();

      // جدولة تذكير الصيانة
      if (settings.assetMaintenanceReminders &&
          asset.nextMaintenanceDate != null) {
        await _scheduleMaintenanceReminder(asset);
      }

      // جدولة تذكير التأمين
      if (settings.assetInsuranceReminders &&
          asset.insuranceExpiryDate != null) {
        await _scheduleInsuranceReminder(asset);
      }

      // جدولة تذكير الرخصة
      if (settings.assetLicenseReminders && asset.licenseExpiryDate != null) {
        await _scheduleLicenseReminder(asset);
      }

      // جدولة تذكير الضمان
      if (settings.assetWarrantyReminders) {
        await _scheduleWarrantyReminder(asset);
      }

      if (kDebugMode) {
        print('✅ Scheduled asset: ${asset.name}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error scheduling asset "${asset.name}": $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // ✅ إضافة دالة جديدة لجدولة خدمة صيانة محددة
  Future<void> scheduleServiceReminder(
    ServiceModel service,
    AssetModel asset,
  ) async {
    if (!service.reminderEnabled || service.nextDueDate == null) return;

    // تحديد موعد التذكير (بناءً على التوقيت المختار أو افتراضياً)
    DateTime scheduledDate;
    if (service.reminderTime != null) {
      // ندمج تاريخ الصيانة المتوقع مع وقت التذكير المختار
      scheduledDate = DateTime(
        service.nextDueDate!.year,
        service.nextDueDate!.month,
        service.nextDueDate!.day,
        service.reminderTime!.hour,
        service.reminderTime!.minute,
      );
    } else {
      // افتراضي: قبل الموعد بـ 7 أيام
      scheduledDate = service.nextDueDate!.subtract(
        Duration(days: service.notifyBeforeDays),
      );
    }

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationService.schedule(
      id: _idManager.forAssetMaintenance(
        service.uuid,
      ), // نستخدم uuid الخدمة ليكون فريداً
      title: '🔧 تذكير صيانة: ${asset.name}',
      body: 'موعد خدمة "${service.name}" قادم قريباً',
      scheduledDate: scheduledDate,
      category: NotificationCategory.asset,
      payload: 'asset:${asset.uuid}:service:${service.uuid}',
    );
  }

  Future<void> _scheduleMaintenanceReminder(AssetModel asset) async {
    final reminderDate = asset.nextMaintenanceDate!.subtract(
      Duration(days: asset.reminderDaysBefore),
    );

    if (reminderDate.isBefore(DateTime.now())) return;

    await _notificationService.schedule(
      id: _idManager.forAssetMaintenance(asset.uuid),
      title: '🔧 تذكير: صيانة ${asset.name}',
      body: 'موعد الصيانة بعد ${asset.reminderDaysBefore} أيام',
      scheduledDate: reminderDate,
      category: NotificationCategory.asset,
      payload: 'asset:${asset.uuid}:maintenance',
    );
  }

  Future<void> _scheduleInsuranceReminder(AssetModel asset) async {
    final reminderDate = asset.insuranceExpiryDate!.subtract(
      Duration(days: asset.reminderDaysBefore),
    );

    if (reminderDate.isBefore(DateTime.now())) return;

    await _notificationService.schedule(
      id: _idManager.forAssetInsurance(asset.uuid),
      title: '🛡️ تذكير: انتهاء تأمين ${asset.name}',
      body: 'التأمين سينتهي بعد ${asset.reminderDaysBefore} أيام',
      scheduledDate: reminderDate,
      category: NotificationCategory.asset,
      payload: 'asset:${asset.uuid}:insurance',
    );
  }

  Future<void> _scheduleLicenseReminder(AssetModel asset) async {
    final reminderDate = asset.licenseExpiryDate!.subtract(
      Duration(days: asset.reminderDaysBefore),
    );

    if (reminderDate.isBefore(DateTime.now())) return;

    await _notificationService.schedule(
      id: _idManager.forAssetLicense(asset.uuid),
      title: '📄 تذكير: انتهاء رخصة ${asset.name}',
      body: 'الرخصة ستنتهي بعد ${asset.reminderDaysBefore} أيام',
      scheduledDate: reminderDate,
      category: NotificationCategory.asset,
      payload: 'asset:${asset.uuid}:license',
    );
  }

  Future<void> _scheduleWarrantyReminder(AssetModel asset) async {
    final warrantyExpiry = asset.warrantyExpiryDate;
    final reminderDate = warrantyExpiry.subtract(
      Duration(days: asset.reminderDaysBefore),
    );

    if (reminderDate.isBefore(DateTime.now())) return;

    await _notificationService.schedule(
      id: _idManager.forAsset(asset.uuid),
      title: '⏰ تذكير: انتهاء ضمان ${asset.name}',
      body: 'الضمان سينتهي بعد ${asset.reminderDaysBefore} أيام',
      scheduledDate: reminderDate,
      category: NotificationCategory.asset,
      payload: 'asset:${asset.uuid}:warranty',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🗑️ CANCELLATION
  // ═══════════════════════════════════════════════════════════

  Future<void> cancelAsset(String assetUuid) async {
    try {
      await _notificationService.cancel(_idManager.forAsset(assetUuid));
      await _notificationService.cancel(
        _idManager.forAssetMaintenance(assetUuid),
      );
      await _notificationService.cancel(
        _idManager.forAssetInsurance(assetUuid),
      );
      await _notificationService.cancel(_idManager.forAssetLicense(assetUuid));

      if (kDebugMode) {
        print('🗑️ Cancelled asset reminders: $assetUuid');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling asset reminders: $e');
      }
      rethrow;
    }
  }

  Future<void> cancelAllAssets() async {
    try {
      await _notificationService.cancelRange(
        NotificationIdRanges.assetBase,
        NotificationIdRanges.assetMax,
      );

      if (kDebugMode) {
        print('🗑️ Cancelled all asset reminders');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling all asset reminders: $e');
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🔧 UTILITIES
  // ═══════════════════════════════════════════════════════════

  Future<void> updateAsset(AssetModel asset) async {
    await cancelAsset(asset.uuid);
    await scheduleAsset(asset);
  }

  Future<void> rescheduleAll() async {
    await cancelAllAssets();
    await scheduleAllAssets();
  }

  Future<void> _scheduleAutoRenewal() async {
    try {
      final renewalTime = DateTime.now().add(const Duration(days: 7));

      await _notificationService.schedule(
        id: _idManager.autoRenewAsset,
        title: '🔄 تجديد إشعارات الأصول',
        body: 'جاري تجديد جدولة إشعارات الأصول...',
        scheduledDate: renewalTime,
        category: NotificationCategory.general,
        payload: 'auto_reschedule_assets',
      );

      if (kDebugMode) {
        print('✅ Asset auto-renewal scheduled for: $renewalTime');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to schedule asset auto-renewal: $e');
      }
    }
  }
}
