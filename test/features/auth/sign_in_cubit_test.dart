import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylper/core/presentation/submission_status.dart';
import 'package:stylper/core/validation/validators.dart';
import 'package:stylper/features/auth/domain/entities/app_user.dart';
import 'package:stylper/features/auth/domain/failures/auth_failure.dart';
import 'package:stylper/features/auth/domain/usecases/email_auth.dart';
import 'package:stylper/features/auth/presentation/cubits/sign_in_cubit.dart';

class _MockSignInWithEmail extends Mock implements SignInWithEmail {}

void main() {
  late _MockSignInWithEmail signIn;

  setUpAll(() {
    registerFallbackValue(const EmailCredentials(email: '', password: ''));
  });

  setUp(() => signIn = _MockSignInWithEmail());

  blocTest<SignInCubit, SignInState>(
    'shows field errors and does not call the use case for invalid input',
    build: () => SignInCubit(signIn),
    act: (cubit) => cubit.submit(email: 'not-an-email', password: ''),
    expect: () => const [
      SignInState(
        emailError: ValidationError.invalidEmail,
        passwordError: ValidationError.required,
      ),
    ],
    verify: (_) => verifyNever(() => signIn(any())),
  );

  blocTest<SignInCubit, SignInState>(
    'reports progress then success',
    build: () {
      when(
        () => signIn(any()),
      ).thenAnswer((_) async => const Right(AppUser(id: '1', email: 'a@b.co')));
      return SignInCubit(signIn);
    },
    act: (cubit) => cubit.submit(email: 'a@b.co', password: 'secret'),
    expect: () => const [
      SignInState(status: SubmissionStatus.inProgress),
      SignInState(status: SubmissionStatus.success),
    ],
  );

  blocTest<SignInCubit, SignInState>(
    'reports the failure from the repository',
    build: () {
      when(() => signIn(any())).thenAnswer(
        (_) async =>
            const Left(AuthFailure(AuthFailureReason.invalidCredentials)),
      );
      return SignInCubit(signIn);
    },
    act: (cubit) => cubit.submit(email: 'a@b.co', password: 'wrong'),
    expect: () => const [
      SignInState(status: SubmissionStatus.inProgress),
      SignInState(
        status: SubmissionStatus.failure,
        failure: AuthFailure(AuthFailureReason.invalidCredentials),
      ),
    ],
  );
}
