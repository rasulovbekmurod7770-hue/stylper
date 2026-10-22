// Live tests of the auth + onboarding slice against the local Supabase stack
// (`npx supabase start`). Not part of `flutter test`; run them with
//
//   flutter test test_supabase --dart-define-from-file=env/test.json
//
// env/test.json (gitignored) is env/local.json plus the stack's secret key
// as SUPABASE_SECRET_KEY (`npx supabase status`), which the account-deleting
// test needs (it's skipped without). Keep that key out of the app's env files.
//
// They use plain `test`, not `testWidgets`, because the widget test binding
// blocks real HTTP. They pass with email confirmation off (the local default)
// and on (production); with it on, they open the link from Mailpit.
import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/core/config/backend_config.dart';
import 'package:stylper/core/domain/style_keys.dart';
import 'package:stylper/core/usecase/usecase.dart';
import 'package:stylper/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:stylper/features/auth/domain/entities/app_user.dart';
import 'package:stylper/features/auth/domain/entities/sign_up_result.dart';
import 'package:stylper/features/auth/domain/failures/auth_failure.dart';
import 'package:stylper/features/onboarding/data/datasources/style_quiz_local_data_source.dart';
import 'package:stylper/features/onboarding/data/datasources/supabase_onboarding_remote_data_source.dart';
import 'package:stylper/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:stylper/features/onboarding/domain/entities/profile_details.dart';
import 'package:stylper/features/onboarding/domain/failures/onboarding_failure.dart';
import 'package:stylper/features/onboarding/domain/usecases/onboarding_usecases.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'live_support.dart';

void main() {
  late SupabaseClient client;
  late SupabaseAuthRepository auth;
  late SaveProfile saveProfile;
  late CompleteStyleQuiz completeStyleQuiz;
  late GetStyleQuiz getStyleQuiz;

  setUp(() {
    client = liveClient();
    auth = SupabaseAuthRepository(client);
    final onboarding = OnboardingRepositoryImpl(
      remote: SupabaseOnboardingRemoteDataSource(client),
      quizLocal: const StyleQuizLocalDataSource(),
    );
    saveProfile = SaveProfile(onboarding, auth);
    completeStyleQuiz = CompleteStyleQuiz(onboarding, auth);
    getStyleQuiz = GetStyleQuiz(onboarding);
  });

  tearDown(() => client.dispose());

  Future<AppUser> signIn(String email) => signInLive(auth, email);

  Future<AppUser> signUpNewUser(String email) =>
      signUpLive(client, auth, email);

  test('a new user signs up, gets a profile row, sets it up, takes the quiz, '
      'and signs back in onboarded', () async {
    final (:email, :username) = newAccount('live');

    final user = await signUpNewUser(email);
    expect(user.email, email);
    expect(user.hasProfile, isFalse);
    expect(user.onboardingCompleted, isFalse);
    expect(auth.currentUser, user);

    // The rows the sign-up trigger created, as the user reads them.
    final profile = await client
        .from('profiles')
        .select('username, onboarded_at')
        .eq('id', user.id)
        .single();
    expect(profile, {'username': null, 'onboarded_at': null});
    final private = await client.from('profile_private').select();
    expect(private, hasLength(1), reason: 'only your own private row');
    expect(private.single['user_id'], user.id);

    // Brands' handles, reserved names and other people's usernames are taken.
    for (final taken in ['cos', 'zara', 'admin', 'stylper', 'katty_miller']) {
      final result = await saveProfile(
        ProfileDetails(username: taken, gender: Gender.female),
      );
      expect(
        result.getLeft().toNullable()?.reason,
        OnboardingFailureReason.usernameTaken,
        reason: taken,
      );
    }
    expect(auth.currentUser!.hasProfile, isFalse);

    final saved = await saveProfile(
      ProfileDetails(
        username: username,
        gender: Gender.female,
        age: 25,
        heightCm: 170,
        weightKg: 60,
      ),
    );
    expect(saved.isRight(), isTrue, reason: '$saved');
    expect(auth.currentUser!.username, username);
    expect(auth.currentUser!.onboardingCompleted, isFalse);
    final body = await client
        .from('profile_private')
        .select('gender, birth_year, height_cm, weight_kg')
        .single();
    expect(body, {
      'gender': 'female',
      'birth_year': DateTime.now().year - 25,
      'height_cm': 170,
      'weight_kg': 60,
    });

    final quiz = (await getStyleQuiz(const NoParams()))
        .getOrElse((_) => fail('no quiz'));
    final done = await completeStyleQuiz(
      LikedOutfit(top: quiz.tops.first, bottom: quiz.bottoms.first),
    );
    expect(done.isRight(), isTrue, reason: '$done');
    expect(auth.currentUser!.onboardingCompleted, isTrue);
    // White T-Shirt + Baggy Jeans (the approved example).
    final dna = await client
        .from('profiles')
        .select('style_dna')
        .eq('id', user.id)
        .single();
    expect(dna['style_dna'], [
      StyleKeys.minimal,
      StyleKeys.neutral,
      StyleKeys.streetwear,
      StyleKeys.oversized,
    ]);
    final answers = await client
        .from('style_quiz_answers')
        .select('top_key, bottom_key, liked');
    expect(answers, [
      {
        'top_key': quiz.tops.first.id,
        'bottom_key': quiz.bottoms.first.id,
        'liked': true,
      },
    ]);

    await auth.signOut();
    expect(auth.currentUser, isNull);
    expect(client.auth.currentSession, isNull);

    final again = await signIn(email);
    expect(again.username, username);
    expect(again.onboardingCompleted, isTrue);
  });

  test('the demo account signs in onboarded; restoreSession picks up the '
      'session Supabase kept', () async {
    final john = await signIn('developer@stylper.ai');
    expect(john.username, 'john');
    expect(john.onboardingCompleted, isTrue);

    final relaunched = SupabaseAuthRepository(client);
    await relaunched.restoreSession();
    expect(relaunched.currentUser, john);
  });

  test(
    'restoreSession signs out when the account was deleted meanwhile',
    () async {
      final user = await signUpNewUser(newAccount('gone').email);

      final admin = SupabaseClient(BackendConfig.supabaseUrl, liveSecretKey);
      addTearDown(admin.dispose);
      await admin.auth.admin.deleteUser(user.id);

      // The access token is still valid, but the profile row is gone.
      final relaunched = SupabaseAuthRepository(client);
      await relaunched.restoreSession();
      expect(relaunched.currentUser, isNull);
      expect(client.auth.currentSession, isNull, reason: 'signed out');
    },
    skip: liveSecretKey.isEmpty ? 'needs SUPABASE_SECRET_KEY' : null,
  );

  test('wrong password and an existing email', () async {
    final wrong = await auth.signInWithEmail(
      email: 'developer@stylper.ai',
      password: 'not-the-password',
    );
    expect(
      wrong.getLeft().toNullable()?.reason,
      AuthFailureReason.invalidCredentials,
    );

    final existing = await auth.signUpWithEmail(
      email: 'developer@stylper.ai',
      password: livePassword,
    );
    // With confirmation on, Supabase answers as for a new account, so nobody
    // can find out who is registered.
    expect(
      existing.match((f) => f.reason, (r) => r),
      anyOf(
        AuthFailureReason.emailAlreadyInUse,
        const ConfirmationEmailSent('developer@stylper.ai'),
      ),
    );
    expect(auth.currentUser, isNull);
  });
}
