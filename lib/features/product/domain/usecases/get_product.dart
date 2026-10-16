import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../failures/product_failure.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProduct
    implements UseCase<Future<Either<ProductFailure, ProductDetail>>, String> {
  const GetProduct(this._products);

  final ProductRepository _products;

  @override
  Future<Either<ProductFailure, ProductDetail>> call(String productId) =>
      _products.getProduct(productId);
}
