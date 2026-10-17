import '../../../../core/fake_backend/fake_backend.dart';
import '../../../../core/network/auth_token_store.dart';

/// Posting endpoints of the Stylper API.
///
/// Implementations throw `ServerException` / `NetworkException`.
abstract interface class PostingRemoteDataSource {
  /// GET /products/search?q=&category=&mine= → `{products}`
  Future<Map<String, Object?>> searchProducts(
    String query, {
    String? category,
    bool mine = false,
  });

  /// GET /me/recent-tags → `{products}`
  Future<Map<String, Object?>> recentTags();

  /// GET /styles → `{styles}`
  Future<Map<String, Object?>> styles();

  /// POST /posts (multipart: the photo + the fields) → the new post.
  Future<Map<String, Object?>> publish(Map<String, Object?> body);
}

/// [PostingRemoteDataSource] backed by [FakeBackend] until the API exists.
class FakePostingRemoteDataSource implements PostingRemoteDataSource {
  const FakePostingRemoteDataSource(this._backend, this._tokenStore);

  final FakeBackend _backend;
  final AuthTokenStore _tokenStore;

  @override
  Future<Map<String, Object?>> searchProducts(
    String query, {
    String? category,
    bool mine = false,
  }) async => _backend.searchProducts(
    query: query,
    category: category,
    mine: mine,
    token: await _tokenStore.read(),
  );

  @override
  Future<Map<String, Object?>> recentTags() async =>
      _backend.recentTags(await _tokenStore.read());

  @override
  Future<Map<String, Object?>> styles() => _backend.postStyles();

  @override
  Future<Map<String, Object?>> publish(Map<String, Object?> body) async =>
      _backend.publishPost(await _tokenStore.read(), body);
}
