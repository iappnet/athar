// lib/core/utils/icon_registry.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 🎨 ICON REGISTRY - نظام مركزي للأيقونات يدعم Tree-Shaking
// ═══════════════════════════════════════════════════════════════════════════════
//
// هذا الملف يحل مشكلة tree-shake للأيقونات عن طريق:
// 1. تعريف جميع الأيقونات المتاحة بشكل ثابت (const)
// 2. ربط كل أيقونة بمفتاح نصي فريد
// 3. استخدام المفتاح النصي في قاعدة البيانات بدلاً من iconCode
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class IconRegistry {
  IconRegistry._();

  // ═══════════════════════════════════════════════════════════════════════════
  // 📦 قائمة الأيقونات المتاحة للتصنيفات
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, IconData> categoryIcons = {
    // 📁 عام
    'label': Icons.label_outline,
    'folder': Icons.folder_outlined,
    'star': Icons.star_outline,
    'bookmark': Icons.bookmark_outline,
    'flag': Icons.flag_outlined,
    'tag': Icons.sell_outlined,

    // 💼 العمل والإنتاجية
    'work': Icons.work_outline,
    'business': Icons.business_outlined,
    'task': Icons.task_alt_outlined,
    'assignment': Icons.assignment_outlined,
    'description': Icons.description_outlined,
    'event': Icons.event_outlined,
    'schedule': Icons.schedule_outlined,
    'alarm': Icons.alarm_outlined,
    'meeting': Icons.groups_outlined,
    'laptop': Icons.laptop_outlined,

    // 🏠 المنزل والحياة
    'home': Icons.home_outlined,
    'family': Icons.family_restroom_outlined,
    'child': Icons.child_care_outlined,
    'pets': Icons.pets_outlined,
    'kitchen': Icons.kitchen_outlined,
    'bed': Icons.bed_outlined,
    'cleaning': Icons.cleaning_services_outlined,
    'garden': Icons.yard_outlined,

    // 🎓 التعليم والتطوير
    'school': Icons.school_outlined,
    'book': Icons.book_outlined,
    'library': Icons.local_library_outlined,
    'science': Icons.science_outlined,
    'code': Icons.code_outlined,
    'lightbulb': Icons.lightbulb_outline,
    'psychology': Icons.psychology_outlined,
    'translate': Icons.translate_outlined,

    // 💪 الصحة واللياقة
    'health': Icons.health_and_safety_outlined,
    'fitness': Icons.fitness_center_outlined,
    'medical': Icons.medical_services_outlined,
    'medication': Icons.medication_outlined,
    'heart': Icons.favorite_outline,
    'spa': Icons.spa_outlined,
    'self_care': Icons.self_improvement_outlined,
    'run': Icons.directions_run_outlined,
    'sports': Icons.sports_outlined,

    // 🛒 التسوق والمال
    'shopping': Icons.shopping_cart_outlined,
    'store': Icons.store_outlined,
    'payment': Icons.payment_outlined,
    'wallet': Icons.account_balance_wallet_outlined,
    'savings': Icons.savings_outlined,
    'receipt': Icons.receipt_outlined,
    'money': Icons.attach_money_outlined,
    'credit_card': Icons.credit_card_outlined,

    // 🚗 السفر والتنقل
    'travel': Icons.flight_outlined,
    'car': Icons.directions_car_outlined,
    'location': Icons.location_on_outlined,
    'map': Icons.map_outlined,
    'explore': Icons.explore_outlined,
    'hotel': Icons.hotel_outlined,
    'beach': Icons.beach_access_outlined,

    // 🎮 الترفيه والهوايات
    'entertainment': Icons.movie_outlined,
    'music': Icons.music_note_outlined,
    'games': Icons.sports_esports_outlined,
    'soccer': Icons.sports_soccer_outlined,
    'art': Icons.palette_outlined,
    'camera': Icons.camera_alt_outlined,
    'theater': Icons.theater_comedy_outlined,
    'headphones': Icons.headphones_outlined,

    // 👥 الاجتماعي والتواصل
    'social': Icons.people_outline,
    'person': Icons.person_outline,
    'group': Icons.group_outlined,
    'chat': Icons.chat_outlined,
    'call': Icons.call_outlined,
    'email': Icons.email_outlined,
    'notifications': Icons.notifications_outlined,

    // 🕌 الإسلامي والروحاني
    'mosque': Icons.mosque_outlined,
    'prayer': Icons.back_hand_outlined,
    'quran': Icons.menu_book_outlined,
    'charity': Icons.volunteer_activism_outlined,
    'crescent': Icons.nightlight_outlined,

    // ⚙️ أخرى
    'settings': Icons.settings_outlined,
    'build': Icons.build_outlined,
    'attach': Icons.attach_file_outlined,
    'link': Icons.link_outlined,
    'cloud': Icons.cloud_outlined,
    'download': Icons.download_outlined,
    'upload': Icons.upload_outlined,
    'lock': Icons.lock_outlined,
    'key': Icons.vpn_key_outlined,
    'info': Icons.info_outlined,
    'help': Icons.help_outlined,
    'warning': Icons.warning_outlined,
    'error': Icons.error_outlined,
    'check': Icons.check_circle_outlined,
    'close': Icons.cancel_outlined,
    'add': Icons.add_circle_outlined,
    'remove': Icons.remove_circle_outlined,
    'edit': Icons.edit_outlined,
    'delete': Icons.delete_outlined,
    'search': Icons.search_outlined,
    'filter': Icons.filter_list_outlined,
    'sort': Icons.sort_outlined,
    'refresh': Icons.refresh_outlined,
    'sync': Icons.sync_outlined,
    'share': Icons.share_outlined,
    'copy': Icons.content_copy_outlined,
    'paste': Icons.content_paste_outlined,
    'cut': Icons.content_cut_outlined,
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 القيم الافتراضية
  // ═══════════════════════════════════════════════════════════════════════════

  static const IconData defaultIcon = Icons.label_outline;
  static const String defaultIconKey = 'label';

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 الدوال المساعدة
  // ═══════════════════════════════════════════════════════════════════════════

  /// ✅ الحصول على أيقونة من المفتاح
  static IconData getIcon(String? key) {
    if (key == null || key.isEmpty) return defaultIcon;
    return categoryIcons[key] ?? defaultIcon;
  }

  /// ✅ الحصول على المفتاح من الأيقونة
  static String getKey(IconData? icon) {
    if (icon == null) return defaultIconKey;
    for (final entry in categoryIcons.entries) {
      if (entry.value.codePoint == icon.codePoint) {
        return entry.key;
      }
    }
    return defaultIconKey;
  }

  /// ✅ تحويل iconCode القديم إلى مفتاح (للـ migration)
  static String migrateFromIconCode(int? iconCode) {
    if (iconCode == null) return defaultIconKey;
    for (final entry in categoryIcons.entries) {
      if (entry.value.codePoint == iconCode) {
        return entry.key;
      }
    }
    return defaultIconKey;
  }

  /// ✅ التحقق من صحة المفتاح
  static bool isValidKey(String? key) {
    if (key == null || key.isEmpty) return false;
    return categoryIcons.containsKey(key);
  }

  /// ✅ قائمة الأيقونات للعرض في Icon Picker
  static List<IconPickerItem> get iconPickerItems {
    return categoryIcons.entries
        .map((e) => IconPickerItem(key: e.key, icon: e.value))
        .toList();
  }

  /// ✅ قائمة المفاتيح فقط
  static List<String> get allKeys => categoryIcons.keys.toList();

  /// ✅ عدد الأيقونات المتاحة
  static int get count => categoryIcons.length;
}

/// ✅ نموذج لعنصر في Icon Picker
class IconPickerItem {
  final String key;
  final IconData icon;

  const IconPickerItem({
    required this.key,
    required this.icon,
  });
}
