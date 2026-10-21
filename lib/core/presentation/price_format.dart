import 'package:intl/intl.dart';

import '../domain/money.dart';
import '../l10n/l10n.dart';

/// Localized price, without decimals for whole amounts. Soʻm, the app's
/// currency, reads `1 130 000 soʻm` (uz), `1 130 000 сум` (ru) or
/// `1,130,000 UZS` (en), never breaking inside the number; any other
/// currency shows its symbol, e.g. `$89`.
String formatPrice(Money price, AppLocalizations l10n) {
  final decimals = price.amount == price.amount.truncate() ? 0 : 2;
  if (price.currency == appCurrency) {
    return l10n.priceInSom(
      NumberFormat.decimalPatternDigits(
        locale: l10n.localeName,
        decimalDigits: decimals,
      ).format(price.amount),
    );
  }
  return NumberFormat.simpleCurrency(
    locale: l10n.localeName,
    name: price.currency,
    decimalDigits: decimals,
  ).format(price.amount);
}
