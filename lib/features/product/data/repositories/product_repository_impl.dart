import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/failures/product_failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_json.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({required this._remote});

  final ProductRemoteDataSource _remote;

  @override
  Future<Either<ProductFailure, ProductDetail>> getProduct(String id) async {
    try {
      return Right(ProductJson.detail(await _remote.getProduct(id)));
    } on ServerException catch (e) {
      return Left(
        ProductFailure(
          e.code == ApiErrorCodes.notFound
              ? ProductFailureReason.notFound
              : ProductFailureReason.unknown,
        ),
      );
    } on NetworkException {
      return const Left(ProductFailure(ProductFailureReason.network));
    }
  }
}
