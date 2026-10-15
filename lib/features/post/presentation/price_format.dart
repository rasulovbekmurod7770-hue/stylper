import 'package:intl/intl.dart';

import '../domain/entities/post.dart';

/// Localized price, without decimals for whole amounts: `$89` (en),
/// `89 $` (ru).
String formatPrice(Money price, String locale) => NumberFormat.simpleCurrency(
  locale: locale,
  name: price.currency,
  decimalDigits: price.amount == price.amount.truncate() ? 0 : 2,
).format(price.amount);
