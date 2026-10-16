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
}
