import '../../../../core/constants/app_assets.dart';
import '../../../../core/domain/style_keys.dart';
import '../models/onboarding_models.dart';

/// Quiz items bundled with the app. Replace with `GET /style-quiz` once the
/// backend serves real brand items. Each has one or two `styles` (the
/// stronger first), from which the liked outfit's Style DNA is counted.
class StyleQuizLocalDataSource {
  const StyleQuizLocalDataSource();

  static const _items = [
    // Tops
    {
      'id': 'terra-pro-white-tshirt',
      'name': 'White T-Shirt',
      'brand': 'Terra Pro',
      'image': AppImages.quizWhiteTShirt,
      'category': 'top',
      'styles': [StyleKeys.minimal, StyleKeys.neutral],
    },
    {
      'id': 'uniqlo-striped-long-sleeve',
      'name': 'Striped Long Sleeve',
      'brand': 'UNIQLO',
      'image': AppImages.quizStripedLongSleeve,
      'category': 'top',
      'styles': [StyleKeys.casual],
    },
    {
      'id': 'cos-cotton-cardigan',
      'name': 'Cotton Cardigan',
      'brand': 'COS',
      'image': AppImages.quizCottonCardigan,
      'category': 'top',
      'styles': [StyleKeys.smartCasual, StyleKeys.minimal],
    },
    {
      'id': 'zara-oversized-white-tshirt',
      'name': 'Oversized White T-Shirt',
      'brand': 'ZARA',
      'image': AppImages.quizOversizedWhiteTShirt,
      'category': 'top',
      'styles': [StyleKeys.oversized, StyleKeys.streetwear],
    },
    {
      'id': 'arket-rugby-polo-sweater',
      'name': 'Rugby Polo Sweater',
      'brand': 'ARKET',
      'image': AppImages.quizRugbyPoloSweater,
      'category': 'top',
      'styles': [StyleKeys.smartCasual, StyleKeys.casual],
    },
    {
      'id': 'uniqlo-waffle-long-sleeve',
      'name': 'Waffle Long-Sleeve',
      'brand': 'UNIQLO',
      'image': AppImages.quizWaffleLongSleeve,
      'category': 'top',
      'styles': [StyleKeys.casual, StyleKeys.neutral],
    },
    // Bottoms
    {
      'id': 'kink-baggy-jeans',
      'name': 'Baggy Jeans',
      'brand': 'Kink',
      'image': AppImages.quizBaggyJeans,
      'category': 'bottom',
      'styles': [StyleKeys.streetwear, StyleKeys.oversized],
    },
    {
      'id': 'cos-barrel-loose-fit-jeans',
      'name': 'Barrel Loose-Fit Jeans',
      'brand': 'COS',
      'image': AppImages.quizBarrelLooseFitJeans,
      'category': 'bottom',
      'styles': [StyleKeys.oversized, StyleKeys.casual],
    },
    {
      'id': 'arket-colored-denim-jeans',
      'name': 'Colored Denim Jeans',
      'brand': 'ARKET',
      'image': AppImages.quizColoredDenimJeans,
      'category': 'bottom',
      'styles': [StyleKeys.casual],
    },
    {
      'id': 'uniqlo-ecru-loose-fit-jeans',
      'name': 'Loose Fit Jeans in Ecru',
      'brand': 'UNIQLO',
      'image': AppImages.quizEcruLooseFitJeans,
      'category': 'bottom',
      'styles': [StyleKeys.neutral, StyleKeys.minimal],
    },
    {
      'id': 'zara-vintage-jeans',
      'name': 'Vintage Jeans',
      'brand': 'ZARA',
      'image': AppImages.quizVintageJeans,
      'category': 'bottom',
      'styles': [StyleKeys.streetwear, StyleKeys.casual],
    },
    {
      'id': 'zara-wide-leg-tailored-trousers',
      'name': 'Wide Leg Tailored Trousers',
      'brand': 'ZARA',
      'image': AppImages.quizWideLegTrousers,
      'category': 'bottom',
      'styles': [StyleKeys.smartCasual, StyleKeys.minimal],
    },
  ];

  List<OutfitItemModel> getItems() =>
      _items.map(OutfitItemModel.fromJson).toList(growable: false);
}
