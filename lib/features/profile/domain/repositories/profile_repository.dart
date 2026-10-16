import 'package:fpdart/fpdart.dart';

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

  static const me = 'me';
}
