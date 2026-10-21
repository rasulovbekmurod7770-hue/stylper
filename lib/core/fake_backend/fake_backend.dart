import '../domain/money.dart';
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
  final _saves = <String, List<String>>{}; // userId → postIds, newest first
  final _profiles = <String, Map<String, Object?>>{}; // userId → profile
  final _followers = <String, Set<String>>{}; // userId → follower ids
  final _wardrobes =
      <String, List<String>>{}; // userId → item ids, newest first

  /// Items users added to their wardrobes themselves (not catalog products),
  /// by id; only their owner has the id in their wardrobe.
  final _ownItems = <String, Map<String, Object?>>{};

  /// Every post, newest first: the seeded ones plus those published here.
  var _posts = <String, Map<String, Object?>>{};
  var _nextId = 1;

  void _seed() {
    for (final MapEntry(key: id, value: post) in FakeContent.posts.entries) {
      _posts[id] = Map.of(post);
      _postLikes[id] = post['likes']! as int;
    }
    for (final MapEntry(key: id, value: profile)
        in FakeContent.profiles.entries) {
      _profiles[id] = Map.of(profile);
    }
    for (final MapEntry(key: user, value: posts) in FakeContent.saved.entries) {
      _saves[user] = [...posts];
    }
    for (final MapEntry(key: follower, value: followed)
        in FakeContent.follows.entries) {
      for (final id in followed) {
        _followers.putIfAbsent(id, () => {}).add(follower);
      }
    }
    for (final MapEntry(key: user, value: items)
        in FakeContent.wardrobes.entries) {
      _wardrobes[user] = [...items];
    }
    for (final MapEntry(key: id, value: item) in FakeContent.ownItems.entries) {
      _ownItems[id] = Map.of(item);
    }
    // The demo accounts own the seeded profiles `a_john` / `a_katty`.
    _createUser(
      id: 'a_john',
      email: demoEmail,
      password: demoPassword,
      username: 'john',
      onboardingCompleted: true,
    );
    _createUser(
      id: 'a_katty',
      email: 'katty.miller@stylper.ai',
      password: demoPassword,
      username: 'katty_miller',
      onboardingCompleted: true,
    );
  }

  Map<String, Object?> _createUser({
    required String email,
    required String password,
    String? id,
    String? username,
    bool onboardingCompleted = false,
  }) {
    id ??= 'user_${_nextId++}';
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

  /// GET /posts/:id → `{id, image, author, caption?, location?, likes,
  /// comments, likedByMe, savedByMe, styles, products, similar}`. Public.
  /// `author` is `{id, name, handle, avatar?, followers, followedByMe,
  /// isMe}`, so the post can offer Follow. Each product carries
  /// `{id, name, shortName, brand, price: {amount, currency}, image,
  /// styledCount, tag: {x, y}}`, the tag as fractions of the photo. An item
  /// the author added themselves (not from a catalog) has
  /// `addedByAuthor: true`, no `image`, and `price` only if they gave one.
  Future<Map<String, Object?>> post(String id, {String? token}) async {
    await _delay();
    _postOr404(id);
    return _postDetail(id, _tokens[token]);
  }

  Map<String, Object?> _postDetail(String id, String? viewer) {
    final post = _posts[id]!;
    final authorId = post['author']! as String;
    return {
      ..._postSummary(id, viewer),
      'author': {
        ..._author(authorId),
        ..._followCounts(authorId, viewer),
        'isMe': viewer == authorId,
      },
      'products': [
        for (final tag in post['products']! as List<Object?>)
          _taggedProduct(tag! as Map<String, Object?>, viewer),
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
    final saves = _saves.putIfAbsent(userId, () => []);
    if (saved && !saves.contains(id)) saves.insert(0, id);
    if (!saved) saves.remove(id);
    return _engagement(id, userId);
  }

  Map<String, Object?> _postOr404(String id) =>
      _posts[id] ??
      (throw const ServerException(
        statusCode: 404,
        code: ApiErrorCodes.notFound,
      ));

  Map<String, Object?> _engagement(String postId, String? userId) => {
    'likes': _postLikes[postId],
    'likedByMe': _likedBy[postId]?.contains(userId) ?? false,
    'savedByMe': _saves[userId]?.contains(postId) ?? false,
  };

  Map<String, Object?> _author(String id) {
    final profile = _profileOf(id)!;
    return {
      'id': id,
      'name': profile['name'],
      'handle': profile['handle'],
      'avatar': profile['avatar'],
    };
  }

  /// A user's public profile; accounts without a seeded one get a default.
  /// An account's handle is always its current username.
  Map<String, Object?>? _profileOf(String id) {
    final user = _users[id];
    final profile = _profiles[id];
    if (user == null && profile == null) return null;
    final username = user?['username'] as String?;
    return {
      'name': username ?? (user?['email'] as String?)?.split('@').first,
      'avatar': null,
      'bio': '',
      'styles': const <String>[],
      'followers': 0,
      'following': 0,
      ...?profile,
      'handle': username ?? profile?['handle'],
    };
  }

  Map<String, Object?> _postSummary(String id, String? userId) {
    final post = _posts[id]!;
    return {
      'id': id,
      'image': post['image'],
      'author': _author(post['author']! as String),
      'comments': post['comments'],
      'styles': post['styles'],
      'caption': post['caption'],
      'location': post['location'],
      ..._engagement(id, userId),
    };
  }

  Map<String, Object?> _postPreview(String id) {
    final post = _posts[id]!;
    final thumbnail = FakeContent.thumbnails[id];
    return {
      'id': id,
      'image': thumbnail?.image ?? post['image'],
      'aspectRatio': thumbnail?.aspectRatio ?? 390 / 516,
      'caption': post['caption'],
      'authorHandle': _profileOf(post['author']! as String)!['handle'],
      'styles': post['styles'],
    };
  }

  Map<String, Object?> _taggedProduct(
    Map<String, Object?> tag,
    String? viewer,
  ) {
    if (tag['item'] case final Map<String, Object?> item) {
      return {
        'id': item['id'],
        'name': item['name'],
        'shortName': item['name'],
        'brand': item['brand'],
        if (item['price'] != null) 'price': item['price'],
        'addedByAuthor': true,
        'styledCount': 0,
        'tag': {'x': tag['x'], 'y': tag['y']},
      };
    }
    final id = tag['product']! as String;
    return {
      ..._productSummary(id),
      'styledCount': FakeContent.products[id]!['styledCount'],
      'inWardrobe': _wardrobes[viewer]?.contains(id) ?? false,
      'tag': {'x': tag['x'], 'y': tag['y']},
    };
  }

  Map<String, Object?> _productSummary(String id) {
    final product = FakeContent.products[id]!;
    return {
      'id': id,
      'name': product['name'],
      'shortName': product['shortName'],
      'brand': product['brand'],
      'brandId': product['brandId'],
      'category': product['category'],
      'price': {'amount': product['price'], 'currency': appCurrency},
      'image': product['image'],
    };
  }

  /// GET /products/:id → `{id, name, shortName, brand, category, price,
  /// image, store: {name, url}?, styledCount, inWardrobe, looks, styles,
  /// similar}`. Public. `looks` are the posts that tag the product, `styles`
  /// the styles of those looks (`{name, image}`), `similar` other products
  /// in the same category.
  Future<Map<String, Object?>> product(String id, {String? token}) async {
    await _delay();
    final product =
        FakeContent.products[id] ??
        (throw const ServerException(
          statusCode: 404,
          code: ApiErrorCodes.notFound,
        ));
    final looks = [
      for (final MapEntry(key: postId, value: post) in _posts.entries)
        if ((post['products']! as List<Object?>).any(
          (tag) => (tag! as Map<String, Object?>)['product'] == id,
        ))
          postId,
    ];
    final styles = <String, String>{}; // style → first look's image
    for (final postId in looks) {
      final post = _posts[postId]!;
      for (final style in post['styles']! as List<Object?>) {
        styles.putIfAbsent(style! as String, () => post['image']! as String);
      }
    }
    return {
      ..._productSummary(id),
      'store': FakeContent.stores[product['brand']],
      'styledCount': product['styledCount'],
      'inWardrobe': _wardrobes[_tokens[token]]?.contains(id) ?? false,
      'looks': [for (final postId in looks) _postPreview(postId)],
      'styles': [
        for (final MapEntry(key: name, value: image) in styles.entries)
          {'name': name, 'image': image},
      ],
      'similar': [
        for (final MapEntry(key: other, value: candidate)
            in FakeContent.products.entries)
          if (other != id && candidate['category'] == product['category'])
            _productSummary(other),
      ],
    };
  }

  /// GET /users/:id (`me` for the signed-in user) → `{id, name, handle,
  /// avatar?, bio, styles, posts, followers, following, isMe, followedByMe,
  /// recentPosts}`. Public, except `me`. `posts` is a count; `recentPosts`
  /// are post previews, newest first.
  Future<Map<String, Object?>> userProfile(String id, {String? token}) async {
    await _delay();
    final viewer = _tokens[token];
    final userId = id == 'me' ? _userIdFor(token ?? '') : id;
    final profile =
        _profileOf(userId) ??
        (throw const ServerException(
          statusCode: 404,
          code: ApiErrorCodes.notFound,
        ));
    final posts = [
      for (final MapEntry(key: postId, value: post) in _posts.entries)
        if (post['author'] == userId) postId,
    ];
    return {
      'id': userId,
      'name': profile['name'],
      'handle': profile['handle'],
      'avatar': profile['avatar'],
      'bio': profile['bio'],
      'styles': profile['styles'],
      'posts': posts.length,
      ..._followCounts(userId, viewer),
      'following': (profile['following']! as int) + _followingCount(userId),
      'isMe': viewer == userId,
      'recentPosts': [for (final postId in posts) _postPreview(postId)],
    };
  }

  /// POST /users/:id/follow (following) / DELETE /users/:id/follow →
  /// `{followers, followedByMe}`. Signed-in users only; not yourself.
  Future<Map<String, Object?>> setFollowing(
    String? token,
    String id, {
    required bool following,
  }) async {
    await _delay();
    final viewer = _userIdFor(token ?? '');
    if (_profileOf(id) == null) {
      throw const ServerException(
        statusCode: 404,
        code: ApiErrorCodes.notFound,
      );
    }
    if (id == viewer) {
      throw const ServerException(
        statusCode: 422,
        code: ApiErrorCodes.validation,
      );
    }
    final followers = _followers.putIfAbsent(id, () => {});
    following ? followers.add(viewer) : followers.remove(viewer);
    return _followCounts(id, viewer);
  }

  Map<String, Object?> _followCounts(String userId, String? viewer) => {
    'followers':
        (_profileOf(userId)!['followers']! as int) +
        (_followers[userId]?.length ?? 0),
    'followedByMe': _followers[userId]?.contains(viewer) ?? false,
  };

  int _followingCount(String userId) =>
      _followers.values.where((followers) => followers.contains(userId)).length;

  /// GET /me/saved → `{posts}`: saved post previews, newest first, each
  /// with `author: {id, name, handle, avatar}` and `{likes, likedByMe,
  /// savedByMe}`.
  Future<Map<String, Object?>> savedPosts(String? token) async {
    await _delay();
    final userId = _userIdFor(token ?? '');
    return {
      'posts': [
        for (final postId in _saves[userId] ?? const <String>[])
          {
            ..._postPreview(postId),
            ..._engagement(postId, userId),
            'author': _author(_posts[postId]!['author']! as String),
          },
      ],
    };
  }

  /// GET /me/wardrobe → `{categories: [{id, count, image?}]}`, in display
  /// order; `image` is the newest photo among the category's items.
  Future<Map<String, Object?>> wardrobe(String? token) async {
    await _delay();
    final items = _wardrobeItems(_userIdFor(token ?? ''));
    return {
      'categories': [
        for (final category in FakeContent.wardrobeCategories)
          {
            'id': category,
            'count': items.where((i) => i['category'] == category).length,
            'image': items
                .where((i) => i['category'] == category && i['image'] != null)
                .firstOrNull?['image'],
          },
      ],
    };
  }

  /// GET /me/wardrobe/:category → `{items: [{id, name, brand?, category,
  /// image?, price?, productId?}]}`, newest first. Items the user added
  /// themselves have no `productId`, and no `image` unless seeded with one.
  Future<Map<String, Object?>> wardrobeCategory(
    String? token,
    String category,
  ) async {
    await _delay();
    return {
      'items': [
        for (final item in _wardrobeItems(_userIdFor(token ?? '')))
          if (item['category'] == category) item,
      ],
    };
  }

  /// PUT /me/wardrobe/items/:id (saved) / DELETE /me/wardrobe/items/:id →
  /// `{inWardrobe}`. Only catalog products can be added this way; any item
  /// can be removed.
  Future<Map<String, Object?>> setInWardrobe(
    String? token,
    String itemId, {
    required bool saved,
  }) async {
    await _delay();
    final userId = _userIdFor(token ?? '');
    final items = _wardrobes.putIfAbsent(userId, () => []);
    if (saved) {
      if (!FakeContent.products.containsKey(itemId)) {
        throw const ServerException(
          statusCode: 404,
          code: ApiErrorCodes.notFound,
        );
      }
      if (!items.contains(itemId)) items.insert(0, itemId);
    } else {
      items.remove(itemId);
    }
    return {'inWardrobe': saved};
  }

  /// POST /me/wardrobe/items — body `{name, brand, category, price?:
  /// {amount, currency}}` → the item, as in GET /me/wardrobe/:category
  /// (without `image`). For clothes no brand on Stylper sells: the item is
  /// private to the user's wardrobe and never in product search; tagged on
  /// a post, its name, brand and price are shown to everyone. 422 when
  /// `name` / `brand` are blank, `category` is unknown or `price` isn't
  /// positive.
  Future<Map<String, Object?>> addWardrobeItem(
    String? token,
    Map<String, Object?> body,
  ) async {
    await _delay();
    final userId = _userIdFor(token ?? '');
    final name = (body['name'] as String?)?.trim() ?? '';
    final brand = (body['brand'] as String?)?.trim() ?? '';
    final category = body['category'] as String?;
    final price = body['price'] as Map<String, Object?>?;
    final amount = price?['amount'] as num?;
    if (name.isEmpty ||
        brand.isEmpty ||
        !FakeContent.wardrobeCategories.contains(category) ||
        (price != null &&
            (amount == null || amount <= 0 || price['currency'] is! String))) {
      throw const ServerException(
        statusCode: 422,
        code: ApiErrorCodes.validation,
      );
    }
    final id = 'w_${_nextId++}';
    _ownItems[id] = {
      'category': category,
      'name': name,
      'brand': brand,
      if (price != null)
        'price': {'amount': amount, 'currency': price['currency']},
    };
    _wardrobes.putIfAbsent(userId, () => []).insert(0, id);
    return {'id': id, ..._ownItems[id]!};
  }

  List<Map<String, Object?>> _wardrobeItems(String userId) => [
    for (final id in _wardrobes[userId] ?? const <String>[])
      if (FakeContent.products.containsKey(id))
        {..._productSummary(id), 'productId': id}
      else if (_ownItems[id] case final item?)
        {'id': id, ...item},
  ];

  /// GET /search/discover → `{city, brands, trending}`: what Search shows
  /// before anything is typed — every brand (local brands first) and the
  /// trending looks as post previews. Public.
  Future<Map<String, Object?>> searchDiscover() async {
    await _delay();
    final brands = FakeContent.brands.keys.toList()
      ..sort((a, b) => _localFirst(a) - _localFirst(b));
    return {
      'city': FakeContent.city,
      'brands': [for (final id in brands) _brandSummary(id)],
      'trending': [for (final id in FakeContent.trending) _postPreview(id)],
    };
  }

  /// GET /search?q= → `{people, brands}`, at most 20 of each. Public.
  /// Matches usernames and names, ignoring case and a leading `@`: an exact
  /// username first, then usernames starting with the query, then names
  /// with a word starting with it, then anything containing it; among
  /// equals, local brands and then more-followed people first. People are
  /// `{id, name, handle, avatar?, followers, followedByMe, isMe}` (for their
  /// Follow button); brands `{id, name, handle, logo?, local, verified,
  /// products}`, `products` being how many catalog items they sell.
  Future<Map<String, Object?>> search(String query, {String? token}) async {
    await _delay();
    final q = query.trim().toLowerCase().replaceFirst(RegExp('^@'), '');
    if (q.isEmpty) return {'people': const [], 'brands': const []};
    final viewer = _tokens[token];

    // Lower is better; null means no match.
    int? rank(String handle, String name) {
      handle = handle.toLowerCase();
      name = name.toLowerCase();
      if (handle == q) return 0;
      if (handle.startsWith(q)) return 1;
      if (name.startsWith(q) || name.contains(' $q')) return 2;
      if (handle.contains(q) || name.contains(q)) return 3;
      return null;
    }

    final people =
        [
          for (final id in {..._profiles.keys, ..._users.keys})
            if (_profileOf(id) case final profile?
                when profile['handle'] != null)
              if (rank(profile['handle']! as String, profile['name']! as String)
                  case final r?)
                (id: id, rank: r, followers: _followCounts(id, viewer)),
        ]..sort(
          (a, b) => a.rank != b.rank
              ? a.rank - b.rank
              : (b.followers['followers']! as int) -
                    (a.followers['followers']! as int),
        );
    final brands =
        [
          for (final MapEntry(key: id, value: brand)
              in FakeContent.brands.entries)
            if (rank(brand['handle']! as String, brand['name']! as String)
                case final r?)
              (id: id, rank: r),
        ]..sort(
          (a, b) => a.rank != b.rank
              ? a.rank - b.rank
              : _localFirst(a.id) - _localFirst(b.id),
        );

    return {
      'people': [
        for (final person in people.take(20))
          {
            ..._author(person.id),
            ...person.followers,
            'isMe': viewer == person.id,
          },
      ],
      'brands': [for (final brand in brands.take(20)) _brandSummary(brand.id)],
    };
  }

  int _localFirst(String brandId) =>
      FakeContent.brands[brandId]!['local']! as bool ? 0 : 1;

  Map<String, Object?> _brandSummary(String id) {
    final brand = FakeContent.brands[id]!;
    return {
      'id': id,
      'name': brand['name'],
      'handle': brand['handle'],
      'logo': brand['logo'],
      'local': brand['local'],
      // Every brand on Stylper is an official showroom for now.
      'verified': true,
      'products': FakeContent.products.values
          .where((product) => product['brandId'] == id)
          .length,
    };
  }

  /// GET /styles → `{styles}`: every style a post can be tagged with.
  Future<Map<String, Object?>> postStyles() async {
    await _delay();
    return {'styles': FakeContent.allStyles};
  }

  /// GET /products/search?q=&category=&mine= → `{products, items}`. Public.
  /// Every word of `q` must appear in the brand, name or item type, so
  /// "jeans zara" finds ZARA's jeans; `category` (tops / bottoms / shoes /
  /// accessories) narrows it down; `mine` keeps only the signed-in user's
  /// wardrobe. Products belong to brand and business profiles (`brandId`).
  /// `items` are the items the user added to their wardrobe themselves
  /// (as in GET /me/wardrobe/:category), newest first — only with `mine`.
  Future<Map<String, Object?>> searchProducts({
    String query = '',
    String? category,
    bool mine = false,
    String? token,
  }) async {
    await _delay();
    final wardrobe = mine
        ? _wardrobes[_userIdFor(token ?? '')] ?? const []
        : null;
    final words = query.toLowerCase().split(RegExp(r'\s+'))
      ..removeWhere((word) => word.isEmpty);
    bool matches(Map<String, Object?> item, List<String> fields) =>
        (category == null || item['category'] == category) &&
        words.every(
          (word) => fields.any(
            (field) => '${item[field] ?? ''}'.toLowerCase().contains(word),
          ),
        );
    return {
      'items': [
        for (final id in wardrobe ?? const <String>[])
          if (_ownItems[id] case final item?)
            if (matches(item, const ['brand', 'name'])) {'id': id, ...item},
      ],
      'products': [
        for (final MapEntry(key: id, value: product)
            in FakeContent.products.entries)
          if ((category == null || product['category'] == category) &&
              (wardrobe == null || wardrobe.contains(id)) &&
              words.every(
                (word) => [
                  product['brand'],
                  product['name'],
                  product['shortName'],
                ].any((field) => '$field'.toLowerCase().contains(word)),
              ))
            _productSummary(id),
      ],
    };
  }

  /// GET /me/recent-tags → `{products}`: catalog products the user tagged in
  /// their own posts, most recent first, without repeats.
  Future<Map<String, Object?>> recentTags(String? token) async {
    await _delay();
    final userId = _userIdFor(token ?? '');
    final seen = <String>{};
    return {
      'products': [
        for (final post in _posts.values)
          if (post['author'] == userId)
            for (final tag
                in (post['products']! as List<Object?>)
                    .cast<Map<String, Object?>>())
              if (tag['product'] case final String id)
                if (seen.add(id)) _productSummary(id),
      ],
    };
  }

  /// POST /posts — body `{image, caption?, location?, styles, tags:
  /// [{productId | itemId, x, y}], allowBrandFeature}` → the new post, as
  /// from GET /posts/:id. Signed-in users only; every post is public (there's
  /// no audience setting). A tag names a catalog product, or (`itemId`) an
  /// item the author added to their own wardrobe, copied into the post so it
  /// stays even if they later remove it. The real API takes the photo as a
  /// multipart upload and returns its URL; here `image` stays the local file
  /// path.
  Future<Map<String, Object?>> publishPost(
    String? token,
    Map<String, Object?> body,
  ) async {
    await _delay();
    final userId = _userIdFor(token ?? '');
    final image = body['image'] as String?;
    final tags = (body['tags'] as List<Object?>? ?? const [])
        .cast<Map<String, Object?>>();
    final wardrobe = _wardrobes[userId] ?? const <String>[];
    bool valid(Map<String, Object?> tag) => switch (tag) {
      {'productId': final String id} => FakeContent.products.containsKey(id),
      {'itemId': final String id} =>
        wardrobe.contains(id) && _ownItems.containsKey(id),
      _ => false,
    };
    if (image == null || image.isEmpty || !tags.every(valid)) {
      throw const ServerException(
        statusCode: 422,
        code: ApiErrorCodes.validation,
      );
    }
    final styles = [...?(body['styles'] as List<Object?>?)?.cast<String>()];
    final id = 'post_${_nextId++}';
    final similar = [
      for (final MapEntry(key: other, value: post) in _posts.entries)
        if ((post['styles']! as List<Object?>).any(styles.contains)) other,
    ].take(4).toList();
    _posts = {
      id: {
        'author': userId,
        'image': image,
        'likes': 0,
        'comments': 0,
        'styles': styles,
        'caption': body['caption'],
        'location': body['location'],
        'allowBrandFeature': body['allowBrandFeature'] ?? false,
        'products': [
          for (final tag in tags)
            if (tag['itemId'] case final String itemId)
              {
                'item': {
                  'id': itemId,
                  'name': _ownItems[itemId]!['name'],
                  'brand': _ownItems[itemId]!['brand'],
                  'price': _ownItems[itemId]!['price'],
                },
                'x': tag['x'],
                'y': tag['y'],
              }
            else
              {'product': tag['productId'], 'x': tag['x'], 'y': tag['y']},
        ],
        'similar': similar,
      },
      ..._posts,
    };
    _postLikes[id] = 0;
    return _postDetail(id, userId);
  }
}
