import 'package:equatable/equatable.dart';

import '../../../post/domain/entities/post.dart';

// Image fields hold a bundled asset path for now; an image URL once the feed
// comes from the API.

/// A large "For you" post at the top of the feed.
class FeaturedPost extends Equatable {
  const FeaturedPost({
    required this.id,
    required this.imagePath,
    required this.author,
    required this.engagement,
    required this.commentCount,
    this.styles = const [],
  });

  /// The post's id.
  final String id;

  /// The card crop (366×300).
  final String imagePath;
  final PostAuthor author;
  final PostEngagement engagement;
  final int commentCount;

  /// Styles the post belongs to, from [HomeFeed.styles].
  final List<String> styles;

  @override
  List<Object?> get props => [
    id,
    imagePath,
    author,
    engagement,
    commentCount,
    styles,
  ];
}

/// Someone shown under "People wearing"; opens their outfit post.
class PersonPreview extends Equatable {
  const PersonPreview({
    required this.id,
    required this.name,
    required this.photoPath,
    required this.postId,
  });

  final String id;
  final String name;
  final String photoPath;
  final String postId;

  @override
  List<Object?> get props => [id, name, photoPath, postId];
}

class HomeFeed extends Equatable {
  const HomeFeed({
    required this.city,
    required this.featured,
    required this.peopleWearing,
    required this.trending,
    this.styles = const [],
  });

  /// City the "Trending in" section is about.
  final String city;

  /// Style chips on the "For you" card, e.g. Casual / Minimal / Street.
  final List<String> styles;
  final List<FeaturedPost> featured;
  final List<PersonPreview> peopleWearing;
  final List<PostPreview> trending;

  /// Featured posts in [style]; all of them when none match.
  List<FeaturedPost> featuredIn(String? style) {
    final matching = [
      for (final post in featured)
        if (post.styles.contains(style)) post,
    ];
    return matching.isEmpty ? featured : matching;
  }

  @override
  List<Object?> get props => [city, styles, featured, peopleWearing, trending];
}
