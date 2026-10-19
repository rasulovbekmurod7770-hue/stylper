import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/failures/search_failure.dart';
import '../../domain/usecases/search_usecases.dart';

final class SearchState extends Equatable {
  const SearchState({
    this.discovery,
    this.discoveryFailure,
    this.query = '',
    this.results,
    this.searching = false,
    this.failure,
  });

  /// Brands and trending looks, shown while nothing is typed.
  final SearchDiscovery? discovery;
  final SearchFailure? discoveryFailure;

  /// What's typed in the field.
  final String query;

  /// The latest answer for [query]; kept on screen while the next search
  /// runs. Null before the first answer.
  final SearchResults? results;
  final bool searching;
  final SearchFailure? failure;

  /// Nothing worth searching for is typed (blank, or just `@`).
  bool get isIdle => SearchCubit.normalize(query).isEmpty;

  @override
  List<Object?> get props => [
    discovery,
    discoveryFailure,
    query,
    results,
    searching,
    failure,
  ];
}

/// Search: brands and people by username or name. Searches once the user
/// pauses typing; an answer to an older query is dropped.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._discover, this._search) : super(const SearchState());

  final GetSearchDiscovery _discover;
  final SearchBrandsAndPeople _search;
  Timer? _debounce;

  static const debounce = Duration(milliseconds: 300);

  /// The query as the backend matches it: trimmed, without a leading `@`.
  static String normalize(String query) =>
      query.trim().replaceFirst(RegExp('^@'), '').trim();

  Future<void> loadDiscovery() async {
    final result = await _discover(const NoParams());
    if (isClosed) return;
    emit(
      result.match(
        (failure) => _copy(discoveryFailure: () => failure),
        (discovery) =>
            _copy(discovery: discovery, discoveryFailure: () => null),
      ),
    );
  }

  void setQuery(String query) {
    if (query == state.query) return;
    _debounce?.cancel();
    if (normalize(query).isEmpty) {
      // Back to the discovery page at once; no request.
      return emit(
        SearchState(
          discovery: state.discovery,
          discoveryFailure: state.discoveryFailure,
          query: query,
        ),
      );
    }
    // A new query clears the last error at once.
    emit(_copy(query: query, failure: () => null));
    _debounce = Timer(debounce, _run);
  }

  /// Searches [SearchState.query] again, e.g. after a failure.
  Future<void> retry() => _run();

  Future<void> _run() async {
    final query = state.query;
    if (normalize(query).isEmpty) return;
    emit(_copy(searching: true));
    final result = await _search(query);
    // A newer query was typed meanwhile; its own search reports.
    if (isClosed || query != state.query) return;
    emit(
      result.match(
        (failure) => _copy(searching: false, failure: () => failure),
        (results) =>
            _copy(searching: false, results: results, failure: () => null),
      ),
    );
  }

  SearchState _copy({
    SearchDiscovery? discovery,
    SearchFailure? Function()? discoveryFailure,
    String? query,
    SearchResults? results,
    bool? searching,
    SearchFailure? Function()? failure,
  }) => SearchState(
    discovery: discovery ?? state.discovery,
    discoveryFailure: discoveryFailure == null
        ? state.discoveryFailure
        : discoveryFailure(),
    query: query ?? state.query,
    results: results ?? state.results,
    searching: searching ?? state.searching,
    failure: failure == null ? state.failure : failure(),
  );

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
