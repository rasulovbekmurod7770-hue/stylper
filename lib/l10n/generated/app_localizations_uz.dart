// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'Stylper';

  @override
  String get welcomeTagline =>
      'Biz odamlarga oʻz uslubini topishga yordam beramiz';

  @override
  String get signIn => 'Kirish';

  @override
  String get createAccount => 'Hisob yaratish';

  @override
  String get skipForNow => 'Hozircha oʻtkazib yuborish';

  @override
  String get signInTitle => 'Xush kelibsiz';

  @override
  String get signInSubtitle => 'Uslubingizni topish uchun hisobingizga kiring';

  @override
  String get emailLabel => 'Elektron pochta';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get passwordLabel => 'Parol';

  @override
  String get passwordHint => 'Parolingizni kiriting';

  @override
  String get showPassword => 'Parolni koʻrsatish';

  @override
  String get hidePassword => 'Parolni yashirish';

  @override
  String get forgotPasswordLink => 'Parolni unutdingizmi?';

  @override
  String get orSignInWith => 'yoki quyidagi orqali kiring';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String noAccountPrompt(String link) {
    return 'Hisobingiz yoʻqmi? $link';
  }

  @override
  String get signUpLink => 'Roʻyxatdan oʻting';

  @override
  String get signUpSubtitle =>
      'Oʻzingizga xos uslubni kashf etish va sozlash uchun roʻyxatdan oʻting';

  @override
  String get confirmPasswordLabel => 'Parolni tasdiqlang';

  @override
  String get confirmPasswordHint => 'Parolni qayta kiriting';

  @override
  String termsAcceptance(String terms, String privacy) {
    return '$terms va ${privacy}ni qabul qilaman';
  }

  @override
  String get termsOfService => 'Foydalanish shartlari';

  @override
  String get privacyPolicy => 'Maxfiylik siyosati';

  @override
  String get orSignUpWith => 'yoki quyidagi orqali roʻyxatdan oʻting';

  @override
  String haveAccountPrompt(String link) {
    return 'Hisobingiz bormi? $link';
  }

  @override
  String get signInLink => 'Kirish';

  @override
  String get forgotPasswordTitle => 'Parolni unutdingizmi?';

  @override
  String get forgotPasswordSubtitle =>
      'Elektron pochta manzilingizni kiriting, biz parolni tiklash va hisobingizga qayta kirish uchun havola yuboramiz.';

  @override
  String get resetLinkHint =>
      'Parolni tiklash uchun xavfsiz havola 60 daqiqa davomida amal qiladi.';

  @override
  String get sendResetLink => 'Havolani yuborish';

  @override
  String resetLinkSent(String email) {
    return 'Tiklash havolasi $email manziliga yuborildi. Pochtangizni tekshiring.';
  }

  @override
  String backToSignIn(String link) {
    return '$link qaytish';
  }

  @override
  String get backToSignInLink => 'Kirishga';

  @override
  String get checkEmailTitle => 'Pochtangizni tekshiring';

  @override
  String checkEmailSubtitle(String email) {
    return 'Tasdiqlash havolasini $email manziliga yubordik. Hisobingizni faollashtirish uchun uni oching, soʻng tizimga kiring.';
  }

  @override
  String get checkEmailHint => 'Xat topilmadimi? «Spam» jildini tekshiring.';

  @override
  String get goToSignIn => 'Kirishga oʻtish';

  @override
  String wrongEmailPrompt(String link) {
    return 'Manzil notoʻgʻrimi? $link';
  }

  @override
  String get signUpAgainLink => 'Qaytadan roʻyxatdan oʻting';

  @override
  String get back => 'Orqaga';

  @override
  String get profileSetupTitle => 'Profilingizni sozlang';

  @override
  String get profileSetupSubtitle =>
      'Uslub tavsiyalari va oʻlchamlarni sizga moslashtirishimizga yordam bering';

  @override
  String get usernameLabel => 'Foydalanuvchi nomi';

  @override
  String get usernameHint => '@your_username';

  @override
  String get genderLabel => 'Jins';

  @override
  String get genderMale => 'Erkak';

  @override
  String get genderFemale => 'Ayol';

  @override
  String get ageLabel => 'Yosh';

  @override
  String get ageHint => 'masalan, 24';

  @override
  String get heightLabel => 'Boʻy';

  @override
  String get heightHint => 'Boʻy (sm)';

  @override
  String get weightLabel => 'Vazn';

  @override
  String get weightHint => 'Vazn (kg)';

  @override
  String get continueButton => 'Davom etish';

  @override
  String styleQuizTitle(String you) {
    return '${you}dek kiyining.';
  }

  @override
  String get styleQuizTitleEmphasis => 'Oʻzingiz';

  @override
  String likeThisOutfit(String outfit) {
    return 'Menga bu $outfit yoqdi';
  }

  @override
  String get likeThisOutfitEmphasis => 'obraz...';

  @override
  String previousItem(String item) {
    return 'Oldingi: $item';
  }

  @override
  String nextItem(String item) {
    return 'Keyingi: $item';
  }

  @override
  String get topsCategory => 'ustki kiyim';

  @override
  String get bottomsCategory => 'pastki kiyim';

  @override
  String get homeForYou => 'Siz uchun';

  @override
  String get homeFollowing => 'Obunalar';

  @override
  String get homeForYouTitle => 'Bugungi uslub ilhomi';

  @override
  String get homePeopleWearing => 'Odamlar nima kiyyapti';

  @override
  String homeTrendingIn(String city) {
    return 'Trendda: $city';
  }

  @override
  String get retry => 'Qayta urinish';

  @override
  String get comingSoon => 'Tez kunda';

  @override
  String get tabHome => 'Bosh sahifa';

  @override
  String get tabSearch => 'Qidiruv';

  @override
  String get tabCreate => 'Yangi post';

  @override
  String get tabExplore => 'Kashf qilish';

  @override
  String get tabProfile => 'Profil';

  @override
  String get postOutfitDetails => 'Obraz tafsilotlari';

  @override
  String get postSimilar => 'Oʻxshash';

  @override
  String get postShop => 'Xarid';

  @override
  String get postAddToWardrobe => 'Garderobga';

  @override
  String get postSeeLooks => 'Obrazlar';

  @override
  String get postSave => 'Saqlash';

  @override
  String postStyledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kishi buni kiygan',
    );
    return '$_temp0';
  }

  @override
  String get postLike => 'Yoqdi';

  @override
  String get postComments => 'Izohlar';

  @override
  String get postShare => 'Ulashish';

  @override
  String get postMore => 'Yana';

  @override
  String get signInToInteract => 'Postlarni yoqtirish va saqlash uchun kiring.';

  @override
  String get signInToPost => 'Obrazingizni ulashish uchun kiring.';

  @override
  String get signInToFollow => 'Odamlarga obuna boʻlish uchun kiring.';

  @override
  String get errorPostNotFound => 'Bu post endi mavjud emas.';

  @override
  String get profileGuestMessage => 'Siz mehmon sifatida koʻrib chiqyapsiz.';

  @override
  String get signOut => 'Chiqish';

  @override
  String get errorInvalidCredentials => 'Elektron pochta yoki parol notoʻgʻri.';

  @override
  String get errorEmailNotConfirmed =>
      'Avval pochtangizni tasdiqlang: biz yuborgan havolani oching.';

  @override
  String get errorEmailInUse =>
      'Bu elektron pochta bilan hisob allaqachon mavjud.';

  @override
  String get errorWeakPassword =>
      'Parol juda oddiy. Kamida 8 ta belgidan foydalaning.';

  @override
  String get errorUserDisabled => 'Bu hisob bloklangan.';

  @override
  String get errorTooManyRequests =>
      'Urinishlar juda koʻp. Keyinroq qayta urinib koʻring.';

  @override
  String get errorNetwork =>
      'Internet aloqasi yoʻq. Tarmoqni tekshirib, qayta urinib koʻring.';

  @override
  String get errorProviderUnavailable =>
      'Bu kirish usuli hozircha mavjud emas.';

  @override
  String get errorUsernameTaken => 'Bu foydalanuvchi nomi band.';

  @override
  String get errorUnknown => 'Nimadir xato ketdi. Qayta urinib koʻring.';

  @override
  String get validationRequired => 'Bu maydon toʻldirilishi shart.';

  @override
  String get validationEmail => 'Toʻgʻri elektron pochta manzilini kiriting.';

  @override
  String validationPasswordLength(int min) {
    return 'Kamida $min ta belgi kiriting.';
  }

  @override
  String get validationPasswordsMismatch => 'Parollar mos kelmadi.';

  @override
  String get validationUsername =>
      '3–20 ta belgi: lotin harflari, raqamlar, _ yoki .';

  @override
  String validationNumberRange(int min, int max) {
    return '$min dan $max gacha son kiriting.';
  }

  @override
  String get validationGender => 'Variantni tanlang.';

  @override
  String get validationTerms =>
      'Foydalanish shartlari va Maxfiylik siyosatini qabul qiling.';

  @override
  String get productTitle => 'Mahsulot';

  @override
  String get productAvailableAt => 'Sotuvda:';

  @override
  String get productSaveToWardrobe => 'Garderobga';

  @override
  String get inWardrobe => 'Garderobda';

  @override
  String get productBuyNow => 'Sotib olish';

  @override
  String get productSeeItOnPeople => 'Odamlarda koʻring';

  @override
  String get productSeeAllLooks => 'Barcha obrazlar';

  @override
  String get productHowPeopleStyleIt => 'Qanday kiyishadi';

  @override
  String get productSimilarStyle => 'Oʻxshash uslub';

  @override
  String get productLooksTitle => 'Obrazlar';

  @override
  String get productNoLooks => 'Hozircha obrazlar yoʻq';

  @override
  String get errorProductNotFound => 'Bu mahsulot endi mavjud emas.';

  @override
  String get errorOpenStore => 'Doʻkonni ochib boʻlmadi.';

  @override
  String get postSaved => 'Saqlangan';

  @override
  String get wardrobeAdded => 'Garderobingizga qoʻshildi';

  @override
  String get wardrobeRemoved => 'Garderobingizdan olib tashlandi';

  @override
  String get wardrobeTitle => 'Mening garderobim';

  @override
  String get wardrobeQuickScan => 'Skanerlash';

  @override
  String get wardrobeAddNewItem => 'Yangi narsa qoʻshish';

  @override
  String get addItemTitle => 'Kiyim maʼlumotlari';

  @override
  String get addItemSubtitle =>
      'Garderobingizda uni faqat siz koʻrasiz. Postda belgilasangiz, hamma bu qanday kiyim ekanini biladi.';

  @override
  String get addItemName => 'Nomi';

  @override
  String get addItemNameHint => 'Masalan, kulrang kardigan';

  @override
  String get addItemBrand => 'Brend';

  @override
  String get addItemBrandHint => 'Brend yoki sotib olgan doʻkoningiz';

  @override
  String get addItemCategory => 'Turkum';

  @override
  String get addItemPrice => 'Narxi';

  @override
  String get addItemOptional => 'Ixtiyoriy';

  @override
  String get addItemPriceHint => 'Masalan, 350 000';

  @override
  String get addItemPriceInvalid => '0 dan katta narx kiriting';

  @override
  String get addItemSubmit => 'Qoʻshish';

  @override
  String priceInSom(String amount) {
    return '$amount soʻm';
  }

  @override
  String get currencySom => 'soʻm';

  @override
  String postAddedBy(String name) {
    return 'Qoʻshgan: $name';
  }

  @override
  String get wardrobeOuterwear => 'Ustki kiyim';

  @override
  String get wardrobeTops => 'Ustki kiyim';

  @override
  String get wardrobeBottoms => 'Pastki kiyim';

  @override
  String get wardrobeShoes => 'Poyabzal';

  @override
  String get wardrobeAccessories => 'Aksessuarlar';

  @override
  String get wardrobeEmpty =>
      'Bu yerda hozircha hech narsa yoʻq. Post va mahsulotlardan narsalarni saqlang.';

  @override
  String get wardrobeRemove => 'Olib tashlash';

  @override
  String get profileEdit => 'Tahrirlash';

  @override
  String get profileMyWardrobe => 'Garderobim';

  @override
  String get profileFollow => 'Obuna boʻlish';

  @override
  String get profileFollowingButton => 'Obunadasiz';

  @override
  String get profileMessage => 'Xabar';

  @override
  String get profileStyleDna => 'Uslub DNKsi';

  @override
  String get styleMinimal => 'Minimalizm';

  @override
  String get styleCasual => 'Kundalik';

  @override
  String get styleStreetwear => 'Koʻcha uslubi';

  @override
  String get styleStreetwearShort => 'Koʻcha';

  @override
  String get styleNeutral => 'Neytral';

  @override
  String get styleOversized => 'Oversayz';

  @override
  String get styleSmartCasual => 'Yarim rasmiy';

  @override
  String get profileMyStyle => 'Mening uslubim';

  @override
  String get profileStyle => 'Uslub';

  @override
  String get profileTabPosts => 'Postlar';

  @override
  String get profileTabSaved => 'Saqlanganlar';

  @override
  String get profileTabStyleBoards => 'Uslub doskalari';

  @override
  String get profileNoPosts => 'Hozircha postlar yoʻq';

  @override
  String get profileNoSaved => 'Saqlangan postlar shu yerda chiqadi';

  @override
  String get profileStyleBoardsSoon => 'Uslub doskalari tez orada';

  @override
  String get profileSettings => 'Sozlamalar';

  @override
  String get editProfileTitle => 'Profilni tahrirlash';

  @override
  String get profileNameLabel => 'Ism';

  @override
  String get profileNameHint => 'Ismingiz';

  @override
  String get profileBioLabel => 'Haqingizda';

  @override
  String get profileBioHint => 'Uslubingiz haqida bir-ikki soʻz';

  @override
  String get profileSave => 'Saqlash';

  @override
  String get settingsPrivacy => 'Maxfiylik';

  @override
  String get settingsPrivateAccount => 'Yopiq hisob';

  @override
  String get settingsPrivateAccountHint =>
      'Postlaringizni faqat obunachilaringiz koʻradi.';

  @override
  String get settingsBrandFeatures => 'Brendlar postlarimni koʻrsata oladi';

  @override
  String get settingsBrandFeaturesHint =>
      'Yangi postlar uchun, faqat ularda belgilangan brendlarga.';

  @override
  String get settingsShowLikeCounts => 'Layklar sonini koʻrsatish';

  @override
  String get settingsNotifications => 'Bildirishnomalar';

  @override
  String get settingsNotifyBrandActivity => 'Brendlar faolligi';

  @override
  String get settingsNotifyBrandActivityHint =>
      'Brend postingizni koʻrsatganda yoki sizga sovgʻa yuborganda.';

  @override
  String get settingsNotifyDrops => 'Yangi kolleksiyalar';

  @override
  String get settingsNotifyDropsHint =>
      'Obuna boʻlgan brendlaringizdan yangi buyumlar.';

  @override
  String get settingsSaveFailed =>
      'Oʻzgarishni saqlab boʻlmadi. Qayta urinib koʻring.';

  @override
  String get profileShare => 'Profilni ulashish';

  @override
  String get profileGuestTitle => 'Profilingizni koʻrish uchun kiring';

  @override
  String get errorProfileNotFound => 'Bu profil mavjud emas.';

  @override
  String productStyledBy(int count, String item) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count xaridor buni kiygan: $item',
    );
    return '$_temp0';
  }

  @override
  String wardrobeItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta narsa',
      zero: 'Narsa yoʻq',
    );
    return '$_temp0';
  }

  @override
  String profilePostsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'post',
    );
    return '$_temp0';
  }

  @override
  String profileFollowersLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'obunachi',
    );
    return '$_temp0';
  }

  @override
  String profileFollowingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'obuna',
    );
    return '$_temp0';
  }

  @override
  String get filterAll => 'Hammasi';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get close => 'Yopish';

  @override
  String get postingNext => 'Keyingi';

  @override
  String get postingNewPost => 'Yangi post';

  @override
  String get postingTagItems => 'Kiyimlarni belgilang';

  @override
  String postingTagLimit(int count) {
    return 'Bitta suratda $count tagacha buyumni belgilash mumkin.';
  }

  @override
  String get postingDetails => 'Tafsilotlar';

  @override
  String get postingPublish => 'Eʼlon qilish';

  @override
  String get postingRecentPhotos => 'Soʻnggi rasmlar';

  @override
  String get postingAlbums => 'Albomlar';

  @override
  String get postingCameraRoll => 'Galereya';

  @override
  String get postingTakePhoto => 'Suratga olish';

  @override
  String get postingAllowAccessTitle => 'Rasmlaringizga ruxsat bering';

  @override
  String get postingAllowAccessBody =>
      'Stylper post uchun obraz tanlashingiz uchun rasmlaringizni koʻrsatadi. Yangi surat ham olishingiz mumkin.';

  @override
  String get postingOpenSettings => 'Sozlamalarni ochish';

  @override
  String get postingLimitedAccess => 'Siz baʼzi rasmlarga ruxsat bergansiz.';

  @override
  String get postingManage => 'Boshqarish';

  @override
  String get postingNoPhotos => 'Hozircha rasmlar yoʻq';

  @override
  String get postingTapToTag =>
      'Kiyimni belgilash uchun rasmning istalgan joyiga bosing';

  @override
  String get postingSearchHint => 'Brend yoki kiyimni qidiring...';

  @override
  String get postingRecentTags => 'Soʻnggi belgilar';

  @override
  String get postingTip =>
      'Maslahat: faqat brendni emas, aniq kiyimni belgilang — post koʻproq koʻrinadi';

  @override
  String get postingNoResults => 'Hech narsa topilmadi';

  @override
  String get postingRemoveTag => 'Belgini olib tashlash';

  @override
  String get postingReadyToPublish => 'Eʼlon qilishga tayyor!';

  @override
  String get postingCaption => 'Izoh';

  @override
  String get postingCaptionHint => 'Izoh yozing...';

  @override
  String get postingLocation => 'Joylashuv';

  @override
  String get postingLocationHint => 'Joylashuvni qoʻshing';

  @override
  String get postingMentionedBrands => 'Tilga olingan brendlar';

  @override
  String get postingNoBrands =>
      'Brendlarni tilga olish uchun kiyimlarni belgilang';

  @override
  String get postingAllowBrandFeature =>
      'Brendlarga koʻrsatishga ruxsat berish';

  @override
  String get postingAllowBrandFeatureHint =>
      'Brendlar obrazingizni oʻz shourumida koʻrsatishi mumkin';

  @override
  String get postingPublishCta => 'Stylperda eʼlon qilish';

  @override
  String get postingVisibleToEveryone => 'Postingizni hamma koʻradi';

  @override
  String get postingPublished => 'Obrazingiz eʼlon qilindi!';

  @override
  String get postingDiscardTitle => 'Post bekor qilinsinmi?';

  @override
  String get postingDiscardBody => 'Rasm va belgilar saqlanmaydi.';

  @override
  String get postingDiscard => 'Bekor qilish';

  @override
  String get errorPublishInvalid =>
      'Postni eʼlon qilib boʻlmadi. Rasm va belgilarni tekshiring.';

  @override
  String postingItemsTagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Obrazda $count ta kiyim belgilangan',
      zero: 'Hozircha belgilar yoʻq',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Brendlar va odamlarni qidiring';

  @override
  String get searchBrandsOnStylper => 'Stylperdagi brendlar';

  @override
  String get searchBrands => 'Brendlar';

  @override
  String get searchPeople => 'Odamlar';

  @override
  String get searchLocal => 'Mahalliy';

  @override
  String get searchVerified => 'Rasmiy brend';

  @override
  String get searchClear => 'Qidiruvni tozalash';

  @override
  String searchNoResults(String query) {
    return '“$query” boʻyicha brend yoki odam topilmadi';
  }

  @override
  String searchBrandItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta mahsulot',
    );
    return '$_temp0';
  }
}
