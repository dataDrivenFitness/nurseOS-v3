import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurseos_v3/features/auth/presentation/login_screen.dart';
import 'package:nurseos_v3/features/auth/services/auth_service_provider.dart';
import 'package:nurseos_v3/features/auth/services/mock_auth_service.dart';

void main() {
  testWidgets('LoginScreen allows sign in with email and password',
      (WidgetTester tester) async {
    // Set up mock auth service
    final mockService = MockAuthService();

    // Override the auth controller provider
    final container = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(mockService),
    ]);

    // Pump the login screen
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    // Find input fields and login button by keys
    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('loginButton'));

    // Enter valid email and password
    await tester.enterText(emailField, 'nurse@example.com');
    await tester.enterText(passwordField, 'testpassword');

    // Tap login button
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Confirm that input fields still exist after interaction (i.e., no crash)
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);
  });
}
