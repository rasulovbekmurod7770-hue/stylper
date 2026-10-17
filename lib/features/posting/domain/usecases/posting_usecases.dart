import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../product/domain/entities/product.dart';
import '../entities/post_draft.dart';
import '../failures/posting_failure.dart';
import '../repositories/posting_repository.dart';

final class ProductQuery extends Equatable {
  const ProductQuery(this.text, {this.category, this.mine = false});

  final String text;

  /// A wardrobe category id, or null for any.
  final String? category;

  /// Only products in the user's wardrobe.
  final bool mine;

  @override
  List<Object?> get props => [text, category, mine];
}

class SearchProducts
    implements
        UseCase<
          Future<Either<PostingFailure, List<ProductSummary>>>,
          ProductQuery
        > {
  const SearchProducts(this._posting);

  final PostingRepository _posting;

  @override
  Future<Either<PostingFailure, List<ProductSummary>>> call(
    ProductQuery query,
  ) => _posting.searchProducts(
    query.text,
    category: query.category,
    mine: query.mine,
  );
}

class GetRecentTags
    implements
        UseCase<
          Future<Either<PostingFailure, List<ProductSummary>>>,
          NoParams
        > {
  const GetRecentTags(this._posting);

  final PostingRepository _posting;

  @override
  Future<Either<PostingFailure, List<ProductSummary>>> call(NoParams params) =>
      _posting.recentTags();
}

class GetPostStyles
    implements UseCase<Future<Either<PostingFailure, List<String>>>, NoParams> {
  const GetPostStyles(this._posting);

  final PostingRepository _posting;

  @override
  Future<Either<PostingFailure, List<String>>> call(NoParams params) =>
      _posting.styles();
}

class PublishPost
    implements UseCase<Future<Either<PostingFailure, String>>, PostDraft> {
  const PublishPost(this._posting);

  final PostingRepository _posting;

  @override
  Future<Either<PostingFailure, String>> call(PostDraft draft) =>
      _posting.publish(draft);
}
