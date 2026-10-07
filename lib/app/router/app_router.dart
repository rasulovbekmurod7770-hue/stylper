import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../features/auth/presentation/cubits/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubits/sign_in_cubit.dart';
import '../../features/auth/presentation/cubits/sign_up_cubit.dart';
import '../../features/auth/presentation/cubits/social_sign_in_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/cubits/profile_setup_cubit.dart';
import '../../features/onboarding/presentation/cubits/style_quiz_cubit.dart';
import '../../features/onboarding/presentation/pages/profile_setup_page.dart';
import '../../features/onboarding/presentation/pages/style_quiz_page.dart';
import '../di/injection.dart';
import '../session/session_cubit.dart';
import 'splash_page.dart';

GoRouter createRouter(SessionCubit session) => GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: _StreamListenable(session.stream),
  redirect: (context, state) =>
      redirectFor(session.state, state.matchedLocation),
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) =>
          WelcomePage(onContinueAsGuest: session.continueAsGuest),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<SignInCubit>()),
              BlocProvider(create: (_) => sl<SocialSignInCubit>()),
            ],
            child: const SignInPage(),
          ),
          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) => BlocProvider(
                create: (_) => sl<ForgotPasswordCubit>(),
                child: const ForgotPasswordPage(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'sign-up',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<SignUpCubit>()),
              BlocProvider(create: (_) => sl<SocialSignInCubit>()),
            ],
            child: const SignUpPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.profileSetup,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<ProfileSetupCubit>(),
        child: const ProfileSetupPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.styleQuiz,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<StyleQuizCubit>()..load(),
        child: const StyleQuizPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) =>
          BlocProvider.value(value: session, child: const HomePage()),
    ),
  ],
);

/// Where a user in [session] may be when trying to open [location]; null
/// keeps them there.
@visibleForTesting
String? redirectFor(SessionState session, String location) {
  bool at(String route) => location == route;

  return switch (session) {
    SessionUnknown() => at(AppRoutes.splash) ? null : AppRoutes.splash,
    SessionUnauthenticated() =>
      AppRoutes.isAuthRoute(location) ? null : AppRoutes.welcome,
    SessionGuest() => at(AppRoutes.home) ? null : AppRoutes.home,
    SessionAuthenticated(:final user) when !user.onboardingCompleted =>
      AppRoutes.isOnboardingRoute(location)
          ? null
          : user.hasProfile
          ? AppRoutes.styleQuiz
          : AppRoutes.profileSetup,
    SessionAuthenticated() =>
      at(AppRoutes.splash) ||
              AppRoutes.isAuthRoute(location) ||
              AppRoutes.isOnboardingRoute(location)
          ? AppRoutes.home
          : null,
  };
}

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
