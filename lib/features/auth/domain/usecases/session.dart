import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RestoreSession implements UseCase<Future<void>, NoParams> {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.restoreSession();
}

class WatchCurrentUser implements UseCase<Stream<AppUser?>, NoParams> {
  const WatchCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  Stream<AppUser?> call(NoParams params) => _repository.watchCurrentUser();
}

class SignOut implements UseCase<Future<void>, NoParams> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.signOut();
}
