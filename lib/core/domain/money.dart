import 'package:equatable/equatable.dart';

/// The app's currency: Uzbek soʻm. Every price on Stylper is in soʻm.
const appCurrency = 'UZS';

class Money extends Equatable {
  const Money({required this.amount, required this.currency});

  final num amount;

  /// ISO 4217 code: [appCurrency].
  final String currency;

  @override
  List<Object?> get props => [amount, currency];
}
