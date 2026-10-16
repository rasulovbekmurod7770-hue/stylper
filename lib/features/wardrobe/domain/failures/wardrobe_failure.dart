import '../../../../core/error/failure.dart';

enum WardrobeFailureReason { signInRequired, notFound, network, unknown }

final class WardrobeFailure extends Failure {
  const WardrobeFailure(this.reason);

  final WardrobeFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
