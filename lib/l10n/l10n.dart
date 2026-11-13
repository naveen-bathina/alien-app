import 'package:flutter/widgets.dart';
import 'package:myalien/l10n/gen/app_localizations.dart';

export 'package:myalien/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
