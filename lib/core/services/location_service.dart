import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LocationService {
  // 1. طلب الإذن والحصول على الموقع الحالي
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // فحص تفعيل الخدمة
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمة الموقع غير مفعلة');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض إذن الموقع');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('إذن الموقع مرفوض نهائياً');
    }

    // ✅ التعديل هنا: استخدام LocationSettings بدلاً من desiredAccuracy المباشرة
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // (اختياري) المسافة بالمتر قبل التحديث
      ),
    );
  }

  // 2. الحصول على اسم المدينة من الإحداثيات
  Future<String?> getCityName(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ??
            placemarks.first.subAdministrativeArea;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // 3. البحث عن إحداثيات مدينة بالاسم (للبحث اليدوي)
  Future<Location?> getCoordinatesFromCity(String cityName) async {
    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        return locations.first;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
