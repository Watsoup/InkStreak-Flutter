import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_bloc.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_state.dart';
import 'package:inkstreak/presentation/screens/auth/login_screen.dart';
import 'package:inkstreak/presentation/screens/main/main_navigation_screen.dart';
import 'package:inkstreak/presentation/screens/profile/profile_screen.dart';
import 'package:inkstreak/presentation/screens/profile/edit_profile_screen.dart';
import 'package:inkstreak/presentation/screens/profile/user_profile_screen.dart';
import 'package:inkstreak/presentation/screens/settings/settings_screen.dart';
import 'package:inkstreak/presentation/screens/calendar/day_posts_screen.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_state.dart' as auth;

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/login',
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoggedIn = authState is AuthAuthenticated;
        final isAuthUnknown = authState is AuthInitial;

        // Show loading screen while checking auth state
        if (isAuthUnknown) {
          return null; // Stay at current location while checking
        }

        final isGoingToLogin = state.matchedLocation == '/login';

        // If not logged in and not going to login, redirect to login
        if (!isLoggedIn && !isGoingToLogin) {
          return '/login';
        }

        // If logged in and going to login, redirect to home
        if (isLoggedIn && isGoingToLogin) {
          return '/home';
        }

        // No redirect needed
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const MainNavigationScreen(initialPage: 0),
          ),
        ),
        GoRoute(
          path: '/upload',
          name: 'upload',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const MainNavigationScreen(initialPage: 1),
          ),
        ),
        GoRoute(
          path: '/feed',
          name: 'feed',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const MainNavigationScreen(initialPage: 2),
          ),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const ProfileScreen(),
          ),
          routes: [
            GoRoute(
              path: 'edit',
              name: 'profile-edit',
              pageBuilder: (context, state) {
                final authState = authBloc.state;
                final user = authState is auth.AuthAuthenticated ? authState.user : null;

                return MaterialPage(
                  key: state.pageKey,
                  child: EditProfileScreen(
                    username: user?.username ?? 'User',
                    currentBio: user?.bio,
                    currentProfilePicture: user?.profilePicture,
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/profile/:username',
          name: 'profile-view',
          pageBuilder: (context, state) {
            final username = state.pathParameters['username']!;
            return MaterialPage(
              key: state.pageKey,
              child: UserProfileScreen(username: username),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/day-posts',
          name: 'day-posts',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final date = extra['date'] as DateTime;
            final posts = extra['posts'] as List<Post>;

            return MaterialPage(
              key: state.pageKey,
              child: DayPostsScreen(
                date: date,
                posts: posts,
              ),
            );
          },
        ),
        // Redirect root to home (will be redirected to login if not authenticated)
        GoRoute(
          path: '/',
          redirect: (context, state) => '/home',
        ),
      ],
      errorPageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'The page you are looking for does not exist.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class to convert Stream to ChangeNotifier for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
