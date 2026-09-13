import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/home/presentation/home_screen.dart';
import 'package:case60/features/mystery/data/mystery_providers.dart';

import '../../../support/mystery_fakes.dart';

void main() {
  testWidgets('renders today\'s case and detective stats', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('CASE 60'), findsOneWidget);
    expect(find.text("TODAY'S CASE"), findsOneWidget);
    expect(find.text('The Locked-Room Heist'), findsOneWidget);
    expect(find.text('START CASE'), findsOneWidget);
    expect(find.text('7 DAY STREAK'), findsOneWidget);
    expect(find.text('DETECTIVE LEVEL 12'), findsOneWidget);
    expect(find.text('1380 / 2400'), findsOneWidget);
  });

  testWidgets('lays out without overflow on a small phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('START CASE'), findsOneWidget);
    expect(find.text('7 DAY STREAK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out without overflow on a tablet', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('START CASE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an error state and recovers on retry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(repository: FakeMysteryRepository(failuresBeforeSuccess: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load today's case."), findsOneWidget);
    expect(find.text('RETRY'), findsOneWidget);

    await tester.tap(find.text('RETRY'));
    await tester.pumpAndSettle();

    expect(find.text('The Locked-Room Heist'), findsOneWidget);
    expect(find.text('START CASE'), findsOneWidget);
  });
}

Widget _buildApp({FakeMysteryRepository? repository}) {
  return ProviderScope(
    overrides: [
      mysteryRepositoryProvider.overrideWithValue(
        repository ?? FakeMysteryRepository(),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}