// Golden tests for PR3 prayer card redesign.
// Run: flutter test --update-goldens test/golden/prayer_card_pr3_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:athar/core/design_system/molecules/cards/next_prayer_card.dart';
import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/biometric_service.dart';
import 'package:athar/core/services/prayer_timer_service.dart';
import 'package:athar/core/services/widget_data_service.dart';
import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/habits/domain/repositories/habit_repository.dart';
import 'package:athar/features/habits/presentation/cubit/habit_cubit.dart';
import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
import 'package:athar/features/prayer/domain/models/prayer_timer_status.dart';
import 'package:athar/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:athar/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:athar/features/prayer/presentation/cubit/prayer_state.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake timer service
// ─────────────────────────────────────────────────────────────────────────────

class _FakeTimerService extends PrayerTimerService {
  // sync: true — events delivered synchronously so StreamBuilder rebuilds
  // before the next tester.pump() captures the golden.
  final StreamController<PrayerTimerStatus> _ctrl =
      StreamController<PrayerTimerStatus>.broadcast(sync: true);

  @override
  Stream<PrayerTimerStatus> get timerStream => _ctrl.stream;

  @override
  void startTimer(List<PrayerTime> prayers) {}

  void push(PrayerTimerStatus status) => _ctrl.add(status);

  @override
  Future<void> dispose() async => _ctrl.close();
}

// ─────────────────────────────────────────────────────────────────────────────
// Stub repositories
// ─────────────────────────────────────────────────────────────────────────────

class _StubPrayerRepo implements PrayerRepository {
  @override
  Future<List<PrayerTime>> getPrayerTimesForDate(DateTime date) =>
      Future.value([]);

  @override
  Future<PrayerTime?> getNextPrayer() => Future.value(null);
}

class _StubSettingsRepo implements SettingsRepository {
  final UserSettings _s;
  _StubSettingsRepo(this._s);

  @override
  Future<UserSettings> getSettings() => Future.value(_s);

  @override
  Future<void> updateSettings(UserSettings settings) => Future.value();

  @override
  Stream<UserSettings> watchSettings() => Stream.value(_s);

  @override
  Future<void> toggleAutoMode(bool isEnabled) => Future.value();

  @override
  Future<void> ensureAthkarSeeding(String userId) => Future.value();
}

class _StubHabitRepo implements HabitRepository {
  @override
  Stream<List<HabitModel>> watchHabits() => const Stream.empty();

  @override
  Future<void> addHabit(HabitModel habit) => Future.value();

  @override
  Future<void> updateHabit(HabitModel habit) => Future.value();

  @override
  Future<void> deleteHabit(int id) => Future.value();

  @override
  Future<void> toggleHabit(int id) => Future.value();

  @override
  Future<void> ensureSystemHabits() => Future.value();

  @override
  Future<void> resetAthkarToDefault(int habitId) => Future.value();

  @override
  Future<bool> hasUserInteractedWithHabits() => Future.value(false);

  @override
  Future<void> clearAllHabits() => Future.value();

  @override
  Future<void> fixMissingUserIds(String userId) => Future.value();

  @override
  Future<void> migrateDataForGuest(String oldUserId) => Future.value();

  @override
  Future<List<HabitModel>> getHabitsWithReminders() => Future.value([]);

  @override
  Future<HabitModel?> getHabitByUuid(String uuid) => Future.value(null);
}

// ─────────────────────────────────────────────────────────────────────────────
// Stub cubits
// ─────────────────────────────────────────────────────────────────────────────

UserSettings _makeSettings({bool enabledCard = true, String? cityName = 'الرياض'}) =>
    UserSettings()
      ..isPrayerEnabled = true
      ..isPrayerCardEnabled = enabledCard
      ..cityName = cityName;

class _StubSettingsCubit extends SettingsCubit {
  _StubSettingsCubit({bool enabledCard = true, String? cityName = 'الرياض'})
      : super(
          _StubSettingsRepo(_makeSettings(enabledCard: enabledCard, cityName: cityName)),
          BiometricService(),
        ) {
    emit(SettingsLoaded(_makeSettings(enabledCard: enabledCard, cityName: cityName)));
  }
}

class _StubPrayerCubit extends PrayerCubit {
  _StubPrayerCubit._(PrayerState s)
      : super(
          prayerRepository: _StubPrayerRepo(),
          settingsRepository: _StubSettingsRepo(_makeSettings()),
          widgetDataService: WidgetDataService(),
        ) {
    emit(s);
  }

  factory _StubPrayerCubit.loaded() => _StubPrayerCubit._(PrayerLoaded(
        nextPrayer: _asrPrayer,
        allPrayers: _prayers,
        cityName: 'الرياض',
      ));

  factory _StubPrayerCubit.loading() =>
      _StubPrayerCubit._(PrayerLoading());

  factory _StubPrayerCubit.error(String msg) =>
      _StubPrayerCubit._(PrayerError(msg));
}

class _StubHabitCubit extends HabitCubit {
  _StubHabitCubit()
      : super(
          _StubHabitRepo(),
          _StubPrayerRepo(),
          _StubSettingsRepo(_makeSettings()),
          WidgetDataService(),
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// Prayer data fixtures
// ─────────────────────────────────────────────────────────────────────────────

final _asrPrayer = PrayerTime(
  type: PrayerType.asr,
  time: DateTime(2025, 1, 15, 15, 45),
  nameArabic: 'العصر',
  nameEnglish: 'Asr',
  isNext: true,
);

final _prayers = <PrayerTime>[
  PrayerTime(
    type: PrayerType.fajr,
    time: DateTime(2025, 1, 15, 5, 20),
    nameArabic: 'الفجر',
    nameEnglish: 'Fajr',
  ),
  PrayerTime(
    type: PrayerType.dhuhr,
    time: DateTime(2025, 1, 15, 12, 20),
    nameArabic: 'الظهر',
    nameEnglish: 'Dhuhr',
  ),
  _asrPrayer,
  PrayerTime(
    type: PrayerType.maghrib,
    time: DateTime(2025, 1, 15, 18, 18),
    nameArabic: 'المغرب',
    nameEnglish: 'Maghrib',
  ),
  PrayerTime(
    type: PrayerType.isha,
    time: DateTime(2025, 1, 15, 19, 45),
    nameArabic: 'العشاء',
    nameEnglish: 'Isha',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// PrayerTimerStatus fixtures
// ─────────────────────────────────────────────────────────────────────────────

PrayerTimerStatus _statusUpcoming({double progress = 0.25}) => PrayerTimerStatus(
      prayerNameAr: 'العصر',
      prayerNameEn: 'Asr',
      timeDisplay: '٣:٤٥ م',
      timeDisplayEn: '3:45 PM',
      timeLeft: '٢:١٥:٣٠',
      timeLeftEn: '2:15:30',
      progress: progress,
      label: PrayerTimerLabel.upcoming,
      statusColor: const Color(0xFFFFC107),
      showDhikrButton: false,
      fullDate: 'الأربعاء، 15 يناير',
      fullDateEn: 'Wed, 15 Jan',
      hijriDate: '١٥ رجب ١٤٤٦',
      gregorianDate: 'الأربعاء، 15 يناير',
      hijriDateEn: '15 Rajab 1446',
      gregorianDateEn: 'Wed, 15 Jan',
      secondsRemaining: 8130,
      sunriseTime: '٦:٢٥ ص',
      sunriseTimeEn: '6:25 AM',
      sunsetTime: '٦:١٨ م',
      sunsetTimeEn: '6:18 PM',
    );

PrayerTimerStatus _statusActive() => PrayerTimerStatus(
      prayerNameAr: 'العصر',
      prayerNameEn: 'Asr',
      timeDisplay: '٣:٤٥ م',
      timeDisplayEn: '3:45 PM',
      timeLeft: 'مضى ١٢ دقيقة',
      timeLeftEn: '12 min elapsed',
      progress: 0.15,
      label: PrayerTimerLabel.current,
      statusColor: const Color(0xFF4CAF50),
      showDhikrButton: true,
      fullDate: 'الأربعاء، 15 يناير',
      fullDateEn: 'Wed, 15 Jan',
      hijriDate: '١٥ رجب ١٤٤٦',
      gregorianDate: 'الأربعاء، 15 يناير',
      hijriDateEn: '15 Rajab 1446',
      gregorianDateEn: 'Wed, 15 Jan',
      secondsRemaining: 0,
      sunriseTime: '٦:٢٥ ص',
      sunriseTimeEn: '6:25 AM',
      sunsetTime: '٦:١٨ م',
      sunsetTimeEn: '6:18 PM',
    );

PrayerTimerStatus _statusDuha() => PrayerTimerStatus(
      prayerNameAr: 'الظهر',
      prayerNameEn: 'Dhuhr',
      timeDisplay: '١٢:٢٠ م',
      timeDisplayEn: '12:20 PM',
      timeLeft: '١:٣٠:٠٠',
      timeLeftEn: '1:30:00',
      progress: 0.3,
      label: PrayerTimerLabel.upcoming,
      statusColor: const Color(0xFFFFC107),
      showDhikrButton: false,
      fullDate: 'الأربعاء، 15 يناير',
      fullDateEn: 'Wed, 15 Jan',
      hijriDate: '١٥ رجب ١٤٤٦',
      gregorianDate: 'الأربعاء، 15 يناير',
      hijriDateEn: '15 Rajab 1446',
      gregorianDateEn: 'Wed, 15 Jan',
      secondsRemaining: 5400,
      isDuhaTime: true,
      sunriseTime: '٦:٢٥ ص',
      sunriseTimeEn: '6:25 AM',
      sunsetTime: '٦:١٨ م',
      sunsetTimeEn: '6:18 PM',
    );

// ─────────────────────────────────────────────────────────────────────────────
// Widget builders
// ─────────────────────────────────────────────────────────────────────────────

Widget _cardWidget({
  required bool rtl,
  bool expanded = false,
}) {
  final locale = rtl ? const Locale('ar') : const Locale('en');
  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>(create: (_) => _StubSettingsCubit()),
      BlocProvider<PrayerCubit>(create: (_) => _StubPrayerCubit.loaded()),
      BlocProvider<HabitCubit>(create: (_) => _StubHabitCubit()),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: Center(
            child: NextPrayerCard(allPrayers: _prayers, expanded: expanded),
          ),
        ),
      ),
    ),
  );
}

Widget _wrapperWidget({
  required bool rtl,
  required PrayerCubit prayerCubit,
  bool enabledCard = true,
  String? cityName = 'الرياض',
}) {
  final locale = rtl ? const Locale('ar') : const Locale('en');
  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>(
        create: (_) => _StubSettingsCubit(enabledCard: enabledCard, cityName: cityName),
      ),
      BlocProvider<PrayerCubit>(create: (_) => prayerCubit),
      BlocProvider<HabitCubit>(create: (_) => _StubHabitCubit()),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData.dark(),
        home: const Scaffold(
          backgroundColor: Color(0xFF121212),
          body: Center(
            child: SmartPrayerCardWrapper(pageType: PageType.dashboard),
          ),
        ),
      ),
    ),
  );
}


void _setSize(WidgetTester tester, {double w = 375, double h = 812}) {
  tester.view.physicalSize = Size(w, h);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

late _FakeTimerService _fakeTimer;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
    _fakeTimer = _FakeTimerService();
    getIt.registerSingleton<PrayerTimerService>(_fakeTimer);
  });

  tearDown(() async => _fakeTimer.dispose());

  // ── 1. Upcoming compact ────────────────────────────────────────────────────

  testWidgets('01_upcoming_ar', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_cardWidget(rtl: true));
    _fakeTimer.push(_statusUpcoming());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/01_upcoming_ar.png'),
    );
  });

  testWidgets('01_upcoming_en', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_cardWidget(rtl: false));
    _fakeTimer.push(_statusUpcoming());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/01_upcoming_en.png'),
    );
  });

  // ── 2. Active prayer ───────────────────────────────────────────────────────

  testWidgets('02_active_ar', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_cardWidget(rtl: true));
    _fakeTimer.push(_statusActive());
    await tester.pump();
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/02_active_ar.png'),
    );
  });

  testWidgets('02_active_en', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_cardWidget(rtl: false));
    _fakeTimer.push(_statusActive());
    await tester.pump();
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/02_active_en.png'),
    );
  });

  // ── 3. Nafl chip — Duha ────────────────────────────────────────────────────

  testWidgets('03_nafl_duha_ar', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_cardWidget(rtl: true));
    _fakeTimer.push(_statusDuha());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/03_nafl_duha_ar.png'),
    );
  });

  testWidgets('03_nafl_duha_en', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_cardWidget(rtl: false));
    _fakeTimer.push(_statusDuha());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/03_nafl_duha_en.png'),
    );
  });

  // ── 4. Expanded variant ────────────────────────────────────────────────────

  testWidgets('04_expanded_ar', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_cardWidget(rtl: true, expanded: true));
    _fakeTimer.push(_statusUpcoming());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/04_expanded_ar.png'),
    );
  });

  testWidgets('04_expanded_en', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_cardWidget(rtl: false, expanded: true));
    _fakeTimer.push(_statusUpcoming());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/04_expanded_en.png'),
    );
  });

  // ── 5. Loading skeleton ────────────────────────────────────────────────────

  testWidgets('05_loading_ar', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(
      _wrapperWidget(rtl: true, prayerCubit: _StubPrayerCubit.loading()),
    );
    await tester.pump();
    await expectLater(
      find.byType(SmartPrayerCardWrapper),
      matchesGoldenFile('pr3/05_loading_ar.png'),
    );
  });

  testWidgets('05_loading_en', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(
      _wrapperWidget(rtl: false, prayerCubit: _StubPrayerCubit.loading()),
    );
    await tester.pump();
    await expectLater(
      find.byType(SmartPrayerCardWrapper),
      matchesGoldenFile('pr3/05_loading_en.png'),
    );
  });

  // ── 6. Permission denied — no city configured ──────────────────────────────

  testWidgets('06_permission_denied_ar', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_wrapperWidget(
      rtl: true,
      prayerCubit: _StubPrayerCubit.error('location unavailable'),
      cityName: null,
    ));
    await tester.pump();
    await expectLater(
      find.byType(SmartPrayerCardWrapper),
      matchesGoldenFile('pr3/06_permission_denied_ar.png'),
    );
  });

  testWidgets('06_permission_denied_en', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_wrapperWidget(
      rtl: false,
      prayerCubit: _StubPrayerCubit.error('location unavailable'),
      cityName: null,
    ));
    await tester.pump();
    await expectLater(
      find.byType(SmartPrayerCardWrapper),
      matchesGoldenFile('pr3/06_permission_denied_en.png'),
    );
  });

  // ── 7. iPhone SE 375×667 ──────────────────────────────────────────────────

  testWidgets('07_se_ar', (tester) async {
    _setSize(tester, w: 375, h: 667);
    await tester.pumpWidget(_cardWidget(rtl: true));
    _fakeTimer.push(_statusUpcoming());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/07_se_ar.png'),
    );
  });

  testWidgets('07_se_en', (tester) async {
    _setSize(tester, w: 375, h: 667);
    await tester.pumpWidget(_cardWidget(rtl: false));
    _fakeTimer.push(_statusUpcoming());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/07_se_en.png'),
    );
  });

  // ── 8. Progress bar ~50% ───────────────────────────────────────────────────

  testWidgets('08_progress50_ar', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_cardWidget(rtl: true));
    _fakeTimer.push(_statusUpcoming(progress: 0.5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/08_progress50_ar.png'),
    );
  });

  testWidgets('08_progress50_en', (tester) async {
    _setSize(tester);
    await tester.pumpWidget(_cardWidget(rtl: false));
    _fakeTimer.push(_statusUpcoming(progress: 0.5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NextPrayerCard),
      matchesGoldenFile('pr3/08_progress50_en.png'),
    );
  });
}
