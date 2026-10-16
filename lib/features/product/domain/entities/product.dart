import 'package:equatable/equatable.dart';

import '../../../post/domain/entities/post.dart';

// Image fields hold a bundled asset path for now; an image URL once products
// come from the API.

/// A product as a card ("Similar Style").
class ProductSummary extends Equatable {
  const ProductSummary({
    required this.id,
    required this.name,
    required this.shortName,
    required this.brand,
    required this.price,
    required this.imagePath,
  });

  final String id;
  final String name;

  /// Item type, e.g. "Cardigan".
  final String shortName;
  final String brand;
  final Money price;
  final String imagePath;

  @override
  List<Object?> get props => [id, name, shortName, brand, price, imagePath];
}

/// Where to buy a product.
class Store extends Equatable {
  const Store({required this.name, required this.url});

  /// Shown as "Available at {name}", e.g. "uniqlo.com".
  final String name;
  final Uri url;

  @override
  List<Object?> get props => [name, url];
}

/// A style people wear the product in ("How people style it").
class ProductStyle extends Equatable {
  const ProductStyle({required this.name, required this.imagePath});

  final String name;
  final String imagePath;

  @override
  List<Object?> get props => [name, imagePath];
}

/// Figma "product-detail" (2775:3077): the exact item, real people wearing
/// it, and similar items.
class ProductDetail extends Equatable {
  const ProductDetail({
    required this.product,
    required this.styledCount,
    required this.inWardrobe,
    this.store,
    this.looks = const [],
    this.styles = const [],
    this.similar = const [],
  });

  final ProductSummary product;

  /// How many people posted outfits with it.
  final int styledCount;

  /// Whether it's in the signed-in user's wardrobe.
  final bool inWardrobe;

  /// Null when the brand has no online store.
  final Store? store;

  /// Posts that tag this product.
  final List<PostPreview> looks;
  final List<ProductStyle> styles;
  final List<ProductSummary> similar;

  /// [looks] in [style], or all of them when [style] is null.
  List<PostPreview> looksIn(String? style) => style == null
      ? looks
      : [
          for (final look in looks)
            if (look.styles.contains(style)) look,
        ];

  @override
  List<Object?> get props => [
    product,
    styledCount,
    inWardrobe,
    store,
    looks,
    styles,
    similar,
  ];
}
