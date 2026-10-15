import '../../../core/l10n/l10n.dart';
import '../domain/failures/post_failure.dart';

extension PostFailureMessage on PostFailure {
  String message(AppLocalizations l10n) => switch (reason) {
    PostFailureReason.notFound => l10n.errorPostNotFound,
    PostFailureReason.signInRequired => l10n.signInToInteract,
    PostFailureReason.network => l10n.errorNetwork,
    PostFailureReason.unknown => l10n.errorUnknown,
  };
}
