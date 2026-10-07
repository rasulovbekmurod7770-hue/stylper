abstract final class AppRoutes {
  static const splash = '/splash';

  static const welcome = '/welcome';
  static const signIn = '/welcome/sign-in';
  static const forgotPassword = '/welcome/sign-in/forgot-password';
  static const signUp = '/welcome/sign-up';

  static const profileSetup = '/onboarding/profile';
  static const styleQuiz = '/onboarding/style-quiz';

  static const home = '/home';

  static bool isAuthRoute(String location) => location.startsWith(welcome);

  static bool isOnboardingRoute(String location) =>
      location.startsWith('/onboarding');
}
