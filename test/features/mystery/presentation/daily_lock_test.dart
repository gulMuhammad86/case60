import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:case60/app/router/app_router.dart';
import 'package:case60/core/services/app_clock.dart';
import 'package:case60/features/mystery/data/mystery_providers.dart';
import 'package:case60/features/mystery/presentation/investigation_screen.dart';
import 'package:case60/features/mystery/presentation/widgets/daily_lock_view.dart';
import 'package:case60/features/player/data/detective_profile_provider.dart';
import 'package:case60/features/player/domain/detective_profile.dart';

import '../../../support/mystery_fakes.dart';

void main() {
  testWidgets('shows the daily lock with a countdown when today is solved', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(DailyLockView), findsOneWidget);
    expect(find.text('CASE SOLVED'), findsOneWidget);
    expect(find.text('CASE #001 concluded — next case available tomorrow.'), findsOneWidget);
    expect(find.text('12:00:00'), findsOneWidget);
    expect(find.text('UNTIL THE NEXT CASE'), findsOneWidget);
    expect(find.text('SUBMIT ANSWER'), findsNothing);
  });

  testWidgets('the lock view counts down each second', (
    WidgetTester tester,
  ) async {
    final MutableAppClock clock = MutableAppClock(DateTime(2026, 9, 13, 12, 0));
    await tester.pumpWidget(_buildApp(clock: clock));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('12:00:00'), findsOneWidget);

    clock.value = DateTime(2026, 9, 13, 12, 0, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('11:59:59'), findsOneWidget);

    clock.value = DateTime(2026, 9, 13, 12, 1, 1);
    await tester.pump(const Duration(seconds: 59));
    expect(find.text('11:58:59'), findsOneWidget);
  });

  testWidgets('return to HQ leaves the lock screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('RETURN TO HQ'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('home'), findsOneWidget);
  });
}

GoRouter _router() {
  return GoRouter(
    initialLocation: AppRoute.mystery.path,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoute.home.path,
        builder: (BuildContext context, GoRouterState state) {
          return const _StubScreen('home');
        },
      ),
      GoRoute(
        path: AppRoute.mystery.path,
        builder: (BuildContext context, GoRouterState state) {
          return const InvestigationScreen();
        },
      ),
      GoRoute(
        path: AppRoute.results.path,
        builder: (BuildContext context, GoRouterState state) {
          return const _StubScreen('results');
        },
      ),
    ],
  );
}

Widget _buildApp({AppClock? clock}) {
  return ProviderScope(
    overrides: [
      mysteryRepositoryProvider.overrideWithValue(FakeMysteryRepository()),
      appClockProvider.overrideWithValue(
        clock ?? FixedAppClock(DateTime(2026, 9, 13, 12, 0)),
      ),
      detectiveProfileProvider.overrideWith(
        () => DetectiveProfileController(
          initial: const DetectiveProfile(
            lastCompletedDate: '2026-09-13',
            streakDays: 3,
          ),
        ),
      ),
    ],
    child: MaterialApp.router(routerConfig: _router()),
  );
}

final class FixedAppClock implements AppClock {
  const FixedAppClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

final class MutableAppClock implements AppClock {
  MutableAppClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;
}

class _StubScreen extends StatelessWidget {
  const _StubScreen(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(label)),
    );
  }
}