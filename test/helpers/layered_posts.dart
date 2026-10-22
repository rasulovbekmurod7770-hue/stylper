import 'package:stylper/features/post/domain/entities/post.dart';

/// A tag for layering tests, as an item the author added (no product page).
TaggedProduct layeredTag(
  String brand,
  String name,
  double x,
  double y, {
  String? category,
}) => TaggedProduct(
  id: '$brand $name',
  name: name,
  shortName: name,
  brand: brand,
  price: null,
  imagePath: null,
  styledCount: 0,
  tagX: x,
  tagY: y,
  category: category,
  addedByAuthor: true,
);

/// The worst case on John's "Rainy layers" photo: a coat and a cardigan 3%
/// apart with a t-shirt under them and a scarf on top, plus trousers and a
/// watch on their own — six tags, more than are shown at first.
final worstCaseTags = [
  layeredTag('TIMEOFLESS', 'Coat', 0.40, 0.38, category: 'outerwear'),
  layeredTag('COS', 'Cardigan', 0.43, 0.41, category: 'tops'),
  layeredTag('Terra Pro', 'T-Shirt', 0.47, 0.35, category: 'tops'),
  layeredTag('TIMEOFLESS', 'Scarf', 0.45, 0.25, category: 'accessories'),
  layeredTag('ZARA', 'Trousers', 0.50, 0.72, category: 'bottoms'),
  layeredTag('Kink', 'Watch', 0.68, 0.55, category: 'accessories'),
];
