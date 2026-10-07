import '../../../../core/error/failure.dart';

enum OnboardingFailureReason { usernameTaken, network, sessionExpired, unknown }

final class OnboardingFailure extends Failure {
  const OnboardingFailure(this.reason);

  final OnboardingFailureReason reason;

  @override
  List<Object?> get props => [reason];
}
