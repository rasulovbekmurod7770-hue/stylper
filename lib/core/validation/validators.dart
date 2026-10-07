enum ValidationError {
  required,
  invalidEmail,
  passwordTooShort,
  passwordsMismatch,
  invalidUsername,
  outOfRange,
  notSelected,
  termsNotAccepted,
}

/// Input rules shared by the auth and onboarding features.
abstract final class Validators {
  static const minPasswordLength = 8;

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final _username = RegExp(r'^[a-z0-9_.]{3,20}$');

  static ValidationError? email(String value) {
    final email = value.trim();
    if (email.isEmpty) return ValidationError.required;
    if (!_email.hasMatch(email)) return ValidationError.invalidEmail;
    return null;
  }

  /// Sign-in only checks presence; length rules apply when creating a password.
  static ValidationError? existingPassword(String value) =>
      value.isEmpty ? ValidationError.required : null;

  static ValidationError? newPassword(String value) {
    if (value.isEmpty) return ValidationError.required;
    if (value.length < minPasswordLength) {
      return ValidationError.passwordTooShort;
    }
    return null;
  }

  static ValidationError? confirmPassword(
    String password,
    String confirmation,
  ) {
    if (confirmation.isEmpty) return ValidationError.required;
    if (password != confirmation) return ValidationError.passwordsMismatch;
    return null;
  }

  /// Strips a leading `@` and lowercases, so `@Katty_Miller` → `katty_miller`.
  static String normalizeUsername(String value) {
    final trimmed = value.trim();
    return (trimmed.startsWith('@') ? trimmed.substring(1) : trimmed)
        .toLowerCase();
  }

  static ValidationError? username(String value) {
    final username = normalizeUsername(value);
    if (username.isEmpty) return ValidationError.required;
    if (!_username.hasMatch(username)) return ValidationError.invalidUsername;
    return null;
  }

  /// Empty input is allowed; anything else must be a whole number in range.
  static ValidationError? optionalIntInRange(String value, int min, int max) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final number = int.tryParse(text);
    if (number == null || number < min || number > max) {
      return ValidationError.outOfRange;
    }
    return null;
  }
}
