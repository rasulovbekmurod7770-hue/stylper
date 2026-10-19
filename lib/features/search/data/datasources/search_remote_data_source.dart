import '../../../../core/fake_backend/fake_backend.dart';
import '../../../../core/network/auth_token_store.dart';

/// Search endpoints of the Stylper API.
///
/// Implementations throw `ServerException` / `NetworkException`.
abstract interface class SearchRemoteDataSource {
  /// GET /search/discover — public.
  Future<Map<String, Object?>> discover();

  /// GET /search?q= — public; sends the token when signed in so each
  /// person's `followedByMe` / `isMe` are the user's.
  Future<Map<String, Object?>> search(String query);
}

/// [SearchRemoteDataSource] backed by [FakeBackend] until the API exists.
class FakeSearchRemoteDataSource implements SearchRemoteDataSource {
  const FakeSearchRemoteDataSource(this._backend, this._tokenStore);

  final FakeBackend _backend;
  final AuthTokenStore _tokenStore;

  @override
  Future<Map<String, Object?>> discover() => _backend.searchDiscover();

  @override
  Future<Map<String, Object?>> search(String query) async =>
      _backend.search(query, token: await _tokenStore.read());
}
