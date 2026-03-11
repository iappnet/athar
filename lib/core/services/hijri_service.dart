import 'package:hijri/hijri_calendar.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

@lazySingleton
class HijriService {
  HijriService() {
    // ضبط اللغة العربية كافتراضي
    HijriCalendar.setLocal('ar');
  }

  /// تحويل تاريخ ميلادي إلى هجري نصي (مثال: 15 رمضان 1446)
  String getHijriDate(DateTime date) {
    final hijriDate = HijriCalendar.fromDate(date);
    return "${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}";
  }

  /// تحويل تاريخ ميلادي إلى هجري كائن (للاستخدام البرمجي)
  HijriCalendar toHijri(DateTime date) {
    return HijriCalendar.fromDate(date);
  }

  /// الحصول على اليوم والشهر (مثال: الإثنين، 15 رمضان)
  String getDayAndHijriMonth(DateTime date) {
    final hijriDate = HijriCalendar.fromDate(date);
    final dayName = DateFormat('EEEE', 'ar').format(date); // اسم اليوم بالعربي
    return "$dayName، ${hijriDate.hDay} ${hijriDate.longMonthName}";
  }
}
