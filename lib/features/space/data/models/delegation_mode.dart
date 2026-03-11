enum DelegationMode {
  inherit, // افتراضي: يتبع إعداد المساحة
  enabled, // مسموح: يتجاوز المساحة ويسمح
  disabled, // ممنوع: يتجاوز المساحة ويمنع
}

// دالة مساعدة لتحويل النص لقيمة (للتخزين في Supabase إذا لزم الأمر)
extension DelegationModeExt on DelegationMode {
  String toStr() => toString().split('.').last;

  static DelegationMode fromStr(String? val) {
    return DelegationMode.values.firstWhere(
      (e) => e.toStr() == val,
      orElse: () => DelegationMode.inherit,
    );
  }
}
