import 'dart:typed_data';

import '../../../../core/fake_backend/fake_backend.dart';
import '../../../../core/network/auth_token_store.dart';

/// Upload endpoints of the Stylper API: the Edge Functions of
/// STYLPER_BACKEND_SPEC.md §6, and the storage they hand out URLs for.
///
/// Implementations throw `ServerException` / `NetworkException`.
abstract interface class UploadRemoteDataSource {
  /// POST /functions/v1/create-upload `{kind, brand_id?, width, height,
  /// bytes, blurhash}` → `{media_id, full_put_url, thumb_put_url,
  /// expires_in}`
  Future<Map<String, Object?>> createUpload(Map<String, Object?> body);

  /// PUT [bytes] to a URL from [createUpload], as `image/webp`.
  Future<void> putObject(String url, Uint8List bytes);

  /// POST /functions/v1/finalize-upload `{media_id}` → `{media_id, full_url,
  /// thumb_url, width, height, blurhash}`
  Future<Map<String, Object?>> finalizeUpload(String mediaId);
}

/// [UploadRemoteDataSource] backed by [FakeBackend].
class FakeUploadRemoteDataSource implements UploadRemoteDataSource {
  const FakeUploadRemoteDataSource(this._backend, this._tokenStore);

  final FakeBackend _backend;
  final AuthTokenStore _tokenStore;

  @override
  Future<Map<String, Object?>> createUpload(Map<String, Object?> body) async =>
      _backend.createUpload(await _tokenStore.read(), body);

  @override
  Future<void> putObject(String url, Uint8List bytes) =>
      _backend.putObject(url, bytes);

  @override
  Future<Map<String, Object?>> finalizeUpload(String mediaId) async =>
      _backend.finalizeUpload(await _tokenStore.read(), {'media_id': mediaId});
}
