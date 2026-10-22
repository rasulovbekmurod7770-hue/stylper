import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/sign_up_result.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import 'current_user_notifier.dart';

/// [AuthRepository] on the Stylper REST API (the fake backend for now),
/// keeping the access token in [AuthTokenStore].
class AuthRepositoryImpl with CurrentUserNotifier implements AuthRepository {
  AuthRepositoryImpl({required this._remote, required this._tokenStore});

  final AuthRemoteDataSource _remote;
  final AuthTokenStore _tokenStore;

  @override
  Future<void> restoreSession() async {
    final token = await _tokenStore.read();
    if (token == null) return setCurrentUser(null);
    try {
      setCurrentUser((await _remote.fetchCurrentUser(token)).toEntity());
    } on ServerException catch (e) {
      if (e.code == ApiErrorCodes.unauthorized) await _tokenStore.clear();
      setCurrentUser(null);
    } on NetworkException {
      setCurrentUser(null);
    }
  }

  @override
  Future<Either<AuthFailure, AppUser>> refreshCurrentUser() async {
    final token = await _tokenStore.read();
    if (token == null) {
      return const Left(AuthFailure(AuthFailureReason.unknown));
    }
    return _guard(() async {
      final user = (await _remote.fetchCurrentUser(token)).toEntity();
      setCurrentUser(user);
      return user;
    });
  }

  @override
  Future<Either<AuthFailure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) => _startSession(() => _remote.signInWithEmail(email, password));

  @override
  Future<Either<AuthFailure, SignUpResult>> signUpWithEmail({
    required String email,
    required String password,
  }) => _guard(() async {
    final session = await _remote.signUpWithEmail(email, password);
    if (session.accessToken == null) {
      return ConfirmationEmailSent(session.user.email);
    }
    return SignedUp(await _start(session));
  });

  @override
  Future<Either<AuthFailure, AppUser>> signInWithGoogle() =>
      _startSession(_remote.signInWithGoogle);

  @override
  Future<Either<AuthFailure, AppUser>> signInWithApple() =>
      _startSession(_remote.signInWithApple);

  @override
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail(String email) =>
      _guard(() async {
        await _remote.sendPasswordResetEmail(email);
        return unit;
      });

  @override
  Future<void> signOut() async {
    final token = await _tokenStore.read();
    await _tokenStore.clear();
    setCurrentUser(null);
    if (token == null) return;
    try {
      await _remote.signOut(token);
    } on Exception {
      // The local session is already gone; a failed server logout only means
      // the token lives until it expires.
    }
  }

  Future<Either<AuthFailure, AppUser>> _startSession(
    Future<AuthSessionModel> Function() request,
  ) => _guard(() async => _start(await request()));

  Future<AppUser> _start(AuthSessionModel session) async {
    await _tokenStore.save(session.accessToken!);
    final user = session.user.toEntity();
    setCurrentUser(user);
    return user;
  }

  Future<Either<AuthFailure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on ServerException catch (e) {
      return Left(AuthFailure(_reasonFor(e.code)));
    } on NetworkException {
      return const Left(AuthFailure(AuthFailureReason.network));
    }
  }

  static AuthFailureReason _reasonFor(String code) => switch (code) {
    ApiErrorCodes.invalidCredentials => AuthFailureReason.invalidCredentials,
    ApiErrorCodes.emailNotConfirmed => AuthFailureReason.emailNotConfirmed,
    ApiErrorCodes.emailTaken => AuthFailureReason.emailAlreadyInUse,
    ApiErrorCodes.weakPassword => AuthFailureReason.weakPassword,
    ApiErrorCodes.userDisabled => AuthFailureReason.userDisabled,
    ApiErrorCodes.tooManyRequests => AuthFailureReason.tooManyRequests,
    ApiErrorCodes.providerUnavailable => AuthFailureReason.providerUnavailable,
    _ => AuthFailureReason.unknown,
  };
}
