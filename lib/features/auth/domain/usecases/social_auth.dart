import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

enum SocialProvider { google, apple }

class SignInWithSocialProvider
    implements UseCase<Future<Either<AuthFailure, AppUser>>, SocialProvider> {
  const SignInWithSocialProvider(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<AuthFailure, AppUser>> call(SocialProvider provider) =>
      switch (provider) {
        SocialProvider.google => _repository.signInWithGoogle(),
        SocialProvider.apple => _repository.signInWithApple(),
      };
}
