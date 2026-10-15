import '../../../post/data/models/post_json.dart';
import '../../domain/entities/home_feed.dart';

/// Parses the `GET /feed/home` response body.
abstract final class HomeFeedJson {
  static HomeFeed parse(JsonMap json) => HomeFeed(
    city: json['city']! as String,
    styles: [...?(json['styles'] as List<Object?>?)?.cast<String>()],
    featured: PostJson.list(json['featured'], _featured),
    peopleWearing: PostJson.list(json['peopleWearing'], _person),
    trending: PostJson.list(json['trending'], PostJson.preview),
  );

  static FeaturedPost _featured(JsonMap json) => FeaturedPost(
    id: json['id']! as String,
    imagePath: json['image']! as String,
    author: PostJson.author(json['author']! as JsonMap),
    engagement: PostJson.engagement(json),
    commentCount: json['comments']! as int,
    styles: [...?(json['styles'] as List<Object?>?)?.cast<String>()],
  );

  static PersonPreview _person(JsonMap json) => PersonPreview(
    id: json['id']! as String,
    name: json['name']! as String,
    photoPath: json['photo']! as String,
    postId: json['postId']! as String,
  );
}
