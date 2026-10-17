import 'package:equatable/equatable.dart';

/// A clothing item tagged on the new post's photo.
class DraftTag extends Equatable {
  const DraftTag({
    required this.productId,
    required this.brand,
    required this.label,
    required this.imagePath,
    required this.x,
    required this.y,
  });

  /// The catalog product, so the published post leads to it.
  final String productId;
  final String brand;

  /// The item, e.g. "Sweater"; the photo shows "{brand} · {label}".
  final String label;
  final String imagePath;

  /// Where the tag sits, as fractions of the photo's width / height.
  final double x;
  final double y;

  @override
  List<Object?> get props => [productId, brand, label, imagePath, x, y];
}

/// A post being created: Figma "Posting" (2849:1017), steps 1–4.
class PostDraft extends Equatable {
  const PostDraft({
    this.photoPath,
    this.tags = const [],
    this.caption = '',
    this.location = '',
    this.styles = const [],
    this.allowBrandFeature = false,
  });

  /// The chosen photo, a file on the device.
  final String? photoPath;
  final List<DraftTag> tags;
  final String caption;
  final String location;
  final List<String> styles;

  /// Brands may show the post in their showroom. There's no audience
  /// setting: every post is visible to everyone on Stylper.
  final bool allowBrandFeature;

  bool get isEmpty => photoPath == null && tags.isEmpty && caption.isEmpty;

  /// The tagged brands, without repeats ("Mentioned brands").
  List<String> get brands => [
    ...{for (final tag in tags) tag.brand},
  ];

  PostDraft copyWith({
    String? photoPath,
    List<DraftTag>? tags,
    String? caption,
    String? location,
    List<String>? styles,
    bool? allowBrandFeature,
  }) => PostDraft(
    photoPath: photoPath ?? this.photoPath,
    tags: tags ?? this.tags,
    caption: caption ?? this.caption,
    location: location ?? this.location,
    styles: styles ?? this.styles,
    allowBrandFeature: allowBrandFeature ?? this.allowBrandFeature,
  );

  @override
  List<Object?> get props => [
    photoPath,
    tags,
    caption,
    location,
    styles,
    allowBrandFeature,
  ];
}
