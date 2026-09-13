import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_clock.dart';
import '../../../core/storage/app_storage.dart';
import '../application/level_service.dart';
import '../application/streak_service.dart';
import '../domain/detective_profile.dart';

/// JSON codec for [DetectiveProfile], used both for persistence and tests.
final class DetectiveProfileCodec {
  const DetectiveProfileCodec();

  static const String storageKey = 'detective_profile.v1';

  String encode(DetectiveProfile profile) {
  return jsonEncode(<String, dynamic>{
    'totalXp': profile.totalXp,
    'streakDays': profile.streakDays,
    'lastCompletedDate': profile.lastCompletedDate,
    'casesSolved': profile.casesSolved,
    'casesFailed': profile.casesFailed,
    'bestTimeSeconds': profile.bestTimeSeconds,
    'totalTimeSeconds': profile.totalTimeSeconds,
  });
}

DetectiveProfile decode(String source) {
  final Map<String, dynamic> map;
  try {
    map = _asMap(jsonDecode(source));
  } on Object {
    return const DetectiveProfile();
  }
  return DetectiveProfile(
    totalXp: _asInt(map['totalXp']),
    streakDays: _asInt(map['streakDays']),
    lastCompletedDate: _asStringOrNull(map['lastCompletedDate']),
    casesSolved: _asInt(map['casesSolved']),
    casesFailed: _asInt(map['casesFailed']),
    bestTimeSeconds: _asIntOrNull(map['bestTimeSeconds']),
    totalTimeSeconds: _asInt(map['totalTimeSeconds']),
  );
}

  /// Reads and decodes the stored profile, or returns `null` when absent or
  /// malformed (a corrupt cache must never crash the app).
  Future<DetectiveProfile?> tryRead(AppStorage storage) async {
    final String? raw = await storage.readString(storageKey);
    if (raw == null) {
      return null;
    }
    try {
      return decode(raw);
    } on Object {
      return null;
    }
  }
}

/// Mutable, persistently written detective profile.
final class DetectiveProfileController extends Notifier<DetectiveProfile> {
  DetectiveProfileController({this.initial = const DetectiveProfile()});

  /// Starting snapshot (override in tests through `overrideWith`).
  final DetectiveProfile initial;

  @override
  DetectiveProfile build() => initial;

  /// Replaces the whole profile with [next] and persists it.
  void replace(DetectiveProfile next) {
    state = next;
    ref
        .read(appStorageProvider)
        .writeString(
          DetectiveProfileCodec.storageKey,
          const DetectiveProfileCodec().encode(next),
        );
  }
}

/// Single source of truth for the detective's progress.
final NotifierProvider<DetectiveProfileController, DetectiveProfile>
detectiveProfileProvider =
    NotifierProvider<DetectiveProfileController, DetectiveProfile>(
      DetectiveProfileController.new,
    );

/// The profile with level/rank/streak resolved for display.
final Provider<DetectiveStanding> detectiveStandingProvider =
    Provider<DetectiveStanding>((Ref ref) {
  final DetectiveProfile profile = ref.watch(detectiveProfileProvider);
  final LevelService levels = ref.watch(levelServiceProvider);
  final StreakService streaks = ref.watch(streakServiceProvider);
  final LevelProgress progress = levels.progressForXp(profile.totalXp);
  final int effectiveStreak = streaks.effectiveStreak(
    lastCompletedDate: profile.lastCompletedDate,
    storedDays: profile.streakDays,
    now: ref.watch(appClockProvider).now(),
  );
  return DetectiveStanding(
    profile: profile,
    level: progress.level,
    title: levels.titleForLevel(progress.level),
    xpIntoLevel: progress.xpIntoLevel,
    xpForNextLevel: progress.xpForNextLevel,
    streakDays: effectiveStreak,
  );
});

/// Whether today's case has already been solved (and is therefore locked).
final Provider<bool> caseLockedTodayProvider = Provider<bool>((Ref ref) {
  final DetectiveProfile profile = ref.watch(detectiveProfileProvider);
  final DateTime now = ref.watch(appClockProvider).now();
  return ref
      .watch(streakServiceProvider)
      .completedOn(profile.lastCompletedDate, now);
});

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return <String, dynamic>{};
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return 0;
}

int? _asIntOrNull(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

String? _asStringOrNull(Object? value) {
  if (value is String) {
    return value;
  }
  return null;
}