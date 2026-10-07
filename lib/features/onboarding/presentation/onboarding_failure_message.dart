import '../../../core/l10n/l10n.dart';
import '../domain/failures/onboarding_failure.dart';

extension OnboardingFailureMessage on OnboardingFailure {
  String message(AppLocalizations l10n) => switch (reason) {
    OnboardingFailureReason.usernameTaken => l10n.errorUsernameTaken,
    OnboardingFailureReason.network => l10n.errorNetwork,
    OnboardingFailureReason.sessionExpired ||
    OnboardingFailureReason.unknown => l10n.errorUnknown,
  };
}
