import 'package:equatable/equatable.dart';

/// Base type for expected, recoverable errors that cross layer boundaries.
///
/// Repositories catch data-layer exceptions and return a [Failure] subtype
/// inside an `Either`; the presentation layer turns it into localized text.
abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}
