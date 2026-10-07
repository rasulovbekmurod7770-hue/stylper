import '../../../../core/constants/app_assets.dart';
import '../models/onboarding_models.dart';

/// Quiz items bundled with the app. Replace with `GET /style-quiz` once the
/// backend serves real brand items.
class StyleQuizLocalDataSource {
  const StyleQuizLocalDataSource();

  static const _items = [
    {
      'id': 'terra-pro-white-tshirt',
      'name': 'White T-Shirt',
      'brand': 'Terra Pro',
      'image': AppImages.quizWhiteTShirt,
      'category': 'top',
    },
    {
      'id': 'kink-baggy-jeans',
      'name': 'Baggy Jeans',
      'brand': 'Kink',
      'image': AppImages.quizBaggyJeans,
      'category': 'bottom',
    },
  ];

  List<OutfitItemModel> getItems() =>
      _items.map(OutfitItemModel.fromJson).toList(growable: false);
}
