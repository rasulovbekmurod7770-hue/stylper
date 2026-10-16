import 'package:fpdart/fpdart.dart';

import '../failures/product_failure.dart';
import '../entities/product.dart';

abstract interface class ProductRepository {
  /// Public: guests can open products too.
  Future<Either<ProductFailure, ProductDetail>> getProduct(String id);
}
