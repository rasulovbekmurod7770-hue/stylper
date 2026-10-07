import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/submission_status.dart';
import '../../../../core/validation/validators.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/usecases/email_auth.dart';

final class SignInState extends Equatable {
  const SignInState({
    this.status = SubmissionStatus.idle,
    this.emailError,
    this.passwordError,
    this.failure,
  });

  final SubmissionStatus status;
  final ValidationError? emailError;
  final ValidationError? passwordError;
  final AuthFailure? failure;

  @override
  List<Object?> get props => [status, emailError, passwordError, failure];
}

/// On success the session listener routes the user onward; this cubit only
/// validates input and reports progress or failure.
class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._signInWithEmail) : super(const SignInState());

  final SignInWithEmail _signInWithEmail;

  Future<void> submit({required String email, required String password}) async {
    if (state.status.isInProgress) return;

    final emailError = Validators.email(email);
    final passwordError = Validators.existingPassword(password);
    if (emailError != null || passwordError != null) {
      return emit(
        SignInState(emailError: emailError, passwordError: passwordError),
      );
    }

    emit(const SignInState(status: SubmissionStatus.inProgress));
    final result = await _signInWithEmail(
      EmailCredentials(email: email, password: password),
    );
    if (isClosed) return;
    emit(
      result.match(
        (failure) =>
            SignInState(status: SubmissionStatus.failure, failure: failure),
        (_) => const SignInState(status: SubmissionStatus.success),
      ),
    );
  }

  /// Clears inline errors once the user edits a field.
  void fieldChanged() {
    if (state.emailError != null || state.passwordError != null) {
      emit(SignInState(status: state.status, failure: state.failure));
    }
  }
}
