import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/post_draft.dart';
import '../../domain/failures/posting_failure.dart';
import '../../domain/usecases/posting_usecases.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';

enum PublishStatus { editing, publishing, published, failure }

final class PostDraftState extends Equatable {
  const PostDraftState({
    this.draft = const PostDraft(),
    this.styleOptions = const [],
    this.status = PublishStatus.editing,
    this.failure,
    this.publishedPostId,
  });

  final PostDraft draft;

  /// Styles the post can be tagged with, from the API.
  final List<String> styleOptions;
  final PublishStatus status;
  final PostingFailure? failure;
  final String? publishedPostId;

  PostDraftState copyWith({
    PostDraft? draft,
    List<String>? styleOptions,
    PublishStatus? status,
    PostingFailure? failure,
    String? publishedPostId,
  }) => PostDraftState(
    draft: draft ?? this.draft,
    styleOptions: styleOptions ?? this.styleOptions,
    status: status ?? this.status,
    failure: failure,
    publishedPostId: publishedPostId ?? this.publishedPostId,
  );

  @override
  List<Object?> get props => [
    draft,
    styleOptions,
    status,
    failure,
    publishedPostId,
  ];
}

/// The post being created, shared by every posting step.
class PostDraftCubit extends Cubit<PostDraftState> {
  PostDraftCubit(this._getStyles, this._publish, this._getSettings)
    : super(const PostDraftState());

  final GetPostStyles _getStyles;
  final PublishPost _publish;
  final GetSettings _getSettings;

  /// The user flipped "Allow brands to feature this" themselves.
  bool _brandFeatureSet = false;

  Future<void> loadStyles() async {
    final result = await _getStyles(const NoParams());
    if (isClosed) return;
    result.match(
      (_) {}, // The styles section just stays empty.
      (styles) => emit(state.copyWith(styleOptions: styles)),
    );
  }

  /// Starts "Allow brands to feature this" from the user's Settings default
  /// for new posts, unless they already flipped it.
  Future<void> loadDefaults() async {
    final result = await _getSettings(const NoParams());
    if (isClosed || _brandFeatureSet) return;
    result.match(
      (_) {}, // The switch just starts off.
      (settings) => emit(
        state.copyWith(
          draft: state.draft.copyWith(
            allowBrandFeature: settings.allowBrandFeatures,
          ),
        ),
      ),
    );
  }

  /// A different photo drops the tags, which were placed on the old one.
  void setPhoto(String path) {
    if (path == state.draft.photoPath) return;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(photoPath: path, tags: []),
      ),
    );
  }

  void addTag(DraftTag tag) => emit(
    state.copyWith(
      draft: state.draft.copyWith(tags: [...state.draft.tags, tag]),
    ),
  );

  void removeTag(DraftTag tag) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        tags: [
          for (final other in state.draft.tags)
            if (other != tag) other,
        ],
      ),
    ),
  );

  void setCaption(String caption) =>
      emit(state.copyWith(draft: state.draft.copyWith(caption: caption)));

  void setLocation(String location) =>
      emit(state.copyWith(draft: state.draft.copyWith(location: location)));

  void toggleStyle(String style) {
    final styles = state.draft.styles;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          styles: styles.contains(style)
              ? [
                  for (final other in styles)
                    if (other != style) other,
                ]
              : [...styles, style],
        ),
      ),
    );
  }

  void setAllowBrandFeature(bool allow) {
    _brandFeatureSet = true;
    emit(state.copyWith(draft: state.draft.copyWith(allowBrandFeature: allow)));
  }

  Future<void> publish() async {
    if (state.status == PublishStatus.publishing) return;
    emit(state.copyWith(status: PublishStatus.publishing));
    final result = await _publish(state.draft);
    if (isClosed) return;
    emit(
      result.match(
        (failure) =>
            state.copyWith(status: PublishStatus.failure, failure: failure),
        (postId) => state.copyWith(
          status: PublishStatus.published,
          publishedPostId: postId,
        ),
      ),
    );
  }
}
