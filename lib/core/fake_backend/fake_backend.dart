import '../error/exceptions.dart';

/// In-memory stand-in for the Stylper REST API, used until the real backend
/// exists. Each method mirrors one endpoint, takes/returns JSON-like maps and
/// throws [ServerException] with the same error codes the API should use, so
/// feature data sources can be swapped for HTTP ones without other changes.
///
/// State lives only in memory: restarting the app resets it to the seed data.
class FakeBackend {
  FakeBackend({this.latency = const Duration(milliseconds: 600)}) {
    _seed();
  }

  /// Simulated network delay for every call.
  final Duration latency;

  static const demoEmail = 'developer@stylper.ai';
  static const demoPassword = 'stylper123';

  static const _minPasswordLength = 8;
  static final _usernamePattern = RegExp(r'^[a-z0-9_.]{3,20}$');

  final _users = <String, Map<String, Object?>>{}; // userId → public user
  final _passwords = <String, String>{}; // email → password
  final _tokens = <String, String>{}; // token → userId
  final _usernames = <String, String>{}; // username → userId
  final _bodyMetrics = <String, Map<String, Object?>>{}; // userId → private
  final _outfitLikes = <String, List<Map<String, Object?>>>{};
  var _nextId = 1;

  void _seed() {
    _createUser(
      email: demoEmail,
      password: demoPassword,
      username: 'developer',
      onboardingCompleted: true,
    );
    _createUser(
      email: 'katty.miller@stylper.ai',
      password: demoPassword,
      username: 'katty_miller',
      onboardingCompleted: true,
    );
  }

  Map<String, Object?> _createUser({
    required String email,
    required String password,
    String? username,
    bool onboardingCompleted = false,
  }) {
    final id = 'user_${_nextId++}';
    final user = <String, Object?>{
      'id': id,
      'email': email,
      'username': username,
      'onboardingCompleted': onboardingCompleted,
    };
    _users[id] = user;
    _passwords[email] = password;
    if (username != null) _usernames[username] = id;
    return user;
  }

  Map<String, Object?> _session(String userId) {
    final token =
        'fake_token_${userId}_${DateTime.now().microsecondsSinceEpoch}';
    _tokens[token] = userId;
    return {'accessToken': token, 'user': Map.of(_users[userId]!)};
  }

  String _userIdFor(String token) =>
      _tokens[token] ??
      (throw const ServerException(
        statusCode: 401,
        code: ApiErrorCodes.unauthorized,
      ));

  Future<void> _delay() => Future<void>.delayed(latency);

  /// POST /auth/login → `{accessToken, user}`
  Future<Map<String, Object?>> login(String email, String password) async {
    await _delay();
    final key = email.toLowerCase();
    if (_passwords[key] != password) {
      throw const ServerException(
        statusCode: 401,
        code: ApiErrorCodes.invalidCredentials,
      );
    }
    final user = _users.values.firstWhere((u) => u['email'] == key);
    return _session(user['id']! as String);
  }

  /// POST /auth/register → `{accessToken, user}`
  Future<Map<String, Object?>> register(String email, String password) async {
    await _delay();
    final key = email.toLowerCase();
    if (_passwords.containsKey(key)) {
      throw const ServerException(
        statusCode: 409,
        code: ApiErrorCodes.emailTaken,
      );
    }
    if (password.length < _minPasswordLength) {
      throw const ServerException(
        statusCode: 422,
        code: ApiErrorCodes.weakPassword,
      );
    }
    final user = _createUser(email: key, password: password);
    return _session(user['id']! as String);
  }

  /// POST /auth/password-reset — always succeeds so emails can't be enumerated.
  Future<void> requestPasswordReset(String email) => _delay();

  /// GET /me → user
  Future<Map<String, Object?>> me(String token) async {
    await _delay();
    return Map.of(_users[_userIdFor(token)]!);
  }

  /// POST /auth/logout
  Future<void> logout(String token) async {
    await _delay();
    _tokens.remove(token);
  }

  /// PUT /me/profile → user.
  /// Body: `{username, gender, age?, heightCm?, weightKg?}`. Body metrics are
  /// stored privately and never returned in public user payloads.
  Future<Map<String, Object?>> updateProfile(
    String token,
    Map<String, Object?> body,
  ) async {
    await _delay();
    final userId = _userIdFor(token);
    final username = body['username'] as String?;
    if (username == null || !_usernamePattern.hasMatch(username)) {
      throw const ServerException(
        statusCode: 422,
        code: ApiErrorCodes.validation,
      );
    }
    final owner = _usernames[username];
    if (owner != null && owner != userId) {
      throw const ServerException(
        statusCode: 409,
        code: ApiErrorCodes.usernameTaken,
      );
    }

    final user = _users[userId]!;
    final previous = user['username'] as String?;
    if (previous != null && previous != username) _usernames.remove(previous);
    _usernames[username] = userId;
    user['username'] = username;
    user['gender'] = body['gender'];
    _bodyMetrics[userId] = {
      'age': body['age'],
      'heightCm': body['heightCm'],
      'weightKg': body['weightKg'],
    };
    return Map.of(user);
  }

  /// POST /me/onboarding/complete → user.
  /// Body: `{likedOutfit: {topId, bottomId}}`.
  Future<Map<String, Object?>> completeOnboarding(
    String token,
    Map<String, Object?> body,
  ) async {
    await _delay();
    final userId = _userIdFor(token);
    final liked = body['likedOutfit'];
    if (liked is Map<String, Object?>) {
      (_outfitLikes[userId] ??= []).add(Map.of(liked));
    }
    final user = _users[userId]!..['onboardingCompleted'] = true;
    return Map.of(user);
  }
}
