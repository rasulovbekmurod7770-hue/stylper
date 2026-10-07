import 'package:fpdart/fpdart.dart';

import '../entities/profile_details.dart';
import '../entities/style_quiz.dart';
import '../failures/onboarding_failure.dart';

abstract interface class OnboardingRepository {
  Future<Either<OnboardingFailure, Unit>> saveProfile(ProfileDetails details);

  Future<Either<OnboardingFailure, StyleQuiz>> getStyleQuiz();

  /// Records the outfit the user liked and marks onboarding as finished.
  Future<Either<OnboardingFailure, Unit>> completeOnboarding({
    required OutfitItem top,
    required OutfitItem bottom,
  });
}
