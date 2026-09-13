import 'package:flutter/services.dart';

import '../../../core/services/app_clock.dart';
import '../application/daily_mystery_service.dart';
import '../domain/models/mystery.dart';
import '../domain/mystery_exceptions.dart';
import '../domain/mystery_repository.dart';
import 'mystery_json_codec.dart';

final class LocalMysteryRepository implements MysteryRepository {
  LocalMysteryRepository({
    AssetBundle? assetBundle,
    AppClock? clock,
    DailyMysteryService? dailyService,
    this.assetPath = defaultAssetPath,
  }) : _assetBundle = assetBundle ?? rootBundle,
       _clock = clock ?? const SystemAppClock(),
       _dailyService = dailyService ?? const DailyMysteryService();

  static const String defaultAssetPath = 'assets/data/mysteries.json';

  final AssetBundle _assetBundle;
  final AppClock _clock;
  final DailyMysteryService _dailyService;
  final String assetPath;

  List<Mystery>? _cache;

  @override
  Future<List<Mystery>> getMysteries() async {
    final List<Mystery>? cached = _cache;
    if (cached != null) {
      return cached;
    }

    final String source;
    try {
      source = await _assetBundle.loadString(assetPath);
    } on Object catch (error) {
      throw MysteryDataException(
        'Could not load the mystery asset at "$assetPath".',
        cause: error,
      );
    }

    final List<Mystery> mysteries = const MysteryJsonCodec().decode(source);
    _cache = List.unmodifiable(mysteries);
    return _cache!;
  }

  @override
  Future<Mystery?> getMysteryById(String id) async {
    final List<Mystery> mysteries = await getMysteries();
    for (final Mystery mystery in mysteries) {
      if (mystery.id == id) {
        return mystery;
      }
    }
    return null;
  }

  @override
  Future<Mystery> getTodayMystery({DateTime? date}) async {
    final List<Mystery> mysteries = await getMysteries();
    return _dailyService.mysteryForDate(date ?? _clock.now(), mysteries);
  }
}