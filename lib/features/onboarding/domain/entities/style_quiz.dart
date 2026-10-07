import 'package:equatable/equatable.dart';

enum OutfitCategory { top, bottom }

/// A clothing item shown in the style quiz, tagged with its brand.
class OutfitItem extends Equatable {
  const OutfitItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.imagePath,
    required this.category,
  });

  final String id;
  final String name;
  final String brand;

  /// Bundled asset path for now; an image URL once items come from the API.
  final String imagePath;
  final OutfitCategory category;

  @override
  List<Object?> get props => [id, name, brand, imagePath, category];
}

class StyleQuiz extends Equatable {
  const StyleQuiz({required this.tops, required this.bottoms});

  final List<OutfitItem> tops;
  final List<OutfitItem> bottoms;

  @override
  List<Object?> get props => [tops, bottoms];
}
