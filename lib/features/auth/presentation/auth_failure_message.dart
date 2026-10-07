import '../../../core/l10n/l10n.dart';
import '../domain/failures/auth_failure.dart';

extension AuthFailureMessage on AuthFailure {
  String message(AppLocalizations l10n) => switch (reason) {
    AuthFailureReason.invalidCredentials => l10n.errorInvalidCredentials,
    AuthFailureReason.emailAlreadyInUse => l10n.errorEmailInUse,
    AuthFailureReason.weakPassword => l10n.errorWeakPassword,
    AuthFailureReason.userDisabled => l10n.errorUserDisabled,
    AuthFailureReason.tooManyRequests => l10n.errorTooManyRequests,
    AuthFailureReason.network => l10n.errorNetwork,
    AuthFailureReason.providerUnavailable => l10n.errorProviderUnavailable,
    AuthFailureReason.cancelled ||
    AuthFailureReason.unknown => l10n.errorUnknown,
  };
}
