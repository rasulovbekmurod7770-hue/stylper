import '../../../../core/fake_backend/fake_backend.dart';

/// Home endpoints of the Stylper API.
///
/// Implementations throw `ServerException` / `NetworkException`.
abstract interface class HomeRemoteDataSource {
  /// GET /feed/home
  Future<Map<String, Object?>> getHomeFeed();
}

/// [HomeRemoteDataSource] backed by [FakeBackend] until the API exists.
class FakeHomeRemoteDataSource implements HomeRemoteDataSource {
  const FakeHomeRemoteDataSource(this._backend);

  final FakeBackend _backend;

  @override
  Future<Map<String, Object?>> getHomeFeed() => _backend.homeFeed();
}
