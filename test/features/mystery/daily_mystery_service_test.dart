import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/mystery/application/daily_mystery_service.dart';
import 'package:case60/features/mystery/domain/models/answer_option.dart';
import 'package:case60/features/mystery/domain/models/clue.dart';
import 'package:case60/features/mystery/domain/models/mystery.dart';
import 'package:case60/features/mystery/domain/mystery_category.dart';
import 'package:case60/features/mystery/domain/mystery_difficulty.dart';

void main() {
  const DailyMysteryService service = DailyMysteryService();

  final List<Mystery> mysteries = <Mystery>[
    _mystery(3, 'case-003'),
    _mystery(1, 'case-001'),
    _mystery(5, 'case-005'),
    _mystery(2, 'case-002'),
    _mystery(4, 'case-004'),
  ];

  group('DailyMysteryService.mysteryForDate', () {
    test('returns the same mystery for the same date', () {
      final DateTime date = DateTime(2026, 9, 13);
      final Mystery first = service.mysteryForDate(date, mysteries);
      final Mystery second = service.mysteryForDate(date, mysteries);

      expect(first.id, second.id);
      expect(first, equals(second));
    });

    test('is stable across different times on the same calendar day', () {
      final Mystery morning = service.mysteryForDate(
        DateTime(2026, 9, 13, 0, 5),
        mysteries,
      );
      final Mystery night = service.mysteryForDate(
        DateTime(2026, 9, 13, 23, 45),
        mysteries,
      );

      expect(morning.id, night.id);
    });

    test('is independent of the input ordering', () {
      final DateTime date = DateTime(2026, 9, 13);
      final List<Mystery> reversed = mysteries.reversed.toList();

      expect(
        service.mysteryForDate(date, reversed).id,
        service.mysteryForDate(date, mysteries).id,
      );
    });

    test('always returns a mystery from the provided list', () {
      final Set<String> knownIds = mysteries.map((Mystery m) => m.id).toSet();

      for (int offset = 0; offset < 60; offset++) {
        final DateTime date = DateTime(2026, 6, 1).add(Duration(days: offset));
        final Mystery mystery = service.mysteryForDate(date, mysteries);
        expect(knownIds, contains(mystery.id));
      }
    });

    test('spreads selections across different dates', () {
      final Set<String> seen = <String>{};

      for (int offset = 0; offset < 60; offset++) {
        final DateTime date = DateTime(2026, 6, 1).add(Duration(days: offset));
        seen.add(service.mysteryForDate(date, mysteries).id);
      }

      expect(seen.length, greaterThan(1));
    });

    test('throws when the mystery list is empty', () {
      expect(
        () => service.mysteryForDate(DateTime(2026, 9, 13), const <Mystery>[]),
        throwsA(isA<StateError>()),
      );
    });
  });
}

Mystery _mystery(int caseNumber, String id) {
  return Mystery(
    id: id,
    caseNumber: caseNumber,
    title: 'Mystery $caseNumber',
    category: MysteryCategory.science,
    difficulty: MysteryDifficulty.medium,
    story: 'Story for $id.',
    clues: const <Clue>[Clue(id: 'c1', text: 'A clue.', orderIndex: 0)],
    answers: const <AnswerOption>[
      AnswerOption(id: 'a1', text: 'First'),
      AnswerOption(id: 'a2', text: 'Second'),
    ],
    correctAnswerId: 'a1',
    explanation: 'An explanation.',
    hints: const <String>['A hint.'],
    timeLimitSeconds: 60,
    availableDate: DateTime(2026, 1, 1),
  );
}