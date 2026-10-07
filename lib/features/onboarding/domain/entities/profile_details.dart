import 'package:equatable/equatable.dart';

enum Gender { male, female }

/// What the user enters on the profile setup screen. Body metrics are
/// optional and private to the user.
class ProfileDetails extends Equatable {
  const ProfileDetails({
    required this.username,
    required this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
  });

  final String username;
  final Gender gender;
  final int? age;
  final int? heightCm;
  final int? weightKg;

  @override
  List<Object?> get props => [username, gender, age, heightCm, weightKg];
}

abstract final class ProfileLimits {
  static const minAge = 13;
  static const maxAge = 100;
  static const minHeightCm = 100;
  static const maxHeightCm = 250;
  static const minWeightKg = 30;
  static const maxWeightKg = 300;
}
