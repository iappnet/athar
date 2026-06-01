/// Hijri month abbreviations per HIJRI_MONTH_ABBREVIATIONS.md (approved 2026-06-01).
/// Latin: fixed 3-char, Title-case. Arabic: shortest unambiguous whole-word form.
class HijriAbbreviations {
  static const List<String> latin = [
    'Muh', 'Saf', 'Rb1', 'Rb2', 'Jm1', 'Jm2',
    'Raj', 'Sha', 'Ram', 'Shw', 'DhQ', 'DhH',
  ];

  static const List<String> arabic = [
    'محرم', 'صفر', 'ربيع ١', 'ربيع ٢', 'جمادى ١', 'جمادى ٢',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  /// Returns the Latin 3-char abbreviation for Hijri month [hMonth] (1-indexed).
  static String getLatin(int hMonth) {
    assert(hMonth >= 1 && hMonth <= 12);
    return latin[hMonth - 1];
  }

  /// Returns the Arabic compact form for Hijri month [hMonth] (1-indexed).
  static String getArabic(int hMonth) {
    assert(hMonth >= 1 && hMonth <= 12);
    return arabic[hMonth - 1];
  }
}
