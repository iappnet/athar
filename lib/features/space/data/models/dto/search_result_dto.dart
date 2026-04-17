class SearchResultDto {
  final String uuid;
  final String username;
  final String fullName;
  final String? email; // ✅ إضافة
  final String? avatarUrl;

  SearchResultDto({
    required this.uuid,
    required this.username,
    required this.fullName,
    this.email,
    this.avatarUrl,
  });

  factory SearchResultDto.fromJson(Map<String, dynamic> json) {
    return SearchResultDto(
      // ✅ الكود الدفاعي (الأصح):
      // يبحث عن 'id' أولاً (الافتراضي في Supabase)، وإذا لم يجده يبحث عن 'uuid'
      uuid: json['id']?.toString() ?? json['uuid']?.toString() ?? '',

      username: json['username'] ?? '',

      // مطابقة لاسم العمود في قاعدة البيانات (full_name)
      fullName: json['full_name'] ?? '',

      email: json['email'], // ✅ إضافة

      avatarUrl: json['avatar_url'],
    );
  }
}
