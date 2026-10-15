import 'package:equatable/equatable.dart';

// Image fields hold a bundled asset path for now; an image URL once the feed
// comes from the API.

class FeedAuthor extends Equatable {
  const FeedAuthor({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarPath,
  });

  final String id;
  final String name;

  /// Username without the leading `@`.
  final String handle;
  final String avatarPath;

  @override
  List<Object?> get props => [id, name, handle, avatarPath];
}

/// A large "For you" post at the top of the feed.
class FeaturedPost extends Equatable {
  const FeaturedPost({
    required this.id,
    required this.imagePath,
    required this.author,
    required this.likeCount,
    required this.commentCount,
    this.tags = const [],
  });

  final String id;
  final String imagePath;
  final FeedAuthor author;
  final int likeCount;
  final int commentCount;

  /// Style chips on the card; the first is the post's main style.
  final List<String> tags;

  @override
  List<Object?> get props => [
    id,
    imagePath,
    author,
    likeCount,
    commentCount,
    tags,
  ];
}

/// Someone shown under "People wearing".
class PersonPreview extends Equatable {
  const PersonPreview({
    required this.id,
    required this.name,
    required this.photoPath,
  });

  final String id;
  final String name;
  final String photoPath;

  @override
  List<Object?> get props => [id, name, photoPath];
}

/// A card in the "Trending in {city}" grid.
class TrendingPost extends Equatable {
  const TrendingPost({
    required this.id,
    required this.imagePath,
    required this.aspectRatio,
    this.caption,
    this.authorHandle,
  });

  final String id;
  final String imagePath;

  /// Width / height of the card, so the grid can stagger like the design.
  final double aspectRatio;
  final String? caption;

  /// Username without the leading `@`.
  final String? authorHandle;

  @override
  List<Object?> get props => [
    id,
    imagePath,
    aspectRatio,
    caption,
    authorHandle,
  ];
}

class HomeFeed extends Equatable {
  const HomeFeed({
    required this.city,
    required this.featured,
    required this.peopleWearing,
    required this.trending,
  });

  /// City the "Trending in" section is about.
  final String city;
  final List<FeaturedPost> featured;
  final List<PersonPreview> peopleWearing;
  final List<TrendingPost> trending;

  @override
  List<Object?> get props => [city, featured, peopleWearing, trending];
}
