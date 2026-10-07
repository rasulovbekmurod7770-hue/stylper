import '../../../../core/error/exceptions.dart';
import '../../../../core/fake_backend/fake_backend.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

/// [AuthRemoteDataSource] backed by [FakeBackend] until the real API exists.
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  const FakeAuthRemoteDataSource(this._backend);

  final FakeBackend _backend;

  @override
  Future<AuthSessionModel> signInWithEmail(
    String email,
    String password,
  ) async => AuthSessionModel.fromJson(await _backend.login(email, password));

  @override
  Future<AuthSessionModel> signUpWithEmail(
    String email,
    String password,
  ) async =>
      AuthSessionModel.fromJson(await _backend.register(email, password));

  // Real Google/Apple sign-in needs OAuth client IDs and a backend endpoint
  // that verifies the provider token; neither exists yet.
  @override
  Future<AuthSessionModel> signInWithGoogle() => _providerUnavailable();

  @override
  Future<AuthSessionModel> signInWithApple() => _providerUnavailable();

  Future<AuthSessionModel> _providerUnavailable() async {
    await Future<void>.delayed(_backend.latency ~/ 2);
    throw const ServerException(
      statusCode: 501,
      code: ApiErrorCodes.providerUnavailable,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _backend.requestPasswordReset(email);

  @override
  Future<UserModel> fetchCurrentUser(String accessToken) async =>
      UserModel.fromJson(await _backend.me(accessToken));

  @override
  Future<void> signOut(String accessToken) => _backend.logout(accessToken);
}
