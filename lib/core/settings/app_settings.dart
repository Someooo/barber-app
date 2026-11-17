import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static const String themeModeKey = 'barbersync_theme_mode';
  static const String localeKey = 'barbersync_locale';

  final SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  AppSettingsController({SharedPreferences? prefs}) : _prefs = prefs {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final prefs = _prefs;
    if (prefs == null) return;

    final savedTheme = prefs.getString(themeModeKey);
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    final savedLocale = prefs.getString(localeKey);
    if (savedLocale == 'ar') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  String get languageCode => _locale.languageCode.toUpperCase();

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

  void toggleTheme([Brightness platformBrightness = Brightness.light]) {
    _themeMode =
        isDarkMode(platformBrightness) ? ThemeMode.light : ThemeMode.dark;
    _prefs?.setString(
      themeModeKey,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  void toggleLocale() {
    _locale =
        _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    _prefs?.setString(localeKey, _locale.languageCode);
    notifyListeners();
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>()
        ?.notifier;
  }

  static AppSettingsController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'AppSettingsScope not found in widget tree.');
    return controller!;
  }
}
