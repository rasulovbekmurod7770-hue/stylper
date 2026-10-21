import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/post_draft.dart';
import '../entities/taggable_item.dart';
import '../failures/posting_failure.dart';
import '../repositories/posting_repository.dart';

final class ItemQuery extends Equatable {
  const ItemQuery(this.text, {this.category, this.mine = false});

  final String text;

  /// A wardrobe category id, or null for any.
  final String? category;

  /// Only the user's wardrobe.
  final bool mine;

  @override
  List<Object?> get props => [text, category, mine];
}

class SearchItems
    implements
        UseCase<Future<Either<PostingFailure, List<TaggableItem>>>, ItemQuery> {
  const SearchItems(this._posting);

  final PostingRepository _posting;

  @override
  Future<Either<PostingFailure, List<TaggableItem>>> call(ItemQuery query) =>
      _posting.searchItems(
        query.text,
        category: query.category,
        mine: query.mine,
      );
}

class GetRecentTags
    implements
        UseCase<Future<Either<PostingFailure, List<TaggableItem>>>, NoParams> {
  const GetRecentTags(this._posting);

  final PostingRepository _posting;

  @override
  Future<Either<PostingFailure, List<TaggableItem>>> call(NoParams params) =>
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
