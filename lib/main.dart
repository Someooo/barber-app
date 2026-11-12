import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}

  await initDependencies();
  runApp(const BarberSyncApp());
}

class BarberSyncApp extends StatefulWidget {
  const BarberSyncApp({
    super.key,
    this.authBloc,
    this.initialLocation = AppRoutes.welcome,
  });

  final AuthBloc? authBloc;
  final String initialLocation;

  @override
  State<BarberSyncApp> createState() => _BarberSyncAppState();
}

class _BarberSyncAppState extends State<BarberSyncApp> {
  final AppSettingsController _settings = AppSettingsController();
  late final AuthBloc _authBloc;
  late final bool _ownsAuthBloc;
  late final GoRouter _router;
  StreamSubscription<AuthState>? _authSubscription;
  bool _splashRemoved = false;

  @override
  void initState() {
    super.initState();
    if (!sl.isRegistered<AuthBloc>()) {
      registerAuthDependencies();
    }

    _ownsAuthBloc = widget.authBloc == null;
    _authBloc = widget.authBloc ?? sl<AuthBloc>();

    _authSubscription = _authBloc.stream.listen(_handleSplashRemoval);

    if (_authBloc.state is AuthInitial) {
      _authBloc.add(const AuthCheckRequested());
    } else {
      _handleSplashRemoval(_authBloc.state);
    }

    _router = createAppRouter(
      authBloc: _authBloc,
      initialLocation: widget.initialLocation,
    );
  }

  void _handleSplashRemoval(AuthState state) {
    if (_splashRemoved) {
      return;
    }
    if (state is! AuthInitial && state is! AuthCheckingSession) {
      _splashRemoved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterNativeSplash.remove();
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _router.dispose();
    if (_ownsAuthBloc) {
      _authBloc.close();
    }
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: AppSettingsScope(
        controller: _settings,
        child: ListenableBuilder(
          listenable: _settings,
          builder: (context, _) {
            return MaterialApp.router(
              title: 'BarberSync',
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _settings.themeMode,
              locale: _settings.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}
