import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/failures/product_failure.dart';
import '../../domain/usecases/get_product.dart';

enum ProductDetailStatus { loading, ready, failure }

final class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.loading,
    this.detail,
    this.failure,
  });

  final ProductDetailStatus status;
  final ProductDetail? detail;
  final ProductFailure? failure;

  @override
  List<Object?> get props => [status, detail, failure];
}

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(this._getProduct, {required this.productId})
    : super(const ProductDetailState());

  final GetProduct _getProduct;
  final String productId;

  Future<void> load() async {
    emit(const ProductDetailState());
    final result = await _getProduct(productId);
    if (isClosed) return;
    emit(
      result.match(
        (failure) => ProductDetailState(
          status: ProductDetailStatus.failure,
          failure: failure,
        ),
        (detail) => ProductDetailState(
          status: ProductDetailStatus.ready,
          detail: detail,
        ),
      ),
    );
  }
}
