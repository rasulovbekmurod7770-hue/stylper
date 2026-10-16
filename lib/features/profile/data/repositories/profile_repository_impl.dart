import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
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
          _ => ProfileFailureReason.unknown,
        }),
      );
    } on NetworkException {
      return const Left(ProfileFailure(ProfileFailureReason.network));
    }
  }
}
