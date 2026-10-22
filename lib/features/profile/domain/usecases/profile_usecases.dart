import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../entities/profile_settings.dart';
import '../entities/user_profile.dart';
import '../failures/profile_failure.dart';
import '../repositories/profile_repository.dart';

class GetProfile
    implements UseCase<Future<Either<ProfileFailure, UserProfile>>, String> {
  const GetProfile(this._profiles);

  final ProfileRepository _profiles;

  @override
  Future<Either<ProfileFailure, UserProfile>> call(String userId) =>
      _profiles.getProfile(userId);
}

final class FollowToggle extends Equatable {
  const FollowToggle(this.userId, {required this.following});

  final String userId;
  final bool following;

  @override
  List<Object?> get props => [userId, following];
}

class SetFollowing
    implements
        UseCase<Future<Either<ProfileFailure, FollowState>>, FollowToggle> {
  const SetFollowing(this._profiles);

  final ProfileRepository _profiles;

  @override
  Future<Either<ProfileFailure, FollowState>> call(FollowToggle toggle) =>
      _profiles.setFollowing(toggle.userId, following: toggle.following);
}

class GetSavedPosts
    implements
        UseCase<Future<Either<ProfileFailure, List<SavedPost>>>, NoParams> {
  const GetSavedPosts(this._profiles);

  final ProfileRepository _profiles;

  @override
  Future<Either<ProfileFailure, List<SavedPost>>> call(NoParams params) =>
      _profiles.getSavedPosts();
}

/// Saves Edit Profile, then refreshes the signed-in user so the session sees
/// a new username.
class UpdateProfile
    implements UseCase<Future<Either<ProfileFailure, Unit>>, ProfileEdit> {
  const UpdateProfile(this._profiles, this._auth);

  final ProfileRepository _profiles;
  final AuthRepository _auth;

  @override
  Future<Either<ProfileFailure, Unit>> call(ProfileEdit edit) async {
    final result = await _profiles.updateProfile(edit);
    if (result.isRight()) await _auth.refreshCurrentUser();
    return result;
  }
}

class GetSettings
    implements
        UseCase<Future<Either<ProfileFailure, ProfileSettings>>, NoParams> {
  const GetSettings(this._profiles);

  final ProfileRepository _profiles;

  @override
  Future<Either<ProfileFailure, ProfileSettings>> call(NoParams params) =>
      _profiles.getSettings();
}

class UpdateSettings
    implements UseCase<Future<Either<ProfileFailure, Unit>>, ProfileSettings> {
  const UpdateSettings(this._profiles);

  final ProfileRepository _profiles;

  @override
  Future<Either<ProfileFailure, Unit>> call(ProfileSettings settings) =>
      _profiles.updateSettings(settings);
}
