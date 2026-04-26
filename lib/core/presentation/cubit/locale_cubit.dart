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
  static const _key = 'preferred_locale';

  LocaleCubit(this._storage) : super(const LocaleState(null));

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
      } else {
        await _storage.write(key: _key, value: locale.languageCode);
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
