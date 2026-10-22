import 'package:equatable/equatable.dart';

import 'app_user.dart';

/// What creating an account led to.
sealed class SignUpResult extends Equatable {
  const SignUpResult();
}

/// The account exists and the user is signed in.
final class SignedUp extends SignUpResult {
  const SignedUp(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

/// The account exists, but [email] must be confirmed (through the link sent
/// to it) before the user can sign in, so there is no session yet.
final class ConfirmationEmailSent extends SignUpResult {
  const ConfirmationEmailSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}
