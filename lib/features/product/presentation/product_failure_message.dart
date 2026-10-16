import '../../../core/l10n/l10n.dart';
import '../domain/failures/product_failure.dart';

extension ProductFailureMessage on ProductFailure {
  String message(AppLocalizations l10n) => switch (reason) {
    ProductFailureReason.notFound => l10n.errorProductNotFound,
    ProductFailureReason.network => l10n.errorNetwork,
    ProductFailureReason.unknown => l10n.errorUnknown,
  };
}
