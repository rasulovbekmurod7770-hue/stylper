import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/usecases/profile_usecases.dart';

enum ProfileStatus { loading, ready, failure }

/// Follows go through the app-wide `FollowingCubit`, so a post's author row
/// and the profile agree.
final class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.profile,
    this.failure,
  });

  final ProfileStatus status;
  final UserProfile? profile;

  /// Why loading failed.
  final ProfileFailure? failure;

  @override
  List<Object?> get props => [status, profile, failure];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getProfile, {required this.userId})
    : super(const ProfileState());

  final GetProfile _getProfile;

  /// The user to show; `ProfileRepository.me` for the signed-in user.
  final String userId;

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
      (profile) =>
          emit(ProfileState(status: ProfileStatus.ready, profile: profile)),
    );
  }
}
