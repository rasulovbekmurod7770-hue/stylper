import '../../domain/entities/post.dart';

typedef JsonMap = Map<String, Object?>;

/// Parses post payloads of the API. The pieces are public so other features'
/// payloads that embed posts (e.g. the home feed) parse them the same way.
abstract final class PostJson {
  static Post post(JsonMap json) => Post(
    id: json['id']! as String,
    imagePath: json['image']! as String,
    author: author(json['author']! as JsonMap),
    engagement: engagement(json),
    commentCount: json['comments']! as int,
    products: list(json['products'], _product),
    similar: list(json['similar'], preview),
  );

  static PostAuthor author(JsonMap json) => PostAuthor(
    id: json['id']! as String,
    name: json['name']! as String,
    handle: json['handle']! as String,
    avatarPath: json['avatar'] as String?,
  );

  /// Reads `{likes, likedByMe?, savedByMe?}` (missing flags mean "no").
  static PostEngagement engagement(JsonMap json) => PostEngagement(
    likeCount: json['likes']! as int,
    liked: json['likedByMe'] as bool? ?? false,
    saved: json['savedByMe'] as bool? ?? false,
  );

  static PostPreview preview(JsonMap json) => PostPreview(
    id: json['id']! as String,
    imagePath: json['image']! as String,
    aspectRatio: (json['aspectRatio']! as num).toDouble(),
    caption: json['caption'] as String?,
    authorHandle: json['authorHandle'] as String?,
    styles: strings(json['styles']),
  );

  /// A JSON array of strings; null or missing reads as empty.
  static List<String> strings(Object? json) => [
    ...?(json as List<Object?>?)?.cast<String>(),
  ];

  /// A JSON array of objects; null or missing reads as empty.
  static List<T> list<T>(Object? json, T Function(JsonMap) parse) => [
    for (final item in (json as List<Object?>?) ?? const [])
      parse(item! as JsonMap),
  ];

  static TaggedProduct _product(JsonMap json) {
    final price = json['price']! as JsonMap;
    final tag = json['tag']! as JsonMap;
    return TaggedProduct(
      id: json['id']! as String,
      name: json['name']! as String,
      shortName: json['shortName']! as String,
      brand: json['brand']! as String,
      price: Money(
        amount: price['amount']! as num,
        currency: price['currency']! as String,
      ),
      imagePath: json['image']! as String,
      styledCount: json['styledCount']! as int,
      tagX: (tag['x']! as num).toDouble(),
      tagY: (tag['y']! as num).toDouble(),
      inWardrobe: json['inWardrobe'] as bool? ?? false,
    );
  }
}
