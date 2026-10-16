import '../../../core/l10n/l10n.dart';
import '../domain/failures/wardrobe_failure.dart';

extension WardrobeFailureMessage on WardrobeFailure {
  String message(AppLocalizations l10n) => switch (reason) {
    WardrobeFailureReason.signInRequired => l10n.signInToInteract,
    WardrobeFailureReason.network => l10n.errorNetwork,
    WardrobeFailureReason.notFound => l10n.errorProductNotFound,
    WardrobeFailureReason.unknown => l10n.errorUnknown,
  };
}
