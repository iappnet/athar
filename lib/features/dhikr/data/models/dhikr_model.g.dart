// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dhikr_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDhikrModelCollection on Isar {
  IsarCollection<DhikrModel> get dhikrModels => this.collection();
}

const DhikrModelSchema = CollectionSchema(
  name: r'DhikrModel',
  id: -3393993723658102084,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
      enumMap: _DhikrModelcategoryEnumValueMap,
    ),
    r'count': PropertySchema(
      id: 1,
      name: r'count',
      type: IsarType.long,
    ),
    r'currentCount': PropertySchema(
      id: 2,
      name: r'currentCount',
      type: IsarType.long,
    ),
    r'isCustom': PropertySchema(
      id: 3,
      name: r'isCustom',
      type: IsarType.bool,
    ),
    r'order': PropertySchema(
      id: 4,
      name: r'order',
      type: IsarType.long,
    ),
    r'text': PropertySchema(
      id: 5,
      name: r'text',
      type: IsarType.string,
    ),
    r'virtue': PropertySchema(
      id: 6,
      name: r'virtue',
      type: IsarType.string,
    )
  },
  estimateSize: _dhikrModelEstimateSize,
  serialize: _dhikrModelSerialize,
  deserialize: _dhikrModelDeserialize,
  deserializeProp: _dhikrModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _dhikrModelGetId,
  getLinks: _dhikrModelGetLinks,
  attach: _dhikrModelAttach,
  version: '3.1.0+1',
);

int _dhikrModelEstimateSize(
  DhikrModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.name.length * 3;
  bytesCount += 3 + object.text.length * 3;
  {
    final value = object.virtue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _dhikrModelSerialize(
  DhikrModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category.name);
  writer.writeLong(offsets[1], object.count);
  writer.writeLong(offsets[2], object.currentCount);
  writer.writeBool(offsets[3], object.isCustom);
  writer.writeLong(offsets[4], object.order);
  writer.writeString(offsets[5], object.text);
  writer.writeString(offsets[6], object.virtue);
}

DhikrModel _dhikrModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DhikrModel();
  object.category =
      _DhikrModelcategoryValueEnumMap[reader.readStringOrNull(offsets[0])] ??
          DhikrCategory.morning;
  object.count = reader.readLong(offsets[1]);
  object.currentCount = reader.readLong(offsets[2]);
  object.id = id;
  object.isCustom = reader.readBool(offsets[3]);
  object.order = reader.readLong(offsets[4]);
  object.text = reader.readString(offsets[5]);
  object.virtue = reader.readStringOrNull(offsets[6]);
  return object;
}

P _dhikrModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_DhikrModelcategoryValueEnumMap[
              reader.readStringOrNull(offset)] ??
          DhikrCategory.morning) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DhikrModelcategoryEnumValueMap = {
  r'morning': r'morning',
  r'evening': r'evening',
  r'prayer': r'prayer',
  r'sleep': r'sleep',
  r'custom': r'custom',
};
const _DhikrModelcategoryValueEnumMap = {
  r'morning': DhikrCategory.morning,
  r'evening': DhikrCategory.evening,
  r'prayer': DhikrCategory.prayer,
  r'sleep': DhikrCategory.sleep,
  r'custom': DhikrCategory.custom,
};

Id _dhikrModelGetId(DhikrModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dhikrModelGetLinks(DhikrModel object) {
  return [];
}

void _dhikrModelAttach(IsarCollection<dynamic> col, Id id, DhikrModel object) {
  object.id = id;
}

extension DhikrModelQueryWhereSort
    on QueryBuilder<DhikrModel, DhikrModel, QWhere> {
  QueryBuilder<DhikrModel, DhikrModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DhikrModelQueryWhere
    on QueryBuilder<DhikrModel, DhikrModel, QWhereClause> {
  QueryBuilder<DhikrModel, DhikrModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DhikrModel, DhikrModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterWhereClause> idBetween(
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
}

extension DhikrModelQueryFilter
    on QueryBuilder<DhikrModel, DhikrModel, QFilterCondition> {
  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> categoryEqualTo(
    DhikrCategory value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition>
      categoryGreaterThan(
    DhikrCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> categoryLessThan(
    DhikrCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> categoryBetween(
    DhikrCategory lower,
    DhikrCategory upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> categoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> countEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> countGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> countLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> countBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'count',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition>
      currentCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition>
      currentCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition>
      currentCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition>
      currentCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> isCustomEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCustom',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> orderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> textContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> textMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> virtueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'virtue',
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition>
      virtueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'virtue',
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> virtueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'virtue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> virtueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'virtue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> virtueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'virtue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> virtueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'virtue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> virtueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'virtue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> virtueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'virtue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> virtueContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'virtue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> virtueMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'virtue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition> virtueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'virtue',
        value: '',
      ));
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterFilterCondition>
      virtueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'virtue',
        value: '',
      ));
    });
  }
}

extension DhikrModelQueryObject
    on QueryBuilder<DhikrModel, DhikrModel, QFilterCondition> {}

extension DhikrModelQueryLinks
    on QueryBuilder<DhikrModel, DhikrModel, QFilterCondition> {}

extension DhikrModelQuerySortBy
    on QueryBuilder<DhikrModel, DhikrModel, QSortBy> {
  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByCurrentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentCount', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByCurrentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentCount', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByIsCustom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustom', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByIsCustomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustom', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByVirtue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virtue', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> sortByVirtueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virtue', Sort.desc);
    });
  }
}

extension DhikrModelQuerySortThenBy
    on QueryBuilder<DhikrModel, DhikrModel, QSortThenBy> {
  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByCurrentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentCount', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByCurrentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentCount', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByIsCustom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustom', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByIsCustomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustom', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByVirtue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virtue', Sort.asc);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QAfterSortBy> thenByVirtueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virtue', Sort.desc);
    });
  }
}

extension DhikrModelQueryWhereDistinct
    on QueryBuilder<DhikrModel, DhikrModel, QDistinct> {
  QueryBuilder<DhikrModel, DhikrModel, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QDistinct> distinctByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'count');
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QDistinct> distinctByCurrentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentCount');
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QDistinct> distinctByIsCustom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCustom');
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QDistinct> distinctByText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DhikrModel, DhikrModel, QDistinct> distinctByVirtue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'virtue', caseSensitive: caseSensitive);
    });
  }
}

extension DhikrModelQueryProperty
    on QueryBuilder<DhikrModel, DhikrModel, QQueryProperty> {
  QueryBuilder<DhikrModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DhikrModel, DhikrCategory, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<DhikrModel, int, QQueryOperations> countProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'count');
    });
  }

  QueryBuilder<DhikrModel, int, QQueryOperations> currentCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentCount');
    });
  }

  QueryBuilder<DhikrModel, bool, QQueryOperations> isCustomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCustom');
    });
  }

  QueryBuilder<DhikrModel, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<DhikrModel, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<DhikrModel, String?, QQueryOperations> virtueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'virtue');
    });
  }
}
