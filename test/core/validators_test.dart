import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/core/validation/validators.dart';

void main() {
  group('email', () {
    test('accepts a normal address, ignoring surrounding spaces', () {
      expect(Validators.email('  developer@stylper.ai '), isNull);
    });

    test('rejects empty and malformed input', () {
      expect(Validators.email(''), ValidationError.required);
      expect(Validators.email('developer@'), ValidationError.invalidEmail);
      expect(Validators.email('dev stylper.ai'), ValidationError.invalidEmail);
    });
  });

  group('passwords', () {
    test('new password needs the minimum length', () {
      expect(Validators.newPassword('short'), ValidationError.passwordTooShort);
      expect(Validators.newPassword('long enough'), isNull);
    });

    test('confirmation must match', () {
      expect(
        Validators.confirmPassword('stylper123', 'stylper124'),
        ValidationError.passwordsMismatch,
      );
      expect(Validators.confirmPassword('stylper123', 'stylper123'), isNull);
    });
  });

  group('username', () {
    test('normalizes a leading @ and case', () {
      expect(Validators.normalizeUsername(' @Katty_Miller '), 'katty_miller');
      expect(Validators.username('@Katty_Miller'), isNull);
    });

    test('rejects too short or invalid characters', () {
      expect(Validators.username('@ab'), ValidationError.invalidUsername);
      expect(
        Validators.username('katty-miller'),
        ValidationError.invalidUsername,
      );
      expect(Validators.username('@'), ValidationError.required);
    });
  });

  test('optional number range allows empty and checks bounds', () {
    expect(Validators.optionalIntInRange('', 13, 100), isNull);
    expect(Validators.optionalIntInRange('24', 13, 100), isNull);
    expect(
      Validators.optionalIntInRange('9', 13, 100),
      ValidationError.outOfRange,
    );
    expect(
      Validators.optionalIntInRange('abc', 13, 100),
      ValidationError.outOfRange,
    );
  });
}
