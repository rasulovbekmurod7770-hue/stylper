import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/submission_status.dart';
import '../../../../core/validation/validators.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/usecases/email_auth.dart';

final class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.status = SubmissionStatus.idle,
    this.emailError,
    this.failure,
    this.sentTo,
  });

  final SubmissionStatus status;
  final ValidationError? emailError;
  final AuthFailure? failure;

  /// The address the reset link was sent to, once [status] is success.
  final String? sentTo;

  @override
  List<Object?> get props => [status, emailError, failure, sentTo];
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._sendPasswordResetEmail)
    : super(const ForgotPasswordState());

  final SendPasswordResetEmail _sendPasswordResetEmail;

  void fieldChanged() {
    if (state.emailError != null) emit(const ForgotPasswordState());
  }

  Future<void> submit(String email) async {
    if (state.status.isInProgress) return;

    final emailError = Validators.email(email);
    if (emailError != null) {
      return emit(ForgotPasswordState(emailError: emailError));
    }

    emit(const ForgotPasswordState(status: SubmissionStatus.inProgress));
    final result = await _sendPasswordResetEmail(email);
    if (isClosed) return;
    emit(
      result.match(
        (failure) => ForgotPasswordState(
          status: SubmissionStatus.failure,
          failure: failure,
        ),
        (_) => ForgotPasswordState(
          status: SubmissionStatus.success,
          sentTo: email.trim(),
        ),
      ),
    );
  }
}
