import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/submission_status.dart';
import '../../../../core/validation/validators.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/usecases/email_auth.dart';

final class SignUpState extends Equatable {
  const SignUpState({
    this.status = SubmissionStatus.idle,
    this.termsAccepted = false,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.termsError,
    this.failure,
  });

  final SubmissionStatus status;
  final bool termsAccepted;
  final ValidationError? emailError;
  final ValidationError? passwordError;
  final ValidationError? confirmPasswordError;
  final ValidationError? termsError;
  final AuthFailure? failure;

  bool get hasFieldErrors =>
      emailError != null ||
      passwordError != null ||
      confirmPasswordError != null ||
      termsError != null;

  @override
  List<Object?> get props => [
    status,
    termsAccepted,
    emailError,
    passwordError,
    confirmPasswordError,
    termsError,
    failure,
  ];
}

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._signUpWithEmail) : super(const SignUpState());

  final SignUpWithEmail _signUpWithEmail;

  void termsToggled(bool accepted) =>
      emit(SignUpState(status: state.status, termsAccepted: accepted));

  void fieldChanged() {
    if (state.hasFieldErrors) {
      emit(
        SignUpState(status: state.status, termsAccepted: state.termsAccepted),
      );
    }
  }

  Future<void> submit({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (state.status.isInProgress) return;

    final errors = SignUpState(
      termsAccepted: state.termsAccepted,
      emailError: Validators.email(email),
      passwordError: Validators.newPassword(password),
      confirmPasswordError: Validators.confirmPassword(
        password,
        confirmPassword,
      ),
      termsError: state.termsAccepted ? null : ValidationError.termsNotAccepted,
    );
    if (errors.hasFieldErrors) return emit(errors);

    emit(
      const SignUpState(
        status: SubmissionStatus.inProgress,
        termsAccepted: true,
      ),
    );
    final result = await _signUpWithEmail(
      EmailCredentials(email: email, password: password),
    );
    if (isClosed) return;
    emit(
      result.match(
        (failure) => SignUpState(
          status: SubmissionStatus.failure,
          termsAccepted: true,
          failure: failure,
        ),
        (_) => const SignUpState(
          status: SubmissionStatus.success,
          termsAccepted: true,
        ),
      ),
    );
  }
}
