import 'package:fpdart/fpdart.dart';

import '../entities/search_results.dart';
import '../failures/search_failure.dart';

abstract interface class SearchRepository {
  /// Brands on Stylper and trending looks. Public.
  Future<Either<SearchFailure, SearchDiscovery>> discover();

  /// Brands and people whose username or name matches [query]. Public.
  Future<Either<SearchFailure, SearchResults>> search(String query);
}
