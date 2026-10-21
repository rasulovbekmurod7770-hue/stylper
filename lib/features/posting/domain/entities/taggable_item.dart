import 'package:equatable/equatable.dart';

import '../../../../core/domain/money.dart';
import '../../../product/domain/entities/product.dart';
import '../../../wardrobe/domain/entities/wardrobe.dart';

/// Something that can be tagged on a post: a product from a brand's catalog,
/// or ([own]) clothes the user added to their wardrobe themselves.
class TaggableItem extends Equatable {
  const TaggableItem({
    required this.id,
    required this.name,
    required this.label,
    required this.brand,
    this.price,
    this.imagePath,
    this.own = false,
  });

  TaggableItem.product(ProductSummary product)
    : this(
        id: product.id,
        name: product.name,
        label: product.shortName,
        brand: product.brand,
        price: product.price,
        imagePath: product.imagePath,
      );

  /// An item the user added to their wardrobe themselves.
  TaggableItem.own(WardrobeItem item)
    : this(
        id: item.id,
        name: item.name,
        label: item.name,
        brand: item.brand ?? '',
        price: item.price,
        imagePath: item.imagePath,
        own: true,
      );

  /// The product's id, or the wardrobe item's for [own] items.
  final String id;
  final String name;

  /// For the photo's "{brand} · {label}": the item type of a product, e.g.
  /// "Sweater"; an own item's name.
  final String label;
  final String brand;

  /// Always set for products; optional for own items.
  final Money? price;

  /// Own items have no photo.
  final String? imagePath;

  /// Not in any catalog: the published post shows it as added by its author.
  final bool own;

  @override
  List<Object?> get props => [id, name, label, brand, price, imagePath, own];
}
