import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/shell/app_shell.dart';
import 'package:gometer/features/about/about_screen.dart';
import 'package:gometer/features/access_key/access_key_screen.dart';
import 'package:gometer/features/notifications/notifications_screen.dart';
import 'package:gometer/features/onboarding/onboarding_screen.dart';
import 'package:gometer/features/settings/settings_screen.dart';
import 'package:gometer/features/usage/usage_screen.dart';

class AppRouter {
  final SettingsRepository _repo;

  AppRouter(this._repo);

  late final router = GoRouter(
    initialLocation: '/usage',
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/usage',
            builder: (context, state) => const UsageScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/key',
            builder: (context, state) => const AccessKeyScreen(),
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final settings = _repo.load();
    final isOnboarding = state.matchedLocation == '/onboarding';

    if (settings.apiKey.isEmpty && !isOnboarding) return '/onboarding';
    if (settings.apiKey.isNotEmpty && isOnboarding) return '/usage';
    return null;
  }
}
