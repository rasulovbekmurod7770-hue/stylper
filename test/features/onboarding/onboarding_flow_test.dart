import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/core/usecase/usecase.dart';
import 'package:stylper/features/auth/data/datasources/fake_auth_remote_data_source.dart';
import 'package:stylper/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:stylper/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:stylper/features/onboarding/data/datasources/style_quiz_local_data_source.dart';
import 'package:stylper/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:stylper/features/onboarding/domain/entities/profile_details.dart';
import 'package:stylper/features/onboarding/domain/failures/onboarding_failure.dart';
import 'package:stylper/features/onboarding/domain/usecases/onboarding_usecases.dart';

/// Sign up → profile setup → style quiz, through the real use cases,
/// repositories and the shared fake backend.
void main() {
  late AuthRepositoryImpl auth;
  late SaveProfile saveProfile;
  late GetStyleQuiz getStyleQuiz;
  late CompleteStyleQuiz completeStyleQuiz;

  setUp(() async {
    final backend = FakeBackend(latency: Duration.zero);
    final tokens = InMemoryAuthTokenStore();
    auth = AuthRepositoryImpl(
      remote: FakeAuthRemoteDataSource(backend),
      tokenStore: tokens,
    );
    final onboarding = OnboardingRepositoryImpl(
      remote: FakeOnboardingRemoteDataSource(backend, tokens),
      quizLocal: const StyleQuizLocalDataSource(),
    );
    saveProfile = SaveProfile(onboarding, auth);
    getStyleQuiz = GetStyleQuiz(onboarding);
    completeStyleQuiz = CompleteStyleQuiz(onboarding, auth);

    await auth.signUpWithEmail(email: 'new@stylper.ai', password: 'stylper123');
  });

  test('a username that belongs to someone else is rejected', () async {
    final result = await saveProfile(
      const ProfileDetails(username: 'katty_miller', gender: Gender.female),
    );
    expect(
      result.getLeft().toNullable()?.reason,
      OnboardingFailureReason.usernameTaken,
    );
    expect(auth.currentUser!.hasProfile, isFalse);
  });

  test('saving the profile updates the signed-in user', () async {
    final result = await saveProfile(
      const ProfileDetails(
        username: 'new_user',
        gender: Gender.male,
        age: 24,
        heightCm: 180,
        weightKg: 72,
      ),
    );
    expect(result.isRight(), isTrue);
    expect(auth.currentUser!.username, 'new_user');
    expect(auth.currentUser!.onboardingCompleted, isFalse);
  });

  test('liking an outfit completes onboarding', () async {
    final quiz = (await getStyleQuiz(const NoParams()))
        .getOrElse((_) => throw StateError('expected a quiz'));
    expect(quiz.tops, isNotEmpty);
    expect(quiz.bottoms, isNotEmpty);

    final result = await completeStyleQuiz(
      LikedOutfit(top: quiz.tops.first, bottom: quiz.bottoms.first),
    );

    expect(result.isRight(), isTrue);
    expect(auth.currentUser!.onboardingCompleted, isTrue);
  });
}
