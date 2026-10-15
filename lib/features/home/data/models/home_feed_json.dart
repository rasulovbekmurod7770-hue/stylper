import '../../domain/entities/home_feed.dart';

typedef _Json = Map<String, Object?>;

/// Parses the `GET /feed/home` response body.
abstract final class HomeFeedJson {
  static HomeFeed parse(Map<String, Object?> json) => HomeFeed(
    city: json['city']! as String,
    featured: _list(json['featured'], _featured),
    peopleWearing: _list(json['peopleWearing'], _person),
    trending: _list(json['trending'], _trending),
  );

  static List<T> _list<T>(Object? json, T Function(_Json) parse) => [
    for (final item in json! as List<Object?>) parse(item! as _Json),
  ];

  static FeaturedPost _featured(_Json json) => FeaturedPost(
    id: json['id']! as String,
    imagePath: json['image']! as String,
    author: _author(json['author']! as _Json),
    likeCount: json['likes']! as int,
    commentCount: json['comments']! as int,
    tags: [...?(json['tags'] as List<Object?>?)?.cast<String>()],
  );

  static FeedAuthor _author(_Json json) => FeedAuthor(
    id: json['id']! as String,
    name: json['name']! as String,
    handle: json['handle']! as String,
    avatarPath: json['avatar']! as String,
  );

  static PersonPreview _person(_Json json) => PersonPreview(
    id: json['id']! as String,
    name: json['name']! as String,
    photoPath: json['photo']! as String,
  );

  static TrendingPost _trending(_Json json) => TrendingPost(
    id: json['id']! as String,
    imagePath: json['image']! as String,
    aspectRatio: (json['aspectRatio']! as num).toDouble(),
    caption: json['caption'] as String?,
    authorHandle: json['authorHandle'] as String?,
  );
}
