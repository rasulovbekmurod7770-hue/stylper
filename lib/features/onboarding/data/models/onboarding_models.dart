import '../../domain/entities/profile_details.dart';
import '../../domain/entities/style_quiz.dart';

extension ProfileDetailsJson on ProfileDetails {
  /// Body of `PUT /me/profile`.
  Map<String, Object?> toJson() => {
    'username': username,
    'gender': gender.name,
    'age': age,
    'heightCm': heightCm,
    'weightKg': weightKg,
  };
}

class OutfitItemModel {
  const OutfitItemModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.imagePath,
    required this.category,
  });

  factory OutfitItemModel.fromJson(Map<String, Object?> json) =>
      OutfitItemModel(
        id: json['id']! as String,
        name: json['name']! as String,
        brand: json['brand']! as String,
        imagePath: json['image']! as String,
        category: OutfitCategory.values.byName(json['category']! as String),
      );

  final String id;
  final String name;
  final String brand;
  final String imagePath;
  final OutfitCategory category;

  OutfitItem toEntity() => OutfitItem(
    id: id,
    name: name,
    brand: brand,
    imagePath: imagePath,
    category: category,
  );
}
