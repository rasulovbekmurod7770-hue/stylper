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
    this.selectedStyle,
  });

  final HomeFeedStatus status;

  /// The last feed that loaded; kept while a refresh is in flight or fails.
  final HomeFeed? feed;
  final HomeFailure? failure;

  /// The chosen "For you" style chip; null means the feed's first style.
  final String? selectedStyle;

  /// The style chip shown as selected.
  String? get style => selectedStyle ?? feed?.styles.firstOrNull;

  @override
  List<Object?> get props => [status, feed, failure, selectedStyle];
}

class HomeFeedCubit extends Cubit<HomeFeedState> {
  HomeFeedCubit(this._getHomeFeed) : super(const HomeFeedState());

  final GetHomeFeed _getHomeFeed;

  /// Loads the feed; also used for pull-to-refresh, which keeps the current
  /// feed and style on screen.
  Future<void> load() async {
    emit(HomeFeedState(feed: state.feed, selectedStyle: state.selectedStyle));
    final result = await _getHomeFeed(const NoParams());
    if (isClosed) return;
    emit(
      result.match(
        (failure) => HomeFeedState(
          status: HomeFeedStatus.failure,
          feed: state.feed,
          failure: failure,
          selectedStyle: state.selectedStyle,
        ),
        (feed) => HomeFeedState(
          status: HomeFeedStatus.ready,
          feed: feed,
          // Keep the choice only if the new feed still offers it.
          selectedStyle: feed.styles.contains(state.selectedStyle)
              ? state.selectedStyle
              : null,
        ),
      ),
    );
  }

  /// Shows the "For you" posts of [style].
  void selectStyle(String style) {
    if (state.feed?.styles.contains(style) ?? false) {
      emit(
        HomeFeedState(
          status: state.status,
          feed: state.feed,
          failure: state.failure,
          selectedStyle: style,
        ),
      );
    }
  }
}
