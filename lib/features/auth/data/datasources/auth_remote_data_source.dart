import '../models/user_model.dart';

/// Auth endpoints of the Stylper API.
///
/// Implementations throw `ServerException` for API errors and
/// `NetworkException` when the server is unreachable.
abstract interface class AuthRemoteDataSource {
  Future<AuthSessionModel> signInWithEmail(String email, String password);

  Future<AuthSessionModel> signUpWithEmail(String email, String password);

  /// Exchanges a Google ID token for a Stylper session.
  Future<AuthSessionModel> signInWithGoogle();

  /// Exchanges an Apple identity token for a Stylper session.
  Future<AuthSessionModel> signInWithApple();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel> fetchCurrentUser(String accessToken);

  Future<void> signOut(String accessToken);
}
