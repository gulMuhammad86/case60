import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal async key-value storage abstraction.
///
/// The concrete backend (shared_preferences, disk) is injected via Riverpod,
/// so feature code never depends on a specific persistence library.
abstract interface class AppStorage {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Default in-memory implementation used until a real backend is wired in.
final class InMemoryAppStorage implements AppStorage {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<String?> readString(String key) async => _store[key];

  @override
  Future<void> writeString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}

/// Root storage provider; override in tests or when a real backend lands.
final Provider<AppStorage> appStorageProvider = Provider<AppStorage>((_) {
  return InMemoryAppStorage();
});