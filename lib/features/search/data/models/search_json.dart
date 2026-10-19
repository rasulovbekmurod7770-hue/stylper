import '../../../post/data/models/post_json.dart';
import '../../domain/entities/search_results.dart';

/// Parses the search endpoints' response bodies.
abstract final class SearchJson {
  /// `GET /search/discover`.
  static SearchDiscovery discovery(JsonMap json) => SearchDiscovery(
    city: json['city']! as String,
    brands: PostJson.list(json['brands'], brand),
    trending: PostJson.list(json['trending'], PostJson.preview),
  );

  /// `GET /search?q=`: people have the shape of a post's author.
  static SearchResults results(JsonMap json) => SearchResults(
    brands: PostJson.list(json['brands'], brand),
    people: PostJson.list(json['people'], PostJson.author),
  );

  static BrandSummary brand(JsonMap json) => BrandSummary(
    id: json['id']! as String,
    name: json['name']! as String,
    handle: json['handle']! as String,
    logoPath: json['logo'] as String?,
    isLocal: json['local'] as bool? ?? false,
    isVerified: json['verified'] as bool? ?? false,
    productCount: json['products'] as int? ?? 0,
  );
}
