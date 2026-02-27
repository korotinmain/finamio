import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/transactions/add_transaction_screen.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/goals/add_goal_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/navigation/bottom_nav_bar.dart';

/// A [ChangeNotifier] that fires whenever the auth state changes.
/// Used as [GoRouter.refreshListenable] so the router re-evaluates its
/// redirect without being recreated entirely.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return '/';

      final isLoggedIn = authState.valueOrNull != null;
      final path = state.uri.path;

      if (!isLoggedIn &&
          path != '/sign-in' &&
          path != '/register' &&
          path != '/forgot-password' &&
          path != '/') {
        return '/sign-in';
      }
      if (isLoggedIn &&
          (path == '/sign-in' ||
              path == '/register' ||
              path == '/forgot-password')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Main shell ──────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => FinamioBottomNav(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, state) => _noTransition(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder:
                (_, state) => _noTransition(state, const TransactionsScreen()),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder:
                (_, state) => _noTransition(state, const GoalsScreen()),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder:
                (_, state) => _noTransition(state, const AnalyticsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder:
                (_, state) => _noTransition(state, const ProfileScreen()),
          ),
        ],
      ),

      // ── Modal / push routes ─────────────────────────────────────────────
      GoRoute(
        path: '/transactions/add',
        builder: (_, __) => const AddTransactionScreen(),
      ),
      GoRoute(path: '/goals/add', builder: (_, __) => const AddGoalScreen()),
    ],
  );

  ref.onDispose(() {
    authNotifier.dispose();
    router.dispose();
  });

  return router;
});

CustomTransitionPage<void> _noTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}
