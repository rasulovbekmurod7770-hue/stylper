import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylper/app/session/session_cubit.dart';
import 'package:stylper/app/shell/app_shell.dart';
import 'package:stylper/core/constants/app_assets.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/usecase/usecase.dart';
import 'package:stylper/features/auth/domain/usecases/email_auth.dart';
import 'package:stylper/features/auth/domain/usecases/social_auth.dart';
import 'package:stylper/features/auth/presentation/cubits/forgot_password_cubit.dart';
import 'package:stylper/features/auth/presentation/cubits/sign_in_cubit.dart';
import 'package:stylper/features/auth/presentation/cubits/sign_up_cubit.dart';
import 'package:stylper/features/auth/presentation/cubits/social_sign_in_cubit.dart';
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

class _MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

/// The app-wide cubits that post widgets read (provided above the router in
/// the app): a guest session and the like / save state.
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
    ],
    child: child,
  );
}

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
      build: () {
        final getPost = _MockGetPost();
        when(() => getPost(any())).thenAnswer(
          (_) async => Right(
            PostJson.post(
              await FakeBackend(latency: Duration.zero)
                  .post('post_utility_chic'),
            ),
          ),
        );
        return _withAppState(
          BlocProvider(
            create: (_) =>
                PostDetailCubit(getPost, postId: 'post_utility_chic')..load(),
            child: const PostDetailPage(),
          ),
        );
      },
      images: const [
        AppImages.postUtilityChic,
        AppImages.homePersonLeo,
        AppImages.quizCottonCardigan,
        AppImages.quizWhiteTShirt,
        AppImages.quizWideLegTrousers,
        AppImages.homeTrendSoftNeutrals,
        AppImages.postFozil,
        AppImages.homeTrendNoWords,
        AppImages.homeTrendLikeMyOutfit,
      ],
    ),
  ];
}
