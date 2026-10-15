import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/post.dart';
import '../failures/post_failure.dart';
import '../repositories/post_repository.dart';

class GetPost implements UseCase<Future<Either<PostFailure, Post>>, String> {
  const GetPost(this._posts);

  final PostRepository _posts;

  @override
  Future<Either<PostFailure, Post>> call(String postId) =>
      _posts.getPost(postId);
}

final class PostToggle extends Equatable {
  const PostToggle(this.postId, {required this.on});

  final String postId;

  /// The state to set: liked / saved when true.
  final bool on;

  @override
  List<Object?> get props => [postId, on];
}

class SetPostLiked
    implements
        UseCase<Future<Either<PostFailure, PostEngagement>>, PostToggle> {
  const SetPostLiked(this._posts);

  final PostRepository _posts;

  @override
  Future<Either<PostFailure, PostEngagement>> call(PostToggle toggle) =>
      _posts.setLiked(toggle.postId, liked: toggle.on);
}

class SetPostSaved
    implements
        UseCase<Future<Either<PostFailure, PostEngagement>>, PostToggle> {
  const SetPostSaved(this._posts);

  final PostRepository _posts;

  @override
  Future<Either<PostFailure, PostEngagement>> call(PostToggle toggle) =>
      _posts.setSaved(toggle.postId, saved: toggle.on);
}
