import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/home_feed.dart';
import '../failures/home_failure.dart';
import '../repositories/home_repository.dart';

class GetHomeFeed
    implements UseCase<Future<Either<HomeFailure, HomeFeed>>, NoParams> {
  const GetHomeFeed(this._home);

  final HomeRepository _home;

  @override
  Future<Either<HomeFailure, HomeFeed>> call(NoParams params) =>
      _home.getHomeFeed();
}
