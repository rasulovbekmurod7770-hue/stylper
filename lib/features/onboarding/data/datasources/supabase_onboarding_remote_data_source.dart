import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/supabase_guard.dart';
import 'onboarding_remote_data_source.dart';

/// [OnboardingRemoteDataSource] on Supabase (spec §7, "Profile setup" and
/// "Dress like you quiz"). The username goes to the public `profiles` row;
/// gender, birth year, height and weight to `profile_private`, which only its
/// owner can read.
class SupabaseOnboardingRemoteDataSource implements OnboardingRemoteDataSource {
  const SupabaseOnboardingRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Body as for `PUT /me/profile`: `{username, gender, age?, heightCm?,
  /// weightKg?}`. A username that is someone else's, a brand's handle or
  /// reserved is a unique violation in the database (migration 0002).
  @override
  Future<void> saveProfile(Map<String, Object?> body) =>
      guardSupabase(() async {
        // The username first: it's the part that can be refused.
        await updateOwnRow(_client, 'profiles', 'id', {
          'username': body['username'],
        });
        final age = body['age'] as int?;
        await updateOwnRow(_client, 'profile_private', 'user_id', {
          'gender': body['gender'],
          'birth_year': age == null ? null : DateTime.now().year - age,
          'height_cm': body['heightCm'],
          'weight_kg': body['weightKg'],
        });
      }, codes: const {'23505': ApiErrorCodes.usernameTaken});

  /// Records the liked outfit, sets the Style DNA and marks onboarding
  /// finished.
  @override
  Future<void> completeOnboarding({
    required String topId,
    required String bottomId,
    required List<String> styleDna,
  }) => guardSupabase(() async {
    final userId = requireUserId(_client);
    await _client.from('style_quiz_answers').insert({
      'user_id': userId,
      'top_key': topId,
      'bottom_key': bottomId,
    });
    await updateOwnRow(_client, 'profiles', 'id', {
      'style_dna': styleDna,
      'onboarded_at': DateTime.now().toUtc().toIso8601String(),
    });
  });
}
