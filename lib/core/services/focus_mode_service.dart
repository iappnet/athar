// lib/features/focus/data/services/focus_mode_service.dart
// ✅ خدمة التحكم بوضع التركيز (DND + Shortcuts)

import 'dart:io';
import 'package:flutter/services.dart';

/// خدمة إدارة وضع التركيز
/// تدعم: iOS Focus Mode عبر Shortcuts، و Android DND
class FocusModeService {
  static const _methodChannel = MethodChannel('com.iappsnet.athar/focus_mode');

  // ═══════════════════════════════════════════════════════════════════
  // iOS: التكامل مع Shortcuts
  // ═══════════════════════════════════════════════════════════════════

  /// تفعيل وضع التركيز عبر Shortcuts (iOS 15+)
  /// يتطلب إعداد Shortcut من المستخدم مسبقاً
  static Future<bool> activateFocusMode({
    String focusModeName = 'Athar Focus',
    int durationMinutes = 25,
  }) async {
    if (Platform.isIOS) {
      return _activateIOSFocusMode(focusModeName, durationMinutes);
    } else if (Platform.isAndroid) {
      return _activateAndroidDND(durationMinutes);
    }
    return false;
  }

  /// إيقاف وضع التركيز
  static Future<bool> deactivateFocusMode() async {
    if (Platform.isIOS) {
      return _deactivateIOSFocusMode();
    } else if (Platform.isAndroid) {
      return _deactivateAndroidDND();
    }
    return false;
  }

  /// التحقق من حالة وضع التركيز
  static Future<bool> isFocusModeActive() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('isFocusModeActive');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // ───────────────────────────────────────────────────────────────────
  // iOS Implementation
  // ───────────────────────────────────────────────────────────────────

  static Future<bool> _activateIOSFocusMode(String name, int duration) async {
    try {
      // محاولة فتح Shortcut محدد مسبقاً
      // يجب على المستخدم إنشاء Shortcut باسم "Athar Focus" في تطبيق Shortcuts
      final result = await _methodChannel.invokeMethod<bool>(
        'activateIOSFocusMode',
        {
          'focusModeName': name,
          'durationMinutes': duration,
        },
      );
      return result ?? false;
    } catch (e) {
      // إذا فشل، نعود لإيقاف الإشعارات داخلياً فقط
      return false;
    }
  }

  static Future<bool> _deactivateIOSFocusMode() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('deactivateIOSFocusMode');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // ───────────────────────────────────────────────────────────────────
  // Android Implementation
  // ───────────────────────────────────────────────────────────────────

  static Future<bool> _activateAndroidDND(int duration) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'activateAndroidDND',
        {'durationMinutes': duration},
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _deactivateAndroidDND() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('deactivateAndroidDND');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // إعدادات المستخدم
  // ═══════════════════════════════════════════════════════════════════

  /// التحقق من صلاحية DND (Android)
  static Future<bool> hasNotificationPolicyAccess() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'hasNotificationPolicyAccess',
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// فتح إعدادات صلاحية DND (Android)
  static Future<void> openNotificationPolicySettings() async {
    if (Platform.isAndroid) {
      try {
        await _methodChannel.invokeMethod('openNotificationPolicySettings');
      } catch (e) {
        // تجاهل
      }
    }
  }

  /// فتح تطبيق Shortcuts (iOS)
  static Future<void> openShortcutsApp() async {
    if (Platform.isIOS) {
      try {
        await _methodChannel.invokeMethod('openShortcutsApp');
      } catch (e) {
        // تجاهل
      }
    }
  }

  /// إنشاء تعليمات إعداد Shortcut للمستخدم
  static FocusModeSetupGuide getSetupGuide() {
    if (Platform.isIOS) {
      return const FocusModeSetupGuide(
        platform: 'iOS',
        title: 'إعداد وضع التركيز مع Shortcuts',
        steps: [
          'افتح تطبيق Shortcuts (الاختصارات)',
          'أنشئ اختصار جديد',
          'سمّه "Athar Focus"',
          'أضف إجراء "Set Focus" واختر "Do Not Disturb"',
          'أضف إجراء "Wait" مع المدة المطلوبة (اختياري)',
          'أضف إجراء "Turn Off Focus"',
          'احفظ الاختصار',
        ],
        note: 'سيتم تفعيل هذا الاختصار تلقائياً عند بدء جلسة التركيز',
      );
    } else {
      return const FocusModeSetupGuide(
        platform: 'Android',
        title: 'إعداد وضع عدم الإزعاج',
        steps: [
          'افتح إعدادات التطبيق',
          'اذهب إلى "أذونات خاصة"',
          'اختر "وضع عدم الإزعاج"',
          'فعّل الإذن لتطبيق أثر',
        ],
        note: 'سيتم تفعيل وضع عدم الإزعاج تلقائياً أثناء جلسات التركيز',
      );
    }
  }
}

/// نموذج دليل الإعداد
class FocusModeSetupGuide {
  final String platform;
  final String title;
  final List<String> steps;
  final String note;

  const FocusModeSetupGuide({
    required this.platform,
    required this.title,
    required this.steps,
    required this.note,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Native Code المطلوب
// ═══════════════════════════════════════════════════════════════════

/*
📁 ios/Runner/AppDelegate.swift - أضف هذا الكود:

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller = window?.rootViewController as! FlutterViewController
    let focusModeChannel = FlutterMethodChannel(
      name: "com.iappsnet.athar/focus_mode",
      binaryMessenger: controller.binaryMessenger
    )
    
    focusModeChannel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "activateIOSFocusMode":
        if let args = call.arguments as? [String: Any],
           let focusName = args["focusModeName"] as? String {
          // فتح Shortcut
          if let url = URL(string: "shortcuts://run-shortcut?name=\(focusName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url) { success in
              result(success)
            }
          } else {
            result(false)
          }
        } else {
          result(false)
        }
        
      case "openShortcutsApp":
        if let url = URL(string: "shortcuts://") {
          UIApplication.shared.open(url)
          result(nil)
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

───────────────────────────────────────────────────────────────────

📁 android/app/src/main/kotlin/.../MainActivity.kt - أضف هذا الكود:

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.iappsnet.athar/focus_mode"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "activateAndroidDND" -> {
                    val duration = call.argument<Int>("durationMinutes") ?: 25
                    result.success(setDNDMode(true))
                }
                "deactivateAndroidDND" -> {
                    result.success(setDNDMode(false))
                }
                "hasNotificationPolicyAccess" -> {
                    result.success(hasNotificationPolicyAccess())
                }
                "openNotificationPolicySettings" -> {
                    openNotificationPolicySettings()
                    result.success(null)
                }
                "isFocusModeActive" -> {
                    result.success(isDNDActive())
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun setDNDMode(enable: Boolean): Boolean {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!notificationManager.isNotificationPolicyAccessGranted) {
                return false
            }
            
            val filter = if (enable) {
                NotificationManager.INTERRUPTION_FILTER_NONE
            } else {
                NotificationManager.INTERRUPTION_FILTER_ALL
            }
            
            notificationManager.setInterruptionFilter(filter)
            return true
        }
        return false
    }
    
    private fun hasNotificationPolicyAccess(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            return notificationManager.isNotificationPolicyAccessGranted
        }
        return true
    }
    
    private fun isDNDActive(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            return notificationManager.currentInterruptionFilter != NotificationManager.INTERRUPTION_FILTER_ALL
        }
        return false
    }
    
    private fun openNotificationPolicySettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            startActivity(intent)
        }
    }
}
*/
