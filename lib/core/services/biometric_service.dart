// lib/core/services/biometric_service.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ FIXED v2 - متوافق مع local_auth 3.0.1
// ═══════════════════════════════════════════════════════════════════════════════
// 📌 المصدر: https://pub.dev/packages/local_auth/versions/3.0.1
//
// ⚠️ تغييرات API في 3.0.0:
// - ❌ AuthenticationOptions تم إزالته
// - ✅ المعاملات مباشرة: biometricOnly, persistAcrossBackgrounding, sensitiveTransaction
// - ❌ useErrorDialogs تم إزالته
// - ❌ stickyAuth → persistAcrossBackgrounding
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

@lazySingleton
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// التحقق هل الجهاز يدعم البصمة وهل يوجد بصمات مسجلة
  Future<bool> get isBiometricAvailable async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("🔐 Check Biometric Error: $e");
      }
      return false;
    }
  }

  /// الحصول على أنواع البصمة المتاحة على الجهاز
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("🔐 Get Available Biometrics Error: $e");
      }
      return [];
    }
  }

  /// التحقق هل Face ID متاح
  Future<bool> get isFaceIdAvailable async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// التحقق هل Touch ID متاح
  Future<bool> get isTouchIdAvailable async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// الحصول على اسم نوع البصمة المتاح للعرض للمستخدم
  Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (biometrics.contains(BiometricType.strong) ||
        biometrics.contains(BiometricType.weak)) {
      return 'Biometric';
    }

    return 'Biometric';
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// ✅ طلب البصمة - متوافق مع local_auth 3.0.1
  /// ═══════════════════════════════════════════════════════════════════════════
  /// [biometricOnly]:
  ///   - true  = بصمة فقط (Face ID / Touch ID) ← الإعداد الموصى به
  ///   - false = بصمة أو رمز مرور كبديل
  ///
  /// [localizedReason]: الرسالة التي تظهر للمستخدم
  Future<bool> authenticate({
    bool biometricOnly = true, // ✅ الافتراضي: بصمة فقط
    String? localizedReason,
  }) async {
    try {
      // التحقق من توفر الخدمة
      final isAvailable = await isBiometricAvailable;
      if (!isAvailable) {
        if (kDebugMode) {
          print("🔐 Biometric not available on this device");
        }
        return false;
      }

      // التحقق من وجود بصمات مسجلة
      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) {
        if (kDebugMode) {
          print("🔐 No biometrics enrolled on this device");
        }
        return false;
      }

      if (kDebugMode) {
        print("🔐 Available biometrics: $biometrics");
        print("🔐 Authenticating (biometricOnly: $biometricOnly)");
      }

      // ✅ الطريقة الصحيحة في 3.0.0+: معاملات مباشرة بدون AuthenticationOptions
      return await _auth.authenticate(
        localizedReason: localizedReason ?? 'يرجى المصادقة للدخول إلى أثر',
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true, // بديل stickyAuth القديم
        sensitiveTransaction: true,
      );
    } on LocalAuthException catch (e) {
      if (kDebugMode) {
        _handleLocalAuthException(e);
      }
      return false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("🔐 Platform Error: $e");
      }
      return false;
    }
  }

  /// طلب البصمة مع السماح برمز المرور كبديل
  Future<bool> authenticateWithFallback({String? localizedReason}) async {
    return authenticate(biometricOnly: false, localizedReason: localizedReason);
  }

  /// طلب البصمة فقط بدون بديل
  Future<bool> authenticateBiometricOnly({String? localizedReason}) async {
    return authenticate(biometricOnly: true, localizedReason: localizedReason);
  }

  /// ✅ معالجة أخطاء LocalAuthException (فقط الأكواد الموجودة فعلياً في 3.0.1)
  void _handleLocalAuthException(LocalAuthException e) {
    switch (e.code) {
      case LocalAuthExceptionCode.noBiometricHardware:
        print("🔐 لا يوجد دعم للبصمة على هذا الجهاز");
        break;
      case LocalAuthExceptionCode.noBiometricsEnrolled:
        print("🔐 لا توجد بصمات مسجلة - يرجى تسجيل البصمة من الإعدادات");
        break;
      case LocalAuthExceptionCode.temporaryLockout:
      case LocalAuthExceptionCode.biometricLockout:
        print("🔐 البصمة مقفلة مؤقتاً بسبب محاولات فاشلة متعددة");
        break;
      case LocalAuthExceptionCode.userCanceled:
        print("🔐 ألغى المستخدم عملية المصادقة");
        break;
      default:
        print(
          "🔐 خطأ في المصادقة: ${e.code.name}"
          "${e.description != null ? ' - ${e.description}' : ''}",
        );
    }
  }
}

//----------------------------------------------------------------------------
// import 'package:flutter/foundation.dart';
// import 'package:injectable/injectable.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:flutter/services.dart';

// @lazySingleton
// class BiometricService {
//   final LocalAuthentication _auth = LocalAuthentication();

//   /// التحقق هل الجهاز يدعم البصمة وهل يوجد بصمات مسجلة
//   Future<bool> get isBiometricAvailable async {
//     try {
//       final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
//       final bool canAuthenticate =
//           canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
//       return canAuthenticate;
//     } on PlatformException catch (e) {
//       if (kDebugMode) {
//         print("Check Biometric Error: $e");
//       }
//       return false;
//     }
//   }

//   /// طلب البصمة من المستخدم
//   /// يعيد true إذا نجحت المصادقة، و false إذا فشلت أو تم الإلغاء
//   Future<bool> authenticate() async {
//     try {
//       final isAvailable = await isBiometricAvailable;
//       if (!isAvailable) return false;

//       // ✅ الطريقة الصحيحة في 3.0.0
//       // المعاملات مباشرة بدون options أو AuthenticationOptions
//       return await _auth.authenticate(
//         localizedReason: 'يرجى المصادقة للدخول إلى أثر',
//         // بدلاً من stickyAuth استخدم persistAcrossBackgrounding مباشرة
//         persistAcrossBackgrounding: true,
//         // بدلاً من biometricOnly داخل options، استخدمه مباشرة
//         biometricOnly: false, // يسمح بالرقم السري كبديل
//       );
//     } on LocalAuthException catch (e) {
//       // ✅ في 3.0.0: استخدم LocalAuthException بدلاً من PlatformException
//       if (kDebugMode) {
//         switch (e.code) {
//           case LocalAuthExceptionCode.noBiometricHardware:
//             print("لا يوجد دعم للبصمة على هذا الجهاز");
//             break;
//           case LocalAuthExceptionCode.noBiometricsEnrolled:
//             print("لا توجد بصمات مسجلة");
//             break;
//           case LocalAuthExceptionCode.temporaryLockout:
//           case LocalAuthExceptionCode.biometricLockout:
//             print("البصمة مقفلة بسبب محاولات فاشلة كثيرة");
//             break;
//           case LocalAuthExceptionCode.userCanceled:
//             print("ألغى المستخدم عملية المصادقة");
//             break;
//           default:
//             // ✅ استخدم description بدلاً من message
//             print(
//               "خطأ في المصادقة: ${e.code.name}${e.description != null ? ' - ${e.description}' : ''}",
//             );
//         }
//       }
//       return false;
//     } on PlatformException catch (e) {
//       // للأخطاء الأخرى غير المتوقعة
//       if (kDebugMode) {
//         print("Platform Error: $e");
//       }
//       return false;
//     }
//   }
// }
//----------------------------------------------------------------------------
