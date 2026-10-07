import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

final class EmailCredentials extends Equatable {
  const EmailCredentials({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class SignInWithEmail
    implements UseCase<Future<Either<AuthFailure, AppUser>>, EmailCredentials> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<AuthFailure, AppUser>> call(EmailCredentials params) =>
      _repository.signInWithEmail(
        email: params.email.trim(),
        password: params.password,
      );
}

class SignUpWithEmail
    implements UseCase<Future<Either<AuthFailure, AppUser>>, EmailCredentials> {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<AuthFailure, AppUser>> call(EmailCredentials params) =>
      _repository.signUpWithEmail(
        email: params.email.trim(),
        password: params.password,
      );
}

class SendPasswordResetEmail
    implements UseCase<Future<Either<AuthFailure, Unit>>, String> {
  const SendPasswordResetEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<AuthFailure, Unit>> call(String email) =>
      _repository.sendPasswordResetEmail(email.trim());
}
