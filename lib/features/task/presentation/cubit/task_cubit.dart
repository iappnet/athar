import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/automation_service.dart';
import 'package:athar/core/services/file_service.dart';
import 'package:athar/core/services/sync_service.dart';
import 'package:athar/core/services/task_notification_scheduler.dart';
import 'package:athar/features/settings/data/repositories/category_repository.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/task/data/models/attachment_model.dart';
import 'package:athar/features/task/data/models/task_note_model.dart';
import 'package:athar/features/task/domain/models/conflict_result.dart';
import 'package:athar/features/task/domain/models/filter_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/models/task_model.dart';
import '../../../../core/time_engine/time_slot_mixin.dart';
import 'task_state.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/settings/data/models/category_model.dart';
import '../../../../core/utils/smart_zone_helper.dart';
import 'package:athar/core/iam/permission_service.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:athar/features/task/data/models/recurrence_pattern.dart';
import 'package:athar/features/task/data/models/task_template.dart';

enum TaskSortMode { manual, eisenhower, time }

@injectable
class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repository;
  final SettingsRepository _settingsRepository;
  final CategoryRepository _categoryRepository;
  final SyncService _syncService = getIt<SyncService>();
  final TaskNotificationScheduler _taskNotificationScheduler;
  final SpaceRepository _spaceRepository;
  final PermissionService _permissionService;

  StreamSubscription? _tasksSubscription;
  StreamSubscription? _settingsSubscription;
  StreamSubscription? _categoriesSubscription;

  List<TaskModel> _cachedTasks = [];
  List<CategoryModel> _cachedCategories = [];
  UserSettings _cachedSettings = UserSettings();
  TaskModel? _lastDeletedTask;

  TaskSortMode _currentSortMode = TaskSortMode.manual;

  final ValueNotifier<DateTime> selectedDateNotifier = ValueNotifier(
    DateTime.now(),
  );

  // ✅ للعمليات الجماعية
  final Set<int> _selectedTaskIds = {};

  TaskCubit(
    this._repository,
    this._settingsRepository,
    this._categoryRepository,
    this._spaceRepository,
    this._permissionService,
    this._taskNotificationScheduler,
  ) : super(TaskInitial());

  // --- 1. المراقبة والجلب ---

  void watchTasks(DateTime date) async {
    selectedDateNotifier.value = date;
    emit(TaskLoading());
    _tasksSubscription?.cancel();
    _settingsSubscription?.cancel();
    _categoriesSubscription?.cancel();

    _categoriesSubscription = _categoryRepository.watchCategories().listen((
      categories,
    ) {
      _cachedCategories = categories;
      _refreshStateWithNewFilters();
    });

    _tasksSubscription = _repository.watchTasksByDate(date).listen((tasks) {
      _cachedTasks = tasks;
      _emitStateWithSmartFilter();
    });

    _settingsSubscription = _settingsRepository.watchSettings().listen((
      settings,
    ) {
      _cachedSettings = settings;
      _emitStateWithSmartFilter();
    });
  }

  void watchModuleTasks(String moduleId) {
    _tasksSubscription?.cancel();
    _settingsSubscription?.cancel();
    _categoriesSubscription?.cancel();

    emit(TaskLoading());

    _tasksSubscription = _repository.watchModuleTasks(moduleId).listen((tasks) {
      final sortedTasks = _applySort(tasks, _currentSortMode);
      _cachedTasks = sortedTasks;

      emit(
        TaskLoaded(
          tasks: sortedTasks,
          activeFilter: FixedFilterType.all,
          availableFilters: [],
        ),
      );
    }, onError: (e) => emit(TaskError(e.toString())));
  }

  // --- 2. الفلترة والترتيب ---

  void changeSortMode(TaskSortMode mode) {
    _currentSortMode = mode;
    if (state is TaskLoaded) {
      final currentTasks = (state as TaskLoaded).tasks;
      final sorted = _applySort(currentTasks, mode);
      emit((state as TaskLoaded).copyWith(tasks: sorted));
    }
  }

  List<TaskModel> _applySort(List<TaskModel> tasks, TaskSortMode mode) {
    List<TaskModel> sorted = List.of(tasks);

    switch (mode) {
      case TaskSortMode.manual:
        sorted.sort((a, b) => a.position.compareTo(b.position));
        break;

      case TaskSortMode.time:
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;

      case TaskSortMode.eisenhower:
        sorted.sort((a, b) {
          int scoreA = (a.isImportant ? 2 : 0) + (a.isUrgent ? 1 : 0);
          int scoreB = (b.isImportant ? 2 : 0) + (b.isUrgent ? 1 : 0);

          if (scoreA != scoreB) {
            return scoreB.compareTo(scoreA);
          } else {
            return a.date.compareTo(b.date);
          }
        });
        break;
    }
    return sorted;
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    if (state is! TaskLoaded) return;

    final currentTasks = List<TaskModel>.from((state as TaskLoaded).tasks);

    if (oldIndex < newIndex) newIndex -= 1;
    final item = currentTasks.removeAt(oldIndex);
    currentTasks.insert(newIndex, item);

    _currentSortMode = TaskSortMode.manual;

    for (int i = 0; i < currentTasks.length; i++) {
      currentTasks[i].position = i.toDouble();
    }

    emit((state as TaskLoaded).copyWith(tasks: currentTasks));

    for (var task in currentTasks) {
      await _repository.updateTask(task);
    }
  }

  void _refreshStateWithNewFilters() {
    if (isClosed) return;
    _emitStateWithSmartFilter();
  }

  Future<void> syncData() async {
    emit(TaskLoading());
    try {
      await _syncService.syncTasks();
      refresh();
    } catch (e) {
      emit(TaskError("فشل المزامنة"));
    }
  }

  List<FilterItem> _buildFiltersList() {
    final uniqueCategories = _cachedCategories
        .map((c) => CategoryFilter(c))
        .toSet()
        .toList();

    return [
      FixedFilterType.all,
      FixedFilterType.urgent,
      FixedFilterType.important,
      ...uniqueCategories,
    ];
  }

  void _emitStateWithSmartFilter() {
    final allFilters = _buildFiltersList();
    FilterItem activeFilter = FixedFilterType.all;

    if (state is TaskLoaded) {
      final current = (state as TaskLoaded).activeFilter;
      if (current != FixedFilterType.all &&
          allFilters.any((f) => f.id == current.id)) {
        activeFilter = current;
      }
    }

    if (activeFilter == FixedFilterType.all &&
        _cachedSettings.isAutoModeEnabled) {
      final zoneKey = SmartZoneHelper.getCurrentZoneKey(_cachedSettings);
      int? targetCategoryId;

      switch (zoneKey) {
        case 'work':
          targetCategoryId = _cachedSettings.workCategoryId;
          break;
        case 'home':
          targetCategoryId = _cachedSettings.familyCategoryId;
          break;
        case 'quiet':
          targetCategoryId = _cachedSettings.quietCategoryId;
          break;
      }

      CategoryModel? foundCategory;

      if (targetCategoryId != null) {
        try {
          foundCategory = _cachedCategories.firstWhere(
            (c) => c.id == targetCategoryId,
          );
        } catch (_) {}
      }

      if (foundCategory == null) {
        try {
          if (zoneKey == 'work') {
            foundCategory = _cachedCategories.firstWhere(
              (c) =>
                  c.name.contains('عمل') ||
                  c.name.toLowerCase().contains('work'),
            );
          } else if (zoneKey == 'home') {
            foundCategory = _cachedCategories.firstWhere(
              (c) =>
                  c.name.contains('منزل') ||
                  c.name.toLowerCase().contains('home'),
            );
          }
        } catch (_) {}
      }

      if (foundCategory != null) {
        activeFilter = CategoryFilter(foundCategory);
      }
    }

    emit(
      TaskLoaded(
        tasks: _cachedTasks,
        activeFilter: activeFilter,
        availableFilters: allFilters,
      ),
    );
  }

  void changeFilter(FilterItem filter) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(currentState.copyWith(activeFilter: filter));
    }
  }

  // --- 3. العمليات (CRUD) ---

  Future<void> addTask({
    required String title,
    required DateTime date,
    bool isUrgent = false,
    bool isImportant = false,
    CategoryModel? category,
    int duration = 30,
    String? moduleId,
    String? spaceId,
    String? assigneeId,
    bool isReminderEnabled = false,
    DateTime? reminderTime,
    RecurrencePattern? recurrence, // ✅ جديد
  }) async {
    try {
      DateTime? validReminderTime = reminderTime;
      if (isReminderEnabled && reminderTime != null) {
        if (reminderTime.isAfter(DateTime.now())) {
          validReminderTime = reminderTime;
        }
      }

      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

      // ✅ إذا كان هناك تكرار، نولّد المهام المتكررة
      if (recurrence != null && recurrence.type != RecurrenceType.none) {
        await _createRecurringTasks(
          title: title,
          baseDate: date,
          isUrgent: isUrgent,
          isImportant: isImportant,
          category: category,
          duration: duration,
          moduleId: moduleId,
          spaceId: spaceId,
          assigneeId: assigneeId,
          reminderTime: validReminderTime,
          recurrence: recurrence,
          userId: userId,
        );
        return;
      }

      // ✅ مهمة عادية (غير متكررة)
      final newTask = TaskModel(
        title: title,
        date: date,
        isUrgent: isUrgent,
        isImportant: isImportant,
        durationMinutes: duration,
        status: TaskStatus.todo,
        isCompleted: false,
        uuid: const Uuid().v4(),
        userId: userId,
        isSynced: false,
        categoryId: category?.id,
        moduleId: moduleId,
        spaceId: spaceId,
        assigneeId: assigneeId,
        reminderTime: validReminderTime,
        position: _cachedTasks.length.toDouble(),
        isRecurring: false,
      );

      if (category != null) {
        newTask.category.value = category;
      }

      await _repository.addTask(newTask);

      if (validReminderTime != null) {
        await _taskNotificationScheduler.scheduleTask(newTask);
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error adding task: $e");
      debugPrint("Stack trace: $stackTrace");
      emit(TaskError("فشل إضافة المهمة: تأكد من البيانات"));
    }
  }

  // ✅ دالة إنشاء المهام المتكررة
  Future<void> _createRecurringTasks({
    required String title,
    required DateTime baseDate,
    required bool isUrgent,
    required bool isImportant,
    CategoryModel? category,
    required int duration,
    String? moduleId,
    String? spaceId,
    String? assigneeId,
    DateTime? reminderTime,
    required RecurrencePattern recurrence,
    required String userId,
  }) async {
    // إنشاء معرف فريد للسلسلة المتكررة
    final parentRecurrenceId = const Uuid().v4();

    // توليد التواريخ المتكررة
    final occurrences = recurrence.generateOccurrences(
      from: baseDate,
      limit: 100, // حد أقصى 100 تكرار
    );

    for (var occurrenceDate in occurrences) {
      // حساب وقت التذكير لكل تكرار
      DateTime? occurrenceReminderTime;
      if (reminderTime != null) {
        final reminderOffset = baseDate.difference(reminderTime);
        occurrenceReminderTime = occurrenceDate.subtract(reminderOffset);
      }

      final task = TaskModel(
        title: title,
        date: occurrenceDate,
        isUrgent: isUrgent,
        isImportant: isImportant,
        durationMinutes: duration,
        status: TaskStatus.todo,
        isCompleted: false,
        uuid: const Uuid().v4(),
        userId: userId,
        isSynced: false,
        categoryId: category?.id,
        moduleId: moduleId,
        spaceId: spaceId,
        assigneeId: assigneeId,
        reminderTime: occurrenceReminderTime,
        position: _cachedTasks.length.toDouble(),
        isRecurring: true,
        recurrence: recurrence,
        parentRecurrenceId: parentRecurrenceId,
        occurrenceDate: occurrenceDate,
      );

      if (category != null) {
        task.category.value = category;
      }

      await _repository.addTask(task);

      // جدولة الإشعار
      if (occurrenceReminderTime != null &&
          occurrenceReminderTime.isAfter(DateTime.now())) {
        await _taskNotificationScheduler.scheduleTask(task);
      }
    }
  }

  /// ✅ إضافة مهمة مع إعدادات الوقت الشرعي
  Future<void> addTaskWithTimeSlot({
    required String title,
    required DateTime date,
    TimeSlotSettings? timeSettings,
    bool isUrgent = false,
    bool isImportant = false,
    CategoryModel? category,
    int duration = 30,
    String? moduleId,
    String? spaceId,
    String? assigneeId,
    DateTime? reminderTime,
  }) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

      final newTask = TaskModel(
        title: title,
        date: date,
        isUrgent: isUrgent,
        isImportant: isImportant,
        durationMinutes: duration,
        status: TaskStatus.todo,
        isCompleted: false,
        uuid: const Uuid().v4(),
        userId: userId,
        isSynced: false,
        categoryId: category?.id,
        moduleId: moduleId,
        spaceId: spaceId,
        assigneeId: assigneeId,
        reminderTime: reminderTime,
        position: _cachedTasks.length.toDouble(),
        isRecurring: false,
      );

      if (timeSettings != null) {
        newTask.applyTimeSettings(timeSettings);
      }

      if (category != null) {
        newTask.category.value = category;
      }

      await _repository.addTask(newTask);

      if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
        await _taskNotificationScheduler.scheduleTask(newTask);
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error adding task with time slot: $e");
      debugPrint("Stack trace: $stackTrace");
      emit(TaskError("فشل إضافة المهمة"));
    }
  }

  Future<void> addTaskModel(TaskModel task) async {
    try {
      await _repository.addTask(task);
    } catch (e) {
      emit(TaskError("فشل التعديل"));
    }
  }

  Future<void> updateTaskStatus(TaskModel task, TaskStatus newStatus) async {
    try {
      await _repository.updateTaskStatus(task.id, newStatus);
    } catch (e) {
      emit(TaskError("فشل نقل المهمة"));
    }
  }

  Future<void> saveCompletionNote(TaskModel task, String note) async {
    if (note.trim().isEmpty) return;
    await _repository.updateTask(task..completionNote = note);
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    try {
      await _repository.toggleTaskCompletion(task.id, !task.isCompleted);
    } catch (e) {
      debugPrint("Error toggling task: $e");
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      if (state is TaskLoaded) {
        final taskToDelete = (state as TaskLoaded).tasks.firstWhere(
          (t) => t.id == taskId,
          orElse: () =>
              TaskModel(title: '', date: DateTime.now(), uuid: '', userId: ''),
        );

        if (taskToDelete.uuid.isNotEmpty) {
          if (taskToDelete.spaceId != null) {
            final members = await _spaceRepository.getSpaceMembers(
              taskToDelete.spaceId!,
            );
            final myId = _permissionService.currentUserId;

            final mySpaceRecord = members.firstWhere(
              (m) => m['user_id'] == myId,
              orElse: () => {'role': 'member'},
            );

            final isSpaceAdmin =
                mySpaceRecord['role'] == 'owner' ||
                mySpaceRecord['role'] == 'admin';

            final canDelete = _permissionService.canDeleteTask(
              task: taskToDelete,
              isSpaceAdmin: isSpaceAdmin,
              isModuleAdmin: false,
            );

            if (!canDelete) {
              emit(TaskError("PERMISSION_DENIED"));
              _emitStateWithSmartFilter();
              return;
            }
          }
        }

        if (taskToDelete.id != Isar.autoIncrement) {
          await taskToDelete.category.load();
          _lastDeletedTask = taskToDelete;

          if (taskToDelete.uuid.isNotEmpty) {
            await _taskNotificationScheduler.cancelTask(taskToDelete.uuid);
          }
        }
      }
      await _repository.deleteTask(taskId);
    } catch (e) {
      emit(TaskError("Failed to delete task"));
      _emitStateWithSmartFilter();
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedTask != null) {
      try {
        final task = _lastDeletedTask!;
        task.deletedAt = null;
        task.isSynced = false;
        task.updatedAt = DateTime.now();

        await _repository.addTask(task);

        if (task.reminderTime != null &&
            task.reminderTime!.isAfter(DateTime.now())) {
          await _taskNotificationScheduler.scheduleTask(task);
        }
        _lastDeletedTask = null;
      } catch (e) {
        emit(TaskError("فشل استرجاع المهمة"));
      }
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _taskNotificationScheduler.cancelTask(task.uuid);
      await _repository.updateTask(task);

      if (task.reminderTime != null &&
          task.reminderTime!.isAfter(DateTime.now())) {
        await _taskNotificationScheduler.scheduleTask(task);
      }

      if (task.automationLinkId != null) {
        getIt<AutomationService>().syncCompletion(
          task.automationLinkId!,
          task.isCompleted,
        );
      }
    } catch (e) {
      emit(TaskError("فشل تحديث المهمة: $e"));
    }
  }

  // --- 4. التحقق والمنطق ---

  Future<ConflictResult> validateTimeConflict({
    required DateTime date,
    required TimeOfDay startTime,
    required int durationMinutes,
    int? excludeTaskId,
  }) async {
    try {
      final newStart = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );
      final newEnd = newStart.add(Duration(minutes: durationMinutes));

      final dayTasks = await _repository.getTasksForDay(date);

      for (var task in dayTasks) {
        if (excludeTaskId != null && task.id == excludeTaskId) continue;
        if (task.time == null) continue;

        final taskStart = task.time!;
        final taskEnd = task.time!.add(Duration(minutes: task.durationMinutes));

        if (newStart.isBefore(taskEnd) && newEnd.isAfter(taskStart)) {
          return ConflictResult.alert(
            "يوجد تعارض مع مهمة: ${task.title}",
            suggestedTime: taskEnd,
          );
        }
      }
      return ConflictResult.none();
    } catch (e) {
      return ConflictResult.none();
    }
  }

  // ✅ دوال القوالب
  Future<void> saveTemplate(TaskTemplate template) async {
    try {
      // حفظ في قاعدة البيانات
      // await _repository.saveTemplate(template);
    } catch (e) {
      emit(TaskError("فشل حفظ القالب"));
    }
  }

  Future<List<TaskTemplate>> loadTemplates() async {
    try {
      // جلب من قاعدة البيانات
      // return await _repository.getTemplates();
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteTemplate(int templateId) async {
    try {
      // await _repository.deleteTemplate(templateId);
    } catch (e) {
      emit(TaskError("فشل حذف القالب"));
    }
  }

  // ✅ العمليات الجماعية (Bulk Operations)

  void toggleTaskSelection(int taskId) {
    if (_selectedTaskIds.contains(taskId)) {
      _selectedTaskIds.remove(taskId);
    } else {
      _selectedTaskIds.add(taskId);
    }

    if (state is TaskLoaded) {
      emit((state as TaskLoaded).copyWith());
    }
  }

  void clearSelection() {
    _selectedTaskIds.clear();
    if (state is TaskLoaded) {
      emit((state as TaskLoaded).copyWith());
    }
  }

  Set<int> get selectedTaskIds => Set.unmodifiable(_selectedTaskIds);

  Future<void> completeSelectedTasks() async {
    try {
      for (var taskId in _selectedTaskIds) {
        await _repository.toggleTaskCompletion(taskId, true);
      }
      clearSelection();
    } catch (e) {
      emit(TaskError("فشل إكمال المهام"));
    }
  }

  Future<void> deleteSelectedTasks() async {
    try {
      for (var taskId in _selectedTaskIds) {
        await deleteTask(taskId);
      }
      clearSelection();
    } catch (e) {
      emit(TaskError("فشل حذف المهام"));
    }
  }

  Future<void> postponeSelectedTasks(Duration duration) async {
    try {
      if (state is! TaskLoaded) return;

      final tasks = (state as TaskLoaded).tasks;

      for (var taskId in _selectedTaskIds) {
        final task = tasks.firstWhere((t) => t.id == taskId);
        task.date = task.date.add(duration);

        if (task.reminderTime != null) {
          task.reminderTime = task.reminderTime!.add(duration);
        }

        await updateTask(task);
      }

      clearSelection();
    } catch (e) {
      emit(TaskError("فشل تأجيل المهام"));
    }
  }

  Future<void> assignSelectedTasks(String userId) async {
    try {
      if (state is! TaskLoaded) return;

      final tasks = (state as TaskLoaded).tasks;

      for (var taskId in _selectedTaskIds) {
        final task = tasks.firstWhere((t) => t.id == taskId);
        await _repository.assignTask(taskUuid: task.uuid, userId: userId);
      }

      clearSelection();
    } catch (e) {
      emit(TaskError("فشل إسناد المهام"));
    }
  }

  // --- الملاحظات والمرفقات ---

  Future<void> saveMyNote(String taskId, String content) async {
    try {
      await _repository.upsertMyNote(taskId: taskId, content: content);
    } catch (e) {
      emit(TaskError("فشل حفظ الملاحظة"));
    }
  }

  Stream<List<TaskNoteModel>> watchTaskNotes(String taskId) {
    _repository.fetchRemoteNotes(taskId);
    return _repository.watchTaskNotes(taskId);
  }

  Future<void> pickAndAddAttachment({
    required String taskId,
    required String spaceType,
    bool isImage = true,
  }) async {
    try {
      final fileService = getIt<FileService>();
      final file = await fileService.pickFile(isImage: isImage);
      if (file == null) return;

      final result = await fileService.processAndQueueFile(
        file: file,
        relatedEntityUuid: taskId,
        entityType: 'task',
        spaceType: spaceType,
      );

      await _repository.addAttachment(taskId, result);
    } catch (e) {
      emit(TaskError("فشل إضافة المرفق: $e"));
    }
  }

  Future<void> deleteAttachment(String uuid) async {
    try {
      await _repository.deleteAttachment(uuid);
    } catch (e) {
      emit(TaskError("فشل حذف الملف"));
    }
  }

  Stream<List<AttachmentModel>> watchAttachments(String taskId) {
    return _repository.watchAttachments(taskId);
  }

  Future<void> requestResurrection(String uuid) async {
    try {
      await _repository.requestResurrection(uuid);
    } catch (e) {
      emit(TaskError("فشل إرسال طلب الإحياء"));
    }
  }

  void refresh() {
    watchTasks(selectedDateNotifier.value);
  }

  // --- الإسناد ---

  Future<void> pickupTask(TaskModel task) async {
    final currentUserId = _permissionService.currentUserId;
    if (currentUserId == null) return;

    if (task.assigneeId == null) {
      try {
        await _repository.assignTask(
          taskUuid: task.uuid,
          userId: currentUserId,
        );
      } catch (e) {
        emit(TaskError("فشل سحب المهمة"));
      }
    }
  }

  Future<void> assignTaskToUser(TaskModel task, String targetUserId) async {
    try {
      await _repository.assignTask(taskUuid: task.uuid, userId: targetUserId);
    } catch (e) {
      emit(TaskError("فشل إسناد المهمة"));
    }
  }

  Future<void> unassignTask(TaskModel task) async {
    try {
      await _repository.assignTask(taskUuid: task.uuid, userId: null);
    } catch (e) {
      emit(TaskError("فشل إلغاء الإسناد"));
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    _settingsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    selectedDateNotifier.dispose();
    return super.close();
  }
}
// import 'dart:async';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/services/file_service.dart';
// import 'package:athar/core/services/sync_service.dart';
// import 'package:athar/features/settings/data/repositories/category_repository.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:athar/features/task/data/models/attachment_model.dart';
// import 'package:athar/features/task/data/models/task_note_model.dart';
// import 'package:athar/features/task/domain/models/conflict_result.dart';
// import 'package:athar/features/task/domain/models/filter_item.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';
// import 'package:isar/isar.dart';
// import 'package:uuid/uuid.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../domain/repositories/task_repository.dart';
// import '../../data/models/task_model.dart';
// import 'task_state.dart';
// import 'package:athar/features/settings/data/models/user_settings.dart';
// import 'package:athar/features/settings/data/models/category_model.dart';
// import '../../../../core/utils/smart_zone_helper.dart';

// @injectable
// class TaskCubit extends Cubit<TaskState> {
//   final TaskRepository _repository;
//   final SettingsRepository _settingsRepository;
//   final CategoryRepository _categoryRepository;
//   final SyncService _syncService = getIt<SyncService>();

//   StreamSubscription? _tasksSubscription;
//   StreamSubscription? _settingsSubscription;
//   StreamSubscription? _categoriesSubscription;

//   List<TaskModel> _cachedTasks = [];
//   List<CategoryModel> _cachedCategories = [];
//   UserSettings _cachedSettings = UserSettings();
//   TaskModel? _lastDeletedTask;

//   final ValueNotifier<DateTime> selectedDateNotifier = ValueNotifier(
//     DateTime.now(),
//   );

//   TaskCubit(
//     this._repository,
//     this._settingsRepository,
//     this._categoryRepository,
//   ) : super(TaskInitial());

//   // --- 1. المراقبة والجلب ---

//   void watchTasks(DateTime date) async {
//     selectedDateNotifier.value = date;
//     emit(TaskLoading());
//     _tasksSubscription?.cancel();
//     _settingsSubscription?.cancel();
//     _categoriesSubscription?.cancel();

//     _categoriesSubscription = _categoryRepository.watchCategories().listen((
//       categories,
//     ) {
//       _cachedCategories = categories;
//       _refreshStateWithNewFilters();
//     });

//     _tasksSubscription = _repository.watchTasksByDate(date).listen((tasks) {
//       _cachedTasks = tasks;
//       _emitStateWithSmartFilter();
//     });

//     _settingsSubscription = _settingsRepository.watchSettings().listen((
//       settings,
//     ) {
//       _cachedSettings = settings;
//       _emitStateWithSmartFilter();
//     });
//   }

//   // ✅ الدالة التي كانت تسبب المشكلة (الآن ستعمل لأننا حدثنا الـ Repository)
//   void watchModuleTasks(String moduleId) {
//     _tasksSubscription?.cancel();
//     _settingsSubscription?.cancel();
//     _categoriesSubscription?.cancel();

//     emit(TaskLoading());

//     _tasksSubscription = _repository.watchModuleTasks(moduleId).listen((tasks) {
//       _cachedTasks = tasks;
//       // في صفحة الموديول، لا نحتاج لفلاتر معقدة حالياً
//       emit(
//         TaskLoaded(
//           tasks: tasks,
//           activeFilter: FixedFilterType.all,
//           availableFilters: [],
//         ),
//       );
//     }, onError: (e) => emit(TaskError(e.toString())));
//   }

//   // --- 2. الفلترة والمنطق ---

//   void _refreshStateWithNewFilters() {
//     if (isClosed) return;
//     _emitStateWithSmartFilter();
//   }

//   Future<void> syncData() async {
//     emit(TaskLoading());
//     try {
//       await _syncService.syncTasks();
//       refresh();
//     } catch (e) {
//       emit(TaskError("فشل المزامنة"));
//     }
//   }

//   List<FilterItem> _buildFiltersList() {
//     final uniqueCategories = _cachedCategories
//         .map((c) => CategoryFilter(c))
//         .toSet()
//         .toList();

//     return [
//       FixedFilterType.all,
//       FixedFilterType.urgent,
//       FixedFilterType.important,
//       ...uniqueCategories,
//     ];
//   }

//   void _emitStateWithSmartFilter() {
//     final allFilters = _buildFiltersList();
//     FilterItem activeFilter = FixedFilterType.all;

//     if (state is TaskLoaded) {
//       final current = (state as TaskLoaded).activeFilter;
//       if (current != FixedFilterType.all &&
//           allFilters.any((f) => f.id == current.id)) {
//         activeFilter = current;
//       }
//     }

//     if (activeFilter == FixedFilterType.all &&
//         _cachedSettings.isAutoModeEnabled) {
//       final zoneKey = SmartZoneHelper.getCurrentZoneKey(_cachedSettings);
//       int? targetCategoryId;

//       switch (zoneKey) {
//         case 'work':
//           targetCategoryId = _cachedSettings.workCategoryId;
//           break;
//         case 'home':
//           targetCategoryId = _cachedSettings.familyCategoryId;
//           break;
//         case 'quiet':
//           targetCategoryId = _cachedSettings.quietCategoryId;
//           break;
//       }

//       CategoryModel? foundCategory;

//       if (targetCategoryId != null) {
//         try {
//           foundCategory = _cachedCategories.firstWhere(
//             (c) => c.id == targetCategoryId,
//           );
//         } catch (_) {}
//       }

//       if (foundCategory == null) {
//         try {
//           if (zoneKey == 'work') {
//             foundCategory = _cachedCategories.firstWhere(
//               (c) =>
//                   c.name.contains('عمل') ||
//                   c.name.toLowerCase().contains('work'),
//             );
//           } else if (zoneKey == 'home') {
//             foundCategory = _cachedCategories.firstWhere(
//               (c) =>
//                   c.name.contains('منزل') ||
//                   c.name.toLowerCase().contains('home'),
//             );
//           }
//         } catch (_) {}
//       }

//       if (foundCategory != null) {
//         activeFilter = CategoryFilter(foundCategory);
//       }
//     }

//     emit(
//       TaskLoaded(
//         tasks: _cachedTasks,
//         activeFilter: activeFilter,
//         availableFilters: allFilters,
//       ),
//     );
//   }

//   void changeFilter(FilterItem filter) {
//     if (state is TaskLoaded) {
//       final currentState = state as TaskLoaded;
//       emit(currentState.copyWith(activeFilter: filter));
//     }
//   }

//   // --- 3. العمليات (CRUD) ---

//   Future<void> addTask({
//     required String title,
//     required DateTime date,
//     bool isUrgent = false,
//     bool isImportant = false,
//     CategoryModel? category,
//     int duration = 30,
//     // الحقول الجديدة للموديولات
//     String? moduleId,
//     String? spaceId,
//   }) async {
//     try {
//       final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

//       final newTask = TaskModel(
//         title: title,
//         date: date,
//         isUrgent: isUrgent,
//         isImportant: isImportant,
//         durationMinutes: duration,
//         status: TaskStatus.todo,
//         isCompleted: false,
//         uuid: const Uuid().v4(),
//         userId: userId,
//         isSynced: false,
//         categoryId: category?.id,
//         // ✅ إضافة الدعم للموديولات والمساحات
//         moduleId: moduleId,
//         spaceId: spaceId,
//       );

//       if (category != null) {
//         newTask.category.value = category;
//       }

//       await _repository.addTask(newTask);
//     } catch (e, stackTrace) {
//       debugPrint("❌ Error adding task: $e");
//       debugPrint("Stack trace: $stackTrace");
//       emit(TaskError("فشل إضافة المهمة: تأكد من البيانات"));
//     }
//   }

//   Future<void> addTaskModel(TaskModel task) async {
//     try {
//       await _repository.addTask(task);
//     } catch (e) {
//       emit(TaskError("فشل التعديل"));
//     }
//   }

//   Future<void> updateTaskStatus(TaskModel task, TaskStatus newStatus) async {
//     try {
//       await _repository.updateTaskStatus(task.id, newStatus);
//     } catch (e) {
//       emit(TaskError("فشل نقل المهمة"));
//     }
//   }

//   // ✅ الدوال التي كانت معلقة خارج الكلاس تم دمجها هنا
//   Future<void> saveCompletionNote(TaskModel task, String note) async {
//     if (note.trim().isEmpty) return;
//     await _repository.updateTask(task..completionNote = note);
//   }

//   Future<void> toggleTaskCompletion(TaskModel task) async {
//     try {
//       await _repository.toggleTaskCompletion(task.id, !task.isCompleted);
//     } catch (e) {
//       debugPrint("Error toggling task: $e");
//     }
//   }

//   Future<void> deleteTask(int taskId) async {
//     try {
//       if (state is TaskLoaded) {
//         final taskToDelete = (state as TaskLoaded).tasks.firstWhere(
//           (t) => t.id == taskId,
//           orElse: () =>
//               TaskModel(title: '', date: DateTime.now(), uuid: '', userId: ''),
//         );

//         if (taskToDelete.id != Isar.autoIncrement) {
//           await taskToDelete.category.load();
//           _lastDeletedTask = taskToDelete;
//         }
//       }
//       await _repository.deleteTask(taskId);
//     } catch (e) {
//       emit(TaskError("Failed to delete task"));
//     }
//   }

//   Future<void> undoDelete() async {
//     if (_lastDeletedTask != null) {
//       try {
//         final task = _lastDeletedTask!;
//         task.deletedAt = null;
//         task.isSynced = false;
//         task.updatedAt = DateTime.now();

//         await _repository.addTask(task);
//         _lastDeletedTask = null;
//       } catch (e) {
//         emit(TaskError("فشل استرجاع المهمة"));
//       }
//     }
//   }

//   Future<void> updateTask(TaskModel task) async {
//     try {
//       await _repository.updateTask(task);
//     } catch (e) {
//       emit(TaskError("فشل تحديث المهمة: $e"));
//     }
//   }

//   // --- 4. التحقق والمنطق ---

//   Future<ConflictResult> validateTimeConflict({
//     required DateTime date,
//     required TimeOfDay startTime,
//     required int durationMinutes,
//     int? excludeTaskId,
//   }) async {
//     try {
//       final newStart = DateTime(
//         date.year,
//         date.month,
//         date.day,
//         startTime.hour,
//         startTime.minute,
//       );
//       final newEnd = newStart.add(Duration(minutes: durationMinutes));

//       final dayTasks = await _repository.getTasksForDay(date);

//       for (var task in dayTasks) {
//         if (excludeTaskId != null && task.id == excludeTaskId) continue;
//         if (task.time == null) continue;

//         final taskStart = task.time!;
//         final taskEnd = task.time!.add(Duration(minutes: task.durationMinutes));

//         if (newStart.isBefore(taskEnd) && newEnd.isAfter(taskStart)) {
//           return ConflictResult.alert(
//             "يوجد تعارض مع مهمة: ${task.title}",
//             suggestedTime: taskEnd,
//           );
//         }
//       }
//       return ConflictResult.none();
//     } catch (e) {
//       return ConflictResult.none();
//     }
//   }

//   // ✅ 1. دالة حفظ ملاحظتي (السبورة الخاصة)
//   Future<void> saveMyNote(String taskId, String content) async {
//     try {
//       await _repository.upsertMyNote(taskId: taskId, content: content);
//       // لا نحتاج لـ emit لأن الستريم سيحدث الواجهة تلقائياً
//     } catch (e) {
//       emit(TaskError("فشل حفظ الملاحظة"));
//     }
//   }

//   // ✅ 2. مراقبة سبورات الفريق
//   Stream<List<TaskNoteModel>> watchTaskNotes(String taskId) {
//     // نطلب تحديث البيانات من السحابة أولاً (في الخلفية)
//     _repository.fetchRemoteNotes(taskId);
//     // نراقب البيانات المحلية
//     return _repository.watchTaskNotes(taskId);
//   }

//   // ✅ 1. اختيار ملف وإضافته
//   Future<void> pickAndAddAttachment({
//     required String taskId,
//     required String spaceType, // 'personal' or 'shared'
//     bool isImage = true,
//   }) async {
//     try {
//       // أ. اختيار الملف
//       final file = await getIt<FileService>().pickFile(isImage: isImage);
//       if (file == null) return; // المستخدم ألغى الاختيار

//       // ب. المعالجة (ضغط + رفع إذا مشترك)
//       // ملاحظة: نعرض Loading هنا إذا أردت
//       final result = await getIt<FileService>().processAndSaveFile(
//         file: file,
//         spaceType: spaceType,
//       );

//       // ج. الحفظ في قاعدة البيانات
//       await _repository.addAttachment(taskId, result);
//     } catch (e) {
//       emit(TaskError("فشل إضافة المرفق: $e"));
//     }
//   }

//   // ✅ 2. حذف مرفق
//   Future<void> deleteAttachment(String uuid) async {
//     try {
//       await _repository.deleteAttachment(uuid);
//     } catch (e) {
//       emit(TaskError("فشل حذف الملف"));
//     }
//   }

//   // ✅ 3. مراقبة المرفقات
//   Stream<List<AttachmentModel>> watchAttachments(String taskId) {
//     return _repository.watchAttachments(taskId);
//   }

//   void refresh() {
//     watchTasks(selectedDateNotifier.value);
//   }

//   @override
//   Future<void> close() {
//     _tasksSubscription?.cancel();
//     _settingsSubscription?.cancel();
//     _categoriesSubscription?.cancel();
//     selectedDateNotifier.dispose();
//     return super.close();
//   }
// }

// import 'dart:async';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/services/sync_service.dart';
// import 'package:athar/features/settings/data/repositories/category_repository.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:athar/features/task/domain/models/conflict_result.dart';
// import 'package:athar/features/task/domain/models/filter_item.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';
// import 'package:isar/isar.dart';
// import 'package:uuid/uuid.dart';
// import '../../domain/repositories/task_repository.dart';
// import '../../data/models/task_model.dart';
// import 'task_state.dart';
// // استيرادات هامة
// import 'package:athar/features/project/data/models/project_model.dart';
// import 'package:athar/features/settings/data/models/user_settings.dart';
// import 'package:athar/features/settings/data/models/category_model.dart'; // ✅ هام للتصنيف
// import '../../../../core/utils/smart_zone_helper.dart';

// @injectable
// class TaskCubit extends Cubit<TaskState> {
//   final TaskRepository _repository;
//   final SettingsRepository _settingsRepository;
//   final CategoryRepository _categoryRepository; // أضف SyncService للمتغيرات
//   final SyncService _syncService =
//       getIt<SyncService>(); // أو حقنها في الكونستركتور

//   StreamSubscription? _tasksSubscription;
//   StreamSubscription? _settingsSubscription;
//   StreamSubscription? _categoriesSubscription; // ✅ اشتراك جديد

//   // تخزين مؤقت للبيانات لإعادة الفلترة
//   List<TaskModel> _cachedTasks = [];
//   List<CategoryModel> _cachedCategories = []; // لتسريع البحث
//   UserSettings _cachedSettings = UserSettings();
//   TaskModel? _lastDeletedTask;
//   // ✅ 1. التغيير هنا: استخدام ValueNotifier وجعله final
//   final ValueNotifier<DateTime> selectedDateNotifier = ValueNotifier(
//     DateTime.now(),
//   );

//   TaskCubit(
//     this._repository,
//     this._settingsRepository,
//     this._categoryRepository,
//   ) : super(TaskInitial());

//   // --- 1. مراقبة المهام الذكية (مع فلترة الوقت) ---
//   void watchTasks(DateTime date) async {
//     // ✅ 2. تحديث القيمة داخل Notifier
//     selectedDateNotifier.value = date;
//     emit(TaskLoading());
//     _tasksSubscription?.cancel();
//     _settingsSubscription?.cancel();
//     _categoriesSubscription?.cancel();

//     // 1. ✅ الاستماع للتصنيفات بشكل مستمر
//     _categoriesSubscription = _categoryRepository.watchCategories().listen((
//       categories,
//     ) {
//       _cachedCategories = categories;
//       // عند تحديث التصنيفات، نعيد بناء الفلاتر ونحدث الحالة
//       _refreshStateWithNewFilters();
//     });

//     // 1. تحميل التصنيفات أولاً لدمجها في الفلتر
//     _categoriesSubscription = _categoryRepository.watchCategories().listen((
//       categories,
//     ) {
//       _cachedCategories = categories;
//       // إعادة بناء الفلتر وتحديث الواجهة
//       _emitStateWithSmartFilter();
//     });

//     // 2. الاستماع للمهام
//     _tasksSubscription = _repository.watchTasksByDate(date).listen((tasks) {
//       _cachedTasks = tasks;
//       _emitStateWithSmartFilter();
//     });

//     // 3. الاستماع للإعدادات (للمناطق الذكية)
//     _settingsSubscription = _settingsRepository.watchSettings().listen((
//       settings,
//     ) {
//       _cachedSettings = settings;
//       _emitStateWithSmartFilter();
//     });
//   }

//   // ✅✅ الدالة المفقودة التي يجب إضافتها:
//   void watchProjectTasks(int projectId) {
//     _tasksSubscription?.cancel();
//     _settingsSubscription?.cancel();
//     emit(TaskLoading());

//     try {
//       _tasksSubscription = _repository.watchProjectTasks(projectId).listen((
//         tasks,
//       ) {
//         _cachedTasks = tasks;
//         // في صفحة المشروع، نعرض الكل دائماً ولا نطبق الفلتر الذكي
//         // لكن نحتاج لتمرير قائمة الفلاتر الموحدة لكي لا ينكسر الـ UI
//         // (يمكنك هنا جلب التصنيفات أيضاً إذا أردت، أو تركها فارغة مؤقتاً)
//         emit(
//           TaskLoaded(
//             tasks: tasks,
//             activeFilter: FixedFilterType.all,
//             availableFilters: [
//               FixedFilterType.all,
//             ], // أو اجلب التصنيفات هنا أيضاً
//           ),
//         );
//       }, onError: (e) => emit(TaskError(e.toString())));
//     } catch (e) {
//       emit(TaskError(e.toString()));
//     }
//   }

//   void _refreshStateWithNewFilters() {
//     if (isClosed) return;
//     _emitStateWithSmartFilter();
//   }

//   // أضف دالة جديدة
//   Future<void> syncData() async {
//     emit(TaskLoading());
//     try {
//       await _syncService.syncTasks();
//       // بعد المزامنة، نعيد جلب البيانات من Isar لتحديث الشاشة
//       refresh(); // هذه الدالة موجودة لديك مسبقاً
//     } catch (e) {
//       emit(TaskError("فشل المزامنة"));
//     }
//   }

//   // ✅ بناء قائمة الفلاتر الموحدة
//   // ✅ بناء القائمة مع إزالة التكرار (Set)
//   List<FilterItem> _buildFiltersList() {
//     // استخدام toSet() يعتمد على operator == الذي أصلحناه في الخطوة 2
//     final uniqueCategories = _cachedCategories
//         .map((c) => CategoryFilter(c))
//         .toSet()
//         .toList();

//     return [
//       FixedFilterType.all,
//       FixedFilterType.urgent,
//       FixedFilterType.important,
//       ...uniqueCategories,
//     ];
//   }

//   void _emitStateWithSmartFilter() {
//     final allFilters = _buildFiltersList();

//     // 1. تحديد الفلتر الحالي
//     FilterItem activeFilter = FixedFilterType.all;

//     // محاولة الحفاظ على الفلتر المختار يدوياً إذا كان موجوداً
//     if (state is TaskLoaded) {
//       final current = (state as TaskLoaded).activeFilter;
//       // نتأكد أنه ليس "الكل" وأنه موجود في القائمة
//       if (current != FixedFilterType.all &&
//           allFilters.any((f) => f.id == current.id)) {
//         activeFilter = current;
//       }
//     }

//     // 2. تطبيق المنطق الذكي (فقط إذا كنا في وضع "الكل" والميزة مفعلة)
//     if (activeFilter == FixedFilterType.all &&
//         _cachedSettings.isAutoModeEnabled) {
//       final zoneKey = SmartZoneHelper.getCurrentZoneKey(_cachedSettings);

//       int? targetCategoryId;

//       // أ) المحاولة الأولى: البحث عن ID مربوط في الإعدادات
//       switch (zoneKey) {
//         case 'work':
//           targetCategoryId = _cachedSettings.workCategoryId;
//           break;
//         case 'home':
//           targetCategoryId = _cachedSettings.familyCategoryId;
//           break;
//         case 'quiet':
//           targetCategoryId = _cachedSettings.quietCategoryId;
//           break;
//       }

//       CategoryModel? foundCategory;

//       // إذا وجدنا ID، نبحث عنه
//       if (targetCategoryId != null) {
//         try {
//           foundCategory = _cachedCategories.firstWhere(
//             (c) => c.id == targetCategoryId,
//           );
//         } catch (_) {}
//       }

//       // ب) المحاولة الثانية (Fallback): البحث بالاسم (المنطق القديم)
//       // هذا سيصلح المشكلة فوراً لأنك معتاد على الأسماء (عمل، منزل)
//       if (foundCategory == null) {
//         try {
//           if (zoneKey == 'work') {
//             foundCategory = _cachedCategories.firstWhere(
//               (c) =>
//                   c.name.contains('عمل') ||
//                   c.name.toLowerCase().contains('work'),
//             );
//           } else if (zoneKey == 'home') {
//             foundCategory = _cachedCategories.firstWhere(
//               (c) =>
//                   c.name.contains('منزل') ||
//                   c.name.toLowerCase().contains('home'),
//             );
//           }
//         } catch (_) {}
//       }

//       // ج) التطبيق
//       if (foundCategory != null) {
//         activeFilter = CategoryFilter(foundCategory);
//       }
//     }

//     emit(
//       TaskLoaded(
//         tasks: _cachedTasks,
//         activeFilter: activeFilter,
//         availableFilters: allFilters,
//       ),
//     );
//   }

//   // // دالة مساعدة لمطابقة المنطقة مع التصنيف
//   // bool _isCategoryMatchingZone(CategoryModel cat, String zoneKey) {
//   //   if (zoneKey == 'work' &&
//   //       (cat.name.contains('عمل') || cat.name.contains('Work'))) {
//   //     return true;
//   //   }
//   //   if (zoneKey == 'home' &&
//   //       (cat.name.contains('منزل') || cat.name.contains('Home'))) {
//   //     return true;
//   //   }
//   //   // يمكن توسيع المنطق هنا أو الاعتماد على IDs محفوظة في UserSettings
//   //   return false;
//   // }

//   void changeFilter(FilterItem filter) {
//     if (state is TaskLoaded) {
//       final currentState = state as TaskLoaded;
//       emit(currentState.copyWith(activeFilter: filter));
//     }
//   }

//   // --- 3. العمليات (CRUD) ---

//   // ✅ الدالة المصححة (تمت إزالة التكرار)
//   Future<void> addTask({
//     required String title,
//     required DateTime date,
//     bool isUrgent = false,
//     bool isImportant = false,
//     CategoryModel? category, // ✅ التصنيف الجديد
//     int duration = 30, // قيمة افتراضية لتجنب null
//     ProjectModel? project,
//   }) async {
//     try {
//       // ✅ استخدام الكونستركتور بدلاً من الـ Cascade (..)
//       // لأن title و date أصبحا required
//       final newTask = TaskModel(
//         title: title,
//         date: date,
//         isUrgent: isUrgent,
//         isImportant: isImportant,
//         durationMinutes: duration,
//         status: TaskStatus.todo,
//         isCompleted: false,
//         uuid: const Uuid().v4(), // توليد UUID جديد
//         isSynced: false,
//       );

//       // ✅ ربط المشروع
//       if (project != null) {
//         // newTask.project.value = project;
//       }

//       // ✅ ربط التصنيف
//       if (category != null) {
//         newTask.category.value = category;
//       }

//       await _repository.addTask(newTask);
//     } catch (e, stackTrace) {
//       debugPrint("❌ Error adding task: $e");
//       debugPrint("Stack trace: $stackTrace");
//       emit(TaskError("فشل إضافة المهمة: تأكد من البيانات"));
//     }
//   }

//   // إضافة دالة لدعم التعديل الكامل (للواجهة)
//   Future<void> addTaskModel(TaskModel task) async {
//     try {
//       await _repository.addTask(task);
//     } catch (e) {
//       emit(TaskError("فشل التعديل"));
//     }
//   }

//   Future<void> updateTaskStatus(TaskModel task, TaskStatus newStatus) async {
//     try {
//       await _repository.updateTaskStatus(task.id, newStatus);
//     } catch (e) {
//       emit(TaskError("فشل نقل المهمة"));
//     }
//   }

//   // ✅ دالة حفظ ملاحظة الإنجاز
//   Future<void> saveCompletionNote(TaskModel task, String note) async {
//     if (note.trim().isEmpty) return;
//     await _repository.updateTask(task..completionNote = note);
//   }

//   Future<void> toggleTaskCompletion(TaskModel task) async {
//     try {
//       await _repository.toggleTaskCompletion(task.id, !task.isCompleted);
//     } catch (e) {
//       debugPrint("Error toggling task: $e");
//     }
//   }

//   Future<void> deleteTask(int taskId) async {
//     try {
//       if (state is TaskLoaded) {
//         // ✅✅ تم إصلاح الخطأ هنا:
//         // عند عدم العثور على المهمة، نمرر TaskModel بقيم وهمية لتفادي خطأ required args
//         final taskToDelete = (state as TaskLoaded).tasks.firstWhere(
//           (t) => t.id == taskId,
//           orElse: () => TaskModel(title: '', date: DateTime.now()),
//         );

//         // ✅ التأكد من تحميل الروابط قبل الحذف للاستعادة
//         if (taskToDelete.id != Isar.autoIncrement) {
//           // await taskToDelete.project.load();
//           await taskToDelete.category.load(); // ✅ تحميل التصنيف أيضاً
//           _lastDeletedTask = taskToDelete;
//         }
//       }
//       await _repository.deleteTask(taskId);
//     } catch (e) {
//       emit(TaskError("Failed to delete task"));
//     }
//   }

//   Future<void> undoDelete() async {
//     if (_lastDeletedTask != null) {
//       try {
//         final task = _lastDeletedTask!;

//         // 1. إعادة ضبط القيم لتعود للحياة
//         task.deletedAt = null;
//         task.isSynced = false; // لتتم مزامنتها لاحقاً
//         task.updatedAt = DateTime.now();

//         // 2. استخدام دالة addTask بدلاً من updateTask
//         // لماذا؟ لأن addTask في الريبوزيتوري الخاص بك تقوم بـ:
//         // _isar.taskModels.put(task) + حفظ الروابط (Category & Project)
//         // هذا يضمن أنه لو كانت محذوفة نهائياً (Hard Delete) سيتم إعادة إنشائها مع روابطها
//         await _repository.addTask(task);

//         // 3. تنظيف الذاكرة وتحديث الواجهة
//         _lastDeletedTask = null;

//         // (اختياري) إذا كنت تستخدم watchTasks ستتحدث الواجهة تلقائياً
//         // ولكن للتحوط يمكنك استدعاء:
//         // refresh();
//       } catch (e) {
//         emit(TaskError("فشل استرجاع المهمة"));
//       }
//     }
//   }

//   // Future<void> undoDelete() async {
//   //   if (_lastDeletedTask != null) {
//   //     // بدلاً من إضافتها كجديدة، نقوم فقط بإلغاء الحذف الناعم
//   //     _lastDeletedTask!.deletedAt = null;
//   //     _lastDeletedTask!.isSynced = false; // لنخبر السيرفر أنها "عادت للحياة"
//   //     _lastDeletedTask!.updatedAt = DateTime.now();

//   //     await _repository.updateTask(_lastDeletedTask!); // دالة update عادية
//   //     _lastDeletedTask = null;
//   //   }
//   // }

//   // ✅ دالة تحديث مهمة كاملة
//   Future<void> updateTask(TaskModel task) async {
//     try {
//       await _repository.updateTask(task);
//       // (اختياري) إذا كنت تريد إعادة تحميل القائمة فوراً، رغم أن Stream سيتكفل بذلك
//       // watchTasks(_currentSelectedDate);
//     } catch (e) {
//       emit(TaskError("فشل تحديث المهمة: $e"));
//     }
//   }

//   // ✅ دالة التحقق من التعارض (المنطق المركزي)
//   Future<ConflictResult> validateTimeConflict({
//     required DateTime date,
//     required TimeOfDay startTime,
//     required int durationMinutes,
//     int? excludeTaskId, // لتجاهل المهمة نفسها عند التعديل
//   }) async {
//     try {
//       // 1. تجهيز أوقات المهمة الجديدة
//       final newStart = DateTime(
//         date.year,
//         date.month,
//         date.day,
//         startTime.hour,
//         startTime.minute,
//       );
//       final newEnd = newStart.add(Duration(minutes: durationMinutes));

//       // 2. جلب مهام اليوم من قاعدة البيانات
//       // (بفضل إصلاحنا السابق، هذه القائمة لن تحتوي على المحذوفات)
//       final dayTasks = await _repository.getTasksForDay(date);

//       // 3. البحث عن تعارض
//       for (var task in dayTasks) {
//         // إذا كنا نعدل مهمة، نتجاهل نفس المهمة
//         if (excludeTaskId != null && task.id == excludeTaskId) continue;

//         // حساب وقت المهمة الموجودة
//         // ملاحظة: افترضنا أن TaskModel يحتوي على getter لـ startTime و endTime
//         // إذا لم يكن موجوداً، سنحسبه يدوياً هنا:
//         final taskStart = task.date;
//         final taskEnd = task.date.add(Duration(minutes: task.durationMinutes));

//         // 4. معادلة تقاطع الوقت (Overlap Logic)
//         // (بداية الجديدة < نهاية القديمة) AND (نهاية الجديدة > بداية القديمة)
//         if (newStart.isBefore(taskEnd) && newEnd.isAfter(taskStart)) {
//           return ConflictResult.alert(
//             "يوجد تعارض مع مهمة: ${task.title}",
//             suggestedTime:
//                 taskEnd, // اقتراح وقت بعد انتهاء المهمة المتعارضة مباشرة
//           );
//         }
//       }

//       // إذا لم يوجد تعارض
//       return ConflictResult.none();
//     } catch (e) {
//       // في حال حدوث خطأ تقني، نسمح بالإضافة لتجنب تعطيل المستخدم
//       return ConflictResult.none();
//     }
//   }

//   void refresh() {
//     watchTasks(selectedDateNotifier.value);
//   }

//   @override
//   Future<void> close() {
//     _tasksSubscription?.cancel();
//     _settingsSubscription?.cancel();
//     _categoriesSubscription?.cancel(); // ✅ تنظيف
//     selectedDateNotifier.dispose();
//     return super.close();
//   }
// }
