import 'package:equatable/equatable.dart';

/// A single application action. [Output] is usually a
/// `Future<Either<SomeFailure, T>>` or a `Stream<T>`.
abstract interface class UseCase<Output, Params> {
  Output call(Params params);
}

final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
