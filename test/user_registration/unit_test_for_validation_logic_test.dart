import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/user_registration_form.dart';

void main() {
  group('Email Validation Tests', () {
    late UserRegistrationFormState formState;

    setUp(() {
      formState = UserRegistrationFormState();
    });

    test('Valid email addresses should pass validation', () {
      expect(formState.isValidEmail('user@example.com'), true);
      expect(formState.isValidEmail('test.user@example.com'), true);
      expect(formState.isValidEmail('user+tag@example.co.uk'), true);
      expect(formState.isValidEmail('user_name@example-domain.com'), true);
      expect(formState.isValidEmail('123@example.com'), true);
    });

    test('Invalid email addresses should fail validation', () {
      expect(formState.isValidEmail(''), false);
      expect(formState.isValidEmail('a@'), false);
      expect(formState.isValidEmail('@b'), false);
      expect(formState.isValidEmail('invalid'), false);
      expect(formState.isValidEmail('invalid@'), false);
      expect(formState.isValidEmail('@invalid.com'), false);
      expect(formState.isValidEmail('invalid@com'), false);
      expect(formState.isValidEmail('invalid@domain'), false);
      expect(formState.isValidEmail('invalid..email@example.com'), false);
      expect(formState.isValidEmail('invalid @example.com'), false);
    });

    test('Edge case email addresses', () {
      expect(formState.isValidEmail('user@domain.c'), false); // TLD too short
      expect(formState.isValidEmail('user@domain.co'), true);
      expect(formState.isValidEmail('a@b.co'), true);
    });
  });

  group('Password Validation Tests', () {
    late UserRegistrationFormState formState;

    setUp(() {
      formState = UserRegistrationFormState();
    });

    test('Valid strong passwords should pass validation', () {
      expect(formState.isValidPassword('Password123!'), true);
      expect(formState.isValidPassword('Str0ng@Pass'), true);
      expect(formState.isValidPassword('MyP@ssw0rd'), true);
      expect(formState.isValidPassword('C0mpl3x!Pass'), true);
      expect(formState.isValidPassword('Test123!@#'), true);
    });

    test('Passwords without minimum length should fail', () {
      expect(formState.isValidPassword('Pass1!'), false);
      expect(formState.isValidPassword('Aa1!'), false);
      expect(formState.isValidPassword(''), false);
    });

    test('Passwords without uppercase should fail', () {
      expect(formState.isValidPassword('password123!'), false);
      expect(formState.isValidPassword('mypass123!'), false);
    });

    test('Passwords without lowercase should fail', () {
      expect(formState.isValidPassword('PASSWORD123!'), false);
      expect(formState.isValidPassword('MYPASS123!'), false);
    });

    test('Passwords without numbers should fail', () {
      expect(formState.isValidPassword('Password!'), false);
      expect(formState.isValidPassword('MyPassword!'), false);
    });

    test('Passwords without special characters should fail', () {
      expect(formState.isValidPassword('Password123'), false);
      expect(formState.isValidPassword('MyPassword123'), false);
    });

    test('Passwords with only some requirements should fail', () {
      expect(formState.isValidPassword('12345678'), false); // Only numbers
      expect(formState.isValidPassword('abcdefgh'), false); // Only lowercase
      expect(formState.isValidPassword('ABCDEFGH'), false); // Only uppercase
      expect(
        formState.isValidPassword(r'!@#$%^&*'),
        false,
      ); // Only special chars

      expect(
        formState.isValidPassword('Password'),
        false,
      ); // No numbers or special
      expect(
        formState.isValidPassword('password123'),
        false,
      ); // No uppercase or special
    });
  });

  group('Password Strength Message Tests', () {
    late UserRegistrationFormState formState;

    setUp(() {
      formState = UserRegistrationFormState();
    });

    test('Strong password should return null', () {
      expect(formState.getPasswordStrengthMessage('Password123!'), null);
      expect(formState.getPasswordStrengthMessage('MyP@ssw0rd'), null);
    });

    test('Empty password should return null', () {
      expect(formState.getPasswordStrengthMessage(''), null);
    });

    test('Weak passwords should return appropriate messages', () {
      final shortMessage = formState.getPasswordStrengthMessage('Pass1!');
      expect(shortMessage, contains('at least 8 characters'));

      final noUpperMessage = formState.getPasswordStrengthMessage(
        'password123!',
      );
      expect(noUpperMessage, contains('an uppercase letter'));

      final noLowerMessage = formState.getPasswordStrengthMessage(
        'PASSWORD123!',
      );
      expect(noLowerMessage, contains('a lowercase letter'));

      final noNumberMessage = formState.getPasswordStrengthMessage('Password!');
      expect(noNumberMessage, contains('a number'));

      final noSpecialMessage = formState.getPasswordStrengthMessage(
        'Password123',
      );
      expect(noSpecialMessage, contains('a special character'));
    });

    test('Multiple missing requirements should be listed', () {
      final multipleMessage = formState.getPasswordStrengthMessage('pass');
      expect(multipleMessage, contains('at least 8 characters'));
      expect(multipleMessage, contains('an uppercase letter'));
      expect(multipleMessage, contains('a number'));
      expect(multipleMessage, contains('a special character'));
    });
  });
}
