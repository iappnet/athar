import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/space/data/models/list_item_model.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/domain/repositories/list_repository.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/task/domain/repositories/task_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';

@lazySingleton
class AutomationService {
  final TaskRepository _taskRepository;
  final ListRepository _listRepository;
  final Isar _isar;

  AutomationService(this._taskRepository, this._listRepository, this._isar);

  // 1. المحرك الرئيسي: طلب إعادة تعبئة الدواء
  Future<void> triggerMedicineRefill(
    MedicineModel medicine,
    String userId,
  ) async {
    // 🛑 فحص: إذا تم الطلب مسبقاً، لا نكرر
    if (medicine.isRefillRequested) return;

    final linkId = const Uuid().v4();

    // البحث عن المكان المناسب (نفس المساحة التي ينتمي إليها الدواء)
    final targetSpaceId = await _findSpaceIdForModule(medicine.moduleId);

    if (targetSpaceId == null) return;

    final listModuleId = await _findDefaultModuleInSpace(targetSpaceId, 'list');
    final projectModuleId = await _findDefaultModuleInSpace(
      targetSpaceId,
      'project',
    );

    // أ. إنشاء عنصر القائمة (إذا اختار list أو both)
    if (medicine.refillAction == 'list' || medicine.refillAction == 'both') {
      if (listModuleId != null) {
        final listItem = ListItemModel(
          uuid: const Uuid().v4(),
          moduleId: listModuleId,
          name: "شراء دواء: ${medicine.name}",
          quantity: 1,
          notes: "تنبيه تلقائي: المخزون وصل لـ ${medicine.stockQuantity}",
          createdBy: userId,
          automationLinkId: linkId,
        );
        await _listRepository.addItem(listItem);
      }
    }

    // ب. إنشاء المهمة (إذا اختار task أو both)
    if (medicine.refillAction == 'task' || medicine.refillAction == 'both') {
      if (projectModuleId != null) {
        final task = TaskModel(
          uuid: const Uuid().v4(),
          userId: userId,
          title: "توفير دواء: ${medicine.name}",
          date: DateTime.now().add(const Duration(days: 1)),
          moduleId: projectModuleId,
          spaceId: targetSpaceId,
          automationLinkId: linkId,
          status: TaskStatus.todo,
        );
        await _taskRepository.addTask(task);
      }
    }
  }

  // 2. التزامن العكسي
  Future<void> syncCompletion(String linkId, bool isCompleted) async {
    if (linkId.isEmpty) return;

    // تحديث القائمة
    final items = await _isar.listItemModels
        .filter()
        .automationLinkIdEqualTo(linkId)
        .findAll();

    for (var item in items) {
      if (item.isChecked != isCompleted) {
        item.isChecked = isCompleted;
        await _listRepository.updateItem(item);
      }
    }

    // تحديث المهام
    final tasks = await _isar.taskModels
        .filter()
        .automationLinkIdEqualTo(linkId)
        .findAll();

    for (var task in tasks) {
      final shouldBeCompleted = isCompleted;
      if (task.isCompleted != shouldBeCompleted) {
        task.isCompleted = shouldBeCompleted;
        // مزامنة حالة المهمة مع حالة العنصر
        task.status = shouldBeCompleted ? TaskStatus.done : TaskStatus.todo;
        await _taskRepository.updateTask(task);
      }
    }
  }

  // --- دوال مساعدة ---
  Future<String?> _findSpaceIdForModule(String moduleId) async {
    final module = await _isar.moduleModels
        .filter()
        .uuidEqualTo(moduleId)
        .findFirst();
    return module?.spaceId;
  }

  Future<String?> _findDefaultModuleInSpace(String spaceId, String type) async {
    final module = await _isar.moduleModels
        .filter()
        .spaceIdEqualTo(spaceId)
        .typeEqualTo(type)
        .findFirst();
    return module?.uuid;
  }
}
