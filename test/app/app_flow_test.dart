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
import 'package:stylper/features/product/presentation/pages/product_detail_page.dart';
import 'package:stylper/features/profile/presentation/pages/profile_page.dart';
import 'package:stylper/features/wardrobe/presentation/pages/wardrobe_page.dart';

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
    // The hero, and the compact header that appears on scroll.
    expect(find.text('@new_user'), findsWidgets);
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
    expect(find.text('John. B'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
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
    expect(
      find.bySemanticsLabel('Home'),
      findsOneWidget,
      reason: 'the tab bar shows on posts too',
    );

    await tester.tap(find.bySemanticsLabel('Like'));
    await tester.pumpAndSettle();
    expect(likedHearts(), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(PostDetailPage), findsNothing);
    expect(likedHearts(), findsOneWidget, reason: 'home agrees');
    expect(find.bySemanticsLabel('Home'), findsOneWidget);
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

  testWidgets('a product opens from a post, with the tab bar; back returns', (
    tester,
  ) async {
    await launch(tester);
    await tapText(tester, 'Skip for now');
    await tapText(tester, 'Sofia');
    expect(find.byType(PostDetailPage), findsOneWidget);

    await tester.tap(find.text('Shop').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailPage), findsOneWidget);
    expect(find.text('Oversized White T-Shirt'), findsOneWidget);
    expect(find.bySemanticsLabel('Home'), findsOneWidget, reason: 'tab bar');

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(PostDetailPage), findsOneWidget);
    expect(find.bySemanticsLabel('Home'), findsOneWidget);
  });

  testWidgets('an item saved from a post shows up in My Wardrobe', (
    tester,
  ) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Profile');
    await tapText(tester, 'My Wardrobe');
    expect(find.byType(WardrobePage), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget, reason: 'Tops');

    await openTab(tester, 'Home');
    await tapText(tester, 'Sofia');
    // Scroll the card's pill out from under the floating tab bar.
    final addToWardrobe = find.text('Add to wardrobe').first.hitTestable();
    await tester.scrollUntilVisible(
      addToWardrobe,
      100,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.tap(addToWardrobe);
    await tester.pumpAndSettle();
    expect(find.text('Added to your wardrobe'), findsOneWidget);
    expect(find.text('In wardrobe'), findsOneWidget);

    // Straight from the post to the Profile tab, where My Wardrobe stayed
    // open; it has caught up.
    await openTab(tester, 'Profile');
    expect(find.byType(WardrobePage), findsOneWidget);
    expect(find.text('4 items'), findsOneWidget, reason: 'Tops');
  });

  testWidgets('following someone updates their follower count', (tester) async {
    await signInAsDemo(tester);
    await tapText(tester, 'Amin');
    await tester.tap(find.bySemanticsLabel('Back').hitTestable().first);
    await tester.pumpAndSettle();
    await tapText(tester, 'Amin');
    // The post's author row opens Amin's profile.
    await tester.tap(find.text('Amin').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('720 Followers', findRichText: true), findsOneWidget);

    await tapText(tester, 'Follow');
    expect(find.text('721 Followers', findRichText: true), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
  });

  testWidgets('your Saved tab lists the posts you saved', (tester) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Profile');

    // The tabs sit below the profile's header.
    await tester.dragUntilVisible(
      find.text('Saved'),
      find.byType(CustomScrollView).hitTestable().first,
      const Offset(0, -300),
    );
    await tapText(tester, 'Saved');
    expect(find.text('@leo'), findsWidgets, reason: 'Utility chic, by Leo');
    expect(find.text('@amin'), findsNothing);

    // Save Amin's post from Home; the open Saved tab catches up.
    await openTab(tester, 'Home');
    await tapText(tester, 'Amin');
    await tester.tap(find.bySemanticsLabel('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    await openTab(tester, 'Profile');
    expect(find.text('@amin'), findsWidgets);
  });

  testWidgets('each tab keeps its own stack; tapping it again goes back up', (
    tester,
  ) async {
    await launch(tester);
    await tapText(tester, 'Skip for now');
    await tapText(tester, 'Sofia');
    expect(find.byType(PostDetailPage), findsOneWidget);

    await openTab(tester, 'Profile');
    expect(find.byType(PostDetailPage), findsNothing);

    await openTab(tester, 'Home');
    expect(find.byType(PostDetailPage), findsOneWidget, reason: 'kept');

    await openTab(tester, 'Home');
    expect(find.byType(PostDetailPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });
}
