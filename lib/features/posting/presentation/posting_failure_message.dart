import '../../../core/l10n/l10n.dart';
import '../domain/failures/posting_failure.dart';

extension PostingFailureMessage on PostingFailure {
  String message(AppLocalizations l10n) => switch (reason) {
    PostingFailureReason.signInRequired => l10n.signInToInteract,
    PostingFailureReason.invalid => l10n.errorPublishInvalid,
    PostingFailureReason.network => l10n.errorNetwork,
    PostingFailureReason.unknown => l10n.errorUnknown,
  };
}
