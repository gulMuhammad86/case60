import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/app/app.dart';
import 'package:case60/features/mystery/data/mystery_providers.dart';

import 'support/mystery_fakes.dart';

void main() {
  testWidgets('CASE 60 app launches and shows the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mysteryRepositoryProvider.overrideWithValue(FakeMysteryRepository()),
        ],
        child: const Case60App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CASE 60'), findsOneWidget);
    expect(find.text("TODAY'S CASE"), findsOneWidget);
    expect(find.text('CASE #001'), findsOneWidget);
    expect(find.text('The Locked-Room Heist'), findsOneWidget);
    expect(find.text('LOGIC  •  MEDIUM'), findsOneWidget);
    expect(find.text('60 SECOND CHALLENGE'), findsOneWidget);
    expect(find.text('START CASE'), findsOneWidget);
    expect(find.text('XP'), findsOneWidget);
    expect(find.text('7 DAY STREAK'), findsOneWidget);
    expect(find.text('DETECTIVE LEVEL 12'), findsOneWidget);
  });

  testWidgets('START CASE navigates to the mystery screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mysteryRepositoryProvider.overrideWithValue(FakeMysteryRepository()),
        ],
        child: const Case60App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('START CASE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Mystery'), findsOneWidget);
    expect(find.text('Awaiting evidence…'), findsOneWidget);
  });
}