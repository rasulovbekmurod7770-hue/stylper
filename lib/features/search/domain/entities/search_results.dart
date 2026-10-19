import 'package:equatable/equatable.dart';

import '../../../post/domain/entities/post.dart';

/// A brand (or other business) with a showroom on Stylper.
class BrandSummary extends Equatable {
  const BrandSummary({
    required this.id,
    required this.name,
    required this.handle,
    required this.productCount,
    this.logoPath,
    this.isLocal = false,
    this.isVerified = false,
  });

  final String id;
  final String name;

  /// Username without the leading `@`.
  final String handle;

  /// Null until the brand uploads one; the app shows a monogram.
  final String? logoPath;

  /// An Uzbek brand (listed first: local brands first).
  final bool isLocal;

  /// The showroom is run by the brand itself.
  final bool isVerified;

  /// How many catalog items the brand sells on Stylper.
  final int productCount;

  @override
  List<Object?> get props => [
    id,
    name,
    handle,
    logoPath,
    isLocal,
    isVerified,
    productCount,
  ];
}

/// What Search shows before anything is typed.
class SearchDiscovery extends Equatable {
  const SearchDiscovery({
    required this.city,
    required this.brands,
    required this.trending,
  });

  final String city;
  final List<BrandSummary> brands;
  final List<PostPreview> trending;

  @override
  List<Object?> get props => [city, brands, trending];
}

/// Brands and people matching a query, best matches first. People carry
/// whether you follow them, for their Follow button.
class SearchResults extends Equatable {
  const SearchResults({this.brands = const [], this.people = const []});

  final List<BrandSummary> brands;
  final List<PostAuthor> people;

  bool get isEmpty => brands.isEmpty && people.isEmpty;

  @override
  List<Object?> get props => [brands, people];
}
