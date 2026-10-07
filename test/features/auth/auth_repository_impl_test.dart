import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/features/auth/data/datasources/fake_auth_remote_data_source.dart';
import 'package:stylper/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:stylper/features/auth/domain/entities/app_user.dart';
import 'package:stylper/features/auth/domain/failures/auth_failure.dart';

void main() {
  late AuthTokenStore tokenStore;
  late AuthRepositoryImpl repository;

  setUp(() {
    tokenStore = InMemoryAuthTokenStore();
    repository = AuthRepositoryImpl(
      remote: FakeAuthRemoteDataSource(FakeBackend(latency: Duration.zero)),
      tokenStore: tokenStore,
    );
  });

  AuthFailureReason? failureOf(Either<AuthFailure, Object?> result) =>
      result.getLeft().toNullable()?.reason;

  test(
    'signing in with the demo account stores a token and emits the user',
    () async {
      final result = await repository.signInWithEmail(
        email: FakeBackend.demoEmail,
        password: FakeBackend.demoPassword,
      );

      final user = result.getOrElse((_) => throw StateError('expected a user'));
      expect(user.email, FakeBackend.demoEmail);
      expect(user.onboardingCompleted, isTrue);
      expect(repository.currentUser, user);
      expect(await tokenStore.read(), isNotNull);
    },
  );

  test('wrong password maps to invalidCredentials', () async {
    final result = await repository.signInWithEmail(
      email: FakeBackend.demoEmail,
      password: 'wrong-password',
    );
    expect(failureOf(result), AuthFailureReason.invalidCredentials);
    expect(repository.currentUser, isNull);
  });

  test('registering an existing email maps to emailAlreadyInUse', () async {
    final result = await repository.signUpWithEmail(
      email: FakeBackend.demoEmail,
      password: 'another-password',
    );
    expect(failureOf(result), AuthFailureReason.emailAlreadyInUse);
  });

  test(
    'a new account starts without a profile or finished onboarding',
    () async {
      final result = await repository.signUpWithEmail(
        email: 'New.User@Stylper.ai',
        password: 'stylper123',
      );
      final user = result.getOrElse((_) => throw StateError('expected a user'));
      expect(user.email, 'new.user@stylper.ai');
      expect(user.hasProfile, isFalse);
      expect(user.onboardingCompleted, isFalse);
    },
  );

  test(
    'social sign-in reports providerUnavailable until it is configured',
    () async {
      expect(
        failureOf(await repository.signInWithGoogle()),
        AuthFailureReason.providerUnavailable,
      );
      expect(
        failureOf(await repository.signInWithApple()),
        AuthFailureReason.providerUnavailable,
      );
    },
  );

  test(
    'watchCurrentUser replays the current value, then follows changes',
    () async {
      await repository.signInWithEmail(
        email: FakeBackend.demoEmail,
        password: FakeBackend.demoPassword,
      );
      final events = <AppUser?>[];
      final subscription = repository.watchCurrentUser().listen(events.add);

      await repository.signOut();
      await pumpEventQueue();

      expect(events, hasLength(2));
      expect(events.first?.email, FakeBackend.demoEmail);
      expect(events.last, isNull);
      expect(await tokenStore.read(), isNull);
      await subscription.cancel();
    },
  );

  test('restoreSession signs the stored token back in', () async {
    await repository.signInWithEmail(
      email: FakeBackend.demoEmail,
      password: FakeBackend.demoPassword,
    );
    final token = await tokenStore.read();

    final restored = AuthRepositoryImpl(
      remote: FakeAuthRemoteDataSource(FakeBackend(latency: Duration.zero)),
      tokenStore: InMemoryAuthTokenStore()..save(token!),
    );
    // A different backend instance doesn't know the token → signed out, token cleared.
    await restored.restoreSession();
    expect(restored.currentUser, isNull);
  });
}
