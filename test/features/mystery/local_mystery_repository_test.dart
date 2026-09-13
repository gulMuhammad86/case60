import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/core/services/app_clock.dart';
import 'package:case60/features/mystery/application/daily_mystery_service.dart';
import 'package:case60/features/mystery/data/local_mystery_repository.dart';
import 'package:case60/features/mystery/domain/models/mystery.dart';
import 'package:case60/features/mystery/domain/mystery_exceptions.dart';

import 'mystery_test_data.dart';

void main() {
  const DailyMysteryService dailyService = DailyMysteryService();

  group('LocalMysteryRepository', () {
    test('loads all mysteries from the bundled JSON', () async {
      final LocalMysteryRepository repository = LocalMysteryRepository(
        assetBundle: _bundle(_twoMysterySource()),
        clock: _FakeClock(DateTime(2026, 1, 1)),
      );

      final List<Mystery> mysteries = await repository.getMysteries();

      expect(mysteries, hasLength(2));
      expect(mysteries.map((Mystery m) => m.id), <String>['first-case', 'second-case']);
    });

    test('returns a mystery by id and null for an unknown id', () async {
      final LocalMysteryRepository repository = LocalMysteryRepository(
        assetBundle: _bundle(_twoMysterySource()),
        clock: _FakeClock(DateTime(2026, 1, 1)),
      );

      final Mystery? found = await repository.getMysteryById('second-case');
      final Mystery? missing = await repository.getMysteryById('does-not-exist');

      expect(found, isNotNull);
      expect(found!.title, 'Second Case');
      expect(missing, isNull);
    });

    test('caches the parsed list across calls', () async {
      final _FakeAssetBundle bundle = _bundle(_twoMysterySource());
      final LocalMysteryRepository repository = LocalMysteryRepository(
        assetBundle: bundle,
        clock: _FakeClock(DateTime(2026, 1, 1)),
      );

      await repository.getMysteries();
      await repository.getMysteries();

      expect(bundle.loadCalls, 1);
    });

    test('today\'s mystery for the supplied date matches the daily service', () async {
      final LocalMysteryRepository repository = LocalMysteryRepository(
        assetBundle: _bundle(_twoMysterySource()),
        clock: _FakeClock(DateTime(2026, 1, 1)),
      );

      final DateTime date = DateTime(2027, 4, 18);
      final Mystery mystery = await repository.getTodayMystery(date: date);
      final List<Mystery> all = await repository.getMysteries();

      expect(
        mystery.id,
        dailyService.mysteryForDate(date, all).id,
      );
    });

    test('today\'s mystery defaults to the injected clock', () async {
      final DateTime clockDate = DateTime(2026, 9, 13);
      final LocalMysteryRepository repository = LocalMysteryRepository(
        assetBundle: _bundle(_twoMysterySource()),
        clock: _FakeClock(clockDate),
      );

      final Mystery mystery = await repository.getTodayMystery();
      final List<Mystery> all = await repository.getMysteries();

      expect(
        mystery.id,
        dailyService.mysteryForDate(clockDate, all).id,
      );
    });

    test('throws MysteryDataException when the asset is missing', () async {
      final LocalMysteryRepository repository = LocalMysteryRepository(
        assetBundle: _FakeAssetBundle(const <String, String>{}),
        clock: _FakeClock(DateTime(2026, 1, 1)),
      );

      expect(
        () => repository.getMysteries(),
        throwsA(isA<MysteryDataException>()),
      );
    });

    test('propagates validation failures from the JSON source', () async {
      final LocalMysteryRepository repository = LocalMysteryRepository(
        assetBundle: _bundle('{"mysteries": [{"id": ""}]}'),
        clock: _FakeClock(DateTime(2026, 1, 1)),
      );

      expect(
        () => repository.getMysteries(),
        throwsA(isA<MysteryValidationException>()),
      );
    });
  });
}

String _twoMysterySource() {
  final Map<String, Object> first = mysteryJsonFixture()
    ..['id'] = 'first-case'
    ..['caseNumber'] = 1
    ..['title'] = 'First Case';
  final Map<String, Object> second = mysteryJsonFixture()
    ..['id'] = 'second-case'
    ..['caseNumber'] = 2
    ..['title'] = 'Second Case';
  return jsonEncode(<String, Object>{
    'mysteries': <Object>[first, second],
  });
}

_FakeAssetBundle _bundle(String source) {
  return _FakeAssetBundle(<String, String>{
    LocalMysteryRepository.defaultAssetPath: source,
  });
}

final class _FakeClock implements AppClock {
  _FakeClock(this.nowValue);

  final DateTime nowValue;

  @override
  DateTime now() => nowValue;
}

final class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._assets);

  final Map<String, String> _assets;
  int loadCalls = 0;

  @override
  Future<ByteData> load(String key) async {
    loadCalls += 1;
    final String? content = _assets[key];
    if (content == null) {
      throw FlutterError('Asset not found: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
  }
}