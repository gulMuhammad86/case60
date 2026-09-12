import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:case60/app/app.dart';

void main() {
  testWidgets('CASE 60 app launches and shows the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: Case60App()));
    await tester.pumpAndSettle();

    expect(find.text('CASE 60'), findsOneWidget);
    expect(find.text("TODAY'S CASE"), findsOneWidget);
    expect(find.text('BEGIN INVESTIGATION'), findsOneWidget);
  });
}