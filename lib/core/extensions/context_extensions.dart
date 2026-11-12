import 'package:flutter/material.dart';

import 'package:barber_app/core/settings/app_settings.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/l10n/app_localizations.dart';

extension AppBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colors => Theme.of(this).colorScheme;

  bool get isDarkMode {
    final settings = AppSettingsScope.maybeOf(this);
    if (settings != null) {
      return settings.isDarkMode(MediaQuery.platformBrightnessOf(this));
    }
    return Theme.of(this).brightness == Brightness.dark;
  }

  Color get cardSurface =>
      isDarkMode ? AppColors.cardDark : AppColors.cardLight;

  Color get borderColor =>
      isDarkMode ? AppColors.borderDark : AppColors.borderLight;

  Color get inputFill => isDarkMode ? AppColors.cardDark : AppColors.white;

  String get languageCode =>
      AppSettingsScope.maybeOf(this)?.languageCode ?? 'EN';

  void toggleLocale() {
    AppSettingsScope.maybeOf(this)?.toggleLocale();
  }

  void toggleTheme() {
    final platformBrightness = MediaQuery.platformBrightnessOf(this);
    AppSettingsScope.maybeOf(this)?.toggleTheme(platformBrightness);
  }
}

