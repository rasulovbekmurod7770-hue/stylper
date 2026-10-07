import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/submission_status.dart';
import '../../../../core/validation/validators.dart';
import '../../domain/entities/profile_details.dart';
import '../../domain/failures/onboarding_failure.dart';
import '../../domain/usecases/onboarding_usecases.dart';

final class ProfileSetupState extends Equatable {
  const ProfileSetupState({
    this.status = SubmissionStatus.idle,
    this.gender,
    this.usernameError,
    this.genderError,
    this.ageError,
    this.heightError,
    this.weightError,
    this.failure,
  });

  final SubmissionStatus status;
  final Gender? gender;
  final ValidationError? usernameError;
  final ValidationError? genderError;
  final ValidationError? ageError;
  final ValidationError? heightError;
  final ValidationError? weightError;
  final OnboardingFailure? failure;

  bool get hasFieldErrors =>
      usernameError != null ||
      genderError != null ||
      ageError != null ||
      heightError != null ||
      weightError != null;

  bool get usernameTaken =>
      failure?.reason == OnboardingFailureReason.usernameTaken;

  @override
  List<Object?> get props => [
    status,
    gender,
    usernameError,
    genderError,
    ageError,
    heightError,
    weightError,
    failure,
  ];
}

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  ProfileSetupCubit(this._saveProfile) : super(const ProfileSetupState());

  final SaveProfile _saveProfile;

  void genderSelected(Gender gender) =>
      emit(ProfileSetupState(status: state.status, gender: gender));

  void fieldChanged() {
    if (state.hasFieldErrors || state.usernameTaken) {
      emit(ProfileSetupState(status: state.status, gender: state.gender));
    }
  }

  Future<void> submit({
    required String username,
    required String age,
    required String heightCm,
    required String weightKg,
  }) async {
    if (state.status.isInProgress) return;

    final errors = ProfileSetupState(
      gender: state.gender,
      usernameError: Validators.username(username),
      genderError: state.gender == null ? ValidationError.notSelected : null,
      ageError: Validators.optionalIntInRange(
        age,
        ProfileLimits.minAge,
        ProfileLimits.maxAge,
      ),
      heightError: Validators.optionalIntInRange(
        heightCm,
        ProfileLimits.minHeightCm,
        ProfileLimits.maxHeightCm,
      ),
      weightError: Validators.optionalIntInRange(
        weightKg,
        ProfileLimits.minWeightKg,
        ProfileLimits.maxWeightKg,
      ),
    );
    if (errors.hasFieldErrors) return emit(errors);

    final gender = state.gender!;
    emit(
      ProfileSetupState(status: SubmissionStatus.inProgress, gender: gender),
    );
    final result = await _saveProfile(
      ProfileDetails(
        username: Validators.normalizeUsername(username),
        gender: gender,
        age: int.tryParse(age.trim()),
        heightCm: int.tryParse(heightCm.trim()),
        weightKg: int.tryParse(weightKg.trim()),
      ),
    );
    if (isClosed) return;
    emit(
      result.match(
        (failure) => ProfileSetupState(
          status: SubmissionStatus.failure,
          gender: gender,
          failure: failure,
        ),
        (_) =>
            ProfileSetupState(status: SubmissionStatus.success, gender: gender),
      ),
    );
  }
}
