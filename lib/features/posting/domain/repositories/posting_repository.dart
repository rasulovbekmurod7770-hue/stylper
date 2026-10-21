import 'package:fpdart/fpdart.dart';

import '../entities/post_draft.dart';
import '../entities/taggable_item.dart';
import '../failures/posting_failure.dart';

abstract interface class PostingRepository {
  /// Catalog products from brand and business profiles matching [query];
  /// with [mine], only the user's wardrobe — including, first, the items
  /// they added themselves.
  Future<Either<PostingFailure, List<TaggableItem>>> searchItems(
    String query, {
    String? category,
    bool mine = false,
  });

  /// Catalog products the user tagged recently.
  Future<Either<PostingFailure, List<TaggableItem>>> recentTags();

  /// Styles a post can be tagged with.
  Future<Either<PostingFailure, List<String>>> styles();

  /// Publishes [draft] to everyone; the new post's id.
  Future<Either<PostingFailure, String>> publish(PostDraft draft);
}
