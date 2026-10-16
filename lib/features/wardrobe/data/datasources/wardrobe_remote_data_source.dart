import '../../../../core/fake_backend/fake_backend.dart';
import '../../../../core/network/auth_token_store.dart';

/// Wardrobe endpoints of the Stylper API (signed-in users only).
///
/// Implementations throw `ServerException` / `NetworkException`.
abstract interface class WardrobeRemoteDataSource {
  /// GET /me/wardrobe → `{categories: [{id, count, image?}]}`
  Future<Map<String, Object?>> getCategories();

  /// GET /me/wardrobe/:category → `{items: [{id, name, brand?, image,
  /// productId?}]}`
  Future<Map<String, Object?>> getItems(String category);

  /// PUT (saved) / DELETE /me/wardrobe/items/:id → `{inWardrobe}`
  Future<Map<String, Object?>> setInWardrobe(
    String itemId, {
    required bool saved,
  });
}

/// [WardrobeRemoteDataSource] backed by [FakeBackend] until the API exists.
class FakeWardrobeRemoteDataSource implements WardrobeRemoteDataSource {
  const FakeWardrobeRemoteDataSource(this._backend, this._tokenStore);

  final FakeBackend _backend;
  final AuthTokenStore _tokenStore;

  @override
  Future<Map<String, Object?>> getCategories() async =>
      _backend.wardrobe(await _tokenStore.read());

  @override
  Future<Map<String, Object?>> getItems(String category) async =>
      _backend.wardrobeCategory(await _tokenStore.read(), category);

  @override
  Future<Map<String, Object?>> setInWardrobe(
    String itemId, {
    required bool saved,
  }) async =>
      _backend.setInWardrobe(await _tokenStore.read(), itemId, saved: saved);
}
