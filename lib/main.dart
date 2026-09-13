import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/storage/app_storage.dart';
import 'features/history/data/history_provider.dart';
import 'features/history/domain/history_entry.dart';
import 'features/player/data/detective_profile_provider.dart';
import 'features/player/domain/detective_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AppStorage storage = SharedPrefsAppStorage(prefs);

  final DetectiveProfile? storedProfile =
      await const DetectiveProfileCodec().tryRead(storage);
  final List<HistoryEntry>? storedHistory = await const HistoryCodec().tryRead(
    storage,
  );

  runApp(
    ProviderScope(
      overrides: [
        appStorageProvider.overrideWithValue(storage),
        detectiveProfileProvider.overrideWith(
          () => DetectiveProfileController(
            initial: storedProfile ?? const DetectiveProfile(),
          ),
        ),
        historyProvider.overrideWith(
          () => HistoryController(initial: storedHistory ?? const <HistoryEntry>[]),
        ),
      ],
      child: const Case60App(),
    ),
  );
}