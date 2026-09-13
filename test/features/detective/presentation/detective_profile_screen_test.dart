import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/core/services/app_clock.dart';
import 'package:case60/features/detective/presentation/detective_profile_screen.dart';
import 'package:case60/features/player/data/detective_profile_provider.dart';
import 'package:case60/features/player/domain/detective_profile.dart';

void main() {
  testWidgets('a fresh detective shows the starting rank and zeroed stats', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildApp());

    expect(find.text('DETECTIVE PROFILE'), findsOneWidget);
    expect(find.text('ROOKIE'), findsOneWidget);
    expect(find.text('LEVEL 1'), findsOneWidget);
    expect(find.text('0 / 300'), findsOneWidget);
    expect(find.text('0 DAY STREAK'), findsOneWidget);
    expect(find.text('CASES SOLVED'), findsOneWidget);
    expect(find.text('CASES FAILED'), findsOneWidget);
    expect(find.text('BEST TIME'), findsOneWidget);
    expect(find.text('AVERAGE TIME'), findsOneWidget);
  });

  testWidgets('a seasoned detective shows rank, streak and statistics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        initial: const DetectiveProfile(
          totalXp: 1240,
          streakDays: 12,
          lastCompletedDate: '2026-09-13',
          casesSolved: 42,
          casesFailed: 8,
          bestTimeSeconds: 18,
          totalTimeSeconds: 2050,
        ),
      ),
    );

    // 1240 XP → Inspector (750..1400), 490 into a 650-XP band.
    expect(find.text('INSPECTOR'), findsOneWidget);
    expect(find.text('LEVEL 3'), findsOneWidget);
    expect(find.text('490 / 650'), findsOneWidget);
    expect(find.text('12 DAY STREAK'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('18 sec'), findsOneWidget);
    expect(find.text('41 sec'), findsOneWidget);
  });
}

Widget _buildApp({DetectiveProfile initial = const DetectiveProfile()}) {
  return ProviderScope(
    overrides: [
      appClockProvider.overrideWithValue(
        FixedAppClock(DateTime(2026, 9, 13, 12, 0)),
      ),
      detectiveProfileProvider.overrideWith(
        () => DetectiveProfileController(initial: initial),
      ),
    ],
    child: const MaterialApp(home: DetectiveProfileScreen()),
  );
}

final class FixedAppClock implements AppClock {
  const FixedAppClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}