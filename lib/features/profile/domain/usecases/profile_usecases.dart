import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
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
