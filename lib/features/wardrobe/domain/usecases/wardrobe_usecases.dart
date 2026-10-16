import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/wardrobe.dart';
import '../failures/wardrobe_failure.dart';
import '../repositories/wardrobe_repository.dart';

class GetWardrobe
    implements
        UseCase<
          Future<Either<WardrobeFailure, List<WardrobeCategory>>>,
          NoParams
        > {
  const GetWardrobe(this._wardrobe);

  final WardrobeRepository _wardrobe;

  @override
  Future<Either<WardrobeFailure, List<WardrobeCategory>>> call(
    NoParams params,
  ) => _wardrobe.getCategories();
}

class GetWardrobeItems
    implements
        UseCase<Future<Either<WardrobeFailure, List<WardrobeItem>>>, String> {
  const GetWardrobeItems(this._wardrobe);

  final WardrobeRepository _wardrobe;

  @override
  Future<Either<WardrobeFailure, List<WardrobeItem>>> call(String category) =>
      _wardrobe.getItems(category);
}

final class WardrobeToggle extends Equatable {
  const WardrobeToggle(this.itemId, {required this.saved});

  final String itemId;
  final bool saved;

  @override
  List<Object?> get props => [itemId, saved];
}

class SetInWardrobe
    implements UseCase<Future<Either<WardrobeFailure, bool>>, WardrobeToggle> {
  const SetInWardrobe(this._wardrobe);

  final WardrobeRepository _wardrobe;

  @override
  Future<Either<WardrobeFailure, bool>> call(WardrobeToggle toggle) =>
      _wardrobe.setInWardrobe(toggle.itemId, saved: toggle.saved);
}
