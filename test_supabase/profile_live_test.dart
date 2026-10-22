// Live tests of your own profile on Supabase: the header, Edit Profile and
// Settings. Run with the others (see auth_onboarding_live_test.dart).
import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/core/domain/style_keys.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:stylper/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:stylper/features/profile/data/datasources/supabase_profile_remote_data_source.dart';
import 'package:stylper/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:stylper/features/profile/domain/entities/profile_settings.dart';
import 'package:stylper/features/profile/domain/entities/user_profile.dart';
import 'package:stylper/features/profile/domain/failures/profile_failure.dart';
import 'package:stylper/features/profile/domain/repositories/profile_repository.dart';
import 'package:stylper/features/profile/domain/usecases/profile_usecases.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'live_support.dart';

void main() {
  late SupabaseClient client;
  late SupabaseAuthRepository auth;
  late ProfileRepositoryImpl profiles;

  setUp(() {
    client = liveClient();
    auth = SupabaseAuthRepository(client);
    profiles = ProfileRepositoryImpl(
      remote: SupabaseProfileRemoteDataSource(
        client,
        FakeProfileRemoteDataSource(
          FakeBackend(latency: Duration.zero),
          InMemoryAuthTokenStore(),
        ),
      ),
    );
  });

  tearDown(() => client.dispose());

  Future<UserProfile> me() async =>
      (await profiles.getProfile(ProfileRepository.me))
          .getOrElse((f) => fail('no profile: ${f.reason}'));

  Future<Map<String, dynamic>> myRow(String columns) => client
      .from('profiles')
      .select(columns)
      .eq('id', auth.currentUser!.id)
      .single();

  test('the header comes from your profile row', () async {
    await signInLive(auth, 'developer@stylper.ai');
    final john = await me();
    final row = await myRow('posts_count, followers_count, following_count');

    expect(john.isMe, isTrue);
    expect((john.name, john.handle), ('John. B', 'john'));
    expect(john.bio, 'Minimalist fashion lover | NYC');
    expect(john.styles, [
      StyleKeys.minimal,
      StyleKeys.casual,
      StyleKeys.streetwear,
      StyleKeys.neutral,
      StyleKeys.oversized,
    ]);
    expect(
      (john.postCount, john.followerCount, john.followingCount),
      (row['posts_count'], row['followers_count'], row['following_count']),
    );
    expect(john.recentPosts, isEmpty, reason: 'posts come with posting');
  });

  test('signed out, there is no profile of yours', () async {
    expect(
      (await profiles.getProfile(ProfileRepository.me))
          .getLeft()
          .toNullable()
          ?.reason,
      ProfileFailureReason.signInRequired,
    );
  });

  test('Edit Profile: taken usernames are refused; name, username and bio '
      'are saved, and an empty name falls back to the username', () async {
    final (:email, :username) = newAccount('edit');
    await signUpLive(client, auth, email);
    final update = UpdateProfile(profiles, auth);

    for (final taken in ['cos', 'zara', 'admin', 'stylper', 'john']) {
      final result = await update(
        ProfileEdit(name: 'Dilnoza', username: taken, bio: ''),
      );
      expect(
        result.getLeft().toNullable()?.reason,
        ProfileFailureReason.usernameTaken,
        reason: taken,
      );
    }

    final saved = await update(
      ProfileEdit(name: 'Dilnoza', username: username, bio: 'Layers, always.'),
    );
    expect(saved.isRight(), isTrue, reason: '$saved');
    expect(await myRow('display_name, username, bio'), {
      'display_name': 'Dilnoza',
      'username': username,
      'bio': 'Layers, always.',
    });
    expect(auth.currentUser!.username, username, reason: 'session follows');
    final profile = await me();
    expect((profile.name, profile.handle), ('Dilnoza', username));

    await update(ProfileEdit(name: '', username: username, bio: ''));
    expect(await myRow('display_name, bio'), {
      'display_name': null,
      'bio': null,
    });
    expect((await me()).name, username);
  });

  test('Settings: every toggle round-trips through both tables', () async {
    await signUpLive(client, auth, newAccount('settings').email);
    expect(
      (await profiles.getSettings()).getOrElse((_) => fail('no settings')),
      const ProfileSettings(),
      reason: 'a new account has the defaults',
    );

    const flipped = ProfileSettings(
      isPrivate: true,
      allowBrandFeatures: false,
      showLikeCounts: false,
      notifyBrandActivity: false,
      notifyDrops: true,
    );
    expect((await profiles.updateSettings(flipped)).isRight(), isTrue);
    expect(await myRow('is_private'), {'is_private': true});
    expect(
      await client
          .from('profile_private')
          .select(
            'allow_brand_features_default, show_like_counts, '
            'notify_brand_activity, notify_drops',
          )
          .single(),
      {
        'allow_brand_features_default': false,
        'show_like_counts': false,
        'notify_brand_activity': false,
        'notify_drops': true,
      },
    );
    expect(
      (await profiles.getSettings()).getOrElse((_) => fail('no settings')),
      flipped,
    );
  });
}
