// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Stylper';

  @override
  String get welcomeTagline => 'We help people to find their style';

  @override
  String get signIn => 'Sign In';

  @override
  String get createAccount => 'Create Account';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to your account to find your style';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get orSignInWith => 'or sign in with';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String noAccountPrompt(String link) {
    return 'Don\'t have an account? $link';
  }

  @override
  String get signUpLink => 'Sign up';

  @override
  String get signUpSubtitle =>
      'Sign up to discover and customize your unique style';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Repeat your password';

  @override
  String termsAcceptance(String terms, String privacy) {
    return 'I accept the $terms & $privacy';
  }

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get orSignUpWith => 'or sign up with';

  @override
  String haveAccountPrompt(String link) {
    return 'Already have an account? $link';
  }

  @override
  String get signInLink => 'Sign in';

  @override
  String get forgotPasswordTitle => 'Forgot password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address below and we\'ll send you a link to reset your password and regain access to your account.';

  @override
  String get resetLinkHint =>
      'A secure password reset verification link will be active for 60 minutes.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String resetLinkSent(String email) {
    return 'We\'ve sent a reset link to $email. Check your inbox.';
  }

  @override
  String backToSignIn(String link) {
    return 'Back to $link';
  }

  @override
  String get backToSignInLink => 'Sign In';

  @override
  String get back => 'Back';

  @override
  String get profileSetupTitle => 'Set Up Your Profile';

  @override
  String get profileSetupSubtitle =>
      'Help us personalize your style recommendations and fits';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => '@your_username';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get ageLabel => 'Age';

  @override
  String get ageHint => 'e.g. 24';

  @override
  String get heightLabel => 'Height';

  @override
  String get heightHint => 'Height in cm';

  @override
  String get weightLabel => 'Weight';

  @override
  String get weightHint => 'Weight in kg';

  @override
  String get continueButton => 'Continue';

  @override
  String styleQuizTitle(String you) {
    return 'Dress like $you.';
  }

  @override
  String get styleQuizTitleEmphasis => 'you';

  @override
  String likeThisOutfit(String outfit) {
    return 'I like this $outfit';
  }

  @override
  String get likeThisOutfitEmphasis => 'outfit...';

  @override
  String previousItem(String item) {
    return 'Previous $item';
  }

  @override
  String nextItem(String item) {
    return 'Next $item';
  }

  @override
  String get topsCategory => 'top';

  @override
  String get bottomsCategory => 'bottom';

  @override
  String get homePlaceholderTitle => 'Your style feed is coming soon';

  @override
  String get homeGuestMessage => 'You\'re browsing as a guest.';

  @override
  String homeSignedInMessage(String name) {
    return 'Signed in as $name';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorEmailInUse => 'An account with this email already exists.';

  @override
  String get errorWeakPassword =>
      'This password is too weak. Use at least 8 characters.';

  @override
  String get errorUserDisabled => 'This account has been disabled.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get errorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorProviderUnavailable =>
      'This sign-in method isn\'t available yet.';

  @override
  String get errorUsernameTaken => 'This username is already taken.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationEmail => 'Enter a valid email address.';

  @override
  String validationPasswordLength(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String get validationPasswordsMismatch => 'Passwords don\'t match.';

  @override
  String get validationUsername =>
      'Use 3–20 characters: letters, numbers, _ or .';

  @override
  String validationNumberRange(int min, int max) {
    return 'Enter a number from $min to $max.';
  }

  @override
  String get validationGender => 'Please choose an option.';

  @override
  String get validationTerms =>
      'Please accept the Terms of Service and Privacy Policy.';
}
