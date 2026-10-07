import '../../../../core/error/failure.dart';

enum AuthFailureReason {
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  userDisabled,
  tooManyRequests,
  network,

  /// The social provider isn't configured yet (no OAuth client / backend endpoint).
  providerUnavailable,

  /// The user closed the social sign-in sheet; not shown as an error.
  cancelled,
  unknown,
}

final class AuthFailure extends Failure {
  const AuthFailure(this.reason);

  final AuthFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
