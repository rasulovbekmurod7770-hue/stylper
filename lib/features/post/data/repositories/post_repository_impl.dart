import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/post.dart';
import '../../domain/failures/post_failure.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';
import '../models/post_json.dart';

class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl({required this._remote});

  final PostRemoteDataSource _remote;

  @override
  Future<Either<PostFailure, Post>> getPost(String id) =>
      _guard(() async => PostJson.post(await _remote.getPost(id)));

  @override
  Future<Either<PostFailure, PostEngagement>> setLiked(
    String postId, {
    required bool liked,
  }) => _guard(
    () async =>
        PostJson.engagement(await _remote.setLiked(postId, liked: liked)),
  );

  @override
  Future<Either<PostFailure, PostEngagement>> setSaved(
    String postId, {
    required bool saved,
  }) => _guard(
    () async =>
        PostJson.engagement(await _remote.setSaved(postId, saved: saved)),
  );

  Future<Either<PostFailure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } on ServerException catch (e) {
      return Left(
        PostFailure(switch (e.code) {
          ApiErrorCodes.notFound => PostFailureReason.notFound,
          ApiErrorCodes.unauthorized => PostFailureReason.signInRequired,
          _ => PostFailureReason.unknown,
        }),
      );
    } on NetworkException {
      return const Left(PostFailure(PostFailureReason.network));
    }
  }
}
