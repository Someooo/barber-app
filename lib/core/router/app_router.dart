import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/features/auth/domain/entities/user_role.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:barber_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:barber_app/features/auth/presentation/screens/login_screen.dart';
import 'package:barber_app/features/auth/presentation/screens/register_screen.dart';
import 'package:barber_app/features/auth/presentation/screens/welcome_role_screen.dart';
import 'package:barber_app/features/barber/presentation/screens/barber_shell_screen.dart';
import 'package:barber_app/features/customer/presentation/screens/booking_flow_screen.dart';
import 'package:barber_app/features/customer/presentation/screens/customer_shell_screen.dart';
import 'package:barber_app/features/owner/presentation/screens/owner_shell_screen.dart';

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
  final isOwnerRoute = matchedLocation.startsWith('/owner');
  final isProtectedRoute = isBarberRoute || isCustomerRoute || isOwnerRoute;
  final isPublicAuthRoute = matchedLocation == AppRoutes.welcome ||
      matchedLocation == AppRoutes.login ||
      matchedLocation == AppRoutes.register;

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
      UserRole.owner => AppRoutes.ownerDashboard,
    };

    if (isPublicAuthRoute) {
      return roleHome;
    }

    if (role == UserRole.customer && (isBarberRoute || isOwnerRoute)) {
      return AppRoutes.customerHome;
    }

    if (role == UserRole.barber && (isCustomerRoute || isOwnerRoute)) {
      return AppRoutes.barberDashboard;
    }

    if (role == UserRole.owner && (isCustomerRoute || isBarberRoute)) {
      return AppRoutes.ownerDashboard;
    }
  }

  return null;
}

GoRouter createAppRouter({
  AuthBloc? authBloc,
  Listenable? refreshListenable,
  String initialLocation = AppRoutes.welcome,
}) {
  final effectiveRefreshListenable = refreshListenable ??
      (authBloc != null ? GoRouterRefreshStream(authBloc.stream) : null);

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: effectiveRefreshListenable,
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
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.barberDashboard,
        builder: (context, state) => const BarberShellScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerDashboard,
        builder: (context, state) => const OwnerShellScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => const CustomerShellScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerBook,
        builder: (context, state) {
          final extra = state.extra;
          String? preselectedServiceId;
          String? preselectedBarberId;
          if (extra is Map<String, dynamic>) {
            preselectedServiceId = extra['serviceId'] as String? ??
                extra['preselectedServiceId'] as String?;
            preselectedBarberId = extra['barberId'] as String? ??
                extra['preselectedBarberId'] as String?;
          }
          preselectedServiceId ??= state.uri.queryParameters['serviceId'] ??
              state.uri.queryParameters['preselectedServiceId'];
          preselectedBarberId ??= state.uri.queryParameters['barberId'] ??
              state.uri.queryParameters['preselectedBarberId'];

          return BookingFlowScreen(
            preselectedServiceId: preselectedServiceId,
            preselectedBarberId: preselectedBarberId,
          );
        },
      ),
    ],
  );
}
