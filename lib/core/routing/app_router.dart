import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../shared/models/app_state.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';

  static GoRouter createRouter(AppState appState) {
    return GoRouter(
      initialLocation: loginRoute,
      redirect: (context, state) {
        final isLoggedIn = appState.isAuthenticated;
        final isOnLogin = state.matchedLocation == loginRoute;

        if (!isLoggedIn && !isOnLogin) return loginRoute;
        if (isLoggedIn && isOnLogin) return dashboardRoute;
        return null;
      },
      refreshListenable: appState,
      routes: [
        GoRoute(
          path: loginRoute,
          name: 'login',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LoginPage(),
          ),
        ),
        GoRoute(
          path: dashboardRoute,
          name: 'dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardPage(),
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      ),
    );
  }
}
