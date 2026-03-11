// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicineModelCollection on Isar {
  IsarCollection<MedicineModel> get medicineModels => this.collection();
}

const MedicineModelSchema = CollectionSchema(
  name: r'MedicineModel',
  id: 2197460021641310300,
  properties: {
    r'autoRefillMode': PropertySchema(
      id: 0,
      name: r'autoRefillMode',
      type: IsarType.string,
    ),
    r'courseDurationDays': PropertySchema(
      id: 1,
      name: r'courseDurationDays',
      type: IsarType.long,
    ),
    r'courseProgress': PropertySchema(
      id: 2,
      name: r'courseProgress',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdBy': PropertySchema(
      id: 4,
      name: r'createdBy',
      type: IsarType.string,
    ),
    r'doseAmount': PropertySchema(
      id: 5,
      name: r'doseAmount',
      type: IsarType.double,
    ),
    r'doseUnit': PropertySchema(
      id: 6,
      name: r'doseUnit',
      type: IsarType.string,
    ),
    r'fixedTimeSlots': PropertySchema(
      id: 7,
      name: r'fixedTimeSlots',
      type: IsarType.stringList,
    ),
    r'instructions': PropertySchema(
      id: 8,
      name: r'instructions',
      type: IsarType.string,
    ),
    r'intervalHours': PropertySchema(
      id: 9,
      name: r'intervalHours',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 10,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isCourseFinished': PropertySchema(
      id: 11,
      name: r'isCourseFinished',
      type: IsarType.bool,
    ),
    r'isRefillRequested': PropertySchema(
      id: 12,
      name: r'isRefillRequested',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 13,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'moduleId': PropertySchema(
      id: 14,
      name: r'moduleId',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 15,
      name: r'name',
      type: IsarType.string,
    ),
    r'refillAction': PropertySchema(
      id: 16,
      name: r'refillAction',
      type: IsarType.string,
    ),
    r'refillThreshold': PropertySchema(
      id: 17,
      name: r'refillThreshold',
      type: IsarType.double,
    ),
    r'schedulingType': PropertySchema(
      id: 18,
      name: r'schedulingType',
      type: IsarType.string,
    ),
    r'startDate': PropertySchema(
      id: 19,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'stockQuantity': PropertySchema(
      id: 20,
      name: r'stockQuantity',
      type: IsarType.double,
    ),
    r'treatmentEndDate': PropertySchema(
      id: 21,
      name: r'treatmentEndDate',
      type: IsarType.dateTime,
    ),
    r'type': PropertySchema(
      id: 22,
      name: r'type',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 23,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(
      id: 24,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _medicineModelEstimateSize,
  serialize: _medicineModelSerialize,
  deserialize: _medicineModelDeserialize,
  deserializeProp: _medicineModelDeserializeProp,
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
    r'createdBy': IndexSchema(
      id: -5864534510598149324,
      name: r'createdBy',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdBy',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _medicineModelGetId,
  getLinks: _medicineModelGetLinks,
  attach: _medicineModelAttach,
  version: '3.1.0+1',
);

int _medicineModelEstimateSize(
  MedicineModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.autoRefillMode.length * 3;
  {
    final value = object.createdBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.doseUnit;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.fixedTimeSlots;
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
    final value = object.instructions;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.moduleId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.refillAction.length * 3;
  bytesCount += 3 + object.schedulingType.length * 3;
  {
    final value = object.type;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _medicineModelSerialize(
  MedicineModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.autoRefillMode);
  writer.writeLong(offsets[1], object.courseDurationDays);
  writer.writeDouble(offsets[2], object.courseProgress);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeString(offsets[4], object.createdBy);
  writer.writeDouble(offsets[5], object.doseAmount);
  writer.writeString(offsets[6], object.doseUnit);
  writer.writeStringList(offsets[7], object.fixedTimeSlots);
  writer.writeString(offsets[8], object.instructions);
  writer.writeLong(offsets[9], object.intervalHours);
  writer.writeBool(offsets[10], object.isActive);
  writer.writeBool(offsets[11], object.isCourseFinished);
  writer.writeBool(offsets[12], object.isRefillRequested);
  writer.writeBool(offsets[13], object.isSynced);
  writer.writeString(offsets[14], object.moduleId);
  writer.writeString(offsets[15], object.name);
  writer.writeString(offsets[16], object.refillAction);
  writer.writeDouble(offsets[17], object.refillThreshold);
  writer.writeString(offsets[18], object.schedulingType);
  writer.writeDateTime(offsets[19], object.startDate);
  writer.writeDouble(offsets[20], object.stockQuantity);
  writer.writeDateTime(offsets[21], object.treatmentEndDate);
  writer.writeString(offsets[22], object.type);
  writer.writeDateTime(offsets[23], object.updatedAt);
  writer.writeString(offsets[24], object.uuid);
}

MedicineModel _medicineModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicineModel(
    autoRefillMode: reader.readStringOrNull(offsets[0]) ?? 'off',
    courseDurationDays: reader.readLongOrNull(offsets[1]),
    createdBy: reader.readStringOrNull(offsets[4]),
    doseAmount: reader.readDoubleOrNull(offsets[5]),
    doseUnit: reader.readStringOrNull(offsets[6]),
    fixedTimeSlots: reader.readStringList(offsets[7]),
    instructions: reader.readStringOrNull(offsets[8]),
    intervalHours: reader.readLongOrNull(offsets[9]),
    isActive: reader.readBoolOrNull(offsets[10]) ?? true,
    isRefillRequested: reader.readBoolOrNull(offsets[12]) ?? false,
    isSynced: reader.readBoolOrNull(offsets[13]) ?? false,
    moduleId: reader.readString(offsets[14]),
    name: reader.readString(offsets[15]),
    refillAction: reader.readStringOrNull(offsets[16]) ?? 'list',
    refillThreshold: reader.readDoubleOrNull(offsets[17]) ?? 0.0,
    schedulingType: reader.readString(offsets[18]),
    startDate: reader.readDateTimeOrNull(offsets[19]),
    stockQuantity: reader.readDoubleOrNull(offsets[20]),
    treatmentEndDate: reader.readDateTimeOrNull(offsets[21]),
    type: reader.readStringOrNull(offsets[22]),
    uuid: reader.readString(offsets[24]),
  );
  object.createdAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[23]);
  return object;
}

P _medicineModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? 'off') as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringList(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 13:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset) ?? 'list') as P;
    case 17:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 20:
      return (reader.readDoubleOrNull(offset)) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readDateTime(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _medicineModelGetId(MedicineModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicineModelGetLinks(MedicineModel object) {
  return [];
}

void _medicineModelAttach(
    IsarCollection<dynamic> col, Id id, MedicineModel object) {
  object.id = id;
}

extension MedicineModelByIndex on IsarCollection<MedicineModel> {
  Future<MedicineModel?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  MedicineModel? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<MedicineModel?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<MedicineModel?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(MedicineModel object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(MedicineModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<MedicineModel> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<MedicineModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension MedicineModelQueryWhereSort
    on QueryBuilder<MedicineModel, MedicineModel, QWhere> {
  QueryBuilder<MedicineModel, MedicineModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MedicineModelQueryWhere
    on QueryBuilder<MedicineModel, MedicineModel, QWhereClause> {
  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause> uuidNotEqualTo(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause> moduleIdEqualTo(
      String moduleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'moduleId',
        value: [moduleId],
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause>
      moduleIdNotEqualTo(String moduleId) {
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause>
      createdByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdBy',
        value: [null],
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause>
      createdByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdBy',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause>
      createdByEqualTo(String? createdBy) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdBy',
        value: [createdBy],
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterWhereClause>
      createdByNotEqualTo(String? createdBy) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdBy',
              lower: [],
              upper: [createdBy],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdBy',
              lower: [createdBy],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdBy',
              lower: [createdBy],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdBy',
              lower: [],
              upper: [createdBy],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MedicineModelQueryFilter
    on QueryBuilder<MedicineModel, MedicineModel, QFilterCondition> {
  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      autoRefillModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoRefillMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      autoRefillModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autoRefillMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      autoRefillModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autoRefillMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      autoRefillModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autoRefillMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      autoRefillModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'autoRefillMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      autoRefillModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'autoRefillMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      autoRefillModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'autoRefillMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      autoRefillModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'autoRefillMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      autoRefillModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoRefillMode',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      autoRefillModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'autoRefillMode',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      courseDurationDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'courseDurationDays',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      courseDurationDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'courseDurationDays',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      courseDurationDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseDurationDays',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      courseDurationDaysGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'courseDurationDays',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      courseDurationDaysLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'courseDurationDays',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      courseDurationDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'courseDurationDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      courseProgressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      courseProgressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'courseProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      courseProgressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'courseProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      courseProgressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'courseProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdBy',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByEqualTo(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByLessThan(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByBetween(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByStartsWith(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByEndsWith(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'createdBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'createdBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      createdByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'createdBy',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'doseAmount',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'doseAmount',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doseAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'doseAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'doseAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'doseAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'doseUnit',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'doseUnit',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'doseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'doseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'doseUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'doseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'doseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'doseUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'doseUnit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doseUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      doseUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'doseUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fixedTimeSlots',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fixedTimeSlots',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fixedTimeSlots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fixedTimeSlots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fixedTimeSlots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fixedTimeSlots',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fixedTimeSlots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fixedTimeSlots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fixedTimeSlots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fixedTimeSlots',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fixedTimeSlots',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fixedTimeSlots',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedTimeSlots',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedTimeSlots',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedTimeSlots',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedTimeSlots',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedTimeSlots',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      fixedTimeSlotsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fixedTimeSlots',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'instructions',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'instructions',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'instructions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'instructions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'instructions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'instructions',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      instructionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'instructions',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      intervalHoursIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'intervalHours',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      intervalHoursIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'intervalHours',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      intervalHoursEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      intervalHoursGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'intervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      intervalHoursLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'intervalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      intervalHoursBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'intervalHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      isCourseFinishedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCourseFinished',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      isRefillRequestedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRefillRequested',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      moduleIdEqualTo(
    String value, {
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      moduleIdGreaterThan(
    String value, {
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      moduleIdLessThan(
    String value, {
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      moduleIdBetween(
    String lower,
    String upper, {
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      moduleIdStartsWith(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      moduleIdEndsWith(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      moduleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      moduleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'moduleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      moduleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moduleId',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      moduleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'moduleId',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillActionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refillAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillActionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refillAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillActionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refillAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillActionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refillAction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillActionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'refillAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillActionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'refillAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillActionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'refillAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillActionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'refillAction',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillActionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refillAction',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillActionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'refillAction',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillThresholdEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refillThreshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillThresholdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refillThreshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillThresholdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refillThreshold',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      refillThresholdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refillThreshold',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      schedulingTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schedulingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      schedulingTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schedulingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      schedulingTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schedulingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      schedulingTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schedulingType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      schedulingTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schedulingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      schedulingTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schedulingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      schedulingTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schedulingType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      schedulingTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schedulingType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      schedulingTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schedulingType',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      schedulingTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schedulingType',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      startDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      startDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      startDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      stockQuantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stockQuantity',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      stockQuantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stockQuantity',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      stockQuantityEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stockQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      stockQuantityGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stockQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      stockQuantityLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stockQuantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      stockQuantityBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stockQuantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      treatmentEndDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'treatmentEndDate',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      treatmentEndDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'treatmentEndDate',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      treatmentEndDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'treatmentEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      treatmentEndDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'treatmentEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      treatmentEndDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'treatmentEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      treatmentEndDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'treatmentEndDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      typeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'type',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      typeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'type',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> typeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      typeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      typeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> typeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> uuidEqualTo(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      uuidGreaterThan(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      uuidLessThan(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> uuidBetween(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      uuidStartsWith(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      uuidEndsWith(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition> uuidMatches(
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

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension MedicineModelQueryObject
    on QueryBuilder<MedicineModel, MedicineModel, QFilterCondition> {}

extension MedicineModelQueryLinks
    on QueryBuilder<MedicineModel, MedicineModel, QFilterCondition> {}

extension MedicineModelQuerySortBy
    on QueryBuilder<MedicineModel, MedicineModel, QSortBy> {
  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByAutoRefillMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRefillMode', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByAutoRefillModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRefillMode', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByCourseDurationDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseDurationDays', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByCourseDurationDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseDurationDays', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByCourseProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseProgress', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByCourseProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseProgress', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByDoseAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doseAmount', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByDoseAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doseAmount', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByDoseUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doseUnit', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByDoseUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doseUnit', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByInstructions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instructions', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByInstructionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instructions', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalHours', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByIntervalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalHours', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByIsCourseFinished() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCourseFinished', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByIsCourseFinishedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCourseFinished', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByIsRefillRequested() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRefillRequested', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByIsRefillRequestedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRefillRequested', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByModuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByModuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByRefillAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillAction', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByRefillActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillAction', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByRefillThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillThreshold', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByRefillThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillThreshold', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortBySchedulingType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schedulingType', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortBySchedulingTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schedulingType', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByStockQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockQuantity', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByStockQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockQuantity', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByTreatmentEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentEndDate', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByTreatmentEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentEndDate', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension MedicineModelQuerySortThenBy
    on QueryBuilder<MedicineModel, MedicineModel, QSortThenBy> {
  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByAutoRefillMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRefillMode', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByAutoRefillModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRefillMode', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByCourseDurationDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseDurationDays', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByCourseDurationDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseDurationDays', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByCourseProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseProgress', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByCourseProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseProgress', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByDoseAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doseAmount', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByDoseAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doseAmount', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByDoseUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doseUnit', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByDoseUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doseUnit', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByInstructions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instructions', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByInstructionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instructions', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalHours', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByIntervalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalHours', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByIsCourseFinished() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCourseFinished', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByIsCourseFinishedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCourseFinished', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByIsRefillRequested() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRefillRequested', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByIsRefillRequestedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRefillRequested', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByModuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByModuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByRefillAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillAction', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByRefillActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillAction', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByRefillThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillThreshold', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByRefillThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillThreshold', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenBySchedulingType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schedulingType', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenBySchedulingTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schedulingType', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByStockQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockQuantity', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByStockQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stockQuantity', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByTreatmentEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentEndDate', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByTreatmentEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentEndDate', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension MedicineModelQueryWhereDistinct
    on QueryBuilder<MedicineModel, MedicineModel, QDistinct> {
  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctByAutoRefillMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoRefillMode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctByCourseDurationDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courseDurationDays');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctByCourseProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courseProgress');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByCreatedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByDoseAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doseAmount');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByDoseUnit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doseUnit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctByFixedTimeSlots() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedTimeSlots');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByInstructions(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'instructions', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctByIntervalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intervalHours');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctByIsCourseFinished() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCourseFinished');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctByIsRefillRequested() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRefillRequested');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByModuleId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moduleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByRefillAction(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refillAction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctByRefillThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refillThreshold');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctBySchedulingType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schedulingType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctByStockQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stockQuantity');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct>
      distinctByTreatmentEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'treatmentEndDate');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MedicineModel, MedicineModel, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension MedicineModelQueryProperty
    on QueryBuilder<MedicineModel, MedicineModel, QQueryProperty> {
  QueryBuilder<MedicineModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicineModel, String, QQueryOperations>
      autoRefillModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoRefillMode');
    });
  }

  QueryBuilder<MedicineModel, int?, QQueryOperations>
      courseDurationDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courseDurationDays');
    });
  }

  QueryBuilder<MedicineModel, double, QQueryOperations>
      courseProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courseProgress');
    });
  }

  QueryBuilder<MedicineModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MedicineModel, String?, QQueryOperations> createdByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdBy');
    });
  }

  QueryBuilder<MedicineModel, double?, QQueryOperations> doseAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doseAmount');
    });
  }

  QueryBuilder<MedicineModel, String?, QQueryOperations> doseUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doseUnit');
    });
  }

  QueryBuilder<MedicineModel, List<String>?, QQueryOperations>
      fixedTimeSlotsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedTimeSlots');
    });
  }

  QueryBuilder<MedicineModel, String?, QQueryOperations>
      instructionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'instructions');
    });
  }

  QueryBuilder<MedicineModel, int?, QQueryOperations> intervalHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intervalHours');
    });
  }

  QueryBuilder<MedicineModel, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<MedicineModel, bool, QQueryOperations>
      isCourseFinishedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCourseFinished');
    });
  }

  QueryBuilder<MedicineModel, bool, QQueryOperations>
      isRefillRequestedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRefillRequested');
    });
  }

  QueryBuilder<MedicineModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<MedicineModel, String, QQueryOperations> moduleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moduleId');
    });
  }

  QueryBuilder<MedicineModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MedicineModel, String, QQueryOperations> refillActionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refillAction');
    });
  }

  QueryBuilder<MedicineModel, double, QQueryOperations>
      refillThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refillThreshold');
    });
  }

  QueryBuilder<MedicineModel, String, QQueryOperations>
      schedulingTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schedulingType');
    });
  }

  QueryBuilder<MedicineModel, DateTime?, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<MedicineModel, double?, QQueryOperations>
      stockQuantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stockQuantity');
    });
  }

  QueryBuilder<MedicineModel, DateTime?, QQueryOperations>
      treatmentEndDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'treatmentEndDate');
    });
  }

  QueryBuilder<MedicineModel, String?, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<MedicineModel, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MedicineModel, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
