import '../../../../core/fake_backend/fake_backend.dart';
import '../../../../core/network/auth_token_store.dart';

/// Product endpoints of the Stylper API.
///
/// Implementations throw `ServerException` / `NetworkException`.
abstract interface class ProductRemoteDataSource {
  /// GET /products/:id — public; `inWardrobe` reflects the token.
  Future<Map<String, Object?>> getProduct(String id);
}

/// [ProductRemoteDataSource] backed by [FakeBackend] until the API exists.
class FakeProductRemoteDataSource implements ProductRemoteDataSource {
  const FakeProductRemoteDataSource(this._backend, this._tokenStore);

  final FakeBackend _backend;
  final AuthTokenStore _tokenStore;

  @override
  Future<Map<String, Object?>> getProduct(String id) async =>
      _backend.product(id, token: await _tokenStore.read());
}
