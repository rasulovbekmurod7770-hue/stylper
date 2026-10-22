import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/sign_up_result.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'current_user_notifier.dart';

/// [AuthRepository] on Supabase Auth.
///
/// Supabase owns the session: it keeps it on the device and refreshes it. The
/// username and onboarding state come from the user's `profiles` row, which a
/// database trigger creates at sign-up.
class SupabaseAuthRepository
    with CurrentUserNotifier
    implements AuthRepository {
  SupabaseAuthRepository(this._client) {
    // A session can also end without signOut(), e.g. when its refresh token
    // is revoked. Errors on this stream reach the calls that cause them.
    _client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedOut) setCurrentUser(null);
    }, onError: (Object _) {});
  }

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  Future<void> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return setCurrentUser(null);
    try {
      await _signedIn(user);
    } on AuthRetryableFetchException {
      setCurrentUser(null); // offline: the session stays for the next launch
    } on AuthException {
      await signOut(); // the stored session can't be refreshed any more
    } on PostgrestException catch (e) {
      // A rejected token or a missing profile row (the account is gone) ends
      // the session; a server error leaves it for the next launch.
      if (_invalidSessionCodes.contains(e.code)) {
        await signOut();
      } else {
        setCurrentUser(null);
      }
    } on http.ClientException {
      setCurrentUser(null);
    } on TimeoutException {
      setCurrentUser(null);
    }
  }

  /// PostgREST: JWT invalid / expired, and `.single()` finding no row.
  static const _invalidSessionCodes = {'PGRST301', 'PGRST303', 'PGRST116'};

  @override
  Future<Either<AuthFailure, AppUser>> refreshCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Left(AuthFailure(AuthFailureReason.unknown));
    }
    return _guard(() => _signedIn(user));
  }

  @override
  Future<Either<AuthFailure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(() async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _signedIn(response.user!);
  });

  @override
  Future<Either<AuthFailure, SignUpResult>> signUpWithEmail({
    required String email,
    required String password,
  }) => _guard(() async {
    final response = await _auth.signUp(email: email, password: password);
    // With email confirmation on, the account waits for its link: no session.
    // (Signing up again with a registered email looks the same, so the
    // response can't be used to find out who has an account.)
    final user = response.user;
    if (response.session == null || user == null) {
      return ConfirmationEmailSent(email);
    }
    return SignedUp(await _signedIn(user));
  });

  // Needs the Google / Apple providers enabled in Supabase plus native
  // sign-in on the device; neither is set up yet.
  @override
  Future<Either<AuthFailure, AppUser>> signInWithGoogle() async =>
      const Left(AuthFailure(AuthFailureReason.providerUnavailable));

  @override
  Future<Either<AuthFailure, AppUser>> signInWithApple() async =>
      const Left(AuthFailure(AuthFailureReason.providerUnavailable));

  @override
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail(String email) =>
      _guard(() async {
        await _auth.resetPasswordForEmail(email);
        return unit;
      });

  @override
  Future<void> signOut() async {
    setCurrentUser(null);
    try {
      await _auth.signOut();
    } on Exception {
      // Supabase drops the local session before telling the server; a failed
      // server call only means the refresh token lives until it expires.
    }
  }

  /// Loads [user]'s profile row and makes them the current user.
  Future<AppUser> _signedIn(User user) async {
    final profile = await _client
        .from('profiles')
        .select('username, onboarded_at')
        .eq('id', user.id)
        .single();
    final appUser = AppUser(
      id: user.id,
      email: user.email ?? '',
      username: profile['username'] as String?,
      onboardingCompleted: profile['onboarded_at'] != null,
    );
    setCurrentUser(appUser);
    return appUser;
  }

  Future<Either<AuthFailure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on AuthRetryableFetchException {
      return const Left(AuthFailure(AuthFailureReason.network));
    } on AuthException catch (e) {
      return Left(AuthFailure(_reasonFor(e.code)));
    } on PostgrestException {
      return const Left(AuthFailure(AuthFailureReason.unknown));
    } on http.ClientException {
      return const Left(AuthFailure(AuthFailureReason.network));
    } on TimeoutException {
      return const Left(AuthFailure(AuthFailureReason.network));
    }
  }

  /// Supabase Auth error codes:
  /// https://supabase.com/docs/guides/auth/debugging/error-codes
  static AuthFailureReason _reasonFor(String? code) => switch (code) {
    'invalid_credentials' => AuthFailureReason.invalidCredentials,
    'email_not_confirmed' => AuthFailureReason.emailNotConfirmed,
    'user_already_exists' ||
    'email_exists' => AuthFailureReason.emailAlreadyInUse,
    'weak_password' => AuthFailureReason.weakPassword,
    'user_banned' => AuthFailureReason.userDisabled,
    'over_request_rate_limit' ||
    'over_email_send_rate_limit' => AuthFailureReason.tooManyRequests,
    _ => AuthFailureReason.unknown,
  };
}
