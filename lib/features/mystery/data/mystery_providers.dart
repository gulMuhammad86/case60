import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_clock.dart';
import '../application/daily_mystery_service.dart';
import '../domain/mystery_repository.dart';
import 'local_mystery_repository.dart';

final Provider<AssetBundle> mysteryAssetBundleProvider = Provider<AssetBundle>(
  (Ref ref) => rootBundle,
);

final Provider<MysteryRepository> mysteryRepositoryProvider =
    Provider<MysteryRepository>((Ref ref) {
  return LocalMysteryRepository(
    assetBundle: ref.watch(mysteryAssetBundleProvider),
    clock: ref.watch(appClockProvider),
  );
});

final Provider<DailyMysteryService> dailyMysteryServiceProvider =
    Provider<DailyMysteryService>((Ref ref) {
  return const DailyMysteryService();
});