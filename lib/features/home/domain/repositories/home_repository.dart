import 'package:fpdart/fpdart.dart';

import '../entities/home_feed.dart';
import '../failures/home_failure.dart';

abstract interface class HomeRepository {
  /// The editorial home feed. Public: guests see it too.
  Future<Either<HomeFailure, HomeFeed>> getHomeFeed();
}
