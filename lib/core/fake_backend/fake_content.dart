import '../constants/app_assets.dart';

/// Seed content served by `FakeBackend`: the people, products and posts of
/// the Figma sample screens. Product photos reuse the style-quiz cut-outs,
/// as the Figma post screens do. Delete with the fake backend.
abstract final class FakeContent {
  static const city = 'Tashkent';
  static const styles = ['Casual', 'Minimal', 'Street'];

  static const authors = <String, Map<String, Object?>>{
    'a_mina': {
      'name': 'Mina Cho',
      'handle': 'fozil',
      'avatar': AppImages.homeAvatarMina,
    },
    'a_fozil': {
      'name': 'Fozil Can Fly',
      'handle': 'fozil',
      'avatar': AppImages.homeAvatarFozil,
    },
    'a_bobur': {
      'name': 'Bob',
      'handle': 'Bobur',
      'avatar': AppImages.homeAvatarBobur,
    },
    'a_bob': {
      'name': 'Bob',
      'handle': 'bob',
      'avatar': AppImages.homeAvatarBob,
    },
    'a_sofia': {
      'name': 'Sofia',
      'handle': 'sofia',
      'avatar': AppImages.homePersonSofia,
    },
    'a_leo': {
      'name': 'Leo',
      'handle': 'leo',
      'avatar': AppImages.homePersonLeo,
    },
    'a_amin': {
      'name': 'Amin',
      'handle': 'amin',
      'avatar': AppImages.homePersonAmin,
    },
    'a_zokir': {
      'name': 'Zokir',
      'handle': 'zokir',
      'avatar': AppImages.homeAvatarZokir,
    },
  };

  static const products = <String, Map<String, Object?>>{
    'p_cardigan_cos': {
      'name': 'Cotton Cardigan',
      'shortName': 'Cardigan',
      'brand': 'COS',
      'price': 89,
      'image': AppImages.quizCottonCardigan,
      'styledCount': 124,
    },
    'p_tee_terra_pro': {
      'name': 'White T-Shirt',
      'shortName': 'T-Shirt',
      'brand': 'Terra Pro',
      'price': 12,
      'image': AppImages.quizWhiteTShirt,
      'styledCount': 312,
    },
    'p_tee_zara': {
      'name': 'Oversized White T-Shirt',
      'shortName': 'T-Shirt',
      'brand': 'ZARA',
      'price': 19,
      'image': AppImages.quizOversizedWhiteTShirt,
      'styledCount': 143,
    },
    'p_longsleeve_uniqlo': {
      'name': 'Striped Long Sleeve',
      'shortName': 'Long sleeve',
      'brand': 'UNIQLO',
      'price': 25,
      'image': AppImages.quizStripedLongSleeve,
      'styledCount': 64,
    },
    'p_waffle_uniqlo': {
      'name': 'Waffle Long-Sleeve',
      'shortName': 'Sweater',
      'brand': 'UNIQLO',
      'price': 29,
      'image': AppImages.quizWaffleLongSleeve,
      'styledCount': 38,
    },
    'p_polo_arket': {
      'name': 'Rugby Polo Sweater',
      'shortName': 'Sweater',
      'brand': 'ARKET',
      'price': 79,
      'image': AppImages.quizRugbyPoloSweater,
      'styledCount': 51,
    },
    'p_trousers_zara': {
      'name': 'Wide Leg Tailored Trousers',
      'shortName': 'Trousers',
      'brand': 'ZARA',
      'price': 55,
      'image': AppImages.quizWideLegTrousers,
      'styledCount': 87,
    },
    'p_jeans_kink': {
      'name': 'Baggy Jeans',
      'shortName': 'Jeans',
      'brand': 'Kink',
      'price': 45,
      'image': AppImages.quizBaggyJeans,
      'styledCount': 205,
    },
    'p_jeans_vintage_zara': {
      'name': 'Vintage Jeans',
      'shortName': 'Jeans',
      'brand': 'ZARA',
      'price': 45,
      'image': AppImages.quizVintageJeans,
      'styledCount': 112,
    },
  };

  /// `products`: tagged items with the tag dot's position as fractions of the
  /// 390×516 post photo.
  static const posts = <String, Map<String, Object?>>{
    'post_mina': {
      'author': 'a_mina',
      'image': AppImages.postMina,
      'likes': 1248,
      'comments': 48,
      'styles': ['Casual'],
      'products': [
        {'product': 'p_trousers_zara', 'x': 0.30, 'y': 0.12},
      ],
      'similar': [
        'post_sofia',
        'post_utility_chic',
        'post_like_my_outfit',
        'post_no_words',
      ],
    },
    'post_sofia': {
      'author': 'a_sofia',
      'image': AppImages.postSofia,
      'likes': 864,
      'comments': 21,
      'styles': ['Casual'],
      'products': [
        {'product': 'p_tee_zara', 'x': 0.48, 'y': 0.30},
        {'product': 'p_jeans_vintage_zara', 'x': 0.44, 'y': 0.62},
      ],
      'similar': [
        'post_mina',
        'post_no_words',
        'post_soft_neutrals',
        'post_leo',
      ],
    },
    'post_bobur': {
      'author': 'a_bobur',
      'image': AppImages.postBobur,
      'likes': 1248,
      'comments': 48,
      'styles': ['Minimal'],
      'products': <Object?>[],
      'similar': [
        'post_soft_neutrals',
        'post_mina',
        'post_amin',
        'post_like_my_outfit',
      ],
    },
    'post_soft_neutrals': {
      'author': 'a_bob',
      'image': AppImages.postSoftNeutrals,
      'likes': 412,
      'comments': 28,
      'styles': ['Minimal'],
      'caption': 'Soft neutrals',
      'products': [
        {'product': 'p_longsleeve_uniqlo', 'x': 0.52, 'y': 0.22},
        {'product': 'p_trousers_zara', 'x': 0.44, 'y': 0.66},
      ],
      'similar': [
        'post_utility_chic',
        'post_like_my_outfit',
        'post_bobur',
        'post_amin',
      ],
    },
    'post_fozil': {
      'author': 'a_fozil',
      'image': AppImages.postFozil,
      'likes': 1248,
      'comments': 48,
      'styles': ['Street'],
      'products': [
        {'product': 'p_waffle_uniqlo', 'x': 0.44, 'y': 0.16},
        {'product': 'p_jeans_kink', 'x': 0.34, 'y': 0.70},
      ],
      'similar': [
        'post_utility_chic',
        'post_leo',
        'post_no_words',
        'post_sofia',
      ],
    },
    'post_utility_chic': {
      'author': 'a_leo',
      'image': AppImages.postUtilityChic,
      'likes': 412,
      'comments': 28,
      'styles': ['Street'],
      'caption': 'Utility chic',
      'products': [
        {'product': 'p_cardigan_cos', 'x': 0.44, 'y': 0.36},
        {'product': 'p_tee_terra_pro', 'x': 0.40, 'y': 0.08},
        {'product': 'p_trousers_zara', 'x': 0.30, 'y': 0.84},
      ],
      'similar': [
        'post_soft_neutrals',
        'post_fozil',
        'post_no_words',
        'post_like_my_outfit',
      ],
    },
    'post_no_words': {
      'author': 'a_zokir',
      'image': AppImages.postNoWords,
      'likes': 233,
      'comments': 12,
      'styles': ['Street'],
      'caption': 'No words',
      'products': [
        {'product': 'p_cardigan_cos', 'x': 0.46, 'y': 0.30},
        {'product': 'p_longsleeve_uniqlo', 'x': 0.56, 'y': 0.10},
        {'product': 'p_jeans_vintage_zara', 'x': 0.34, 'y': 0.70},
      ],
      'similar': ['post_utility_chic', 'post_sofia', 'post_fozil', 'post_leo'],
    },
    'post_like_my_outfit': {
      'author': 'a_fozil',
      'image': AppImages.postLikeMyOutfit,
      'likes': 389,
      'comments': 17,
      'styles': ['Minimal'],
      'caption': 'I like my Outfit',
      'products': [
        {'product': 'p_tee_zara', 'x': 0.50, 'y': 0.42},
        {'product': 'p_trousers_zara', 'x': 0.50, 'y': 0.78},
      ],
      'similar': [
        'post_soft_neutrals',
        'post_mina',
        'post_utility_chic',
        'post_amin',
      ],
    },
    'post_leo': {
      'author': 'a_leo',
      'image': AppImages.postLeo,
      'likes': 301,
      'comments': 9,
      'styles': ['Casual'],
      'products': [
        {'product': 'p_polo_arket', 'x': 0.50, 'y': 0.26},
      ],
      'similar': ['post_utility_chic', 'post_amin', 'post_sofia', 'post_fozil'],
    },
    'post_amin': {
      'author': 'a_amin',
      'image': AppImages.postAmin,
      'likes': 276,
      'comments': 14,
      'styles': ['Minimal'],
      'products': [
        {'product': 'p_cardigan_cos', 'x': 0.40, 'y': 0.40},
        {'product': 'p_trousers_zara', 'x': 0.42, 'y': 0.70},
      ],
      'similar': ['post_leo', 'post_bobur', 'post_soft_neutrals', 'post_mina'],
    },
  };

  /// "For you" carousel: two posts per style, with their 366×300 card crops.
  static const featured = <Map<String, String>>[
    {'post': 'post_mina', 'image': AppImages.homeHeroMina},
    {'post': 'post_fozil', 'image': AppImages.homeHeroFozil},
    {'post': 'post_bobur', 'image': AppImages.homeHeroBobur},
    {'post': 'post_sofia', 'image': AppImages.homeHeroSofia},
    {'post': 'post_utility_chic', 'image': AppImages.homeHeroUtilityChic},
    {'post': 'post_soft_neutrals', 'image': AppImages.homeHeroSoftNeutrals},
  ];

  static const peopleWearing = <Map<String, String>>[
    {
      'id': 'person_sofia',
      'name': 'Sofia',
      'photo': AppImages.homePersonSofia,
      'post': 'post_sofia',
    },
    {
      'id': 'person_leo',
      'name': 'Leo',
      'photo': AppImages.homePersonLeo,
      'post': 'post_leo',
    },
    {
      'id': 'person_amin',
      'name': 'Amin',
      'photo': AppImages.homePersonAmin,
      'post': 'post_amin',
    },
  ];

  /// Grid thumbnails as cropped in the Figma Home frame; other posts use
  /// their full photo.
  static const thumbnails = <String, ({String image, double aspectRatio})>{
    'post_utility_chic': (
      image: AppImages.homeTrendUtilityChic,
      aspectRatio: 177 / 264,
    ),
    'post_soft_neutrals': (
      image: AppImages.homeTrendSoftNeutrals,
      aspectRatio: 177 / 228,
    ),
    'post_no_words': (
      image: AppImages.homeTrendNoWords,
      aspectRatio: 177 / 238,
    ),
    'post_like_my_outfit': (
      image: AppImages.homeTrendLikeMyOutfit,
      aspectRatio: 180 / 197,
    ),
  };

  static const trending = [
    'post_utility_chic',
    'post_soft_neutrals',
    'post_no_words',
    'post_like_my_outfit',
  ];
}
