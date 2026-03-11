// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_pattern.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RecurrencePatternSchema = Schema(
  name: r'RecurrencePattern',
  id: 8363953192313144933,
  properties: {
    r'endDate': PropertySchema(
      id: 0,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'endType': PropertySchema(
      id: 1,
      name: r'endType',
      type: IsarType.byte,
      enumMap: _RecurrencePatternendTypeEnumValueMap,
    ),
    r'interval': PropertySchema(
      id: 2,
      name: r'interval',
      type: IsarType.long,
    ),
    r'monthDays': PropertySchema(
      id: 3,
      name: r'monthDays',
      type: IsarType.longList,
    ),
    r'occurrences': PropertySchema(
      id: 4,
      name: r'occurrences',
      type: IsarType.long,
    ),
    r'startDate': PropertySchema(
      id: 5,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'type': PropertySchema(
      id: 6,
      name: r'type',
      type: IsarType.byte,
      enumMap: _RecurrencePatterntypeEnumValueMap,
    ),
    r'weekDays': PropertySchema(
      id: 7,
      name: r'weekDays',
      type: IsarType.longList,
    )
  },
  estimateSize: _recurrencePatternEstimateSize,
  serialize: _recurrencePatternSerialize,
  deserialize: _recurrencePatternDeserialize,
  deserializeProp: _recurrencePatternDeserializeProp,
);

int _recurrencePatternEstimateSize(
  RecurrencePattern object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.monthDays.length * 8;
  bytesCount += 3 + object.weekDays.length * 8;
  return bytesCount;
}

void _recurrencePatternSerialize(
  RecurrencePattern object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.endDate);
  writer.writeByte(offsets[1], object.endType.index);
  writer.writeLong(offsets[2], object.interval);
  writer.writeLongList(offsets[3], object.monthDays);
  writer.writeLong(offsets[4], object.occurrences);
  writer.writeDateTime(offsets[5], object.startDate);
  writer.writeByte(offsets[6], object.type.index);
  writer.writeLongList(offsets[7], object.weekDays);
}

RecurrencePattern _recurrencePatternDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecurrencePattern();
  object.endDate = reader.readDateTimeOrNull(offsets[0]);
  object.endType = _RecurrencePatternendTypeValueEnumMap[
          reader.readByteOrNull(offsets[1])] ??
      RecurrenceEndType.never;
  object.interval = reader.readLong(offsets[2]);
  object.monthDays = reader.readLongList(offsets[3]) ?? [];
  object.occurrences = reader.readLongOrNull(offsets[4]);
  object.startDate = reader.readDateTimeOrNull(offsets[5]);
  object.type =
      _RecurrencePatterntypeValueEnumMap[reader.readByteOrNull(offsets[6])] ??
          RecurrenceType.none;
  object.weekDays = reader.readLongList(offsets[7]) ?? [];
  return object;
}

P _recurrencePatternDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (_RecurrencePatternendTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          RecurrenceEndType.never) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLongList(offset) ?? []) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (_RecurrencePatterntypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          RecurrenceType.none) as P;
    case 7:
      return (reader.readLongList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RecurrencePatternendTypeEnumValueMap = {
  'never': 0,
  'afterOccurrences': 1,
  'onDate': 2,
};
const _RecurrencePatternendTypeValueEnumMap = {
  0: RecurrenceEndType.never,
  1: RecurrenceEndType.afterOccurrences,
  2: RecurrenceEndType.onDate,
};
const _RecurrencePatterntypeEnumValueMap = {
  'none': 0,
  'daily': 1,
  'weekly': 2,
  'monthly': 3,
  'yearly': 4,
  'custom': 5,
};
const _RecurrencePatterntypeValueEnumMap = {
  0: RecurrenceType.none,
  1: RecurrenceType.daily,
  2: RecurrenceType.weekly,
  3: RecurrenceType.monthly,
  4: RecurrenceType.yearly,
  5: RecurrenceType.custom,
};

extension RecurrencePatternQueryFilter
    on QueryBuilder<RecurrencePattern, RecurrencePattern, QFilterCondition> {
  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      endDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      endTypeEqualTo(RecurrenceEndType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endType',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      endTypeGreaterThan(
    RecurrenceEndType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endType',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      endTypeLessThan(
    RecurrenceEndType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endType',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      endTypeBetween(
    RecurrenceEndType lower,
    RecurrenceEndType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      intervalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      intervalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      intervalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      intervalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interval',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      monthDaysElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthDays',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      monthDaysElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthDays',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      monthDaysElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthDays',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      monthDaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      monthDaysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monthDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      monthDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monthDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      monthDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monthDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      monthDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monthDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      monthDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monthDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      monthDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monthDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      occurrencesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'occurrences',
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      occurrencesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'occurrences',
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      occurrencesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurrences',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      occurrencesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occurrences',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      occurrencesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occurrences',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      occurrencesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occurrences',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      startDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
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

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
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

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
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

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      typeEqualTo(RecurrenceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      typeGreaterThan(
    RecurrenceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      typeLessThan(
    RecurrenceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      typeBetween(
    RecurrenceType lower,
    RecurrenceType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      weekDaysElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekDays',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      weekDaysElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekDays',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      weekDaysElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekDays',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      weekDaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      weekDaysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      weekDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      weekDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      weekDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      weekDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RecurrencePattern, RecurrencePattern, QAfterFilterCondition>
      weekDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weekDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension RecurrencePatternQueryObject
    on QueryBuilder<RecurrencePattern, RecurrencePattern, QFilterCondition> {}
