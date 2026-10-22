import 'package:fpdart/fpdart.dart';

import '../entities/app_user.dart';
import '../entities/sign_up_result.dart';
import '../failures/auth_failure.dart';

abstract interface class AuthRepository {
  /// The signed-in user, or null. Valid after [restoreSession] completes.
  AppUser? get currentUser;

  /// Emits [currentUser] immediately to every new listener, then each change.
  Stream<AppUser?> watchCurrentUser();

  /// Restores a stored session on app start (no-op when there is none).
  Future<void> restoreSession();

  /// Re-fetches the signed-in user, e.g. after onboarding changed it on the server.
  Future<Either<AuthFailure, AppUser>> refreshCurrentUser();

  Future<Either<AuthFailure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs the new user in, unless the backend first wants the email
  /// confirmed ([ConfirmationEmailSent]).
  Future<Either<AuthFailure, SignUpResult>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, AppUser>> signInWithGoogle();

  Future<Either<AuthFailure, AppUser>> signInWithApple();

  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
