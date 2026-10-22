import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/app/app.dart';
import 'package:stylper/app/di/injection.dart';
import 'package:stylper/app/session/session_cubit.dart';
import 'package:stylper/app/shell/app_tab_bar.dart';
import 'package:stylper/core/constants/app_assets.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/widgets/app_switch.dart';
import 'package:stylper/features/auth/presentation/pages/check_email_page.dart';
import 'package:stylper/features/auth/presentation/pages/sign_in_page.dart';
import 'package:stylper/features/auth/presentation/pages/sign_up_page.dart';
import 'package:stylper/features/auth/presentation/pages/welcome_page.dart';
import 'package:stylper/features/home/presentation/pages/home_page.dart';
import 'package:stylper/features/onboarding/presentation/pages/profile_setup_page.dart';
import 'package:stylper/features/onboarding/presentation/pages/style_quiz_page.dart';
import 'package:stylper/features/post/presentation/pages/post_detail_page.dart';
import 'package:stylper/features/posting/presentation/pages/media_selection_page.dart';
import 'package:stylper/features/posting/presentation/pages/posting_details_page.dart';
import 'package:stylper/features/posting/presentation/pages/publish_page.dart';
import 'package:stylper/features/posting/presentation/pages/tag_items_page.dart';
import 'package:stylper/features/wardrobe/presentation/widgets/add_item_card.dart';
import 'package:stylper/features/wardrobe/presentation/widgets/add_item_sheet.dart';
import 'package:stylper/features/posting/presentation/widgets/posting_widgets.dart';
import 'package:stylper/features/product/presentation/pages/product_detail_page.dart';
import 'package:stylper/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:stylper/features/profile/presentation/pages/profile_page.dart';
import 'package:stylper/features/search/presentation/cubits/search_cubit.dart';
import 'package:stylper/features/search/presentation/pages/search_page.dart';
import 'package:stylper/features/search/presentation/widgets/search_rows.dart';
import 'package:stylper/features/wardrobe/presentation/pages/wardrobe_page.dart';

import '../helpers/fake_media.dart';
import '../helpers/screen_harness.dart';

/// The photo posted in the posting flows; none of John's posts use it.
const _newPhoto = 'assets/images/posts/amin.webp';

/// Drives the real app — DI, router, session and the fake backend — through
/// the auth and onboarding flows.
void main() {
  late SessionCubit session;

  setUp(() async {
    await sl.reset();
    configureDependencies(
      backend: FakeBackend(latency: Duration.zero),
      media: FakeMediaRepository(library: [_newPhoto]),
      thumbnails: const AssetGalleryThumbnails(),
    );
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

  /// "Add New Item" → TIMEOFLESS's grey cardigan, a top, 350 000 soʻm.
  Future<void> addGreyCardigan(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(AddItemCard).last);
    await tester.tap(find.byType(AddItemCard).last);
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(BottomSheet).last,
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'Grey Cardigan');
    await tester.enterText(fields.at(1), 'TIMEOFLESS');
    await tester.enterText(fields.at(2), '350000');
    await tapText(tester, 'Tops');
    await tester.ensureVisible(find.byKey(addItemSubmitKey));
    await tester.tap(find.byKey(addItemSubmitKey));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
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
    // Style DNA of the outfit liked: White T-Shirt + Baggy Jeans.
    for (final style in ['Minimal', 'Neutral', 'Streetwear', 'Oversized']) {
      expect(find.text(style), findsOneWidget, reason: style);
    }
  });

  testWidgets('Edit Profile: a brand\'s handle is taken, then the profile '
      'shows the new name, username and bio', (tester) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Profile');
    await tapText(tester, 'Edit Profile');
    expect(find.byType(EditProfilePage), findsOneWidget);
    expect(find.text('john'), findsOneWidget, reason: 'starts from @john');

    await type(tester, 1, 'cos');
    await tapText(tester, 'Save');
    expect(find.text('This username is already taken.'), findsOneWidget);

    await type(tester, 0, 'John Brown');
    await type(tester, 1, '@john_b');
    await type(tester, 2, 'Layers, always.');
    await tapText(tester, 'Save');

    expect(find.byType(EditProfilePage), findsNothing);
    expect(find.text('John Brown'), findsWidgets);
    expect(find.text('@john_b'), findsWidgets);
    expect(find.text('Layers, always.'), findsOneWidget);
  });

  testWidgets('Settings: a toggle stays as set when the sheet reopens', (
    tester,
  ) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Profile');
    Future<void> openSettings() async {
      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpAndSettle();
    }

    bool privateAccount() => tester
        .widget<AppSwitch>(
          find.descendant(
            of: find.ancestor(
              of: find.text('Private account'),
              matching: find.byType(InkWell),
            ),
            matching: find.byType(AppSwitch),
          ),
        )
        .value;

    await openSettings();
    expect(privateAccount(), isFalse);
    await tapText(tester, 'Private account');
    expect(privateAccount(), isTrue);

    await tester.tapAt(const Offset(20, 20)); // closes the sheet
    await tester.pumpAndSettle();
    await openSettings();
    expect(privateAccount(), isTrue);
  });

  testWidgets('with email confirmation on: sign up → check your email → '
      'sign in once the link is opened', (tester) async {
    final backend = FakeBackend(
      latency: Duration.zero,
      requireEmailConfirmation: true,
    );
    await sl.reset();
    configureDependencies(
      backend: backend,
      media: FakeMediaRepository(library: [_newPhoto]),
      thumbnails: const AssetGalleryThumbnails(),
    );
    session = sl<SessionCubit>();
    await launch(tester);

    await tapText(tester, 'Create Account');
    await type(tester, 0, 'new.user@stylper.ai');
    await type(tester, 1, 'stylper123');
    await type(tester, 2, 'stylper123');
    await tester.ensureVisible(find.byType(AppSwitch));
    await tester.tap(find.byType(AppSwitch));
    await tester.pumpAndSettle();
    await tapText(tester, 'Create Account');

    expect(find.byType(CheckEmailPage), findsOneWidget);
    expect(find.textContaining('new.user@stylper.ai'), findsOneWidget);
    await tapText(tester, 'Go to Sign In');

    expect(find.byType(SignInPage), findsOneWidget);
    await type(tester, 0, 'new.user@stylper.ai');
    await type(tester, 1, 'stylper123');
    await tapText(tester, 'Sign In');
    expect(find.byType(SignInPage), findsOneWidget);
    expect(
      find.text('Confirm your email first: open the link we sent you.'),
      findsOneWidget,
    );

    await tester.runAsync(() => backend.confirmEmail('new.user@stylper.ai'));
    await tapText(tester, 'Sign In');
    expect(find.byType(ProfileSetupPage), findsOneWidget);
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

  /// Images showing [asset] on screen.
  Finder imagesOf(String asset) => find.byWidgetPredicate(
    (widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == asset,
  );

  testWidgets('posting: pick, tag from the catalog, describe, publish → '
      'your profile shows it', (tester) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Profile');
    expect(imagesOf(_newPhoto), findsNothing);

    await tester.tap(find.bySemanticsLabel('New post'));
    await tester.pumpAndSettle();
    // Posting covers the tab bar, on every step.
    expect(find.byType(MediaSelectionPage), findsOneWidget);
    expect(find.byType(AppTabBar), findsNothing);
    await tapText(tester, 'Next');

    // Tap the photo where the jeans are, then find them in the catalog.
    expect(find.byType(TagItemsPage), findsOneWidget);
    expect(find.byType(AppTabBar), findsNothing);
    await tester.tap(find.byType(TagCanvas));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'jeans zara');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Baggy Jeans'), findsNothing);
    await tapText(tester, 'Vintage Jeans');
    expect(find.text('ZARA · Jeans'), findsOneWidget);

    // A cardigan no brand here sells: added to the wardrobe and tagged.
    await addGreyCardigan(tester);
    expect(find.text('TIMEOFLESS · Grey Cardigan'), findsOneWidget);
    await tapText(tester, 'Next');

    expect(find.byType(PostingDetailsPage), findsOneWidget);
    expect(find.byType(AppTabBar), findsNothing);
    expect(find.text('2 items tagged in this outfit'), findsOneWidget);
    await type(tester, 0, 'Weekend denim');
    await type(tester, 1, 'Tashkent');
    await tapText(tester, 'Casual');
    expect(find.text('ZARA'), findsOneWidget, reason: 'mentioned brand');
    await tapText(tester, 'Next');

    expect(find.byType(PublishPage), findsOneWidget);
    expect(find.byType(AppTabBar), findsNothing);
    expect(find.text('Weekend denim'), findsOneWidget);
    expect(find.text('#Casual'), findsOneWidget);
    expect(find.text('Share to followers'), findsNothing);
    await tapText(tester, 'Publish to Stylper');

    // Back on your profile, which shows the new look right away.
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.byType(AppTabBar), findsOneWidget);
    expect(find.text('Your look is live!'), findsOneWidget);
    expect(imagesOf(_newPhoto), findsWidgets);

    // It opens like any post, with its caption, place and item.
    final newPost = imagesOf(_newPhoto).first.hitTestable();
    await tester.scrollUntilVisible(
      newPost,
      100,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.tap(newPost);
    await tester.pumpAndSettle();
    expect(find.byType(PostDetailPage), findsOneWidget);
    expect(find.text('Tashkent'), findsOneWidget);
    expect(
      find.textContaining('Weekend denim', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('ZARA · Jeans'), findsOneWidget);
    expect(find.text('TIMEOFLESS · Grey Cardigan'), findsOneWidget);
    expect(find.text('Added by John. B'), findsOneWidget);
  });

  testWidgets('the wardrobe\'s "Add New Item" adds to the category', (
    tester,
  ) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Profile');
    await tapText(tester, 'My Wardrobe');
    expect(find.text('3 items'), findsOneWidget, reason: 'tops');

    await addGreyCardigan(tester);
    expect(find.text('4 items'), findsOneWidget);
    await tapText(tester, 'Tops');
    expect(find.text('Grey Cardigan'), findsOneWidget);
  });

  testWidgets('closing posting returns to the tab; a started post asks first', (
    tester,
  ) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Profile');

    // Nothing started: close just leaves.
    await tester.tap(find.bySemanticsLabel('New post'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(MediaSelectionPage), findsNothing);
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.byType(AppTabBar), findsOneWidget);

    // With a photo chosen, back from step 1 asks before discarding.
    await tester.tap(find.bySemanticsLabel('New post'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Next');
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(MediaSelectionPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard post?'), findsOneWidget);
    await tapText(tester, 'Cancel');
    expect(find.byType(MediaSelectionPage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Discard');
    expect(find.byType(MediaSelectionPage), findsNothing);
    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('guests are asked to sign in before posting', (tester) async {
    await launch(tester);
    await tapText(tester, 'Skip for now');

    await tester.tap(find.bySemanticsLabel('New post'));
    await tester.pumpAndSettle();
    expect(find.byType(MediaSelectionPage), findsNothing);
    expect(find.text('Sign in to share your look.'), findsOneWidget);
  });

  testWidgets('follow a post\'s author; their profile agrees, and back', (
    tester,
  ) async {
    await signInAsDemo(tester);
    await tapText(tester, 'Amin');
    expect(find.byType(PostDetailPage), findsOneWidget);

    await tester.tap(find.text('Follow'));
    await tester.pumpAndSettle();
    expect(find.text('Following'), findsOneWidget);

    // Their profile shows it, with one more follower (720 → 721).
    await tester.tap(find.text('Amin').first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
    expect(find.textContaining('721', findRichText: true), findsOneWidget);

    // Unfollow there; the post agrees when you go back.
    await tester.tap(find.text('Following'));
    await tester.pumpAndSettle();
    expect(find.textContaining('720', findRichText: true), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(PostDetailPage), findsOneWidget);
    expect(find.text('Follow'), findsOneWidget);
  });

  testWidgets('your own post has no Follow button', (tester) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Profile');
    final ownPost = imagesOf(AppImages.postJohnCoat).first.hitTestable();
    await tester.scrollUntilVisible(
      ownPost,
      100,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.tap(ownPost);
    await tester.pumpAndSettle();

    expect(find.byType(PostDetailPage), findsOneWidget);
    expect(find.text('Follow'), findsNothing);
    expect(find.text('Following'), findsNothing);
  });

  /// Types into the Search field and waits for the results.
  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(SearchPage),
        matching: find.byType(TextField),
      ),
      query,
    );
    await tester.pump(SearchCubit.debounce + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
  }

  /// The path of the screen showing [widget], e.g. `/search/user/a_amin`.
  String pathOf(WidgetTester tester, Type widget) =>
      GoRouterState.of(tester.element(find.byType(widget))).uri.path;

  testWidgets('search finds people by username; their profile opens in the '
      'Search tab, and Back keeps the search', (tester) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Search');
    expect(find.text('BRANDS ON STYLPER'), findsOneWidget);

    await search(tester, '@amin');
    final aminRow = find.descendant(
      of: find.byType(PersonRow),
      matching: find.text('@amin'),
    );
    expect(aminRow, findsOneWidget);
    await tester.tap(aminRow);
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(pathOf(tester, ProfilePage), '/search/user/a_amin');
    expect(find.byType(AppTabBar), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsOneWidget);
    expect(aminRow, findsOneWidget, reason: 'query and results kept');

    // Leaving the tab and coming back keeps the search too.
    await openTab(tester, 'Home');
    await openTab(tester, 'Search');
    expect(aminRow, findsOneWidget);
  });

  testWidgets('follow someone from search; their profile agrees', (
    tester,
  ) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Search');
    await search(tester, 'amin');

    await tester.tap(find.text('Follow').first);
    await tester.pumpAndSettle();
    expect(find.text('Following'), findsOneWidget);

    await tester.tap(find.text('@amin'));
    await tester.pumpAndSettle();
    expect(find.text('Following'), findsOneWidget);
    expect(find.textContaining('721', findRichText: true), findsOneWidget);
  });

  testWidgets('you find yourself without a Follow button', (tester) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Search');
    await search(tester, 'john');
    expect(find.text('@john'), findsOneWidget);
    expect(find.text('Follow'), findsNothing);
  });

  testWidgets('brands are found by name; their page is coming soon', (
    tester,
  ) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Search');
    await search(tester, 'zara');
    expect(find.text('BRANDS'), findsOneWidget);
    expect(find.text('@zara · 3 items'), findsOneWidget);

    await tester.tap(find.text('ZARA'));
    await tester.pump();
    expect(find.text('Coming soon'), findsOneWidget);

    await search(tester, 'nobody like this');
    expect(
      find.text('No brands or people match “nobody like this”'),
      findsOneWidget,
    );
  });

  testWidgets('trending looks open inside the Search tab', (tester) async {
    await signInAsDemo(tester);
    await openTab(tester, 'Search');
    await tapText(tester, 'Utility chic');
    expect(find.byType(PostDetailPage), findsOneWidget);
    expect(pathOf(tester, PostDetailPage), '/search/post/post_utility_chic');
  });

  testWidgets('guests can search, and are asked to sign in to follow', (
    tester,
  ) async {
    await launch(tester);
    await tapText(tester, 'Skip for now');
    await openTab(tester, 'Search');
    await search(tester, 'leo');
    expect(find.text('@leo'), findsOneWidget);

    await tester.tap(find.text('Follow'));
    await tester.pump();
    expect(find.text('Sign in to follow people.'), findsOneWidget);
  });
}
