import 'package:go_router/go_router.dart';

import 'package:barber_app/core/router/app_routes.dart';
import 'package:barber_app/features/auth/presentation/screens/login_placeholder_screen.dart';
import 'package:barber_app/features/auth/presentation/screens/welcome_role_screen.dart';

/// Builds the application router. `WelcomeRoleScreen` is the initial route.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeRoleScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginPlaceholderScreen(
          titleBuilder: (l10n) => l10n.loginScreenTitle,
        ),
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

