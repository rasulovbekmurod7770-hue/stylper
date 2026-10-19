import '../../../core/l10n/l10n.dart';
import '../domain/failures/search_failure.dart';

extension SearchFailureMessage on SearchFailure {
  String message(AppLocalizations l10n) => switch (reason) {
    SearchFailureReason.network => l10n.errorNetwork,
    SearchFailureReason.unknown => l10n.errorUnknown,
  };
}
