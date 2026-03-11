enum DailyItemType { task, medicine, appointment }

class DailyItem {
  final String id;
  final DailyItemType type;
  final DateTime time; // وقت الاستحقاق
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final bool hasReminder; // ✅ إضافة جديدة

  // الاحتفاظ بالكائن الأصلي لتنفيذ الإجراءات
  final dynamic originalData;

  DailyItem({
    required this.id,
    required this.type,
    required this.time,
    required this.title,
    this.subtitle,
    this.isCompleted = false,
    required this.originalData,
    this.hasReminder = false,
  });
}
