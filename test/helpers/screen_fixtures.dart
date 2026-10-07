import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylper/core/constants/app_assets.dart';
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
import 'package:stylper/features/onboarding/data/datasources/style_quiz_local_data_source.dart';
import 'package:stylper/features/onboarding/domain/entities/profile_details.dart';
import 'package:stylper/features/onboarding/domain/entities/style_quiz.dart';
import 'package:stylper/features/onboarding/domain/usecases/onboarding_usecases.dart';
import 'package:stylper/features/onboarding/presentation/cubits/profile_setup_cubit.dart';
import 'package:stylper/features/onboarding/presentation/cubits/style_quiz_cubit.dart';
import 'package:stylper/features/onboarding/presentation/pages/profile_setup_page.dart';
import 'package:stylper/features/onboarding/presentation/pages/style_quiz_page.dart';

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

/// One auth/onboarding screen with its cubits (backed by unused mock use
/// cases) and the sample content from the Figma frame.
class ScreenFixture {
  const ScreenFixture({
    required this.name,
    required this.build,
    this.images = const [],
    this.fillIn,
  });

  /// Also the golden file name: `goldens/screens/<name>.png`.
  final String name;
  final Widget Function() build;
  final List<String> images;

  /// Enters the design's sample content after the screen is pumped.
  final Future<void> Function(WidgetTester tester)? fillIn;
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

List<ScreenFixture> authScreenFixtures() {
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
        when(() => getQuiz(any())).thenAnswer((_) async => Right(_bundledQuiz()));
        return BlocProvider(
          create: (_) =>
              StyleQuizCubit(getQuiz, _MockCompleteStyleQuiz())..load(),
          child: const StyleQuizPage(),
        );
      },
      images: const [AppImages.quizWhiteTShirt, AppImages.quizBaggyJeans],
    ),
  ];
}
