import '../../../../core/error/failure.dart';

enum HomeFailureReason { network, unknown }

final class HomeFailure extends Failure {
  const HomeFailure(this.reason);

  final HomeFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
