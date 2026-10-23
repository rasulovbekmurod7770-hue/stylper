import 'package:fpdart/fpdart.dart';

import '../entities/profile_settings.dart';
import '../entities/user_profile.dart';
import '../failures/profile_failure.dart';

abstract interface class ProfileRepository {
  /// A user's profile; [me] for the signed-in user's own.
  Future<Either<ProfileFailure, UserProfile>> getProfile(String userId);

  /// Follows or unfollows; signed-in users only.
  Future<Either<ProfileFailure, FollowState>> setFollowing(
    String userId, {
    required bool following,
  });

  /// The signed-in user's saved posts, newest first.
  Future<Either<ProfileFailure, List<SavedPost>>> getSavedPosts();

  /// Saves the signed-in user's name, username, bio and, if it changed, their
  /// photo. A username that is someone else's, a brand's or reserved is
  /// [ProfileFailureReason.usernameTaken].
  Future<Either<ProfileFailure, Unit>> updateProfile(ProfileEdit edit);

  Future<Either<ProfileFailure, ProfileSettings>> getSettings();

  Future<Either<ProfileFailure, Unit>> updateSettings(ProfileSettings settings);

  static const me = 'me';
}
