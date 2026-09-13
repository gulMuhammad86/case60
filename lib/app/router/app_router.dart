import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/achievements/presentation/achievements_placeholder_screen.dart';
import '../../features/ads/presentation/ads_placeholder_screen.dart';
import '../../features/detective/presentation/detective_placeholder_screen.dart';
import '../../features/history/presentation/history_placeholder_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/mystery/presentation/mystery_placeholder_screen.dart';
import '../../features/results/presentation/results_placeholder_screen.dart';
import '../../features/settings/presentation/settings_placeholder_screen.dart';

/// The single [GoRouter] instance for the app.
///
/// Exposed as a provider so tests can substitute a scoped router and so the
/// instance is created exactly once for the widget tree.
final Provider<GoRouter> routerProvider = Provider<GoRouter>(AppRouter._create);

/// Centralized route names (no magic path strings in widgets).
enum AppRoute {
  home('/home'),
  mystery('/mystery'),
  results('/results'),
  profile('/profile'),
  achievements('/achievements'),
  history('/history'),
  settings('/settings'),
  ads('/ads');

  const AppRoute(this.path);
  final String path;

  String get location => path;
}

/// Builds the single [GoRouter] used by the app.
final class AppRouter {
  AppRouter._();

  static GoRouter _create(Ref ref) {
    return GoRouter(
      initialLocation: AppRoute.home.path,
      redirect: (BuildContext context, GoRouterState state) {
        if (state.matchedLocation == '/') {
          return AppRoute.home.path;
        }
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoute.home.path,
          name: AppRoute.home.name,
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: AppRoute.mystery.path,
          name: AppRoute.mystery.name,
          builder: (BuildContext context, GoRouterState state) {
            return const MysteryPlaceholderScreen();
          },
        ),
        GoRoute(
          path: AppRoute.results.path,
          name: AppRoute.results.name,
          builder: (BuildContext context, GoRouterState state) {
            return const ResultsPlaceholderScreen();
          },
        ),
        GoRoute(
          path: AppRoute.profile.path,
          name: AppRoute.profile.name,
          builder: (BuildContext context, GoRouterState state) {
            return const DetectivePlaceholderScreen();
          },
        ),
        GoRoute(
          path: AppRoute.achievements.path,
          name: AppRoute.achievements.name,
          builder: (BuildContext context, GoRouterState state) {
            return const AchievementsPlaceholderScreen();
          },
        ),
        GoRoute(
          path: AppRoute.history.path,
          name: AppRoute.history.name,
          builder: (BuildContext context, GoRouterState state) {
            return const HistoryPlaceholderScreen();
          },
        ),
        GoRoute(
          path: AppRoute.settings.path,
          name: AppRoute.settings.name,
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsPlaceholderScreen();
          },
        ),
        GoRoute(
          path: AppRoute.ads.path,
          name: AppRoute.ads.name,
          builder: (BuildContext context, GoRouterState state) {
            return const AdsPlaceholderScreen();
          },
        ),
      ],
    );
  }
}