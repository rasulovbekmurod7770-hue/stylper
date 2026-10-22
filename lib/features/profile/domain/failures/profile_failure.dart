import '../../../../core/error/failure.dart';

enum ProfileFailureReason {
  notFound,
  signInRequired,

  /// Edit Profile: the username is someone else's, a brand's or reserved.
  usernameTaken,
  network,
  unknown,
}

final class ProfileFailure extends Failure {
  const ProfileFailure(this.reason);

  final ProfileFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
