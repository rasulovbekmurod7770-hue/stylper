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
  String get homeForYou => 'For you';

  @override
  String get homeFollowing => 'Following';

  @override
  String get homeForYouTitle => 'Today\'s style inspiration';

  @override
  String get homePeopleWearing => 'People wearing';

  @override
  String homeTrendingIn(String city) {
    return 'Trending in $city';
  }

  @override
  String get retry => 'Try again';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get tabHome => 'Home';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabCreate => 'New post';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabProfile => 'Profile';

  @override
  String get postOutfitDetails => 'Outfit details';

  @override
  String get postSimilar => 'Similar';

  @override
  String get postShop => 'Shop';

  @override
  String get postAddToWardrobe => 'Add to wardrobe';

  @override
  String get postSeeLooks => 'See looks';

  @override
  String get postSave => 'Save';

  @override
  String postStyledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people styled this',
      one: '1 person styled this',
    );
    return '$_temp0';
  }

  @override
  String get postLike => 'Like';

  @override
  String get postComments => 'Comments';

  @override
  String get postShare => 'Share';

  @override
  String get postMore => 'More';

  @override
  String get signInToInteract => 'Sign in to like and save posts.';

  @override
  String get signInToPost => 'Sign in to share your look.';

  @override
  String get signInToFollow => 'Sign in to follow people.';

  @override
  String get errorPostNotFound => 'This post is no longer available.';

  @override
  String get profileGuestMessage => 'You\'re browsing as a guest.';

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

  @override
  String get productTitle => 'Product';

  @override
  String get productAvailableAt => 'Available at';

  @override
  String get productSaveToWardrobe => 'Save to Wardrobe';

  @override
  String get inWardrobe => 'In wardrobe';

  @override
  String get productBuyNow => 'Buy Now';

  @override
  String get productSeeItOnPeople => 'See It On People';

  @override
  String get productSeeAllLooks => 'See all looks';

  @override
  String get productHowPeopleStyleIt => 'How people style it';

  @override
  String get productSimilarStyle => 'Similar Style';

  @override
  String get productLooksTitle => 'Looks';

  @override
  String get productNoLooks => 'No looks yet';

  @override
  String get errorProductNotFound => 'This product is no longer available.';

  @override
  String get errorOpenStore => 'Couldn\'t open the store.';

  @override
  String get postSaved => 'Saved';

  @override
  String get wardrobeAdded => 'Added to your wardrobe';

  @override
  String get wardrobeRemoved => 'Removed from your wardrobe';

  @override
  String get wardrobeTitle => 'My Wardrobe';

  @override
  String get wardrobeQuickScan => 'Quick Scan';

  @override
  String get wardrobeAddNewItem => 'Add new item';

  @override
  String get wardrobeTops => 'Tops';

  @override
  String get wardrobeBottoms => 'Bottoms';

  @override
  String get wardrobeShoes => 'Shoes';

  @override
  String get wardrobeAccessories => 'Accessories';

  @override
  String get wardrobeEmpty =>
      'Nothing here yet. Save items from posts and products.';

  @override
  String get wardrobeRemove => 'Remove';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileMyWardrobe => 'My Wardrobe';

  @override
  String get profileFollow => 'Follow';

  @override
  String get profileFollowingButton => 'Following';

  @override
  String get profileMessage => 'Message';

  @override
  String get profileStyleDna => 'Style DNA';

  @override
  String get profileMyStyle => 'My style';

  @override
  String get profileStyle => 'Style';

  @override
  String get profileTabPosts => 'Posts';

  @override
  String get profileTabSaved => 'Saved';

  @override
  String get profileTabStyleBoards => 'Style Boards';

  @override
  String get profileNoPosts => 'No posts yet';

  @override
  String get profileNoSaved => 'Posts you save appear here';

  @override
  String get profileStyleBoardsSoon => 'Style boards are coming soon';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileShare => 'Share profile';

  @override
  String get profileGuestTitle => 'Sign in to see your profile';

  @override
  String get errorProfileNotFound => 'This profile isn\'t available.';

  @override
  String productStyledBy(int count, String item) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count real customers styled this $item',
      one: '1 real customer styled this $item',
    );
    return '$_temp0';
  }

  @override
  String wardrobeItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String profilePostsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Posts',
      one: 'Post',
    );
    return '$_temp0';
  }

  @override
  String profileFollowersLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Followers',
      one: 'Follower',
    );
    return '$_temp0';
  }

  @override
  String profileFollowingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Following',
    );
    return '$_temp0';
  }

  @override
  String get filterAll => 'All';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get postingNext => 'Next';

  @override
  String get postingNewPost => 'New Post';

  @override
  String get postingTagItems => 'Tag Items';

  @override
  String get postingDetails => 'Details';

  @override
  String get postingPublish => 'Publish';

  @override
  String get postingRecentPhotos => 'Recent Photos';

  @override
  String get postingAlbums => 'Albums';

  @override
  String get postingCameraRoll => 'Camera Roll';

  @override
  String get postingTakePhoto => 'Take Photo';

  @override
  String get postingAllowAccessTitle => 'Allow access to your photos';

  @override
  String get postingAllowAccessBody =>
      'Stylper shows your photos so you can choose an outfit to post. You can still take a new photo.';

  @override
  String get postingOpenSettings => 'Open Settings';

  @override
  String get postingLimitedAccess => 'You\'ve given access to some photos.';

  @override
  String get postingManage => 'Manage';

  @override
  String get postingNoPhotos => 'No photos yet';

  @override
  String get postingTapToTag => 'Tap anywhere on the photo to tag clothes';

  @override
  String get postingSearchHint => 'Search brand or item...';

  @override
  String get postingRecentTags => 'Recent tags';

  @override
  String get postingTip =>
      'Tip: Tag specific items rather than just the brand for better visibility';

  @override
  String get postingNoResults => 'No items found';

  @override
  String get postingRemoveTag => 'Remove tag';

  @override
  String get postingWardrobeOnlyCatalog =>
      'Only items from brands can be tagged.';

  @override
  String get postingReadyToPublish => 'Ready to publish!';

  @override
  String get postingCaption => 'Caption';

  @override
  String get postingCaptionHint => 'Write a caption...';

  @override
  String get postingLocation => 'Location';

  @override
  String get postingLocationHint => 'Add a location';

  @override
  String get postingMentionedBrands => 'Mentioned brands';

  @override
  String get postingNoBrands => 'Tag items to mention their brands';

  @override
  String get postingAllowBrandFeature => 'Allow brands to feature this';

  @override
  String get postingAllowBrandFeatureHint =>
      'Brands can showcase your look in their showroom';

  @override
  String get postingPublishCta => 'Publish to Stylper';

  @override
  String get postingVisibleToEveryone =>
      'Your post will be visible to everyone';

  @override
  String get postingPublished => 'Your look is live!';

  @override
  String get postingDiscardTitle => 'Discard post?';

  @override
  String get postingDiscardBody => 'Your photo and tags will be lost.';

  @override
  String get postingDiscard => 'Discard';

  @override
  String get errorPublishInvalid =>
      'Couldn\'t publish this post. Check the photo and tags.';

  @override
  String postingItemsTagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items tagged in this outfit',
      one: '1 item tagged in this outfit',
      zero: 'No items tagged yet',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Search brands and people';

  @override
  String get searchBrandsOnStylper => 'Brands on Stylper';

  @override
  String get searchBrands => 'Brands';

  @override
  String get searchPeople => 'People';

  @override
  String get searchLocal => 'Local';

  @override
  String get searchVerified => 'Official brand';

  @override
  String get searchClear => 'Clear search';

  @override
  String searchNoResults(String query) {
    return 'No brands or people match “$query”';
  }

  @override
  String searchBrandItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }
}
