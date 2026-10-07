import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/app/app.dart';
import 'package:stylper/app/di/injection.dart';
import 'package:stylper/app/session/session_cubit.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/widgets/app_switch.dart';
import 'package:stylper/features/auth/presentation/pages/sign_in_page.dart';
import 'package:stylper/features/auth/presentation/pages/sign_up_page.dart';
import 'package:stylper/features/auth/presentation/pages/welcome_page.dart';
import 'package:stylper/features/home/presentation/pages/home_page.dart';
import 'package:stylper/features/onboarding/presentation/pages/profile_setup_page.dart';
import 'package:stylper/features/onboarding/presentation/pages/style_quiz_page.dart';

import '../helpers/screen_harness.dart';

/// Drives the real app — DI, router, session and the fake backend — through
/// the auth and onboarding flows.
void main() {
  late SessionCubit session;

  setUp(() async {
    await sl.reset();
    configureDependencies(backend: FakeBackend(latency: Duration.zero));
    session = sl<SessionCubit>();
  });

  Future<void> launch(WidgetTester tester) async {
    await loadAppFonts();
    tester.view
      ..physicalSize = figmaFrameSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await session.start();
    await tester.pumpWidget(StylperApp(session: session));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, int index, String text) async {
    await tester.enterText(find.byType(TextField).at(index), text);
    await tester.pump();
  }

  testWidgets('new user: sign up → profile → style quiz → home', (
    tester,
  ) async {
    await launch(tester);
    expect(find.byType(WelcomePage), findsOneWidget);

    await tapText(tester, 'Create Account');
    expect(find.byType(SignUpPage), findsOneWidget);

    await type(tester, 0, 'new.user@stylper.ai');
    await type(tester, 1, 'stylper123');
    await type(tester, 2, 'stylper123');
    await tester.ensureVisible(find.byType(AppSwitch));
    await tester.tap(find.byType(AppSwitch));
    await tester.pumpAndSettle();
    await tapText(tester, 'Create Account');

    expect(find.byType(ProfileSetupPage), findsOneWidget);
    await type(tester, 0, '@new_user');
    await tapText(tester, 'Male');
    await type(tester, 1, '24');
    await tapText(tester, 'Continue');

    expect(find.byType(StyleQuizPage), findsOneWidget);
    await tester.tap(find.textContaining('I like this', findRichText: true));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Signed in as new_user'), findsOneWidget);
  });

  testWidgets('existing user signs in straight to home, then signs out', (
    tester,
  ) async {
    await launch(tester);
    await tapText(tester, 'Sign In');
    expect(find.byType(SignInPage), findsOneWidget);

    await type(tester, 0, FakeBackend.demoEmail);
    await type(tester, 1, FakeBackend.demoPassword);
    await tapText(tester, 'Sign In');

    expect(find.byType(HomePage), findsOneWidget);
    await tapText(tester, 'Sign out');
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('wrong password shows an error and stays on sign in', (
    tester,
  ) async {
    await launch(tester);
    await tapText(tester, 'Sign In');
    await type(tester, 0, FakeBackend.demoEmail);
    await type(tester, 1, 'not-the-password');
    await tapText(tester, 'Sign In');

    expect(find.byType(SignInPage), findsOneWidget);
    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('skip for now browses as a guest', (tester) async {
    await launch(tester);
    await tapText(tester, 'Skip for now');

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text("You're browsing as a guest."), findsOneWidget);
  });
}
