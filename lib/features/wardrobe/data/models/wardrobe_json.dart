import '../../../post/data/models/post_json.dart';
import '../../domain/entities/wardrobe.dart';

abstract final class WardrobeJson {
  static List<WardrobeCategory> categories(JsonMap json) =>
      PostJson.list(json['categories'], _category);

  static List<WardrobeItem> items(JsonMap json) =>
      PostJson.list(json['items'], _item);

  static WardrobeCategory _category(JsonMap json) => WardrobeCategory(
    id: json['id']! as String,
    itemCount: json['count']! as int,
    imagePath: json['image'] as String?,
  );

  static WardrobeItem _item(JsonMap json) => WardrobeItem(
    id: json['id']! as String,
    name: json['name']! as String,
    imagePath: json['image']! as String,
    brand: json['brand'] as String?,
    productId: json['productId'] as String?,
  );
}
