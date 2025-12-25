import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scasa_flutter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:scasa_flutter_app/features/auth/providers/auth_provider.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('displays login form with email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify email field exists
      expect(find.byType(TextFormField), findsNWidgets(2));
      
      // Verify password field exists
      expect(find.text('Password'), findsOneWidget);
      
      // Verify login button exists
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Tap login button without entering email
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Email or mobile is required'), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Find password field
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'testpassword');
      
      // Find visibility toggle icon
      final toggleIcon = find.byIcon(Icons.visibility_off);
      expect(toggleIcon, findsOneWidget);
      
      // Tap to toggle visibility
      await tester.tap(toggleIcon);
      await tester.pump();
      
      // Should show visibility icon
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}

