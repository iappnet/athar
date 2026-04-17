import 'package:flutter/widgets.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

extension L10nExtension on BuildContext {
  /// ✅ يُرجع الترجمات أو null إذا لم تُحمَّل
  AppLocalizations? get l10nOrNull {
    return Localizations.of<AppLocalizations>(this, AppLocalizations);
  }

  /// ✅ يُرجع الترجمات (يفترض أنها محملة)
  AppLocalizations get l10n {
    final loc = Localizations.of<AppLocalizations>(this, AppLocalizations);
    assert(loc != null, 'AppLocalizations not found!');
    return loc!;
  }

  /// ✅ هل الترجمات جاهزة؟
  bool get isL10nReady {
    return Localizations.of<AppLocalizations>(this, AppLocalizations) != null;
  }
}
