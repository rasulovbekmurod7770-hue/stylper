/// Persists the API access token between requests (and, later, app launches).
abstract interface class AuthTokenStore {
  Future<String?> read();
  Future<void> save(String token);
  Future<void> clear();
}

/// Keeps the token in memory only, so every app launch starts signed out.
///
/// Replace with a secure-storage implementation (Keychain / Keystore) once the
/// real backend issues long-lived tokens.
class InMemoryAuthTokenStore implements AuthTokenStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> save(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
