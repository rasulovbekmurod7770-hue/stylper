import '../../../../core/error/failure.dart';

enum ProfileFailureReason { notFound, signInRequired, network, unknown }

final class ProfileFailure extends Failure {
  const ProfileFailure(this.reason);

  final ProfileFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
