import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/app/di/injection.dart';
import 'package:stylper/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:stylper/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:stylper/features/auth/domain/repositories/auth_repository.dart';
import 'package:stylper/features/home/data/datasources/home_remote_data_source.dart';
import 'package:stylper/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:stylper/features/onboarding/data/datasources/supabase_onboarding_remote_data_source.dart';
import 'package:stylper/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:stylper/features/profile/data/datasources/supabase_profile_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// `BACKEND=supabase` moves only the ported features (auth, onboarding, your
/// own profile) to Supabase; the rest stay on the fake backend.
void main() {
  tearDown(sl.reset);

  test('without a Supabase client everything runs on the fake backend', () {
    configureDependencies();
    expect(sl<AuthRepository>(), isA<AuthRepositoryImpl>());
    expect(
      sl<OnboardingRemoteDataSource>(),
      isA<FakeOnboardingRemoteDataSource>(),
    );
  });

  test('with one, auth, onboarding and your profile use Supabase', () {
    final client = SupabaseClient('http://127.0.0.1:54321', 'test-key');
    addTearDown(client.dispose);
    configureDependencies(supabase: client);

    expect(sl<AuthRepository>(), isA<SupabaseAuthRepository>());
    expect(
      sl<OnboardingRemoteDataSource>(),
      isA<SupabaseOnboardingRemoteDataSource>(),
    );
    expect(
      sl<ProfileRemoteDataSource>(),
      isA<SupabaseProfileRemoteDataSource>(),
    );
    expect(sl<HomeRemoteDataSource>(), isA<FakeHomeRemoteDataSource>());
  });
}
