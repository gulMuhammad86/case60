import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/mystery/data/mystery_json_codec.dart';
import 'package:case60/features/mystery/domain/mystery_exceptions.dart';

import 'mystery_test_data.dart';

void main() {
  const MysteryJsonCodec codec = MysteryJsonCodec();

  void expectInvalid(
    String field, {
    required Map<String, Object> mystery,
  }) {
    final String source = mysteryJsonDocumentWith(mystery);
    Object? error;
    try {
      codec.decode(source);
    } on Object catch (e) {
      error = e;
    }
    expect(
      error,
      isA<MysteryValidationException>(),
      reason: 'Expected validation failure for "$field".',
    );
    final MysteryValidationException validation = error! as MysteryValidationException;
    expect(
      validation.errors.any((String message) => message.contains(field)),
      isTrue,
      reason: 'Expected an error mentioning "$field", got: ${validation.errors}',
    );
    expect(validation.message, 'Mystery JSON is invalid.');
  }

  group('MysteryJsonCodec.validate detects', () {
    test('a missing id', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..remove('id');
      expectInvalid('"id"', mystery: mystery);
    });

    test('an empty id', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['id'] = '   ';
      expectInvalid('"id"', mystery: mystery);
    });

    test('a duplicate mystery id', () {
      final String source = mysteryJsonDocument(<Map<String, Object>>[
        mysteryJsonFixture(),
        mysteryJsonFixture()..['caseNumber'] = 2,
      ]);
      Object? error;
      try {
        codec.decode(source);
      } on Object catch (e) {
        error = e;
      }
      expect(error, isA<MysteryValidationException>());
      final MysteryValidationException validation = error! as MysteryValidationException;
      expect(
        validation.errors.any((String message) => message.contains('duplicate id')),
        isTrue,
        reason: 'Expected a duplicate id error, got: ${validation.errors}',
      );
    });

    test('an empty title', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['title'] = '';
      expectInvalid('"title"', mystery: mystery);
    });

    test('an empty story', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['story'] = '  ';
      expectInvalid('"story"', mystery: mystery);
    });

    test('missing clues', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..remove('clues');
      expectInvalid('"clues"', mystery: mystery);
    });

    test('an empty clues array', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['clues'] = <Object>[];
      expectInvalid('"clues"', mystery: mystery);
    });

    test('a clue missing its id', () {
      final Map<String, Object> mystery = mysteryJsonFixture();
      final List<Object> clues = mystery['clues']! as List<Object>;
      (clues.first as Map<String, Object>).remove('id');
      expectInvalid('"id"', mystery: mystery);
    });

    test('a clue missing its text', () {
      final Map<String, Object> mystery = mysteryJsonFixture();
      final List<Object> clues = mystery['clues']! as List<Object>;
      (clues.first as Map<String, Object>).remove('text');
      expectInvalid('"text"', mystery: mystery);
    });

    test('duplicate answer ids', () {
      final Map<String, Object> mystery = mysteryJsonFixture();
      final List<Object> answers = mystery['answers']! as List<Object>;
      (answers.last as Map<String, Object>)['id'] = 'a1';
      expectInvalid('duplicate answer id', mystery: mystery);
    });

    test('fewer than two answers', () {
      final Map<String, Object> mystery = mysteryJsonFixture();
      mystery['answers'] = <Object>[
        <String, Object>{'id': 'a1', 'text': 'Solo option'},
      ];
      expectInvalid('"answers"', mystery: mystery);
    });

    test('a correctAnswerId that matches no answer', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['correctAnswerId'] = 'a99';
      expectInvalid('correctAnswerId', mystery: mystery);
    });

    test('a missing correctAnswerId', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..remove('correctAnswerId');
      expectInvalid('correctAnswerId', mystery: mystery);
    });

    test('a zero time limit', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['timeLimitSeconds'] = 0;
      expectInvalid('timeLimitSeconds', mystery: mystery);
    });

    test('a negative time limit', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['timeLimitSeconds'] = -30;
      expectInvalid('timeLimitSeconds', mystery: mystery);
    });

    test('a non-integer time limit', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['timeLimitSeconds'] = 'sixty';
      expectInvalid('timeLimitSeconds', mystery: mystery);
    });

    test('an unknown category', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['category'] = 'Spooky';
      expectInvalid('category', mystery: mystery);
    });

    test('an unknown difficulty', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['difficulty'] = 'Impossible';
      expectInvalid('difficulty', mystery: mystery);
    });

    test('an invalid availableDate', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['availableDate'] = 'whenever';
      expectInvalid('availableDate', mystery: mystery);
    });

    test('an empty explanation', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['explanation'] = '';
      expectInvalid('"explanation"', mystery: mystery);
    });
  });

  group('MysteryJsonCodec.validate accepts', () {
    test('a missing hints field', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..remove('hints');
      expect(codec.decode(mysteryJsonDocumentWith(mystery)), hasLength(1));
    });

    test('hints as an empty array', () {
      final Map<String, Object> mystery = mysteryJsonFixture()..['hints'] = <Object>[];
      expect(codec.decode(mysteryJsonDocumentWith(mystery)), hasLength(1));
    });
  });
}