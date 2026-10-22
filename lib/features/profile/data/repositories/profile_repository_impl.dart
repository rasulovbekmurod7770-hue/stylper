import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/profile_settings.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_json.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required this._remote});

  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<ProfileFailure, UserProfile>> getProfile(String userId) =>
      _guard(() async => ProfileJson.profile(await _remote.getProfile(userId)));

  @override
  Future<Either<ProfileFailure, FollowState>> setFollowing(
    String userId, {
    required bool following,
  }) => _guard(
    () async => ProfileJson.follow(
      await _remote.setFollowing(userId, following: following),
    ),
  );

  @override
  Future<Either<ProfileFailure, List<SavedPost>>> getSavedPosts() =>
      _guard(() async => ProfileJson.saved(await _remote.getSavedPosts()));

  @override
  Future<Either<ProfileFailure, Unit>> updateProfile(ProfileEdit edit) =>
      _guard(() async {
        await _remote.updateProfile(ProfileJson.editBody(edit));
        return unit;
      });

  @override
  Future<Either<ProfileFailure, ProfileSettings>> getSettings() =>
      _guard(() async => ProfileJson.settings(await _remote.getSettings()));

  @override
  Future<Either<ProfileFailure, Unit>> updateSettings(
    ProfileSettings settings,
  ) => _guard(() async {
    await _remote.updateSettings(ProfileJson.settingsBody(settings));
    return unit;
  });

  Future<Either<ProfileFailure, T>> _guard<T>(
    Future<T> Function() request,
  ) async {
    try {
      return Right(await request());
    } on ServerException catch (e) {
      return Left(
        ProfileFailure(switch (e.code) {
          ApiErrorCodes.notFound => ProfileFailureReason.notFound,
          ApiErrorCodes.unauthorized => ProfileFailureReason.signInRequired,
          ApiErrorCodes.usernameTaken => ProfileFailureReason.usernameTaken,
          _ => ProfileFailureReason.unknown,
        }),
      );
    } on NetworkException {
      return const Left(ProfileFailure(ProfileFailureReason.network));
    }
  }
}
