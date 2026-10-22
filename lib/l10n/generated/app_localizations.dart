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

  /// No description provided for @checkEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmailTitle;

  /// No description provided for @checkEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a confirmation link to {email}. Open it to activate your account, then sign in.'**
  String checkEmailSubtitle(String email);

  /// No description provided for @checkEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it? Check your spam folder.'**
  String get checkEmailHint;

  /// No description provided for @goToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Go to Sign In'**
  String get goToSignIn;

  /// Footer on the check-your-email screen. {link} is replaced by the tappable signUpAgainLink text.
  ///
  /// In en, this message translates to:
  /// **'Wrong email? {link}'**
  String wrongEmailPrompt(String link);

  /// No description provided for @signUpAgainLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up again'**
  String get signUpAgainLink;

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

  /// No description provided for @homeForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get homeForYou;

  /// No description provided for @homeFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get homeFollowing;

  /// No description provided for @homeForYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s style inspiration'**
  String get homeForYouTitle;

  /// No description provided for @homePeopleWearing.
  ///
  /// In en, this message translates to:
  /// **'People wearing'**
  String get homePeopleWearing;

  /// No description provided for @homeTrendingIn.
  ///
  /// In en, this message translates to:
  /// **'Trending in {city}'**
  String homeTrendingIn(String city);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @tabCreate.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get tabCreate;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @postOutfitDetails.
  ///
  /// In en, this message translates to:
  /// **'Outfit details'**
  String get postOutfitDetails;

  /// No description provided for @postSimilar.
  ///
  /// In en, this message translates to:
  /// **'Similar'**
  String get postSimilar;

  /// No description provided for @postShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get postShop;

  /// No description provided for @postAddToWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Add to wardrobe'**
  String get postAddToWardrobe;

  /// No description provided for @postSeeLooks.
  ///
  /// In en, this message translates to:
  /// **'See looks'**
  String get postSeeLooks;

  /// No description provided for @postSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get postSave;

  /// No description provided for @postStyledCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person styled this} other{{count} people styled this}}'**
  String postStyledCount(int count);

  /// No description provided for @postLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get postLike;

  /// No description provided for @postComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get postComments;

  /// No description provided for @postShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get postShare;

  /// No description provided for @postMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get postMore;

  /// No description provided for @signInToInteract.
  ///
  /// In en, this message translates to:
  /// **'Sign in to like and save posts.'**
  String get signInToInteract;

  /// Shown to guests who tap New post.
  ///
  /// In en, this message translates to:
  /// **'Sign in to share your look.'**
  String get signInToPost;

  /// No description provided for @signInToFollow.
  ///
  /// In en, this message translates to:
  /// **'Sign in to follow people.'**
  String get signInToFollow;

  /// No description provided for @errorPostNotFound.
  ///
  /// In en, this message translates to:
  /// **'This post is no longer available.'**
  String get errorPostNotFound;

  /// No description provided for @profileGuestMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re browsing as a guest.'**
  String get profileGuestMessage;

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

  /// No description provided for @errorEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email first: open the link we sent you.'**
  String get errorEmailNotConfirmed;

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

  /// No description provided for @productTitle.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productTitle;

  /// No description provided for @productAvailableAt.
  ///
  /// In en, this message translates to:
  /// **'Available at'**
  String get productAvailableAt;

  /// No description provided for @productSaveToWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Save to Wardrobe'**
  String get productSaveToWardrobe;

  /// No description provided for @inWardrobe.
  ///
  /// In en, this message translates to:
  /// **'In wardrobe'**
  String get inWardrobe;

  /// No description provided for @productBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get productBuyNow;

  /// No description provided for @productSeeItOnPeople.
  ///
  /// In en, this message translates to:
  /// **'See It On People'**
  String get productSeeItOnPeople;

  /// No description provided for @productSeeAllLooks.
  ///
  /// In en, this message translates to:
  /// **'See all looks'**
  String get productSeeAllLooks;

  /// No description provided for @productHowPeopleStyleIt.
  ///
  /// In en, this message translates to:
  /// **'How people style it'**
  String get productHowPeopleStyleIt;

  /// No description provided for @productSimilarStyle.
  ///
  /// In en, this message translates to:
  /// **'Similar Style'**
  String get productSimilarStyle;

  /// No description provided for @productLooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Looks'**
  String get productLooksTitle;

  /// No description provided for @productNoLooks.
  ///
  /// In en, this message translates to:
  /// **'No looks yet'**
  String get productNoLooks;

  /// No description provided for @errorProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'This product is no longer available.'**
  String get errorProductNotFound;

  /// No description provided for @errorOpenStore.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the store.'**
  String get errorOpenStore;

  /// No description provided for @postSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get postSaved;

  /// No description provided for @wardrobeAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your wardrobe'**
  String get wardrobeAdded;

  /// No description provided for @wardrobeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from your wardrobe'**
  String get wardrobeRemoved;

  /// No description provided for @wardrobeTitle.
  ///
  /// In en, this message translates to:
  /// **'My Wardrobe'**
  String get wardrobeTitle;

  /// No description provided for @wardrobeQuickScan.
  ///
  /// In en, this message translates to:
  /// **'Quick Scan'**
  String get wardrobeQuickScan;

  /// No description provided for @wardrobeAddNewItem.
  ///
  /// In en, this message translates to:
  /// **'Add new item'**
  String get wardrobeAddNewItem;

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Item details'**
  String get addItemTitle;

  /// No description provided for @addItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only you see it in your wardrobe. Tag it on a post and everyone sees what it is.'**
  String get addItemSubtitle;

  /// No description provided for @addItemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get addItemName;

  /// No description provided for @addItemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Grey cardigan'**
  String get addItemNameHint;

  /// No description provided for @addItemBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand name'**
  String get addItemBrand;

  /// No description provided for @addItemBrandHint.
  ///
  /// In en, this message translates to:
  /// **'The brand, or the shop you got it from'**
  String get addItemBrandHint;

  /// No description provided for @addItemCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addItemCategory;

  /// No description provided for @addItemPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get addItemPrice;

  /// No description provided for @addItemOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get addItemOptional;

  /// No description provided for @addItemPriceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 350,000'**
  String get addItemPriceHint;

  /// No description provided for @addItemPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a price above 0'**
  String get addItemPriceInvalid;

  /// No description provided for @addItemSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItemSubmit;

  /// A price in Uzbek soʻm; amount is already grouped, e.g. 1,130,000.
  ///
  /// In en, this message translates to:
  /// **'{amount} UZS'**
  String priceInSom(String amount);

  /// No description provided for @currencySom.
  ///
  /// In en, this message translates to:
  /// **'UZS'**
  String get currencySom;

  /// No description provided for @postAddedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String postAddedBy(String name);

  /// No description provided for @wardrobeTops.
  ///
  /// In en, this message translates to:
  /// **'Tops'**
  String get wardrobeTops;

  /// No description provided for @wardrobeBottoms.
  ///
  /// In en, this message translates to:
  /// **'Bottoms'**
  String get wardrobeBottoms;

  /// No description provided for @wardrobeShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get wardrobeShoes;

  /// No description provided for @wardrobeAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get wardrobeAccessories;

  /// No description provided for @wardrobeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Save items from posts and products.'**
  String get wardrobeEmpty;

  /// No description provided for @wardrobeRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get wardrobeRemove;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileMyWardrobe.
  ///
  /// In en, this message translates to:
  /// **'My Wardrobe'**
  String get profileMyWardrobe;

  /// No description provided for @profileFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get profileFollow;

  /// No description provided for @profileFollowingButton.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profileFollowingButton;

  /// No description provided for @profileMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get profileMessage;

  /// No description provided for @profileStyleDna.
  ///
  /// In en, this message translates to:
  /// **'Style DNA'**
  String get profileStyleDna;

  /// No description provided for @profileMyStyle.
  ///
  /// In en, this message translates to:
  /// **'My style'**
  String get profileMyStyle;

  /// No description provided for @profileStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get profileStyle;

  /// No description provided for @profileTabPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get profileTabPosts;

  /// No description provided for @profileTabSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profileTabSaved;

  /// No description provided for @profileTabStyleBoards.
  ///
  /// In en, this message translates to:
  /// **'Style Boards'**
  String get profileTabStyleBoards;

  /// No description provided for @profileNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get profileNoPosts;

  /// No description provided for @profileNoSaved.
  ///
  /// In en, this message translates to:
  /// **'Posts you save appear here'**
  String get profileNoSaved;

  /// No description provided for @profileStyleBoardsSoon.
  ///
  /// In en, this message translates to:
  /// **'Style boards are coming soon'**
  String get profileStyleBoardsSoon;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileShare.
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get profileShare;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your profile'**
  String get profileGuestTitle;

  /// No description provided for @errorProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'This profile isn\'t available.'**
  String get errorProfileNotFound;

  /// No description provided for @productStyledBy.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 real customer styled this {item}} other{{count} real customers styled this {item}}}'**
  String productStyledBy(int count, String item);

  /// No description provided for @wardrobeItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String wardrobeItemCount(int count);

  /// No description provided for @profilePostsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Post} other{Posts}}'**
  String profilePostsLabel(int count);

  /// No description provided for @profileFollowersLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Follower} other{Followers}}'**
  String profileFollowersLabel(int count);

  /// No description provided for @profileFollowingLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Following}}'**
  String profileFollowingLabel(int count);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @postingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get postingNext;

  /// No description provided for @postingNewPost.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get postingNewPost;

  /// No description provided for @postingTagItems.
  ///
  /// In en, this message translates to:
  /// **'Tag Items'**
  String get postingTagItems;

  /// No description provided for @postingDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get postingDetails;

  /// No description provided for @postingPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get postingPublish;

  /// No description provided for @postingRecentPhotos.
  ///
  /// In en, this message translates to:
  /// **'Recent Photos'**
  String get postingRecentPhotos;

  /// No description provided for @postingAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get postingAlbums;

  /// No description provided for @postingCameraRoll.
  ///
  /// In en, this message translates to:
  /// **'Camera Roll'**
  String get postingCameraRoll;

  /// No description provided for @postingTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get postingTakePhoto;

  /// No description provided for @postingAllowAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow access to your photos'**
  String get postingAllowAccessTitle;

  /// No description provided for @postingAllowAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Stylper shows your photos so you can choose an outfit to post. You can still take a new photo.'**
  String get postingAllowAccessBody;

  /// No description provided for @postingOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get postingOpenSettings;

  /// No description provided for @postingLimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'You\'ve given access to some photos.'**
  String get postingLimitedAccess;

  /// No description provided for @postingManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get postingManage;

  /// No description provided for @postingNoPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get postingNoPhotos;

  /// No description provided for @postingTapToTag.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere on the photo to tag clothes'**
  String get postingTapToTag;

  /// No description provided for @postingSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search brand or item...'**
  String get postingSearchHint;

  /// No description provided for @postingRecentTags.
  ///
  /// In en, this message translates to:
  /// **'Recent tags'**
  String get postingRecentTags;

  /// No description provided for @postingTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Tag specific items rather than just the brand for better visibility'**
  String get postingTip;

  /// No description provided for @postingNoResults.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get postingNoResults;

  /// No description provided for @postingRemoveTag.
  ///
  /// In en, this message translates to:
  /// **'Remove tag'**
  String get postingRemoveTag;

  /// No description provided for @postingReadyToPublish.
  ///
  /// In en, this message translates to:
  /// **'Ready to publish!'**
  String get postingReadyToPublish;

  /// No description provided for @postingCaption.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get postingCaption;

  /// No description provided for @postingCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write a caption...'**
  String get postingCaptionHint;

  /// No description provided for @postingLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get postingLocation;

  /// No description provided for @postingLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Add a location'**
  String get postingLocationHint;

  /// No description provided for @postingMentionedBrands.
  ///
  /// In en, this message translates to:
  /// **'Mentioned brands'**
  String get postingMentionedBrands;

  /// No description provided for @postingNoBrands.
  ///
  /// In en, this message translates to:
  /// **'Tag items to mention their brands'**
  String get postingNoBrands;

  /// No description provided for @postingAllowBrandFeature.
  ///
  /// In en, this message translates to:
  /// **'Allow brands to feature this'**
  String get postingAllowBrandFeature;

  /// No description provided for @postingAllowBrandFeatureHint.
  ///
  /// In en, this message translates to:
  /// **'Brands can showcase your look in their showroom'**
  String get postingAllowBrandFeatureHint;

  /// No description provided for @postingPublishCta.
  ///
  /// In en, this message translates to:
  /// **'Publish to Stylper'**
  String get postingPublishCta;

  /// No description provided for @postingVisibleToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Your post will be visible to everyone'**
  String get postingVisibleToEveryone;

  /// No description provided for @postingPublished.
  ///
  /// In en, this message translates to:
  /// **'Your look is live!'**
  String get postingPublished;

  /// No description provided for @postingDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard post?'**
  String get postingDiscardTitle;

  /// No description provided for @postingDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your photo and tags will be lost.'**
  String get postingDiscardBody;

  /// No description provided for @postingDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get postingDiscard;

  /// No description provided for @errorPublishInvalid.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t publish this post. Check the photo and tags.'**
  String get errorPublishInvalid;

  /// No description provided for @postingItemsTagged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items tagged yet} =1{1 item tagged in this outfit} other{{count} items tagged in this outfit}}'**
  String postingItemsTagged(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search brands and people'**
  String get searchHint;

  /// No description provided for @searchBrandsOnStylper.
  ///
  /// In en, this message translates to:
  /// **'Brands on Stylper'**
  String get searchBrandsOnStylper;

  /// No description provided for @searchBrands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get searchBrands;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get searchPeople;

  /// No description provided for @searchLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get searchLocal;

  /// No description provided for @searchVerified.
  ///
  /// In en, this message translates to:
  /// **'Official brand'**
  String get searchVerified;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClear;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No brands or people match “{query}”'**
  String searchNoResults(String query);

  /// How many catalog items a brand sells.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String searchBrandItems(int count);
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
