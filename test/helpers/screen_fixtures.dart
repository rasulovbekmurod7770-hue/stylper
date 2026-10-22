import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylper/app/session/session_cubit.dart';
import 'package:stylper/app/shell/app_shell.dart';
import 'package:stylper/core/constants/app_assets.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/core/usecase/usecase.dart';
import 'package:stylper/features/auth/domain/usecases/email_auth.dart';
import 'package:stylper/features/auth/domain/usecases/social_auth.dart';
import 'package:stylper/features/auth/presentation/cubits/forgot_password_cubit.dart';
import 'package:stylper/features/auth/presentation/cubits/sign_in_cubit.dart';
import 'package:stylper/features/auth/presentation/cubits/sign_up_cubit.dart';
import 'package:stylper/features/auth/presentation/cubits/social_sign_in_cubit.dart';
import 'package:stylper/features/auth/presentation/pages/check_email_page.dart';
import 'package:stylper/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:stylper/features/auth/presentation/pages/sign_in_page.dart';
import 'package:stylper/features/auth/presentation/pages/sign_up_page.dart';
import 'package:stylper/features/auth/presentation/pages/welcome_page.dart';
import 'package:stylper/features/home/data/models/home_feed_json.dart';
import 'package:stylper/features/home/domain/usecases/get_home_feed.dart';
import 'package:stylper/features/home/presentation/cubits/home_feed_cubit.dart';
import 'package:stylper/features/home/presentation/pages/home_page.dart';
import 'package:stylper/features/onboarding/data/datasources/style_quiz_local_data_source.dart';
import 'package:stylper/features/onboarding/domain/entities/profile_details.dart';
import 'package:stylper/features/onboarding/domain/entities/style_quiz.dart';
import 'package:stylper/features/onboarding/domain/usecases/onboarding_usecases.dart';
import 'package:stylper/features/onboarding/presentation/cubits/profile_setup_cubit.dart';
import 'package:stylper/features/onboarding/presentation/cubits/style_quiz_cubit.dart';
import 'package:stylper/features/onboarding/presentation/pages/profile_setup_page.dart';
import 'package:stylper/features/onboarding/presentation/pages/style_quiz_page.dart';
import 'package:stylper/features/post/data/models/post_json.dart';
import 'package:stylper/features/post/domain/usecases/post_usecases.dart';
import 'package:stylper/features/post/presentation/cubits/post_detail_cubit.dart';
import 'package:stylper/features/post/presentation/cubits/post_engagement_cubit.dart';
import 'package:stylper/features/post/presentation/pages/post_detail_page.dart';
import 'package:stylper/features/posting/data/datasources/posting_remote_data_source.dart';
import 'package:stylper/features/posting/data/repositories/posting_repository_impl.dart';
import 'package:stylper/features/posting/domain/entities/post_draft.dart';
import 'package:stylper/features/posting/domain/failures/posting_failure.dart';
import 'package:stylper/features/posting/domain/repositories/posting_repository.dart';
import 'package:stylper/features/posting/domain/usecases/posting_usecases.dart';
import 'package:stylper/features/posting/presentation/cubits/media_picker_cubit.dart';
import 'package:stylper/features/posting/presentation/cubits/post_draft_cubit.dart';
import 'package:stylper/features/posting/presentation/cubits/published_posts_cubit.dart';
import 'package:stylper/features/posting/presentation/cubits/tag_search_cubit.dart';
import 'package:stylper/features/posting/presentation/gallery_thumbnails.dart';
import 'package:stylper/features/posting/presentation/pages/media_selection_page.dart';
import 'package:stylper/features/posting/presentation/pages/posting_details_page.dart';
import 'package:stylper/features/posting/presentation/pages/publish_page.dart';
import 'package:stylper/features/posting/presentation/pages/tag_items_page.dart';
import 'package:stylper/features/posting/presentation/widgets/posting_widgets.dart';
import 'package:stylper/features/product/data/models/product_json.dart';
import 'package:stylper/features/product/domain/usecases/get_product.dart';
import 'package:stylper/features/product/presentation/cubits/product_detail_cubit.dart';
import 'package:stylper/features/product/presentation/pages/product_detail_page.dart';
import 'package:stylper/features/profile/data/models/profile_json.dart';
import 'package:stylper/features/profile/domain/repositories/profile_repository.dart';
import 'package:stylper/features/profile/domain/usecases/profile_usecases.dart';
import 'package:stylper/features/profile/domain/entities/profile_settings.dart';
import 'package:stylper/features/profile/presentation/cubits/edit_profile_cubit.dart';
import 'package:stylper/features/profile/presentation/cubits/following_cubit.dart';
import 'package:stylper/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:stylper/features/profile/presentation/cubits/saved_posts_cubit.dart';
import 'package:stylper/features/profile/presentation/cubits/settings_cubit.dart';
import 'package:stylper/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:stylper/features/profile/presentation/pages/profile_page.dart';
import 'package:stylper/features/profile/presentation/widgets/profile_header.dart';
import 'package:stylper/features/profile/presentation/widgets/profile_sections.dart';
import 'package:stylper/features/profile/presentation/widgets/settings_sheet.dart';
import 'package:stylper/features/search/data/datasources/search_remote_data_source.dart';
import 'package:stylper/features/search/data/repositories/search_repository_impl.dart';
import 'package:stylper/features/search/domain/usecases/search_usecases.dart';
import 'package:stylper/features/search/presentation/cubits/search_cubit.dart';
import 'package:stylper/features/search/presentation/pages/search_page.dart';
import 'package:stylper/features/wardrobe/data/models/wardrobe_json.dart';
import 'package:stylper/features/posting/domain/entities/taggable_item.dart';
import 'package:stylper/features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import 'package:stylper/features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import 'package:stylper/features/wardrobe/domain/entities/wardrobe.dart';
import 'package:stylper/features/wardrobe/domain/failures/wardrobe_failure.dart';
import 'package:stylper/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:stylper/features/wardrobe/presentation/cubits/add_item_cubit.dart';
import 'package:stylper/features/wardrobe/presentation/widgets/add_item_card.dart';
import 'package:stylper/features/wardrobe/presentation/widgets/add_item_sheet.dart';
import 'package:stylper/features/wardrobe/domain/usecases/wardrobe_usecases.dart';
import 'package:stylper/features/wardrobe/presentation/cubits/wardrobe_cubit.dart';
import 'package:stylper/features/wardrobe/presentation/pages/wardrobe_page.dart';
import 'package:stylper/features/wardrobe/presentation/cubits/wardrobe_membership_cubit.dart';

import 'fake_media.dart';
import 'screen_harness.dart';

class _MockSignInWithEmail extends Mock implements SignInWithEmail {}

class _MockSignUpWithEmail extends Mock implements SignUpWithEmail {}

class _MockSendPasswordResetEmail extends Mock
    implements SendPasswordResetEmail {}

class _MockSignInWithSocialProvider extends Mock
    implements SignInWithSocialProvider {}

class _MockSaveProfile extends Mock implements SaveProfile {}

class _MockGetStyleQuiz extends Mock implements GetStyleQuiz {}

class _MockCompleteStyleQuiz extends Mock implements CompleteStyleQuiz {}

class _MockGetHomeFeed extends Mock implements GetHomeFeed {}

class _MockGetPost extends Mock implements GetPost {}

class _MockSetPostLiked extends Mock implements SetPostLiked {}

class _MockSetPostSaved extends Mock implements SetPostSaved {}

class _MockSetInWardrobe extends Mock implements SetInWardrobe {}

class _MockGetProduct extends Mock implements GetProduct {}

class _MockGetProfile extends Mock implements GetProfile {}

class _MockSetFollowing extends Mock implements SetFollowing {}

class _MockGetSavedPosts extends Mock implements GetSavedPosts {}

class _MockUpdateProfile extends Mock implements UpdateProfile {}

class _MockGetSettings extends Mock implements GetSettings {}

class _MockUpdateSettings extends Mock implements UpdateSettings {}

class _MockGetWardrobe extends Mock implements GetWardrobe {}

/// The fake backend with the demo account (John) signed in.
Future<(FakeBackend, String)> _signedInBackend() async {
  final backend = FakeBackend(latency: Duration.zero);
  final session = await backend.login(
    FakeBackend.demoEmail,
    FakeBackend.demoPassword,
  );
  return (backend, session['accessToken']! as String);
}

/// A screen inside the tab shell, as in the Figma frames with a tab bar.
Widget _inShell(Widget page, {MainTab tab = MainTab.home}) => _withAppState(
  AppShell(currentTab: tab, onTabSelected: (_) {}, child: page),
);

/// John's own profile, with his saved posts.
Widget _ownProfile() {
  final getSaved = _MockGetSavedPosts();
  when(() => getSaved(any())).thenAnswer((_) async {
    final (backend, token) = await _signedInBackend();
    return Right(ProfileJson.saved(await backend.savedPosts(token)));
  });
  return _inShell(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _ownProfileCubit()),
        BlocProvider(create: (_) => SavedPostsCubit(getSaved)),
      ],
      child: const ProfilePage(),
    ),
    tab: MainTab.profile,
  );
}

/// Edit Profile, starting from John's profile.
Widget _editProfile() {
  final getProfile = _MockGetProfile();
  when(() => getProfile(any())).thenAnswer((_) async {
    final (backend, token) = await _signedInBackend();
    return Right(
      ProfileJson.profile(
        await backend.userProfile(ProfileRepository.me, token: token),
      ),
    );
  });
  return _inShell(
    BlocProvider(
      create: (_) => EditProfileCubit(getProfile, _MockUpdateProfile())..load(),
      child: const EditProfilePage(),
    ),
    tab: MainTab.profile,
  );
}

/// The Settings sheet's content, as opened from your profile: private
/// account on.
Widget _settingsSheet() {
  final getSettings = _MockGetSettings();
  when(() => getSettings(any()))
      .thenAnswer((_) async => const Right(ProfileSettings(isPrivate: true)));
  return Scaffold(
    body: SafeArea(
      child: BlocProvider(
        create: (_) =>
            SettingsCubit(getSettings, _MockUpdateSettings())..load(),
        child: SettingsSheet(onSignOut: () {}),
      ),
    ),
  );
}

/// John's profile, loading.
ProfileCubit _ownProfileCubit() {
  final getProfile = _MockGetProfile();
  when(() => getProfile(any())).thenAnswer((_) async {
    final (backend, token) = await _signedInBackend();
    return Right(
      ProfileJson.profile(
        await backend.userProfile(ProfileRepository.me, token: token),
      ),
    );
  });
  return ProfileCubit(getProfile, userId: ProfileRepository.me)..load();
}

/// John's posting endpoints on the fake backend, signed in on first use.
class _JohnsPosting implements PostingRepository {
  /// The signed-in backend, shared with [_JohnsWardrobe].
  late final Future<(FakeBackend, InMemoryAuthTokenStore)> session = () async {
    final (backend, token) = await _signedInBackend();
    final tokens = InMemoryAuthTokenStore();
    await tokens.save(token);
    return (backend, tokens);
  }();

  late final Future<PostingRepository> _repository = session.then(
    (s) =>
        PostingRepositoryImpl(remote: FakePostingRemoteDataSource(s.$1, s.$2)),
  );

  @override
  Future<Either<PostingFailure, List<TaggableItem>>> searchItems(
    String query, {
    String? category,
    bool mine = false,
  }) async =>
      (await _repository).searchItems(query, category: category, mine: mine);

  @override
  Future<Either<PostingFailure, List<TaggableItem>>> recentTags() async =>
      (await _repository).recentTags();

  @override
  Future<Either<PostingFailure, List<String>>> styles() async =>
      (await _repository).styles();

  @override
  Future<Either<PostingFailure, String>> publish(PostDraft draft) async =>
      (await _repository).publish(draft);
}

/// John's wardrobe on the same backend as his posting endpoints, so items
/// he adds while tagging can be found and published.
class _JohnsWardrobe implements WardrobeRepository {
  _JohnsWardrobe(this._posting);

  final _JohnsPosting _posting;

  late final Future<WardrobeRepository> _repository = _posting.session.then(
    (s) => WardrobeRepositoryImpl(
      remote: FakeWardrobeRemoteDataSource(s.$1, s.$2),
    ),
  );

  @override
  Future<Either<WardrobeFailure, List<WardrobeCategory>>>
  getCategories() async => (await _repository).getCategories();

  @override
  Future<Either<WardrobeFailure, List<WardrobeItem>>> getItems(
    String category,
  ) async => (await _repository).getItems(category);

  @override
  Future<Either<WardrobeFailure, bool>> setInWardrobe(
    String itemId, {
    required bool saved,
  }) async => (await _repository).setInWardrobe(itemId, saved: saved);

  @override
  Future<Either<WardrobeFailure, WardrobeItem>> addItem(
    NewWardrobeItem item,
  ) async => (await _repository).addItem(item);
}

/// The Figma posting sample: John's grey knit with two tagged items, posted
/// in Tashkent as Minimal / Casual, filled in up to [step] (0–3).
Widget _posting(Widget page, {required int step}) {
  final posting = _JohnsPosting();
  final wardrobe = _JohnsWardrobe(posting);
  final draft = PostDraftCubit(
    GetPostStyles(posting),
    PublishPost(posting),
    _MockGetSettings(),
  )..loadStyles();
  if (step >= 1) draft.setPhoto('assets/images/posts/john_knit.webp');
  if (step >= 2) {
    draft
      ..addTag(
        const DraftTag(
          item: TaggableItem(
            id: 'p_polo_arket',
            name: 'Rugby Polo Sweater',
            label: 'Sweater',
            brand: 'ARKET',
            imagePath: AppImages.quizRugbyPoloSweater,
          ),
          x: 0.42,
          y: 0.24,
        ),
      )
      ..addTag(
        const DraftTag(
          item: TaggableItem(
            id: 'p_jeans_kink',
            name: 'Baggy Jeans',
            label: 'Jeans',
            brand: 'Kink',
            imagePath: AppImages.quizBaggyJeans,
          ),
          x: 0.5,
          y: 0.62,
        ),
      )
      ..setLocation('Tashkent')
      ..toggleStyle('minimal')
      ..toggleStyle('casual');
  }
  if (step >= 3) {
    draft.setCaption(
      'Minimal tones for autumn season. Soft layering makes it easy.',
    );
  }
  return _withAppState(
    RepositoryProvider<GalleryThumbnails>.value(
      value: const AssetGalleryThumbnails(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: draft),
          BlocProvider(
            create: (_) =>
                TagSearchCubit(SearchItems(posting), GetRecentTags(posting))
                  ..load(),
          ),
          BlocProvider(create: (_) => AddItemCubit(AddWardrobeItem(wardrobe))),
          BlocProvider(
            create: (_) => MediaPickerCubit(FakeMediaRepository())..start(),
          ),
          BlocProvider(create: (_) => _ownProfileCubit()),
        ],
        child: page,
      ),
    ),
  );
}

/// The Search tab on the fake backend, as a guest.
Widget _search() {
  final repository = SearchRepositoryImpl(
    remote: FakeSearchRemoteDataSource(
      FakeBackend(latency: Duration.zero),
      InMemoryAuthTokenStore(),
    ),
  );
  return _inShell(
    BlocProvider(
      create: (_) => SearchCubit(
        GetSearchDiscovery(repository),
        SearchBrandsAndPeople(repository),
      )..loadDiscovery(),
      child: const SearchPage(),
    ),
    tab: MainTab.search,
  );
}

/// Types [query] into Search and waits for the results; [keyboard] is the
/// on-screen keyboard's height, if it's up.
/// John's wardrobe in the Profile tab.
Widget _wardrobe() {
  final getWardrobe = _MockGetWardrobe();
  when(() => getWardrobe(any())).thenAnswer((_) async {
    final (backend, token) = await _signedInBackend();
    return Right(WardrobeJson.categories(await backend.wardrobe(token)));
  });
  return _inShell(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WardrobeCubit(getWardrobe)..load()),
        BlocProvider(
          create: (_) =>
              AddItemCubit(AddWardrobeItem(_JohnsWardrobe(_JohnsPosting()))),
        ),
      ],
      child: const WardrobePage(),
    ),
    tab: MainTab.profile,
  );
}

/// Opens "Add New Item" (while tagging, or on the wardrobe) and fills in the
/// Figma sample (Grey
/// Cardigan by TIMEOFLESS, a top, 350 000 soʻm), with the keyboard up if given.
Future<void> _fillAddItem(WidgetTester tester, {double keyboard = 0}) async {
  final card = find.byType(AddItemCard);
  await tester.ensureVisible(card);
  await tester.pump();
  await tester.tap(card);
  await settleState(tester);
  final fields = find.descendant(
    of: find.byType(BottomSheet),
    matching: find.byType(TextField),
  );
  await tester.enterText(fields.at(0), 'Grey Cardigan');
  await tester.enterText(fields.at(1), 'TIMEOFLESS');
  await tester.enterText(fields.at(2), '350000');
  final tops = find.byKey(const ValueKey(WardrobeCategories.tops));
  await tester.ensureVisible(tops);
  await tester.pump();
  await tester.tap(tops);
  if (keyboard > 0) {
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  } else {
    FocusManager.instance.primaryFocus?.unfocus();
  }
  await settleState(tester);
}

/// John's post tagging the cardigan he added himself (TIMEOFLESS, 350 000 soʻm) and
/// Kink's jeans.
Widget _postWithOwnItem() {
  final getPost = _MockGetPost();
  when(() => getPost(any())).thenAnswer((_) async {
    final (backend, token) = await _signedInBackend();
    final item = await backend.addWardrobeItem(token, {
      'name': 'Grey Cardigan',
      'brand': 'TIMEOFLESS',
      'category': 'tops',
      'price': {'amount': 350000, 'currency': 'UZS'},
    });
    return Right(
      PostJson.post(
        await backend.publishPost(token, {
          'image': 'assets/images/posts/john_knit.webp',
          'styles': ['minimal'],
          'tags': [
            {'itemId': item['id'], 'x': 0.42, 'y': 0.24},
            {'productId': 'p_jeans_kink', 'x': 0.5, 'y': 0.62},
          ],
        }),
      ),
    );
  });
  return _inShell(
    BlocProvider(
      create: (_) => PostDetailCubit(getPost, postId: 'own')..load(),
      child: const PostDetailPage(),
    ),
  );
}

Future<void> _typeSearch(
  WidgetTester tester,
  String query, {
  double keyboard = 0,
}) async {
  await tester.enterText(find.byType(TextField), query);
  if (keyboard == 0) FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump(SearchCubit.debounce + const Duration(milliseconds: 50));
  if (keyboard > 0) tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  await settleState(tester);
  await settleAssets(tester);
}

/// Every content photo, for screens that show many.
const _allContentImages = ['assets/images/'];

class _MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

/// The app-wide cubits that screens read (provided above the router in the
/// app): a guest session, the like / save state, wardrobe membership,
/// newly published posts and follows.
Widget _withAppState(Widget child) {
  final session = _MockSessionCubit();
  whenListen(
    session,
    const Stream<SessionState>.empty(),
    initialState: const SessionGuest(),
  );
  return MultiBlocProvider(
    providers: [
      BlocProvider<SessionCubit>.value(value: session),
      BlocProvider(
        create: (_) =>
            PostEngagementCubit(_MockSetPostLiked(), _MockSetPostSaved()),
      ),
      BlocProvider(
        create: (_) => WardrobeMembershipCubit(_MockSetInWardrobe()),
      ),
      BlocProvider(create: (_) => PublishedPostsCubit()),
      BlocProvider(create: (_) => FollowingCubit(_MockSetFollowing())),
    ],
    child: child,
  );
}

/// The Figma post sample: Leo's "Utility chic".
Widget _post() {
  final getPost = _MockGetPost();
  when(() => getPost(any())).thenAnswer(
    (_) async => Right(
      PostJson.post(
        await FakeBackend(latency: Duration.zero).post('post_utility_chic'),
      ),
    ),
  );
  return _inShell(
    BlocProvider(
      create: (_) =>
          PostDetailCubit(getPost, postId: 'post_utility_chic')..load(),
      child: const PostDetailPage(),
    ),
  );
}

const _postImages = [
  AppImages.postUtilityChic,
  AppImages.homePersonLeo,
  AppImages.quizCottonCardigan,
  AppImages.quizWhiteTShirt,
  AppImages.quizWideLegTrousers,
  AppImages.homeTrendSoftNeutrals,
  AppImages.postFozil,
  AppImages.homeTrendNoWords,
  AppImages.homeTrendLikeMyOutfit,
];

/// One app screen with its cubits (backed by unused mock use
/// cases) and the sample content from the Figma frame.
class ScreenFixture {
  const ScreenFixture({
    required this.name,
    required this.build,
    this.images = const [],
    this.fillIn,
    this.goldenSize = figmaFrameSize,
  });

  /// Also the golden file name: `goldens/screens/<name>.png`.
  final String name;
  final Widget Function() build;
  final List<String> images;

  /// Enters the design's sample content after the screen is pumped.
  final Future<void> Function(WidgetTester tester)? fillIn;

  /// Viewport for the golden: the Figma frame size, so they can be compared.
  final Size goldenSize;
}

StyleQuiz _bundledQuiz() {
  final items = const StyleQuizLocalDataSource().getItems().map(
    (model) => model.toEntity(),
  );
  return StyleQuiz(
    tops: [...items.where((i) => i.category == OutfitCategory.top)],
    bottoms: [...items.where((i) => i.category == OutfitCategory.bottom)],
  );
}

Widget _withSocialSignIn(Widget page, BlocProvider<Object?> primary) =>
    MultiBlocProvider(
      providers: [
        primary,
        BlocProvider(
          create: (_) => SocialSignInCubit(_MockSignInWithSocialProvider()),
        ),
      ],
      child: page,
    );

List<ScreenFixture> screenFixtures() {
  registerFallbackValue(const NoParams());
  late SignUpCubit signUp;
  late ProfileSetupCubit profileSetup;

  return [
    ScreenFixture(
      name: 'welcome',
      build: () => WelcomePage(onContinueAsGuest: () {}),
      images: const [
        AppImages.welcomeOutfit1,
        AppImages.welcomeOutfit2,
        AppImages.welcomeOutfit3,
        AppImages.welcomeOutfit4,
      ],
    ),
    ScreenFixture(
      name: 'sign_in',
      build: () => _withSocialSignIn(
        const SignInPage(),
        BlocProvider<SignInCubit>(
          create: (_) => SignInCubit(_MockSignInWithEmail()),
        ),
      ),
      fillIn: (tester) async {
        await fillField(tester, 0, 'developer@stylper.ai');
        await fillField(tester, 1, 'stylper12345');
      },
    ),
    ScreenFixture(
      name: 'sign_up',
      build: () => _withSocialSignIn(
        const SignUpPage(),
        BlocProvider<SignUpCubit>(
          create: (_) => signUp = SignUpCubit(_MockSignUpWithEmail()),
        ),
      ),
      fillIn: (tester) async {
        await fillField(tester, 0, 'katty.miller@stylper.ai');
        await fillField(tester, 1, 'stylper12345');
        await fillField(tester, 2, 'stylper12345');
        signUp.termsToggled(true);
        await settleState(tester);
      },
    ),
    ScreenFixture(
      name: 'forgot_password',
      build: () => BlocProvider(
        create: (_) => ForgotPasswordCubit(_MockSendPasswordResetEmail()),
        child: const ForgotPasswordPage(),
      ),
    ),
    // Not in Figma: shown after sign-up when the email must be confirmed.
    ScreenFixture(
      name: 'check_email',
      build: () => const CheckEmailPage(email: 'new.user@stylper.ai'),
    ),
    ScreenFixture(
      name: 'profile_setup',
      build: () => BlocProvider(
        create: (_) => profileSetup = ProfileSetupCubit(_MockSaveProfile()),
        child: const ProfileSetupPage(),
      ),
      fillIn: (tester) async {
        profileSetup.genderSelected(Gender.male);
        await settleState(tester);
      },
    ),
    ScreenFixture(
      name: 'style_quiz',
      build: () {
        final getQuiz = _MockGetStyleQuiz();
        when(() => getQuiz(any()))
            .thenAnswer((_) async => Right(_bundledQuiz()));
        return BlocProvider(
          create: (_) =>
              StyleQuizCubit(getQuiz, _MockCompleteStyleQuiz())..load(),
          child: const StyleQuizPage(),
        );
      },
      images: const [AppImages.quizWhiteTShirt, AppImages.quizBaggyJeans],
    ),
    ScreenFixture(
      name: 'home',
      goldenSize: const Size(390, 1287),
      build: () {
        final getFeed = _MockGetHomeFeed();
        when(() => getFeed(any())).thenAnswer(
          (_) async => Right(
            HomeFeedJson.parse(
              await FakeBackend(latency: Duration.zero).homeFeed(),
            ),
          ),
        );
        return _withAppState(
          AppShell(
            currentTab: MainTab.home,
            onTabSelected: (_) {},
            child: BlocProvider(
              create: (_) => HomeFeedCubit(getFeed)..load(),
              child: const HomePage(),
            ),
          ),
        );
      },
      images: const [
        AppImages.homeHeroMina,
        AppImages.homeAvatarMina,
        AppImages.homePersonSofia,
        AppImages.homePersonLeo,
        AppImages.homePersonAmin,
        AppImages.homeTrendUtilityChic,
        AppImages.homeTrendSoftNeutrals,
        AppImages.homeTrendNoWords,
        AppImages.homeTrendLikeMyOutfit,
      ],
    ),
    ScreenFixture(
      name: 'post',
      goldenSize: const Size(390, 1287),
      build: _post,
      images: _postImages,
    ),
    // Figma 2775:2953: the same post with the cardigan's tag tapped.
    ScreenFixture(
      name: 'post_tag',
      goldenSize: const Size(390, 1287),
      build: _post,
      images: _postImages,
      fillIn: (tester) async {
        await tester.tap(find.text('COS · Cardigan'));
        await settleState(tester);
      },
    ),
    ScreenFixture(
      name: 'product',
      goldenSize: const Size(390, 1611),
      build: () {
        final getProduct = _MockGetProduct();
        when(() => getProduct(any())).thenAnswer(
          (_) async => Right(
            ProductJson.detail(
              await FakeBackend(latency: Duration.zero)
                  .product('p_cardigan_cos'),
            ),
          ),
        );
        return _inShell(
          BlocProvider(
            create: (_) =>
                ProductDetailCubit(getProduct, productId: 'p_cardigan_cos')
                  ..load(),
            child: const ProductDetailPage(),
          ),
        );
      },
      images: _allContentImages,
    ),
    ScreenFixture(
      name: 'profile',
      goldenSize: const Size(390, 1322),
      build: _ownProfile,
      images: _allContentImages,
    ),
    // Not in Figma: Edit Profile and the Settings sheet.
    ScreenFixture(name: 'edit_profile', build: _editProfile),
    ScreenFixture(name: 'settings_sheet', build: _settingsSheet),
    // Figma "Profile 4": the Saved tab, scrolled to the compact header.
    ScreenFixture(
      name: 'profile_saved',
      build: _ownProfile,
      images: _allContentImages,
      fillIn: (tester) async {
        final scroll = find.byType(CustomScrollView).first;
        const savedTab = ValueKey(ProfileTab.saved);
        await tester.dragUntilVisible(
          find.byKey(savedTab),
          scroll,
          const Offset(0, -300),
        );
        await tester.tap(find.byKey(savedTab));
        await settleState(tester);
        // Just far enough for the tab bar to pin under the compact header.
        final tabBarTop = tester.getTopLeft(find.byType(ProfileTabBar)).dy;
        final headerBottom = tester
            .getBottomLeft(find.byType(ProfileTopBar))
            .dy;
        final position = tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position;
        position.jumpTo(position.pixels + tabBarTop - headerBottom);
        await settleState(tester);
        await settleAssets(tester, precacheImages: _allContentImages);
      },
    ),
    ScreenFixture(
      name: 'wardrobe',
      build: _wardrobe,
      images: _allContentImages,
    ),
    // Not in Figma: the wardrobe's "Add New Item" opens the item details
    // sheet (2974:66565) over the tab bar. With the keyboard up it looks as
    // in posting_add_item_keyboard, so that one covers both.
    ScreenFixture(
      name: 'wardrobe_add_item',
      build: _wardrobe,
      images: _allContentImages,
      fillIn: _fillAddItem,
    ),
    // Not in Figma: the claude.ai prototype's Search screen. Before typing,
    // then "k" (brands Kink and ARKET, people katty_miller and zokir).
    ScreenFixture(name: 'search', build: _search, images: _allContentImages),
    ScreenFixture(
      name: 'search_results',
      build: _search,
      fillIn: (tester) => _typeSearch(tester, 'k'),
    ),
    ScreenFixture(
      name: 'search_keyboard',
      build: _search,
      fillIn: (tester) => _typeSearch(tester, 'k', keyboard: 300),
    ),
    // Figma "Posting" (2849:1017), steps 1–4, and the item search.
    ScreenFixture(
      name: 'posting_media',
      build: () => _posting(const MediaSelectionPage(), step: 0),
      images: _allContentImages,
    ),
    ScreenFixture(
      name: 'posting_tag',
      build: () => _posting(const TagItemsPage(), step: 1),
      images: _allContentImages,
    ),
    ScreenFixture(
      name: 'posting_tag_search',
      build: () => _posting(const TagItemsPage(), step: 1),
      images: _allContentImages,
      fillIn: (tester) async {
        await tester.tap(find.byType(PostingSearchField));
        await settleState(tester);
        await tester.enterText(find.byType(TextField).last, 'jeans');
        // Past the search debounce, with the keyboard up.
        await tester.pump(const Duration(milliseconds: 400));
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await settleState(tester);
        await settleAssets(tester, precacheImages: _allContentImages);
      },
    ),
    // Figma 2974:66565 / 2974:67417: "Add New Item" while tagging — the
    // item details sheet, and the item added and tagged.
    ScreenFixture(
      name: 'posting_add_item',
      build: () => _posting(const TagItemsPage(), step: 1),
      images: _allContentImages,
      fillIn: _fillAddItem,
    ),
    ScreenFixture(
      name: 'posting_add_item_keyboard',
      build: () => _posting(const TagItemsPage(), step: 1),
      images: _allContentImages,
      fillIn: (tester) => _fillAddItem(tester, keyboard: 300),
    ),
    ScreenFixture(
      name: 'posting_item_added',
      build: () => _posting(const TagItemsPage(), step: 1),
      images: _allContentImages,
      fillIn: (tester) async {
        await _fillAddItem(tester);
        await tester.tap(find.byKey(addItemSubmitKey));
        await settleState(tester);
        await settleState(tester);
        // Back to the top, as the Figma frame.
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await settleState(tester);
      },
    ),
    // Not in Figma: a post with an item its author added, its card open.
    ScreenFixture(
      name: 'post_own_item',
      goldenSize: const Size(390, 1287),
      build: _postWithOwnItem,
      images: _allContentImages,
      fillIn: (tester) async {
        await tester.tap(find.text('TIMEOFLESS · Grey Cardigan'));
        await settleState(tester);
      },
    ),
    ScreenFixture(
      name: 'posting_details',
      build: () => _posting(const PostingDetailsPage(), step: 2),
      images: _allContentImages,
    ),
    ScreenFixture(
      name: 'posting_publish',
      build: () => _posting(const PublishPage(), step: 3),
      images: _allContentImages,
    ),
  ];
}
