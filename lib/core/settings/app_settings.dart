import 'package:flutter/material.dart';

/// Holds app-wide user preferences (theme mode and locale).
class AppSettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  /// Short uppercase language code for UI chips, e.g. `EN` / `AR`.
  String get languageCode => _locale.languageCode.toUpperCase();

  /// Resolves whether the app is effectively rendering in dark mode.
  bool isDarkMode(Brightness platformBrightness) {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return platformBrightness == Brightness.dark;
    }
  }

  void toggleTheme(Brightness platformBrightness) {
    _themeMode =
        isDarkMode(platformBrightness) ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleLocale() {
    _locale = _locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    notifyListeners();
  }
}

/// Exposes [AppSettingsController] to the widget tree.
class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found in widget tree.');
    return scope!.notifier!;
  }
}

