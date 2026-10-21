import 'package:equatable/equatable.dart';

import '../../../../core/domain/money.dart';

export '../../../../core/domain/money.dart';

// Image fields hold a bundled asset path for now; an image URL once posts
// come from the API.

/// A person on Stylper: a post's author, or a person in search results.
class PostAuthor extends Equatable {
  const PostAuthor({
    required this.id,
    required this.name,
    required this.handle,
    this.avatarPath,
    this.followerCount = 0,
    this.followedByMe = false,
    this.isMe = false,
  });

  final String id;
  final String name;

  /// Username without the leading `@`.
  final String handle;

  /// Null when the user has no photo; the app shows initials.
  final String? avatarPath;

  /// Only an opened post and search results carry these (for the Follow
  /// button); feed cards leave the defaults.
  final int followerCount;
  final bool followedByMe;

  /// The signed-in viewer wrote the post: nobody to follow.
  final bool isMe;

  @override
  List<Object?> get props => [
    id,
    name,
    handle,
    avatarPath,
    followerCount,
    followedByMe,
    isMe,
  ];
}

/// The signed-in viewer's like / save state for a post, with its like count.
class PostEngagement extends Equatable {
  const PostEngagement({
    required this.likeCount,
    this.liked = false,
    this.saved = false,
  });

  final int likeCount;
  final bool liked;
  final bool saved;

  PostEngagement copyWith({int? likeCount, bool? liked, bool? saved}) =>
      PostEngagement(
        likeCount: likeCount ?? this.likeCount,
        liked: liked ?? this.liked,
        saved: saved ?? this.saved,
      );

  @override
  List<Object?> get props => [likeCount, liked, saved];
}

/// A clothing item tagged on a post photo — "what is it and where to get it".
/// Usually a catalog product; or clothes no brand on Stylper sells, which
/// the author added to their own wardrobe ([addedByAuthor]).
class TaggedProduct extends Equatable {
  const TaggedProduct({
    required this.id,
    required this.name,
    required this.shortName,
    required this.brand,
    required this.price,
    required this.imagePath,
    required this.styledCount,
    required this.tagX,
    required this.tagY,
    this.inWardrobe = false,
    this.addedByAuthor = false,
  });

  /// The product's id; for [addedByAuthor] items, the author's wardrobe
  /// item (there's no product page to open).
  final String id;

  /// Full product name, e.g. "Oversized Wool Cardigan".
  final String name;

  /// Item type for compact labels, e.g. "Cardigan".
  final String shortName;
  final String brand;

  /// Null when the author added the item without one.
  final Money? price;

  /// Null for items the author added (they have no photo).
  final String? imagePath;

  /// How many people posted outfits with this item.
  final int styledCount;

  /// Where the tag dot sits on the photo, as fractions of its width / height.
  final double tagX;
  final double tagY;

  /// Whether it's in the signed-in user's wardrobe.
  final bool inWardrobe;

  /// Not from a brand's catalog: the post's author added it themselves.
  final bool addedByAuthor;

  @override
  List<Object?> get props => [
    id,
    name,
    shortName,
    brand,
    price,
    imagePath,
    styledCount,
    tagX,
    tagY,
    addedByAuthor,
    inWardrobe,
  ];
}

/// A post as a grid card ("Trending", "Similar").
class PostPreview extends Equatable {
  const PostPreview({
    required this.id,
    required this.imagePath,
    required this.aspectRatio,
    this.caption,
    this.authorHandle,
    this.styles = const [],
  });

  /// The post's id.
  final String id;
  final String imagePath;

  /// Width / height of the card, so grids can stagger.
  final double aspectRatio;
  final String? caption;

  /// Username without the leading `@`.
  final String? authorHandle;

  /// Styles the post belongs to, e.g. "Casual".
  final List<String> styles;

  @override
  List<Object?> get props => [
    id,
    imagePath,
    aspectRatio,
    caption,
    authorHandle,
    styles,
  ];
}

/// A full outfit post (Figma "home-feed-2", 2775:2840).
class Post extends Equatable {
  const Post({
    required this.id,
    required this.imagePath,
    required this.author,
    required this.engagement,
    required this.commentCount,
    this.caption,
    this.location,
    this.products = const [],
    this.similar = const [],
  });

  final String id;
  final String imagePath;
  final PostAuthor author;
  final PostEngagement engagement;
  final int commentCount;

  /// What the author wrote, and where; null when left empty.
  final String? caption;
  final String? location;
  final List<TaggedProduct> products;
  final List<PostPreview> similar;

  @override
  List<Object?> get props => [
    id,
    imagePath,
    author,
    engagement,
    commentCount,
    caption,
    location,
    products,
    similar,
  ];
}
