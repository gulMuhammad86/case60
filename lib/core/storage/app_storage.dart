import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal async key-value storage abstraction.
///
/// The concrete backend (shared_preferences, disk) is injected via Riverpod,
/// so feature code never depends on a specific persistence library. Feature
/// code serializes JSON itself and only moves primitives through these calls.
abstract interface class AppStorage {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
  Future<int?> readInt(String key);
  Future<void> writeInt(String key, int value);
  Future<bool?> readBool(String key);
  Future<void> writeBool(String key, bool value);
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
  Future<int?> readInt(String key) async => _intValue(_store[key]);

  @override
  Future<void> writeInt(String key, int value) async {
    _store[key] = value.toString();
  }

  @override
  Future<bool?> readBool(String key) async => _boolValue(_store[key]);

  @override
  Future<void> writeBool(String key, bool value) async {
    _store[key] = value.toString();
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  static int? _intValue(String? raw) {
    if (raw == null) {
      return null;
    }
    return int.tryParse(raw);
  }

  static bool? _boolValue(String? raw) {
    if (raw == null) {
      return null;
    }
    if (raw == 'true') {
      return true;
    }
    if (raw == 'false') {
      return false;
    }
    return null;
  }
}

/// [AppStorage] backed by [SharedPreferences] (localStorage on web, platform
/// prefs on mobile/desktop).
final class SharedPrefsAppStorage implements AppStorage {
  SharedPrefsAppStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> readString(String key) async => _prefs.getString(key);

  @override
  Future<void> writeString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<int?> readInt(String key) async => _prefs.getInt(key);

  @override
  Future<void> writeInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<bool?> readBool(String key) async => _prefs.getBool(key);

  @override
  Future<void> writeBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}

/// Root storage provider; override in tests or when a real backend lands.
final Provider<AppStorage> appStorageProvider = Provider<AppStorage>((_) {
  return InMemoryAppStorage();
});