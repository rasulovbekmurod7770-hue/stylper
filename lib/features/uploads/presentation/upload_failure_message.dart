import '../../../core/l10n/l10n.dart';
import '../domain/failures/upload_failure.dart';

extension UploadFailureMessage on UploadFailure {
  String message(AppLocalizations l10n) => switch (reason) {
    UploadFailureReason.unusablePhoto => l10n.errorPhotoUnusable,
    UploadFailureReason.tooManyUploads => l10n.errorTooManyRequests,
    UploadFailureReason.signInRequired => l10n.signInToInteract,
    UploadFailureReason.network => l10n.errorNetwork,
    UploadFailureReason.unknown => l10n.errorUnknown,
  };
}
