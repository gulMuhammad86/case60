import 'package:case60/features/mystery/domain/models/answer_option.dart';
import 'package:case60/features/mystery/domain/models/clue.dart';
import 'package:case60/features/mystery/domain/models/mystery.dart';
import 'package:case60/features/mystery/domain/mystery_category.dart';
import 'package:case60/features/mystery/domain/mystery_difficulty.dart';
import 'package:case60/features/mystery/domain/mystery_repository.dart';

/// A deterministic sample used by widget-level tests.
Mystery sampleMystery() {
  return Mystery(
    id: 'locked-room-heist',
    caseNumber: 1,
    title: 'The Locked-Room Heist',
    category: MysteryCategory.logic,
    difficulty: MysteryDifficulty.medium,
    story: 'A vault robbed from inside.',
    clues: const <Clue>[
      Clue(id: 'c1', text: 'The latch is intact.', orderIndex: 1),
      Clue(id: 'c2', text: 'The vent is too narrow.', orderIndex: 0),
    ],
    answers: const <AnswerOption>[
      AnswerOption(id: 'a1', text: 'The night guard'),
      AnswerOption(id: 'a2', text: 'The ceiling vent'),
    ],
    correctAnswerId: 'a1',
    explanation: 'The guard had the keys.',
    hints: const <String>['Follow the keys.'],
    timeLimitSeconds: 60,
    availableDate: DateTime(2026, 9, 13),
  );
}

/// In-memory repository stub; can be configured to fail before succeeding.
class FakeMysteryRepository implements MysteryRepository {
  FakeMysteryRepository({this.failuresBeforeSuccess = 0});

  final int failuresBeforeSuccess;
  int _calls = 0;

  @override
  Future<List<Mystery>> getMysteries() async => <Mystery>[sampleMystery()];

  @override
  Future<Mystery?> getMysteryById(String id) async => sampleMystery();

  @override
  Future<Mystery> getTodayMystery({DateTime? date}) async {
    _calls++;
    if (_calls <= failuresBeforeSuccess) {
      throw StateError('case file corrupted');
    }
    return sampleMystery();
  }
}