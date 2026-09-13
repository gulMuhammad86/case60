import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:case60/app/router/app_router.dart';
import 'package:case60/features/mystery/data/mystery_providers.dart';
import 'package:case60/features/mystery/presentation/investigation_screen.dart';
import 'package:case60/features/mystery/presentation/widgets/answer_option_tile.dart';

import '../../../support/mystery_fakes.dart';

void main() {
  testWidgets('opens the case file with story, clues and countdown', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('CASE #001'), findsOneWidget);
    expect(find.text('The Locked-Room Heist'), findsOneWidget);
    expect(find.text('STORY'), findsOneWidget);
    expect(find.text('A vault robbed from inside.'), findsOneWidget);
    expect(find.text('CLUES'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
    expect(find.text('The vent is too narrow.'), findsOneWidget);
    expect(find.text('The latch is intact.'), findsOneWidget);
    expect(find.text('TIME REMAINING'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('ANSWER'), findsOneWidget);
    expect(find.text('SUBMIT ANSWER'), findsOneWidget);
  });

  testWidgets('selecting an answer enables submit and submission ends the case', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    ElevatedButton submitButton() => tester.widget<ElevatedButton>(
          find.byWidgetPredicate((Widget widget) => widget is ElevatedButton),
        );

    expect(submitButton().onPressed, isNull);

    await tester.ensureVisible(find.text('The night guard'));
    await tester.tap(find.text('The night guard'));
    await tester.pump();

    final AnswerOptionTile selected = tester.widget<AnswerOptionTile>(
      find.byKey(const ValueKey<String>('answer-a1')),
    );
    expect(selected.state, AnswerOptionState.selected);

    final AnswerOptionTile others = tester.widget<AnswerOptionTile>(
      find.byKey(const ValueKey<String>('answer-a2')),
    );
    expect(others.state, AnswerOptionState.unselected);

    expect(submitButton().onPressed, isNotNull);

    await tester.ensureVisible(find.text('SUBMIT ANSWER'));
    await tester.tap(find.text('SUBMIT ANSWER'));
    await tester.pumpAndSettle();

    expect(find.text('results'), findsOneWidget);
  });

  testWidgets('the countdown redirects to results on timeout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    for (int i = 0; i < 62; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();

    expect(find.text('results'), findsOneWidget);
  });

  testWidgets('lays out without overflow on a small phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('SUBMIT ANSWER'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      mysteryRepositoryProvider.overrideWithValue(FakeMysteryRepository()),
    ],
    child: MaterialApp.router(routerConfig: _router()),
  );
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