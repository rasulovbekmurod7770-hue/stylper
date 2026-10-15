import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/app/app.dart';
import 'package:stylper/app/di/injection.dart';
import 'package:stylper/app/session/session_cubit.dart';
import 'package:stylper/core/constants/app_assets.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/widgets/app_switch.dart';
import 'package:stylper/features/auth/presentation/pages/sign_in_page.dart';
import 'package:stylper/features/auth/presentation/pages/sign_up_page.dart';
import 'package:stylper/features/auth/presentation/pages/welcome_page.dart';
import 'package:stylper/features/home/presentation/pages/home_page.dart';
import 'package:stylper/features/onboarding/presentation/pages/profile_setup_page.dart';
import 'package:stylper/features/onboarding/presentation/pages/style_quiz_page.dart';
import 'package:stylper/features/post/presentation/pages/post_detail_page.dart';

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

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(find.bySemanticsLabel(label));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, int index, String text) async {
    await tester.enterText(find.byType(TextField).at(index), text);
    await tester.pump();
  }

  Future<void> signInAsDemo(WidgetTester tester) async {
    await launch(tester);
    await tapText(tester, 'Sign In');
    await type(tester, 0, FakeBackend.demoEmail);
    await type(tester, 1, FakeBackend.demoPassword);
    await tapText(tester, 'Sign In');
    expect(find.byType(HomePage), findsOneWidget);
  }

  /// Filled hearts on screen, i.e. posts shown as liked.
  Finder likedHearts() => find.byWidgetPredicate(
    (widget) =>
        widget is SvgPicture &&
        widget.bytesLoader is SvgAssetLoader &&
        (widget.bytesLoader as SvgAssetLoader).assetName ==
            AppIcons.heartFilled,
  );

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
    await openTab(tester, 'Profile');
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
    await openTab(tester, 'Profile');
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
    expect(find.text('Mina Cho'), findsOneWidget, reason: 'feed is public');
    await openTab(tester, 'Profile');
    expect(find.text("You're browsing as a guest."), findsOneWidget);
  });

  testWidgets('a post opened from home and liked shows liked on home too', (
    tester,
  ) async {
    await signInAsDemo(tester);

    // The "For you" card opens Mina Cho's post.
    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();
    expect(find.byType(PostDetailPage), findsOneWidget);
    expect(find.text('ZARA · Trousers'), findsOneWidget);
    expect(likedHearts(), findsNothing);

    await tester.tap(find.bySemanticsLabel('Like'));
    await tester.pumpAndSettle();
    expect(likedHearts(), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(PostDetailPage), findsNothing);
    expect(likedHearts(), findsOneWidget, reason: 'home agrees');
  });

  testWidgets('style chips switch the For you posts without opening one', (
    tester,
  ) async {
    await launch(tester);
    await tapText(tester, 'Skip for now');
    expect(find.text('Mina Cho'), findsOneWidget);

    await tapText(tester, 'Minimal');

    expect(find.byType(PostDetailPage), findsNothing);
    expect(find.text('@Bobur'), findsOneWidget);
  });

  testWidgets('guests are asked to sign in before liking', (tester) async {
    await launch(tester);
    await tapText(tester, 'Skip for now');

    await tester.tap(find.bySemanticsLabel('Like').first);
    await tester.pump();

    expect(find.text('Sign in to like and save posts.'), findsOneWidget);
    expect(likedHearts(), findsNothing);
  });
}
