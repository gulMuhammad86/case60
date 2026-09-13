import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/mystery/application/case_controller.dart';
import 'package:case60/features/mystery/domain/mystery_difficulty.dart';
import 'package:case60/features/player/application/xp_service.dart';
import 'package:case60/features/results/presentation/results_screen.dart';

import '../../../support/mystery_fakes.dart';

void main() {
  testWidgets('a correct solve shows verdict, time, XP and explanation', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _container();
    addTearDown(container.dispose);
    final CaseController controller =
        container.read(caseControllerProvider.notifier);
    controller.begin(sampleMystery());
    controller.selectAnswer('a1');
    controller.submit();

    await tester.pumpWidget(_harness(container));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('CASE CLOSED'), findsOneWidget);
    expect(find.text('✓ SOLVED'), findsOneWidget);
    expect(find.text('Solved in 0 seconds.'), findsOneWidget);
    expect(find.text('+100 XP'), findsOneWidget);
    expect(find.text('CASE #001'), findsOneWidget);
    expect(find.text('The Locked-Room Heist'), findsOneWidget);
    expect(find.text('CORRECT ANSWER'), findsOneWidget);
    expect(find.text('The night guard'), findsOneWidget);
    expect(find.text('EXPLANATION'), findsOneWidget);
    expect(find.text('The guard had the keys.'), findsOneWidget);
    expect(find.text('THE EVIDENCE'), findsOneWidget);
    expect(find.text('The vent is too narrow.'), findsOneWidget);
    expect(find.text('The latch is intact.'), findsOneWidget);
    expect(find.text('RETURN TO HQ'), findsOneWidget);
    expect(find.text('TRY AGAIN'), findsOneWidget);
  });

  testWidgets('a wrong answer reveals the unsolved verdict and correct answer', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _container();
    addTearDown(container.dispose);
    final CaseController controller =
        container.read(caseControllerProvider.notifier);
    controller.begin(sampleMystery());
    controller.selectAnswer('a2');
    controller.submit();

    await tester.pumpWidget(_harness(container));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('CASE CLOSED'), findsOneWidget);
    expect(find.text('✕ CASE UNSOLVED'), findsOneWidget);
    expect(find.text('You were close.'), findsOneWidget);
    expect(find.text('YOUR ANSWER'), findsOneWidget);
    expect(find.text('The ceiling vent'), findsWidgets);
    expect(find.text('CORRECT ANSWER'), findsOneWidget);
    expect(find.text('The night guard'), findsOneWidget);
    expect(find.text('+10 XP'), findsOneWidget);
  });

  testWidgets('a timeout keeps the time-up verdict and awards no XP', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _container();
    addTearDown(container.dispose);
    final CaseController controller =
        container.read(caseControllerProvider.notifier);
    controller.begin(sampleMystery());

    await tester.pumpWidget(_harness(container));

    for (int i = 0; i < 62; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump();

    expect(find.text("TIME'S UP"), findsOneWidget);
    expect(
      find.text('No answer was submitted — time ran out.'),
      findsOneWidget,
    );
    expect(find.text('+0 XP'), findsOneWidget);
    expect(find.text('The night guard'), findsOneWidget);
    expect(find.text('✓ SOLVED'), findsNothing);
  });

  testWidgets('shows an empty state when no terminal case is available', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _container();
    addTearDown(container.dispose);

    await tester.pumpWidget(_harness(container));
    await tester.pump();

    expect(find.text('No Case In Progress'), findsOneWidget);
    expect(find.text('CASE CLOSED'), findsNothing);
  });
}

/// Deterministic XP config so the rendered rewards are stable in assertions.
ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      xpServiceProvider.overrideWithValue(
        const XPService(
          XPConfig(
            baseXpByDifficulty: <MysteryDifficulty, int>{
              MysteryDifficulty.medium: 100,
            },
            speedBonusMax: 0,
            incorrectXp: 10,
            hintPenaltyXp: 0,
            maxHintPenaltyXp: 0,
            timeoutXp: 0,
          ),
        ),
      ),
    ],
  );
}

Widget _harness(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: ResultsScreen()),
  );
}