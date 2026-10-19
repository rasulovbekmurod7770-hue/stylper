import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/failures/search_failure.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';
import '../models/search_json.dart';

class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl({required this._remote});

  final SearchRemoteDataSource _remote;

  @override
  Future<Either<SearchFailure, SearchDiscovery>> discover() =>
      _guard(() async => SearchJson.discovery(await _remote.discover()));

  @override
  Future<Either<SearchFailure, SearchResults>> search(String query) =>
      _guard(() async => SearchJson.results(await _remote.search(query)));

  Future<Either<SearchFailure, T>> _guard<T>(
    Future<T> Function() request,
  ) async {
    try {
      return Right(await request());
    } on ServerException {
      return const Left(SearchFailure(SearchFailureReason.unknown));
    } on NetworkException {
      return const Left(SearchFailure(SearchFailureReason.network));
    }
  }
}
