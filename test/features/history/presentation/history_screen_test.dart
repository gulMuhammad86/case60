import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/history/data/history_provider.dart';
import 'package:case60/features/history/domain/history_entry.dart';
import 'package:case60/features/history/presentation/history_screen.dart';
import 'package:case60/features/history/presentation/widgets/history_card.dart';

void main() {
  testWidgets('renders the empty state when there is no history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );

    expect(find.text('CASE HISTORY'), findsOneWidget);
    expect(find.text('No Cases Yet'), findsOneWidget);
  });

  testWidgets('lists attempts newest first with outcome chips', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyProvider.overrideWith(
            () => HistoryController(initial: <HistoryEntry>[
              HistoryEntry(
                caseNumber: 42,
                completedAt: DateTime(2026, 9, 13),
                solved: true,
                timeSeconds: 37,
                xpEarned: 100,
              ),
              HistoryEntry(
                caseNumber: 41,
                completedAt: DateTime(2026, 9, 12),
                solved: false,
                timeSeconds: 60,
                xpEarned: 0,
              ),
            ]),
          ),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );

    expect(find.text('CASE #042'), findsOneWidget);
    expect(find.text('SOLVED  •  37 SEC'), findsOneWidget);
    expect(find.text('+100 XP'), findsOneWidget);
    expect(find.text('CASE #041'), findsOneWidget);
    expect(find.text('UNSOLVED  •  60 SEC'), findsOneWidget);
  });

  testWidgets('a solved card surfaces the XP award', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HistoryCard(
            entry: HistoryEntry(
              caseNumber: 42,
              completedAt: DateTime(2026, 9, 13),
              solved: true,
              timeSeconds: 37,
              xpEarned: 100,
            ),
          ),
        ),
      ),
    );

    expect(find.text('CASE #042'), findsOneWidget);
    expect(find.text('SOLVED  •  37 SEC'), findsOneWidget);
    expect(find.text('+100 XP'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('an unsolved card omits the XP award', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HistoryCard(
            entry: HistoryEntry(
              caseNumber: 40,
              completedAt: DateTime(2026, 9, 10),
              solved: false,
              timeSeconds: 60,
              xpEarned: 0,
            ),
          ),
        ),
      ),
    );

    expect(find.text('CASE #040'), findsOneWidget);
    expect(find.text('UNSOLVED  •  60 SEC'), findsOneWidget);
    expect(find.textContaining('+'), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}