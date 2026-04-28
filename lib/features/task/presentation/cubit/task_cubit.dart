import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/automation_service.dart';
import 'package:athar/features/stats/domain/repositories/i_stats_repository.dart';
import 'package:athar/core/services/file_service.dart';
import 'package:athar/core/services/sync_service.dart';
import 'package:athar/core/services/task_notification_scheduler.dart';
import 'package:athar/core/services/widget_data_service.dart';
import 'package:athar/core/time_engine/time_slot_mixin.dart';
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
import 'task_state.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/settings/data/models/category_model.dart';
import '../../../../core/utils/smart_zone_helper.dart';
import 'package:athar/core/config/subscription_config.dart';
import 'package:athar/core/iam/permission_service.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:athar/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:athar/features/task/data/models/recurrence_pattern.dart';
import 'package:athar/features/task/data/models/task_template.dart';

enum TaskSortMode { manual, eisenhower, time }

@injectable
class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repository;
  final SettingsRepository _settingsRepository;
  final CategoryRepository _categoryRepository;
  final SyncService _syncService;
  final WidgetDataService _widgetDataService;
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
    this._syncService,
    this._widgetDataService,
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
      if (isClosed) return;
      final sortedTasks = _applySort(tasks, _currentSortMode);
      _cachedTasks = sortedTasks;

      emit(
        TaskLoaded(
          tasks: sortedTasks,
          activeFilter: FixedFilterType.all,
          availableFilters: [],
        ),
      );
    }, onError: (e) {
      if (isClosed) return;
      emit(TaskError(e.toString()));
    });
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
    if (isClosed) return;
    emit(TaskLoading());
    try {
      await _syncService.syncTasks();
      refresh();
    } catch (e) {
      if (isClosed) return;
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
      ...uniqueCategories,
    ];
  }

  void _emitStateWithSmartFilter() {
    if (isClosed) return;
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
        final matches = _cachedCategories.where((c) => c.id == targetCategoryId);
        foundCategory = matches.isEmpty ? null : matches.first;
      }

      if (foundCategory == null) {
        if (zoneKey == 'work') {
          final matches = _cachedCategories.where(
            (c) => c.name.contains('عمل') || c.name.toLowerCase().contains('work'),
          );
          foundCategory = matches.isEmpty ? null : matches.first;
        } else if (zoneKey == 'home') {
          final matches = _cachedCategories.where(
            (c) => c.name.contains('منزل') || c.name.toLowerCase().contains('home'),
          );
          foundCategory = matches.isEmpty ? null : matches.first;
        }
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

    unawaited(_widgetDataService.pushTaskData(_cachedTasks));
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
    RecurrencePattern? recurrence,
  }) async {
    // Await first subscription load so Pro users on slow networks are not
    // incorrectly capped at the free limit during the startup race window.
    await getIt<SubscriptionCubit>().ready;
    // Free-tier limit check
    if (!getIt<SubscriptionCubit>().hasUnlimitedTasksAndHabits) {
      final activeTasks = await _repository.getActiveTasks();
      if (activeTasks.length >= SubscriptionConfig.freeTasksLimit) {
        emit(TaskFreeLimitReached());
        return;
      }
    }

    try {
      DateTime? validReminderTime = reminderTime;
      if (isReminderEnabled && reminderTime != null) {
        if (reminderTime.isAfter(DateTime.now())) {
          validReminderTime = reminderTime;
        }
      }

      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

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
        getIt<IStatsRepository>().invalidateCache();
        return;
      }

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
      getIt<IStatsRepository>().invalidateCache();

      if (validReminderTime != null) {
        await _taskNotificationScheduler.scheduleTask(newTask);
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error adding task: $e");
      debugPrint("Stack trace: $stackTrace");
      if (isClosed) return;
      emit(TaskError("فشل إضافة المهمة: تأكد من البيانات"));
    }
  }

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
    final parentRecurrenceId = const Uuid().v4();

    final occurrences = recurrence.generateOccurrences(
      from: baseDate,
      limit: 100,
    );

    for (var occurrenceDate in occurrences) {
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

      if (occurrenceReminderTime != null &&
          occurrenceReminderTime.isAfter(DateTime.now())) {
        await _taskNotificationScheduler.scheduleTask(task);
      }
    }
  }

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
    RecurrencePattern? recurrence,
  }) async {
    // Same subscription gate as addTask() — must stay in sync.
    await getIt<SubscriptionCubit>().ready;
    if (!getIt<SubscriptionCubit>().hasUnlimitedTasksAndHabits) {
      final activeTasks = await _repository.getActiveTasks();
      if (activeTasks.length >= SubscriptionConfig.freeTasksLimit) {
        emit(TaskFreeLimitReached());
        return;
      }
    }

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

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
          reminderTime: reminderTime,
          recurrence: recurrence,
          userId: userId,
        );
        return;
      }

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
      if (isClosed) return;
      emit(TaskError("فشل إضافة المهمة"));
    }
  }

  Future<void> addTaskModel(TaskModel task) async {
    try {
      await _repository.addTask(task);
    } catch (e) {
      if (isClosed) return;
      emit(TaskError("فشل التعديل"));
    }
  }

  Future<void> updateTaskStatus(TaskModel task, TaskStatus newStatus) async {
    try {
      await _repository.updateTaskStatus(task.id, newStatus);
    } catch (e) {
      if (isClosed) return;
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
      getIt<IStatsRepository>().invalidateCache();
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
      getIt<IStatsRepository>().invalidateCache();
    } catch (e) {
      if (isClosed) return;
      emit(TaskError("فشل حذف المهمة"));
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
        if (isClosed) return;
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
      if (isClosed) return;
      emit(TaskError("فشل تحديث المهمة"));
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

  Future<void> saveTemplate(TaskTemplate template) async {
    try {
      // await _repository.saveTemplate(template);
    } catch (e) {
      if (isClosed) return;
      emit(TaskError("فشل حفظ القالب"));
    }
  }

  Future<List<TaskTemplate>> loadTemplates() async {
    try {
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
      if (isClosed) return;
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
      if (isClosed) return;
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
      if (isClosed) return;
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
      if (isClosed) return;
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
      if (isClosed) return;
      emit(TaskError("فشل إسناد المهام"));
    }
  }

  // --- الملاحظات والمرفقات ---

  Future<void> saveMyNote(String taskId, String content) async {
    try {
      await _repository.upsertMyNote(taskId: taskId, content: content);
    } catch (e) {
      if (isClosed) return;
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
      if (isClosed) return;
      emit(TaskError("فشل إضافة المرفق"));
    }
  }

  Future<void> deleteAttachment(String uuid) async {
    try {
      await _repository.deleteAttachment(uuid);
    } catch (e) {
      if (isClosed) return;
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
      if (isClosed) return;
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
        if (isClosed) return;
        emit(TaskError("فشل سحب المهمة"));
      }
    }
  }

  Future<void> assignTaskToUser(TaskModel task, String targetUserId) async {
    try {
      await _repository.assignTask(taskUuid: task.uuid, userId: targetUserId);
    } catch (e) {
      if (isClosed) return;
      emit(TaskError("فشل إسناد المهمة"));
    }
  }

  Future<void> unassignTask(TaskModel task) async {
    try {
      await _repository.assignTask(taskUuid: task.uuid, userId: null);
    } catch (e) {
      if (isClosed) return;
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
