import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scasa_flutter_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('complete login flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify login screen is displayed
      expect(find.text('Sign In'), findsOneWidget);

      // Enter email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'happyvalleyadmin@scasa.pro');
      await tester.pump();

      // Enter password
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'HPAdmin@123');
      await tester.pump();

      // Tap login button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify navigation to dashboard (or handle based on actual flow)
      // This test may need adjustment based on actual app behavior
    });
  });
}

