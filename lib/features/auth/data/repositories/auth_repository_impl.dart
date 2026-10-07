import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._remote, required this._tokenStore});

  final AuthRemoteDataSource _remote;
  final AuthTokenStore _tokenStore;
  final _changes = StreamController<AppUser?>.broadcast(sync: true);

  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> watchCurrentUser() => Stream.multi((controller) {
    controller.add(_currentUser);
    final subscription = _changes.stream.listen(
      controller.add,
      onError: controller.addError,
    );
    controller.onCancel = subscription.cancel;
  });

  void _setUser(AppUser? user) {
    if (user == _currentUser) return;
    _currentUser = user;
    _changes.add(user);
  }

  @override
  Future<void> restoreSession() async {
    final token = await _tokenStore.read();
    if (token == null) return _setUser(null);
    try {
      _setUser((await _remote.fetchCurrentUser(token)).toEntity());
    } on ServerException catch (e) {
      if (e.code == ApiErrorCodes.unauthorized) await _tokenStore.clear();
      _setUser(null);
    } on NetworkException {
      _setUser(null);
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
      _setUser(user);
      return user;
    });
  }

  @override
  Future<Either<AuthFailure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) => _startSession(() => _remote.signInWithEmail(email, password));

  @override
  Future<Either<AuthFailure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
  }) => _startSession(() => _remote.signUpWithEmail(email, password));

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
    _setUser(null);
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
  ) => _guard(() async {
    final session = await request();
    await _tokenStore.save(session.accessToken);
    final user = session.user.toEntity();
    _setUser(user);
    return user;
  });

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
    ApiErrorCodes.emailTaken => AuthFailureReason.emailAlreadyInUse,
    ApiErrorCodes.weakPassword => AuthFailureReason.weakPassword,
    ApiErrorCodes.userDisabled => AuthFailureReason.userDisabled,
    ApiErrorCodes.tooManyRequests => AuthFailureReason.tooManyRequests,
    ApiErrorCodes.providerUnavailable => AuthFailureReason.providerUnavailable,
    _ => AuthFailureReason.unknown,
  };
}
