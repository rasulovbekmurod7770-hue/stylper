import '../../../../core/error/failure.dart';

enum ProductFailureReason { notFound, network, unknown }

final class ProductFailure extends Failure {
  const ProductFailure(this.reason);

  final ProductFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
