import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/failures/home_failure.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/home_feed_json.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required this._remote});

  final HomeRemoteDataSource _remote;

  @override
  Future<Either<HomeFailure, HomeFeed>> getHomeFeed() async {
    try {
      return Right(HomeFeedJson.parse(await _remote.getHomeFeed()));
    } on ServerException {
      return const Left(HomeFailure(HomeFailureReason.unknown));
    } on NetworkException {
      return const Left(HomeFailure(HomeFailureReason.network));
    }
  }
}
