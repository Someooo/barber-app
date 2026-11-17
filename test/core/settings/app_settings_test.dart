import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barber_app/core/settings/app_settings.dart';

void main() {
  group('AppSettingsController Persistence', () {
    test(
        'defaults to ThemeMode.light and en locale when SharedPreferences is empty',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final controller = AppSettingsController(prefs: prefs);

      expect(controller.themeMode, ThemeMode.light);
      expect(controller.locale, const Locale('en'));
      expect(controller.languageCode, 'EN');
      expect(controller.isDarkMode(Brightness.light), isFalse);
    });

    test('loads saved theme and locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        AppSettingsController.themeModeKey: 'dark',
        AppSettingsController.localeKey: 'ar',
      });
      final prefs = await SharedPreferences.getInstance();

      final controller = AppSettingsController(prefs: prefs);

      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.locale, const Locale('ar'));
      expect(controller.languageCode, 'AR');
      expect(controller.isDarkMode(Brightness.light), isTrue);
    });

    test('persists toggled theme to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final controller = AppSettingsController(prefs: prefs);

      controller.toggleTheme(Brightness.light);
      expect(controller.themeMode, ThemeMode.dark);
      expect(prefs.getString(AppSettingsController.themeModeKey), 'dark');

      controller.toggleTheme(Brightness.light);
      expect(controller.themeMode, ThemeMode.light);
      expect(prefs.getString(AppSettingsController.themeModeKey), 'light');
    });

    test('persists toggled locale to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final controller = AppSettingsController(prefs: prefs);

      controller.toggleLocale();
      expect(controller.locale, const Locale('ar'));
      expect(prefs.getString(AppSettingsController.localeKey), 'ar');

      controller.toggleLocale();
      expect(controller.locale, const Locale('en'));
      expect(prefs.getString(AppSettingsController.localeKey), 'en');
    });

    test('operates gracefully in-memory when SharedPreferences is null', () {
      final controller = AppSettingsController();

      expect(controller.themeMode, ThemeMode.light);
      expect(controller.locale, const Locale('en'));

      controller.toggleTheme();
      expect(controller.themeMode, ThemeMode.dark);

      controller.toggleLocale();
      expect(controller.locale, const Locale('ar'));
    });
  });
}
