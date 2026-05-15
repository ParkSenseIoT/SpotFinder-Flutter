import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/auth/presentation/blocs/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/parking_session/presentation/pages/find_my_car_page.dart';
import '../../features/parking_session/presentation/pages/home_page.dart';
import '../../features/parking_session/presentation/pages/session_detail_page.dart';
import '../../features/parking_session/presentation/pages/session_history_page.dart';

GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRouterListenable(authBloc.stream),
    redirect: (context, goRouterState) {
      final state = authBloc.state;
      final location = goRouterState.matchedLocation;
      final authPaths = {'/splash', '/onboarding', '/login', '/register'};
      final goingToAuth = authPaths.contains(location);

      if (state.status == AuthStatus.authenticated && goingToAuth && location != '/splash') {
        return '/home';
      }
      if (state.status == AuthStatus.unauthenticated && !goingToAuth) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
      GoRoute(path: '/find-my-car', builder: (_, __) => const FindMyCarPage()),
      GoRoute(path: '/sessions/history', builder: (_, __) => const SessionHistoryPage()),
      GoRoute(
        path: '/sessions/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const SessionHistoryPage();
          return SessionDetailPage(sessionId: id);
        },
      ),
    ],
  );
}

class _AuthRouterListenable extends ChangeNotifier {
  _AuthRouterListenable(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
