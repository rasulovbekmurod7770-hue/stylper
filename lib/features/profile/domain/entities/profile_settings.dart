import 'package:equatable/equatable.dart';

/// The signed-in user's Settings toggles. Defaults are those of a new
/// account.
class ProfileSettings extends Equatable {
  const ProfileSettings({
    this.isPrivate = false,
    this.allowBrandFeatures = true,
    this.showLikeCounts = true,
    this.notifyBrandActivity = true,
    this.notifyDrops = false,
  });

  /// Only followers see your posts.
  final bool isPrivate;

  /// Whether new posts let the brands they tag feature them.
  final bool allowBrandFeatures;
  final bool showLikeCounts;

  /// Notifications when a brand features your post or sends you a reward.
  final bool notifyBrandActivity;

  /// Notifications about new items from brands you follow.
  final bool notifyDrops;

  ProfileSettings copyWith({
    bool? isPrivate,
    bool? allowBrandFeatures,
    bool? showLikeCounts,
    bool? notifyBrandActivity,
    bool? notifyDrops,
  }) => ProfileSettings(
    isPrivate: isPrivate ?? this.isPrivate,
    allowBrandFeatures: allowBrandFeatures ?? this.allowBrandFeatures,
    showLikeCounts: showLikeCounts ?? this.showLikeCounts,
    notifyBrandActivity: notifyBrandActivity ?? this.notifyBrandActivity,
    notifyDrops: notifyDrops ?? this.notifyDrops,
  );

  @override
  List<Object?> get props => [
    isPrivate,
    allowBrandFeatures,
    showLikeCounts,
    notifyBrandActivity,
    notifyDrops,
  ];
}

/// What Edit Profile saves. An empty [name] or [bio] clears it.
class ProfileEdit extends Equatable {
  const ProfileEdit({
    required this.name,
    required this.username,
    required this.bio,
    this.avatar,
  });

  final String name;

  /// Without the leading `@`.
  final String username;
  final String bio;

  /// A new profile photo; null keeps the current one.
  final AvatarChange? avatar;

  @override
  List<Object?> get props => [name, username, bio, avatar];
}

/// Edit Profile's new photo: an uploaded photo's [mediaId], or null to
/// remove the photo.
class AvatarChange extends Equatable {
  const AvatarChange(this.mediaId);

  final String? mediaId;

  @override
  List<Object?> get props => [mediaId];
}

abstract final class ProfileLimits {
  static const maxNameLength = 60;
  static const maxBioLength = 160;
}
