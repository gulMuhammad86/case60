import 'package:flutter_test/flutter_test.dart';

import 'package:case60/features/player/application/streak_service.dart';

void main() {
  const StreakService service = StreakService();

  // Fixed "today" so day math is deterministic and timezone-free.
  final DateTime today = DateTime(2026, 9, 13, 20, 30);

  group('completedOn', () {
    test('is false with no completion record', () {
      expect(service.completedOn(null, today), isFalse);
    });

    test('is true when the stored key matches the given day', () {
      expect(service.completedOn('2026-09-13', today), isTrue);
    });

    test('is false for any other day', () {
      expect(service.completedOn('2026-09-12', today), isFalse);
    });
  });

  group('nextStreak', () {
    test('a first completion starts the streak at one', () {
      expect(
        service.nextStreak(
          lastCompletedDate: null,
          storedDays: 0,
          now: today,
        ),
        1,
      );
    });

    test('completing the day after the last one extends the streak', () {
      expect(
        service.nextStreak(
          lastCompletedDate: '2026-09-12',
          storedDays: 5,
          now: today,
        ),
        6,
      );
    });

    test('completing on the same day leaves the streak unchanged', () {
      expect(
        service.nextStreak(
          lastCompletedDate: '2026-09-13',
          storedDays: 5,
          now: today,
        ),
        5,
      );
    });

    test('a missed day resets the streak to one', () {
      expect(
        service.nextStreak(
          lastCompletedDate: '2026-09-10',
          storedDays: 5,
          now: today,
        ),
        1,
      );
    });

    test('a malformed stored key falls back to starting fresh', () {
      expect(
        service.nextStreak(
          lastCompletedDate: 'not-a-date',
          storedDays: 5,
          now: today,
        ),
        1,
      );
    });
  });

  group('effectiveStreak', () {
    test('reads zero when nothing has been completed', () {
      expect(
        service.effectiveStreak(
          lastCompletedDate: null,
          storedDays: 8,
          now: today,
        ),
        0,
      );
    });

    test('keeps the streak alive on the completion day', () {
      expect(
        service.effectiveStreak(
          lastCompletedDate: '2026-09-13',
          storedDays: 8,
          now: today,
        ),
        8,
      );
      expect(
        service.effectiveStreak(
          lastCompletedDate: '2026-09-13',
          storedDays: 8,
          now: DateTime(2026, 9, 13, 23, 59),
        ),
        8,
      );
    });

    test('survives the day after the last completion', () {
      expect(
        service.effectiveStreak(
          lastCompletedDate: '2026-09-12',
          storedDays: 8,
          now: today,
        ),
        8,
      );
    });

    test('collapses to zero after a full missed day', () {
      expect(
        service.effectiveStreak(
          lastCompletedDate: '2026-09-11',
          storedDays: 8,
          now: today,
        ),
        0,
      );
    });

    test('never reports a negative streak for a zero stored value', () {
      expect(
        service.effectiveStreak(
          lastCompletedDate: '2026-09-13',
          storedDays: 0,
          now: today,
        ),
        0,
      );
    });
  });
}