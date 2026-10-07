import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    this.username,
    this.onboardingCompleted = false,
  });

  final String id;
  final String email;

  /// Null until the user finishes profile setup.
  final String? username;

  /// True once profile setup and the style quiz are done; drives routing.
  final bool onboardingCompleted;

  bool get hasProfile => username != null;

  @override
  List<Object?> get props => [id, email, username, onboardingCompleted];
}
