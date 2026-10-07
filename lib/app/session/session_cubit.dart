import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/usecase/usecase.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/domain/usecases/session.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

/// The stored session hasn't been checked yet (splash screen).
final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

/// The user tapped "Skip for now" and browses without an account.
final class SessionGuest extends SessionState {
  const SessionGuest();
}

final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

/// App-wide session: who is signed in, or whether the user is a guest.
/// The router redirects based on this state.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required this._restoreSession,
    required this._watchCurrentUser,
    required this._signOut,
  }) : super(const SessionUnknown());

  final RestoreSession _restoreSession;
  final WatchCurrentUser _watchCurrentUser;
  final SignOut _signOut;
  StreamSubscription<AppUser?>? _subscription;

  Future<void> start() async {
    await _restoreSession(const NoParams());
    _subscription = _watchCurrentUser(const NoParams()).listen(_onUserChanged);
  }

  void _onUserChanged(AppUser? user) {
    if (user != null) return emit(SessionAuthenticated(user));
    // Signing out of an account never drops the user into guest mode.
    if (state is! SessionGuest) emit(const SessionUnauthenticated());
  }

  void continueAsGuest() {
    if (state is SessionUnauthenticated) emit(const SessionGuest());
  }

  void leaveGuestMode() {
    if (state is SessionGuest) emit(const SessionUnauthenticated());
  }

  Future<void> signOut() => _signOut(const NoParams());

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
