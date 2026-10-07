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
  String get homePlaceholderTitle =>
      'Uslublar lentangiz tez orada paydo boʻladi';

  @override
  String get homeGuestMessage => 'Siz mehmon sifatida koʻrib chiqyapsiz.';

  @override
  String homeSignedInMessage(String name) {
    return '$name sifatida kirdingiz';
  }

  @override
  String get signOut => 'Chiqish';

  @override
  String get errorInvalidCredentials => 'Elektron pochta yoki parol notoʻgʻri.';

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
}
