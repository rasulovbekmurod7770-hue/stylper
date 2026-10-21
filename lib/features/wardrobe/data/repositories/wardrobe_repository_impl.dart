import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/wardrobe.dart';
import '../../domain/failures/wardrobe_failure.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../datasources/wardrobe_remote_data_source.dart';
import '../models/wardrobe_json.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  const WardrobeRepositoryImpl({required this._remote});

  final WardrobeRemoteDataSource _remote;

  @override
  Future<Either<WardrobeFailure, List<WardrobeCategory>>> getCategories() =>
      _guard(
        () async => WardrobeJson.categories(await _remote.getCategories()),
      );

  @override
  Future<Either<WardrobeFailure, List<WardrobeItem>>> getItems(
    String category,
  ) => _guard(() async => WardrobeJson.items(await _remote.getItems(category)));

  @override
  Future<Either<WardrobeFailure, bool>> setInWardrobe(
    String itemId, {
    required bool saved,
  }) => _guard(
    () async =>
        (await _remote.setInWardrobe(itemId, saved: saved))['inWardrobe']!
            as bool,
  );

  @override
  Future<Either<WardrobeFailure, WardrobeItem>> addItem(NewWardrobeItem item) =>
      _guard(
        () async => WardrobeJson.item(
          await _remote.addItem(WardrobeJson.newItem(item)),
        ),
      );

  Future<Either<WardrobeFailure, T>> _guard<T>(
    Future<T> Function() request,
  ) async {
    try {
      return Right(await request());
    } on ServerException catch (e) {
      return Left(
        WardrobeFailure(switch (e.code) {
          ApiErrorCodes.unauthorized => WardrobeFailureReason.signInRequired,
          ApiErrorCodes.notFound => WardrobeFailureReason.notFound,
          _ => WardrobeFailureReason.unknown,
        }),
      );
    } on NetworkException {
      return const Left(WardrobeFailure(WardrobeFailureReason.network));
    }
  }
}
