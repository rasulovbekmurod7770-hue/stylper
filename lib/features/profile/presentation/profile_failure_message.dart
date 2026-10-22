import '../../../core/l10n/l10n.dart';
import '../domain/failures/profile_failure.dart';

extension ProfileFailureMessage on ProfileFailure {
  String message(AppLocalizations l10n) => switch (reason) {
    ProfileFailureReason.notFound => l10n.errorProfileNotFound,
    ProfileFailureReason.signInRequired => l10n.signInToInteract,
    ProfileFailureReason.usernameTaken => l10n.errorUsernameTaken,
    ProfileFailureReason.network => l10n.errorNetwork,
    ProfileFailureReason.unknown => l10n.errorUnknown,
  };
}
