import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/auth/presentation/screens/login_placeholder_screen.dart';
import 'package:barber_app/features/auth/presentation/screens/login_screen.dart';
import 'package:barber_app/features/auth/presentation/screens/welcome_role_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

String? evaluateAuthRedirect({
  required AuthState authState,
  required String matchedLocation,
}) {
  if (authState is AuthInitial || authState is AuthCheckingSession) {
    return null;
  }

  final isBarberRoute = matchedLocation.startsWith('/barber');
  final isCustomerRoute = matchedLocation.startsWith('/customer');
  final isProtectedRoute = isBarberRoute || isCustomerRoute;
  final isPublicAuthRoute = matchedLocation == AppRoutes.welcome ||
      matchedLocation == AppRoutes.login;

  if (authState is Unauthenticated || authState is AuthFailureState) {
    if (isProtectedRoute) {
      return AppRoutes.welcome;
    }
    return null;
  }

  if (authState is Authenticated) {
    final role = authState.user.role;
    final roleHome = switch (role) {
      UserRole.barber => AppRoutes.barberDashboard,
      UserRole.customer => AppRoutes.customerHome,
    };

    if (isPublicAuthRoute) {
      return roleHome;
    }

    if (role == UserRole.customer && isBarberRoute) {
      return AppRoutes.customerHome;
    }

    if (role == UserRole.barber && isCustomerRoute) {
      return AppRoutes.barberDashboard;
    }
  }

  return null;
}

GoRouter createAppRouter({
  AuthBloc? authBloc,
  String initialLocation = AppRoutes.welcome,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable:
        authBloc != null ? GoRouterRefreshStream(authBloc.stream) : null,
    redirect: authBloc == null
        ? null
        : (context, state) => evaluateAuthRedirect(
              authState: authBloc.state,
              matchedLocation: state.matchedLocation,
            ),
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeRoleScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.barberDashboard,
        builder: (context, state) => LoginPlaceholderScreen(
          titleBuilder: (l10n) => l10n.barberDashboardTitle,
        ),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => LoginPlaceholderScreen(
          titleBuilder: (l10n) => l10n.customerHomeTitle,
        ),
      ),
    ],
  );
}
