import 'package:flutter/material.dart';

class AppSettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

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
    notifyListeners();
  }

  void toggleLocale() {
    _locale =
        _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
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
