import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/core/timer/case_countdown.dart';

void main() {
  group('CaseCountdown', () {
    test('ticks down one second per tick, reporting remaining time', () {
      fakeAsync((FakeAsync async) {
        final List<int> ticks = <int>[];
        final CaseCountdown countdown = CaseCountdown(
          duration: const Duration(seconds: 3),
          onTick: (Duration remaining) => ticks.add(remaining.inSeconds),
        );

        countdown.start();
        expect(countdown.remaining, const Duration(seconds: 3));

        async.elapse(const Duration(seconds: 1));
        expect(countdown.remaining, const Duration(seconds: 2));
        expect(ticks, <int>[2]);

        async.elapse(const Duration(seconds: 1));
        expect(countdown.remaining, const Duration(seconds: 1));
        expect(ticks, <int>[2, 1]);
      });
    });

    test('stops at zero, fires onComplete once and never ticks again', () {
      fakeAsync((FakeAsync async) {
        final List<int> ticks = <int>[];
        int completions = 0;
        final CaseCountdown countdown = CaseCountdown(
          duration: const Duration(seconds: 2),
          onTick: (Duration remaining) => ticks.add(remaining.inSeconds),
          onComplete: () => completions++,
        );

        countdown.start();
        async.elapse(const Duration(seconds: 2));

        expect(completions, 1);
        expect(countdown.remaining, Duration.zero);
        expect(countdown.isRunning, isFalse);
        expect(ticks, <int>[1]);

        async.elapse(const Duration(seconds: 5));
        expect(completions, 1);
        expect(ticks, <int>[1]);
      });
    });

    test('starting while running is a no-op and never duplicates the timer', () {
      fakeAsync((FakeAsync async) {
        int completions = 0;
        final CaseCountdown countdown = CaseCountdown(
          duration: const Duration(seconds: 3),
          onComplete: () => completions++,
        );

        countdown.start();
        countdown.start();
        countdown.start();

        async.elapse(const Duration(seconds: 3));
        expect(countdown.remaining, Duration.zero);
        expect(completions, 1);
      });
    });

    test('stop halts the countdown and is idempotent', () {
      fakeAsync((FakeAsync async) {
        int completions = 0;
        final CaseCountdown countdown = CaseCountdown(
          duration: const Duration(seconds: 10),
          onComplete: () => completions++,
        );

        countdown.start();
        async.elapse(const Duration(seconds: 4));
        countdown.stop();
        countdown.stop();

        expect(countdown.remaining, const Duration(seconds: 6));
        expect(countdown.isRunning, isFalse);

        async.elapse(const Duration(seconds: 20));
        expect(countdown.remaining, const Duration(seconds: 6));
        expect(completions, 0);
      });
    });

    test('dispose cancels the timer without further callbacks', () {
      fakeAsync((FakeAsync async) {
        int completions = 0;
        final CaseCountdown countdown = CaseCountdown(
          duration: const Duration(seconds: 5),
          onComplete: () => completions++,
        );

        countdown.start();
        async.elapse(const Duration(seconds: 2));
        countdown.dispose();
        async.elapse(const Duration(seconds: 20));

        expect(countdown.isRunning, isFalse);
        expect(completions, 0);
      });
    });

    test('finished countdown can be started again from its duration', () {
      fakeAsync((FakeAsync async) {
        int completions = 0;
        final CaseCountdown countdown = CaseCountdown(
          duration: const Duration(seconds: 2),
          onComplete: () => completions++,
        );

        countdown.start();
        async.elapse(const Duration(seconds: 2));
        expect(completions, 1);

        countdown.start();
        expect(countdown.remaining, const Duration(seconds: 2));
        async.elapse(const Duration(seconds: 2));
        expect(completions, 2);
      });
    });
  });

  group('CaseCountdown.format', () {
    test('renders mm:ss with zero padding', () {
      expect(CaseCountdown.format(Duration.zero), '00:00');
      expect(CaseCountdown.format(const Duration(seconds: 47)), '00:47');
      expect(CaseCountdown.format(const Duration(seconds: 60)), '01:00');
      expect(CaseCountdown.format(const Duration(seconds: 95)), '01:35');
      expect(CaseCountdown.format(const Duration(seconds: 3599)), '59:59');
    });

    test('clamps negative durations to zero', () {
      expect(
        CaseCountdown.format(const Duration(seconds: -5)),
        '00:00',
      );
    });
  });
}