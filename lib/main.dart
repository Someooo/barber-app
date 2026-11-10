import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const BarberSyncApp());
}

class BarberSyncApp extends StatefulWidget {
  const BarberSyncApp({super.key});

  @override
  State<BarberSyncApp> createState() => _BarberSyncAppState();
}

class _BarberSyncAppState extends State<BarberSyncApp> {
  final AppSettingsController _settings = AppSettingsController();
  late final GoRouter _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      controller: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'BarberSync',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _settings.themeMode,
            locale: _settings.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
