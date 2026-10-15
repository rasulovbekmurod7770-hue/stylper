import 'package:fpdart/fpdart.dart';

import '../entities/post.dart';
import '../failures/post_failure.dart';

abstract interface class PostRepository {
  /// Public: guests can open posts too.
  Future<Either<PostFailure, Post>> getPost(String id);

  /// Requires a signed-in user. Returns the post's updated engagement.
  Future<Either<PostFailure, PostEngagement>> setLiked(
    String postId, {
    required bool liked,
  });

  /// Requires a signed-in user. Returns the post's updated engagement.
  Future<Either<PostFailure, PostEngagement>> setSaved(
    String postId, {
    required bool saved,
  });
}
