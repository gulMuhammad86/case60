import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/core/services/app_clock.dart';
import 'package:case60/core/storage/app_storage.dart';
import 'package:case60/features/player/data/detective_profile_provider.dart';
import 'package:case60/features/player/domain/detective_profile.dart';

void main() {
  final DateTime now = DateTime(2026, 9, 13, 12, 0);

  ProviderContainer buildContainer({
    DetectiveProfile initial = const DetectiveProfile(),
    AppStorage? storage,
  }) {
    return ProviderContainer(
      overrides: [
        appClockProvider.overrideWithValue(FixedAppClock(now)),
        appStorageProvider.overrideWithValue(storage ?? InMemoryAppStorage()),
        detectiveProfileProvider.overrideWith(
          () => DetectiveProfileController(initial: initial),
        ),
      ],
    );
  }

  group('DetectiveProfileCodec', () {
    test('round-trips every field', () {
      const DetectiveProfile profile = DetectiveProfile(
        totalXp: 1240,
        streakDays: 12,
        lastCompletedDate: '2026-09-13',
        casesSolved: 42,
        casesFailed: 8,
        bestTimeSeconds: 18,
        totalTimeSeconds: 2050,
      );
      final DetectiveProfile restored =
          const DetectiveProfileCodec().decode(
            const DetectiveProfileCodec().encode(profile),
          );
      expect(restored, profile);
    });

    test('missing or malformed input decodes to an empty profile', () {
      expect(const DetectiveProfileCodec().decode('not json').totalXp, 0);
    });
  });

  group('DetectiveProfileCodec.tryRead', () {
    test('returns null when nothing is stored', () async {
      final InMemoryAppStorage storage = InMemoryAppStorage();
      expect(await const DetectiveProfileCodec().tryRead(storage), isNull);
    });

    test('returns an empty profile for corrupt data instead of throwing',
        () async {
      final InMemoryAppStorage storage = InMemoryAppStorage();
      await storage.writeString(DetectiveProfileCodec.storageKey, 'garbage');
      final DetectiveProfile? restored =
          await const DetectiveProfileCodec().tryRead(storage);
      expect(restored, isNotNull);
      expect(restored!.totalXp, 0);
    });
  });

  group('DetectiveProfileController', () {
    test('starts from the injected initial snapshot', () {
      final ProviderContainer container = buildContainer(
        initial: const DetectiveProfile(totalXp: 500),
      );
      addTearDown(container.dispose);
      expect(container.read(detectiveProfileProvider).totalXp, 500);
    });

    test('replace updates state and persists a JSON snapshot', () async {
      final InMemoryAppStorage storage = InMemoryAppStorage();
      final ProviderContainer container = buildContainer(storage: storage);
      addTearDown(container.dispose);

      container.read(detectiveProfileProvider.notifier).replace(
            const DetectiveProfile(totalXp: 130, streakDays: 1),
          );

      final String? raw =
          await storage.readString(DetectiveProfileCodec.storageKey);
      expect(raw, isNotNull);
      final DetectiveProfile restored =
          const DetectiveProfileCodec().decode(raw!);
      expect(restored.totalXp, 130);
      expect(restored.streakDays, 1);
      expect(container.read(detectiveProfileProvider).totalXp, 130);
    });
  });

  group('detectiveStandingProvider', () {
    test('derives level, XP band and effective streak', () {
      final ProviderContainer container = buildContainer(
        initial: const DetectiveProfile(
          totalXp: 1240,
          streakDays: 12,
          lastCompletedDate: '2026-09-13',
        ),
      );
      addTearDown(container.dispose);

      final DetectiveStanding standing =
          container.read(detectiveStandingProvider);
      expect(standing.level, 3);
      expect(standing.title, 'Inspector');
      expect(standing.xpIntoLevel, 490);
      expect(standing.xpForNextLevel, 650);
      expect(standing.streakDays, 12);
    });

    test('a missed day collapses the displayed streak', () {
      final ProviderContainer container = buildContainer(
        initial: const DetectiveProfile(
          streakDays: 12,
          lastCompletedDate: '2026-09-10',
        ),
      );
      addTearDown(container.dispose);

      expect(container.read(detectiveStandingProvider).streakDays, 0);
    });

    test('a fresh detective sits on level one with no streak', () {
      final ProviderContainer container = buildContainer();
      addTearDown(container.dispose);

      final DetectiveStanding standing =
          container.read(detectiveStandingProvider);
      expect(standing.level, 1);
      expect(standing.title, 'Rookie');
      expect(standing.xpIntoLevel, 0);
      expect(standing.xpForNextLevel, 300);
      expect(standing.streakDays, 0);
    });
  });

  group('caseLockedTodayProvider', () {
    test('is true when today\'s case was solved', () {
      final ProviderContainer container = buildContainer(
        initial: const DetectiveProfile(lastCompletedDate: '2026-09-13'),
      );
      addTearDown(container.dispose);
      expect(container.read(caseLockedTodayProvider), isTrue);
    });

    test('is false when the last completion was yesterday', () {
      final ProviderContainer container = buildContainer(
        initial: const DetectiveProfile(lastCompletedDate: '2026-09-12'),
      );
      addTearDown(container.dispose);
      expect(container.read(caseLockedTodayProvider), isFalse);
    });

    test('is false for a fresh profile', () {
      final ProviderContainer container = buildContainer();
      addTearDown(container.dispose);
      expect(container.read(caseLockedTodayProvider), isFalse);
    });
  });
}

final class FixedAppClock implements AppClock {
  const FixedAppClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}