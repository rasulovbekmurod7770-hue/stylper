import '../validation/validators.dart';
import 'l10n.dart';

extension ValidationErrorMessage on ValidationError {
  /// [min] and [max] are only used by [ValidationError.outOfRange].
  String message(AppLocalizations l10n, {int min = 0, int max = 0}) =>
      switch (this) {
        ValidationError.required => l10n.validationRequired,
        ValidationError.invalidEmail => l10n.validationEmail,
        ValidationError.passwordTooShort => l10n.validationPasswordLength(
          Validators.minPasswordLength,
        ),
        ValidationError.passwordsMismatch => l10n.validationPasswordsMismatch,
        ValidationError.invalidUsername => l10n.validationUsername,
        ValidationError.outOfRange => l10n.validationNumberRange(min, max),
        ValidationError.notSelected => l10n.validationGender,
        ValidationError.termsNotAccepted => l10n.validationTerms,
      };
}
