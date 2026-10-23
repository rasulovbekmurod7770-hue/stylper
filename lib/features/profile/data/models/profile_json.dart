import '../../../post/data/models/post_json.dart';
import '../../domain/entities/profile_settings.dart';
import '../../domain/entities/user_profile.dart';

abstract final class ProfileJson {
  static UserProfile profile(JsonMap json) => UserProfile(
    id: json['id']! as String,
    name: json['name']! as String,
    // No username yet if profile setup was skipped.
    handle: json['handle'] as String? ?? '',
    avatarPath: json['avatar'] as String?,
    bio: json['bio'] as String? ?? '',
    styles: PostJson.strings(json['styles']),
    postCount: json['posts']! as int,
    followerCount: json['followers']! as int,
    followingCount: json['following']! as int,
    isMe: json['isMe'] as bool? ?? false,
    followedByMe: json['followedByMe'] as bool? ?? false,
    recentPosts: PostJson.list(json['recentPosts'], PostJson.preview),
  );

  static FollowState follow(JsonMap json) => FollowState(
    followerCount: json['followers']! as int,
    following: json['followedByMe']! as bool,
  );

  static List<SavedPost> saved(JsonMap json) => PostJson.list(
    json['posts'],
    (post) => SavedPost(
      post: PostJson.preview(post),
      author: PostJson.author(post['author']! as JsonMap),
      engagement: PostJson.engagement(post),
    ),
  );

  static ProfileSettings settings(JsonMap json) => ProfileSettings(
    isPrivate: json['isPrivate']! as bool,
    allowBrandFeatures: json['allowBrandFeatures']! as bool,
    showLikeCounts: json['showLikeCounts']! as bool,
    notifyBrandActivity: json['notifyBrandActivity']! as bool,
    notifyDrops: json['notifyDrops']! as bool,
  );

  static JsonMap settingsBody(ProfileSettings settings) => {
    'isPrivate': settings.isPrivate,
    'allowBrandFeatures': settings.allowBrandFeatures,
    'showLikeCounts': settings.showLikeCounts,
    'notifyBrandActivity': settings.notifyBrandActivity,
    'notifyDrops': settings.notifyDrops,
  };

  static JsonMap editBody(ProfileEdit edit) => {
    'name': edit.name.trim(),
    'username': edit.username,
    'bio': edit.bio.trim(),
    if (edit.avatar case final avatar?) 'avatarMediaId': avatar.mediaId,
  };
}
