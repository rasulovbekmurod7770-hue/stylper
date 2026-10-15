import '../../../core/l10n/l10n.dart';
import '../domain/failures/home_failure.dart';

extension HomeFailureMessage on HomeFailure {
  String message(AppLocalizations l10n) => switch (reason) {
    HomeFailureReason.network => l10n.errorNetwork,
    HomeFailureReason.unknown => l10n.errorUnknown,
  };
}
