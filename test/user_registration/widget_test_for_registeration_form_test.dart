import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/user_registration_form.dart';

void main() {
  group('User Registration Form Widget Tests', () {
    testWidgets('Form renders all required fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Check all fields are present
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('Name validation shows error for empty input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Tap register without entering name
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('Name validation shows error for short name', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Enter a single character name
      await tester.enterText(find.byType(TextFormField).at(0), 'A');
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('Email validation shows error for empty input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('Email validation shows error for invalid email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Test various invalid emails
      final invalidEmails = ['a@', '@b', 'invalid', 'invalid@'];

      for (final email in invalidEmails) {
        await tester.enterText(find.byType(TextFormField).at(1), email);
        await tester.tap(find.text('Register'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email address'), findsOneWidget);
      }
    });

    testWidgets('Email validation accepts valid email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsNothing);
    });

    testWidgets('Password validation shows error for empty input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('Password validation shows error for weak password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Enter a weak password
      await tester.enterText(find.byType(TextFormField).at(2), 'weak');
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Password must contain'), findsOneWidget);
    });

    testWidgets('Password validation accepts strong password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      await tester.enterText(
        find.byType(TextFormField).at(2),
        'StrongPass123!',
      );
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Should not show password strength error
      expect(find.textContaining('Password must contain'), findsNothing);
    });

    testWidgets(
      'Confirm password validation shows error when passwords do not match',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
        );

        await tester.enterText(
          find.byType(TextFormField).at(2),
          'StrongPass123!',
        );
        await tester.enterText(
          find.byType(TextFormField).at(3),
          'DifferentPass123!',
        );
        await tester.tap(find.text('Register'));
        await tester.pumpAndSettle();

        expect(find.text('Passwords do not match'), findsOneWidget);
      },
    );

    testWidgets('Confirm password validation passes when passwords match', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      await tester.enterText(
        find.byType(TextFormField).at(2),
        'StrongPass123!',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'StrongPass123!',
      );
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('Form shows loading indicator during submission', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Fill all fields with valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'StrongPass123!',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'StrongPass123!',
      );

      // Tap register
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Loading indicator should appear
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let the 2-second timer complete
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('Form shows success message after valid submission', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Fill all fields with valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'StrongPass123!',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'StrongPass123!',
      );

      // Tap register and wait for completion
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Registration successful!'), findsOneWidget);
    });

    testWidgets('Form shows error message when validation fails', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Tap register without filling fields
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Please fix the errors above'), findsOneWidget);
    });

    testWidgets('Register button is disabled during loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Fill all fields with valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'StrongPass123!',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'StrongPass123!',
      );

      // Tap register
      await tester.tap(find.text('Register'));
      await tester.pump(); // Allow setState to trigger UI rebuild

      // Button should be disabled (onPressed == null)
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      // (Optional) Wait for loading to finish
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('Password fields are obscured', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Find TextField widgets instead (TextFormField wraps TextField)
      final passwordFields = find.byType(TextField);

      // Check password field (index 2)
      final passwordField = tester.widget<TextField>(passwordFields.at(2));
      expect(passwordField.obscureText, true);

      // Check confirm password field (index 3)
      final confirmPasswordField = tester.widget<TextField>(
        passwordFields.at(3),
      );
      expect(confirmPasswordField.obscureText, true);
    });

    testWidgets('All validation errors show simultaneously', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Tap register without entering any data
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // All validation errors should be visible
      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });
  });
}
