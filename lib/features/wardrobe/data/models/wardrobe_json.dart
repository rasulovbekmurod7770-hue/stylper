import '../../../post/data/models/post_json.dart';
import '../../../../core/domain/money.dart';
import '../../domain/entities/wardrobe.dart';

abstract final class WardrobeJson {
  static List<WardrobeCategory> categories(JsonMap json) =>
      PostJson.list(json['categories'], _category);

  static List<WardrobeItem> items(JsonMap json) =>
      PostJson.list(json['items'], item);

  static WardrobeCategory _category(JsonMap json) => WardrobeCategory(
    id: json['id']! as String,
    itemCount: json['count']! as int,
    imagePath: json['image'] as String?,
  );

  static WardrobeItem item(JsonMap json) => WardrobeItem(
    id: json['id']! as String,
    name: json['name']! as String,
    imagePath: json['image'] as String?,
    brand: json['brand'] as String?,
    price: money(json['price'] as JsonMap?),
    productId: json['productId'] as String?,
  );

  /// Reads `{amount, currency}`; null stays null.
  static Money? money(JsonMap? json) => json == null
      ? null
      : Money(
          amount: json['amount']! as num,
          currency: json['currency']! as String,
        );

  /// The body of POST /me/wardrobe/items.
  static JsonMap newItem(NewWardrobeItem item) => {
    'name': item.name,
    'brand': item.brand,
    'category': item.category,
    if (item.price case final price?)
      'price': {'amount': price.amount, 'currency': price.currency},
  };
}
