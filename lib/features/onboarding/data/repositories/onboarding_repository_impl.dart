import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/profile_details.dart';
import '../../domain/entities/style_quiz.dart';
import '../../domain/failures/onboarding_failure.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_data_source.dart';
import '../datasources/style_quiz_local_data_source.dart';
import '../models/onboarding_models.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl({
    required this._remote,
    required this._quizLocal,
  });

  final OnboardingRemoteDataSource _remote;
  final StyleQuizLocalDataSource _quizLocal;

  @override
  Future<Either<OnboardingFailure, Unit>> saveProfile(ProfileDetails details) =>
      _guard(() => _remote.saveProfile(details.toJson()));

  @override
  Future<Either<OnboardingFailure, StyleQuiz>> getStyleQuiz() async {
    final items = _quizLocal.getItems().map((model) => model.toEntity());
    return Right(
      StyleQuiz(
        tops: [...items.where((i) => i.category == OutfitCategory.top)],
        bottoms: [...items.where((i) => i.category == OutfitCategory.bottom)],
      ),
    );
  }

  @override
  Future<Either<OnboardingFailure, Unit>> completeOnboarding({
    required OutfitItem top,
    required OutfitItem bottom,
  }) => _guard(
    () => _remote.completeOnboarding(topId: top.id, bottomId: bottom.id),
  );

  Future<Either<OnboardingFailure, Unit>> _guard(
    Future<void> Function() request,
  ) async {
    try {
      await request();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(
        OnboardingFailure(switch (e.code) {
          ApiErrorCodes.usernameTaken => OnboardingFailureReason.usernameTaken,
          ApiErrorCodes.unauthorized => OnboardingFailureReason.sessionExpired,
          _ => OnboardingFailureReason.unknown,
        }),
      );
    } on NetworkException {
      return const Left(OnboardingFailure(OnboardingFailureReason.network));
    }
  }
}
