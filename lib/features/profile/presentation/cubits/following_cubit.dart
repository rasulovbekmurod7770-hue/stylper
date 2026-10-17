import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/usecases/profile_usecases.dart';

final class FollowingState extends Equatable {
  const FollowingState({
    this.overrides = const {},
    this.failure,
    this.failureCount = 0,
  });

  /// Follows changed in this session, by user id. They win over what a
  /// screen loaded, so a post's author row and their profile agree.
  final Map<String, FollowState> overrides;

  /// The last follow / unfollow that failed; [failureCount] changes with
  /// each one so repeats still reach listeners.
  final ProfileFailure? failure;
  final int failureCount;

  /// [loaded] with this session's changes applied.
  FollowState of(String userId, FollowState loaded) =>
      overrides[userId] ?? loaded;

  @override
  List<Object?> get props => [overrides, failure, failureCount];
}

/// App-wide follow state. A follow shows at once (with the follower count)
/// and rolls back if the API refuses.
class FollowingCubit extends Cubit<FollowingState> {
  FollowingCubit(this._setFollowing) : super(const FollowingState());

  final SetFollowing _setFollowing;
  final _inFlight = <String>{};

  /// Follows or unfollows [userId] (their real id, never `me`); [loaded] is
  /// what the screen loaded.
  Future<void> toggle(String userId, FollowState loaded) async {
    if (!_inFlight.add(userId)) return; // ignore taps while one is pending
    final current = state.of(userId, loaded);
    final follow = !current.following;
    _put(
      userId,
      FollowState(
        following: follow,
        followerCount: current.followerCount + (follow ? 1 : -1),
      ),
    );
    final result = await _setFollowing(FollowToggle(userId, following: follow));
    if (isClosed || !_inFlight.remove(userId)) return;
    result.match(
      (failure) => _put(userId, current, failure: failure),
      (server) => _put(userId, server),
    );
  }

  /// Forgets this session's changes, e.g. when another user signs in.
  void reset() {
    _inFlight.clear();
    emit(const FollowingState());
  }

  void _put(String userId, FollowState follow, {ProfileFailure? failure}) {
    emit(
      FollowingState(
        overrides: {...state.overrides, userId: follow},
        failure: failure ?? state.failure,
        failureCount: state.failureCount + (failure == null ? 0 : 1),
      ),
    );
  }
}
