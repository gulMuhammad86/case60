import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config/app_config.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget for CASE 60.
///
/// Wraps the entire widget tree in a [ProviderScope] so every descendant may
/// access Riverpod providers, then mounts the Material app with the theme and
/// the shared [GoRouter] from [routerProvider].
class Case60App extends ConsumerWidget {
  const Case60App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}