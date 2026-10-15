import 'package:get_it/get_it.dart';

import '../../core/fake_backend/fake_backend.dart';
import '../../core/network/auth_token_store.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/fake_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/email_auth.dart';
import '../../features/auth/domain/usecases/session.dart';
import '../../features/auth/domain/usecases/social_auth.dart';
import '../../features/auth/presentation/cubits/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubits/sign_in_cubit.dart';
import '../../features/auth/presentation/cubits/sign_up_cubit.dart';
import '../../features/auth/presentation/cubits/social_sign_in_cubit.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_feed.dart';
import '../../features/home/presentation/cubits/home_feed_cubit.dart';
import '../../features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import '../../features/onboarding/data/datasources/style_quiz_local_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/onboarding_usecases.dart';
import '../../features/onboarding/presentation/cubits/profile_setup_cubit.dart';
import '../../features/onboarding/presentation/cubits/style_quiz_cubit.dart';
import '../session/session_cubit.dart';

final sl = GetIt.instance;

/// [backend] lets tests inject a [FakeBackend] without simulated latency.
void configureDependencies({FakeBackend? backend}) {
  // Infrastructure
  sl
    ..registerLazySingleton<AuthTokenStore>(InMemoryAuthTokenStore.new)
    // ── Backend ────────────────────────────────────────────────────────────
    // Until the Stylper API exists, remote data sources talk to an in-memory
    // FakeBackend. When it's ready, register HTTP implementations of
    // AuthRemoteDataSource, OnboardingRemoteDataSource and HomeRemoteDataSource
    // here instead;
    // nothing outside this block needs to change.
    ..registerLazySingleton(() => backend ?? FakeBackend())
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => FakeAuthRemoteDataSource(sl()),
    )
    ..registerLazySingleton<OnboardingRemoteDataSource>(
      () => FakeOnboardingRemoteDataSource(sl(), sl()),
    )
    ..registerLazySingleton<HomeRemoteDataSource>(
      () => FakeHomeRemoteDataSource(sl()),
    )
    // ───────────────────────────────────────────────────────────────────────
    ..registerLazySingleton(StyleQuizLocalDataSource.new)
    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: sl(), tokenStore: sl()),
    )
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(remote: sl(), quizLocal: sl()),
    )
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remote: sl()),
    )
    // Use cases
    ..registerFactory(() => RestoreSession(sl()))
    ..registerFactory(() => WatchCurrentUser(sl()))
    ..registerFactory(() => SignOut(sl()))
    ..registerFactory(() => SignInWithEmail(sl()))
    ..registerFactory(() => SignUpWithEmail(sl()))
    ..registerFactory(() => SendPasswordResetEmail(sl()))
    ..registerFactory(() => SignInWithSocialProvider(sl()))
    ..registerFactory(() => SaveProfile(sl(), sl()))
    ..registerFactory(() => GetStyleQuiz(sl()))
    ..registerFactory(() => CompleteStyleQuiz(sl(), sl()))
    ..registerFactory(() => GetHomeFeed(sl()))
    // Presentation
    ..registerLazySingleton(
      () => SessionCubit(
        restoreSession: sl(),
        watchCurrentUser: sl(),
        signOut: sl(),
      ),
    )
    ..registerFactory(() => SignInCubit(sl()))
    ..registerFactory(() => SignUpCubit(sl()))
    ..registerFactory(() => ForgotPasswordCubit(sl()))
    ..registerFactory(() => SocialSignInCubit(sl()))
    ..registerFactory(() => ProfileSetupCubit(sl()))
    ..registerFactory(() => StyleQuizCubit(sl(), sl()))
    ..registerFactory(() => HomeFeedCubit(sl()));
}
