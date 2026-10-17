import 'package:equatable/equatable.dart';

import '../../../post/domain/entities/post.dart';

/// Figma "Profile" (2775:3285): someone's personal style.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    required this.handle,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.isMe,
    this.avatarPath,
    this.bio = '',
    this.styles = const [],
    this.followedByMe = false,
    this.recentPosts = const [],
  });

  final String id;
  final String name;

  /// Username without the leading `@`.
  final String handle;

  /// Null when the user has no photo; the app shows initials.
  final String? avatarPath;
  final String bio;

  /// "Style DNA" tags, e.g. Minimal, Streetwear.
  final List<String> styles;
  final int postCount;
  final int followerCount;
  final int followingCount;

  /// The signed-in user's own profile.
  final bool isMe;
  final bool followedByMe;

  /// Newest first; the first three are "My style".
  final List<PostPreview> recentPosts;

  /// Whether you follow them, and their follower count, as loaded.
  FollowState get followState =>
      FollowState(followerCount: followerCount, following: followedByMe);

  @override
  List<Object?> get props => [
    id,
    name,
    handle,
    avatarPath,
    bio,
    styles,
    postCount,
    followerCount,
    followingCount,
    isMe,
    followedByMe,
    recentPosts,
  ];
}

/// A post the signed-in user saved, with who posted it ("saved-card").
class SavedPost extends Equatable {
  const SavedPost({
    required this.post,
    required this.author,
    required this.engagement,
  });

  final PostPreview post;
  final PostAuthor author;
  final PostEngagement engagement;

  @override
  List<Object?> get props => [post, author, engagement];
}

/// A profile's follower count and whether the viewer follows it.
class FollowState extends Equatable {
  const FollowState({required this.followerCount, required this.following});

  final int followerCount;
  final bool following;

  @override
  List<Object?> get props => [followerCount, following];
}
