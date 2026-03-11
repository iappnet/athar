// تعريف أدوار المساحة
enum SpaceRole {
  owner,
  admin,
  member;

  static SpaceRole fromString(String role) {
    return SpaceRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => SpaceRole.member,
    );
  }
}

// تعريف أدوار الموديول
enum ModuleRole {
  admin,
  viewer; // Editor تم حذفه لأنه أصبح Assignee

  static ModuleRole fromString(String role) {
    return ModuleRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => ModuleRole.viewer,
    );
  }
}

// تعريف خصوصية العناصر
enum ItemVisibility {
  public, // للجميع
  private, // خاص جداً
  adminsOnly; // للمدراء والمالك فقط

  static ItemVisibility fromString(String visibility) {
    // تحويل النص من قاعدة البيانات (admins_only -> adminsOnly)
    if (visibility == 'admins_only') return ItemVisibility.adminsOnly;
    return ItemVisibility.values.firstWhere(
      (e) => e.name == visibility,
      orElse: () => ItemVisibility.public,
    );
  }
}
