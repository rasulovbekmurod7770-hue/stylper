import '../../../../core/fake_backend/fake_backend.dart';
import '../../../../core/network/auth_token_store.dart';

/// Home endpoints of the Stylper API.
///
/// Implementations throw `ServerException` / `NetworkException`.
abstract interface class HomeRemoteDataSource {
  /// GET /feed/home — public; sends the token when signed in so
  /// `likedByMe` / `savedByMe` are the user's.
  Future<Map<String, Object?>> getHomeFeed();
}

/// [HomeRemoteDataSource] backed by [FakeBackend] until the API exists.
class FakeHomeRemoteDataSource implements HomeRemoteDataSource {
  const FakeHomeRemoteDataSource(this._backend, this._tokenStore);

  final FakeBackend _backend;
  final AuthTokenStore _tokenStore;

  @override
  Future<Map<String, Object?>> getHomeFeed() async =>
      _backend.homeFeed(token: await _tokenStore.read());
}
