import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/post.dart';
import '../../domain/failures/post_failure.dart';
import '../../domain/usecases/post_usecases.dart';

final class PostEngagementState extends Equatable {
  const PostEngagementState({
    this.overrides = const {},
    this.failure,
    this.failureCount = 0,
  });

  /// Likes / saves changed in this session, by post id. They win over what a
  /// screen loaded, so every screen showing a post agrees.
  final Map<String, PostEngagement> overrides;

  /// The last like / save that failed; [failureCount] changes with each one
  /// so repeats still reach listeners.
  final PostFailure? failure;
  final int failureCount;

  /// [loaded] with this session's changes applied.
  PostEngagement of(String postId, PostEngagement loaded) =>
      overrides[postId] ?? loaded;

  @override
  List<Object?> get props => [overrides, failure, failureCount];
}

/// App-wide like / save state. Toggles update optimistically and roll back
/// if the API refuses.
class PostEngagementCubit extends Cubit<PostEngagementState> {
  PostEngagementCubit(this._setLiked, this._setSaved)
    : super(const PostEngagementState());

  final SetPostLiked _setLiked;
  final SetPostSaved _setSaved;
  final _inFlight = <String>{};

  Future<void> toggleLike(String postId, PostEngagement current) {
    final liked = !current.liked;
    return _toggle(
      key: 'like:$postId',
      postId: postId,
      apply: (e) =>
          e.copyWith(liked: liked, likeCount: e.likeCount + (liked ? 1 : -1)),
      request: () => _setLiked(PostToggle(postId, on: liked)),
      confirm: (e, server) => e.copyWith(
        liked: server.liked,
        likeCount: server.likeCount,
        saved: _inFlight.contains('save:$postId') ? null : server.saved,
      ),
      revert: (e) =>
          e.copyWith(liked: current.liked, likeCount: current.likeCount),
      current: current,
    );
  }

  Future<void> toggleSave(String postId, PostEngagement current) {
    final saved = !current.saved;
    return _toggle(
      key: 'save:$postId',
      postId: postId,
      apply: (e) => e.copyWith(saved: saved),
      request: () => _setSaved(PostToggle(postId, on: saved)),
      confirm: (e, server) {
        final liking = _inFlight.contains('like:$postId');
        return e.copyWith(
          saved: server.saved,
          liked: liking ? null : server.liked,
          likeCount: liking ? null : server.likeCount,
        );
      },
      revert: (e) => e.copyWith(saved: current.saved),
      current: current,
    );
  }

  /// Forgets this session's changes, e.g. when another user signs in.
  void reset() {
    _inFlight.clear();
    emit(const PostEngagementState());
  }

  /// Like and save requests for one post can overlap, so each one only
  /// reverts its own fields, and takes the server's other fields only when
  /// no request for them is pending.
  Future<void> _toggle({
    required String key,
    required String postId,
    required PostEngagement current,
    required PostEngagement Function(PostEngagement) apply,
    required Future<Either<PostFailure, PostEngagement>> Function() request,
    required PostEngagement Function(PostEngagement, PostEngagement) confirm,
    required PostEngagement Function(PostEngagement) revert,
  }) async {
    if (!_inFlight.add(key)) return; // ignore taps while one is pending
    _put(postId, apply(state.of(postId, current)));
    final result = await request();
    if (isClosed || !_inFlight.remove(key)) return;
    final latest = state.of(postId, current);
    result.match(
      (failure) => _put(postId, revert(latest), failure: failure),
      (server) => _put(postId, confirm(latest, server)),
    );
  }

  void _put(String postId, PostEngagement engagement, {PostFailure? failure}) {
    emit(
      PostEngagementState(
        overrides: {...state.overrides, postId: engagement},
        failure: failure ?? state.failure,
        failureCount: state.failureCount + (failure == null ? 0 : 1),
      ),
    );
  }
}
