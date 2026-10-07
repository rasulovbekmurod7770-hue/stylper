import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/validation_messages.dart';
import '../../../../core/presentation/submission_status.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_password_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/fill_viewport_scroll_view.dart';
import '../../../../core/widgets/linked_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/snackbars.dart';
import '../auth_failure_message.dart';
import '../cubits/sign_in_cubit.dart';
import '../widgets/auth_error_listeners.dart';
import '../widgets/social_auth_section.dart';

/// Figma: "Screen-Login" (2775:2318).
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<SignInCubit>().submit(
      email: _email.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SignInCubit>();

    return SocialSignInErrorListener(
      child: BlocListener<SignInCubit, SignInState>(
        listenWhen: (previous, current) =>
            current.status == SubmissionStatus.failure &&
            previous.status != current.status,
        listener: (context, state) =>
            context.showMessage(state.failure!.message(l10n)),
        child: Scaffold(
          body: SafeArea(
            child: FillViewportScrollView(
              child: AutofillGroup(
                child: Column(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: BlocBuilder<SignInCubit, SignInState>(
                        builder: (context, state) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ScreenHeader(
                              title: l10n.signInTitle,
                              subtitle: l10n.signInSubtitle,
                            ),
                            const SizedBox(height: 28),
                            AppTextField(
                              label: l10n.emailLabel,
                              iconAsset: AppIcons.mail,
                              controller: _email,
                              hintText: l10n.emailHint,
                              errorText: state.emailError?.message(l10n),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              autocorrect: false,
                              onChanged: (_) => cubit.fieldChanged(),
                            ),
                            const SizedBox(height: 16),
                            AppPasswordField(
                              label: l10n.passwordLabel,
                              controller: _password,
                              hintText: l10n.passwordHint,
                              showPasswordLabel: l10n.showPassword,
                              hidePasswordLabel: l10n.hidePassword,
                              errorText: state.passwordError?.message(l10n),
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onChanged: (_) => cubit.fieldChanged(),
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: GestureDetector(
                                onTap: () =>
                                    context.go(AppRoutes.forgotPassword),
                                child: Text(
                                  l10n.forgotPasswordLink,
                                  style: AppTypography.link,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            PrimaryButton(
                              label: l10n.signIn,
                              isLoading: state.status.isInProgress,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 28),
                            SocialAuthSection(dividerText: l10n.orSignInWith),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: LinkedText(
                        template: l10n.noAccountPrompt('{link}'),
                        links: {
                          '{link}': TextLink(
                            l10n.signUpLink,
                            () => context.go(AppRoutes.signUp),
                          ),
                        },
                        style: AppTypography.footer,
                        linkStyle: AppTypography.footerLink,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
