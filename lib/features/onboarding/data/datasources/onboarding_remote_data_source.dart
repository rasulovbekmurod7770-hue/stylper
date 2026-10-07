import '../../../../core/fake_backend/fake_backend.dart';
import '../../../../core/network/auth_token_store.dart';

/// Onboarding endpoints of the Stylper API.
///
/// Implementations throw `ServerException` / `NetworkException`.
abstract interface class OnboardingRemoteDataSource {
  /// PUT /me/profile
  Future<void> saveProfile(Map<String, Object?> body);

  /// POST /me/onboarding/complete
  Future<void> completeOnboarding({
    required String topId,
    required String bottomId,
  });
}

/// [OnboardingRemoteDataSource] backed by [FakeBackend] until the API exists.
class FakeOnboardingRemoteDataSource implements OnboardingRemoteDataSource {
  const FakeOnboardingRemoteDataSource(this._backend, this._tokenStore);

  final FakeBackend _backend;
  final AuthTokenStore _tokenStore;

  Future<String> get _token async => await _tokenStore.read() ?? '';

  @override
  Future<void> saveProfile(Map<String, Object?> body) async {
    await _backend.updateProfile(await _token, body);
  }

  @override
  Future<void> completeOnboarding({
    required String topId,
    required String bottomId,
  }) async {
    await _backend.completeOnboarding(await _token, {
      'likedOutfit': {'topId': topId, 'bottomId': bottomId},
    });
  }
}
