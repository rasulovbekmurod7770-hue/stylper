import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/app/router/app_router.dart';
import 'package:stylper/app/session/session_cubit.dart';
import 'package:stylper/core/router/app_routes.dart';
import 'package:stylper/features/auth/domain/entities/app_user.dart';

void main() {
  const newUser = AppUser(id: '1', email: 'a@b.co');
  const profiledUser = AppUser(id: '1', email: 'a@b.co', username: 'ab');
  const onboardedUser = AppUser(
    id: '1',
    email: 'a@b.co',
    username: 'ab',
    onboardingCompleted: true,
  );

  test('unknown session waits on the splash screen', () {
    expect(
      redirectFor(const SessionUnknown(), AppRoutes.home),
      AppRoutes.splash,
    );
    expect(redirectFor(const SessionUnknown(), AppRoutes.splash), isNull);
  });

  test('signed-out users stay within the auth screens', () {
    const s = SessionUnauthenticated();
    expect(redirectFor(s, AppRoutes.splash), AppRoutes.welcome);
    expect(redirectFor(s, AppRoutes.home), AppRoutes.welcome);
    expect(redirectFor(s, AppRoutes.signIn), isNull);
    expect(redirectFor(s, AppRoutes.forgotPassword), isNull);
  });

  test('guests go to home', () {
    expect(
      redirectFor(const SessionGuest(), AppRoutes.welcome),
      AppRoutes.home,
    );
    expect(redirectFor(const SessionGuest(), AppRoutes.home), isNull);
  });

  test('new accounts are sent through onboarding', () {
    expect(
      redirectFor(const SessionAuthenticated(newUser), AppRoutes.signUp),
      AppRoutes.profileSetup,
    );
    expect(
      redirectFor(const SessionAuthenticated(profiledUser), AppRoutes.home),
      AppRoutes.styleQuiz,
    );
    expect(
      redirectFor(const SessionAuthenticated(newUser), AppRoutes.styleQuiz),
      isNull,
      reason: 'profile setup can be skipped',
    );
  });

  test('onboarded users land on home and cannot go back to auth', () {
    const s = SessionAuthenticated(onboardedUser);
    expect(redirectFor(s, AppRoutes.signIn), AppRoutes.home);
    expect(redirectFor(s, AppRoutes.profileSetup), AppRoutes.home);
    expect(redirectFor(s, AppRoutes.home), isNull);
  });
}
