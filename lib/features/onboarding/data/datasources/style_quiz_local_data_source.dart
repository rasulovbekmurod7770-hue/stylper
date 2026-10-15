import '../../../../core/constants/app_assets.dart';
import '../models/onboarding_models.dart';

/// Quiz items bundled with the app. Replace with `GET /style-quiz` once the
/// backend serves real brand items.
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
    },
    {
      'id': 'uniqlo-striped-long-sleeve',
      'name': 'Striped Long Sleeve',
      'brand': 'UNIQLO',
      'image': AppImages.quizStripedLongSleeve,
      'category': 'top',
    },
    {
      'id': 'cos-cotton-cardigan',
      'name': 'Cotton Cardigan',
      'brand': 'COS',
      'image': AppImages.quizCottonCardigan,
      'category': 'top',
    },
    {
      'id': 'zara-oversized-white-tshirt',
      'name': 'Oversized White T-Shirt',
      'brand': 'ZARA',
      'image': AppImages.quizOversizedWhiteTShirt,
      'category': 'top',
    },
    {
      'id': 'arket-rugby-polo-sweater',
      'name': 'Rugby Polo Sweater',
      'brand': 'ARKET',
      'image': AppImages.quizRugbyPoloSweater,
      'category': 'top',
    },
    {
      'id': 'uniqlo-waffle-long-sleeve',
      'name': 'Waffle Long-Sleeve',
      'brand': 'UNIQLO',
      'image': AppImages.quizWaffleLongSleeve,
      'category': 'top',
    },
    // Bottoms
    {
      'id': 'kink-baggy-jeans',
      'name': 'Baggy Jeans',
      'brand': 'Kink',
      'image': AppImages.quizBaggyJeans,
      'category': 'bottom',
    },
    {
      'id': 'cos-barrel-loose-fit-jeans',
      'name': 'Barrel Loose-Fit Jeans',
      'brand': 'COS',
      'image': AppImages.quizBarrelLooseFitJeans,
      'category': 'bottom',
    },
    {
      'id': 'arket-colored-denim-jeans',
      'name': 'Colored Denim Jeans',
      'brand': 'ARKET',
      'image': AppImages.quizColoredDenimJeans,
      'category': 'bottom',
    },
    {
      'id': 'uniqlo-ecru-loose-fit-jeans',
      'name': 'Loose Fit Jeans in Ecru',
      'brand': 'UNIQLO',
      'image': AppImages.quizEcruLooseFitJeans,
      'category': 'bottom',
    },
    {
      'id': 'zara-vintage-jeans',
      'name': 'Vintage Jeans',
      'brand': 'ZARA',
      'image': AppImages.quizVintageJeans,
      'category': 'bottom',
    },
    {
      'id': 'zara-wide-leg-tailored-trousers',
      'name': 'Wide Leg Tailored Trousers',
      'brand': 'ZARA',
      'image': AppImages.quizWideLegTrousers,
      'category': 'bottom',
    },
  ];

  List<OutfitItemModel> getItems() =>
      _items.map(OutfitItemModel.fromJson).toList(growable: false);
}
