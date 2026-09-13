import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../domain/history_entry.dart';

/// JSON codec for a list of [HistoryEntry] (newest first), used for
/// persistence and tests.
final class HistoryCodec {
  const HistoryCodec();

  static const String storageKey = 'history.v1';

  String encode(List<HistoryEntry> entries) {
    final List<Map<String, dynamic>> items = <Map<String, dynamic>>[
      for (final HistoryEntry entry in entries)
        <String, dynamic>{
          'caseNumber': entry.caseNumber,
          'completedAt': entry.completedAt.toIso8601String(),
          'solved': entry.solved,
          'timeSeconds': entry.timeSeconds,
          'xpEarned': entry.xpEarned,
        },
    ];
    return jsonEncode(items);
  }

  List<HistoryEntry> decode(String source) {
    final Object? decoded = _tryJsonDecode(source);
    if (decoded is! List<dynamic>) {
      return <HistoryEntry>[];
    }
    final List<HistoryEntry> entries = <HistoryEntry>[];
    for (final Object? item in decoded) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      entries.add(_entryFromMap(item));
    }
    return entries;
  }

  /// Reads and decodes the stored history, or returns `null` when absent or
  /// malformed (a corrupt cache must never crash the app).
  Future<List<HistoryEntry>?> tryRead(AppStorage storage) async {
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

  static HistoryEntry _entryFromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      caseNumber: (map['caseNumber'] as num?)?.toInt() ?? 0,
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      solved: map['solved'] == true,
      timeSeconds: (map['timeSeconds'] as num?)?.toInt() ?? 0,
      xpEarned: (map['xpEarned'] as num?)?.toInt() ?? 0,
    );
  }

  static Object? _tryJsonDecode(String source) {
    try {
      return jsonDecode(source);
    } on Object {
      return null;
    }
  }
}

/// Mutable, persistently written case history (newest first).
final class HistoryController extends Notifier<List<HistoryEntry>> {
  HistoryController({this.initial = const <HistoryEntry>[]});

  /// Starting snapshot (override in tests through `overrideWith`).
  final List<HistoryEntry> initial;

  @override
  List<HistoryEntry> build() => List<HistoryEntry>.unmodifiable(initial);

  /// Prepends [entry] and persists the list.
  void add(HistoryEntry entry) {
    state = List<HistoryEntry>.unmodifiable(<HistoryEntry>[entry, ...state]);
    ref
        .read(appStorageProvider)
        .writeString(HistoryCodec.storageKey, const HistoryCodec().encode(state));
  }

  /// Replaces the whole history and persists it.
  void replaceAll(List<HistoryEntry> entries) {
    state = List<HistoryEntry>.unmodifiable(entries);
    ref
        .read(appStorageProvider)
        .writeString(HistoryCodec.storageKey, const HistoryCodec().encode(state));
  }
}

/// Single source of truth for the case history (newest first).
final NotifierProvider<HistoryController, List<HistoryEntry>> historyProvider =
    NotifierProvider<HistoryController, List<HistoryEntry>>(
      HistoryController.new,
    );