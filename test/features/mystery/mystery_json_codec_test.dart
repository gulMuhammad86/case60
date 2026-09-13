import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/mystery/data/mystery_json_codec.dart';
import 'package:case60/features/mystery/domain/models/answer_option.dart';
import 'package:case60/features/mystery/domain/models/clue.dart';
import 'package:case60/features/mystery/domain/models/mystery.dart';
import 'package:case60/features/mystery/domain/mystery_category.dart';
import 'package:case60/features/mystery/domain/mystery_difficulty.dart';
import 'package:case60/features/mystery/domain/mystery_exceptions.dart';

import 'mystery_test_data.dart';

void main() {
  const MysteryJsonCodec codec = MysteryJsonCodec();

  group('MysteryJsonCodec.parse', () {
    test('decodes a well-formed document into typed models', () {
      final List<Mystery> mysteries = codec.decode(mysteryJsonDocument());

      expect(mysteries, hasLength(1));
      final Mystery mystery = mysteries.single;
      expect(mystery.id, 'alchemy-vault');
      expect(mystery.caseNumber, 1);
      expect(mystery.title, 'The Alchemy Vault');
      expect(mystery.category, MysteryCategory.logic);
      expect(mystery.difficulty, MysteryDifficulty.easy);
      expect(mystery.story, 'Three sealed caskets.');
      expect(
        mystery.clues,
        equals(<Clue>[
          const Clue(id: 'c1', text: 'Clue one.', orderIndex: 0),
          const Clue(id: 'c2', text: 'Clue two.', orderIndex: 1),
        ]),
      );
      expect(
        mystery.answers,
        equals(<AnswerOption>[
          const AnswerOption(id: 'a1', text: 'The gold casket'),
          const AnswerOption(id: 'a2', text: 'The silver casket'),
          const AnswerOption(id: 'a3', text: 'The bronze casket'),
          const AnswerOption(id: 'a4', text: 'None of the above'),
        ]),
      );
      expect(mystery.correctAnswerId, 'a2');
      expect(mystery.explanation, 'Because silver is the only case.');
      expect(mystery.hints, <String>['Look at silver.']);
      expect(mystery.timeLimitSeconds, 60);
      expect(mystery.availableDate, DateTime(2026, 8, 1));
    });

    test('resolves correctAnswer to the matching option', () {
      final Mystery mystery = codec.decode(mysteryJsonDocument()).single;
      expect(mystery.correctAnswer, isNotNull);
      expect(mystery.correctAnswer!.id, 'a2');
      expect(mystery.correctAnswer!.text, 'The silver casket');
    });

    test('maps every category label', () {
      final List<Map<String, Object>> items = <Map<String, Object>>[];

      for (final MysteryCategory category in MysteryCategory.values) {
        final Map<String, Object> item = mysteryJsonFixture()..['id'] = category.name;
        item['category'] = category.label;
        items.add(item);
      }

      final List<Mystery> mysteries = codec.decode(mysteryJsonDocument(items));

      expect(
        mysteries.map((Mystery m) => m.category).toSet(),
        MysteryCategory.values.toSet(),
      );
    });

    test('maps every difficulty label', () {
      final List<Map<String, Object>> items = <Map<String, Object>>[];

      for (final MysteryDifficulty difficulty in MysteryDifficulty.values) {
        final Map<String, Object> item = mysteryJsonFixture()
          ..['id'] = difficulty.name;
        item['difficulty'] = difficulty.label;
        items.add(item);
      }

      final List<Mystery> mysteries = codec.decode(mysteryJsonDocument(items));

      expect(
        mysteries.map((Mystery m) => m.difficulty).toSet(),
        MysteryDifficulty.values.toSet(),
      );
    });
  });

  group('MysteryJsonCodec.decode error handling', () {
    test('throws MysteryDataException for undecodable JSON', () {
      expect(() => codec.decode('this is not json'), throwsA(isA<MysteryDataException>()));
    });

    test('throws MysteryValidationException when the root is not an object', () {
      expect(() => codec.decode('[1, 2, 3]'), throwsA(isA<MysteryValidationException>()));
    });

    test('throws MysteryValidationException when the mysteries array is missing', () {
      expect(
        () => codec.decode('{"other": []}'),
        throwsA(isA<MysteryValidationException>()),
      );
    });

    test('throws MysteryValidationException for an empty mysteries array', () {
      expect(
        () => codec.decode('{"mysteries": []}'),
        throwsA(isA<MysteryValidationException>()),
      );
    });
  });
}