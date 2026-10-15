import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/router/app_routes.dart';
import '../../features/auth/presentation/cubits/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubits/sign_in_cubit.dart';
import '../../features/auth/presentation/cubits/sign_up_cubit.dart';
import '../../features/auth/presentation/cubits/social_sign_in_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/home/presentation/cubits/home_feed_cubit.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/cubits/profile_setup_cubit.dart';
import '../../features/onboarding/presentation/cubits/style_quiz_cubit.dart';
import '../../features/onboarding/presentation/pages/profile_setup_page.dart';
import '../../features/onboarding/presentation/pages/style_quiz_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../di/injection.dart';
import '../session/session_cubit.dart';
import '../shell/app_shell.dart';
import '../shell/tab_placeholder_page.dart';
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(
        currentTab: MainTab.values[shell.currentIndex],
        onTabSelected: (tab) => shell.goBranch(
          tab.index,
          // Tapping the current tab again returns to its first screen.
          initialLocation: tab.index == shell.currentIndex,
        ),
        child: shell,
      ),
      // One branch per MainTab, in the same order.
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => BlocProvider(
                create: (_) => sl<HomeFeedCubit>()..load(),
                child: const HomePage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) =>
                  TabPlaceholderPage(title: context.l10n.tabSearch),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) =>
                  TabPlaceholderPage(title: context.l10n.tabExplore),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => BlocProvider.value(
                value: session,
                child: const ProfilePage(),
              ),
            ),
          ],
        ),
      ],
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
    SessionGuest() => AppRoutes.isMainRoute(location) ? null : AppRoutes.home,
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
