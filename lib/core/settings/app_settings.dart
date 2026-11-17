import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static const String themeModeKey = 'barbersync_theme_mode';
  static const String localeKey = 'barbersync_locale';
  static const String profileImageKeyPrefix = 'barbersync_profile_image_';

  static String profileImageKey(String userId) =>
      '$profileImageKeyPrefix$userId';

  final SharedPreferences? _prefs;
  final Future<Directory> Function()? _documentsDirectoryProvider;
  final ValueNotifier<String?> _profileImagePathNotifier =
      ValueNotifier<String?>(null);

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');
  String? _activeUserId;

  AppSettingsController({
    SharedPreferences? prefs,
    Future<Directory> Function()? documentsDirectoryProvider,
  })  : _prefs = prefs,
        _documentsDirectoryProvider = documentsDirectoryProvider {
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
  String? get activeUserId => _activeUserId;
  String? get profileImagePath => _profileImagePathNotifier.value;
  ValueListenable<String?> get profileImagePathListenable =>
      _profileImagePathNotifier;

  String get languageCode => _locale.languageCode.toUpperCase();

  void setActiveUser(String? userId) {
    final normalized = (userId == null || userId.isEmpty) ? null : userId;
    if (_activeUserId == normalized &&
        (normalized == null ||
            _profileImagePathNotifier.value ==
                _resolveStoredProfileImagePath(normalized))) {
      return;
    }
    _activeUserId = normalized;
    _profileImagePathNotifier.value =
        normalized == null ? null : _resolveStoredProfileImagePath(normalized);
  }

  String? loadProfileImagePath(String userId) {
    if (userId.isEmpty) return null;
    return _resolveStoredProfileImagePath(userId);
  }

  String? _resolveStoredProfileImagePath(String userId) {
    final savedPath = _prefs?.getString(profileImageKey(userId));
    if (savedPath == null || savedPath.isEmpty) {
      return null;
    }
    if (!File(savedPath).existsSync()) {
      _prefs?.remove(profileImageKey(userId));
      return null;
    }
    return savedPath;
  }

  Future<String?> saveProfileImage({
    required String sourcePath,
    String? userId,
  }) async {
    final targetUserId = (userId ?? _activeUserId)?.trim();
    if (targetUserId == null || targetUserId.isEmpty) {
      return null;
    }
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      return null;
    }

    final docsDir = await (_documentsDirectoryProvider ??
        getApplicationDocumentsDirectory)();
    final photosDir = Directory(p.join(docsDir.path, 'profile_photos'));
    if (!photosDir.existsSync()) {
      await photosDir.create(recursive: true);
    }

    final previousPath = _prefs?.getString(profileImageKey(targetUserId));
    final ext =
        p.extension(sourcePath).isNotEmpty ? p.extension(sourcePath) : '.jpg';
    final fileName =
        'avatar_${targetUserId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final destinationPath = p.join(photosDir.path, fileName);

    final copiedFile = await sourceFile.copy(destinationPath);
    await _prefs?.setString(profileImageKey(targetUserId), copiedFile.path);

    if (previousPath != null &&
        previousPath.isNotEmpty &&
        previousPath != copiedFile.path) {
      _deleteFileQuietly(previousPath);
    }

    if (_activeUserId == null || _activeUserId == targetUserId) {
      _activeUserId = targetUserId;
      _profileImagePathNotifier.value = copiedFile.path;
    }

    return copiedFile.path;
  }

  Future<void> removeProfileImage({String? userId}) async {
    final targetUserId = (userId ?? _activeUserId)?.trim();
    if (targetUserId == null || targetUserId.isEmpty) {
      _profileImagePathNotifier.value = null;
      return;
    }

    final existingPath = _prefs?.getString(profileImageKey(targetUserId));
    await _prefs?.remove(profileImageKey(targetUserId));
    if (existingPath != null && existingPath.isNotEmpty) {
      _deleteFileQuietly(existingPath);
    }

    if (_activeUserId == targetUserId) {
      _profileImagePathNotifier.value = null;
    }
  }

  void _deleteFileQuietly(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _profileImagePathNotifier.dispose();
    super.dispose();
  }

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
