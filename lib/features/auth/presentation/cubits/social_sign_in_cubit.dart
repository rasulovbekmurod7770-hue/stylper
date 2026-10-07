import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/usecases/social_auth.dart';

final class SocialSignInState extends Equatable {
  const SocialSignInState({this.inProgress, this.failure});

  /// The provider whose sign-in is running, if any.
  final SocialProvider? inProgress;
  final AuthFailure? failure;

  @override
  List<Object?> get props => [inProgress, failure];
}

class SocialSignInCubit extends Cubit<SocialSignInState> {
  SocialSignInCubit(this._signIn) : super(const SocialSignInState());

  final SignInWithSocialProvider _signIn;

  Future<void> signIn(SocialProvider provider) async {
    if (state.inProgress != null) return;

    emit(SocialSignInState(inProgress: provider));
    final result = await _signIn(provider);
    if (isClosed) return;
    emit(
      result.match(
        (failure) => failure.reason == AuthFailureReason.cancelled
            ? const SocialSignInState()
            : SocialSignInState(failure: failure),
        (_) => const SocialSignInState(),
      ),
    );
  }
}
