import 'package:equatable/equatable.dart';

class Money extends Equatable {
  const Money({required this.amount, required this.currency});

  final num amount;

  /// ISO 4217 code, e.g. `USD`, `UZS`.
  final String currency;

  @override
  List<Object?> get props => [amount, currency];
}
