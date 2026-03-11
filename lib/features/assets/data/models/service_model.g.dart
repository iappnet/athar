// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetServiceModelCollection on Isar {
  IsarCollection<ServiceModel> get serviceModels => this.collection();
}

const ServiceModelSchema = CollectionSchema(
  name: r'ServiceModel',
  id: -8100188801209214237,
  properties: {
    r'assetId': PropertySchema(
      id: 0,
      name: r'assetId',
      type: IsarType.string,
    ),
    r'averageKmPerDay': PropertySchema(
      id: 1,
      name: r'averageKmPerDay',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 3,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'isSynced': PropertySchema(
      id: 4,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastOdometerReading': PropertySchema(
      id: 5,
      name: r'lastOdometerReading',
      type: IsarType.long,
    ),
    r'lastServiceDate': PropertySchema(
      id: 6,
      name: r'lastServiceDate',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 7,
      name: r'name',
      type: IsarType.string,
    ),
    r'nextDueDate': PropertySchema(
      id: 8,
      name: r'nextDueDate',
      type: IsarType.dateTime,
    ),
    r'nextDueOdometer': PropertySchema(
      id: 9,
      name: r'nextDueOdometer',
      type: IsarType.long,
    ),
    r'notifyBeforeDays': PropertySchema(
      id: 10,
      name: r'notifyBeforeDays',
      type: IsarType.long,
    ),
    r'reminderEnabled': PropertySchema(
      id: 11,
      name: r'reminderEnabled',
      type: IsarType.bool,
    ),
    r'reminderTime': PropertySchema(
      id: 12,
      name: r'reminderTime',
      type: IsarType.dateTime,
    ),
    r'repeatEveryDays': PropertySchema(
      id: 13,
      name: r'repeatEveryDays',
      type: IsarType.long,
    ),
    r'repeatEveryKm': PropertySchema(
      id: 14,
      name: r'repeatEveryKm',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(
      id: 16,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _serviceModelEstimateSize,
  serialize: _serviceModelSerialize,
  deserialize: _serviceModelDeserialize,
  deserializeProp: _serviceModelDeserializeProp,
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
    r'assetId': IndexSchema(
      id: 174362542210192109,
      name: r'assetId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'assetId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _serviceModelGetId,
  getLinks: _serviceModelGetLinks,
  attach: _serviceModelAttach,
  version: '3.1.0+1',
);

int _serviceModelEstimateSize(
  ServiceModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.assetId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _serviceModelSerialize(
  ServiceModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.assetId);
  writer.writeDouble(offsets[1], object.averageKmPerDay);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDateTime(offsets[3], object.deletedAt);
  writer.writeBool(offsets[4], object.isSynced);
  writer.writeLong(offsets[5], object.lastOdometerReading);
  writer.writeDateTime(offsets[6], object.lastServiceDate);
  writer.writeString(offsets[7], object.name);
  writer.writeDateTime(offsets[8], object.nextDueDate);
  writer.writeLong(offsets[9], object.nextDueOdometer);
  writer.writeLong(offsets[10], object.notifyBeforeDays);
  writer.writeBool(offsets[11], object.reminderEnabled);
  writer.writeDateTime(offsets[12], object.reminderTime);
  writer.writeLong(offsets[13], object.repeatEveryDays);
  writer.writeLong(offsets[14], object.repeatEveryKm);
  writer.writeDateTime(offsets[15], object.updatedAt);
  writer.writeString(offsets[16], object.uuid);
}

ServiceModel _serviceModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ServiceModel(
    assetId: reader.readString(offsets[0]),
    averageKmPerDay: reader.readDoubleOrNull(offsets[1]),
    deletedAt: reader.readDateTimeOrNull(offsets[3]),
    isSynced: reader.readBoolOrNull(offsets[4]) ?? false,
    lastOdometerReading: reader.readLongOrNull(offsets[5]),
    lastServiceDate: reader.readDateTimeOrNull(offsets[6]),
    name: reader.readString(offsets[7]),
    nextDueDate: reader.readDateTimeOrNull(offsets[8]),
    nextDueOdometer: reader.readLongOrNull(offsets[9]),
    notifyBeforeDays: reader.readLongOrNull(offsets[10]) ?? 7,
    reminderEnabled: reader.readBoolOrNull(offsets[11]) ?? true,
    reminderTime: reader.readDateTimeOrNull(offsets[12]),
    repeatEveryDays: reader.readLongOrNull(offsets[13]),
    repeatEveryKm: reader.readLongOrNull(offsets[14]),
    updatedAt: reader.readDateTimeOrNull(offsets[15]),
    uuid: reader.readString(offsets[16]),
  );
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  return object;
}

P _serviceModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset) ?? 7) as P;
    case 11:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _serviceModelGetId(ServiceModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _serviceModelGetLinks(ServiceModel object) {
  return [];
}

void _serviceModelAttach(
    IsarCollection<dynamic> col, Id id, ServiceModel object) {
  object.id = id;
}

extension ServiceModelByIndex on IsarCollection<ServiceModel> {
  Future<ServiceModel?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  ServiceModel? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<ServiceModel?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<ServiceModel?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(ServiceModel object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(ServiceModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<ServiceModel> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<ServiceModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension ServiceModelQueryWhereSort
    on QueryBuilder<ServiceModel, ServiceModel, QWhere> {
  QueryBuilder<ServiceModel, ServiceModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ServiceModelQueryWhere
    on QueryBuilder<ServiceModel, ServiceModel, QWhereClause> {
  QueryBuilder<ServiceModel, ServiceModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterWhereClause> uuidNotEqualTo(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterWhereClause> assetIdEqualTo(
      String assetId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'assetId',
        value: [assetId],
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterWhereClause> assetIdNotEqualTo(
      String assetId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assetId',
              lower: [],
              upper: [assetId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assetId',
              lower: [assetId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assetId',
              lower: [assetId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assetId',
              lower: [],
              upper: [assetId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ServiceModelQueryFilter
    on QueryBuilder<ServiceModel, ServiceModel, QFilterCondition> {
  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      assetIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      assetIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      assetIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      assetIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      assetIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      assetIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      assetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      assetIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      assetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetId',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      assetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assetId',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      averageKmPerDayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'averageKmPerDay',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      averageKmPerDayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'averageKmPerDay',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      averageKmPerDayEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'averageKmPerDay',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      averageKmPerDayGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'averageKmPerDay',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      averageKmPerDayLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'averageKmPerDay',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      averageKmPerDayBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'averageKmPerDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      deletedAtLessThan(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      deletedAtBetween(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastOdometerReadingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastOdometerReading',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastOdometerReadingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastOdometerReading',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastOdometerReadingEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastOdometerReading',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastOdometerReadingGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastOdometerReading',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastOdometerReadingLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastOdometerReading',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastOdometerReadingBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastOdometerReading',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastServiceDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastServiceDate',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastServiceDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastServiceDate',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastServiceDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastServiceDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastServiceDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastServiceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      lastServiceDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastServiceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextDueDate',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextDueDate',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextDueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextDueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueOdometerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextDueOdometer',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueOdometerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextDueOdometer',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueOdometerEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextDueOdometer',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueOdometerGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextDueOdometer',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueOdometerLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextDueOdometer',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      nextDueOdometerBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextDueOdometer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      notifyBeforeDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notifyBeforeDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      notifyBeforeDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notifyBeforeDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      notifyBeforeDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notifyBeforeDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      notifyBeforeDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notifyBeforeDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      reminderEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      reminderTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reminderTime',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      reminderTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reminderTime',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      reminderTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      reminderTimeBetween(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'repeatEveryDays',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'repeatEveryDays',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatEveryDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryDaysGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatEveryDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryDaysLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatEveryDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatEveryDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryKmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'repeatEveryKm',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryKmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'repeatEveryKm',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryKmEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatEveryKm',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryKmGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatEveryKm',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryKmLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatEveryKm',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      repeatEveryKmBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatEveryKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      updatedAtLessThan(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      updatedAtBetween(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> uuidEqualTo(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> uuidLessThan(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> uuidBetween(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> uuidEndsWith(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> uuidContains(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition> uuidMatches(
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

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension ServiceModelQueryObject
    on QueryBuilder<ServiceModel, ServiceModel, QFilterCondition> {}

extension ServiceModelQueryLinks
    on QueryBuilder<ServiceModel, ServiceModel, QFilterCondition> {}

extension ServiceModelQuerySortBy
    on QueryBuilder<ServiceModel, ServiceModel, QSortBy> {
  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByAssetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByAssetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByAverageKmPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageKmPerDay', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByAverageKmPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageKmPerDay', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByLastOdometerReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOdometerReading', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByLastOdometerReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOdometerReading', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByLastServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceDate', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByLastServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceDate', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByNextDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByNextDueOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueOdometer', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByNextDueOdometerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueOdometer', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByNotifyBeforeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyBeforeDays', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByNotifyBeforeDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyBeforeDays', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTime', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByReminderTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTime', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByRepeatEveryDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatEveryDays', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByRepeatEveryDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatEveryDays', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByRepeatEveryKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatEveryKm', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      sortByRepeatEveryKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatEveryKm', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension ServiceModelQuerySortThenBy
    on QueryBuilder<ServiceModel, ServiceModel, QSortThenBy> {
  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByAssetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByAssetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByAverageKmPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageKmPerDay', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByAverageKmPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageKmPerDay', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByLastOdometerReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOdometerReading', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByLastOdometerReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOdometerReading', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByLastServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceDate', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByLastServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastServiceDate', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByNextDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueDate', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByNextDueOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueOdometer', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByNextDueOdometerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextDueOdometer', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByNotifyBeforeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyBeforeDays', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByNotifyBeforeDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyBeforeDays', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTime', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByReminderTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTime', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByRepeatEveryDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatEveryDays', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByRepeatEveryDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatEveryDays', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByRepeatEveryKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatEveryKm', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy>
      thenByRepeatEveryKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatEveryKm', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension ServiceModelQueryWhereDistinct
    on QueryBuilder<ServiceModel, ServiceModel, QDistinct> {
  QueryBuilder<ServiceModel, ServiceModel, QDistinct> distinctByAssetId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct>
      distinctByAverageKmPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageKmPerDay');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct>
      distinctByLastOdometerReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastOdometerReading');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct>
      distinctByLastServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastServiceDate');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct> distinctByNextDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextDueDate');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct>
      distinctByNextDueOdometer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextDueOdometer');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct>
      distinctByNotifyBeforeDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifyBeforeDays');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct>
      distinctByReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderEnabled');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct> distinctByReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderTime');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct>
      distinctByRepeatEveryDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatEveryDays');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct>
      distinctByRepeatEveryKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatEveryKm');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<ServiceModel, ServiceModel, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension ServiceModelQueryProperty
    on QueryBuilder<ServiceModel, ServiceModel, QQueryProperty> {
  QueryBuilder<ServiceModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ServiceModel, String, QQueryOperations> assetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetId');
    });
  }

  QueryBuilder<ServiceModel, double?, QQueryOperations>
      averageKmPerDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageKmPerDay');
    });
  }

  QueryBuilder<ServiceModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ServiceModel, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<ServiceModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<ServiceModel, int?, QQueryOperations>
      lastOdometerReadingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastOdometerReading');
    });
  }

  QueryBuilder<ServiceModel, DateTime?, QQueryOperations>
      lastServiceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastServiceDate');
    });
  }

  QueryBuilder<ServiceModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ServiceModel, DateTime?, QQueryOperations>
      nextDueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextDueDate');
    });
  }

  QueryBuilder<ServiceModel, int?, QQueryOperations> nextDueOdometerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextDueOdometer');
    });
  }

  QueryBuilder<ServiceModel, int, QQueryOperations> notifyBeforeDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifyBeforeDays');
    });
  }

  QueryBuilder<ServiceModel, bool, QQueryOperations> reminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderEnabled');
    });
  }

  QueryBuilder<ServiceModel, DateTime?, QQueryOperations>
      reminderTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderTime');
    });
  }

  QueryBuilder<ServiceModel, int?, QQueryOperations> repeatEveryDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatEveryDays');
    });
  }

  QueryBuilder<ServiceModel, int?, QQueryOperations> repeatEveryKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatEveryKm');
    });
  }

  QueryBuilder<ServiceModel, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ServiceModel, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
