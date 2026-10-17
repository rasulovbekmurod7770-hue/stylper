import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/usecases/profile_usecases.dart';

enum ProfileStatus { loading, ready, failure }

final class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.profile,
    this.failure,
    this.followFailureCount = 0,
  });

  final ProfileStatus status;
  final UserProfile? profile;

  /// Why loading failed, or the last refused follow.
  final ProfileFailure? failure;

  /// Changes with each refused follow, so repeats still reach listeners.
  final int followFailureCount;

  ProfileState copyWith({
    UserProfile? profile,
    ProfileFailure? failure,
    int? followFailureCount,
  }) => ProfileState(
    status: status,
    profile: profile ?? this.profile,
    failure: failure ?? this.failure,
    followFailureCount: followFailureCount ?? this.followFailureCount,
  );

  @override
  List<Object?> get props => [status, profile, failure, followFailureCount];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getProfile, this._setFollowing, {required this.userId})
    : super(const ProfileState());

  final GetProfile _getProfile;
  final SetFollowing _setFollowing;

  /// The user to show; `ProfileRepository.me` for the signed-in user.
  final String userId;
  var _following = false;

  Future<void> load() async {
    emit(const ProfileState());
    final result = await _getProfile(userId);
    if (isClosed) return;
    emit(
      result.match(
        (failure) =>
            ProfileState(status: ProfileStatus.failure, failure: failure),
        (profile) =>
            ProfileState(status: ProfileStatus.ready, profile: profile),
      ),
    );
  }

  /// Reloads while the current profile stays on screen (e.g. after you
  /// post); a failure keeps what's shown.
  Future<void> refresh() async {
    if (state.profile == null) return load();
    final result = await _getProfile(userId);
    if (isClosed) return;
    result.match(
      (_) {},
      (profile) => emit(
        ProfileState(
          status: ProfileStatus.ready,
          profile: profile,
          followFailureCount: state.followFailureCount,
        ),
      ),
    );
  }

  /// Follows or unfollows, updating the follower count at once and rolling
  /// back if the API refuses.
  Future<void> toggleFollow() async {
    final current = state.profile;
    if (current == null || current.isMe || _following) return;
    _following = true;
    final follow = !current.followedByMe;
    emit(
      state.copyWith(
        profile: current.copyWith(
          followedByMe: follow,
          followerCount: current.followerCount + (follow ? 1 : -1),
        ),
      ),
    );
    final result = await _setFollowing(
      FollowToggle(current.id, following: follow),
    );
    _following = false;
    if (isClosed) return;
    emit(
      result.match(
        (failure) => state.copyWith(
          profile: current,
          failure: failure,
          followFailureCount: state.followFailureCount + 1,
        ),
        (server) => state.copyWith(
          profile: state.profile!.copyWith(
            followedByMe: server.following,
            followerCount: server.followerCount,
          ),
        ),
      ),
    );
  }
}
