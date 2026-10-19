import '../constants/app_assets.dart';

/// Seed content served by `FakeBackend`: the people, products and posts of
/// the Figma sample screens. Product photos reuse the style-quiz cut-outs,
/// as the Figma post screens do. Delete with the fake backend.
abstract final class FakeContent {
  static const city = 'Tashkent';

  /// Home's "For you" style chips.
  static const styles = ['Casual', 'Minimal', 'Street'];

  /// Every style a post can be tagged with; Home's chips are a subset.
  static const allStyles = [
    'Minimal',
    'Casual',
    'Street',
    'Neutral',
    'Oversized',
    'Smart Casual',
  ];

  /// Brands (and other businesses) that sell the catalog products. `handle`
  /// is the brand's username; `local` marks Uzbek brands (shown first);
  /// `verified` an official showroom run by the brand. No logos yet (the app
  /// shows a monogram).
  static const brands = <String, Map<String, Object?>>{
    'b_cos': {'name': 'COS', 'handle': 'cos', 'local': false},
    'b_zara': {'name': 'ZARA', 'handle': 'zara', 'local': false},
    'b_uniqlo': {'name': 'UNIQLO', 'handle': 'uniqlo', 'local': false},
    'b_arket': {'name': 'ARKET', 'handle': 'arket', 'local': false},
    'b_kink': {'name': 'Kink', 'handle': 'kink', 'local': true},
    'b_terra_pro': {'name': 'Terra Pro', 'handle': 'terra_pro', 'local': true},
  };

  /// Public profiles. `a_john` and `a_katty` are also sign-in accounts (see
  /// `FakeBackend._seed`); their handle is the account's username. `avatar`
  /// may be null (the app shows initials). `followers` / `following` are
  /// counts from before this app session.
  static const profiles = <String, Map<String, Object?>>{
    'a_john': {
      'name': 'John. B',
      'handle': 'john',
      'avatar': null,
      'bio': 'Minimalist fashion lover | NYC',
      'styles': ['Minimal', 'Casual', 'Streetwear', 'Neutral', 'Oversized'],
      'followers': 1200,
      'following': 338,
    },
    'a_katty': {
      'name': 'Katty Miller',
      'handle': 'katty_miller',
      'avatar': null,
      'bio': '',
      'styles': ['Casual'],
      'followers': 87,
      'following': 112,
    },
    'a_mina': {
      'name': 'Mina Cho',
      'handle': 'mina',
      'avatar': AppImages.homeAvatarMina,
      'bio': 'Sneakers first, outfit second',
      'styles': ['Casual', 'Street'],
      'followers': 5300,
      'following': 210,
    },
    'a_fozil': {
      'name': 'Fozil Can Fly',
      'handle': 'fozil',
      'avatar': AppImages.homeAvatarFozil,
      'bio': 'Tashkent streets',
      'styles': ['Street', 'Layered'],
      'followers': 2400,
      'following': 180,
    },
    'a_bobur': {
      'name': 'Bob',
      'handle': 'Bobur',
      'avatar': AppImages.homeAvatarBobur,
      'bio': 'Less, but better',
      'styles': ['Minimal'],
      'followers': 980,
      'following': 75,
    },
    'a_bob': {
      'name': 'Bob',
      'handle': 'bob',
      'avatar': AppImages.homeAvatarBob,
      'bio': '',
      'styles': ['Minimal', 'Neutral'],
      'followers': 640,
      'following': 90,
    },
    'a_sofia': {
      'name': 'Sofia',
      'handle': 'sofia',
      'avatar': AppImages.homePersonSofia,
      'bio': 'Denim every day',
      'styles': ['Casual'],
      'followers': 3100,
      'following': 402,
    },
    'a_leo': {
      'name': 'Leo',
      'handle': 'leo',
      'avatar': AppImages.homePersonLeo,
      'bio': 'Knitwear collector',
      'styles': ['Street', 'Casual'],
      'followers': 1900,
      'following': 260,
    },
    'a_amin': {
      'name': 'Amin',
      'handle': 'amin',
      'avatar': AppImages.homePersonAmin,
      'bio': '',
      'styles': ['Minimal'],
      'followers': 720,
      'following': 133,
    },
    'a_zokir': {
      'name': 'Zokir',
      'handle': 'zokir',
      'avatar': AppImages.homeAvatarZokir,
      'bio': '',
      'styles': ['Street'],
      'followers': 410,
      'following': 98,
    },
  };

  /// Brand stores, only where the official site is certain.
  static const stores = <String, Map<String, String>>{
    'COS': {'name': 'cos.com', 'url': 'https://www.cos.com'},
    'ZARA': {'name': 'zara.com', 'url': 'https://www.zara.com'},
    'UNIQLO': {'name': 'uniqlo.com', 'url': 'https://www.uniqlo.com'},
    'ARKET': {'name': 'arket.com', 'url': 'https://www.arket.com'},
  };

  static const products = <String, Map<String, Object?>>{
    'p_cardigan_cos': {
      'category': 'tops',
      'name': 'Cotton Cardigan',
      'shortName': 'Cardigan',
      'brand': 'COS',
      'brandId': 'b_cos',
      'price': 89,
      'image': AppImages.quizCottonCardigan,
      'styledCount': 124,
    },
    'p_tee_terra_pro': {
      'category': 'tops',
      'name': 'White T-Shirt',
      'shortName': 'T-Shirt',
      'brand': 'Terra Pro',
      'brandId': 'b_terra_pro',
      'price': 12,
      'image': AppImages.quizWhiteTShirt,
      'styledCount': 312,
    },
    'p_tee_zara': {
      'category': 'tops',
      'name': 'Oversized White T-Shirt',
      'shortName': 'T-Shirt',
      'brand': 'ZARA',
      'brandId': 'b_zara',
      'price': 19,
      'image': AppImages.quizOversizedWhiteTShirt,
      'styledCount': 143,
    },
    'p_longsleeve_uniqlo': {
      'category': 'tops',
      'name': 'Striped Long Sleeve',
      'shortName': 'Long sleeve',
      'brand': 'UNIQLO',
      'brandId': 'b_uniqlo',
      'price': 25,
      'image': AppImages.quizStripedLongSleeve,
      'styledCount': 64,
    },
    'p_waffle_uniqlo': {
      'category': 'tops',
      'name': 'Waffle Long-Sleeve',
      'shortName': 'Sweater',
      'brand': 'UNIQLO',
      'brandId': 'b_uniqlo',
      'price': 29,
      'image': AppImages.quizWaffleLongSleeve,
      'styledCount': 38,
    },
    'p_polo_arket': {
      'category': 'tops',
      'name': 'Rugby Polo Sweater',
      'shortName': 'Sweater',
      'brand': 'ARKET',
      'brandId': 'b_arket',
      'price': 79,
      'image': AppImages.quizRugbyPoloSweater,
      'styledCount': 51,
    },
    'p_trousers_zara': {
      'category': 'bottoms',
      'name': 'Wide Leg Tailored Trousers',
      'shortName': 'Trousers',
      'brand': 'ZARA',
      'brandId': 'b_zara',
      'price': 55,
      'image': AppImages.quizWideLegTrousers,
      'styledCount': 87,
    },
    'p_jeans_kink': {
      'category': 'bottoms',
      'name': 'Baggy Jeans',
      'shortName': 'Jeans',
      'brand': 'Kink',
      'brandId': 'b_kink',
      'price': 45,
      'image': AppImages.quizBaggyJeans,
      'styledCount': 205,
    },
    'p_jeans_vintage_zara': {
      'category': 'bottoms',
      'name': 'Vintage Jeans',
      'shortName': 'Jeans',
      'brand': 'ZARA',
      'brandId': 'b_zara',
      'price': 45,
      'image': AppImages.quizVintageJeans,
      'styledCount': 112,
    },
    // Shoes and accessories from local brands, so every category has items.
    'p_sneakers_terra_pro': {
      'category': 'shoes',
      'name': 'Suede Sneakers',
      'shortName': 'Sneakers',
      'brand': 'Terra Pro',
      'brandId': 'b_terra_pro',
      'price': 65,
      'image': AppImages.wardrobeSneakers,
      'styledCount': 41,
    },
    'p_watch_kink': {
      'category': 'accessories',
      'name': 'Digital Watch',
      'shortName': 'Watch',
      'brand': 'Kink',
      'brandId': 'b_kink',
      'price': 30,
      'image': AppImages.wardrobeWatches,
      'styledCount': 19,
    },
    'p_sunglasses_kink': {
      'category': 'accessories',
      'name': 'Sport Sunglasses',
      'shortName': 'Sunglasses',
      'brand': 'Kink',
      'brandId': 'b_kink',
      'price': 22,
      'image': AppImages.wardrobeSunglasses,
      'styledCount': 27,
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
    'post_john_coat': {
      'author': 'a_john',
      'image': AppImages.postJohnCoat,
      'likes': 642,
      'comments': 31,
      'styles': ['Minimal'],
      'caption': 'Rainy layers',
      'products': [
        {'product': 'p_trousers_zara', 'x': 0.50, 'y': 0.72},
      ],
      'similar': [
        'post_bobur',
        'post_john_suit',
        'post_amin',
        'post_soft_neutrals',
      ],
    },
    'post_john_suit': {
      'author': 'a_john',
      'image': AppImages.postJohnSuit,
      'likes': 518,
      'comments': 22,
      'styles': ['Minimal'],
      'caption': 'All black',
      'products': [
        {'product': 'p_trousers_zara', 'x': 0.48, 'y': 0.70},
      ],
      'similar': [
        'post_john_coat',
        'post_bobur',
        'post_soft_neutrals',
        'post_amin',
      ],
    },
    'post_john_knit': {
      'author': 'a_john',
      'image': AppImages.postJohnKnit,
      'likes': 377,
      'comments': 15,
      'styles': ['Casual'],
      'caption': 'Soft knit',
      'products': <Object?>[],
      'similar': [
        'post_sofia',
        'post_mina',
        'post_john_coat',
        'post_like_my_outfit',
      ],
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

  /// Seed wardrobes: catalog product ids and the owner's own items (`w_…`).
  static const wardrobes = <String, List<String>>{
    'a_john': [
      'p_tee_terra_pro',
      'p_cardigan_cos',
      'p_longsleeve_uniqlo',
      'p_jeans_kink',
      'p_trousers_zara',
      'w_sneakers',
      'w_sunglasses',
      'w_watches',
    ],
  };

  /// Wardrobe items that aren't catalog products (added by the user).
  static const ownItems = <String, Map<String, String>>{
    'w_sneakers': {
      'category': 'shoes',
      'name': 'Suede Sneakers',
      'image': AppImages.wardrobeSneakers,
    },
    'w_sunglasses': {
      'category': 'accessories',
      'name': 'Sport Sunglasses',
      'image': AppImages.wardrobeSunglasses,
    },
    'w_watches': {
      'category': 'accessories',
      'name': 'Digital Watch',
      'image': AppImages.wardrobeWatches,
    },
  };

  /// Wardrobe categories, in display order.
  static const wardrobeCategories = ['tops', 'bottoms', 'shoes', 'accessories'];

  static const saved = <String, List<String>>{
    'a_john': [
      'post_utility_chic',
      'post_soft_neutrals',
      'post_no_words',
      'post_sofia',
    ],
  };

  static const follows = <String, List<String>>{
    'a_john': ['a_leo', 'a_sofia'],
  };
}
