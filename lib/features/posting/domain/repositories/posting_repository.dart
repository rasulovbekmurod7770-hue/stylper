import 'package:fpdart/fpdart.dart';

import '../../../product/domain/entities/product.dart';
import '../entities/post_draft.dart';
import '../failures/posting_failure.dart';

abstract interface class PostingRepository {
  /// Catalog products from brand and business profiles matching [query];
  /// with [mine], only those in the user's wardrobe.
  Future<Either<PostingFailure, List<ProductSummary>>> searchProducts(
    String query, {
    String? category,
    bool mine = false,
  });

  /// Products the user tagged recently.
  Future<Either<PostingFailure, List<ProductSummary>>> recentTags();

  /// Styles a post can be tagged with.
  Future<Either<PostingFailure, List<String>>> styles();

  /// Publishes [draft] to everyone; the new post's id.
  Future<Either<PostingFailure, String>> publish(PostDraft draft);
}
