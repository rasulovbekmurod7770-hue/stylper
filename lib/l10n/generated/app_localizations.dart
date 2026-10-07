import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Stylper'**
  String get appName;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'We help people to find their style'**
  String get welcomeTagline;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account to find your style'**
  String get signInSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'or sign in with'**
  String get orSignInWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// Footer on the sign-in screen. {link} is replaced by the tappable signUpLink text.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? {link}'**
  String noAccountPrompt(String link);

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpLink;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to discover and customize your unique style'**
  String get signUpSubtitle;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get confirmPasswordHint;

  /// Terms switch label. {terms} and {privacy} are replaced by the tappable termsOfService and privacyPolicy texts.
  ///
  /// In en, this message translates to:
  /// **'I accept the {terms} & {privacy}'**
  String termsAcceptance(String terms, String privacy);

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'or sign up with'**
  String get orSignUpWith;

  /// Footer on the sign-up screen. {link} is replaced by the tappable signInLink text.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? {link}'**
  String haveAccountPrompt(String link);

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address below and we\'ll send you a link to reset your password and regain access to your account.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @resetLinkHint.
  ///
  /// In en, this message translates to:
  /// **'A secure password reset verification link will be active for 60 minutes.'**
  String get resetLinkHint;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a reset link to {email}. Check your inbox.'**
  String resetLinkSent(String email);

  /// Footer on the forgot-password screen. {link} is replaced by the tappable backToSignInLink text.
  ///
  /// In en, this message translates to:
  /// **'Back to {link}'**
  String backToSignIn(String link);

  /// No description provided for @backToSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get backToSignInLink;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Up Your Profile'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your style recommendations and fits'**
  String get profileSetupSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'@your_username'**
  String get usernameHint;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @ageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 24'**
  String get ageHint;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @heightHint.
  ///
  /// In en, this message translates to:
  /// **'Height in cm'**
  String get heightHint;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @weightHint.
  ///
  /// In en, this message translates to:
  /// **'Weight in kg'**
  String get weightHint;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Style quiz heading. {you} is replaced by styleQuizTitleEmphasis, drawn in an italic serif.
  ///
  /// In en, this message translates to:
  /// **'Dress like {you}.'**
  String styleQuizTitle(String you);

  /// No description provided for @styleQuizTitleEmphasis.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get styleQuizTitleEmphasis;

  /// Style quiz button. {outfit} is replaced by likeThisOutfitEmphasis, drawn in semibold.
  ///
  /// In en, this message translates to:
  /// **'I like this {outfit}'**
  String likeThisOutfit(String outfit);

  /// No description provided for @likeThisOutfitEmphasis.
  ///
  /// In en, this message translates to:
  /// **'outfit...'**
  String get likeThisOutfitEmphasis;

  /// No description provided for @previousItem.
  ///
  /// In en, this message translates to:
  /// **'Previous {item}'**
  String previousItem(String item);

  /// No description provided for @nextItem.
  ///
  /// In en, this message translates to:
  /// **'Next {item}'**
  String nextItem(String item);

  /// No description provided for @topsCategory.
  ///
  /// In en, this message translates to:
  /// **'top'**
  String get topsCategory;

  /// No description provided for @bottomsCategory.
  ///
  /// In en, this message translates to:
  /// **'bottom'**
  String get bottomsCategory;

  /// No description provided for @homePlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your style feed is coming soon'**
  String get homePlaceholderTitle;

  /// No description provided for @homeGuestMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re browsing as a guest.'**
  String get homeGuestMessage;

  /// No description provided for @homeSignedInMessage.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String homeSignedInMessage(String name);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'This password is too weak. Use at least 8 characters.'**
  String get errorWeakPassword;

  /// No description provided for @errorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get errorUserDisabled;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get errorTooManyRequests;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get errorNetwork;

  /// No description provided for @errorProviderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method isn\'t available yet.'**
  String get errorProviderUnavailable;

  /// No description provided for @errorUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken.'**
  String get errorUsernameTaken;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEmail;

  /// No description provided for @validationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String validationPasswordLength(int min);

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get validationPasswordsMismatch;

  /// No description provided for @validationUsername.
  ///
  /// In en, this message translates to:
  /// **'Use 3–20 characters: letters, numbers, _ or .'**
  String get validationUsername;

  /// No description provided for @validationNumberRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from {min} to {max}.'**
  String validationNumberRange(int min, int max);

  /// No description provided for @validationGender.
  ///
  /// In en, this message translates to:
  /// **'Please choose an option.'**
  String get validationGender;

  /// No description provided for @validationTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms of Service and Privacy Policy.'**
  String get validationTerms;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
