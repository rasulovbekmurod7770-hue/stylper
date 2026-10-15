import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/failures/home_failure.dart';
import '../../domain/usecases/get_home_feed.dart';

enum HomeFeedStatus { loading, ready, failure }

final class HomeFeedState extends Equatable {
  const HomeFeedState({
    this.status = HomeFeedStatus.loading,
    this.feed,
    this.failure,
  });

  final HomeFeedStatus status;

  /// The last feed that loaded; kept while a refresh is in flight or fails.
  final HomeFeed? feed;
  final HomeFailure? failure;

  @override
  List<Object?> get props => [status, feed, failure];
}

class HomeFeedCubit extends Cubit<HomeFeedState> {
  HomeFeedCubit(this._getHomeFeed) : super(const HomeFeedState());

  final GetHomeFeed _getHomeFeed;

  /// Loads the feed; also used for pull-to-refresh, which keeps the current
  /// feed on screen.
  Future<void> load() async {
    emit(HomeFeedState(feed: state.feed));
    final result = await _getHomeFeed(const NoParams());
    if (isClosed) return;
    emit(
      result.match(
        (failure) => HomeFeedState(
          status: HomeFeedStatus.failure,
          feed: state.feed,
          failure: failure,
        ),
        (feed) => HomeFeedState(status: HomeFeedStatus.ready, feed: feed),
      ),
    );
  }
}
