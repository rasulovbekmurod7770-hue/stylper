import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/usecases/profile_usecases.dart';

enum SavedPostsStatus { loading, ready, failure }

final class SavedPostsState extends Equatable {
  const SavedPostsState({
    this.status = SavedPostsStatus.loading,
    this.posts = const [],
    this.failure,
  });

  final SavedPostsStatus status;
  final List<SavedPost> posts;
  final ProfileFailure? failure;

  @override
  List<Object?> get props => [status, posts, failure];
}

/// The signed-in user's saved posts (the profile's "Saved" tab).
class SavedPostsCubit extends Cubit<SavedPostsState> {
  SavedPostsCubit(this._getSavedPosts) : super(const SavedPostsState());

  final GetSavedPosts _getSavedPosts;

  /// Loads the saved posts; a reload keeps the current ones on screen.
  Future<void> load() async {
    if (state.posts.isEmpty) emit(const SavedPostsState());
    final result = await _getSavedPosts(const NoParams());
    if (isClosed) return;
    emit(
      result.match(
        (failure) => SavedPostsState(
          status: SavedPostsStatus.failure,
          posts: state.posts,
          failure: failure,
        ),
        (posts) =>
            SavedPostsState(status: SavedPostsStatus.ready, posts: posts),
      ),
    );
  }
}
