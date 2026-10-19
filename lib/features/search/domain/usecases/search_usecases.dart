import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/search_results.dart';
import '../failures/search_failure.dart';
import '../repositories/search_repository.dart';

class GetSearchDiscovery
    implements
        UseCase<Future<Either<SearchFailure, SearchDiscovery>>, NoParams> {
  const GetSearchDiscovery(this._search);

  final SearchRepository _search;

  @override
  Future<Either<SearchFailure, SearchDiscovery>> call(NoParams params) =>
      _search.discover();
}

/// Finds brands and people by username or name (a leading `@` is fine).
class SearchBrandsAndPeople
    implements UseCase<Future<Either<SearchFailure, SearchResults>>, String> {
  const SearchBrandsAndPeople(this._search);

  final SearchRepository _search;

  @override
  Future<Either<SearchFailure, SearchResults>> call(String query) =>
      _search.search(query);
}
