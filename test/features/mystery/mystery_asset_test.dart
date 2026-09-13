import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/mystery/data/local_mystery_repository.dart';
import 'package:case60/features/mystery/domain/models/mystery.dart';
import 'package:case60/features/mystery/domain/mystery_category.dart';
import 'package:case60/features/mystery/domain/mystery_difficulty.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late final LocalMysteryRepository repository;
  late final List<Mystery> mysteries;

  setUpAll(() async {
    repository = LocalMysteryRepository(assetBundle: rootBundle);
    mysteries = await repository.getMysteries();
  });

  test('bundled mysteries.json contains at least 20 mysteries', () {
    expect(mysteries.length, greaterThanOrEqualTo(20));
  });

  test('mystery ids are unique', () {
    final Set<String> ids = mysteries.map((Mystery m) => m.id).toSet();
    expect(ids.length, mysteries.length);
  });

  test('case numbers are unique', () {
    final Set<int> caseNumbers = mysteries.map((Mystery m) => m.caseNumber).toSet();
    expect(caseNumbers.length, mysteries.length);
  });

  test('every mystery has complete, valid content', () {
    for (final Mystery mystery in mysteries) {
      expect(mystery.id.trim(), isNotEmpty, reason: 'id for case ${mystery.caseNumber}');
      expect(mystery.caseNumber, greaterThan(0));
      expect(mystery.title.trim(), isNotEmpty, reason: 'title for ${mystery.id}');
      expect(mystery.story.trim(), isNotEmpty, reason: 'story for ${mystery.id}');
      expect(mystery.explanation.trim(), isNotEmpty, reason: 'explanation for ${mystery.id}');
      expect(mystery.clues, isNotEmpty, reason: 'clues for ${mystery.id}');
      expect(mystery.answers.length, greaterThanOrEqualTo(2), reason: 'answers for ${mystery.id}');
      expect(mystery.timeLimitSeconds, greaterThan(0), reason: 'time limit for ${mystery.id}');

      final Set<String> answerIds = mystery.answers.map((a) => a.id).toSet();
      expect(answerIds, contains(mystery.correctAnswerId), reason: 'correct answer for ${mystery.id}');
      expect(mystery.correctAnswer, isNotNull, reason: 'resolvable answer for ${mystery.id}');
    }
  });

  test('all ten categories are represented', () {
    final Set<MysteryCategory> categories = mysteries
        .map((Mystery m) => m.category)
        .toSet();
    expect(categories, containsAll(MysteryCategory.values));
  });

  test('all difficulties are represented', () {
    final Set<MysteryDifficulty> difficulties = mysteries
        .map((Mystery m) => m.difficulty)
        .toSet();
    expect(difficulties, containsAll(MysteryDifficulty.values));
  });

  test('mysteries are not all murder mysteries', () {
    final int murderStories = mysteries
        .where((Mystery m) => m.story.toLowerCase().contains('murder'))
        .length;
    expect(murderStories, 0);

    final int crimeCases = mysteries
        .where((Mystery m) => m.category == MysteryCategory.crime)
        .length;
    expect(crimeCases, lessThanOrEqualTo(2));
  });
}