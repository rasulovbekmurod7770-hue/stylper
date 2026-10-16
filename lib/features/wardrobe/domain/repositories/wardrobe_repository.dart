import 'package:fpdart/fpdart.dart';

import '../entities/wardrobe.dart';
import '../failures/wardrobe_failure.dart';

/// The signed-in user's wardrobe.
abstract interface class WardrobeRepository {
  Future<Either<WardrobeFailure, List<WardrobeCategory>>> getCategories();

  Future<Either<WardrobeFailure, List<WardrobeItem>>> getItems(String category);

  /// Adds a catalog product ([saved]) or removes any item. Returns whether
  /// it's now in the wardrobe.
  Future<Either<WardrobeFailure, bool>> setInWardrobe(
    String itemId, {
    required bool saved,
  });
}
