import 'package:isar/isar.dart';

part 'dhikr_model.g.dart';

@collection
class DhikrModel {
  Id id = Isar.autoIncrement;

  late String text;
  int count = 1;
  int currentCount = 0;

  @Enumerated(EnumType.name)
  DhikrCategory category = DhikrCategory.morning;

  int order = 0;
  bool isCustom = false;
  String? virtue;
}

enum DhikrCategory {
  morning,
  evening,
  prayer,
  sleep, // ✅ تمت الإضافة: ضروري جداً لكي لا ينهار التطبيق عند حفظ أذكار النوم
  custom,
}
