import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

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
        print("Check Biometric Error: $e");
      }
      return false;
    }
  }

  /// طلب البصمة من المستخدم
  /// يعيد true إذا نجحت المصادقة، و false إذا فشلت أو تم الإلغاء
  Future<bool> authenticate() async {
    try {
      final isAvailable = await isBiometricAvailable;
      if (!isAvailable) return false;

      // ✅ الطريقة الصحيحة في 3.0.0
      // المعاملات مباشرة بدون options أو AuthenticationOptions
      return await _auth.authenticate(
        localizedReason: 'يرجى المصادقة للدخول إلى أثر',
        // بدلاً من stickyAuth استخدم persistAcrossBackgrounding مباشرة
        persistAcrossBackgrounding: true,
        // بدلاً من biometricOnly داخل options، استخدمه مباشرة
        biometricOnly: false, // يسمح بالرقم السري كبديل
      );
    } on LocalAuthException catch (e) {
      // ✅ في 3.0.0: استخدم LocalAuthException بدلاً من PlatformException
      if (kDebugMode) {
        switch (e.code) {
          case LocalAuthExceptionCode.noBiometricHardware:
            print("لا يوجد دعم للبصمة على هذا الجهاز");
            break;
          case LocalAuthExceptionCode.noBiometricsEnrolled:
            print("لا توجد بصمات مسجلة");
            break;
          case LocalAuthExceptionCode.temporaryLockout:
          case LocalAuthExceptionCode.biometricLockout:
            print("البصمة مقفلة بسبب محاولات فاشلة كثيرة");
            break;
          case LocalAuthExceptionCode.userCanceled:
            print("ألغى المستخدم عملية المصادقة");
            break;
          default:
            // ✅ استخدم description بدلاً من message
            print(
              "خطأ في المصادقة: ${e.code.name}${e.description != null ? ' - ${e.description}' : ''}",
            );
        }
      }
      return false;
    } on PlatformException catch (e) {
      // للأخطاء الأخرى غير المتوقعة
      if (kDebugMode) {
        print("Platform Error: $e");
      }
      return false;
    }
  }
}
