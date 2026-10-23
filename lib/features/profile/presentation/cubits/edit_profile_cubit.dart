import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/validation/validators.dart';
import '../../../posting/domain/repositories/media_repository.dart';
import '../../../uploads/domain/entities/uploaded_photo.dart';
import '../../../uploads/domain/failures/upload_failure.dart';
import '../../../uploads/domain/usecases/upload_photo.dart';
import '../../domain/entities/profile_settings.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';

enum EditProfileStatus { loading, loadFailure, ready, saving, saved }

/// A change to the profile photo in Edit Profile, saved with the rest.
sealed class PhotoChange extends Equatable {
  const PhotoChange();

  @override
  List<Object?> get props => [];
}

/// A picked photo being uploaded; the form shows [path] meanwhile.
final class PhotoUploading extends PhotoChange {
  const PhotoUploading(this.path);

  final String path;

  @override
  List<Object?> get props => [path];
}

/// A picked photo, uploaded as [mediaId].
final class PhotoUploaded extends PhotoChange {
  const PhotoUploaded(this.path, this.mediaId);

  final String path;
  final String mediaId;

  @override
  List<Object?> get props => [path, mediaId];
}

final class PhotoRemoved extends PhotoChange {
  const PhotoRemoved();
}

final class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = EditProfileStatus.loading,
    this.profile,
    this.photo,
    this.usernameError,
    this.failure,
    this.photoFailure,
  });

  final EditProfileStatus status;

  /// The profile the form starts from.
  final UserProfile? profile;

  /// Null keeps the profile's photo.
  final PhotoChange? photo;
  final ValidationError? usernameError;
  final ProfileFailure? failure;

  /// Why the photo just picked couldn't be uploaded.
  final UploadFailure? photoFailure;

  bool get usernameTaken =>
      failure?.reason == ProfileFailureReason.usernameTaken;

  /// The photo the form shows: the profile's, or the one picked here.
  String? get photoPath => switch (photo) {
    null => profile?.avatarPath,
    PhotoUploading(:final path) || PhotoUploaded(:final path) => path,
    PhotoRemoved() => null,
  };

  bool get uploadingPhoto => photo is PhotoUploading;

  /// This state with [status]; errors are cleared unless given.
  EditProfileState next(
    EditProfileStatus status, {
    ValidationError? usernameError,
    ProfileFailure? failure,
  }) => EditProfileState(
    status: status,
    profile: profile,
    photo: photo,
    usernameError: usernameError,
    failure: failure,
  );

  /// This state with another [photo] (null: the profile's own).
  EditProfileState withPhoto(PhotoChange? photo, {UploadFailure? failure}) =>
      EditProfileState(
        status: status,
        profile: profile,
        photo: photo,
        usernameError: usernameError,
        failure: this.failure,
        photoFailure: failure,
      );

  @override
  List<Object?> get props => [
    status,
    profile,
    photo,
    usernameError,
    failure,
    photoFailure,
  ];
}

/// Edit Profile: your photo, name, username and bio. A username is required.
/// A picked photo uploads straight away and is attached on Save.
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(
    this._getProfile,
    this._updateProfile,
    this._media,
    this._uploadPhoto,
  ) : super(const EditProfileState());

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final MediaRepository _media;
  final UploadPhoto _uploadPhoto;

  /// The upload in progress, done once its result is in the state; Save
  /// waits for it.
  Future<void>? _upload;

  bool get canTakePhoto => _media.canTakePhoto;

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
        (profile) =>
            EditProfileState(status: EditProfileStatus.ready, profile: profile),
      ),
    );
  }

  void fieldChanged() {
    if (state.usernameError != null || state.failure != null) {
      emit(state.next(state.status));
    }
  }

  /// Picks a photo from the library (or the [camera]) and uploads it.
  Future<void> choosePhoto({bool camera = false}) async {
    if (state.status != EditProfileStatus.ready) return;
    final path = camera ? await _media.takePhoto() : await _media.pickPhoto();
    if (path == null || isClosed || state.status != EditProfileStatus.ready) {
      return;
    }
    // A failed upload goes back to the photo before it.
    final before = state.photo is PhotoUploading ? null : state.photo;
    final uploading = PhotoUploading(path);
    emit(state.withPhoto(uploading));
    await (_upload = _finishUpload(uploading, before));
  }

  Future<void> _finishUpload(
    PhotoUploading uploading,
    PhotoChange? before,
  ) async {
    final result = await _uploadPhoto(
      PhotoUpload(uploading.path, UploadKind.avatar),
    );
    // Gone, or another photo was picked meanwhile.
    if (isClosed || state.photo != uploading) return;
    emit(
      result.match(
        (failure) => state.withPhoto(before, failure: failure),
        (photo) => state.withPhoto(PhotoUploaded(uploading.path, photo.id)),
      ),
    );
  }

  void removePhoto() {
    if (state.status != EditProfileStatus.ready) return;
    emit(
      state.withPhoto(
        state.profile?.avatarPath == null ? null : const PhotoRemoved(),
      ),
    );
  }

  Future<void> save({
    required String name,
    required String username,
    required String bio,
  }) async {
    if (state.status != EditProfileStatus.ready) return;
    if (Validators.username(username) case final error?) {
      return emit(state.next(EditProfileStatus.ready, usernameError: error));
    }

    emit(state.next(EditProfileStatus.saving));
    if (state.uploadingPhoto) {
      await _upload;
      if (isClosed) return;
      // It failed: the form shows why, and the old photo again.
      if (state.photoFailure != null) {
        return emit(state.next(EditProfileStatus.ready));
      }
    }
    final result = await _updateProfile(
      ProfileEdit(
        name: name.trim(),
        username: Validators.normalizeUsername(username),
        bio: bio.trim(),
        avatar: switch (state.photo) {
          PhotoUploaded(:final mediaId) => AvatarChange(mediaId),
          PhotoRemoved() => const AvatarChange(null),
          _ => null,
        },
      ),
    );
    if (isClosed) return;
    emit(
      result.match(
        (failure) => state.next(EditProfileStatus.ready, failure: failure),
        (_) => state.next(EditProfileStatus.saved),
      ),
    );
  }
}
