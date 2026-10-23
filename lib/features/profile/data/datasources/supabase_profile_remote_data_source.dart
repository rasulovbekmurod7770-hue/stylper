import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/media_url.dart';
import '../../../../core/network/supabase_guard.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_remote_data_source.dart';

/// [ProfileRemoteDataSource] on Supabase for your own profile: its header,
/// Edit Profile and Settings. Other people's profiles, follows and saved
/// posts aren't ported yet and still go to [_notPorted] (the fake backend).
class SupabaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  const SupabaseProfileRemoteDataSource(this._client, this._notPorted);

  final SupabaseClient _client;
  final ProfileRemoteDataSource _notPorted;

  /// Your own profile as `GET /users/me` returns it, its photo as the 400 px
  /// thumbnail. No posts until posting is ported (spec §10 step 3).
  @override
  Future<Map<String, Object?>> getProfile(String userId) {
    if (userId != ProfileRepository.me) return _notPorted.getProfile(userId);
    return guardSupabase(() async {
      final id = requireUserId(_client);
      final row = await _client
          .from('profiles')
          .select(
            'username, display_name, bio, style_dna, posts_count, '
            'followers_count, following_count, '
            // Two foreign keys join profiles and media; name the photo's.
            'avatar:media!profiles_avatar_fk(thumb_key)',
          )
          .eq('id', id)
          .single();
      final username = row['username'] as String?;
      return {
        'id': id,
        'name':
            row['display_name'] ??
            username ??
            _client.auth.currentUser?.email?.split('@').first ??
            '',
        'handle': username,
        'avatar': mediaUrl(
          (row['avatar'] as Map<String, Object?>?)?['thumb_key'] as String?,
        ),
        'bio': row['bio'] ?? '',
        'styles': row['style_dna'],
        'posts': row['posts_count'],
        'followers': row['followers_count'],
        'following': row['following_count'],
        'isMe': true,
        'recentPosts': const <Object?>[],
      };
    }, codes: const {'PGRST116': ApiErrorCodes.notFound});
  }

  @override
  Future<Map<String, Object?>> setFollowing(
    String userId, {
    required bool following,
  }) => _notPorted.setFollowing(userId, following: following);

  @override
  Future<Map<String, Object?>> getSavedPosts() => _notPorted.getSavedPosts();

  /// A username that is someone else's, a brand's or reserved is a unique
  /// violation (migration 0002); an empty name or bio clears it. A photo must
  /// be a finished upload of yours (RLS), else [ApiErrorCodes.unauthorized].
  @override
  Future<void> updateProfile(Map<String, Object?> body) => guardSupabase(
    () => updateOwnRow(_client, 'profiles', 'id', {
      'display_name': _nullIfEmpty(body['name']),
      'username': body['username'],
      'bio': _nullIfEmpty(body['bio']),
      if (body.containsKey('avatarMediaId'))
        'avatar_media_id': body['avatarMediaId'],
    }),
    codes: const {'23505': ApiErrorCodes.usernameTaken},
  );

  /// "Private account" is on the public profile row; the rest are private.
  @override
  Future<Map<String, Object?>> getSettings() => guardSupabase(() async {
    final id = requireUserId(_client);
    final profile = await _client
        .from('profiles')
        .select('is_private')
        .eq('id', id)
        .single();
    final private = await _client
        .from('profile_private')
        .select(
          'allow_brand_features_default, show_like_counts, '
          'notify_brand_activity, notify_drops',
        )
        .eq('user_id', id)
        .single();
    return {
      'isPrivate': profile['is_private'],
      'allowBrandFeatures': private['allow_brand_features_default'],
      'showLikeCounts': private['show_like_counts'],
      'notifyBrandActivity': private['notify_brand_activity'],
      'notifyDrops': private['notify_drops'],
    };
  });

  @override
  Future<void> updateSettings(Map<String, Object?> body) =>
      guardSupabase(() async {
        await updateOwnRow(_client, 'profiles', 'id', {
          'is_private': body['isPrivate'],
        });
        await updateOwnRow(_client, 'profile_private', 'user_id', {
          'allow_brand_features_default': body['allowBrandFeatures'],
          'show_like_counts': body['showLikeCounts'],
          'notify_brand_activity': body['notifyBrandActivity'],
          'notify_drops': body['notifyDrops'],
        });
      });

  static Object? _nullIfEmpty(Object? value) =>
      value is String && value.isEmpty ? null : value;
}
