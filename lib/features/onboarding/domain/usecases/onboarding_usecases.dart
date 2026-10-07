import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../entities/profile_details.dart';
import '../entities/style_quiz.dart';
import '../failures/onboarding_failure.dart';
import '../repositories/onboarding_repository.dart';

/// Saves the profile, then refreshes the signed-in user so the session sees
/// the new username.
class SaveProfile
    implements
        UseCase<Future<Either<OnboardingFailure, Unit>>, ProfileDetails> {
  const SaveProfile(this._onboarding, this._auth);

  final OnboardingRepository _onboarding;
  final AuthRepository _auth;

  @override
  Future<Either<OnboardingFailure, Unit>> call(ProfileDetails details) async {
    final result = await _onboarding.saveProfile(details);
    if (result.isRight()) await _auth.refreshCurrentUser();
    return result;
  }
}

class GetStyleQuiz
    implements UseCase<Future<Either<OnboardingFailure, StyleQuiz>>, NoParams> {
  const GetStyleQuiz(this._onboarding);

  final OnboardingRepository _onboarding;

  @override
  Future<Either<OnboardingFailure, StyleQuiz>> call(NoParams params) =>
      _onboarding.getStyleQuiz();
}

final class LikedOutfit extends Equatable {
  const LikedOutfit({required this.top, required this.bottom});

  final OutfitItem top;
  final OutfitItem bottom;

  @override
  List<Object?> get props => [top, bottom];
}

/// Finishes onboarding, then refreshes the user so routing moves to Home.
class CompleteStyleQuiz
    implements UseCase<Future<Either<OnboardingFailure, Unit>>, LikedOutfit> {
  const CompleteStyleQuiz(this._onboarding, this._auth);

  final OnboardingRepository _onboarding;
  final AuthRepository _auth;

  @override
  Future<Either<OnboardingFailure, Unit>> call(LikedOutfit outfit) async {
    final result = await _onboarding.completeOnboarding(
      top: outfit.top,
      bottom: outfit.bottom,
    );
    if (result.isLeft()) return result;
    return (await _auth.refreshCurrentUser()).match(
      (_) => const Left(OnboardingFailure(OnboardingFailureReason.unknown)),
      (_) => const Right(unit),
    );
  }
}
