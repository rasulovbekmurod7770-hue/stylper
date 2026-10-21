import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/taggable_item.dart';
import '../../domain/failures/posting_failure.dart';
import '../../domain/usecases/posting_usecases.dart';

final class TagSearchState extends Equatable {
  const TagSearchState({
    this.query = '',
    this.category,
    this.mine = false,
    this.results = const [],
    this.recent = const [],
    this.added = const [],
    this.searching = false,
    this.failure,
  });

  final String query;

  /// A wardrobe category id narrowing the search, or null for all.
  final String? category;

  /// Only items in the user's wardrobe ("My Wardrobe").
  final bool mine;
  final List<TaggableItem> results;

  /// Products the user tagged before.
  final List<TaggableItem> recent;

  /// Items the user added to their wardrobe while tagging, newest first.
  final List<TaggableItem> added;
  final bool searching;
  final PostingFailure? failure;

  @override
  List<Object?> get props => [
    query,
    category,
    mine,
    results,
    recent,
    added,
    searching,
    failure,
  ];
}

/// Finding the item to tag: brand and business catalogs (and, under "My
/// Wardrobe", the user's own items), searched by words, narrowed by
/// category.
class TagSearchCubit extends Cubit<TagSearchState> {
  TagSearchCubit(this._search, this._recentTags)
    : super(const TagSearchState());

  final SearchItems _search;
  final GetRecentTags _recentTags;
  Timer? _debounce;

  /// Loads the recent tags and the whole catalog.
  Future<void> load() async {
    final recent = await _recentTags(const NoParams());
    if (isClosed) return;
    recent.match((_) {}, (products) => emit(_copy(recent: products)));
    await _run();
  }

  /// Searches as the user types, once they pause.
  void setQuery(String query) {
    if (query == state.query) return;
    emit(_copy(query: query));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _run);
  }

  /// Shows only the user's wardrobe, or everything again.
  void toggleMine() {
    emit(_copy(mine: !state.mine));
    _run();
  }

  /// Records an item the user just added to their wardrobe, to list under
  /// the search; "My Wardrobe" results include it from now on.
  void addedItem(TaggableItem item) {
    emit(_copy(added: [item, ...state.added]));
    if (state.mine) _run();
  }

  /// Picks [category], or clears it when it's already picked.
  void toggleCategory(String category) {
    emit(_copy(category: () => state.category == category ? null : category));
    _run();
  }

  Future<void> _run() async {
    final query = _query;
    emit(_copy(searching: true));
    final result = await _search(query);
    if (isClosed) return;
    // A newer search started meanwhile; let it report.
    if (query != _query) return;
    emit(
      result.match(
        (failure) => _copy(searching: false, failure: () => failure),
        (products) =>
            _copy(searching: false, results: products, failure: () => null),
      ),
    );
  }

  ItemQuery get _query =>
      ItemQuery(state.query, category: state.category, mine: state.mine);

  TagSearchState _copy({
    String? query,
    String? Function()? category,
    bool? mine,
    List<TaggableItem>? results,
    List<TaggableItem>? recent,
    List<TaggableItem>? added,
    bool? searching,
    PostingFailure? Function()? failure,
  }) => TagSearchState(
    query: query ?? state.query,
    category: category == null ? state.category : category(),
    mine: mine ?? state.mine,
    results: results ?? state.results,
    recent: recent ?? state.recent,
    added: added ?? state.added,
    searching: searching ?? state.searching,
    failure: failure == null ? state.failure : failure(),
  );

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
