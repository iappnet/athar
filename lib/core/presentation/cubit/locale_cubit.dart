import 'package:athar/core/services/widget_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleState {
  // null means "follow system"
  final Locale? locale;
  const LocaleState(this.locale);
}

class LocaleCubit extends Cubit<LocaleState> {
  final FlutterSecureStorage _storage;
  final WidgetDataService _widgetDataService;
  static const _key = 'preferred_locale';

  LocaleCubit(this._storage, this._widgetDataService)
      : super(const LocaleState(null));

  Future<void> loadLocale() async {
    try {
      final code = await _storage.read(key: _key);
      emit(LocaleState(_codeToLocale(code)));
    } catch (_) {
      emit(const LocaleState(null));
    }
  }

  Future<void> setLocale(Locale? locale) async {
    try {
      if (locale == null) {
        await _storage.delete(key: _key);
        await _widgetDataService.pushLocaleOnly('system');
      } else {
        await _storage.write(key: _key, value: locale.languageCode);
        await _widgetDataService.pushLocaleOnly(locale.languageCode);
      }
    } catch (_) {}
    emit(LocaleState(locale));
  }

  Locale? _codeToLocale(String? code) {
    switch (code) {
      case 'ar':
        return const Locale('ar', 'SA');
      case 'en':
        return const Locale('en', 'US');
      default:
        return null;
    }
  }
}
