import 'dart:async';

import '../../domain/entities/app_user.dart';

/// The signed-in user and its changes, for `AuthRepository` implementations.
mixin CurrentUserNotifier {
  final _changes = StreamController<AppUser?>.broadcast(sync: true);

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  /// Emits [currentUser] immediately to every new listener, then each change.
  Stream<AppUser?> watchCurrentUser() => Stream.multi((controller) {
    controller.add(_currentUser);
    final subscription = _changes.stream.listen(
      controller.add,
      onError: controller.addError,
    );
    controller.onCancel = subscription.cancel;
  });

  /// For the repository itself; not part of `AuthRepository`.
  void setCurrentUser(AppUser? user) {
    if (user == _currentUser) return;
    _currentUser = user;
    _changes.add(user);
  }
}
