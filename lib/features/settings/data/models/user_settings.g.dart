// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserSettingsCollection on Isar {
  IsarCollection<UserSettings> get userSettings => this.collection();
}

const UserSettingsSchema = CollectionSchema(
  name: r'UserSettings',
  id: 4939698790990493221,
  properties: {
    r'appointmentMultipleReminders': PropertySchema(
      id: 0,
      name: r'appointmentMultipleReminders',
      type: IsarType.bool,
    ),
    r'assetInsuranceReminders': PropertySchema(
      id: 1,
      name: r'assetInsuranceReminders',
      type: IsarType.bool,
    ),
    r'assetLicenseReminders': PropertySchema(
      id: 2,
      name: r'assetLicenseReminders',
      type: IsarType.bool,
    ),
    r'assetMaintenanceReminders': PropertySchema(
      id: 3,
      name: r'assetMaintenanceReminders',
      type: IsarType.bool,
    ),
    r'assetReminderDaysBefore': PropertySchema(
      id: 4,
      name: r'assetReminderDaysBefore',
      type: IsarType.long,
    ),
    r'assetWarrantyReminders': PropertySchema(
      id: 5,
      name: r'assetWarrantyReminders',
      type: IsarType.bool,
    ),
    r'athkarDisplayMode': PropertySchema(
      id: 6,
      name: r'athkarDisplayMode',
      type: IsarType.string,
      enumMap: _UserSettingsathkarDisplayModeEnumValueMap,
    ),
    r'athkarSessionViewMode': PropertySchema(
      id: 7,
      name: r'athkarSessionViewMode',
      type: IsarType.string,
      enumMap: _UserSettingsathkarSessionViewModeEnumValueMap,
    ),
    r'cityName': PropertySchema(
      id: 8,
      name: r'cityName',
      type: IsarType.string,
    ),
    r'defaultAppointmentReminderMinutes': PropertySchema(
      id: 9,
      name: r'defaultAppointmentReminderMinutes',
      type: IsarType.long,
    ),
    r'defaultHabitReminderTime': PropertySchema(
      id: 10,
      name: r'defaultHabitReminderTime',
      type: IsarType.dateTime,
    ),
    r'didMigratePrayerFeatureSettings': PropertySchema(
      id: 11,
      name: r'didMigratePrayerFeatureSettings',
      type: IsarType.bool,
    ),
    r'didMigrateThemePreference': PropertySchema(
      id: 12,
      name: r'didMigrateThemePreference',
      type: IsarType.bool,
    ),
    r'disableGyroscope': PropertySchema(
      id: 13,
      name: r'disableGyroscope',
      type: IsarType.bool,
    ),
    r'easternNumerals': PropertySchema(
      id: 14,
      name: r'easternNumerals',
      type: IsarType.bool,
    ),
    r'enablePrayerReminders': PropertySchema(
      id: 15,
      name: r'enablePrayerReminders',
      type: IsarType.bool,
    ),
    r'eveningAthkarTime': PropertySchema(
      id: 16,
      name: r'eveningAthkarTime',
      type: IsarType.string,
    ),
    r'familyCategoryId': PropertySchema(
      id: 17,
      name: r'familyCategoryId',
      type: IsarType.long,
    ),
    r'familyPeriods': PropertySchema(
      id: 18,
      name: r'familyPeriods',
      type: IsarType.objectList,
      target: r'TimeRange',
    ),
    r'focusIntensity': PropertySchema(
      id: 19,
      name: r'focusIntensity',
      type: IsarType.string,
      enumMap: _UserSettingsfocusIntensityEnumValueMap,
    ),
    r'freeCategoryId': PropertySchema(
      id: 20,
      name: r'freeCategoryId',
      type: IsarType.long,
    ),
    r'freePeriods': PropertySchema(
      id: 21,
      name: r'freePeriods',
      type: IsarType.objectList,
      target: r'TimeRange',
    ),
    r'hideNavOnScroll': PropertySchema(
      id: 22,
      name: r'hideNavOnScroll',
      type: IsarType.bool,
    ),
    r'isAppointmentRemindersEnabled': PropertySchema(
      id: 23,
      name: r'isAppointmentRemindersEnabled',
      type: IsarType.bool,
    ),
    r'isAssetRemindersEnabled': PropertySchema(
      id: 24,
      name: r'isAssetRemindersEnabled',
      type: IsarType.bool,
    ),
    r'isAthkarEnabled': PropertySchema(
      id: 25,
      name: r'isAthkarEnabled',
      type: IsarType.bool,
    ),
    r'isAthkarRemindersEnabled': PropertySchema(
      id: 26,
      name: r'isAthkarRemindersEnabled',
      type: IsarType.bool,
    ),
    r'isAutoModeEnabled': PropertySchema(
      id: 27,
      name: r'isAutoModeEnabled',
      type: IsarType.bool,
    ),
    r'isAutoSyncEnabled': PropertySchema(
      id: 28,
      name: r'isAutoSyncEnabled',
      type: IsarType.bool,
    ),
    r'isBiometricEnabled': PropertySchema(
      id: 29,
      name: r'isBiometricEnabled',
      type: IsarType.bool,
    ),
    r'isDarkMode': PropertySchema(
      id: 30,
      name: r'isDarkMode',
      type: IsarType.bool,
    ),
    r'isHabitRemindersEnabled': PropertySchema(
      id: 31,
      name: r'isHabitRemindersEnabled',
      type: IsarType.bool,
    ),
    r'isHijriMode': PropertySchema(
      id: 32,
      name: r'isHijriMode',
      type: IsarType.bool,
    ),
    r'isMedicationNotificationsEnabled': PropertySchema(
      id: 33,
      name: r'isMedicationNotificationsEnabled',
      type: IsarType.bool,
    ),
    r'isPrayerCardEnabled': PropertySchema(
      id: 34,
      name: r'isPrayerCardEnabled',
      type: IsarType.bool,
    ),
    r'isPrayerEnabled': PropertySchema(
      id: 35,
      name: r'isPrayerEnabled',
      type: IsarType.bool,
    ),
    r'isPrayerNotificationsEnabled': PropertySchema(
      id: 36,
      name: r'isPrayerNotificationsEnabled',
      type: IsarType.bool,
    ),
    r'isProjectRemindersEnabled': PropertySchema(
      id: 37,
      name: r'isProjectRemindersEnabled',
      type: IsarType.bool,
    ),
    r'isTaskRemindersEnabled': PropertySchema(
      id: 38,
      name: r'isTaskRemindersEnabled',
      type: IsarType.bool,
    ),
    r'isTasksKanbanView': PropertySchema(
      id: 39,
      name: r'isTasksKanbanView',
      type: IsarType.bool,
    ),
    r'lastSyncAt': PropertySchema(
      id: 40,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    ),
    r'lastSyncError': PropertySchema(
      id: 41,
      name: r'lastSyncError',
      type: IsarType.string,
    ),
    r'latitude': PropertySchema(
      id: 42,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 43,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'morningAthkarTime': PropertySchema(
      id: 44,
      name: r'morningAthkarTime',
      type: IsarType.string,
    ),
    r'prayerCardDisplayMode': PropertySchema(
      id: 45,
      name: r'prayerCardDisplayMode',
      type: IsarType.string,
      enumMap: _UserSettingsprayerCardDisplayModeEnumValueMap,
    ),
    r'prayerTimeAdjustmentMinutes': PropertySchema(
      id: 46,
      name: r'prayerTimeAdjustmentMinutes',
      type: IsarType.long,
    ),
    r'projectDailyReminders': PropertySchema(
      id: 47,
      name: r'projectDailyReminders',
      type: IsarType.bool,
    ),
    r'projectReminderDaysBefore': PropertySchema(
      id: 48,
      name: r'projectReminderDaysBefore',
      type: IsarType.long,
    ),
    r'projectReminderHoursBefore': PropertySchema(
      id: 49,
      name: r'projectReminderHoursBefore',
      type: IsarType.long,
    ),
    r'projectWeeklySummary': PropertySchema(
      id: 50,
      name: r'projectWeeklySummary',
      type: IsarType.bool,
    ),
    r'quietCategoryId': PropertySchema(
      id: 51,
      name: r'quietCategoryId',
      type: IsarType.long,
    ),
    r'quietPeriods': PropertySchema(
      id: 52,
      name: r'quietPeriods',
      type: IsarType.objectList,
      target: r'TimeRange',
    ),
    r'reduceMotion': PropertySchema(
      id: 53,
      name: r'reduceMotion',
      type: IsarType.bool,
    ),
    r'respectQuietPeriodsForTasks': PropertySchema(
      id: 54,
      name: r'respectQuietPeriodsForTasks',
      type: IsarType.bool,
    ),
    r'sampleDataDismissed': PropertySchema(
      id: 55,
      name: r'sampleDataDismissed',
      type: IsarType.bool,
    ),
    r'sampleDataShown': PropertySchema(
      id: 56,
      name: r'sampleDataShown',
      type: IsarType.bool,
    ),
    r'showPrayerDotsOnCalendar': PropertySchema(
      id: 57,
      name: r'showPrayerDotsOnCalendar',
      type: IsarType.bool,
    ),
    r'sleepAthkarTime': PropertySchema(
      id: 58,
      name: r'sleepAthkarTime',
      type: IsarType.string,
    ),
    r'sleepCategoryId': PropertySchema(
      id: 59,
      name: r'sleepCategoryId',
      type: IsarType.long,
    ),
    r'sleepPeriods': PropertySchema(
      id: 60,
      name: r'sleepPeriods',
      type: IsarType.objectList,
      target: r'TimeRange',
    ),
    r'taskReminderMinutesBefore': PropertySchema(
      id: 61,
      name: r'taskReminderMinutesBefore',
      type: IsarType.long,
    ),
    r'themePreference': PropertySchema(
      id: 62,
      name: r'themePreference',
      type: IsarType.string,
      enumMap: _UserSettingsthemePreferenceEnumValueMap,
    ),
    r'workCategoryId': PropertySchema(
      id: 63,
      name: r'workCategoryId',
      type: IsarType.long,
    ),
    r'workDays': PropertySchema(
      id: 64,
      name: r'workDays',
      type: IsarType.longList,
    ),
    r'workPeriods': PropertySchema(
      id: 65,
      name: r'workPeriods',
      type: IsarType.objectList,
      target: r'TimeRange',
    )
  },
  estimateSize: _userSettingsEstimateSize,
  serialize: _userSettingsSerialize,
  deserialize: _userSettingsDeserialize,
  deserializeProp: _userSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'TimeRange': TimeRangeSchema},
  getId: _userSettingsGetId,
  getLinks: _userSettingsGetLinks,
  attach: _userSettingsAttach,
  version: '3.1.0+1',
);

int _userSettingsEstimateSize(
  UserSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.athkarDisplayMode.name.length * 3;
  bytesCount += 3 + object.athkarSessionViewMode.name.length * 3;
  {
    final value = object.cityName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.eveningAthkarTime.length * 3;
  {
    final list = object.familyPeriods;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[TimeRange]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              TimeRangeSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  bytesCount += 3 + object.focusIntensity.name.length * 3;
  {
    final list = object.freePeriods;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[TimeRange]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              TimeRangeSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.lastSyncError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.morningAthkarTime.length * 3;
  bytesCount += 3 + object.prayerCardDisplayMode.name.length * 3;
  {
    final list = object.quietPeriods;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[TimeRange]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              TimeRangeSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  bytesCount += 3 + object.sleepAthkarTime.length * 3;
  {
    final list = object.sleepPeriods;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[TimeRange]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              TimeRangeSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  bytesCount += 3 + object.themePreference.name.length * 3;
  {
    final value = object.workDays;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final list = object.workPeriods;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[TimeRange]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              TimeRangeSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  return bytesCount;
}

void _userSettingsSerialize(
  UserSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.appointmentMultipleReminders);
  writer.writeBool(offsets[1], object.assetInsuranceReminders);
  writer.writeBool(offsets[2], object.assetLicenseReminders);
  writer.writeBool(offsets[3], object.assetMaintenanceReminders);
  writer.writeLong(offsets[4], object.assetReminderDaysBefore);
  writer.writeBool(offsets[5], object.assetWarrantyReminders);
  writer.writeString(offsets[6], object.athkarDisplayMode.name);
  writer.writeString(offsets[7], object.athkarSessionViewMode.name);
  writer.writeString(offsets[8], object.cityName);
  writer.writeLong(offsets[9], object.defaultAppointmentReminderMinutes);
  writer.writeDateTime(offsets[10], object.defaultHabitReminderTime);
  writer.writeBool(offsets[11], object.didMigratePrayerFeatureSettings);
  writer.writeBool(offsets[12], object.didMigrateThemePreference);
  writer.writeBool(offsets[13], object.disableGyroscope);
  writer.writeBool(offsets[14], object.easternNumerals);
  writer.writeBool(offsets[15], object.enablePrayerReminders);
  writer.writeString(offsets[16], object.eveningAthkarTime);
  writer.writeLong(offsets[17], object.familyCategoryId);
  writer.writeObjectList<TimeRange>(
    offsets[18],
    allOffsets,
    TimeRangeSchema.serialize,
    object.familyPeriods,
  );
  writer.writeString(offsets[19], object.focusIntensity.name);
  writer.writeLong(offsets[20], object.freeCategoryId);
  writer.writeObjectList<TimeRange>(
    offsets[21],
    allOffsets,
    TimeRangeSchema.serialize,
    object.freePeriods,
  );
  writer.writeBool(offsets[22], object.hideNavOnScroll);
  writer.writeBool(offsets[23], object.isAppointmentRemindersEnabled);
  writer.writeBool(offsets[24], object.isAssetRemindersEnabled);
  writer.writeBool(offsets[25], object.isAthkarEnabled);
  writer.writeBool(offsets[26], object.isAthkarRemindersEnabled);
  writer.writeBool(offsets[27], object.isAutoModeEnabled);
  writer.writeBool(offsets[28], object.isAutoSyncEnabled);
  writer.writeBool(offsets[29], object.isBiometricEnabled);
  writer.writeBool(offsets[30], object.isDarkMode);
  writer.writeBool(offsets[31], object.isHabitRemindersEnabled);
  writer.writeBool(offsets[32], object.isHijriMode);
  writer.writeBool(offsets[33], object.isMedicationNotificationsEnabled);
  writer.writeBool(offsets[34], object.isPrayerCardEnabled);
  writer.writeBool(offsets[35], object.isPrayerEnabled);
  writer.writeBool(offsets[36], object.isPrayerNotificationsEnabled);
  writer.writeBool(offsets[37], object.isProjectRemindersEnabled);
  writer.writeBool(offsets[38], object.isTaskRemindersEnabled);
  writer.writeBool(offsets[39], object.isTasksKanbanView);
  writer.writeDateTime(offsets[40], object.lastSyncAt);
  writer.writeString(offsets[41], object.lastSyncError);
  writer.writeDouble(offsets[42], object.latitude);
  writer.writeDouble(offsets[43], object.longitude);
  writer.writeString(offsets[44], object.morningAthkarTime);
  writer.writeString(offsets[45], object.prayerCardDisplayMode.name);
  writer.writeLong(offsets[46], object.prayerTimeAdjustmentMinutes);
  writer.writeBool(offsets[47], object.projectDailyReminders);
  writer.writeLong(offsets[48], object.projectReminderDaysBefore);
  writer.writeLong(offsets[49], object.projectReminderHoursBefore);
  writer.writeBool(offsets[50], object.projectWeeklySummary);
  writer.writeLong(offsets[51], object.quietCategoryId);
  writer.writeObjectList<TimeRange>(
    offsets[52],
    allOffsets,
    TimeRangeSchema.serialize,
    object.quietPeriods,
  );
  writer.writeBool(offsets[53], object.reduceMotion);
  writer.writeBool(offsets[54], object.respectQuietPeriodsForTasks);
  writer.writeBool(offsets[55], object.sampleDataDismissed);
  writer.writeBool(offsets[56], object.sampleDataShown);
  writer.writeBool(offsets[57], object.showPrayerDotsOnCalendar);
  writer.writeString(offsets[58], object.sleepAthkarTime);
  writer.writeLong(offsets[59], object.sleepCategoryId);
  writer.writeObjectList<TimeRange>(
    offsets[60],
    allOffsets,
    TimeRangeSchema.serialize,
    object.sleepPeriods,
  );
  writer.writeLong(offsets[61], object.taskReminderMinutesBefore);
  writer.writeString(offsets[62], object.themePreference.name);
  writer.writeLong(offsets[63], object.workCategoryId);
  writer.writeLongList(offsets[64], object.workDays);
  writer.writeObjectList<TimeRange>(
    offsets[65],
    allOffsets,
    TimeRangeSchema.serialize,
    object.workPeriods,
  );
}

UserSettings _userSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserSettings(
    appointmentMultipleReminders: reader.readBoolOrNull(offsets[0]) ?? true,
    assetInsuranceReminders: reader.readBoolOrNull(offsets[1]) ?? true,
    assetLicenseReminders: reader.readBoolOrNull(offsets[2]) ?? true,
    assetMaintenanceReminders: reader.readBoolOrNull(offsets[3]) ?? true,
    assetReminderDaysBefore: reader.readLongOrNull(offsets[4]) ?? 7,
    assetWarrantyReminders: reader.readBoolOrNull(offsets[5]) ?? true,
    athkarDisplayMode: _UserSettingsathkarDisplayModeValueEnumMap[
            reader.readStringOrNull(offsets[6])] ??
        AthkarDisplayMode.independent,
    athkarSessionViewMode: _UserSettingsathkarSessionViewModeValueEnumMap[
            reader.readStringOrNull(offsets[7])] ??
        AthkarSessionViewMode.list,
    cityName: reader.readStringOrNull(offsets[8]),
    defaultAppointmentReminderMinutes: reader.readLongOrNull(offsets[9]) ?? 60,
    defaultHabitReminderTime: reader.readDateTimeOrNull(offsets[10]),
    didMigratePrayerFeatureSettings:
        reader.readBoolOrNull(offsets[11]) ?? false,
    didMigrateThemePreference: reader.readBoolOrNull(offsets[12]) ?? false,
    disableGyroscope: reader.readBoolOrNull(offsets[13]) ?? false,
    easternNumerals: reader.readBoolOrNull(offsets[14]) ?? false,
    enablePrayerReminders: reader.readBoolOrNull(offsets[15]) ?? true,
    eveningAthkarTime: reader.readStringOrNull(offsets[16]) ?? '17:00',
    familyPeriods: reader.readObjectList<TimeRange>(
      offsets[18],
      TimeRangeSchema.deserialize,
      allOffsets,
      TimeRange(),
    ),
    focusIntensity: _UserSettingsfocusIntensityValueEnumMap[
            reader.readStringOrNull(offsets[19])] ??
        FocusIntensity.standard,
    freePeriods: reader.readObjectList<TimeRange>(
      offsets[21],
      TimeRangeSchema.deserialize,
      allOffsets,
      TimeRange(),
    ),
    hideNavOnScroll: reader.readBoolOrNull(offsets[22]) ?? false,
    isAppointmentRemindersEnabled: reader.readBoolOrNull(offsets[23]) ?? true,
    isAssetRemindersEnabled: reader.readBoolOrNull(offsets[24]) ?? true,
    isAthkarEnabled: reader.readBoolOrNull(offsets[25]) ?? true,
    isAthkarRemindersEnabled: reader.readBoolOrNull(offsets[26]) ?? true,
    isAutoModeEnabled: reader.readBoolOrNull(offsets[27]) ?? false,
    isAutoSyncEnabled: reader.readBoolOrNull(offsets[28]) ?? false,
    isBiometricEnabled: reader.readBoolOrNull(offsets[29]) ?? false,
    isDarkMode: reader.readBoolOrNull(offsets[30]) ?? false,
    isHabitRemindersEnabled: reader.readBoolOrNull(offsets[31]) ?? true,
    isHijriMode: reader.readBoolOrNull(offsets[32]) ?? false,
    isMedicationNotificationsEnabled:
        reader.readBoolOrNull(offsets[33]) ?? true,
    isPrayerCardEnabled: reader.readBoolOrNull(offsets[34]) ?? false,
    isPrayerEnabled: reader.readBoolOrNull(offsets[35]) ?? false,
    isPrayerNotificationsEnabled: reader.readBoolOrNull(offsets[36]) ?? false,
    isProjectRemindersEnabled: reader.readBoolOrNull(offsets[37]) ?? true,
    isTaskRemindersEnabled: reader.readBoolOrNull(offsets[38]) ?? true,
    isTasksKanbanView: reader.readBoolOrNull(offsets[39]) ?? false,
    latitude: reader.readDoubleOrNull(offsets[42]),
    longitude: reader.readDoubleOrNull(offsets[43]),
    morningAthkarTime: reader.readStringOrNull(offsets[44]) ?? '06:00',
    prayerCardDisplayMode: _UserSettingsprayerCardDisplayModeValueEnumMap[
            reader.readStringOrNull(offsets[45])] ??
        PrayerCardDisplayMode.dashboardOnly,
    prayerTimeAdjustmentMinutes: reader.readLongOrNull(offsets[46]) ?? 0,
    projectDailyReminders: reader.readBoolOrNull(offsets[47]) ?? false,
    projectReminderDaysBefore: reader.readLongOrNull(offsets[48]) ?? 7,
    projectReminderHoursBefore: reader.readLongOrNull(offsets[49]) ?? 24,
    projectWeeklySummary: reader.readBoolOrNull(offsets[50]) ?? false,
    quietPeriods: reader.readObjectList<TimeRange>(
      offsets[52],
      TimeRangeSchema.deserialize,
      allOffsets,
      TimeRange(),
    ),
    reduceMotion: reader.readBoolOrNull(offsets[53]) ?? false,
    respectQuietPeriodsForTasks: reader.readBoolOrNull(offsets[54]) ?? true,
    sampleDataDismissed: reader.readBoolOrNull(offsets[55]) ?? false,
    sampleDataShown: reader.readBoolOrNull(offsets[56]) ?? false,
    showPrayerDotsOnCalendar: reader.readBoolOrNull(offsets[57]) ?? true,
    sleepAthkarTime: reader.readStringOrNull(offsets[58]) ?? '22:00',
    sleepPeriods: reader.readObjectList<TimeRange>(
      offsets[60],
      TimeRangeSchema.deserialize,
      allOffsets,
      TimeRange(),
    ),
    taskReminderMinutesBefore: reader.readLongOrNull(offsets[61]) ?? 30,
    themePreference: _UserSettingsthemePreferenceValueEnumMap[
            reader.readStringOrNull(offsets[62])] ??
        ThemePreference.system,
    workDays: reader.readLongList(offsets[64]),
    workPeriods: reader.readObjectList<TimeRange>(
      offsets[65],
      TimeRangeSchema.deserialize,
      allOffsets,
      TimeRange(),
    ),
  );
  object.familyCategoryId = reader.readLongOrNull(offsets[17]);
  object.freeCategoryId = reader.readLongOrNull(offsets[20]);
  object.id = id;
  object.lastSyncAt = reader.readDateTimeOrNull(offsets[40]);
  object.lastSyncError = reader.readStringOrNull(offsets[41]);
  object.quietCategoryId = reader.readLongOrNull(offsets[51]);
  object.sleepCategoryId = reader.readLongOrNull(offsets[59]);
  object.workCategoryId = reader.readLongOrNull(offsets[63]);
  return object;
}

P _userSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 7) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 6:
      return (_UserSettingsathkarDisplayModeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AthkarDisplayMode.independent) as P;
    case 7:
      return (_UserSettingsathkarSessionViewModeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AthkarSessionViewMode.list) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset) ?? 60) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 12:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 13:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 14:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 15:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 16:
      return (reader.readStringOrNull(offset) ?? '17:00') as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readObjectList<TimeRange>(
        offset,
        TimeRangeSchema.deserialize,
        allOffsets,
        TimeRange(),
      )) as P;
    case 19:
      return (_UserSettingsfocusIntensityValueEnumMap[
              reader.readStringOrNull(offset)] ??
          FocusIntensity.standard) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (reader.readObjectList<TimeRange>(
        offset,
        TimeRangeSchema.deserialize,
        allOffsets,
        TimeRange(),
      )) as P;
    case 22:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 23:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 24:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 25:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 26:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 27:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 28:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 29:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 30:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 31:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 32:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 33:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 34:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 35:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 36:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 37:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 38:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 39:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 40:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 41:
      return (reader.readStringOrNull(offset)) as P;
    case 42:
      return (reader.readDoubleOrNull(offset)) as P;
    case 43:
      return (reader.readDoubleOrNull(offset)) as P;
    case 44:
      return (reader.readStringOrNull(offset) ?? '06:00') as P;
    case 45:
      return (_UserSettingsprayerCardDisplayModeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          PrayerCardDisplayMode.dashboardOnly) as P;
    case 46:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 47:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 48:
      return (reader.readLongOrNull(offset) ?? 7) as P;
    case 49:
      return (reader.readLongOrNull(offset) ?? 24) as P;
    case 50:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 51:
      return (reader.readLongOrNull(offset)) as P;
    case 52:
      return (reader.readObjectList<TimeRange>(
        offset,
        TimeRangeSchema.deserialize,
        allOffsets,
        TimeRange(),
      )) as P;
    case 53:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 54:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 55:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 56:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 57:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 58:
      return (reader.readStringOrNull(offset) ?? '22:00') as P;
    case 59:
      return (reader.readLongOrNull(offset)) as P;
    case 60:
      return (reader.readObjectList<TimeRange>(
        offset,
        TimeRangeSchema.deserialize,
        allOffsets,
        TimeRange(),
      )) as P;
    case 61:
      return (reader.readLongOrNull(offset) ?? 30) as P;
    case 62:
      return (_UserSettingsthemePreferenceValueEnumMap[
              reader.readStringOrNull(offset)] ??
          ThemePreference.system) as P;
    case 63:
      return (reader.readLongOrNull(offset)) as P;
    case 64:
      return (reader.readLongList(offset)) as P;
    case 65:
      return (reader.readObjectList<TimeRange>(
        offset,
        TimeRangeSchema.deserialize,
        allOffsets,
        TimeRange(),
      )) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _UserSettingsathkarDisplayModeEnumValueMap = {
  r'independent': r'independent',
  r'embedded': r'embedded',
};
const _UserSettingsathkarDisplayModeValueEnumMap = {
  r'independent': AthkarDisplayMode.independent,
  r'embedded': AthkarDisplayMode.embedded,
};
const _UserSettingsathkarSessionViewModeEnumValueMap = {
  r'list': r'list',
  r'focus': r'focus',
};
const _UserSettingsathkarSessionViewModeValueEnumMap = {
  r'list': AthkarSessionViewMode.list,
  r'focus': AthkarSessionViewMode.focus,
};
const _UserSettingsfocusIntensityEnumValueMap = {
  r'calm': r'calm',
  r'standard': r'standard',
  r'intense': r'intense',
};
const _UserSettingsfocusIntensityValueEnumMap = {
  r'calm': FocusIntensity.calm,
  r'standard': FocusIntensity.standard,
  r'intense': FocusIntensity.intense,
};
const _UserSettingsprayerCardDisplayModeEnumValueMap = {
  r'dashboardOnly': r'dashboardOnly',
  r'dashboardAndTasks': r'dashboardAndTasks',
  r'allPages': r'allPages',
};
const _UserSettingsprayerCardDisplayModeValueEnumMap = {
  r'dashboardOnly': PrayerCardDisplayMode.dashboardOnly,
  r'dashboardAndTasks': PrayerCardDisplayMode.dashboardAndTasks,
  r'allPages': PrayerCardDisplayMode.allPages,
};
const _UserSettingsthemePreferenceEnumValueMap = {
  r'system': r'system',
  r'light': r'light',
  r'dark': r'dark',
};
const _UserSettingsthemePreferenceValueEnumMap = {
  r'system': ThemePreference.system,
  r'light': ThemePreference.light,
  r'dark': ThemePreference.dark,
};

Id _userSettingsGetId(UserSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userSettingsGetLinks(UserSettings object) {
  return [];
}

void _userSettingsAttach(
    IsarCollection<dynamic> col, Id id, UserSettings object) {
  object.id = id;
}

extension UserSettingsQueryWhereSort
    on QueryBuilder<UserSettings, UserSettings, QWhere> {
  QueryBuilder<UserSettings, UserSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserSettingsQueryWhere
    on QueryBuilder<UserSettings, UserSettings, QWhereClause> {
  QueryBuilder<UserSettings, UserSettings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<UserSettings, UserSettings, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterWhereClause> idBetween(
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

extension UserSettingsQueryFilter
    on QueryBuilder<UserSettings, UserSettings, QFilterCondition> {
  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      appointmentMultipleRemindersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appointmentMultipleReminders',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      assetInsuranceRemindersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetInsuranceReminders',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      assetLicenseRemindersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetLicenseReminders',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      assetMaintenanceRemindersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetMaintenanceReminders',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      assetReminderDaysBeforeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetReminderDaysBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      assetReminderDaysBeforeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assetReminderDaysBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      assetReminderDaysBeforeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assetReminderDaysBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      assetReminderDaysBeforeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assetReminderDaysBefore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      assetWarrantyRemindersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetWarrantyReminders',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarDisplayModeEqualTo(
    AthkarDisplayMode value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'athkarDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarDisplayModeGreaterThan(
    AthkarDisplayMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'athkarDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarDisplayModeLessThan(
    AthkarDisplayMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'athkarDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarDisplayModeBetween(
    AthkarDisplayMode lower,
    AthkarDisplayMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'athkarDisplayMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarDisplayModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'athkarDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarDisplayModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'athkarDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarDisplayModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'athkarDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarDisplayModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'athkarDisplayMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarDisplayModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'athkarDisplayMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarDisplayModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'athkarDisplayMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarSessionViewModeEqualTo(
    AthkarSessionViewMode value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'athkarSessionViewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarSessionViewModeGreaterThan(
    AthkarSessionViewMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'athkarSessionViewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarSessionViewModeLessThan(
    AthkarSessionViewMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'athkarSessionViewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarSessionViewModeBetween(
    AthkarSessionViewMode lower,
    AthkarSessionViewMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'athkarSessionViewMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarSessionViewModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'athkarSessionViewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarSessionViewModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'athkarSessionViewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarSessionViewModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'athkarSessionViewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarSessionViewModeMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'athkarSessionViewMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarSessionViewModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'athkarSessionViewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      athkarSessionViewModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'athkarSessionViewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cityName',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cityName',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cityName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cityName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cityName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      cityNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cityName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      defaultAppointmentReminderMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultAppointmentReminderMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      defaultAppointmentReminderMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultAppointmentReminderMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      defaultAppointmentReminderMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultAppointmentReminderMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      defaultAppointmentReminderMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultAppointmentReminderMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      defaultHabitReminderTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'defaultHabitReminderTime',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      defaultHabitReminderTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'defaultHabitReminderTime',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      defaultHabitReminderTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultHabitReminderTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      defaultHabitReminderTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultHabitReminderTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      defaultHabitReminderTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultHabitReminderTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      defaultHabitReminderTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultHabitReminderTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      didMigratePrayerFeatureSettingsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'didMigratePrayerFeatureSettings',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      didMigrateThemePreferenceEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'didMigrateThemePreference',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      disableGyroscopeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disableGyroscope',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      easternNumeralsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'easternNumerals',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      enablePrayerRemindersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enablePrayerReminders',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      eveningAthkarTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eveningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      eveningAthkarTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eveningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      eveningAthkarTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eveningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      eveningAthkarTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eveningAthkarTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      eveningAthkarTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eveningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      eveningAthkarTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eveningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      eveningAthkarTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eveningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      eveningAthkarTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eveningAthkarTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      eveningAthkarTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eveningAthkarTime',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      eveningAthkarTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eveningAthkarTime',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'familyCategoryId',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'familyCategoryId',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyCategoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'familyCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyCategoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'familyCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyCategoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'familyCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyCategoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'familyCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyPeriodsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'familyPeriods',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyPeriodsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'familyPeriods',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyPeriodsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyPeriods',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyPeriodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyPeriods',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyPeriodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyPeriods',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyPeriodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyPeriods',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyPeriodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyPeriods',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyPeriodsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'familyPeriods',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      focusIntensityEqualTo(
    FocusIntensity value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focusIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      focusIntensityGreaterThan(
    FocusIntensity value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'focusIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      focusIntensityLessThan(
    FocusIntensity value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'focusIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      focusIntensityBetween(
    FocusIntensity lower,
    FocusIntensity upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'focusIntensity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      focusIntensityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'focusIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      focusIntensityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'focusIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      focusIntensityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'focusIntensity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      focusIntensityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'focusIntensity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      focusIntensityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focusIntensity',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      focusIntensityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'focusIntensity',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freeCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'freeCategoryId',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freeCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'freeCategoryId',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freeCategoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'freeCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freeCategoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'freeCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freeCategoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'freeCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freeCategoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'freeCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freePeriodsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'freePeriods',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freePeriodsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'freePeriods',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freePeriodsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'freePeriods',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freePeriodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'freePeriods',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freePeriodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'freePeriods',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freePeriodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'freePeriods',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freePeriodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'freePeriods',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freePeriodsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'freePeriods',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      hideNavOnScrollEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hideNavOnScroll',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isAppointmentRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAppointmentRemindersEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isAssetRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAssetRemindersEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isAthkarEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAthkarEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isAthkarRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAthkarRemindersEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isAutoModeEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAutoModeEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isAutoSyncEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAutoSyncEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isBiometricEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBiometricEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isDarkModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDarkMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isHabitRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isHabitRemindersEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isHijriModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isHijriMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isMedicationNotificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMedicationNotificationsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isPrayerCardEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPrayerCardEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isPrayerEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPrayerEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isPrayerNotificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPrayerNotificationsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isProjectRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isProjectRemindersEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isTaskRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTaskRemindersEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      isTasksKanbanViewEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTasksKanbanView',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncError',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncError',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastSyncError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncError',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      lastSyncErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastSyncError',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      latitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      latitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      latitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      latitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      latitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      latitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      longitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      longitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      longitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      longitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      longitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      longitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      morningAthkarTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'morningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      morningAthkarTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'morningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      morningAthkarTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'morningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      morningAthkarTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'morningAthkarTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      morningAthkarTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'morningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      morningAthkarTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'morningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      morningAthkarTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'morningAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      morningAthkarTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'morningAthkarTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      morningAthkarTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'morningAthkarTime',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      morningAthkarTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'morningAthkarTime',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerCardDisplayModeEqualTo(
    PrayerCardDisplayMode value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prayerCardDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerCardDisplayModeGreaterThan(
    PrayerCardDisplayMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prayerCardDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerCardDisplayModeLessThan(
    PrayerCardDisplayMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prayerCardDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerCardDisplayModeBetween(
    PrayerCardDisplayMode lower,
    PrayerCardDisplayMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prayerCardDisplayMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerCardDisplayModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'prayerCardDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerCardDisplayModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'prayerCardDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerCardDisplayModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'prayerCardDisplayMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerCardDisplayModeMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'prayerCardDisplayMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerCardDisplayModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prayerCardDisplayMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerCardDisplayModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'prayerCardDisplayMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerTimeAdjustmentMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prayerTimeAdjustmentMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerTimeAdjustmentMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prayerTimeAdjustmentMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerTimeAdjustmentMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prayerTimeAdjustmentMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      prayerTimeAdjustmentMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prayerTimeAdjustmentMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      projectDailyRemindersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectDailyReminders',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      projectReminderDaysBeforeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectReminderDaysBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      projectReminderDaysBeforeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectReminderDaysBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      projectReminderDaysBeforeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectReminderDaysBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      projectReminderDaysBeforeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectReminderDaysBefore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      projectReminderHoursBeforeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectReminderHoursBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      projectReminderHoursBeforeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectReminderHoursBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      projectReminderHoursBeforeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectReminderHoursBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      projectReminderHoursBeforeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectReminderHoursBefore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      projectWeeklySummaryEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectWeeklySummary',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quietCategoryId',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quietCategoryId',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietCategoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quietCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietCategoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quietCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietCategoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quietCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietCategoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quietCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietPeriodsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quietPeriods',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietPeriodsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quietPeriods',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietPeriodsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quietPeriods',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietPeriodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quietPeriods',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietPeriodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quietPeriods',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietPeriodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quietPeriods',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietPeriodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quietPeriods',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietPeriodsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'quietPeriods',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      reduceMotionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reduceMotion',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      respectQuietPeriodsForTasksEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'respectQuietPeriodsForTasks',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sampleDataDismissedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleDataDismissed',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sampleDataShownEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleDataShown',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      showPrayerDotsOnCalendarEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showPrayerDotsOnCalendar',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepAthkarTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepAthkarTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepAthkarTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepAthkarTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepAthkarTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepAthkarTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sleepAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepAthkarTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sleepAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepAthkarTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sleepAthkarTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepAthkarTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sleepAthkarTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepAthkarTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepAthkarTime',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepAthkarTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sleepAthkarTime',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sleepCategoryId',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sleepCategoryId',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepCategoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepCategoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepCategoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepCategoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepPeriodsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sleepPeriods',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepPeriodsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sleepPeriods',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepPeriodsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sleepPeriods',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepPeriodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sleepPeriods',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepPeriodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sleepPeriods',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepPeriodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sleepPeriods',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepPeriodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sleepPeriods',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepPeriodsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sleepPeriods',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      taskReminderMinutesBeforeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskReminderMinutesBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      taskReminderMinutesBeforeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskReminderMinutesBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      taskReminderMinutesBeforeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskReminderMinutesBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      taskReminderMinutesBeforeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskReminderMinutesBefore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      themePreferenceEqualTo(
    ThemePreference value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      themePreferenceGreaterThan(
    ThemePreference value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      themePreferenceLessThan(
    ThemePreference value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      themePreferenceBetween(
    ThemePreference lower,
    ThemePreference upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themePreference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      themePreferenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      themePreferenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      themePreferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'themePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      themePreferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'themePreference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      themePreferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themePreference',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      themePreferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'themePreference',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'workCategoryId',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'workCategoryId',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workCategoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workCategoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workCategoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workCategoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'workDays',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'workDays',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workDays',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'workDays',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'workDays',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'workDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workPeriodsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'workPeriods',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workPeriodsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'workPeriods',
      ));
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workPeriodsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workPeriods',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workPeriodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workPeriods',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workPeriodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workPeriods',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workPeriodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workPeriods',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workPeriodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workPeriods',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workPeriodsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'workPeriods',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension UserSettingsQueryObject
    on QueryBuilder<UserSettings, UserSettings, QFilterCondition> {
  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      familyPeriodsElement(FilterQuery<TimeRange> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'familyPeriods');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      freePeriodsElement(FilterQuery<TimeRange> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'freePeriods');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      quietPeriodsElement(FilterQuery<TimeRange> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'quietPeriods');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      sleepPeriodsElement(FilterQuery<TimeRange> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'sleepPeriods');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterFilterCondition>
      workPeriodsElement(FilterQuery<TimeRange> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'workPeriods');
    });
  }
}

extension UserSettingsQueryLinks
    on QueryBuilder<UserSettings, UserSettings, QFilterCondition> {}

extension UserSettingsQuerySortBy
    on QueryBuilder<UserSettings, UserSettings, QSortBy> {
  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAppointmentMultipleReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appointmentMultipleReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAppointmentMultipleRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appointmentMultipleReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAssetInsuranceReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetInsuranceReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAssetInsuranceRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetInsuranceReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAssetLicenseReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetLicenseReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAssetLicenseRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetLicenseReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAssetMaintenanceReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetMaintenanceReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAssetMaintenanceRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetMaintenanceReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAssetReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetReminderDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAssetReminderDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetReminderDaysBefore', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAssetWarrantyReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetWarrantyReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAssetWarrantyRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetWarrantyReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAthkarDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athkarDisplayMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAthkarDisplayModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athkarDisplayMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAthkarSessionViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athkarSessionViewMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByAthkarSessionViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athkarSessionViewMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByCityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByCityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByDefaultAppointmentReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultAppointmentReminderMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByDefaultAppointmentReminderMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultAppointmentReminderMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByDefaultHabitReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultHabitReminderTime', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByDefaultHabitReminderTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultHabitReminderTime', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByDidMigratePrayerFeatureSettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didMigratePrayerFeatureSettings', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByDidMigratePrayerFeatureSettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didMigratePrayerFeatureSettings', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByDidMigrateThemePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didMigrateThemePreference', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByDidMigrateThemePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didMigrateThemePreference', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByDisableGyroscope() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableGyroscope', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByDisableGyroscopeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableGyroscope', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByEasternNumerals() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easternNumerals', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByEasternNumeralsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easternNumerals', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByEnablePrayerReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePrayerReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByEnablePrayerRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePrayerReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByEveningAthkarTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eveningAthkarTime', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByEveningAthkarTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eveningAthkarTime', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByFamilyCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyCategoryId', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByFamilyCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyCategoryId', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByFocusIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusIntensity', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByFocusIntensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusIntensity', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByFreeCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'freeCategoryId', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByFreeCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'freeCategoryId', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByHideNavOnScroll() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideNavOnScroll', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByHideNavOnScrollDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideNavOnScroll', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAppointmentRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAppointmentRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAppointmentRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAppointmentRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAssetRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAssetRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAssetRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAssetRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAthkarEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAthkarEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAthkarEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAthkarEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAthkarRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAthkarRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAthkarRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAthkarRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAutoModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoModeEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAutoModeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoModeEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAutoSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoSyncEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsAutoSyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoSyncEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsBiometricEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsHabitRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHabitRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsHabitRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHabitRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByIsHijriMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHijriMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsHijriModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHijriMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsMedicationNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMedicationNotificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsMedicationNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMedicationNotificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsPrayerCardEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerCardEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsPrayerCardEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerCardEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsPrayerEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsPrayerEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsPrayerNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerNotificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsPrayerNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerNotificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsProjectRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProjectRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsProjectRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProjectRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsTaskRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTaskRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsTaskRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTaskRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsTasksKanbanView() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTasksKanbanView', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByIsTasksKanbanViewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTasksKanbanView', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByLastSyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByMorningAthkarTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'morningAthkarTime', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByMorningAthkarTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'morningAthkarTime', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByPrayerCardDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerCardDisplayMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByPrayerCardDisplayModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerCardDisplayMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByPrayerTimeAdjustmentMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerTimeAdjustmentMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByPrayerTimeAdjustmentMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerTimeAdjustmentMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByProjectDailyReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectDailyReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByProjectDailyRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectDailyReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByProjectReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectReminderDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByProjectReminderDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectReminderDaysBefore', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByProjectReminderHoursBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectReminderHoursBefore', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByProjectReminderHoursBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectReminderHoursBefore', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByProjectWeeklySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectWeeklySummary', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByProjectWeeklySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectWeeklySummary', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByQuietCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietCategoryId', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByQuietCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietCategoryId', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> sortByReduceMotion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reduceMotion', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByReduceMotionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reduceMotion', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByRespectQuietPeriodsForTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respectQuietPeriodsForTasks', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByRespectQuietPeriodsForTasksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respectQuietPeriodsForTasks', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortBySampleDataDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleDataDismissed', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortBySampleDataDismissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleDataDismissed', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortBySampleDataShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleDataShown', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortBySampleDataShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleDataShown', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByShowPrayerDotsOnCalendar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPrayerDotsOnCalendar', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByShowPrayerDotsOnCalendarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPrayerDotsOnCalendar', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortBySleepAthkarTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepAthkarTime', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortBySleepAthkarTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepAthkarTime', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortBySleepCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepCategoryId', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortBySleepCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepCategoryId', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByTaskReminderMinutesBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderMinutesBefore', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByTaskReminderMinutesBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderMinutesBefore', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByThemePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePreference', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByThemePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePreference', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByWorkCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workCategoryId', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      sortByWorkCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workCategoryId', Sort.desc);
    });
  }
}

extension UserSettingsQuerySortThenBy
    on QueryBuilder<UserSettings, UserSettings, QSortThenBy> {
  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAppointmentMultipleReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appointmentMultipleReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAppointmentMultipleRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appointmentMultipleReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAssetInsuranceReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetInsuranceReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAssetInsuranceRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetInsuranceReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAssetLicenseReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetLicenseReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAssetLicenseRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetLicenseReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAssetMaintenanceReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetMaintenanceReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAssetMaintenanceRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetMaintenanceReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAssetReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetReminderDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAssetReminderDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetReminderDaysBefore', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAssetWarrantyReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetWarrantyReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAssetWarrantyRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetWarrantyReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAthkarDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athkarDisplayMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAthkarDisplayModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athkarDisplayMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAthkarSessionViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athkarSessionViewMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByAthkarSessionViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'athkarSessionViewMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByCityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByCityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cityName', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByDefaultAppointmentReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultAppointmentReminderMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByDefaultAppointmentReminderMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultAppointmentReminderMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByDefaultHabitReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultHabitReminderTime', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByDefaultHabitReminderTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultHabitReminderTime', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByDidMigratePrayerFeatureSettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didMigratePrayerFeatureSettings', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByDidMigratePrayerFeatureSettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didMigratePrayerFeatureSettings', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByDidMigrateThemePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didMigrateThemePreference', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByDidMigrateThemePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didMigrateThemePreference', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByDisableGyroscope() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableGyroscope', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByDisableGyroscopeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableGyroscope', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByEasternNumerals() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easternNumerals', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByEasternNumeralsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easternNumerals', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByEnablePrayerReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePrayerReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByEnablePrayerRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePrayerReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByEveningAthkarTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eveningAthkarTime', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByEveningAthkarTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eveningAthkarTime', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByFamilyCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyCategoryId', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByFamilyCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'familyCategoryId', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByFocusIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusIntensity', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByFocusIntensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusIntensity', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByFreeCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'freeCategoryId', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByFreeCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'freeCategoryId', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByHideNavOnScroll() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideNavOnScroll', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByHideNavOnScrollDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hideNavOnScroll', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAppointmentRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAppointmentRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAppointmentRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAppointmentRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAssetRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAssetRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAssetRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAssetRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAthkarEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAthkarEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAthkarEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAthkarEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAthkarRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAthkarRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAthkarRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAthkarRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAutoModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoModeEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAutoModeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoModeEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAutoSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoSyncEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsAutoSyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoSyncEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsBiometricEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsHabitRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHabitRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsHabitRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHabitRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByIsHijriMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHijriMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsHijriModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHijriMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsMedicationNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMedicationNotificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsMedicationNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMedicationNotificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsPrayerCardEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerCardEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsPrayerCardEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerCardEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsPrayerEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsPrayerEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsPrayerNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerNotificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsPrayerNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrayerNotificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsProjectRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProjectRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsProjectRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isProjectRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsTaskRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTaskRemindersEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsTaskRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTaskRemindersEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsTasksKanbanView() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTasksKanbanView', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByIsTasksKanbanViewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTasksKanbanView', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByLastSyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByMorningAthkarTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'morningAthkarTime', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByMorningAthkarTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'morningAthkarTime', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByPrayerCardDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerCardDisplayMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByPrayerCardDisplayModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerCardDisplayMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByPrayerTimeAdjustmentMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerTimeAdjustmentMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByPrayerTimeAdjustmentMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prayerTimeAdjustmentMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByProjectDailyReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectDailyReminders', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByProjectDailyRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectDailyReminders', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByProjectReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectReminderDaysBefore', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByProjectReminderDaysBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectReminderDaysBefore', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByProjectReminderHoursBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectReminderHoursBefore', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByProjectReminderHoursBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectReminderHoursBefore', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByProjectWeeklySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectWeeklySummary', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByProjectWeeklySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectWeeklySummary', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByQuietCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietCategoryId', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByQuietCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quietCategoryId', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy> thenByReduceMotion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reduceMotion', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByReduceMotionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reduceMotion', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByRespectQuietPeriodsForTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respectQuietPeriodsForTasks', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByRespectQuietPeriodsForTasksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respectQuietPeriodsForTasks', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenBySampleDataDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleDataDismissed', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenBySampleDataDismissedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleDataDismissed', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenBySampleDataShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleDataShown', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenBySampleDataShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleDataShown', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByShowPrayerDotsOnCalendar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPrayerDotsOnCalendar', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByShowPrayerDotsOnCalendarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPrayerDotsOnCalendar', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenBySleepAthkarTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepAthkarTime', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenBySleepAthkarTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepAthkarTime', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenBySleepCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepCategoryId', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenBySleepCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepCategoryId', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByTaskReminderMinutesBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderMinutesBefore', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByTaskReminderMinutesBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskReminderMinutesBefore', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByThemePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePreference', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByThemePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themePreference', Sort.desc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByWorkCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workCategoryId', Sort.asc);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QAfterSortBy>
      thenByWorkCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workCategoryId', Sort.desc);
    });
  }
}

extension UserSettingsQueryWhereDistinct
    on QueryBuilder<UserSettings, UserSettings, QDistinct> {
  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByAppointmentMultipleReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appointmentMultipleReminders');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByAssetInsuranceReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetInsuranceReminders');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByAssetLicenseReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetLicenseReminders');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByAssetMaintenanceReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetMaintenanceReminders');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByAssetReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetReminderDaysBefore');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByAssetWarrantyReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetWarrantyReminders');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByAthkarDisplayMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'athkarDisplayMode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByAthkarSessionViewMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'athkarSessionViewMode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByCityName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cityName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByDefaultAppointmentReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultAppointmentReminderMinutes');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByDefaultHabitReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultHabitReminderTime');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByDidMigratePrayerFeatureSettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'didMigratePrayerFeatureSettings');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByDidMigrateThemePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'didMigrateThemePreference');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByDisableGyroscope() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disableGyroscope');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByEasternNumerals() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'easternNumerals');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByEnablePrayerReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enablePrayerReminders');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByEveningAthkarTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eveningAthkarTime',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByFamilyCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'familyCategoryId');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByFocusIntensity(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'focusIntensity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByFreeCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'freeCategoryId');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByHideNavOnScroll() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hideNavOnScroll');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsAppointmentRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAppointmentRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsAssetRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAssetRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsAthkarEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAthkarEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsAthkarRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAthkarRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsAutoModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAutoModeEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsAutoSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAutoSyncEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBiometricEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDarkMode');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsHabitRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHabitRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByIsHijriMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHijriMode');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsMedicationNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMedicationNotificationsEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsPrayerCardEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPrayerCardEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsPrayerEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPrayerEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsPrayerNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPrayerNotificationsEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsProjectRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isProjectRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsTaskRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTaskRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByIsTasksKanbanView() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTasksKanbanView');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByLastSyncError(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncError',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByMorningAthkarTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'morningAthkarTime',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByPrayerCardDisplayMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prayerCardDisplayMode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByPrayerTimeAdjustmentMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prayerTimeAdjustmentMinutes');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByProjectDailyReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectDailyReminders');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByProjectReminderDaysBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectReminderDaysBefore');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByProjectReminderHoursBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectReminderHoursBefore');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByProjectWeeklySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectWeeklySummary');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByQuietCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quietCategoryId');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByReduceMotion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reduceMotion');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByRespectQuietPeriodsForTasks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'respectQuietPeriodsForTasks');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctBySampleDataDismissed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sampleDataDismissed');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctBySampleDataShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sampleDataShown');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByShowPrayerDotsOnCalendar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showPrayerDotsOnCalendar');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctBySleepAthkarTime(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepAthkarTime',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctBySleepCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepCategoryId');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByTaskReminderMinutesBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskReminderMinutesBefore');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByThemePreference(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themePreference',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct>
      distinctByWorkCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workCategoryId');
    });
  }

  QueryBuilder<UserSettings, UserSettings, QDistinct> distinctByWorkDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workDays');
    });
  }
}

extension UserSettingsQueryProperty
    on QueryBuilder<UserSettings, UserSettings, QQueryProperty> {
  QueryBuilder<UserSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      appointmentMultipleRemindersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appointmentMultipleReminders');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      assetInsuranceRemindersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetInsuranceReminders');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      assetLicenseRemindersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetLicenseReminders');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      assetMaintenanceRemindersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetMaintenanceReminders');
    });
  }

  QueryBuilder<UserSettings, int, QQueryOperations>
      assetReminderDaysBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetReminderDaysBefore');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      assetWarrantyRemindersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetWarrantyReminders');
    });
  }

  QueryBuilder<UserSettings, AthkarDisplayMode, QQueryOperations>
      athkarDisplayModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'athkarDisplayMode');
    });
  }

  QueryBuilder<UserSettings, AthkarSessionViewMode, QQueryOperations>
      athkarSessionViewModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'athkarSessionViewMode');
    });
  }

  QueryBuilder<UserSettings, String?, QQueryOperations> cityNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cityName');
    });
  }

  QueryBuilder<UserSettings, int, QQueryOperations>
      defaultAppointmentReminderMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultAppointmentReminderMinutes');
    });
  }

  QueryBuilder<UserSettings, DateTime?, QQueryOperations>
      defaultHabitReminderTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultHabitReminderTime');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      didMigratePrayerFeatureSettingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'didMigratePrayerFeatureSettings');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      didMigrateThemePreferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'didMigrateThemePreference');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      disableGyroscopeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disableGyroscope');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations> easternNumeralsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'easternNumerals');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      enablePrayerRemindersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enablePrayerReminders');
    });
  }

  QueryBuilder<UserSettings, String, QQueryOperations>
      eveningAthkarTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eveningAthkarTime');
    });
  }

  QueryBuilder<UserSettings, int?, QQueryOperations>
      familyCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'familyCategoryId');
    });
  }

  QueryBuilder<UserSettings, List<TimeRange>?, QQueryOperations>
      familyPeriodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'familyPeriods');
    });
  }

  QueryBuilder<UserSettings, FocusIntensity, QQueryOperations>
      focusIntensityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'focusIntensity');
    });
  }

  QueryBuilder<UserSettings, int?, QQueryOperations> freeCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'freeCategoryId');
    });
  }

  QueryBuilder<UserSettings, List<TimeRange>?, QQueryOperations>
      freePeriodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'freePeriods');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations> hideNavOnScrollProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hideNavOnScroll');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isAppointmentRemindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAppointmentRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isAssetRemindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAssetRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations> isAthkarEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAthkarEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isAthkarRemindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAthkarRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isAutoModeEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAutoModeEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isAutoSyncEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAutoSyncEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isBiometricEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBiometricEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations> isDarkModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDarkMode');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isHabitRemindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHabitRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations> isHijriModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHijriMode');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isMedicationNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMedicationNotificationsEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isPrayerCardEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPrayerCardEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations> isPrayerEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPrayerEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isPrayerNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPrayerNotificationsEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isProjectRemindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isProjectRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isTaskRemindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTaskRemindersEnabled');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      isTasksKanbanViewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTasksKanbanView');
    });
  }

  QueryBuilder<UserSettings, DateTime?, QQueryOperations> lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }

  QueryBuilder<UserSettings, String?, QQueryOperations>
      lastSyncErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncError');
    });
  }

  QueryBuilder<UserSettings, double?, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<UserSettings, double?, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<UserSettings, String, QQueryOperations>
      morningAthkarTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'morningAthkarTime');
    });
  }

  QueryBuilder<UserSettings, PrayerCardDisplayMode, QQueryOperations>
      prayerCardDisplayModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prayerCardDisplayMode');
    });
  }

  QueryBuilder<UserSettings, int, QQueryOperations>
      prayerTimeAdjustmentMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prayerTimeAdjustmentMinutes');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      projectDailyRemindersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectDailyReminders');
    });
  }

  QueryBuilder<UserSettings, int, QQueryOperations>
      projectReminderDaysBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectReminderDaysBefore');
    });
  }

  QueryBuilder<UserSettings, int, QQueryOperations>
      projectReminderHoursBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectReminderHoursBefore');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      projectWeeklySummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectWeeklySummary');
    });
  }

  QueryBuilder<UserSettings, int?, QQueryOperations> quietCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quietCategoryId');
    });
  }

  QueryBuilder<UserSettings, List<TimeRange>?, QQueryOperations>
      quietPeriodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quietPeriods');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations> reduceMotionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reduceMotion');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      respectQuietPeriodsForTasksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'respectQuietPeriodsForTasks');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      sampleDataDismissedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sampleDataDismissed');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations> sampleDataShownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sampleDataShown');
    });
  }

  QueryBuilder<UserSettings, bool, QQueryOperations>
      showPrayerDotsOnCalendarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showPrayerDotsOnCalendar');
    });
  }

  QueryBuilder<UserSettings, String, QQueryOperations>
      sleepAthkarTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepAthkarTime');
    });
  }

  QueryBuilder<UserSettings, int?, QQueryOperations> sleepCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepCategoryId');
    });
  }

  QueryBuilder<UserSettings, List<TimeRange>?, QQueryOperations>
      sleepPeriodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepPeriods');
    });
  }

  QueryBuilder<UserSettings, int, QQueryOperations>
      taskReminderMinutesBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskReminderMinutesBefore');
    });
  }

  QueryBuilder<UserSettings, ThemePreference, QQueryOperations>
      themePreferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themePreference');
    });
  }

  QueryBuilder<UserSettings, int?, QQueryOperations> workCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workCategoryId');
    });
  }

  QueryBuilder<UserSettings, List<int>?, QQueryOperations> workDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workDays');
    });
  }

  QueryBuilder<UserSettings, List<TimeRange>?, QQueryOperations>
      workPeriodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workPeriods');
    });
  }
}
