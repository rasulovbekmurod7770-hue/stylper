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
        final userId = requireUserId(_client);
        // The username first: it's the part that can be refused.
        await _updateOwnRow('profiles', 'id', userId, {
          'username': body['username'],
        });
        final age = body['age'] as int?;
        await _updateOwnRow('profile_private', 'user_id', userId, {
          'gender': body['gender'],
          'birth_year': age == null ? null : DateTime.now().year - age,
          'height_cm': body['heightCm'],
          'weight_kg': body['weightKg'],
        });
      }, codes: const {'23505': ApiErrorCodes.usernameTaken});

  /// Records the liked outfit and marks onboarding finished. `style_dna`
  /// stays as it is: the quiz items don't carry style tags yet.
  @override
  Future<void> completeOnboarding({
    required String topId,
    required String bottomId,
  }) => guardSupabase(() async {
    final userId = requireUserId(_client);
    await _client.from('style_quiz_answers').insert({
      'user_id': userId,
      'top_key': topId,
      'bottom_key': bottomId,
    });
    await _updateOwnRow('profiles', 'id', userId, {
      'onboarded_at': DateTime.now().toUtc().toIso8601String(),
    });
  });

  /// Updates the signed-in user's row in [table]. RLS answers an update of
  /// someone else's row with no rows rather than an error, so none counts as
  /// unauthorized.
  Future<void> _updateOwnRow(
    String table,
    String idColumn,
    String userId,
    Map<String, Object?> values,
  ) async {
    final rows = await _client
        .from(table)
        .update(values)
        .eq(idColumn, userId)
        .select(idColumn);
    if (rows.isEmpty) {
      throw const ServerException(
        statusCode: 401,
        code: ApiErrorCodes.unauthorized,
      );
    }
  }
}
