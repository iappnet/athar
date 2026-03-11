// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_range.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const TimeRangeSchema = Schema(
  name: r'TimeRange',
  id: 3189720617673134546,
  properties: {
    r'categoryId': PropertySchema(
      id: 0,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'endHour': PropertySchema(
      id: 1,
      name: r'endHour',
      type: IsarType.long,
    ),
    r'endMinute': PropertySchema(
      id: 2,
      name: r'endMinute',
      type: IsarType.long,
    ),
    r'startHour': PropertySchema(
      id: 3,
      name: r'startHour',
      type: IsarType.long,
    ),
    r'startMinute': PropertySchema(
      id: 4,
      name: r'startMinute',
      type: IsarType.long,
    )
  },
  estimateSize: _timeRangeEstimateSize,
  serialize: _timeRangeSerialize,
  deserialize: _timeRangeDeserialize,
  deserializeProp: _timeRangeDeserializeProp,
);

int _timeRangeEstimateSize(
  TimeRange object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _timeRangeSerialize(
  TimeRange object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.categoryId);
  writer.writeLong(offsets[1], object.endHour);
  writer.writeLong(offsets[2], object.endMinute);
  writer.writeLong(offsets[3], object.startHour);
  writer.writeLong(offsets[4], object.startMinute);
}

TimeRange _timeRangeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TimeRange(
    categoryId: reader.readLongOrNull(offsets[0]),
    endHour: reader.readLongOrNull(offsets[1]) ?? 15,
    endMinute: reader.readLongOrNull(offsets[2]) ?? 0,
    startHour: reader.readLongOrNull(offsets[3]) ?? 7,
    startMinute: reader.readLongOrNull(offsets[4]) ?? 0,
  );
  return object;
}

P _timeRangeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 15) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 7) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension TimeRangeQueryFilter
    on QueryBuilder<TimeRange, TimeRange, QFilterCondition> {
  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoryId',
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition>
      categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoryId',
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> categoryIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition>
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

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> categoryIdLessThan(
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

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> categoryIdBetween(
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

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> endHourEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> endHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> endHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> endHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> endMinuteEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition>
      endMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> endMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> endMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> startHourEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition>
      startHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> startHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> startHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> startMinuteEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition>
      startMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> startMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeRange, TimeRange, QAfterFilterCondition> startMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TimeRangeQueryObject
    on QueryBuilder<TimeRange, TimeRange, QFilterCondition> {}
