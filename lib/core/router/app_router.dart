
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/meditation/presentation/screens/meditation_screen.dart';
import '../../features/meditation/presentation/screens/pre_session_screen.dart';
import '../../features/meditation/presentation/screens/session_summary_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/dashboard/presentation/screens/stats_screen.dart';
import '../../shared/widgets/shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.whenOrNull(
        data: (data) => data.session != null,
      ) ?? false;

      final isAuthRoute = state.matchedLocation == '/login';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/meditate',
        builder: (context, state) => const PreSessionScreen(),
      ),
      GoRoute(
        path: '/meditate/session',
        builder: (context, state) => const MeditationScreen(),
      ),
      GoRoute(
        path: '/meditate/summary',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SessionSummaryScreen(
            sessionId: extra?['sessionId'] as String? ?? '',
          );
        },
      ),
    ],
  );
});
