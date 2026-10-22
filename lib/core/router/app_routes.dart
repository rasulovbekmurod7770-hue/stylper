abstract final class AppRoutes {
  static const splash = '/splash';

  static const welcome = '/welcome';
  static const signIn = '/welcome/sign-in';
  static const forgotPassword = '/welcome/sign-in/forgot-password';
  static const signUp = '/welcome/sign-up';

  /// After sign-up when the email must be confirmed first.
  static const checkEmail = '$signUp/check-email';

  static String checkEmailFor(String email) =>
      Uri(path: checkEmail, queryParameters: {'email': email}).toString();

  static const profileSetup = '/onboarding/profile';
  static const styleQuiz = '/onboarding/style-quiz';

  // Main tabs (bottom bar), in the order of `MainTab`.
  static const home = '/home';
  static const search = '/search';
  static const explore = '/explore';
  static const profile = '/profile';
  static const mainTabs = [home, search, explore, profile];

  // Detail screens open inside a main tab, e.g. `/home/post/1`, so each tab
  // keeps its own back stack.
  static String post(String id, {String tab = home}) => '$tab/post/$id';

  static String product(String id, {String tab = home}) => '$tab/product/$id';

  static String user(String id, {String tab = home}) => '$tab/user/$id';

  static const wardrobe = '$profile/wardrobe';

  static String wardrobeCategory(String category) => '$wardrobe/$category';

  /// Posting: full-screen steps outside the tabs, so the tab bar is hidden.
  static const create = '/create';
  static const createTag = '$create/tag';
  static const createDetails = '$create/details';
  static const createPublish = '$create/publish';

  static bool isAuthRoute(String location) => location.startsWith(welcome);

  static bool isMainRoute(String location) =>
      mainTabs.any((tab) => location == tab || location.startsWith('$tab/'));

  static bool isOnboardingRoute(String location) =>
      location.startsWith('/onboarding');
}
