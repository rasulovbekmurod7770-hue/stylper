import '../../../../core/fake_backend/fake_backend.dart';
import '../../../../core/network/auth_token_store.dart';

/// Profile endpoints of the Stylper API.
///
/// Implementations throw `ServerException` / `NetworkException`.
abstract interface class ProfileRemoteDataSource {
  /// GET /users/:id (`me` = the signed-in user) — public except `me`.
  Future<Map<String, Object?>> getProfile(String userId);

  /// POST (following) / DELETE /users/:id/follow →
  /// `{followers, followedByMe}`
  Future<Map<String, Object?>> setFollowing(
    String userId, {
    required bool following,
  });

  /// GET /me/saved → `{posts}`
  Future<Map<String, Object?>> getSavedPosts();

  /// PATCH /me/profile `{name, username, bio, avatarMediaId?}` (Edit
  /// Profile); `avatarMediaId` only when the photo changes (null removes it)
  Future<void> updateProfile(Map<String, Object?> body);

  /// GET /me/settings → `{isPrivate, allowBrandFeatures, showLikeCounts,
  /// notifyBrandActivity, notifyDrops}`
  Future<Map<String, Object?>> getSettings();

  /// PUT /me/settings, same body
  Future<void> updateSettings(Map<String, Object?> body);
}

/// [ProfileRemoteDataSource] backed by [FakeBackend] until the API exists.
class FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  const FakeProfileRemoteDataSource(this._backend, this._tokenStore);

  final FakeBackend _backend;
  final AuthTokenStore _tokenStore;

  @override
  Future<Map<String, Object?>> getProfile(String userId) async =>
      _backend.userProfile(userId, token: await _tokenStore.read());

  @override
  Future<Map<String, Object?>> setFollowing(
    String userId, {
    required bool following,
  }) async => _backend.setFollowing(
    await _tokenStore.read(),
    userId,
    following: following,
  );

  @override
  Future<Map<String, Object?>> getSavedPosts() async =>
      _backend.savedPosts(await _tokenStore.read());

  @override
  Future<void> updateProfile(Map<String, Object?> body) async =>
      _backend.editProfile(await _tokenStore.read() ?? '', body);

  @override
  Future<Map<String, Object?>> getSettings() async =>
      _backend.settings(await _tokenStore.read() ?? '');

  @override
  Future<void> updateSettings(Map<String, Object?> body) async =>
      _backend.updateSettings(await _tokenStore.read() ?? '', body);
}
