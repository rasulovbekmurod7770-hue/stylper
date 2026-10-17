import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../post/data/models/post_json.dart';
import '../../../product/data/models/product_json.dart';
import '../../../product/domain/entities/product.dart';
import '../../domain/entities/post_draft.dart';
import '../../domain/failures/posting_failure.dart';
import '../../domain/repositories/posting_repository.dart';
import '../datasources/posting_remote_data_source.dart';

class PostingRepositoryImpl implements PostingRepository {
  const PostingRepositoryImpl({required this._remote});

  final PostingRemoteDataSource _remote;

  @override
  Future<Either<PostingFailure, List<ProductSummary>>> searchProducts(
    String query, {
    String? category,
    bool mine = false,
  }) => _guard(
    () async => PostJson.list(
      (await _remote.searchProducts(
        query,
        category: category,
        mine: mine,
      ))['products'],
      ProductJson.summary,
    ),
  );

  @override
  Future<Either<PostingFailure, List<ProductSummary>>> recentTags() => _guard(
    () async => PostJson.list(
      (await _remote.recentTags())['products'],
      ProductJson.summary,
    ),
  );

  @override
  Future<Either<PostingFailure, List<String>>> styles() =>
      _guard(() async => PostJson.strings((await _remote.styles())['styles']));

  @override
  Future<Either<PostingFailure, String>> publish(PostDraft draft) => _guard(
    () async =>
        (await _remote.publish({
              'image': draft.photoPath,
              if (draft.caption.trim().isNotEmpty)
                'caption': draft.caption.trim(),
              if (draft.location.trim().isNotEmpty)
                'location': draft.location.trim(),
              'styles': draft.styles,
              'tags': [
                for (final tag in draft.tags)
                  {'productId': tag.productId, 'x': tag.x, 'y': tag.y},
              ],
              'allowBrandFeature': draft.allowBrandFeature,
            }))['id']!
            as String,
  );

  Future<Either<PostingFailure, T>> _guard<T>(
    Future<T> Function() request,
  ) async {
    try {
      return Right(await request());
    } on ServerException catch (e) {
      return Left(
        PostingFailure(switch (e.code) {
          ApiErrorCodes.unauthorized => PostingFailureReason.signInRequired,
          ApiErrorCodes.validation => PostingFailureReason.invalid,
          _ => PostingFailureReason.unknown,
        }),
      );
    } on NetworkException {
      return const Left(PostingFailure(PostingFailureReason.network));
    }
  }
}
