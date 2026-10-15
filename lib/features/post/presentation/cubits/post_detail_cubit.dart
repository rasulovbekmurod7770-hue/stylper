import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post.dart';
import '../../domain/failures/post_failure.dart';
import '../../domain/usecases/post_usecases.dart';

enum PostDetailStatus { loading, ready, failure }

final class PostDetailState extends Equatable {
  const PostDetailState({
    this.status = PostDetailStatus.loading,
    this.post,
    this.failure,
  });

  final PostDetailStatus status;
  final Post? post;
  final PostFailure? failure;

  @override
  List<Object?> get props => [status, post, failure];
}

class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit(this._getPost, {required this.postId})
    : super(const PostDetailState());

  final GetPost _getPost;
  final String postId;

  Future<void> load() async {
    emit(const PostDetailState());
    final result = await _getPost(postId);
    if (isClosed) return;
    emit(
      result.match(
        (failure) =>
            PostDetailState(status: PostDetailStatus.failure, failure: failure),
        (post) => PostDetailState(status: PostDetailStatus.ready, post: post),
      ),
    );
  }
}
