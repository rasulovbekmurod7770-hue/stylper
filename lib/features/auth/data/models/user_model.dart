import '../../domain/entities/app_user.dart';

/// User as returned by the API (`GET /me`, login/register responses).
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.username,
    this.onboardingCompleted = false,
  });

  factory UserModel.fromJson(Map<String, Object?> json) => UserModel(
    id: json['id']! as String,
    email: json['email']! as String,
    username: json['username'] as String?,
    onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
  );

  final String id;
  final String email;
  final String? username;
  final bool onboardingCompleted;

  AppUser toEntity() => AppUser(
    id: id,
    email: email,
    username: username,
    onboardingCompleted: onboardingCompleted,
  );
}

/// Response of the login / register endpoints.
class AuthSessionModel {
  const AuthSessionModel({required this.accessToken, required this.user});

  factory AuthSessionModel.fromJson(Map<String, Object?> json) =>
      AuthSessionModel(
        accessToken: json['accessToken']! as String,
        user: UserModel.fromJson(json['user']! as Map<String, Object?>),
      );

  final String accessToken;
  final UserModel user;
}
