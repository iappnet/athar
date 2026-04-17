// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTaskModelCollection on Isar {
  IsarCollection<TaskModel> get taskModels => this.collection();
}

const TaskModelSchema = CollectionSchema(
  name: r'TaskModel',
  id: -1192054402460482572,
  properties: {
    r'assignedTo': PropertySchema(
      id: 0,
      name: r'assignedTo',
      type: IsarType.string,
    ),
    r'assigneeId': PropertySchema(
      id: 1,
      name: r'assigneeId',
      type: IsarType.string,
    ),
    r'assigneesIds': PropertySchema(
      id: 2,
      name: r'assigneesIds',
      type: IsarType.stringList,
    ),
    r'automationLinkId': PropertySchema(
      id: 3,
      name: r'automationLinkId',
      type: IsarType.string,
    ),
    r'categoryId': PropertySchema(
      id: 4,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'completedAt': PropertySchema(
      id: 5,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'completionNote': PropertySchema(
      id: 6,
      name: r'completionNote',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 7,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdBy': PropertySchema(
      id: 8,
      name: r'createdBy',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 9,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 10,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 11,
      name: r'description',
      type: IsarType.string,
    ),
    r'durationMinutes': PropertySchema(
      id: 12,
      name: r'durationMinutes',
      type: IsarType.long,
    ),
    r'fixedHour': PropertySchema(
      id: 13,
      name: r'fixedHour',
      type: IsarType.long,
    ),
    r'fixedMinute': PropertySchema(
      id: 14,
      name: r'fixedMinute',
      type: IsarType.long,
    ),
    r'isCompleted': PropertySchema(
      id: 15,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isHidden': PropertySchema(
      id: 16,
      name: r'isHidden',
      type: IsarType.bool,
    ),
    r'isImportant': PropertySchema(
      id: 17,
      name: r'isImportant',
      type: IsarType.bool,
    ),
    r'isReassignable': PropertySchema(
      id: 18,
      name: r'isReassignable',
      type: IsarType.bool,
    ),
    r'isRecurring': PropertySchema(
      id: 19,
      name: r'isRecurring',
      type: IsarType.bool,
    ),
    r'isSampleData': PropertySchema(
      id: 20,
      name: r'isSampleData',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 21,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'isUrgent': PropertySchema(
      id: 22,
      name: r'isUrgent',
      type: IsarType.bool,
    ),
    r'moduleId': PropertySchema(
      id: 23,
      name: r'moduleId',
      type: IsarType.string,
    ),
    r'occurrenceDate': PropertySchema(
      id: 24,
      name: r'occurrenceDate',
      type: IsarType.dateTime,
    ),
    r'offsetMinutes': PropertySchema(
      id: 25,
      name: r'offsetMinutes',
      type: IsarType.long,
    ),
    r'parentRecurrenceId': PropertySchema(
      id: 26,
      name: r'parentRecurrenceId',
      type: IsarType.string,
    ),
    r'periodPositionIndex': PropertySchema(
      id: 27,
      name: r'periodPositionIndex',
      type: IsarType.long,
    ),
    r'position': PropertySchema(
      id: 28,
      name: r'position',
      type: IsarType.double,
    ),
    r'prayerRelationIndex': PropertySchema(
      id: 29,
      name: r'prayerRelationIndex',
      type: IsarType.long,
    ),
    r'priority': PropertySchema(
      id: 30,
      name: r'priority',
      type: IsarType.byte,
      enumMap: _TaskModelpriorityEnumValueMap,
    ),
    r'recurrence': PropertySchema(
      id: 31,
      name: r'recurrence',
      type: IsarType.object,
      target: r'RecurrencePattern',
    ),
    r'referencePrayerIndex': PropertySchema(
      id: 32,
      name: r'referencePrayerIndex',
      type: IsarType.long,
    ),
    r'reminderTime': PropertySchema(
      id: 33,
      name: r'reminderTime',
      type: IsarType.dateTime,
    ),
    r'spaceId': PropertySchema(
      id: 34,
      name: r'spaceId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 35,
      name: r'status',
      type: IsarType.byte,
      enumMap: _TaskModelstatusEnumValueMap,
    ),
    r'templateId': PropertySchema(
      id: 36,
      name: r'templateId',
      type: IsarType.string,
    ),
    r'time': PropertySchema(
      id: 37,
      name: r'time',
      type: IsarType.dateTime,
    ),
    r'timePeriodIndex': PropertySchema(
      id: 38,
      name: r'timePeriodIndex',
      type: IsarType.long,
    ),
    r'timeTypeIndex': PropertySchema(
      id: 39,
      name: r'timeTypeIndex',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 40,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 41,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 42,
      name: r'userId',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(
      id: 43,
      name: r'uuid',
      type: IsarType.string,
    ),
    r'visibility': PropertySchema(
      id: 44,
      name: r'visibility',
      type: IsarType.string,
    )
  },
  estimateSize: _taskModelEstimateSize,
  serialize: _taskModelSerialize,
  deserialize: _taskModelDeserialize,
  deserializeProp: _taskModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'position': IndexSchema(
      id: 5117117876086213592,
      name: r'position',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'position',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'visibility': IndexSchema(
      id: 3694774238852621761,
      name: r'visibility',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'visibility',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'assigneeId': IndexSchema(
      id: -1223177842302803329,
      name: r'assigneeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'assigneeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'spaceId': IndexSchema(
      id: -1779888219436521473,
      name: r'spaceId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'spaceId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'automationLinkId': IndexSchema(
      id: -2400648584168533702,
      name: r'automationLinkId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'automationLinkId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'moduleId': IndexSchema(
      id: 294732126243497764,
      name: r'moduleId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'moduleId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'categoryId': IndexSchema(
      id: -8798048739239305339,
      name: r'categoryId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'categoryId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'attachments': LinkSchema(
      id: 1774185833264094556,
      name: r'attachments',
      target: r'AttachmentModel',
      single: false,
    ),
    r'category': LinkSchema(
      id: 5737870565558117497,
      name: r'category',
      target: r'CategoryModel',
      single: true,
    )
  },
  embeddedSchemas: {r'RecurrencePattern': RecurrencePatternSchema},
  getId: _taskModelGetId,
  getLinks: _taskModelGetLinks,
  attach: _taskModelAttach,
  version: '3.1.0+1',
);

int _taskModelEstimateSize(
  TaskModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.assignedTo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assigneeId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.assigneesIds;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.automationLinkId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.completionNote;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.createdBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.moduleId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.parentRecurrenceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.recurrence;
    if (value != null) {
      bytesCount += 3 +
          RecurrencePatternSchema.estimateSize(
              value, allOffsets[RecurrencePattern]!, allOffsets);
    }
  }
  {
    final value = object.spaceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.templateId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  bytesCount += 3 + object.visibility.length * 3;
  return bytesCount;
}

void _taskModelSerialize(
  TaskModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.assignedTo);
  writer.writeString(offsets[1], object.assigneeId);
  writer.writeStringList(offsets[2], object.assigneesIds);
  writer.writeString(offsets[3], object.automationLinkId);
  writer.writeLong(offsets[4], object.categoryId);
  writer.writeDateTime(offsets[5], object.completedAt);
  writer.writeString(offsets[6], object.completionNote);
  writer.writeDateTime(offsets[7], object.createdAt);
  writer.writeString(offsets[8], object.createdBy);
  writer.writeDateTime(offsets[9], object.date);
  writer.writeDateTime(offsets[10], object.deletedAt);
  writer.writeString(offsets[11], object.description);
  writer.writeLong(offsets[12], object.durationMinutes);
  writer.writeLong(offsets[13], object.fixedHour);
  writer.writeLong(offsets[14], object.fixedMinute);
  writer.writeBool(offsets[15], object.isCompleted);
  writer.writeBool(offsets[16], object.isHidden);
  writer.writeBool(offsets[17], object.isImportant);
  writer.writeBool(offsets[18], object.isReassignable);
  writer.writeBool(offsets[19], object.isRecurring);
  writer.writeBool(offsets[20], object.isSampleData);
  writer.writeBool(offsets[21], object.isSynced);
  writer.writeBool(offsets[22], object.isUrgent);
  writer.writeString(offsets[23], object.moduleId);
  writer.writeDateTime(offsets[24], object.occurrenceDate);
  writer.writeLong(offsets[25], object.offsetMinutes);
  writer.writeString(offsets[26], object.parentRecurrenceId);
  writer.writeLong(offsets[27], object.periodPositionIndex);
  writer.writeDouble(offsets[28], object.position);
  writer.writeLong(offsets[29], object.prayerRelationIndex);
  writer.writeByte(offsets[30], object.priority.index);
  writer.writeObject<RecurrencePattern>(
    offsets[31],
    allOffsets,
    RecurrencePatternSchema.serialize,
    object.recurrence,
  );
  writer.writeLong(offsets[32], object.referencePrayerIndex);
  writer.writeDateTime(offsets[33], object.reminderTime);
  writer.writeString(offsets[34], object.spaceId);
  writer.writeByte(offsets[35], object.status.index);
  writer.writeString(offsets[36], object.templateId);
  writer.writeDateTime(offsets[37], object.time);
  writer.writeLong(offsets[38], object.timePeriodIndex);
  writer.writeLong(offsets[39], object.timeTypeIndex);
  writer.writeString(offsets[40], object.title);
  writer.writeDateTime(offsets[41], object.updatedAt);
  writer.writeString(offsets[42], object.userId);
  writer.writeString(offsets[43], object.uuid);
  writer.writeString(offsets[44], object.visibility);
}

TaskModel _taskModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TaskModel(
    assignedTo: reader.readStringOrNull(offsets[0]),
    assigneeId: reader.readStringOrNull(offsets[1]),
    assigneesIds: reader.readStringList(offsets[2]),
    automationLinkId: reader.readStringOrNull(offsets[3]),
    categoryId: reader.readLongOrNull(offsets[4]),
    completionNote: reader.readStringOrNull(offsets[6]),
    createdBy: reader.readStringOrNull(offsets[8]),
    date: reader.readDateTime(offsets[9]),
    deletedAt: reader.readDateTimeOrNull(offsets[10]),
    description: reader.readStringOrNull(offsets[11]),
    durationMinutes: reader.readLongOrNull(offsets[12]) ?? 30,
    fixedHour: reader.readLongOrNull(offsets[13]),
    fixedMinute: reader.readLongOrNull(offsets[14]),
    isCompleted: reader.readBoolOrNull(offsets[15]) ?? false,
    isHidden: reader.readBoolOrNull(offsets[16]) ?? false,
    isImportant: reader.readBoolOrNull(offsets[17]) ?? false,
    isReassignable: reader.readBoolOrNull(offsets[18]) ?? true,
    isRecurring: reader.readBoolOrNull(offsets[19]) ?? false,
    isSynced: reader.readBoolOrNull(offsets[21]) ?? false,
    isUrgent: reader.readBoolOrNull(offsets[22]) ?? false,
    moduleId: reader.readStringOrNull(offsets[23]),
    occurrenceDate: reader.readDateTimeOrNull(offsets[24]),
    offsetMinutes: reader.readLongOrNull(offsets[25]) ?? 0,
    parentRecurrenceId: reader.readStringOrNull(offsets[26]),
    periodPositionIndex: reader.readLongOrNull(offsets[27]),
    position: reader.readDoubleOrNull(offsets[28]) ?? 0.0,
    prayerRelationIndex: reader.readLongOrNull(offsets[29]),
    priority:
        _TaskModelpriorityValueEnumMap[reader.readByteOrNull(offsets[30])] ??
            TaskPriority.medium,
    recurrence: reader.readObjectOrNull<RecurrencePattern>(
      offsets[31],
      RecurrencePatternSchema.deserialize,
      allOffsets,
    ),
    referencePrayerIndex: reader.readLongOrNull(offsets[32]),
    reminderTime: reader.readDateTimeOrNull(offsets[33]),
    spaceId: reader.readStringOrNull(offsets[34]),
    status: _TaskModelstatusValueEnumMap[reader.readByteOrNull(offsets[35])] ??
        TaskStatus.todo,
    templateId: reader.readStringOrNull(offsets[36]),
    time: reader.readDateTimeOrNull(offsets[37]),
    timePeriodIndex: reader.readLongOrNull(offsets[38]),
    timeTypeIndex: reader.readLongOrNull(offsets[39]) ?? 0,
    title: reader.readString(offsets[40]),
    updatedAt: reader.readDateTimeOrNull(offsets[41]),
    userId: reader.readString(offsets[42]),
    uuid: reader.readString(offsets[43]),
    visibility: reader.readStringOrNull(offsets[44]) ?? 'public',
  );
  object.completedAt = reader.readDateTimeOrNull(offsets[5]);
  object.createdAt = reader.readDateTime(offsets[7]);
  object.id = id;
  object.isSampleData = reader.readBool(offsets[20]);
  return object;
}

P _taskModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset) ?? 30) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 16:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 17:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 18:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 19:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 22:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 25:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readLongOrNull(offset)) as P;
    case 28:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 29:
      return (reader.readLongOrNull(offset)) as P;
    case 30:
      return (_TaskModelpriorityValueEnumMap[reader.readByteOrNull(offset)] ??
          TaskPriority.medium) as P;
    case 31:
      return (reader.readObjectOrNull<RecurrencePattern>(
        offset,
        RecurrencePatternSchema.deserialize,
        allOffsets,
      )) as P;
    case 32:
      return (reader.readLongOrNull(offset)) as P;
    case 33:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 34:
      return (reader.readStringOrNull(offset)) as P;
    case 35:
      return (_TaskModelstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          TaskStatus.todo) as P;
    case 36:
      return (reader.readStringOrNull(offset)) as P;
    case 37:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 38:
      return (reader.readLongOrNull(offset)) as P;
    case 39:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 40:
      return (reader.readString(offset)) as P;
    case 41:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 42:
      return (reader.readString(offset)) as P;
    case 43:
      return (reader.readString(offset)) as P;
    case 44:
      return (reader.readStringOrNull(offset) ?? 'public') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TaskModelpriorityEnumValueMap = {
  'high': 0,
  'medium': 1,
  'low': 2,
};
const _TaskModelpriorityValueEnumMap = {
  0: TaskPriority.high,
  1: TaskPriority.medium,
  2: TaskPriority.low,
};
const _TaskModelstatusEnumValueMap = {
  'todo': 0,
  'inProgress': 1,
  'done': 2,
};
const _TaskModelstatusValueEnumMap = {
  0: TaskStatus.todo,
  1: TaskStatus.inProgress,
  2: TaskStatus.done,
};

Id _taskModelGetId(TaskModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _taskModelGetLinks(TaskModel object) {
  return [object.attachments, object.category];
}

void _taskModelAttach(IsarCollection<dynamic> col, Id id, TaskModel object) {
  object.id = id;
  object.attachments
      .attach(col, col.isar.collection<AttachmentModel>(), r'attachments', id);
  object.category
      .attach(col, col.isar.collection<CategoryModel>(), r'category', id);
}

extension TaskModelByIndex on IsarCollection<TaskModel> {
  Future<TaskModel?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  TaskModel? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<TaskModel?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<TaskModel?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(TaskModel object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(TaskModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<TaskModel> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<TaskModel> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension TaskModelQueryWhereSort
    on QueryBuilder<TaskModel, TaskModel, QWhere> {
  QueryBuilder<TaskModel, TaskModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhere> anyPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'position'),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhere> anyCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'categoryId'),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhere> anyTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'title'),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension TaskModelQueryWhere
    on QueryBuilder<TaskModel, TaskModel, QWhereClause> {
  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> uuidNotEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> userIdNotEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> positionEqualTo(
      double position) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'position',
        value: [position],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> positionNotEqualTo(
      double position) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'position',
              lower: [],
              upper: [position],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'position',
              lower: [position],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'position',
              lower: [position],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'position',
              lower: [],
              upper: [position],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> positionGreaterThan(
    double position, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'position',
        lower: [position],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> positionLessThan(
    double position, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'position',
        lower: [],
        upper: [position],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> positionBetween(
    double lowerPosition,
    double upperPosition, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'position',
        lower: [lowerPosition],
        includeLower: includeLower,
        upper: [upperPosition],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> visibilityEqualTo(
      String visibility) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'visibility',
        value: [visibility],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> visibilityNotEqualTo(
      String visibility) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visibility',
              lower: [],
              upper: [visibility],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visibility',
              lower: [visibility],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visibility',
              lower: [visibility],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visibility',
              lower: [],
              upper: [visibility],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> assigneeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'assigneeId',
        value: [null],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> assigneeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'assigneeId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> assigneeIdEqualTo(
      String? assigneeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'assigneeId',
        value: [assigneeId],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> assigneeIdNotEqualTo(
      String? assigneeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assigneeId',
              lower: [],
              upper: [assigneeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assigneeId',
              lower: [assigneeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assigneeId',
              lower: [assigneeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assigneeId',
              lower: [],
              upper: [assigneeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> spaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'spaceId',
        value: [null],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> spaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'spaceId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> spaceIdEqualTo(
      String? spaceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'spaceId',
        value: [spaceId],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> spaceIdNotEqualTo(
      String? spaceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'spaceId',
              lower: [],
              upper: [spaceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'spaceId',
              lower: [spaceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'spaceId',
              lower: [spaceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'spaceId',
              lower: [],
              upper: [spaceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause>
      automationLinkIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'automationLinkId',
        value: [null],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause>
      automationLinkIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'automationLinkId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> automationLinkIdEqualTo(
      String? automationLinkId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'automationLinkId',
        value: [automationLinkId],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause>
      automationLinkIdNotEqualTo(String? automationLinkId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'automationLinkId',
              lower: [],
              upper: [automationLinkId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'automationLinkId',
              lower: [automationLinkId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'automationLinkId',
              lower: [automationLinkId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'automationLinkId',
              lower: [],
              upper: [automationLinkId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> moduleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'moduleId',
        value: [null],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> moduleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'moduleId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> moduleIdEqualTo(
      String? moduleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'moduleId',
        value: [moduleId],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> moduleIdNotEqualTo(
      String? moduleId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'moduleId',
              lower: [],
              upper: [moduleId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'moduleId',
              lower: [moduleId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'moduleId',
              lower: [moduleId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'moduleId',
              lower: [],
              upper: [moduleId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'categoryId',
        value: [null],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> categoryIdEqualTo(
      int? categoryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'categoryId',
        value: [categoryId],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> categoryIdNotEqualTo(
      int? categoryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [],
              upper: [categoryId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [categoryId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [categoryId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryId',
              lower: [],
              upper: [categoryId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> categoryIdGreaterThan(
    int? categoryId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryId',
        lower: [categoryId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> categoryIdLessThan(
    int? categoryId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryId',
        lower: [],
        upper: [categoryId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> categoryIdBetween(
    int? lowerCategoryId,
    int? upperCategoryId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'categoryId',
        lower: [lowerCategoryId],
        includeLower: includeLower,
        upper: [upperCategoryId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> titleEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [title],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> titleNotEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> titleGreaterThan(
    String title, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'title',
        lower: [title],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> titleLessThan(
    String title, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'title',
        lower: [],
        upper: [title],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> titleBetween(
    String lowerTitle,
    String upperTitle, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'title',
        lower: [lowerTitle],
        includeLower: includeLower,
        upper: [upperTitle],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> titleStartsWith(
      String TitlePrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'title',
        lower: [TitlePrefix],
        upper: ['$TitlePrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [''],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'title',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'title',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'title',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'title',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TaskModelQueryFilter
    on QueryBuilder<TaskModel, TaskModel, QFilterCondition> {
  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assignedToIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedTo',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assignedToIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedTo',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assignedToEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assignedToGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assignedToLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assignedToBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedTo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assignedToStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assignedToEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assignedToContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedTo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assignedToMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedTo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assignedToIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedTo',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assignedToIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedTo',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assigneeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assigneeId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assigneeId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assigneeIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneeIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assigneeIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assigneeIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assigneeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assigneeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assigneeIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assigneeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> assigneeIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assigneeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assigneeId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assigneeId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assigneesIds',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assigneesIds',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assigneesIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assigneesIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assigneesIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assigneesIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assigneesIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assigneesIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assigneesIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assigneesIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assigneesIds',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assigneesIds',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assigneesIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assigneesIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assigneesIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assigneesIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assigneesIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      assigneesIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assigneesIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'automationLinkId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'automationLinkId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'automationLinkId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'automationLinkId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'automationLinkId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'automationLinkId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'automationLinkId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'automationLinkId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'automationLinkId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'automationLinkId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'automationLinkId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      automationLinkIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'automationLinkId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoryId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoryId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      categoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> completedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completionNote',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completionNote',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completionNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completionNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completionNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completionNote',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'completionNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'completionNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'completionNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'completionNote',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completionNote',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      completionNoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'completionNote',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      createdByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      createdByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdByContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdByMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> createdByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      createdByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> deletedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      deletedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> deletedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      durationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      durationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      durationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      durationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> fixedHourIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fixedHour',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      fixedHourIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fixedHour',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> fixedHourEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fixedHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      fixedHourGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fixedHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> fixedHourLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fixedHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> fixedHourBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fixedHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      fixedMinuteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fixedMinute',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      fixedMinuteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fixedMinute',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> fixedMinuteEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fixedMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      fixedMinuteGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fixedMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> fixedMinuteLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fixedMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> fixedMinuteBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fixedMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isCompletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isHiddenEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isHidden',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isImportantEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isImportant',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      isReassignableEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isReassignable',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isRecurringEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRecurring',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isSampleDataEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSampleData',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isSyncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isUrgentEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isUrgent',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> moduleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'moduleId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      moduleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'moduleId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> moduleIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> moduleIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> moduleIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> moduleIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moduleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> moduleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> moduleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> moduleIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> moduleIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'moduleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> moduleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moduleId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      moduleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'moduleId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      occurrenceDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'occurrenceDate',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      occurrenceDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'occurrenceDate',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      occurrenceDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurrenceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      occurrenceDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occurrenceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      occurrenceDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occurrenceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      occurrenceDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occurrenceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      offsetMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offsetMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      offsetMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offsetMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      offsetMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offsetMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      offsetMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offsetMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentRecurrenceId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentRecurrenceId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentRecurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentRecurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentRecurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentRecurrenceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parentRecurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parentRecurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentRecurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentRecurrenceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentRecurrenceId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      parentRecurrenceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentRecurrenceId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      periodPositionIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'periodPositionIndex',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      periodPositionIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'periodPositionIndex',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      periodPositionIndexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodPositionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      periodPositionIndexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodPositionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      periodPositionIndexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodPositionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      periodPositionIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodPositionIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> positionEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'position',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> positionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'position',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> positionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'position',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> positionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'position',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      prayerRelationIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'prayerRelationIndex',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      prayerRelationIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'prayerRelationIndex',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      prayerRelationIndexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prayerRelationIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      prayerRelationIndexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prayerRelationIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      prayerRelationIndexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prayerRelationIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      prayerRelationIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prayerRelationIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> priorityEqualTo(
      TaskPriority value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> priorityGreaterThan(
    TaskPriority value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> priorityLessThan(
    TaskPriority value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> priorityBetween(
    TaskPriority lower,
    TaskPriority upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> recurrenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recurrence',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      recurrenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recurrence',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      referencePrayerIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'referencePrayerIndex',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      referencePrayerIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'referencePrayerIndex',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      referencePrayerIndexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referencePrayerIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      referencePrayerIndexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referencePrayerIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      referencePrayerIndexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referencePrayerIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      referencePrayerIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referencePrayerIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      reminderTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reminderTime',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      reminderTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reminderTime',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> reminderTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderTime',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      reminderTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderTime',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      reminderTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderTime',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> reminderTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'spaceId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'spaceId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spaceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spaceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spaceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spaceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'spaceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'spaceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'spaceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'spaceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> spaceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spaceId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      spaceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'spaceId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> statusEqualTo(
      TaskStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> statusGreaterThan(
    TaskStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> statusLessThan(
    TaskStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> statusBetween(
    TaskStatus lower,
    TaskStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> templateIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'templateId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      templateIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'templateId',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> templateIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      templateIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> templateIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> templateIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'templateId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      templateIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> templateIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> templateIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'templateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> templateIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'templateId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      templateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'templateId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      templateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'templateId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> timeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'time',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> timeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'time',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> timeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> timeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> timeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> timeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      timePeriodIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timePeriodIndex',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      timePeriodIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timePeriodIndex',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      timePeriodIndexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timePeriodIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      timePeriodIndexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timePeriodIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      timePeriodIndexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timePeriodIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      timePeriodIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timePeriodIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      timeTypeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      timeTypeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      timeTypeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      timeTypeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeTypeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> updatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> userIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> uuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> uuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> visibilityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      visibilityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> visibilityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> visibilityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visibility',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      visibilityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> visibilityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> visibilityContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visibility',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> visibilityMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visibility',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      visibilityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibility',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      visibilityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visibility',
        value: '',
      ));
    });
  }
}

extension TaskModelQueryObject
    on QueryBuilder<TaskModel, TaskModel, QFilterCondition> {
  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> recurrence(
      FilterQuery<RecurrencePattern> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'recurrence');
    });
  }
}

extension TaskModelQueryLinks
    on QueryBuilder<TaskModel, TaskModel, QFilterCondition> {
  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> attachments(
      FilterQuery<AttachmentModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'attachments');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      attachmentsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'attachments', length, true, length, true);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      attachmentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'attachments', 0, true, 0, true);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      attachmentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'attachments', 0, false, 999999, true);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      attachmentsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'attachments', 0, true, length, include);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      attachmentsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'attachments', length, include, 999999, true);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
      attachmentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'attachments', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> category(
      FilterQuery<CategoryModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'category');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'category', 0, true, 0, true);
    });
  }
}

extension TaskModelQuerySortBy on QueryBuilder<TaskModel, TaskModel, QSortBy> {
  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByAssignedTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedTo', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByAssignedToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedTo', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByAssigneeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigneeId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByAssigneeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigneeId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByAutomationLinkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'automationLinkId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      sortByAutomationLinkIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'automationLinkId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCompletionNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionNote', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCompletionNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionNote', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByFixedHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedHour', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByFixedHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedHour', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByFixedMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedMinute', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByFixedMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedMinute', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHidden', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsHiddenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHidden', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsImportant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsImportantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsReassignable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReassignable', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsReassignableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReassignable', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurring', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsRecurringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurring', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsSampleData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSampleData', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsSampleDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSampleData', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsUrgent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUrgent', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsUrgentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUrgent', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByModuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByModuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByOccurrenceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByOffsetMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offsetMinutes', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByOffsetMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offsetMinutes', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByParentRecurrenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentRecurrenceId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      sortByParentRecurrenceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentRecurrenceId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByPeriodPositionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodPositionIndex', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      sortByPeriodPositionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodPositionIndex', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByPrayerRelationIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerRelationIndex', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      sortByPrayerRelationIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerRelationIndex', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      sortByReferencePrayerIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencePrayerIndex', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      sortByReferencePrayerIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencePrayerIndex', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTime', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByReminderTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTime', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortBySpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spaceId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortBySpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spaceId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTimePeriodIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timePeriodIndex', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTimePeriodIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timePeriodIndex', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTimeTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTimeTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTypeIndex', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByVisibility() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visibility', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByVisibilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visibility', Sort.desc);
    });
  }
}

extension TaskModelQuerySortThenBy
    on QueryBuilder<TaskModel, TaskModel, QSortThenBy> {
  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByAssignedTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedTo', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByAssignedToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedTo', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByAssigneeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigneeId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByAssigneeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assigneeId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByAutomationLinkId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'automationLinkId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      thenByAutomationLinkIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'automationLinkId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCompletionNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionNote', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCompletionNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionNote', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByFixedHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedHour', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByFixedHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedHour', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByFixedMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedMinute', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByFixedMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedMinute', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHidden', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsHiddenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHidden', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsImportant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsImportantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsReassignable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReassignable', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsReassignableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isReassignable', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurring', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsRecurringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurring', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsSampleData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSampleData', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsSampleDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSampleData', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsUrgent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUrgent', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsUrgentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUrgent', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByModuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByModuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByOccurrenceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceDate', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByOffsetMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offsetMinutes', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByOffsetMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offsetMinutes', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByParentRecurrenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentRecurrenceId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      thenByParentRecurrenceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentRecurrenceId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByPeriodPositionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodPositionIndex', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      thenByPeriodPositionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodPositionIndex', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByPrayerRelationIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerRelationIndex', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      thenByPrayerRelationIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerRelationIndex', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      thenByReferencePrayerIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencePrayerIndex', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy>
      thenByReferencePrayerIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencePrayerIndex', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTime', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByReminderTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTime', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenBySpaceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spaceId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenBySpaceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spaceId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTimePeriodIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timePeriodIndex', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTimePeriodIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timePeriodIndex', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTimeTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTimeTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeTypeIndex', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByVisibility() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visibility', Sort.asc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByVisibilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visibility', Sort.desc);
    });
  }
}

extension TaskModelQueryWhereDistinct
    on QueryBuilder<TaskModel, TaskModel, QDistinct> {
  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByAssignedTo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedTo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByAssigneeId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assigneeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByAssigneesIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assigneesIds');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByAutomationLinkId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'automationLinkId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByCompletionNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completionNote',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByCreatedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMinutes');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByFixedHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedHour');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByFixedMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedMinute');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByIsHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHidden');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByIsImportant() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isImportant');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByIsReassignable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isReassignable');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByIsRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRecurring');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByIsSampleData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSampleData');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByIsUrgent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isUrgent');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByModuleId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moduleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByOccurrenceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurrenceDate');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByOffsetMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offsetMinutes');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByParentRecurrenceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentRecurrenceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct>
      distinctByPeriodPositionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodPositionIndex');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'position');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct>
      distinctByPrayerRelationIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prayerRelationIndex');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct>
      distinctByReferencePrayerIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referencePrayerIndex');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderTime');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctBySpaceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spaceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByTemplateId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'templateId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByTimePeriodIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timePeriodIndex');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByTimeTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeTypeIndex');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QDistinct> distinctByVisibility(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visibility', caseSensitive: caseSensitive);
    });
  }
}

extension TaskModelQueryProperty
    on QueryBuilder<TaskModel, TaskModel, QQueryProperty> {
  QueryBuilder<TaskModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TaskModel, String?, QQueryOperations> assignedToProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedTo');
    });
  }

  QueryBuilder<TaskModel, String?, QQueryOperations> assigneeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assigneeId');
    });
  }

  QueryBuilder<TaskModel, List<String>?, QQueryOperations>
      assigneesIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assigneesIds');
    });
  }

  QueryBuilder<TaskModel, String?, QQueryOperations>
      automationLinkIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'automationLinkId');
    });
  }

  QueryBuilder<TaskModel, int?, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<TaskModel, DateTime?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<TaskModel, String?, QQueryOperations> completionNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completionNote');
    });
  }

  QueryBuilder<TaskModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TaskModel, String?, QQueryOperations> createdByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdBy');
    });
  }

  QueryBuilder<TaskModel, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<TaskModel, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<TaskModel, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<TaskModel, int, QQueryOperations> durationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMinutes');
    });
  }

  QueryBuilder<TaskModel, int?, QQueryOperations> fixedHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedHour');
    });
  }

  QueryBuilder<TaskModel, int?, QQueryOperations> fixedMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedMinute');
    });
  }

  QueryBuilder<TaskModel, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<TaskModel, bool, QQueryOperations> isHiddenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHidden');
    });
  }

  QueryBuilder<TaskModel, bool, QQueryOperations> isImportantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isImportant');
    });
  }

  QueryBuilder<TaskModel, bool, QQueryOperations> isReassignableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isReassignable');
    });
  }

  QueryBuilder<TaskModel, bool, QQueryOperations> isRecurringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRecurring');
    });
  }

  QueryBuilder<TaskModel, bool, QQueryOperations> isSampleDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSampleData');
    });
  }

  QueryBuilder<TaskModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<TaskModel, bool, QQueryOperations> isUrgentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isUrgent');
    });
  }

  QueryBuilder<TaskModel, String?, QQueryOperations> moduleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moduleId');
    });
  }

  QueryBuilder<TaskModel, DateTime?, QQueryOperations>
      occurrenceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurrenceDate');
    });
  }

  QueryBuilder<TaskModel, int, QQueryOperations> offsetMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offsetMinutes');
    });
  }

  QueryBuilder<TaskModel, String?, QQueryOperations>
      parentRecurrenceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentRecurrenceId');
    });
  }

  QueryBuilder<TaskModel, int?, QQueryOperations>
      periodPositionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodPositionIndex');
    });
  }

  QueryBuilder<TaskModel, double, QQueryOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'position');
    });
  }

  QueryBuilder<TaskModel, int?, QQueryOperations>
      prayerRelationIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prayerRelationIndex');
    });
  }

  QueryBuilder<TaskModel, TaskPriority, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<TaskModel, RecurrencePattern?, QQueryOperations>
      recurrenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrence');
    });
  }

  QueryBuilder<TaskModel, int?, QQueryOperations>
      referencePrayerIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referencePrayerIndex');
    });
  }

  QueryBuilder<TaskModel, DateTime?, QQueryOperations> reminderTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderTime');
    });
  }

  QueryBuilder<TaskModel, String?, QQueryOperations> spaceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spaceId');
    });
  }

  QueryBuilder<TaskModel, TaskStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<TaskModel, String?, QQueryOperations> templateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateId');
    });
  }

  QueryBuilder<TaskModel, DateTime?, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<TaskModel, int?, QQueryOperations> timePeriodIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timePeriodIndex');
    });
  }

  QueryBuilder<TaskModel, int, QQueryOperations> timeTypeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeTypeIndex');
    });
  }

  QueryBuilder<TaskModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<TaskModel, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<TaskModel, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<TaskModel, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<TaskModel, String, QQueryOperations> visibilityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visibility');
    });
  }
}
