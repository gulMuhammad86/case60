import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/core/storage/app_storage.dart';
import 'package:case60/features/history/data/history_provider.dart';
import 'package:case60/features/history/domain/history_entry.dart';

void main() {
  group('HistoryCodec', () {
    test('round-trips entries preserving order and fields', () {
      final List<HistoryEntry> entries = <HistoryEntry>[
        HistoryEntry(
          caseNumber: 42,
          completedAt: DateTime(2026, 9, 13, 12, 0),
          solved: true,
          timeSeconds: 37,
          xpEarned: 100,
        ),
        HistoryEntry(
          caseNumber: 41,
          completedAt: DateTime(2026, 9, 12, 9, 30),
          solved: false,
          timeSeconds: 60,
          xpEarned: 0,
        ),
      ];

      final List<HistoryEntry> restored = const HistoryCodec().decode(
        const HistoryCodec().encode(entries),
      );
      expect(restored, hasLength(2));
      expect(restored[0].caseNumber, 42);
      expect(restored[0].solved, isTrue);
      expect(restored[0].timeSeconds, 37);
      expect(restored[0].xpEarned, 100);
      expect(restored[0].completedAt, DateTime(2026, 9, 13, 12, 0));
      expect(restored[1].caseNumber, 41);
      expect(restored[1].solved, isFalse);
    });

    test('malformed input decodes to an empty list', () {
      expect(const HistoryCodec().decode('not json'), isEmpty);
      expect(const HistoryCodec().decode('{"nested":1}'), isEmpty);
    });
  });

  group('HistoryCodec.tryRead', () {
    test('returns null when nothing is stored', () async {
      expect(await const HistoryCodec().tryRead(InMemoryAppStorage()), isNull);
    });

    test('returns an empty list for corrupt data instead of throwing',
        () async {
      final InMemoryAppStorage storage = InMemoryAppStorage();
      await storage.writeString(HistoryCodec.storageKey, 'garbage');
      expect(await const HistoryCodec().tryRead(storage), isEmpty);
    });
  });

  group('HistoryController', () {
    test('starts from the injected initial list', () {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          historyProvider.overrideWith(
            () => HistoryController(initial: <HistoryEntry>[
              HistoryEntry(
                caseNumber: 1,
                completedAt: DateTime(2026, 1, 1),
                solved: true,
                timeSeconds: 10,
                xpEarned: 5,
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(historyProvider), hasLength(1));
    });

    test('add prepends newest-first and persists', () async {
      final InMemoryAppStorage storage = InMemoryAppStorage();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          appStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      container.read(historyProvider.notifier).add(
            HistoryEntry(
              caseNumber: 42,
              completedAt: DateTime(2026, 9, 13),
              solved: true,
              timeSeconds: 37,
              xpEarned: 100,
            ),
          );
      container.read(historyProvider.notifier).add(
            HistoryEntry(
              caseNumber: 41,
              completedAt: DateTime(2026, 9, 12),
              solved: false,
              timeSeconds: 60,
              xpEarned: 0,
            ),
          );

      final List<HistoryEntry> state = container.read(historyProvider);
      expect(state.map((HistoryEntry e) => e.caseNumber).toList(), <int>[41, 42]);

      final String? raw = await storage.readString(HistoryCodec.storageKey);
      final List<HistoryEntry> restored = const HistoryCodec().decode(raw!);
      expect(restored.map((HistoryEntry e) => e.caseNumber).toList(), <int>[
        41,
        42,
      ]);
    });
  });
}