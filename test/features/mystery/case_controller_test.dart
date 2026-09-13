import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/mystery/application/case_controller.dart';
import 'package:case60/features/mystery/domain/case_session.dart';
import 'package:case60/features/mystery/domain/models/answer_option.dart';
import 'package:case60/features/mystery/domain/models/clue.dart';
import 'package:case60/features/mystery/domain/models/mystery.dart';
import 'package:case60/features/mystery/domain/mystery_category.dart';
import 'package:case60/features/mystery/domain/mystery_difficulty.dart';
import 'package:case60/features/player/application/xp_service.dart';
import 'package:case60/features/player/data/player_stats_provider.dart';

void main() {
  late ProviderContainer container;
  late CaseController controller;

  setUp(() {
    // A flat, far-away level curve keeps XP awards from crossing level 12 so
    // the asserted totals stay predictable; the reward bases match the
    // production defaults.
    container = ProviderContainer(
      overrides: [
        xpServiceProvider.overrideWithValue(
          const XPService(
            XPConfig(
              baseXpForLevel: 100000,
              levelGrowth: 1.0,
            ),
          ),
        ),
      ],
    );
    controller = container.read(caseControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('begin', () {
    test('transitions to inProgress and starts the countdown', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());

        CaseSession session = container.read(caseControllerProvider);
        expect(session.phase, CasePhase.inProgress);
        expect(session.remainingSeconds, 60);

        async.elapse(const Duration(seconds: 2));
        session = container.read(caseControllerProvider);
        expect(session.remainingSeconds, 58);
      });
    });

    test('beginning twice never creates a second timer', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        controller.begin(_case());

        async.elapse(const Duration(seconds: 5));
        expect(container.read(caseControllerProvider).remainingSeconds, 55);
      });
    });

    test('begin after a terminal phase starts a fresh attempt', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        async.elapse(const Duration(seconds: 60));
        expect(container.read(caseControllerProvider).phase, CasePhase.timeout);

        controller.begin(_case());
        expect(
          container.read(caseControllerProvider).phase,
          CasePhase.inProgress,
        );
        expect(container.read(caseControllerProvider).remainingSeconds, 60);
      });
    });
  });

  group('selectAnswer', () {
    test('is ignored before a case begins', () {
      controller.selectAnswer('a1');
      expect(container.read(caseControllerProvider).selectedAnswerId, isNull);
    });

    test('is ignored for unknown ids and stored for known ones', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());

        controller.selectAnswer('bogus');
        expect(container.read(caseControllerProvider).selectedAnswerId, isNull);

        controller.selectAnswer('a2');
        expect(container.read(caseControllerProvider).selectedAnswerId, 'a2');
      });
    });

    test('selecting again replaces the previous selection', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        controller.selectAnswer('a1');
        controller.selectAnswer('a3');
        expect(container.read(caseControllerProvider).selectedAnswerId, 'a3');
      });
    });
  });

  group('submit', () {
    test('is blocked until an answer is selected', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        controller.submit();
        expect(
          container.read(caseControllerProvider).phase,
          CasePhase.inProgress,
        );

        controller.selectAnswer('a1');
        controller.submit();
        expect(
          container.read(caseControllerProvider).phase,
          CasePhase.completed,
        );
      });
    });

    test('records solve time and correctness', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case(correctAnswerId: 'a2'));
        async.elapse(const Duration(seconds: 3));
        controller.selectAnswer('a2');
        controller.submit();

        final CaseSession session = container.read(caseControllerProvider);
        expect(session.phase, CasePhase.completed);
        expect(session.isCorrect, isTrue);
        expect(session.submittedAnswerId, 'a2');
        expect(session.solveTimeSeconds, 3);
      });
    });

    test('flags a wrong submission as incorrect', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case(correctAnswerId: 'a2'));
        async.elapse(const Duration(seconds: 3));
        controller.selectAnswer('a1');
        controller.submit();

        final CaseSession session = container.read(caseControllerProvider);
        expect(session.isCorrect, isFalse);
        expect(session.submittedAnswerId, 'a1');
      });
    });

    test('freezes the timer after submission', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        async.elapse(const Duration(seconds: 4));
        controller.selectAnswer('a1');
        controller.submit();

        final int frozen = container.read(caseControllerProvider).remainingSeconds;
        async.elapse(const Duration(seconds: 10));
        expect(
          container.read(caseControllerProvider).remainingSeconds,
          frozen,
        );
      });
    });

    test('duplicate submissions are ignored', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        async.elapse(const Duration(seconds: 2));
        controller.selectAnswer('a1');
        controller.submit();

        final CaseSession first = container.read(caseControllerProvider);

        async.elapse(const Duration(seconds: 5));
        controller.submit();
        controller.submit();

        final CaseSession second = container.read(caseControllerProvider);
        expect(second.phase, CasePhase.completed);
        expect(second.submittedAnswerId, first.submittedAnswerId);
        expect(second.isCorrect, first.isCorrect);
        expect(second.solveTimeSeconds, first.solveTimeSeconds);
      });
    });
  });

  group('timeout', () {
    test('expiring the timer ends the case as timeout', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        async.elapse(const Duration(seconds: 60));

        final CaseSession session = container.read(caseControllerProvider);
        expect(session.phase, CasePhase.timeout);
        expect(session.remainingSeconds, 0);
        expect(session.isCorrect, isNull);
        expect(session.submittedAnswerId, isNull);
      });
    });

    test('a timed-out session has a stopped timer', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        async.elapse(const Duration(seconds: 60));
        async.elapse(const Duration(seconds: 20));

        expect(container.read(caseControllerProvider).remainingSeconds, 0);
      });
    });

    test('submit after timeout is ignored', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        async.elapse(const Duration(seconds: 60));

        controller.selectAnswer('a1');
        controller.submit();
        expect(
          container.read(caseControllerProvider).phase,
          CasePhase.timeout,
        );
      });
    });

    test('a timeout awards no score, XP or player progression', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        async.elapse(const Duration(seconds: 60));

        final CaseSession session = container.read(caseControllerProvider);
        expect(session.score, 0);
        expect(session.xpReward, 0);
        expect(session.xpAwarded, isFalse);
        expect(container.read(playerStatsProvider).xpCurrent, 1380);
      });
    });
  });

  group('scoring and XP', () {
    test('a correct submission banks score and XP exactly once', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        controller.selectAnswer('a1');
        controller.submit();

        final CaseSession session = container.read(caseControllerProvider);
        expect(session.phase, CasePhase.completed);
        expect(session.score, 75);
        expect(session.xpReward, 130);
        expect(session.xpAwarded, isTrue);

        expect(container.read(playerStatsProvider).xpCurrent, 1510);

        controller.submit();
        expect(container.read(playerStatsProvider).xpCurrent, 1510);
      });
    });

    test('a wrong answer earns a reduced score and flat XP', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case(correctAnswerId: 'a2'));
        controller.selectAnswer('a1');
        controller.submit();

        final CaseSession session = container.read(caseControllerProvider);
        expect(session.isCorrect, isFalse);
        expect(session.score, 19);
        expect(session.xpReward, 15);
        expect(container.read(playerStatsProvider).xpCurrent, 1395);
      });
    });

    test('hints reduce the score and XP of a correct solve', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        controller.useHint();
        controller.selectAnswer('a1');
        controller.submit();

        final CaseSession session = container.read(caseControllerProvider);
        expect(session.hintsUsed, 1);
        expect(session.score, 64);
        expect(session.xpReward, 120);
        expect(container.read(playerStatsProvider).xpCurrent, 1500);
      });
    });
  });

  group('useHint', () {
    test('increments during play and caps at the available hints', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        controller.useHint();
        controller.useHint();
        expect(container.read(caseControllerProvider).hintsUsed, 1);
      });
    });

    test('is ignored before a case begins', () {
      controller.useHint();
      expect(container.read(caseControllerProvider).hintsUsed, 0);
    });
  });

  group('reset', () {
    test('returns to the initial idle state and halts the timer', () {
      fakeAsync((FakeAsync async) {
        controller.begin(_case());
        async.elapse(const Duration(seconds: 5));
        controller.reset();

        final CaseSession session = container.read(caseControllerProvider);
        expect(session.phase, CasePhase.initial);
        expect(session.mystery, isNull);
        expect(session.remainingSeconds, 0);
        expect(session.selectedAnswerId, isNull);

        async.elapse(const Duration(seconds: 10));
        expect(container.read(caseControllerProvider).phase, CasePhase.initial);
      });
    });
  });
}

Mystery _case({String correctAnswerId = 'a1', int timeLimitSeconds = 60}) {
  return Mystery(
    id: 'case-1',
    caseNumber: 1,
    title: 'The Locked Room',
    category: MysteryCategory.logic,
    difficulty: MysteryDifficulty.medium,
    story: 'A study locked from within.',
    clues: const <Clue>[Clue(id: 'c1', text: 'The key is missing.', orderIndex: 0)],
    answers: const <AnswerOption>[
      AnswerOption(id: 'a1', text: 'The professor'),
      AnswerOption(id: 'a2', text: 'The maid'),
      AnswerOption(id: 'a3', text: 'The clock'),
    ],
    correctAnswerId: correctAnswerId,
    explanation: 'It was the clock.',
    hints: const <String>['Check the pendulum.'],
    timeLimitSeconds: timeLimitSeconds,
    availableDate: DateTime(2026, 9, 13),
  );
}