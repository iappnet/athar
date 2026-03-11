// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_profile_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHealthProfileModelCollection on Isar {
  IsarCollection<HealthProfileModel> get healthProfileModels =>
      this.collection();
}

const HealthProfileModelSchema = CollectionSchema(
  name: r'HealthProfileModel',
  id: 8988456793443905751,
  properties: {
    r'allergies': PropertySchema(
      id: 0,
      name: r'allergies',
      type: IsarType.string,
    ),
    r'bloodType': PropertySchema(
      id: 1,
      name: r'bloodType',
      type: IsarType.string,
    ),
    r'emergencyContactName': PropertySchema(
      id: 2,
      name: r'emergencyContactName',
      type: IsarType.string,
    ),
    r'emergencyContactPhone': PropertySchema(
      id: 3,
      name: r'emergencyContactPhone',
      type: IsarType.string,
    ),
    r'insuranceNumber': PropertySchema(
      id: 4,
      name: r'insuranceNumber',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 5,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'moduleId': PropertySchema(
      id: 6,
      name: r'moduleId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(
      id: 8,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _healthProfileModelEstimateSize,
  serialize: _healthProfileModelSerialize,
  deserialize: _healthProfileModelDeserialize,
  deserializeProp: _healthProfileModelDeserializeProp,
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
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'moduleId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _healthProfileModelGetId,
  getLinks: _healthProfileModelGetLinks,
  attach: _healthProfileModelAttach,
  version: '3.1.0+1',
);

int _healthProfileModelEstimateSize(
  HealthProfileModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.allergies;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.bloodType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.emergencyContactName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.emergencyContactPhone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.insuranceNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.moduleId.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _healthProfileModelSerialize(
  HealthProfileModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.allergies);
  writer.writeString(offsets[1], object.bloodType);
  writer.writeString(offsets[2], object.emergencyContactName);
  writer.writeString(offsets[3], object.emergencyContactPhone);
  writer.writeString(offsets[4], object.insuranceNumber);
  writer.writeBool(offsets[5], object.isSynced);
  writer.writeString(offsets[6], object.moduleId);
  writer.writeDateTime(offsets[7], object.updatedAt);
  writer.writeString(offsets[8], object.uuid);
}

HealthProfileModel _healthProfileModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HealthProfileModel(
    allergies: reader.readStringOrNull(offsets[0]),
    bloodType: reader.readStringOrNull(offsets[1]),
    emergencyContactName: reader.readStringOrNull(offsets[2]),
    emergencyContactPhone: reader.readStringOrNull(offsets[3]),
    insuranceNumber: reader.readStringOrNull(offsets[4]),
    isSynced: reader.readBoolOrNull(offsets[5]) ?? false,
    moduleId: reader.readString(offsets[6]),
    uuid: reader.readString(offsets[8]),
  );
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[7]);
  return object;
}

P _healthProfileModelDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _healthProfileModelGetId(HealthProfileModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _healthProfileModelGetLinks(
    HealthProfileModel object) {
  return [];
}

void _healthProfileModelAttach(
    IsarCollection<dynamic> col, Id id, HealthProfileModel object) {
  object.id = id;
}

extension HealthProfileModelByIndex on IsarCollection<HealthProfileModel> {
  Future<HealthProfileModel?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  HealthProfileModel? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<HealthProfileModel?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<HealthProfileModel?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(HealthProfileModel object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(HealthProfileModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<HealthProfileModel> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<HealthProfileModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }

  Future<HealthProfileModel?> getByModuleId(String moduleId) {
    return getByIndex(r'moduleId', [moduleId]);
  }

  HealthProfileModel? getByModuleIdSync(String moduleId) {
    return getByIndexSync(r'moduleId', [moduleId]);
  }

  Future<bool> deleteByModuleId(String moduleId) {
    return deleteByIndex(r'moduleId', [moduleId]);
  }

  bool deleteByModuleIdSync(String moduleId) {
    return deleteByIndexSync(r'moduleId', [moduleId]);
  }

  Future<List<HealthProfileModel?>> getAllByModuleId(
      List<String> moduleIdValues) {
    final values = moduleIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'moduleId', values);
  }

  List<HealthProfileModel?> getAllByModuleIdSync(List<String> moduleIdValues) {
    final values = moduleIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'moduleId', values);
  }

  Future<int> deleteAllByModuleId(List<String> moduleIdValues) {
    final values = moduleIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'moduleId', values);
  }

  int deleteAllByModuleIdSync(List<String> moduleIdValues) {
    final values = moduleIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'moduleId', values);
  }

  Future<Id> putByModuleId(HealthProfileModel object) {
    return putByIndex(r'moduleId', object);
  }

  Id putByModuleIdSync(HealthProfileModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'moduleId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByModuleId(List<HealthProfileModel> objects) {
    return putAllByIndex(r'moduleId', objects);
  }

  List<Id> putAllByModuleIdSync(List<HealthProfileModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'moduleId', objects, saveLinks: saveLinks);
  }
}

extension HealthProfileModelQueryWhereSort
    on QueryBuilder<HealthProfileModel, HealthProfileModel, QWhere> {
  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HealthProfileModelQueryWhere
    on QueryBuilder<HealthProfileModel, HealthProfileModel, QWhereClause> {
  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterWhereClause>
      uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterWhereClause>
      uuidNotEqualTo(String uuid) {
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterWhereClause>
      moduleIdEqualTo(String moduleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'moduleId',
        value: [moduleId],
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterWhereClause>
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
}

extension HealthProfileModelQueryFilter
    on QueryBuilder<HealthProfileModel, HealthProfileModel, QFilterCondition> {
  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'allergies',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'allergies',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'allergies',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'allergies',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allergies',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      allergiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'allergies',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bloodType',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bloodType',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bloodType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bloodType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodType',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      bloodTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bloodType',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'emergencyContactName',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'emergencyContactName',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emergencyContactName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emergencyContactName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyContactName',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emergencyContactName',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'emergencyContactPhone',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'emergencyContactPhone',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emergencyContactPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emergencyContactPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyContactPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      emergencyContactPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emergencyContactPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'insuranceNumber',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'insuranceNumber',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insuranceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insuranceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insuranceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insuranceNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'insuranceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'insuranceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'insuranceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'insuranceNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insuranceNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      insuranceNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'insuranceNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      moduleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      moduleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'moduleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      moduleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moduleId',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      moduleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'moduleId',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      uuidEqualTo(
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      uuidBetween(
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
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

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension HealthProfileModelQueryObject
    on QueryBuilder<HealthProfileModel, HealthProfileModel, QFilterCondition> {}

extension HealthProfileModelQueryLinks
    on QueryBuilder<HealthProfileModel, HealthProfileModel, QFilterCondition> {}

extension HealthProfileModelQuerySortBy
    on QueryBuilder<HealthProfileModel, HealthProfileModel, QSortBy> {
  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByAllergies() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allergies', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByAllergiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allergies', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByBloodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByBloodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByEmergencyContactName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactName', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByEmergencyContactNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactName', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByEmergencyContactPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactPhone', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByEmergencyContactPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactPhone', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByInsuranceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceNumber', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByInsuranceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceNumber', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByModuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByModuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension HealthProfileModelQuerySortThenBy
    on QueryBuilder<HealthProfileModel, HealthProfileModel, QSortThenBy> {
  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByAllergies() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allergies', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByAllergiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allergies', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByBloodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByBloodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByEmergencyContactName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactName', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByEmergencyContactNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactName', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByEmergencyContactPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactPhone', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByEmergencyContactPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactPhone', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByInsuranceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceNumber', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByInsuranceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insuranceNumber', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByModuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByModuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension HealthProfileModelQueryWhereDistinct
    on QueryBuilder<HealthProfileModel, HealthProfileModel, QDistinct> {
  QueryBuilder<HealthProfileModel, HealthProfileModel, QDistinct>
      distinctByAllergies({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allergies', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QDistinct>
      distinctByBloodType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bloodType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QDistinct>
      distinctByEmergencyContactName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emergencyContactName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QDistinct>
      distinctByEmergencyContactPhone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emergencyContactPhone',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QDistinct>
      distinctByInsuranceNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insuranceNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QDistinct>
      distinctByModuleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moduleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<HealthProfileModel, HealthProfileModel, QDistinct>
      distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension HealthProfileModelQueryProperty
    on QueryBuilder<HealthProfileModel, HealthProfileModel, QQueryProperty> {
  QueryBuilder<HealthProfileModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HealthProfileModel, String?, QQueryOperations>
      allergiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allergies');
    });
  }

  QueryBuilder<HealthProfileModel, String?, QQueryOperations>
      bloodTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bloodType');
    });
  }

  QueryBuilder<HealthProfileModel, String?, QQueryOperations>
      emergencyContactNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emergencyContactName');
    });
  }

  QueryBuilder<HealthProfileModel, String?, QQueryOperations>
      emergencyContactPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emergencyContactPhone');
    });
  }

  QueryBuilder<HealthProfileModel, String?, QQueryOperations>
      insuranceNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insuranceNumber');
    });
  }

  QueryBuilder<HealthProfileModel, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<HealthProfileModel, String, QQueryOperations>
      moduleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moduleId');
    });
  }

  QueryBuilder<HealthProfileModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<HealthProfileModel, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
