import '../error/exceptions.dart';
import 'fake_content.dart';

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
  final _postLikes = <String, int>{}; // postId → like count
  final _likedBy = <String, Set<String>>{}; // postId → userIds
  final _savedBy = <String, Set<String>>{}; // postId → userIds
  var _nextId = 1;

  void _seed() {
    for (final MapEntry(key: id, value: post) in FakeContent.posts.entries) {
      _postLikes[id] = post['likes']! as int;
    }
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

  /// GET /feed/home → `{city, styles, featured, peopleWearing, trending}`.
  /// Public, so guests get it too; with a [token], `likedByMe` / `savedByMe`
  /// are the signed-in user's. Featured posts carry their `styles` so the app
  /// can filter the carousel by the selected style.
  Future<Map<String, Object?>> homeFeed({String? token}) async {
    await _delay();
    final userId = _tokens[token];
    return {
      'city': FakeContent.city,
      'styles': FakeContent.styles,
      'featured': [
        for (final item in FakeContent.featured)
          {..._postSummary(item['post']!, userId), 'image': item['image']},
      ],
      'peopleWearing': [
        for (final person in FakeContent.peopleWearing)
          {
            'id': person['id'],
            'name': person['name'],
            'photo': person['photo'],
            'postId': person['post'],
          },
      ],
      'trending': [for (final id in FakeContent.trending) _postPreview(id)],
    };
  }

  /// GET /posts/:id → `{id, image, author, likes, comments, likedByMe,
  /// savedByMe, styles, products, similar}`. Public. Each product carries
  /// `{id, name, shortName, brand, price: {amount, currency}, image,
  /// styledCount, tag: {x, y}}`, the tag as fractions of the photo.
  Future<Map<String, Object?>> post(String id, {String? token}) async {
    await _delay();
    final post = _postOr404(id);
    return {
      ..._postSummary(id, _tokens[token]),
      'products': [
        for (final tag in post['products']! as List<Object?>)
          _taggedProduct(tag! as Map<String, Object?>),
      ],
      'similar': [
        for (final similar in post['similar']! as List<Object?>)
          _postPreview(similar! as String),
      ],
    };
  }

  /// POST /posts/:id/like (liked) / DELETE /posts/:id/like →
  /// `{likes, likedByMe, savedByMe}`. Signed-in users only.
  Future<Map<String, Object?>> setLiked(
    String? token,
    String id, {
    required bool liked,
  }) async {
    await _delay();
    final userId = _userIdFor(token ?? '');
    _postOr404(id);
    final likers = _likedBy.putIfAbsent(id, () => {});
    final changed = liked ? likers.add(userId) : likers.remove(userId);
    if (changed) _postLikes[id] = _postLikes[id]! + (liked ? 1 : -1);
    return _engagement(id, userId);
  }

  /// PUT /posts/:id/save (saved) / DELETE /posts/:id/save →
  /// `{likes, likedByMe, savedByMe}`. Signed-in users only.
  Future<Map<String, Object?>> setSaved(
    String? token,
    String id, {
    required bool saved,
  }) async {
    await _delay();
    final userId = _userIdFor(token ?? '');
    _postOr404(id);
    final savers = _savedBy.putIfAbsent(id, () => {});
    saved ? savers.add(userId) : savers.remove(userId);
    return _engagement(id, userId);
  }

  Map<String, Object?> _postOr404(String id) =>
      FakeContent.posts[id] ??
      (throw const ServerException(
        statusCode: 404,
        code: ApiErrorCodes.notFound,
      ));

  Map<String, Object?> _engagement(String postId, String? userId) => {
    'likes': _postLikes[postId],
    'likedByMe': _likedBy[postId]?.contains(userId) ?? false,
    'savedByMe': _savedBy[postId]?.contains(userId) ?? false,
  };

  Map<String, Object?> _author(String id) => {
    'id': id,
    ...FakeContent.authors[id]!,
  };

  Map<String, Object?> _postSummary(String id, String? userId) {
    final post = FakeContent.posts[id]!;
    return {
      'id': id,
      'image': post['image'],
      'author': _author(post['author']! as String),
      'comments': post['comments'],
      'styles': post['styles'],
      ..._engagement(id, userId),
    };
  }

  Map<String, Object?> _postPreview(String id) {
    final post = FakeContent.posts[id]!;
    final thumbnail = FakeContent.thumbnails[id];
    return {
      'id': id,
      'image': thumbnail?.image ?? post['image'],
      'aspectRatio': thumbnail?.aspectRatio ?? 390 / 516,
      'caption': post['caption'],
      'authorHandle': FakeContent.authors[post['author']]!['handle'],
    };
  }

  Map<String, Object?> _taggedProduct(Map<String, Object?> tag) {
    final id = tag['product']! as String;
    final product = FakeContent.products[id]!;
    return {
      'id': id,
      'name': product['name'],
      'shortName': product['shortName'],
      'brand': product['brand'],
      'price': {'amount': product['price'], 'currency': 'USD'},
      'image': product['image'],
      'styledCount': product['styledCount'],
      'tag': {'x': tag['x'], 'y': tag['y']},
    };
  }
}
