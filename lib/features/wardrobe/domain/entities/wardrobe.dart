import 'package:equatable/equatable.dart';

import '../../../../core/domain/money.dart';

/// Category ids the API uses (`item_category_t`).
abstract final class WardrobeCategories {
  static const outerwear = 'outerwear';
  static const tops = 'tops';
  static const bottoms = 'bottoms';
  static const shoes = 'shoes';
  static const accessories = 'accessories';

  /// Display order: outside in, as people layer clothes.
  static const all = [outerwear, tops, bottoms, shoes, accessories];
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
    this.imagePath,
    this.brand,
    this.price,
    this.productId,
  });

  final String id;
  final String name;

  /// Bundled asset path for now; an image URL once it comes from the API.
  /// Null for an item added without a photo.
  final String? imagePath;
  final String? brand;

  /// Null when the user didn't give one for an item they added.
  final Money? price;

  /// Set when the item is a catalog product, which opens its product page.
  final String? productId;

  @override
  List<Object?> get props => [id, name, imagePath, brand, price, productId];
}

/// Clothes the user adds to their wardrobe themselves, because no brand on
/// Stylper sells them. Private to their wardrobe; tagged on a post, it shows
/// everyone what the item is.
class NewWardrobeItem extends Equatable {
  const NewWardrobeItem({
    required this.name,
    required this.brand,
    required this.category,
    this.price,
  });

  final String name;
  final String brand;

  /// One of [WardrobeCategories].
  final String category;

  /// Optional.
  final Money? price;

  @override
  List<Object?> get props => [name, brand, category, price];
}
