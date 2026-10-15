import '../../../../core/fake_backend/fake_backend.dart';
import '../../../../core/network/auth_token_store.dart';

/// Post endpoints of the Stylper API.
///
/// Implementations throw `ServerException` / `NetworkException`.
abstract interface class PostRemoteDataSource {
  /// GET /posts/:id — public; `likedByMe` / `savedByMe` reflect the token.
  Future<Map<String, Object?>> getPost(String id);

  /// POST /posts/:id/like (liked) or DELETE /posts/:id/like →
  /// `{likes, likedByMe, savedByMe}`.
  Future<Map<String, Object?>> setLiked(String id, {required bool liked});

  /// PUT /posts/:id/save (saved) or DELETE /posts/:id/save →
  /// `{likes, likedByMe, savedByMe}`.
  Future<Map<String, Object?>> setSaved(String id, {required bool saved});
}

/// [PostRemoteDataSource] backed by [FakeBackend] until the API exists.
class FakePostRemoteDataSource implements PostRemoteDataSource {
  const FakePostRemoteDataSource(this._backend, this._tokenStore);

  final FakeBackend _backend;
  final AuthTokenStore _tokenStore;

  @override
  Future<Map<String, Object?>> getPost(String id) async =>
      _backend.post(id, token: await _tokenStore.read());

  @override
  Future<Map<String, Object?>> setLiked(
    String id, {
    required bool liked,
  }) async => _backend.setLiked(await _tokenStore.read(), id, liked: liked);

  @override
  Future<Map<String, Object?>> setSaved(
    String id, {
    required bool saved,
  }) async => _backend.setSaved(await _tokenStore.read(), id, saved: saved);
}
