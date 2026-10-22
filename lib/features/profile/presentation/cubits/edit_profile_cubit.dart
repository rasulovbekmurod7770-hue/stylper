import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/validation/validators.dart';
import '../../domain/entities/profile_settings.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';

enum EditProfileStatus { loading, loadFailure, ready, saving, saved }

final class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = EditProfileStatus.loading,
    this.profile,
    this.usernameError,
    this.failure,
  });

  final EditProfileStatus status;

  /// The profile the form starts from.
  final UserProfile? profile;
  final ValidationError? usernameError;
  final ProfileFailure? failure;

  bool get usernameTaken =>
      failure?.reason == ProfileFailureReason.usernameTaken;

  @override
  List<Object?> get props => [status, profile, usernameError, failure];
}

/// Edit Profile: your name, username and bio. A username is required.
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._getProfile, this._updateProfile)
    : super(const EditProfileState());

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;

  Future<void> load() async {
    emit(const EditProfileState());
    final result = await _getProfile(ProfileRepository.me);
    if (isClosed) return;
    emit(
      result.match(
        (failure) => EditProfileState(
          status: EditProfileStatus.loadFailure,
          failure: failure,
        ),
        (profile) => EditProfileState(
          status: EditProfileStatus.ready,
          profile: profile,
        ),
      ),
    );
  }

  void fieldChanged() {
    if (state.usernameError != null || state.failure != null) {
      emit(EditProfileState(status: state.status, profile: state.profile));
    }
  }

  Future<void> save({
    required String name,
    required String username,
    required String bio,
  }) async {
    if (state.status != EditProfileStatus.ready) return;
    final profile = state.profile;
    if (Validators.username(username) case final error?) {
      return emit(
        EditProfileState(
          status: EditProfileStatus.ready,
          profile: profile,
          usernameError: error,
        ),
      );
    }

    emit(EditProfileState(status: EditProfileStatus.saving, profile: profile));
    final result = await _updateProfile(
      ProfileEdit(
        name: name.trim(),
        username: Validators.normalizeUsername(username),
        bio: bio.trim(),
      ),
    );
    if (isClosed) return;
    emit(
      result.match(
        (failure) => EditProfileState(
          status: EditProfileStatus.ready,
          profile: profile,
          failure: failure,
        ),
        (_) => EditProfileState(
          status: EditProfileStatus.saved,
          profile: profile,
        ),
      ),
    );
  }
}
