import 'package:equatable/equatable.dart';

/// Category ids the API uses, in display order.
abstract final class WardrobeCategories {
  static const tops = 'tops';
  static const bottoms = 'bottoms';
  static const shoes = 'shoes';
  static const accessories = 'accessories';
}

class WardrobeCategory extends Equatable {
  const WardrobeCategory({
    required this.id,
    required this.itemCount,
    this.imagePath,
  });

  /// One of [WardrobeCategories]; the app names it in the user's language.
  final String id;
  final int itemCount;

  /// The newest item's photo; null for an empty category.
  final String? imagePath;

  @override
  List<Object?> get props => [id, itemCount, imagePath];
}

/// Something in the user's wardrobe: a saved catalog product, or an item they
/// added themselves.
class WardrobeItem extends Equatable {
  const WardrobeItem({
    required this.id,
    required this.name,
    required this.imagePath,
    this.brand,
    this.productId,
  });

  final String id;
  final String name;

  /// Bundled asset path for now; an image URL once it comes from the API.
  final String imagePath;
  final String? brand;

  /// Set when the item is a catalog product, which opens its product page.
  final String? productId;

  @override
  List<Object?> get props => [id, name, imagePath, brand, productId];
}
