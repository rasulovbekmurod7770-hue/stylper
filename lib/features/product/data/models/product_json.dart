import '../../../../core/domain/money.dart';
import '../../../post/data/models/post_json.dart';
import '../../domain/entities/product.dart';

/// Parses `GET /products/:id`.
abstract final class ProductJson {
  static ProductDetail detail(JsonMap json) {
    final store = json['store'] as JsonMap?;
    return ProductDetail(
      product: summary(json),
      styledCount: json['styledCount']! as int,
      inWardrobe: json['inWardrobe'] as bool? ?? false,
      store: store == null
          ? null
          : Store(
              name: store['name']! as String,
              url: Uri.parse(store['url']! as String),
            ),
      looks: PostJson.list(json['looks'], PostJson.preview),
      styles: PostJson.list(
        json['styles'],
        (style) => ProductStyle(
          name: style['name']! as String,
          imagePath: style['image']! as String,
        ),
      ),
      similar: PostJson.list(json['similar'], summary),
    );
  }

  static ProductSummary summary(JsonMap json) {
    final price = json['price']! as JsonMap;
    return ProductSummary(
      id: json['id']! as String,
      name: json['name']! as String,
      shortName: json['shortName']! as String,
      brand: json['brand']! as String,
      price: Money(
        amount: price['amount']! as num,
        currency: price['currency']! as String,
      ),
      imagePath: json['image']! as String,
    );
  }
}
