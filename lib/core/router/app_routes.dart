abstract final class AppRoutes {
  static const splash = '/splash';

  static const welcome = '/welcome';
  static const signIn = '/welcome/sign-in';
  static const forgotPassword = '/welcome/sign-in/forgot-password';
  static const signUp = '/welcome/sign-up';

  static const profileSetup = '/onboarding/profile';
  static const styleQuiz = '/onboarding/style-quiz';

  // Main tabs (bottom bar), in the order of `MainTab`.
  static const home = '/home';
  static const search = '/search';
  static const explore = '/explore';
  static const profile = '/profile';
  static const mainTabs = [home, search, explore, profile];

  /// An outfit post, shown over the tab bar.
  static String post(String id) => '$home/post/$id';

  static bool isAuthRoute(String location) => location.startsWith(welcome);

  static bool isMainRoute(String location) =>
      mainTabs.any((tab) => location == tab || location.startsWith('$tab/'));

  static bool isOnboardingRoute(String location) =>
      location.startsWith('/onboarding');
}
